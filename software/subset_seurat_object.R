
# Argument parsing CLI ------------------------------------------------------

# Load argparse package
library(argparse)

# Create a parser
parser <- ArgumentParser(description = 'Subset Seurat object script')

# Add arguments
parser$add_argument('--seurat_obj', required = TRUE,
                    help = 'Path to the Seurat object RDS file')

parser$add_argument('--processed_images', required = TRUE,
                    help = 'Path to the directory that contains the coordinates csv files')
parser$add_argument('--metadata_col_name', required = TRUE,
                    help = 'Name of the new metadata column to assign the cells in the masks')
parser$add_argument('--out', required = TRUE,
                    help = 'Name of the new metadata column to assign the cells in the masks')

# Parse arguments
args <- parser$parse_args()

# Access arguments
seurat_path <- args$seurat_obj
processed_images_dir <- args$processed_images
meta_col <- args$metadata_col_name
out_path <- file.path(args$out)

cat("Seurat object path:", seurat_path, "\n")

# Example:
# library(Seurat)
# seurat_obj <- readRDS(seurat_path)
# background_image <- readPNG(image_path)  # Or appropriate function based on image type

# Load libraries -----------------------------------------------------------
library(Seurat)
library(dplyr)
library(sp)
library(tools)

# Load object -------------------------------------------------------------

obj <- readRDS(seurat_path)

# Build SpatialPoints object from desired fov/image -----------------------

# List to store SpatialPoints objects for each image
spatial_points_list <- list()

for (image in names(obj@images)){
  
  # get cell names for the desired fov/image
  image_cells <- obj@images[[image]]$centroids@cells
  
  # get the coordinates from the metadata
  cell_coordinates <- obj@meta.data[image_cells, c("x_slide_mm", "y_slide_mm")]
  
  # convert coordinates to SpatialPoints
  image_spatial_points <- cell_coordinates %>%
    as.matrix() %>%
    SpatialPoints()
  
  # assign the SpatialPoints object to the list
  spatial_points_list[[image]] <- image_spatial_points
}


# Build SpatialPolygons objects from the mask_coordinates -----------------

processed_images_dir <- "~/GitHub/SubsetMask/test"

# Create a list to store SpatialPolygons objects
spatial_polygons_list <- list()

for (image in names(obj@images)) {
  
  # get corrdinated folder for iamge
  image_coords_dir <- file.path(processed_images_dir, image, "coordinates")
  image_coords <- list.files(image_coords_dir, full.names = TRUE, recursive=F)
  
  # Loop through each file and create SpatialPolygons
  for (file in image_coords) {
    
    # name
    file_name <- file_path_sans_ext(basename(file))
    # Read the coordinates from the CSV file
    coords_df <- read.csv(file)
    
    # Create the SpatialPolygons object using the coordinates
    coords <- as.matrix(coords_df)
    polygon <- Polygon(coords)
    spatial_polygon <- Polygons(list(polygon), ID = file_name)
    spatial_polygon_object <- SpatialPolygons(list(spatial_polygon))
    
    # assigning the polygon object to the mask.polygons list
    spatial_polygons_list[[image]][[file_name]] <- spatial_polygon_object
  }

}


# Overlap the SpatialPoints with the SpatialPolygons for each mask ----------------------


# empty list to store the points inside the region masks
overlap_points_list <- list()

# loop to check if the points are inside the polygon
for (image in names(obj@images)){
  
  # image spatial points
  points <- spatial_points_list[[image]]
  
  for (mask_name in names(spatial_polygons_list[[image]])){
    
    mask <- spatial_polygons_list[[image]][[mask_name]]
    
    inside_polygon <- !is.na(over(points, mask))
    inside_polygon_df <- data.frame(inside_polygon)
    names(inside_polygon_df)[1] <- "inside"
    
    # Get the row names of points that are inside the polygon
    inside_polygon_cells <- row.names(subset(inside_polygon_df, inside == TRUE))
    
    
    # remove "coords" from the mask_name
    #mask_name <- gsub("-coords", "", mask_name)
    
    # removed the image name from the inside_points object lists 
    # i.e. "agranular_insula" instead of "s1055ant_bs1-agranular_insula"
    # remove the image name from the mask name (DID IT)
    #mask_name <- gsub(paste0(image,"-"), "", mask_name)
    
    overlap_points_list[[image]][[mask_name]] <- inside_polygon_cells
    
  }
  
}


# Assign the region labels to the original Seurat object ------------------------

# extract metadata from the Seurat object
metadata <- obj@meta.data

# create a column in the metadata object to store the region labels and set "not assigned" by default
metadata[[meta_col]] <- "not_assigned"

# image names inside the overlap_points_list
image_names <- names(overlap_points_list)

# get all the names/barcodes of cells from the metadata
all_cells <- rownames(metadata) 

# main processing loop
for (image in image_names){
  
  image_overlap_points <- overlap_points_list[[image]]
  
  section_names <- names(image_overlap_points)
  
  for (section in section_names){
    
    # assign the region name to the cells in the region
    section_cells <- image_overlap_points[[section]]
    
    # assign "section" in the metadata (meta_col) to the cells in section_cells
    metadata[all_cells %in% section_cells, meta_col] <- section
    
  }
  
}



#  save metdata to seurat object  -----------------------------------------

obj <- AddMetaData(obj, metadata)

# print stats of the metdata column 

print("Number of cells assigned to each section")
print(table(metadata[meta_col], useNA="always"))

# save the seurat objec tin the output directory
out_path <- file.path(args$out)
print(paste("Saving the Seurat object to", out_path))
saveRDS(obj, out_path)
print("Seurat object saved successfully.")

# 
# ImageDimPlot(obj, split.by = "sample", boundaries="centroids", flip_xy = F)
# ImageDimPlot(obj, group.by = "sample", boundaries="centroids", flip_xy = F, axes=T)
