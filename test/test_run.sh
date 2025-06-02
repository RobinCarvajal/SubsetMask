#!/bin/bash

python draw_masks_CLI.py \
--image="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/plot.png" \
--out="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks"

python get_mask_coords_CLI.py \
--masks="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks" \
--out="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/coordinates" \
--dims_table="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/image_dimensions.csv"

# cmd

python draw_masks_CLI.py --image="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/plot.png" --out="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks"

python get_mask_coords_CLI.py --masks="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks" --out="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/coordinates" --dims_table="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/image_dimensions.csv"

"C:/Program Files/R/R-4.5.0/bin/Rscript.exe" subset_seurat_object.R --seurat_obj="H:/projects_work/cosmx_gray/data/gray_lung_slide_1_unprocessed.rds" --processed_images="C:/Users/robin/Documents/GitHub/SubsetMask/test" --metadata_col_name="sample" --out="H:/projects_work/cosmx_gray/data/gray_lung_slide_1_unprocessed_annotated.rds"

# mac
conda activate cosmx_python
cd /Users/robin/Documents/GitHub/SubsetMask/software

python3 draw_masks_CLI.py --image="/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/plot.png" --out="/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks_erase"

python3 get_mask_coords_CLI.py --masks="/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks" --out="/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/coordinates" --dims_table="/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/image_dimensions.csv"

Rscript subset_metadata_CLI.R --metadata="/Users/robin/Documents/GitHub/SubsetMask/test/metadata.csv" --images_col="slide" --processed_images="/Users/robin/Documents/GitHub/SubsetMask/test" --ann_col="sample" --out="/Users/robin/Documents/GitHub/SubsetMask/test/metadata_annotated.csv"
