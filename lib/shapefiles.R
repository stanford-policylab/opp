library(rgdal)
library(sp)

source("utils.R")


load_shapefiles <- function(dir, layer_name) {
  readOGR(dir, layer = layer_name)
}


add_geolocation_labels <- function(
    longitudes,
    latitudes,
    shapes_obj,
    # NOTE: example: c(1 = "banana", 2 = "apple", ...)
    # where 1 and 2 are the polygon indices in the shapefile
    # and "banana" and "apple" are the corresponding labels
    labels_translator,
    # NOTE: this is the Coordinate Reference System (CRS) for the provided
    # latitude and longitude; for more information: https://www.goo.gl/tUeaqK
    # Google Maps defaults to the following:
    # https://www.quora.com/How-does-Google-maps-coordinate-system-works
    new_column_name = "label",
    crs_proj4string =
      "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
  ) {
  locs = tibble(
    "longitude" = longitudes,
    "latitude" = latitudes
  ) %>% distinct() %>% na.omit()
  sp::coordinates(locs) <- c("longitude", "latitude")
  proj4string(locs) <- crs_proj4string
  spatial_polygons <- as(shapes_obj, "SpatialPolygons")
  # NOTE: returns the indices of the polygons matching each location
  mutate(
    as_tibble(locs),
    dummy_label = labels_translator[over(locs, spatial_polygons)]
  ) %>%
  rename_with_str(
    from = "dummy_label",
    to = new_column_name
  )
}
