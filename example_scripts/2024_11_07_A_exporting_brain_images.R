
#  load brain object ------------------------------------------------------

brain <- readRDS(file.path(objects_dir,"brain_objects",
                           "05_11_2024_brain_v1.5_broad.labels_added.RDS"))


# making dirs -------------------------------------------------------------

# list of fov images
fov_list <- names(brain@images)

# create a directory for the regional images
centroids_plots_dir <- file.path(data_dir, "regional", "spatial_centroids_plots")
segmentation_plots_dir <- file.path(data_dir, "regional", "spatial_segmentation_plots")

# Create the directory if they do not already exist
if (!dir.exists(centroids_plots_dir)) {dir.create(centroids_plots_dir, recursive = TRUE)}
if (!dir.exists(segmentation_plots_dir)) {dir.create(segmentation_plots_dir, recursive = TRUE)}


# centroids option --------------------------------------------------------


for (fov in fov_list){
  
  plot <- ImageDimPlot(object = brain, 
                       fov = fov, 
                       boundaries = "centroids", 
                       group.by = "broad.labels", 
                       size = 1,
                       flip_xy = F)+
    scale_y_continuous(expand = c(0,0)) +
    scale_x_continuous(expand = c(0,0))+
    theme_void() +
    NoLegend()
  
  # create a dir per fov
  fov_dir <- file.path(centroids_plots_dir, fov)
  if (!dir.exists(fov_dir)) {dir.create(fov_dir, recursive = TRUE)}
  
  # save the plot
  ggsave(plot =  plot, 
         filename = file.path(fov_dir, paste0(fov,".png")),
         w=40, h=50, units = "cm", 
         dpi=600, bg = "white")
  
  # indicate when finished
  print(paste0(fov, " Finished "))
  
}




# segmentation option -----------------------------------------------------

# make a plot per fov

for (fov in fov_list){
  
  plot <- ImageDimPlot(object = brain, 
                       fov = fov, 
                       boundaries = "segmentation", 
                       group.by = "broad.labels", 
                       border.size = 0.01,
                       border.color = "black",
                       flip_xy = F)+
    scale_y_continuous(expand = c(0,0)) +
    scale_x_continuous(expand = c(0,0))+
    theme_void() +
    NoLegend()
  
  # create a dir per fov
  #fov_dir <- file.path(segmentation_plots_dir, fov)
  fov_dir <- segmentation_plots_dir
  if (!dir.exists(fov_dir)) {dir.create(fov_dir, recursive = TRUE)}
  
  # save the plot
  ggsave(plot =  plot, 
         filename = file.path(fov_dir, paste0(fov,".png")),
         w=3400, h=4250, units = "px", 
         dpi=300, bg = "white")
  
  # indicate when finished
  print(paste0(fov, " Finished "))


}


# create a folder to store the masks --------------------------------------

for (fov in fov_list){
  
  # create a dir per fov
  mask_dir <- file.path(data_dir,"regional", "spatial_segmentation_masks")
  fov_dir <- file.path(mask_dir, fov)
  if (!dir.exists(fov_dir)) {dir.create(fov_dir, recursive = TRUE)}

  
  # indicate when finished
  print(paste0(fov, " Finished "))
  
  
}

