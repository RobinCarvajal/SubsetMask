
export.images <- function(seurat.object, dir.out, fov.names = NULL, ...) {
  #' Arguments
  #' seurat.object: seurat object WITH polygons/segmentation
  #' dir.out: output directory
  #' fov.names: vector of image names in the "images" slot of the seurat object, if NULL use all images present
  #' ... :  additional arguments to pass to the ImageDimPlot function
  
  ###--- Checking the fov.names argument ---###
  if (is.null(fov.names)) {
    # use all spatial FOVs present in the object
    fov.names <- names(seurat.object@images)
  } else {
    # Check the validity of provided image names
    check_missing_images(seurat.object=seurat.object, fov.names=fov.names)
  }

  ###--- Exporting images ---###
  for (image_name in fov.names) {
    
    # Generate the image
    plot.fov <- ImageDimPlot(object = seurat.object, 
                       fov = image_name, 
                       boundaries = "segmentation",
                       border.size = 0.01,
                       border.color = "black",
                       flip_xy = F,
                       ...) +
      scale_y_continuous(expand = c(0, 0)) +
      scale_x_continuous(expand = c(0, 0)) +
      theme_void() +
      NoLegend()
    
    # Export the image
    png(file.path(dir.out, paste0(image_name, ".png")), 
        width = 3400, height = 4250, units = "px", res = 300, bg="white")
    plot.fov 
    dev.off()
    
    message(paste("Image", image_name, "exported to", image_dir))
  }
}





