
# getting the base directory ----------------------------------------------

# this function only works when run on Background Jobs
get.base_dir <- function() {
  # If RStudio editor
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getActiveDocumentContext()$path
    if (!is.null(path) && path != "") {
      return(dirname(path))
    }
  }
  # Otherwise fallback to working directory
  return(getwd())
}

base_dir <- get.base_dir()
cat("Base directory:", base_dir, "\n")


# running all the functions -----------------------------------------------

# software dir
software_dir <- file.path(base_dir, "software")
cat("Software directory:", software_dir, "\n")

# export.images() function --------------------------------------------------


functions <- c("export.images","export.images_dimensions")

for (function_name in functions){
  # source helpers and main 
  tryCatch({
    function_dir <- file.path(software_dir, function_name)
    source(file.path(function_dir, paste0("helpers-",function_name,".R")))
    source(file.path(function_dir, paste0("main-",function_name,".R")))
    cat("Function [", function_name,"] successfully loaded", "\n")
  }, error = function(e) {
    cat("Error caught:", e$message, "\n")
    return(NA)
  })
}

# removing unnecessary functions/paths ------------------------------------
unnecessary_objects <- c(
  "get.base_dir",
  "function_dir",
  "functions",
  "function_name"
)

unnecessary_dirs <- c(
  "base_dir",
  "export_images_dir",
  "software_dir"
)

rm(list = unnecessary_objects)
rm(list = unnecessary_dirs)
rm(list = c("unnecessary_objects", "unnecessary_dirs"))
