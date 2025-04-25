# Load the brain object with annotated regions
brain <- readRDS(file.path(objects_dir,"brain_objects","2024_11_22_brain_v1.6_fine.labels_added.RDS"))
# load the region points
region.points_list <- readRDS( file.path(data_dir,"regional","final_region.points.RDS"))
# create a metadata object
metadata <- brain@meta.data

# creating MAJOR and MINOR regions lists ---------------------------------------

# extract all the regions names
all.regions <- c()
for (sample in names(region.points_list)){
  sample.regions <- names(region.points_list[[sample]])
  # add all the labels to the all.regions vector
  all.regions <- c(all.regions, sample.regions)
}
# removing repeated names
all.regions <- unique(all.regions) 

# minor regions that overlap
regions.minor_overlap <- c(
  "CA1_hippocampus", "CA2_hippocampus", "CA3_hippocampus", "dentate_gyrus", # hippocampus
  "primary_motor_area", "secondary_motor_area" # motor areas
)
# major regions that overlap
regions.major_overlap <- c("hippocampus", "motor_areas")

# major regions 
regions.major <- all.regions[!all.regions %in% regions.minor_overlap] # remove minor regions overlap
# minor regions 
regions.minor <- all.regions[!all.regions %in% regions.major_overlap] # remove major regions overlap

# add MAJOR regions ------------------------------------------------------------

# create a column in the metadata object to store the region labels
# and set "not assigned" by default
metadata$regions.major <- "not_assigned"

for (sample in names(region.points_list)){
  
  sample.region_points <- region.points_list[[sample]]
  
  for (region in regions.major){
    
    # special case to separate the anterior_commussure from the nucleus_accumbens
    if (region == "nucleus_accumbens"){
      
      # assign the region name to the cells in the region
      region_cells <- sample.region_points[[region]]
      
      # remove the cells from the anterior_commissure
      region_cells <- region_cells[!region_cells %in% sample.region_points[["anterior_commissure"]]]
      
    } else {
      
      # assign the region name to the cells in the region
      region_cells <- sample.region_points[[region]]
    }
    
    # assign "region" to the cells in the region_cells
    metadata[rownames(metadata) %in% region_cells, "regions.major"] <- region
    
  }
  
}

# adding MINOR regions ---------------------------------------------------------

# create a column in the metadata object to store the region labels
# and set "not assigned" by default
metadata$regions.minor <- "not_assigned"

for (sample in names(region.points_list)){
  
  sample.region_points <- region.points_list[[sample]]
  
  for (region in regions.minor){

    # special case to separate the anterior_commussure from the nucleus_accumbens
    if (region == "nucleus_accumbens"){
      
      # assign the region name to the cells in the region
      region_cells <- sample.region_points[[region]]
      
      # remove the cells from the anterior_commissure
      region_cells <- region_cells[!region_cells %in% sample.region_points[["anterior_commissure"]]]
      
    } else {
      
      # assign the region name to the cells in the region
      region_cells <- sample.region_points[[region]]
    }
    
    # assign "region" to the cells in the region_cells
    metadata[rownames(metadata) %in% region_cells, "regions.minor"] <- region
    
  }
  
}

# save metadata to brain -------------------------------------------------------
brain <- AddMetaData(brain, metadata)

# Spatial view example ---------------------------------------------------------
ImageDimPlot(brain, group.by = "regions.major")
ImageDimPlot(brain, split.by = "regions.minor")

# save the brain object --------------------------------------------------------
saveRDS(brain, file.path(objects_dir,"brain_objects",
                         "2025_01_22_brain_v1.7_region.labels_added.RDS"))

