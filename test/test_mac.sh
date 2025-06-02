#!/bin/bash

# note: conda env must be activated before running this script
# This script is intended to run on macOS and assumes that the necessary Python and R environments are set up.

# Set paths
BASE_DIR="/Users/robin/Documents/GitHub/SubsetMask"
TEST_DIR="$BASE_DIR/test/slide_1"

# Run Python scripts
python3 "$BASE_DIR/software/draw_masks_CLI.py" \
    --image="$TEST_DIR/plot.png" \
    --out="$TEST_DIR/masks"

python3 "$BASE_DIR/software/get_mask_coords_CLI.py" \
    --masks="$TEST_DIR/masks" \
    --out="$TEST_DIR/coordinates" \
    --dims_table="$TEST_DIR/image_dimensions.csv"

# Run R script
Rscript "$BASE_DIR/software/subset_metadata_CLI.R" \
    --metadata="$BASE_DIR/test/metadata.csv" \
    --images_col="slide" \
    --processed_images="$BASE_DIR/test" \
    --ann_col="sample" \
    --out="$BASE_DIR/test/metadata_annotated.csv"
