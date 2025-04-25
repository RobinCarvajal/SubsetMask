
# %% libraries 

import cv2
import csv
import pandas as pd
from pathlib import Path
import os

# %% function 

def get_mask_coord(mask_path, x_min, x_max, y_min, y_max, out):

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
                writer.writerow([f"{x_transformed:.4f}", f"{y_transformed:.2f}"])

    print(f"Coordinates have been saved to {out}")

    return None


# %% Code 

# regional path
regional_path = "F:/cosmx_data/regional"

# load dimentions csv
dims_table = pd.read_csv(Path(regional_path)/"image_dimensions.csv")
dims_table = dims_table.set_index("sample")


# %%
print(dims_table)

# %% samples list

# actual samples in the folder
samples = os.listdir(Path(regional_path) / "spatial_segmentation_masks")

# %% mask directories dictionary

mask_dirs = {}

# loop
for sample in samples:
    # List files in the directory
    sample_masks = Path(regional_path) / "spatial_segmentation_masks" / sample
    files = os.listdir(sample_masks)
    
    # Create a list to hold filtered files
    filtered_files = []
    
    # Loop through the files and add those that don't start with "._" (hidden files)
    for file in files:
        if not file.startswith("._"):
            filtered_files.append(file)
    
    # Assign the filtered files to the dictionary
    mask_dirs[sample] = filtered_files
    
    #break

print(mask_dirs)


# %% main loop

for sample, mask_list in mask_dirs.items():
    for mask in mask_list:
        print(mask)

        mask_path = Path(regional_path) / "spatial_segmentation_masks" / sample/ mask

        print(mask_path)

        out_dir = f"{regional_path}/segmentation_mask_coords/{sample}"
        os.makedirs(out_dir, exist_ok=True)

        print(out_dir)
        
        # remove png from the mask name
        mask_noext = os.path.splitext(mask)[0]
        print(mask_noext)
        
        get_mask_coord(

            mask_path=mask_path,
            x_min=dims_table.loc[sample]["x_min"],
            x_max=dims_table.loc[sample]["x_max"],
            y_min=dims_table.loc[sample]["y_min"],
            y_max=dims_table.loc[sample]["y_max"],
            out=f"{out_dir}/{mask_noext}_coords.csv"

        )



# %%


