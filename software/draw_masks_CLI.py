import napari
from imageio import imread, imwrite
import numpy as np
import os
import argparse

# ---- Step 1: Parse Arguments ----
parser = argparse.ArgumentParser(description='Draw masks on an image and save them.')
parser.add_argument('--image', required=True, help='Path to input image')
parser.add_argument('--out', required=True, help='Path to output folder for masks')

args = parser.parse_args()
image_path = args.image
output_dir = args.out

# ---- Step 2: Load the background image ----
background_image = imread(image_path)

# ---- Step 3: Launch Napari ----
viewer = napari.Viewer()

# Add your real background image
viewer.add_image(background_image, name='Background')

# Add labels layer for drawing masks
labels_layer = viewer.add_labels(np.zeros(background_image.shape[:2], dtype=np.uint8), name='Mask')

# Open the Napari GUI
napari.run()

# ---- Step 4: After drawing, save each mask separately ----
mask = labels_layer.data

# Get all unique labels (except background 0)
labels = np.unique(mask)
labels = labels[labels != 0]

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Save each mask as a separate PNG (white background, black mask)
for label in labels:
    single_mask = np.full(mask.shape, 255, dtype=np.uint8)
    single_mask[mask == label] = 0
    filename = os.path.join(output_dir, f'label_{label}.png') # could also use f'mask_{label}.png'
    imwrite(filename, single_mask)
    print(f"Saved {filename}")

print("All masks saved successfully with black masks on white background!")
