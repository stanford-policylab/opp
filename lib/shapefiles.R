library(rgdal)

add_location_labels <- function(lngs, lats, shapes_obj, labels) {
  locs = cbind("longitude" = lngs, "latitude" = lats)
  coordinates(locs) <- c("longitude", "latitude")
  # NOTE: assumes locations coming from Google Maps, which uses WGS84
  # https://www.quora.com/How-does-Google-maps-coordinate-system-works
  proj4string(locs) <-
    "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
}
