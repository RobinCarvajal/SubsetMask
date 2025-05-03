
make.sample_fovs <- function(seurat.object, samples_column) {
  
  # get sample names 
  sample_names <- unique(seurat.object@meta.data[[samples_column]])
  
  # list of polygons
  list.polygons <- list()
  # add original fov 
  list.polygons[["original"]] <- seurat.object@images[[1]]
  
  # create progress bar
  pb <- txtProgressBar(min = 0, max = length(sample_names), style = 3)
  
  # loop with progress bar
  for (i in seq_along(sample_names)) {
    sample <- sample_names[i]
    
    # get cells from sample
    meta <- seurat.object@meta.data
    sample_cells <- row.names(meta[meta[[samples_column]] == sample, ])
    
    # subset
    sub <- subset(seurat.object, cells = sample_cells)
    
    # extract polygons
    sub_polygons <- sub@images[[1]]
    
    # add to list.polygons 
    list.polygons[[as.character(sample)]] <- sub_polygons
    
    # update progress bar
    setTxtProgressBar(pb, i)
  }
  
  close(pb)
  
  # add polygons back to object 
  seurat.object@images <- list.polygons
  
  # return list of polygons
  return(seurat.object)
}


# add "sample" to every item in sample column
obj <- readRDS("/Volumes/Robin SSD/projects_work/CosMx_Gut/data/resegmented_cosmx_gut_with_samples.rds")

obj_fovs <- make.sample_fovs(obj, samples_column = "sample")
