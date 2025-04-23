
#  load brain object ------------------------------------------------------
brain <- readRDS(file.path(objects_dir,"brain_objects",
                           "2024_11_22_brain_v1.6_fine.labels_added.RDS"))

# brain metadata
brain.metadata <- brain@meta.data

# Load all the mask coordinates -------------------------------------------

# load all the mask coordinates in a list 

# eventually replace with teh complete list of samples(from brain)
samples <- list.files(file.path(data_dir,"regional","segmentation_mask_coords"),
                      full.names = F, recursive = F)

# create an empty list to store the polygon objects
mask.polygons_list <- list()

# loop to add all polygons to its object
for (sample in samples){
  
  # extracting all the paths of the mask coordinates files
  mask_list <- list.files(file.path(data_dir,"regional","segmentation_mask_coords",sample),
                          full.names = T, recursive = F)
  
  # loop to add all the mask coordinates to its sample
  # and create the polygon object
  for (mask in mask_list){
    
    # name
    mask_name <- file_path_sans_ext(basename(mask))
    # path
    mask_path <- mask
    
    # read the mask coordinates
    mask_df <- read.csv(mask_path)
    
    # Create the polygon using the coordinates
    coords <- as.matrix(mask_df)
    polygon <- Polygon(coords)
    spatial_polygon <- Polygons(list(polygon), ID = mask_name)
    spatial_polygon_object <- SpatialPolygons(list(spatial_polygon))
    

  # assigning the polygon object to the mask.coords list
    mask.polygons_list[[sample]][[mask_name]] <- spatial_polygon_object
  
  }
  
}

#example of viasualisation
example_sample <- "s1056ant_bs4"
example_mask <- "s1056ant_bs4-nucleus_accumbens_coords"
example_polygon <- mask.polygons_list[[example_sample]][[example_mask]]
plot(example_polygon, col = "lightblue", border = "black")

# brain coords as spatial objects  ----------------------------------------

# empty list to add SpatialPoints object per sample
brain_spatial.points_list <- list()

# loop to add the spatial objects based on brain coords 
for (sample in samples){
  
  brain_spatial.points_list[[sample]] <- brain.metadata %>%
    filter(sample_name == sample) %>%
    select(x_slide_mm, y_slide_mm) %>%
    as.matrix() %>%
    SpatialPoints()
  
}

# example of SpatialPoints object
plot(brain_spatial.points_list$s1055ant_bs2)

# Checking if the points are inside the polygon ------------------------------

# empty list to store the points inside the region masks
region.points_list <- list()

# loop to check if the points are inside the polygon
for (sample in samples){
  
  # sample spatial points
  points <- brain_spatial.points_list[[sample]]
  
  for (mask_name in names(mask.polygons_list[[sample]])){
    
    mask <- mask.polygons_list[[sample]][[mask_name]]
    
    inside_polygon <- !is.na(over(points, mask))
    inside_polygon_df <- data.frame(inside_polygon)
    names(inside_polygon_df)[1] <- "inside"
    
    # Get the row names of points that are inside the polygon
    inside_polygon_cells <- row.names(subset(inside_polygon_df, inside == TRUE))
    

    # remove "coords" from the mask_name
    mask_name <- gsub("_coords", "", mask_name)
    
    # removed the sample name from the inside_points object lists 
    # i.e. "agranular_insula" instead of "s1055ant_bs1-agranular_insula"
    # remove the sample name from the mask name (DID IT)
    mask_name <- gsub(paste0(sample,"-"), "", mask_name)
    
    region.points_list[[sample]][[mask_name]] <- inside_polygon_cells
    
  }

}


# example of visualisation ------------------------------------------------

example_cells <- region.points_list[["s1055ant_bs1"]][["caudoputamen"]]
example_subset <- subset(brain, cells =  example_cells)# subset from the brain object
example_spatial.plot <- ImageDimPlot(example_subset, boundaries = "segmentation", coord.fixed = T, flip_xy = F)


# save the list of cells as an object -------------------------------------
saveRDS(region.points_list, file.path(data_dir,"regional",
                                 "final_region.points.RDS"))


# annotate/subset the regions of interest with the cell names obtained --------

## could use SetIdent for that like: 
# brain <- SetIdent(brain, cells = cortex.cells, value = "cortex")
# cortex cells would be the barcodes of the cells from the inside points object

# Check results -----------------------------------------------------------

# Create an empty data frame
df <- data.frame()

# Iterate through each sample in the list
for (sample in names(region.points_list)) {
  print(" ")
  print(sample)
  
  # Get all regions as a single string separated by "/"
  all_regions <- paste(names(region.points_list[[sample]]), collapse = "/")
  
  # Create a data frame line with sample and combined regions
  df_line <- data.frame(sample = sample, 
                        regions = all_regions)
  
  # Add df_line to df
  df <- rbind(df, df_line)
}

# View the resulting data frame
print(df)

# save as a txt file 
write.csv(df, file.path(data_dir,"regional",
                        "2025_01_21_region_points_summary.csv"))


