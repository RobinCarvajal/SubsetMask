###--- IMPORTS ---###

# Core scientific libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import io

# Image processing
import cv2
from imageio.v3 import imread

# Spatial and geometry handling
import geopandas as gpd
from shapely.geometry import Polygon, Point

# Visualization
import napari

###--- store_image_as_array ---###
def store_image_as_array(metadata_df, images_col, image_name, x_col, y_col,
                        group_col=None, figsize=(30, 50), dpi=300, dot_size=5, cmap='tab20'):
    """
    Create a dot plot from spatial coordinates and return it as a NumPy array.
    """
    image_metadata_df = metadata_df[metadata_df[images_col] == image_name]

    fig, ax = plt.subplots(figsize=figsize, dpi=dpi)

    if group_col is not None and group_col in image_metadata_df.columns:
        color_values = image_metadata_df[group_col].astype('category').cat.codes
        scatter_kwargs = dict(c=color_values, cmap=cmap)
    else:
        scatter_kwargs = dict(c='black')

    ax.scatter(
            image_metadata_df[x_col],
            image_metadata_df[y_col],
            s=dot_size,
            marker='.',
            alpha=1,
            edgecolors='none',
            linewidths=0,
            **scatter_kwargs
        )

    ax.set_xlim(image_metadata_df[x_col].min(), image_metadata_df[x_col].max())
    ax.set_ylim(image_metadata_df[y_col].min(), image_metadata_df[y_col].max())
    ax.axis("off")
    plt.margins(0)
    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)

    # Save to in-memory buffer
    buf = io.BytesIO()
    plt.savefig(buf, format='png', bbox_inches='tight', pad_inches=0, dpi=dpi)
    plt.close(fig)
    buf.seek(0)

    # Read buffer as NumPy array
    image_np = imread(buf)
    buf.close()

    return image_np

###--- draw_labels ---###
def draw_labels(image_array):
    """
    Open the stored image in Napari, let user draw labels, and return the labels layer.
    """
    if image_array is None:
        raise ValueError("Image array is not set. Run get_image_array() first.")

    viewer = napari.Viewer()
    viewer.add_image(image_array, name='Background')
    labels_layer = viewer.add_labels(np.zeros(image_array.shape[:2], dtype=np.uint8), name='Mask')
    napari.run()

    return labels_layer

###--- labels_to_masks_dict ---###
def labels_to_masks_dict(labels_layer):
    """
    Convert each label in the napari labels layer to a NumPy mask 
    (white background, black mask) and return as a dictionary.

    Parameters:
        labels_layer: napari.layers.Labels
            The napari labels layer with user-drawn labels.

    Returns:
        dict: A dictionary with keys like 'label_1' and values as NumPy arrays (masks).
    """
    if labels_layer is None:
        raise ValueError("Labels layer is None.")

    labels_data = labels_layer.data
    unique_labels = np.unique(labels_data)

    masks_dict = {}
    for label in unique_labels:
        if label == 0:
            continue  # skip background

        mask = np.full(labels_data.shape, 255, dtype=np.uint8)
        mask[labels_data == label] = 0
        masks_dict[f"label_{label}"] = mask

    return masks_dict

###--- get_mask_coords_from_dict ---###
def get_mask_coords_from_dict(mask_dict, x_min, x_max, y_min, y_max):
    """
    Extract coordinates from multiple mask arrays and return a dict of label name → DataFrame.

    Parameters:
        mask_dict (dict): Dict of {label_name: 2D np.ndarray}
        x_min, x_max, y_min, y_max (float): Coordinate bounds for scaling

    Returns:
        dict: {label_name: pd.DataFrame with x, y columns}
    """
    coords_dict = {}

    for label_name, mask_array in mask_dict.items():
        if len(mask_array.shape) != 2:
            raise ValueError(f"Mask for {label_name} is not 2D")

        height, width = mask_array.shape
        scale_x = (x_max - x_min) / width
        scale_y = (y_max - y_min) / height

        # Convert to binary (0 = white, 255 = black label)
        binary_mask = mask_array.copy()
        _, binary_thresh = cv2.threshold(binary_mask, 1, 255, cv2.THRESH_BINARY_INV)

        contours, _ = cv2.findContours(binary_thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        points = []
        for contour in contours:
            for point in contour:
                x, y = point[0]
                x_transformed = x * scale_x + x_min
                y_transformed = y_max - (y * scale_y)
                points.append((x_transformed, y_transformed))

        df = pd.DataFrame(points, columns=["x", "y"])
        coords_dict[label_name] = df

    return coords_dict

###--- get_cell_names ---###
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

###--- annotate_metadata ---###
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