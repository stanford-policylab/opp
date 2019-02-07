# opp-city
Open Policing Project -- City Data

## Required System Packages -- Fedora
* R
* gdal-devel
* proj-nad
* proj-epsg
* proj-devel
* v8-314-devel (libv8-3.14-dev ubuntu)
* libjpeg-turbo-devel

## Required R Packages
* *tidyverse
* stringr
* jsonlite
* rgdal
* rgeos
* maptools
* suncalc
* lutz
  
## TODO
* Philly district 77 has lots of searches but 0% hit rate and 0% threshold -- is this for real?
* vod - daylight savings? states?
* prima facie stats? what year for stop rates? population redraw from nhgis,
  states, population baseline?
* lat/lng checks? - cover update
* cite IPUMS/NHGIS as data sources and get permission for redistribution
* force coerce contraband_found to NA when search_conducted FALSE
* daylight savings check in sanity report
* pull out granularity of "other/non-discretionary" search types
