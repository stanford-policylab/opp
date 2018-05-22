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
  
## TODO
* remove zone/district -> precinct coercions
* find .mdb .aacdb files -> to_csv updated to correctly convert
* write script to get block group containment by police geographic division
* write script to assign block group populations to police divisions
* write script to download all block group shapefiles
