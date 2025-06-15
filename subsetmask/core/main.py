from imageio.v3 import imread, imwrite
import napari
import numpy as np
import os

# libraries for get_mask_coords.py
import cv2
import csv
import pandas as pd
from pathlib import Path

# for get_cell_names 
import geopandas as gpd
from shapely.geometry import Polygon
from shapely.geometry import Point

def label_image(image_path):
    """
    Open an image in Napari, let user draw labels, then return the labels layer
    
    """
    
    image = imread(image_path)

    viewer = napari.Viewer()
    viewer.add_image(image, name='Background')
    labels_layer = viewer.add_labels(np.zeros(image.shape[:2], dtype=np.uint8), name='Mask')
    napari.run()

    return labels_layer

def save_masks(labels_layer, output_dir):
    """
    Save the labels layer as individual mask images with white background and black label regions.
    """

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    labels_data = labels_layer.data
    unique_labels = np.unique(labels_data)

    for label in unique_labels:
        if label == 0:  # Skip background
            continue

        # White background, black label
        mask = np.full(labels_data.shape, 255, dtype=np.uint8)
        mask[labels_data == label] = 0

        mask_path = os.path.join(output_dir, f'label_{label}.png')
        imwrite(mask_path, mask)
        print(f'Saved mask for label {label} at {mask_path}')

    print("All masks saved successfully.")

        
def get_mask_coords(mask_path, x_min, x_max, y_min, y_max, out):
    """
    Extracts coordinates from a black-and-white mask image and saves them to a CSV file.
    Parameters:
        mask_path (str): Path to the black-and-white mask image.
        x_min (float): Minimum x-coordinate of the target range.
        x_max (float): Maximum x-coordinate of the target range.
        y_min (float): Minimum y-coordinate of the target range.
        y_max (float): Maximum y-coordinate of the target range.
        out (str): Path to the output CSV file where coordinates will be saved.
    Returns:
        None
    """
    # Load the black-and-white image
    mask = cv2.imread(mask_path, cv2.IMREAD_GRAYSCALE)

    # Get the original image dimensions
    height, width = mask.shape

    # Calculate scaling factors based on the target ranges
    scale_x = (x_max - x_min) / width
    scale_y = (y_max - y_min) / height

    # Apply binary inverse thresholding to select black regions
    _, binary = cv2.threshold(mask, 1, 255, cv2.THRESH_BINARY_INV)

    # Find contours in the black regions
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Open a CSV file to write
    with open(out, mode='w', newline='', encoding="utf-8") as file:
        writer = csv.writer(file)
        
        # Write the header row with 'x' and 'y'
        writer.writerow(['x', 'y'])
        
        # Extract, scale, and write the transformed coordinates of the contours
        for contour in contours:
            for point in contour:
                # Original coordinates (mask space)
                x, y = point[0]
                
                # Scale the x and y coordinates to the target range
                x_transformed = x * scale_x + x_min
                # Correct the y-axis (invert the y-coordinate system)
                y_transformed = y_max - (y * scale_y )
                
                # Write the transformed coordinates to the CSV
                writer.writerow([f"{x_transformed:.4f}", f"{y_transformed:.4f}"])

    print(f"Coordinates have been saved to {out}")

    return None




def get_cell_names(image_coords, x_name, y_name, mask_coords_dict):
    """
    Map mask coordinates to cell coordinates.
    This function takes two DataFrames containing coordinates of image and mask,
    and returns a DataFrame with mapped coordinates.
    Parameters:
    - image_coords: DataFrame with columns for x and y coordinates of the image points.
    - x_name: Name of the column in image_coords for x coordinates.
    - y_name: Name of the column in image_coords for y coordinates.
    - mask_coords_dict: Dictionary of dataframes with mask coordinates
    
    """
    #### Generate spatial points from image_coords
    # 1. Ensure the DataFrame has the correct columns
    if not all(col in image_coords.columns for col in [x_name, y_name]):
        raise ValueError(f"DataFrame must contain columns: {x_name}, {y_name}")

    from shapely.geometry import Point
    # 2. Convert to shapely Point geometries
    geometry = [Point(xy) for xy in zip(image_coords[x_name], image_coords[y_name])]

    # 3. Create GeoDataFrame
    gdf_image_points = gpd.GeoDataFrame(image_coords, geometry=geometry, crs=None)  # set your CRS if known

    #### Generate spatial polygon from mask_coords
    
    # Convert to shapely Polygon geometries
    polygons_dict = {}
    for item in mask_coords_dict.keys():
        coords_df = mask_coords_dict[item]
        polygon = [Polygon(coords_df[["x", "y"]].values)]
        polygons_dict[item] = polygon

    #### Get the overlaps of all polygons in the dictionary agains the image points
    inside_points_dict = {}
    for mask_name, polygon in polygons_dict.items():
        # Create a GeoDataFrame for the polygon
        gdf_polygon = gpd.GeoDataFrame(geometry=polygon, crs=None)  # or use None if unknown CRS

        # Spatial join to find points within the polygon
        points_inside = gpd.sjoin(gdf_image_points, gdf_polygon, how="inner", predicate="within")

        # Store the names of points inside this polygon
        inside_points_dict[mask_name] = points_inside.index.tolist()

    return inside_points_dict


def annotate_metadata(cell_names_dict, metadata_df, ann_col_name):
    """
    Annotate metadata DataFrame with labels based on a dictionary of index groups.

    Parameters:
    - cell_names_dict: Dict with labels as keys and lists of indices (row names) as values.
    - metadata_df: DataFrame to annotate. Index must match the cell names.
    - ann_col_name: Name of the annotation column to create or update.

    Returns:
    - Annotated DataFrame with the updated column.
    """
    # If the annotation column doesn't exist, initialize with 'not_assigned'
    if ann_col_name not in metadata_df.columns:
        metadata_df[ann_col_name] = "not_assigned"

    # Update only the specified rows
    for label, indices in cell_names_dict.items():
        metadata_df.loc[indices, ann_col_name] = label

    return metadata_df
