
#  load brain object ------------------------------------------------------

brain <- readRDS(file.path(objects_dir,"brain_objects",
                           "05_11_2024_brain_v1.5_broad.labels_added.RDS"))


# making dirs -------------------------------------------------------------

# list of fov images
fov_list <- names(brain@images)


# extract metadata --------------------------------------------------------

brain.meta <- brain@meta.data %>% 
  select(x_slide_mm, y_slide_mm, sample_name)

# extract image dimensions ------------------------------------------------------

image_dimensions <- brain.meta %>%
  # Filter rows in brain.meta that are in fov_list
  filter(sample_name %in% fov_list) %>% 
  group_by(sample_name) %>%
  #calculate min and max values and summarise
  summarize(
    x_min = min(x_slide_mm, na.rm = TRUE),
    x_max = max(x_slide_mm, na.rm = TRUE),
    y_min = min(y_slide_mm, na.rm = TRUE),
    y_max = max(y_slide_mm, na.rm = TRUE)
  ) %>%
  # change column sample_name to sample
  rename(sample = sample_name) %>%
  ungroup()%>%
  # transforming to df
  as.data.frame()

print(image_dimensions)


#  export as csv ----------------------------------------------------------

write.csv(image_dimensions, file.path(data_dir, "regional", "image_dimensions.csv"), row.names = FALSE)
