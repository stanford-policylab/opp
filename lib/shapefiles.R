library(rgdal)
library(dplyr)
library(sp)
library(tibble)



load_shapefiles <- function(dir) {
  shape_filename = list.files(dir, pattern = ".shp")
  layer_name = tools::file_path_sans_ext(shape_filename)
  readOGR(dir, layer = layer_name)
}


add_shapefiles_data <- function(
  tbl,
  shapes_obj,
  longitude_colname,
  latitude_colname,
  # NOTE: this is the Coordinate Reference System (CRS) for the provided
  # latitudes and longitudes; for more information: https://www.goo.gl/tUeaqK
  # Google Maps defaults to the following:
  # https://www.quora.com/How-does-Google-maps-coordinate-system-works
  crs_proj4string =
    "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
) {
  # NOTE: creating this intermediate data.frame is necessary since you can't
  # run the `over` function on the entire dataset if it contains any NA values
  locs <- select_(tbl, longitude_colname, latitude_colname) %>%
    distinct() %>% na.omit()
  lng_lat_colnames <- c(longitude_colname, latitude_colname)
  sp::coordinates(locs) <- lng_lat_colnames
  proj4string(locs) <- crs_proj4string
  spatial_polygons <- as(shapes_obj, "SpatialPolygons")
  data <- slot(shapes_obj, "data")
  # NOTE: this assumes that the polygon index is corresponds to the index
  # in the "data" slot; usually eachy polygon in the "polygons" slot will
  # have an associated "ID" slot --> this should match with the index in the
  # data section; i.e. ID = 0 corresponds to row index 1 in the data section
  polygon_indices <- over(locs, spatial_polygons)
  locs_with_data <- cbind(as_tibble(locs), data[polygon_indices, ])
  # NOTE: join only on original longitude_colname and latitude_colname;
  # this prevents accidentally joining on new data columns in the shapefiles
  # data section
  names(lng_lat_colnames) <- lng_lat_colnames
  left_join(tbl, locs_with_data, by = lng_lat_colnames)
}
