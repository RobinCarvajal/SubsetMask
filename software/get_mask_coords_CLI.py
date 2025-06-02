
# libraries for CLI
import os
import argparse

# libraries for get_mask_coords.py
import cv2
import csv
import pandas as pd
from pathlib import Path


# ---- Step 1: Parse Arguments ----
parser = argparse.ArgumentParser(description='Get the coordiantes from a mask.')
parser.add_argument('--masks', required=True, help='Path to input the masks directory')
parser.add_argument('--out', required=True, help='Path to output folder for coordinates')
parser.add_argument('--dims_table', required=True, help='Path to dimensions table CSV')
args = parser.parse_args()

masks_dir = args.masks

dims_table_path = args.dims_table
dims_table= pd.read_csv(dims_table_path)

out_dir = args.out


# defining function to get the coordinates from the mask
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
    with open(out, mode='w', newline='') as file:
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

# getting the dimenstions
x_min_value = dims_table.loc[0]["x_min"]
x_max_value = dims_table.loc[0]["x_max"]
y_min_value = dims_table.loc[0]["y_min"]
y_max_value = dims_table.loc[0]["y_max"]

# Loop through each mask in the directory
for mask in os.listdir(masks_dir):
    mask_path = os.path.join(masks_dir, mask)

    # extract the name of the mask without extension
    mask_noext = Path(mask).stem

    # create the output directory if it does not exist
    os.makedirs(out_dir, exist_ok=True)

    # Running Function
    get_mask_coords(
                mask_path=mask_path,
                x_min=x_min_value,
                x_max=x_max_value,
                y_min=y_min_value,
                y_max=y_max_value,
                out=f"{out_dir}/{mask_noext}.csv"
            )
    