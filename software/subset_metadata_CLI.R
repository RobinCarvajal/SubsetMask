
# Load libraries -----------------------------------------------------------
library(argparse)
library(dplyr)
library(sp)
library(tools)

# Argument parsing CLI ------------------------------------------------------

# Create a parser
parser <- ArgumentParser(description = 'Subset Seurat object script')

# Add arguments
parser$add_argument('--metadata', required = TRUE,
                    help = 'Path to the metadata CSV file')
parser$add_argument('--images_col', required = TRUE,
                    help = 'Path to the metadata column where the image/slide names are stored.')
parser$add_argument('--processed_images', required = TRUE,
                    help = 'Path to the directory that contains the coordinates CSV files')
parser$add_argument('--ann_col', required = TRUE,
                    help = 'Name of the new metadata column to assign the cells in the masks')
parser$add_argument('--out', required = TRUE,
                    help = 'Path to save the annotated metadata file')

# Parse arguments
args <- parser$parse_args()

# Access arguments
metadata_path <- args$metadata
images_col <- args$images_col
processed_images_dir <- args$processed_images
ann_col <- args$ann_col
out_path <- file.path(args$out)

cat("Metadata path:", metadata_path, "\n")
cat("Processed images directory:", processed_images_dir, "\n")

# Load metadata -------------------------------------------------------------

meta <- read.csv(metadata_path, row.names = 1, header = T)

# Build SpatialPoints object from desired fov/image -----------------------

# List to store SpatialPoints objects for each image
spatial_points_list <- list()

for (image in unique(meta[[images_col]])){
  
  # get cell names for the desired fov/image
  image_cells <- meta %>%
    filter(!!sym(images_col) == image) %>%
    row.names()
  
  # get the coordinates from the metadata
  cell_coordinates <- meta[image_cells, c("x_slide_mm", "y_slide_mm")]
  
  # convert coordinates to SpatialPoints
  image_spatial_points <- cell_coordinates %>%
    as.matrix() %>%
    SpatialPoints()
  
  # assign the SpatialPoints object to the list
  spatial_points_list[[image]] <- image_spatial_points
}


# Build SpatialPolygons objects from the mask_coordinates -----------------

# Create a list to store SpatialPolygons objects
spatial_polygons_list <- list()

for (image in unique(meta[[images_col]])) {
  
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
for (image in unique(meta[[images_col]])){
  
  # image spatial points
  points <- spatial_points_list[[image]]
  
  for (mask_name in names(spatial_polygons_list[[image]])){
    
    mask <- spatial_polygons_list[[image]][[mask_name]]
    
    inside_polygon <- !is.na(over(points, mask))
    inside_polygon_df <- data.frame(inside_polygon)
    names(inside_polygon_df)[1] <- "inside"
    
    # Get the row names of points that are inside the polygon
    inside_polygon_cells <- row.names(subset(inside_polygon_df, inside == TRUE))
    
    # save to the overlap_points_list
    overlap_points_list[[image]][[mask_name]] <- inside_polygon_cells
    
  }
  
}


# Assign the region labels to the original Seurat object ------------------------

# create a column in the metadata object to store the region labels and set "not assigned" by default
meta[[ann_col]] <- "not_assigned"

# image names inside the overlap_points_list
image_names <- names(overlap_points_list)

# get all the names/barcodes of cells from the metadata
all_cells <- rownames(meta) 

# main processing loop
for (image in image_names){
  
  image_overlap_points <- overlap_points_list[[image]]
  
  section_names <- names(image_overlap_points)
  
  for (section in section_names){
    
    # assign the region name to the cells in the region
    section_cells <- image_overlap_points[[section]]
    
    # assign "section" in the metadata (ann_col) to the cells in section_cells
    meta[all_cells %in% section_cells, ann_col] <- section
    
  }
  
}


# print stats of the metdata column 

print("Number of cells assigned to each section")
print(table(meta[ann_col], useNA="always"))

# Save the annotated metadata to a CSV file --------------------------------
write.csv(meta, file = out_path, row.names = TRUE)
cat("Annotated metadata saved to:", out_path, "\n")
