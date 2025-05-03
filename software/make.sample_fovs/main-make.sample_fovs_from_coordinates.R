library(dplyr)

make.sample_fovs <- function(seurat.object, samples_column) {
  
  # get sample names 
  sample_names <- unique(seurat.object@meta.data[[samples_column]])
  
  # rename the only spatial fov to "original"
  names(obj@images)[1] <- "original"
  
  # create progress bar
  pb <- txtProgressBar(min = 0, max = length(sample_names), style = 3)
  
  # loop with progress bar
  for (i in seq_along(sample_names)) {
    sample <- sample_names[i]
    
    # get cells from sample
    meta <- seurat.object@meta.data
    sample_meta <- meta[meta[[samples_column]] == sample, ]
    
    # get coordinates
    sample_coords <- sample_meta %>%
      select(x_slide_mm, y_slide_mm)
    
    sample_x.coords <- c(min(sample_coords$x_slide_mm), max(sample_coords$x_slide_mm))
    sample_y.coords <- c(min(sample_coords$y_slide_mm), max(sample_coords$y_slide_mm))
    
    # crop
    sample.crop <- Crop(seurat.object[["original"]], 
                     x = sample_x.coords, 
                     y = sample_y.coords,
                     coords="tissue")
    
    # change key (not used for now)
    #sample.crop@key <- paste0(sample,"_")

    # add crop to object
    seurat.object@images[[as.character(sample)]] <- sample.crop
    
    # update progress bar
    setTxtProgressBar(pb, i)
  }
  
  close(pb)
  
  # return list of polygons
  return(seurat.object)
}



obj_with_fovs <- make.sample_fovs(seurat.object = obj, samples_column = "sample")

