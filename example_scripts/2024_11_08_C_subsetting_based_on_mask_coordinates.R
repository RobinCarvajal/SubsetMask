
# load the mask.coordinates
mask.coordinates <- read.csv(file.path(data_dir,"regional","segmentation_mask_coords",
                                       "s1055ant_bs1",
                                       "s1055ant_bs1-cortex_coords.csv"))

# plot coordinates
ggplot(mask.coordinates, aes(x = x, y = y)) +
  geom_point() +
  # fixed coorndates
  coord_fixed() +
  theme_minimal()

# brain subset
brain.sub <- subset(brain, subset = sample_name =="s1055ant_bs1")

#extract coorindates forom brain subset 
brain.coords <- brain.sub@meta.data[,c("x_slide_mm","y_slide_mm")]

# plot coordinates
ggplot(brain.coords, aes(x = x_slide_mm, y = y_slide_mm)) +
  geom_point(size=0.01) +
  geom_point(data = mask.coordinates, aes(x = x, y = y), color = "red", size = 0.05) +
  # fixed coorndates
  coord_fixed() +
  theme_void()


# create a mask polygon object --------------------------------------------

library(sp)

# Create the polygon using the coordinates
coords <- as.matrix(mask.coordinates)
polygon <- Polygon(coords)
spatial_polygon <- Polygons(list(polygon), "poly1")
spatial_polygon_object <- SpatialPolygons(list(spatial_polygon))

# Print the spatial polygon object
spatial_polygon_object

plot(spatial_polygon_object, col = "lightblue", border = "black")



# check if the points are inside the polygon ------------------------------

# convert brain coords into spatial points
points <- SpatialPoints(brain.coords)



inside_polygon <- !is.na(over(points, spatial_polygon_object))
inside_polygon_df <- data.frame(inside_polygon)
names(inside_polygon_df)[1] <- "inside"


# Get the row names of points that are inside the polygon
inside_polygon_cells <- row.names(subset(inside_polygon_df, inside == TRUE))


# make a hipocampus subset -----------------------------------------------

hipocampus.cells <- inside_polygon_cells

hipocampus.sub <- subset(brain.sub, brain_cell_id %in% hipocampus.cells)


ImageDimPlot(hipocampus.sub, boundaries = "segmentation", coord.fixed = T, flip_xy = F)