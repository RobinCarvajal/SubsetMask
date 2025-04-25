
# check_missing_images ----------------------------------------------------
check_missing_images <- function(seurat.object, fov.names) {
  missing.images <- setdiff(fov.names, names(seurat.object@images))
  
  if (length(missing.images) > 0) {
    stop(paste(
      "These image names are not present in the Seurat object:",
      paste(missing.images, collapse = ", ")
    ))
  }
  
  message("All provided image names are present in the Seurat object.")
}
