@echo off
REM Activate your conda environment (if needed)
call conda activate cosmx_python

REM Change to the directory with your Python scripts
cd /d "C:\Users\robin\Documents\GitHub\SubsetMask\software"

REM Step 1: Draw masks
python draw_masks_CLI.py ^
  --image="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/plot.png" ^
  --out="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks"

REM Step 2: Extract coordinates from masks
python get_mask_coords_CLI.py ^
  --masks="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/masks" ^
  --out="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/coordinates" ^
  --dims_table="C:/Users/robin/Documents/GitHub/SubsetMask/test/slide_1/image_dimensions.csv"

REM Step 3: Subset Seurat object in R
"C:\Program Files\R\R-4.5.0\bin\Rscript.exe" subset_seurat_object.R ^
  --seurat_obj="H:/projects_work/cosmx_gray/data/gray_lung_slide_1_unprocessed.rds" ^
  --processed_images="C:/Users/robin/Documents/GitHub/SubsetMask/test" ^
  --metadata_col_name="sample" ^
  --out="H:/projects_work/cosmx_gray/data/gray_lung_slide_1_unprocessed_annotated.rds"
