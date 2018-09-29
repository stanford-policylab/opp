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
* see if cities are sufficiently homogeneous in their tests to aggregate @city 
* select comparable sub-geographies by city 
* review distribution of counts of race by subgeography by year (by month?) by city
* run ot/tt for each final selected subset
* plot ot/tt for each city
* lutz - get TZ --> get sunset time --> get darkness --> make controls
* VA - Statewide is broken
* test --everything after VA fixed and other 6 pushed, then revert to parallel 
* eligibility reports: stats, outcome, threshold, rar, veil of darkness
* write script to get block group containment by police geographic division
* write script to assign block group populations to police divisions
* daylight savings check in sanity report
* benchmark to 2010 block data for race distributions?
* use load_years in all opp_city
* check for violation used in place of reason for stop
* pull out granularity of "other/non-discretionary" search types
* add notes to report pdf
* cite IPUMS/NHGIS as data sources and get permission for redistribution
