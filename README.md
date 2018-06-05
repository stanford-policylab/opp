# opp-city
Open Policing Project -- City Data

## Required System Packages -- Fedora
* R
* gdal-devel
* proj-nad
* proj-epsg
* proj-devel

## Required R Packages
* *tidyverse
* stringr
* jsonlite
* rgdal
* rgeos
  
## TODO
* write script to get block group containment by police geographic division
* write script to assign block group populations to police divisions
* daylight savings check in sanity report
* incident_id -> raw_row_number
* change standardization to not differentiate between require/extra for final
  data output
* benchmark to 2010 block data for race distributions?
