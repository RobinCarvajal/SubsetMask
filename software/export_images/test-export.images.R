###--- Test the function below ---###

# Loading object
brain <- readRDS(file.path(objects_dir,"brain_objects",
                           "05_11_2024_brain_v1.5_broad.labels_added.RDS"))

# export images dir
export_images_dir <- file.path(objects_dir,"brain_objects","exported_images")

# there might be the need to use the argument group.by ("broad.labels" in this case) of ImageDimPlot()
export.images(seurat.object = brain, 
              dir.out = export_images_dir,
              fov.names = "ALL",
              # ImageDimPlot arguments
              group.by = "broad.labels")

