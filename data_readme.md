## Little Rock, AR
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- While the data seems reasonable -- there were ~51k traffic stop calls in 2017 according to the "2017 Annual Report Little Rock Police Department" and we have ~20k citations through November 2017 -- we appear to only have data on those stops that resulted in citations, which means we don't have stops that didn't result in an action taken and we don't have the other actions taken, namely warnings and arrests

### Notes:
- this only includes stops through the beginning of November
- all of the stops have an associated `Vehicle Type`
- filter out rows where DateTime is null

### Issues:
- what is this file? it has similar fields but far fewer records ytd_traffic_stops_from_rms_data_export_tool.csv
- missing reason_for_stop/search/contraband fields
- missing all stops, even those that didn't result in an action taken pg.8 of the reports looks like they have this: https://www.littlerock.gov/media/3937/lrpd-annual-report-final-draft.pdf
- missing other outcomes (warnings/arrests)


## Statewide, AZ
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 10.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 47.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 10.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 97.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 95.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 5.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 1.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 1.45% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Data is too sparse in 2009, 2010, and part of 2011; don't trust it until mid 2011.  TODO: Missing two weeks of data in 2012 (oct 1-14), and two weeks of data in  2013 (nov 2-14) - see:  NOTE from old opp: "Some contraband information is available and so we define a  contraband_found column in case it is useful to other researchers. But the data is  messy and there are multiple ways contraband_found might be defined, and so we do  not include Arizona in our contraband analysis."
- these are taken from correspondence with the PD
- this map was reverse engineered from the highways; i.e. the county was determined by the highways that pass through it
- there doesn't seem to be any other way to suss out whether this was a pedestrian stop; presumably this is quite low, since these are state patrol stops; PE = Pedestrian, BI = Bicyclist
- use County column if possible, otherwise, use the values generated from add_county_from_highway_milepost
- DR = Driver, PS = Passenger, PE = Pedestrian, BI = Bicyclist

### Issues:
- lacking translations for violations: EQ FD FY LU OT TS
- what are kots_* and dots_* files vs the yearly data?
- missing a data dictionary for ReasonForStop


## Gilbert, AZ
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 99.86% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.88% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 99.88% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 99.98% </td>
  </tr>
</tbody>
</table>

### Validation:
- Gilbert Police Department's "FY 2017 Annual Report" has a section on call volume for traffic stops, which seems to be about 10-20% higher than the number of recorded stops in our data; this may be because only certain outcomes are recorded; unfortunately, we don't get a lot of data here, including stop outcome.

### Notes:
- we have subject name here but no other demographic information
- the overwhelming majority of model_years are either NULL or 0, and there are so many 0s that it's more likely a NULL value than the proportion of vehicles stopped that were made in the year 2000

### Issues:
- missing reason_for_stop/search/contraband fields
- missing demographics (age/sex/race)
- missing stop outcome (warning/citation/arrest)


## Mesa, AZ
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 1.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 1.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 1.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 1.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 7.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Mesa Police Department's "2017 Annual Report indicates that they had between 115k and 144k traffic stops each year from 2014 to 2017, since our numbers are around 30k each year (except 2017 where we only have part of the year), it appears as though we only have those stops that resulted in actions taken, i.e. arrests, citations, warnings; it's also a little unclear as to which charges are specifically pedestrian vs. vehicular, so our categorization here is weak; see outstanding TODO

### Notes:

### Issues:
- missing clearer definitions of ped vs veh


## San Diego, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.32% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> service_area </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 3.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.21% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 8.96% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 8.37% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 8.37% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 10.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 33.65% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 9.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 96.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 96.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 12.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
</tbody>
</table>

### Validation:
- There is only partial data for 2017. The PD doesn't appear to produce annual reports with traffic figures, but the numbers seem reasonable given the population.

### Notes:
- the updated data is loaded above; this will load the old data d <- load_single_file( raw_data_dir, "pra_16-1288_vehiclestop2014-2015_sheet_1.csv", n_max ) bundle_raw(d$data, d$loading_problems)
- all of the files are prefixed with vehicle_stops_*
- 4th Waiver Search applies to those on parole/probation who have waived their right to consent searches
- there are shapefiles but no location data; fortunately, there is service area

### Issues:
- There are 1,824 duplicated stop_ids representing ~4k rows; curiously, they have different information, i.e. are at different dates, times, and service areas; what is going on here?


## San Bernardino, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 1.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 6.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 6.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 29.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 0.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 61.99% </td>
  </tr>
</tbody>
</table>

### Validation:
- The San Bernardino City's website offers traffic and crime stats, and the county sheriff's 2017 Annual Report also lists detailed crime, but there doesn't appear to be any easily accessible public reference for vehicular/pedestrian stops; however, the number of stops seems relatively appropriate given a population of ~200k

### Notes:
- in 2011 we only have partial data

### Issues:
- missing reason_for_stop/search/contraband fields
- missing race information
- missing outcomes (warning, citation, arrest) Perhaps this is in the Disposition column, in which case missing a data dictionary
- CallType T = Traffic? CKS = ?


## Anaheim, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- We have very little data here and the police department's website doesn't seem to issue any annual report

### Notes:
- this isn't really a reason for the stop, this is more like a mix of reason for stop, stop category, and violation in one
- these are only traffic stops according to the correspondence

### Issues:
- is this all we can get? we got almost nothing other than date
- we have shapefiles, but no location data yet


## San Francisco, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 5.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 6.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 1.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.24% </td>
  </tr>
</tbody>
</table>

### Validation:
- According to the 2014 Annual Report, there were 130k traffic citations, 94.18% of which were vehicular, so roughly 122k. our data shows 65k citations in 2014, although we do have a small gap in reporting in 2014

### Notes:
- we only have partial data for 2016
- this file is missing age
- maps are from key_to_e585_data.csv
- all the reasons for the stop are vehicle related
- other than consent, there are only inventory, incident to arrest, and parole searches
- unfortunately, we don't get any greater resolution than "Positive Result" for the searches

### Issues:
- Why are they showing nearly double the citations for 2014 in their report ~122k vs 65k?
- what are the crossroads files, and are filenames significant?


## Long Beach, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 25.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 25.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 33.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 33.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subdistrict </td>
   <td style="text-align:left;"> 33.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 33.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_years_of_service </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 15.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 16.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 15.49% </td>
  </tr>
</tbody>
</table>

### Validation:
- Long Beach's Police Department's FY 2018 report is mostly budgeting and high level aggregate figures, but it does say there were 567k calls responded to in 2016, and we have 15k tickets issued, which seems reasonable; it appears as though this data is ticket/citation related, so we don't have other types of outcomes

### Notes:
- type classification is based on first [assumed primary] violation
- this is vehicle year, confirmed with department
- Police Reporting District Number PO_DIST_NO is just the first 2 digits of this

### Issues:
- why are the stops going down so fast yoy from 2009 to 2016?
- missing reason_for_stop/search/contraband fields for reason_for_stop, maybe we need the data dictionary for Violation codes
- missing outcomes (warnings, arrests)


## Santa Ana, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 3.94% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> region </td>
   <td style="text-align:left;"> 3.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- 2014 appears to have data collection issues, and in 2018 we are missing months after April; unfortunately, the annual reports only seem to provide budgeting details, but the data looks reasonable

### Notes:
- Stop Results are all CITATION

### Issues:
- missing search/contraband fields
- missing other outcomes arrests/warnings


## San Jose, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 7.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 11.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 11.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 4.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 12.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 61.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 6.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 5.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> use_of_force_description </td>
   <td style="text-align:left;"> 12.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> use_of_force_reason </td>
   <td style="text-align:left;"> 8.43% </td>
  </tr>
</tbody>
</table>

### Validation:
- While the numbers seem to be on the right order of magnitude, they don't clearly line up with the city report put out by the San Jose government; however, the racial breakdown does closely match that in "San Jose Police Department Traffic and Pedestrian Stop Study"

### Notes:
- We have incomplete data for 2013 and 2018 (missing months)
- the first sheet of each contains the schema
- search type may be included in the narrative, but this is not a separate or searchable field in their database
- COMMONPLACE seems to be a name for places with addresses, i.e. OVERFELT GARDENS, SAFEWAY, WALMART, etc...
- there are other outcomes that don't fall into our schema of warning, citation, and arrest, but aren't put into this factor

### Issues:
- arrests for years 2014-2016 in our data are between 1.5k and 4k, but the "City of San Jose -- Annual Report on City Services 2016-17" says there were around 17k arrests for each of those year; is this not the universe of stops? It not, what are we missing?
- what is `NUMBER OF STOPS`? and `DETENTION DISPO`?


## Stockton, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 0.40% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.57% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.37% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 45.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 45.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.37% </td>
  </tr>
</tbody>
</table>

### Validation:
- We only have partial data in 2012; the PD doesn't seem to issue annual reports to validate these figures, but the data seems reasonable for the size of the city

### Notes:
- all stops are traffic stops as per reply letter
- officer_id is ~90% null; officer2_id is ~50% null; coalescing, there are 2,151 instances where both officers are listed and we only take the first

### Issues:
- how do we join these sets of files?  stop_files contain date, time, location, officer demographics
- location is in the stop files, but let's wait to geocode until we are sure we are going to use those files (currently we can't join them to the survey_files) helpers$add_lat_lng( "address" ) %>%
- add shapefile data after we figure out how to join the files


## Bakersfield, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.57% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 1.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 1.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 8.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 0.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.46% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- Bakersfield Police Department provides crime mapping here: https://www.crimemapping.com/map/ca/bakersfield, but doesn't appear to offer any annual report; however, the top figures look reasonable given a population of roughly 350k; 2008 and 2018 appear to only have partial data

### Notes:
- the files that are named with just years are the CAD Call information, which are not loaded or processed here but available in the raw data directory
- BEAT_ID is the id, USER_FLAG is the human-readable beat name

### Issues:
- why do we see a dip in stops in 2013? See report
- missing reason_for_stop/search/contraband fields
- what are the following ticket classes: O, W, C, V, P?
- what are the following ticket statuses: C, W, E, V?
- missing a data dictionary for statute_{name, section}
- improve this once we get decodings for statute_section; until then, going with vehicular stops since the file has traffic_citations in the name
- missing other outcomes (warnings, arrests)


## Statewide, CA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.30% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 0.30% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 30.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 30.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 30.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 30.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 95.69% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 99.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 99.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- The stop time is not provided; all times appearing in the Date column are 00:00:00. The shift time is provided in the raw data but is not granular enough.
- subject_age is provided, but only as an enum representing age ranges: "0-14","15-25","25-32","33-39","40-48","49+".
- Data is for California Highway Patrol vehicular stops.

### Issues:


## Denver, CO
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 48.61% </td>
  </tr>
</tbody>
</table>

### Validation:
- There is almost no data from 2010 and only the first 7 months of 2018. The annual report put out by denvergov.org doesn't supply stop figures, but these figures seem reasonable given the population; unfortunately, we don't get key demographic information; see TODOS for outstanding tasks

### Notes:
- we have shapefiles, but don't load them since district and precinct are given in the data
- stops are either a Vehicle Stop or a Subject Stop
- we don't get time of stop, but time of phone call

### Issues:
- what is police_pedestrian_stops_and_vehicle_stops.zip? it unzips to .gb tables?
- missing race/sex/age (i.e. demographics)
- missing reason_for_stop/search/contraband fields


## Aurora, CO
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 18.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 18.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 19.41% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 3.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 3.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 1.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 2.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 2.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- auroragov.org was down (2018-12-13), so the annual report couldn't be accessed for validation, but the data seems reasonable.

### Notes:

### Issues:
- get search and contraband
- do we really only get citations?


## Statewide, CO
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 24.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 24.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 14.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 23.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 10.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 10.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 65.65% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 10.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 10.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 16.65% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 41.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 41.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 41.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 55.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 1.90% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Some column names are missing; add them here. Other column names are duplicated, so we use a numeric suffix.
- fill in 2017 county with LocationCounty,  which is name, not code (like the other years)
- A row in the data is a citation. There may be multiple citations in a stop. Group by the situational details of the stop and summarize to create a single row for a stop. For search_conducted and contraband_found fields, >99.9% all stops in group have same value.
- county_name comes from counties.csv, a dictionary provided by the department that converts LocationCounty 1-64 to county name
- Source data all describe state police traffic stops.
- Timestamp contains fractional seconds, though the fractional part is always 0. The seconds are also commonly 0, suggesting they are not recorded consistently.
- missing specific contraband type column.

### Issues:
- The original analysis suggests outcome / arrest data after 2013 is bad. Follow up on this to clarify what's wrong and remove it here as necessary.


## Statewide, CT
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 78.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 78.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 11.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 11.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 1.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 1.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 5.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 49.55% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- The time 00:00 appears more than 10x over the next most frequent time (minute granularity).
- Some rows belong to the same stop.  We dedup below with a group_by and aggregate to potentially have multiple violations and multiple reasons for stop.  For the outcome, we take the most severe outcome.
- There is also StatutatoryCitationPostStop which is the violation the individual was cited for.
- Inferring type "vehicular" based on search_vehicle and whether the violation section is of the form 14-XXX. See: https://www.cga.ct.gov/2015/pub/title_14.htm

### Issues:


## Hartford, CT
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 1.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 1.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 6.63% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 13.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- 2013 has only the last 2 months and 2016 all but the last 3 months of data. While Hartford has weekly crime reports, it doesn't seem to produce any other report that could be used to validate these figures.

### Notes:
- inventory
- ther includes: Probable Cause, Incident to Arrest, Reasonable Suspicion, Plain View Contraband, Drug Dog Alert, and Exigent Circumstances; since most of these are "probable cause" related reasons, we have made it probable cause even though it's possible to have other non-discretionary search bases here, i.e. incident to arrest
- all InterventionReasonCodes are vehicle related
- U = "Uniform Arrest Report"
- I = "Infraction"
- W = "Written Warning", V = "Verbal Warning"
- lat/lng provided in the data are 99.99% null
- no data provided here, so calling the names 'district's

### Issues:
- the search rate is ~30%, this seems extremely high, is this true?


## Tampa, FL
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 0.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 2.72% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 6.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 6.66% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 2.39% </td>
  </tr>
</tbody>
</table>

### Validation:
- The data sources are open for anyone to download https://publicrec.hillsclerk.com/Traffic/Civil_Traffic_Name_Index_files/ https://publicrec.hillsclerk.com/Traffic/Criminal_Traffic_Name_Index_files/ we assume these are all citations since one of the primary keys is Citation Number; the reports don't seem to include traffic stop figures either; data appears to be incomplete for 200-2004 as well as 2018

### Notes:
- this includes multiple Tampa-area police departments
- one of the primary keys is Citation Number, so presumably they are all citations

### Issues:
- missing search/contraband information
- missing other outcome data (warning, arrest)
- What is the difference between Criminal and Civil traffic stops? More specifically, what are Statute Number prefixes 893 and 999, everything else looks like traffic
- is this the address on the driver's license or offense location?  location = str_c_na( `Address Line 1`, `Address Line 2`, City, State, `Zip Code`, sep = ", " ),
- add lat/lng/ back in if the location is actually offense location  helpers$add_lat_lng( ) %>% helpers$add_shapefiles_data( ) %>% rename( district = TPD_DISTRI.x, police_grid_number = TPD_GRID, sector = TPD_SECTOR.x, zone = TPD_ZONE ) %>%


## Saint Petersburg, FL
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 10.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 10.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 1.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- There is only the first 7 months of 2010 here and there doesn't seem to be an annual report that goes back that far (as of 2018-12-13 there is only the Annual Report for 2017).

### Notes:
- the "Nature" of all stops is TRAFFIC, so all vehicular stops

### Issues:
- missing race/search/contraband
- missing more than the first half of 2010


## Statewide, FL
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 77.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 24.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 24.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 18.38% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 22.66% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 13.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 24.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_years_of_service </td>
   <td style="text-align:left;"> 7.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 24.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unit </td>
   <td style="text-align:left;"> 0.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 7.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 7.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 8.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 24.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 1.48% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 7.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 7.87% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 34.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 24.62% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- don't trust first half of 2010; looks like there was a ramp-up period as they begun to collect data. Things look fine starting in June 2010
- Replacing "NULL" with NA everywhere.
- There are also duplicate rows due to multiple violations per stop. Some pertain to different passengers, and hence we sometimes cannot uniquely identify the race of the driver.
- We do a similar deduplication as above for old_data.
- We join the data because some stops are in both old_data and new_data.
- Only vehicular traffic stops were requested in the data request.
- These are all actually citations per Florida PD's clarification.
- Regarding contraband_found, there is data on items seized, but it is not really clear how much this is as a result of a search.

### Issues:


## Statewide, GA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 65.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.86% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.86% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 47.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 3.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 1.93% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 3.98% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 4.81% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- loc is usually highway numbers or main roads, X11 is usually city

### Issues:


## Statewide, IA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 15.30% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 10.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 95.40% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 60.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 73.96% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 60.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 42.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 42.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 42.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 14.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 7.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 15.61% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 15.61% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 15.61% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 46.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 45.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 47.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 61.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 61.66% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- location does not include city or county.
- subject_age, officer_id, department_name are NA for all warnings.
- vehicle_* is NA for all warnings.
- county_name is NA for all warnings.
- subject_race, subject_sex are NA for all warnings.
- Inferring type "vehicular" based on if vehicle data is not NA or if the violation section is vehicle related based on: https://www.legis.iowa.gov/law/iowaCode/sections?codeChapter=321&year=2018
- (old opp) There are duplicates where more than one warning or citation is given within  the same stop. We remove these by grouping by the remaining fields by the stop key and date. In some cases, there are multiple time stamps per unique (key, date) combination.  In most of these cases, the timestamps differ by a few minutes, but all other fields  (except for violation) are the same. In 0.1% of stops, the max span between timestamps  is more than 60 minutes. In those cases it looks like the same officer stopped the same  individual more than once in the same day.

### Issues:
- Determine whether it is worth it to geocode.
- Is vehicle_year the model year or the year on the plates? Possibly LOCKVEHICLEPLATEYEAR. In either case, the data is a bit messy.
- Should we use COUNTY or LOCKCOUNTY?


## Idaho Falls, ID
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 15.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 15.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> neighborhood </td>
   <td style="text-align:left;"> 6.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 40.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subdivision </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 7.66% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 68.20% </td>
  </tr>
</tbody>
</table>

### Validation:
- The figures look close to Traffic Citations section (pg. 16) of the 2016 Idaho Falls Police Department's Annual Report, but we have not yet received translations for the 'reptspec' column, so we can't translate these into typical outcomes (warning, citation, arrest); there is also only partial data for 2008 and 2016 (see NOTE for details on 2016).

### Notes:
- there are 6 months of new data that weren't processed here because they were in a completely different format and a small fraction of the data compared to the main files ss_new_format <- "ss_july_16_to_sep_17_sheet_2.csv" ts_new_format <- "ts_july_25_to_dec_31_2016_sheet_1.csv"
- reason_for_stop/search/contraband fields aren't recorded unless a case is opened
- sex, race are not on the ID driver's license the only extant values must have been filled in manually i.e. getting race and sex for the remaining stops is not possible; subject age is also 100% null
- TS is Traffic Stop; SS is Subject Stop
- 100% null, so no use including in output

### Issues:
- missing deeper explanations of these, like what do they really mean (also, what's a reptspec) Can we translate these to outcome, i.e. warning, citation, arrest
- what is the difference between emunit and emdivision?
- what are geox and geoy? they aren't lat/lng, but never null


## Statewide, IL
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 1.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 1.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_yob </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 67.91% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 2.43% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 0.21% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Enum columns should have integer values, but when encoded as characters some have a trailing ".0" while some do not. We normalize this here.
- The schema indicates that this data is vehicle specific. All subject and search related columns are prefaced with Vehicle, Driver, or Passenger.

### Issues:
- Determine whether Chicago should be removed from this dataset.


## Chicago, IL
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 8.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 24.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 24.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 74.93% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 73.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 81.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 81.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 92.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 7.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 7.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 7.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 7.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_years_of_service </td>
   <td style="text-align:left;"> 7.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 74.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 24.40% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- This data is from a FOIA request directly to the Chicago Police Department. There is also local Chicago data in the statewide directory, but it has disparate schemas and organization; i.e. 2007 is consistent, but other years have the PD broken down into sub-PDs, i.e. University Police, Ridge Police, North Chicago Police, etc. Because of the difficulty in reconciling all those disparate data sources over years, we elected to use the data delivered directly from our city-level FOIA request here. The 2017 annual report has arrests by race for 2016 (pg. 83). The total number of arrests is stated as 85,752; we have 37,817 associated with traffic stops which seems reasonable.

### Notes:
- coalesce identical columns, preferring arrests to citations data
- this is both arrest_date and contact_date after the join

### Issues:


## Fort Wayne, IN
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 3.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 3.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 0.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 33.66% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Roster.csv (police officer info) is available in raw data, but doesn't join cleanly to stops data; first names are often truncated and nicknames are used, i.e.  Manny vs Manuel; it can be loaded and reviewed manually if desired.
- Description is a description of Disposition
- `Incident nature` is all "30 TRAFFIC STOP" so vehicular stops

### Issues:
- missing search/contraband information
- missing reason for stop
- missing subject race
- do we want to filter out the other types of dispositions?


## Wichita, KS
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 2.69% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 2.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 2.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 18.93% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 2.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 17.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 2.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 69.87% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 6.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 4.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 53.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 71.78% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Wichita Police Department's Year In Review for 2016 has no substantial statistics.

### Notes:
- all the files are named citations_<year>.csv

### Issues:
- missing reason_for_stop/search/contraband fields
- are citation numbers unique? sometimes it looks like the represent the same stop, other times, there are two separate locations for the same citation number, i.e. "07M000645"?
- is this acceptable? should we filter out anything else?
- missing other outcomes (warnings, arrests)


## Owensboro, KY
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 0.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 0.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.61% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 0.79% </td>
  </tr>
</tbody>
</table>

### Validation:
- There is only partial data fro 2015 and 2017. The PD's 2016 Annual Report cites figures that are similar to those in the data; for instance, there were 308 "Street Crimes Unit" arrests; we have 429 arrests from traffic violations, which is in the same neighborhood. The Annual Report doesn't give any traffic statistics but the data here seems to be on the same magnitude as that in the report.

### Notes:
- There are some aggregate statistics in excel files for 2016/early 2017 on citations and drugs in the data directory
- FI CARDS are "when an officer comes across a person/persons in a suspicious circumstance or around an area being watched"
- there is a list_of_officers.csv as well as the excel spreadsheet (preferable given the formatting) that have more officer information.
- the data table has fixed-width, 0-padded violation codes
- column names are of the format 'VIOLATION CODE <N>' in data join the violation codes table onto the data table once for each violation
- use the first violation under the assumption that this is the "main" violation and likely the reason for the stop
- without negating longitude, all stops are in central China

### Issues:
- missing search/contraband data
- what are TOTAL COUNTS? is each row in citations multiple?
- all citations with sometimes arrests? warnings?


## New Orleans, LA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 18.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 49.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 49.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 2.57% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 2.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 2.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_assignment </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 29.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 34.57% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 24.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 46.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 46.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 49.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 46.91% </td>
  </tr>
</tbody>
</table>

### Validation:
- Almost no data before 2010. The New Orlean's "Bias-Free-Policing-annual-report-2015.pdf" has statistics on stops by subject race, and out percentages nearly perfectly match them; the discrepancy is likely due to what counts as a traffic/pedestrian stop; namely, we have some offenses here that aren't classified as either by the PD.

### Notes:
- addresses are given sanitized, so we attempt to geocode them by replacing XX with 00 to at least get block level geocodes

### Issues:


## Statewide, MA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 4.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.46% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 9.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 48.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 0.29% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Time is always midnight UTC, so we drop it.
- dataset does not include pedestrian stops.
- there are very few cases where "RsltSrchNo" and "RsltSrchXX" are both true (< 1%). In these cases, we give RsltSrchNo precedence
- If a reason for stop is not given we record the value as NA.
- Drop incomplete years. There are only a handful of stops in the data before 2007, so those years are clearly wrong. It appears that the first few months (nearly half) of 2007 are also incomplete, but we have not attempted to remove the incomplete months.

### Issues:
- there are route numbers that we might be able to turn into more granular locations.


## Baltimore, MD
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 1.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 36.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 39.88% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 10.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 10.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 2.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- A lot of key features are missing here, and the annual report for 2016 only has one statistic that can really be used for evaluating the likelihood that this data is valid: the number of total calls for service, which was 992k. 2016 had 127k stops in this dataset, which is probably reasonable.

### Notes:
- For some reason, the primary key seems to be a combination of Ticket and Citation Number; when Ticket is null, Citation Number isn't and vice versa; both are duplicated across rows, so we deduplicate on those two IDs coalesced
- primary key is Citation Number

### Issues:
- missing reason_for_stop/search/contraband fields
- missing subject race
- is Post like police beat?
- missing `Ordinance Code` translations
- what are the `Enforcement Type` translations? And why are they 99% null?
- missing `Citation Type` translations
- Violation is almost all null? Why is this data all so bad / not present?
- is "Watch" incident type -- i.e. vehicular/pedestrian?
- missing other types of outcomes arrests/warnings
- missing location  helpers$add_lat_lng( ) %>%


## Statewide, MD
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 2.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 77.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 77.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 77.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 77.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.38% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 1.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 98.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 99.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 6.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 6.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 6.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 21.26% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 18.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 1.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 97.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 97.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 85.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_arrest </td>
   <td style="text-align:left;"> 12.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 1.48% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.80% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- January 2013 looks suspiciously low in both the old OPP data and in this cleaned version
- search/hit counts are a bit different between old opp and this version, because the old opp counted all search NAs as FALSE, whereas we check other fields when NA. (i believe our new method to be more accurate)
- there are also some slight discrepancy in by-month numbers throughout 2013 and 2014, between old opp and this cleaned data (even after filtering to the patrol-only data);  though the total counts and race breakdowns are identical between old opp and newly cleaned data. it is unclear to me where these discrepancies arise from. it is  possible that 2013 sheets 23467 should be used instead of sheet 1, however when merging the two, they line up identically, so i can't see that helping.
- pages 23467 contain duplicates of pg 1, so we don't process them d13_23467 <- load_regex( raw_data_dir, '2013_master_traffic_stop_data_for_2014_report_sheet_.csv', n_max = n_max )
- 2007 actually kept more data about registration; we drop it here because all other years track only in-state or out-of-state.
- 2007 data do not have dates; mark stops at first of year.
- 2009-11 data do not have dates; mark stops at first of year.
- 2012 data do not have dates; mark stops at first of year.
- Convert these to a character for row-binding; we'll turn the them back into logical later in processing with the other years' data.
- Some dates include timestamps as well. These are redundant with the `Time of Stop` column, so drop them here.
- Some times include AM/PM. These are redundant with the hour, which is 24-hour, so cut the string to only the HH:MM.
- Some DOBs contain a junk time component (midnight); cut them off. Other DOBs are malformed (e.g., 3-digit year); they will become NA.
- Source data only include vehicle stops.
- `Arrest Made` column isn't complete, so supplement with "arrest" values from the Outcome column when missing.
- the `Search Conducted` field is not totally reliable. Check there if possible, but if it is NA check also whether the `Search` field indicates that a search took place.

### Issues:
- figure out what is causing discrepancies between old and new opp data in by-month  2013 counts


## Statewide, MI
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 2.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- don't trust data until 2013 (2012 still seems a bit low, but  definitely don't use the data before 2012.)
- there are some spike abberations 4x/year
- race data seems shoddy.
- Replacing "NULL" with NA everywhere.
- Deduping because each row corresponds to a violation, not to a stop.
- We also have Felony, Misdemeanor, CivilInfraction and several court related columns to help refine the outcome.
- All rows have a non-NULL VehicleID or have a ConfiscatedPlate and a non-zero VehicleImpounded code.
- All rows have a TicketNum. Here we assume that if any ticket is not a warning, then it is a citation.  But then potentially for outcome, anything that is not an arrest or warning could have a court summons.

### Issues:
- To geocode, we would need to translate CityTownshipCode and add to location.
- Figure out if we should try to disambiguate the outcome summons and citation cases, leave it as citation, or set as NA. In addition to Warning, we also have Felony, Misdemeanor, CivilInfraction and several court related columns to help refine the outcome.


## Saint Paul, MN
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> police_grid_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 86.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 17.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 15.88% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 86.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 15.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 15.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 15.84% </td>
  </tr>
</tbody>
</table>

### Validation:
- While it doesn't appear as though the St. Paul PD puts out an annual report, they do have a very well documented open data portal from which this data is taken. Given the transparency of their government data portal, it seems unlikely the PD would report numbers in opposition to those available here.

### Notes:
- all stops either involved driver or vehicle, so vehicular

### Issues:
- if a citation wasn't issued, was it a warning?   warning_issued = !citation_issued,
- missing other outcomes
- missing contraband
- missing location
- missing reason for stop


## Statewide, MO
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Stops / searches are aggregated by year, agency, and race. Dis- aggregate data so one row represents one stop. Note also that the source files contain other aggregated statistics that we omit here because they are not crosstabulated.
- to standardize city spellings;
- We drop values that are logically inconsistent. In particular, if 1) the number of searches exceeds the number of stops, or 2) the number of contraband discoveries exceeds the number of searches, we will ignore this row.
- Including city is iffy because depts have multiple cities per agency (and multiple spellings of department, and multiple spellings of cities within department) which causes duplicates in disaggregation.
- all source data are traffic stops.

### Issues:
- needs more standardization if it's to be trust
- missing reason_for_stop/search fields and more info on subject (gender, age, etc). Can we get all the raw data (not aggregated)


## Statewide, MS
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 0.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- acd descriptions are listed in "acd alpha listing.pdf"
- Instructions for decoding "agency" column in "agency decode.docx".
- Instructions for decoding "agency" column in "agency decode.docx".
- Only vehicular stops were requested for the data received in Aug 2016.

### Issues:


## Statewide, MT
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.38% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 3.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 2.88% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 7.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 3.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 0.95% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Even though StopTime has the Z timezone indicating UTC, the timestamps are actually in local time America/Denver. So we strip the Z because it is technically incorrect.
- Replacing "NULL" with NA everywhere.
- The public records request for the data received in Feb 2017 were vehicular stops by the Montana Highway Patrol.

### Issues:
- Verify that these search bases are mapped correctly.


## Raleigh, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 2.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 96.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 96.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 96.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 1.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.94% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- There are many missing months of data. The 2014 Raleigh PD Community Report has very few traffic related statistics, but on page 21 it says "Traffic Enforcement Unit officers were responsible for 6.337 total charges, including 142 DWI arrests." This data shows 1,785 arrests in 2014 (although one month is missing) and 67k stops.  It's unclear how this figures can be reconciled.

### Notes:
- the NC cities break the contract implicit in all other city processing files; most can be sourced without assuming other files have already been sourced; however, in the case of NC, we process all statewide data in statewide.R; rather than copying the contents of this script over to every city, we elected to break the contract in this case and assume opp.R has already been sourced and we have access to opp_load_raw("nc", "statewide") and opp_load_clean("nc", "statewide"); this means a few things: (1) metadata will refer to the entire statewide metadata, i.e.  loading problems, and (2) raw_row_number will not be unique to this file, but to NC as a whole, i.e. a city might contain ids 1, 5, 20, 2182, etc...but the data generated by statewide.R will have all ids

### Issues:
- Missing data 2/2004, 2/2005, 5/2005, 10/2005, 11/2005, 3/2006, 8/2006, 4/2007, 11/2008, 1/2009, 11/2012, 9/2013, 11/2013, 7/2014, 10/2014, 10/2015


## Statewide, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 50.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 2.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 2.98% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 96.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 96.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 96.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 3.56% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- D is Driver and P is Passenger, see refcommoncode.csv; drop Type as well, since it's now useless and Type in search.csv corresponds to search type, which we want to keep
- there can be multiple search bases per stop-search-person, so we collapse them here
- the only major caveat with the following data is that the search, search basis, and contraband associated with each stop could be from a Driver or a Passenger (~3.6% of cases), even though we use the Driver for demographic information like race, sex, age, etc
- there is a 1:N correspondence between StopID and PersonID, so we filtered out passengers above to prevent duplicates
- by not joining search also on PersonID, we are getting the search associated with whomever was searched, Driver or Passenger; curiously, with this data, there is a 1:1 correspondence between StopID and SearchID, (as well as between SearchID and PersonID) meaning that only the Driver or Passenger is associated with the SearchID, even though this has no bearing on DriverSearched and PassengerSearched fields in the search table; in other words, one person from each stop was selected to link the stop and search tables, i.e. # StopID, PersonID, Type, SearchID, DriverSearched, PassengerSearched 123   , 1       , D   , NA      , NA            , NA 123   , 2       , P   , 7889,   , 1             , 1 123   , 3       , P   , NA      , NA            , NA # SearchID:StopID is 1:1 --> group_by(search, SearchID, StopID) %>% count %>% nrow == nrow(search) # j <- group_by(left_join(select(search, -Type), person)) # SearchID:PersonID is 1:1 --> group_by(j, SearchID, PersonID) %>% count %>% nrow == nrow(search) # DriverSearched and PassengerSearched don't depend on whether the PersonID associated with the SearchID was a Driver or Passenger --> group_by(j, Type, DriverSearch, PersonSearch) %>% count
- again, not joining also on PersonID here because the search basis is associated with whomever was searched, Driver or Passenger, and here we are focusing on only the Drivers to remove duplicates; so this will be the search basis associated with the SearchID above: # There are not multiple people associated with each <StopID,SearchID> --> group_by(search_basis, StopID, SearchID, PersonID) %>% count %>% nrow group_by(search_basis, StopID, SearchID) %>% count %>% nrow # There are, however, multiple SearchBasisIDs per <StopID,SearchID>, so we collapsed those above
- same reasoning as above, except there is only one ContrabandID per <StopID, SearchID> --> group_by(contraband, StopID, SearchID) %>% count %>% nrow group_by(contraband, StopID, SearchID, ContrabandID) %>% count %>% nrow
- Map length-2 county district codes to county name, and normalize non-mapped names
- all persons are either Drivers or Passengers (no Pedestrians)
- the majority of times are midnight, which signify missing data
- a small percentage of these are "No Action Taken" which will be coerced to NAs during standardization

### Issues:
- missing better location data
- what are "gallons" and "pints" typically of?


## Winston-Salem, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 21.38% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 2.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 97.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 97.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 97.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.98% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.98% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- 2000 and 2001 are missing most data; there are also several missing months in 2014 and 2015. And while the 2015 Annual Report has a lot of statistics, they don't clearly align with the data here (likely due in part to the missing data).

### Notes:
- the NC cities break the contract implicit in all other city processing files; most can be sourced without assuming other files have already been sourced; however, in the case of NC, we process all statewide data in statewide.R; rather than copying the contents of this script over to every city, we elected to break the contract in this case and assume opp.R has already been sourced and we have access to opp_load_raw("nc", "statewide") and opp_load_clean("nc", "statewide"); this means a few things: (1) metadata will refer to the entire statewide metadata, i.e. loading problems, and (2) raw_row_number will not be unique to this file, but to NC as a whole, i.e. a city might contain ids 1, 5, 20, 2182, etc...but the data generated by statewide.R will have all ids

### Issues:
- missing data 8/2014, 1/2015, 2/2015, and 5/2015


## Greensboro, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.87% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 2.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 94.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 94.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 94.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 2.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.88% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Greensboro Police Department Annual Professional Standards Report 2015 has few traffic statistics but lists figures for calls for service: 243k in 2014 and 224k in 2015. This data has 39k stops in 2014 and 28k in 2015, which seems reasonable by comparison. 2000 and 2001 only have partial data. There are also some random months with missing data.

### Notes:
- the NC cities break the contract implicit in all other city processing files; most can be sourced without assuming other files have already been sourced; however, in the case of NC, we process all statewide data in statewide.R; rather than copying the contents of this script over to every city, we elected to break the contract in this case and assume opp.R has already been sourced and we have access to opp_load_raw("nc", "statewide") and opp_load_clean("nc", "statewide"); this means a few things: (1) metadata will refer to the entire statewide metadata, i.e. loading problems, and (2) raw_row_number will not be unique to this file, but to NC as a whole, i.e. a city might contain ids 1, 5, 20, 2182, etc...but the data generated by statewide.R will have all ids

### Issues:
- missing data 8/2015, 11/2015, 11/2016, and 3/2014


## Durham, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 14.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 3.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 93.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 93.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 93.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 3.57% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- 2008, 2009, and 2010; the Durham PD's 2015 Annual Report only lists statistics on violent crimes, so it's hard to tell how traffic data stands in comparison. However, arrest totals 2013-2015 in the traffic data were roughly 60-80% of total vehicle theft arrests in the same time period according to the report, which seems reasonable. See TODOs in statewide.R for outstanding tasks

### Notes:
- the NC cities break the contract implicit in all other city processing files; most can be sourced without assuming other files have already been sourced; however, in the case of NC, we process all statewide data in statewide.R; rather than copying the contents of this script over to every city, we elected to break the contract in this case and assume opp.R has already been sourced and we have access to opp_load_raw("nc", "statewide") and opp_load_clean("nc", "statewide"); this means a few things: (1) metadata will refer to the entire statewide metadata, i.e. loading problems, and (2) raw_row_number will not be unique to this file, but to NC as a whole, i.e. a city might contain ids 1, 5, 20, 2182, etc...but the data generated by statewide.R will have all ids

### Issues:
- missing missing data from 2008-2013: 2008 missing January data 2009 missing February, April, July, September, October, December 2010 missing February, November 2013 missing May


## Fayetteville, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 3.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 2.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 94.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 94.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 94.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 4.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- 2000 and 2001 have only partial data; it also appears that 2009 has data issues for August through December. The Fayetteville PDs 2015 annual report cites 57,528 traffic stops in 2015 while we have 57,816, representing a ~0.5% difference; this could be due to the time the report was compiled or when the data were collected, but is quite close.

### Notes:
- the NC cities break the contract implicit in all other city processing files; most can be sourced without assuming other files have already been sourced; however, in the case of NC, we process all statewide data in statewide.R; rather than copying the contents of this script over to every city, we elected to break the contract in this case and assume opp.R has already been sourced and we have access to opp_load_raw("nc", "statewide") and opp_load_clean("nc", "statewide"); this means a few things: (1) metadata will refer to the entire statewide metadata, i.e. loading problems, and (2) raw_row_number will not be unique to this file, but to NC as a whole, i.e. a city might contain ids 1, 5, 20, 2182, etc...but the data generated by statewide.R will have all ids

### Issues:


## Charlotte, NC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 4.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 94.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 94.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 94.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 1.77% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 99.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- The 2010 Annual Report lists some figures, but they're only crime statistics. For comparison, though, there were ~29k non-traffic arrests in 2010, and there were ~4k traffic ones in this data, so that seems reasonable. 2000 and 2001 only have partial data. See TODOs in statewide.R for outstanding tasks

### Notes:
- the NC cities break the contract implicit in all other city processing files; most can be sourced without assuming other files have already been sourced; however, in the case of NC, we process all statewide data in statewide.R; rather than copying the contents of this script over to every city, we elected to break the contract in this case and assume opp.R has already been sourced and we have access to opp_load_raw("nc", "statewide") and opp_load_clean("nc", "statewide"); this means a few things: (1) metadata will refer to the entire statewide metadata, i.e. loading problems, and (2) raw_row_number will not be unique to this file, but to NC as a whole, i.e. a city might contain ids 1, 5, 20, 2182, etc...but the data generated by statewide.R will have all ids

### Issues:


## Grand Forks, ND
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 3.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 6.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 6.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 39.98% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Grand Forks PD's 2016 Annual Report cites figures that don't totally correspond to our classification here, but are not far off. It's not clear what is considered a traffic stop by the PD (i.e. a pedestrian stop but as it relates to traffic law?). There are also some peculiar spikes, usually at least 1 day a year, that is a clear outlier.

### Notes:
- search and contraband-related fields are not recorded by the PD
- PD says they cannot give arrests as they are not recorded with traffic stops

### Issues:
- why are there always spikes around may/june? The following days have massive spikes, relatively speaking: 2010-05-08 (147) 2011-06-02 (157) 2012-05-05 (173) 2013-05-04 (185) 2014-05-10 (138) 2015-05-09 (112) 2016-05-20 (78)


## Statewide, ND
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.78% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Each row in the dataset corresponds to a citation. We dedup to have one row per stop.
- If all values feeding into location are NA, str_c_na returns "". We convert to NA here.
- Inferring type "vehicular" based on century_code_viol and whether the violation section starts with "39". See: https://www.legis.nd.gov/cencode/t39.html

### Issues:
- The old code seems to indicate that this is all state patrol stops. Figure out if this is really true, in which case department_name is "North Dakota State Highway Patrol".


## Statewide, NE
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 52.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Data in these sources are aggregated by quarter. The date field is the first day of the quarter. Most of the useful fields are joined in from data dictionaries.
- We derive the `Reason` column from the `TopicDescription` column. The `TopicDescription` is one of stop reason, outcome, or whether there was a search. Ideally we would be able to consider all of these factors, but since the data are aggregated we can't cross-tabulate them. Filter to consider only the search topics.
- Time portion of the timestamp is always midnight, so drop it and parse only the date portion.
- Aggregate newer data by quarter to match old data.
- Convert quarter number to the month when that quartert starts, for consistency with old data. E.g., for Q2 return "04" for April.
- Date is the first day of the given quarter, for consistency with old data.
- The department name is joined from a dictionary and in a small number of cases is missing. For these, fall back on the ID, which in these cases is human-readable.
- Convert from wide format to long.
- The `type` column holds the column headers as given above, e.g. Search_Not_Conducted_Hispanic. This contains two pieces of information: whether a search was conducted and the race. Separate this string into two columns accordingly.
- Clean up underscores to make this consistent with the old data.
- All stops in these sources are vehicular.
- old opp filters out dept_lvl 4, 7, 12; however, we won't be able  to distinguish in our cleaned data; if this is important, maybe add dept_lvl classification to location? or concatenate with dept categorization department_name = case_when( dept_lvl %in% c(1,5,9,10,11) ~ "Nebraska State Agency", dept_lvl == 4 ~ "Federal Agency", dept_lvl == 12 ~ "Private Agency", dept_lvl == 7 ~ "Other", TRUE ~ NA_character_ )

### Issues:
- missing gender/reason_for_stop/search/contraband fields Also missing data at the stop level (not aggregated by quarter)


## Statewide, NH
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 12.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 12.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 47.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 47.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 36.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 1.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 5.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 5.68% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- 2014 data come from three sheets of a spreadsheet. Only the first sheet has column headers. The second and third sheets have one and two extra variables, respectively. They are unlabeled, but we know their labels from the original analysis. We add NAs for these variables in the sheets where they are missing, and standardize the column headers between all of them.
- 2015 data come from three sheets of a spreadsheet. Only the first sheet has column labels, but the sheets all have consistent variables. Compared with 2014, they are all missing the DEF_COMPANY variable, which we add and fill with NA.
- Race data is a mess. This translator maps all variations that occur more than 10 times in the data. This covers 99.9% of non-NA rows; note, however, that more than a third of the race entries are NA anyway.
- only vehicular stops in data

### Issues:
- missing reason_for_stop/search/contraband/arrest_made fields


## Statewide, NJ
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 2.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 23.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 96.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 22.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 22.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 22.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 96.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 96.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 2.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 3.72% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 75.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 0.72% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- race differs slightly from old opp (far fewer asians, far more na/other), but categorizations are from raw to clean are identical; old opp mentioned new data that they hadn't used? perhaps this accounts for the discrepancy? it's also not a large enough discrepancy to be too worrisome, and counts of overall number of stops are the same, by month
- Data are grouped by stop ID; rows represent individuals. We need to reduce the group to a single row representing the stop. Choose a driver row for this if there is one; otherwise any row will do.

### Issues:
- missing reason_for_stop/search/contraband fields
- Geocode locations.


## Camden, NJ
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 1.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 1.91% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 1.91% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 1.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 1.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.94% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unit </td>
   <td style="text-align:left;"> 57.21% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 52.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 28.32% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 28.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 29.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 25.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 29.25% </td>
  </tr>
</tbody>
</table>

### Validation:
- For 2013 and 2018 there is only half of the year of data. The Camden PD doesn't appear to have released any annual report recently, so it's hard to validate these numbers. They are a little high some years relative to the population, but crime in Camden has also been high, so these may be reasonable figures

### Notes:
- all officer names are in last name since there are punctuation or spaces between the first and last names
- There are TRAFFIC STOP and PEDESTRIAN STOP and what looks like some accidental free form text for this column, but most reference patrol so classifying as vehicular
- it appears as though Camden police often classify hispanics as white, since the stop rate for whites is extremely high and there are no stops for hispanics
- FIELD CONTACT CARD just records the event when no action was taken
- according to the PD, summons is a citation

### Issues:
- missing reason_for_stop/search/contraband fields


## Statewide, NV
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 8.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Fix some column name inconsistencies between files.
- The arrest file does not contain a Result column, so fill it in.
- Drop partial columns.
- The data do not mark hispanics.
- Source data are all state police traffic stops.
- A couple of stops recorded in 2009; these look like mistakes.

### Issues:
- missing reason_for_stop/search/contraband fields


## Statewide, NY
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 11.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 66.56% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 66.56% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 0.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 100.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 3.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 1.27% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- we could maybe assume "1" is male and "2" is female also, but for now those are cast to NA since we weren't given a metadata file

### Issues:


## Albany, NY
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 9.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 9.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 9.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 38.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 1.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.77% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 0.94% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 1.24% </td>
  </tr>
</tbody>
</table>

### Validation:
- Neither the "Safer Neighborhoods through Precision Policing Initiative" nor the 2018 Prospectus seem to collect statistics on traffic stops, although the Prospectus has some figures on crime. That said, the counts seem reasonable for a city of its size, with the exception of a few days in 2015

### Notes:
- all violations appear to be vehicle related
- cross streets are mashed together with &&, make this more readable

### Issues:
- What happened on 2015-04-29, 2015-05-02, and 2015-05-23; there are massive spikes in stops
- missing reason_for_stop/search/contraband fields
- missing outcomes (warning/citation/arrest)


## Columbus, OH
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 7.41% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 7.41% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 10.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 10.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 9.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- It appears as though the Annual Reports only include Violent and Property crime statistics (in addition to complaints). That said, the number of stops and consistency year over year appear reasonable.

### Notes:
- stop location is null about 2/3 of the time, so using violation location
- all stop reasons are vehicle related

### Issues:
- what is cruiser district?


## Statewide, OH
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 9.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 9.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 49.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 60.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 81.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- The data received in Dec 2015 and Feb 2016 are vehicular stops by the Ohio State Highway Patrol.
- The following are the only disposition codes that clearly indicate arrest or warning. Can't find disposition codes that clearly indicate a citation.

### Issues:


## Cincinnati, OH
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> neighborhood </td>
   <td style="text-align:left;"> 75.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 76.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_assignment </td>
   <td style="text-align:left;"> 1.48% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 75.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 13.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 88.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.95% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 1.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 1.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 1.23% </td>
  </tr>
</tbody>
</table>

### Validation:
- Prior to 2009, there are only random stops recorded, and 2018 only has partial data. The Cincinnati PD doesn't seem to put out Annual Reports but does have crime statistics ("STARS" reports). Despite the lack of validation, the data seems relatively reasonable. However, there is a notable downward trend in stops from 2009 to 2017

### Notes:
- filtering out passengers, since we are concerned about drivers
- addresses are "sanitized", i.e. 1823 Field St. -> 18XX Field St. since 83% of given geocodes are null, we replace X with 0 and get approximate geocoding locations

### Issues:
- Why do the number of stops drop so precipitously from 2009 to 2017?
- missing search/contraband fields


## Oklahoma City, OK
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 10.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 10.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 15.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 15.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 15.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 0.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 10.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 14.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 14.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 52.96% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 18.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 22.06% </td>
  </tr>
</tbody>
</table>

### Validation:
- Prior to 2011, it appears as though there is only partial data, same with the latter part of 2017. The Oklahoma City PD doesn't appear to produce annual reports or anything with traffic statistics (although crime is reported). That said, the figures for years where there appears to be complete data, 2012-2016, the counts seem reasonable.

### Notes:
- veh_color_2 is null 99.8% of the time
- these are all citations

### Issues:
- missing search/contraband information
- what is veh_tag_st TU? roughly 10% are these
- missing other types of outcomes


## Tulsa, OK
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 9.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 9.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.92% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.83% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 62.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 60.14% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 9.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 6.93% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 17.98% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 7.11% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 6.85% </td>
  </tr>
</tbody>
</table>

### Validation:
- Tulsa's 2016 Annual Report doesn't list traffic statistics, but does list calls for service and arrests; these figures seem to be on the right order of magnitude relative to the number of calls for service.

### Notes:

### Issues:
- missing outcome (warning, citation, arrest)
- missing search/contraband fields
- what is CHARGEPARA and CHARGESECTION? Can we get a data dictionary?
- missing beat/precinct or shapefiles for those


## Statewide, OR
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 7.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Data are aggregated with a Count column. Unaggregate them so that one row in the dataset represents one stop.
- We treat middle-eastern as white. See the US Census race definitions: https://www.census.gov/topics/population/race/about.html
- The only date information we have is year. Set the date as the first day of the year, similar to how we treat coarse time units for other states.
- Source file is for traffic stops.

### Issues:
- missing literally any other fields date/location/reason_for_stop/search/contraband, etc.


## Philadelphia, PA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 2.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 5.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 5.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> service_area </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 94.91% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- There is only partial data for 2018, and it looks like the first month or two of 2014 are missing. According to the 2017 Annual Report, recorded pedestrian stops are 20-30k higher than that reported here each year.

### Notes:
- being hispanic/latino trumps other races in assignment
- some clarifications of variables can be found here: http://metadata.phila.gov/#home/datasetdetails/ 571787614fc865407e3cf2b4/representationdetails/571787614fc865407e3cf2b8/

### Issues:
- why are pedestrian stops 20-30k higher each year according to the 2017 Annual Report than in this data?
- missing reason_for_stop
- missing other outcomes - citations/warnings
- is a vehicle_frisk a frisk?


## Statewide, RI
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_yob </td>
   <td style="text-align:left;"> 5.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 5.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 5.71% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 5.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 5.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 5.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 7.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 26.96% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 90.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 99.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 5.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 37.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 54.86% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- L corresponds to "Black Hispanic" which is mapped to "hispanic". This is consistent with coding policies in other states.
- Best lead on mapping trooper zone to location: http://www.scannewengland.net/wiki/index.php?title=Rhode_Island_State_Police
- Data received in Apr 2016 were specifically from a request for vehicular stops.

### Issues:


## Statewide, SC
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 76.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 76.59% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 1.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 1.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 0.48% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 33.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 33.70% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 100.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 100.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Replacing "NULL" with NA everywhere.
- Data received in Aug 2016 was mostly vehicular stops.
- Including `!is.na(ContrabandDesc)` was discussed at length. This mimics the processing decision of the old analysis, in addition to staying true to the department's definition of contraband. Without that inclusion, contraband recovery is low enough to raise skepticism, and includes many, many zeros, especially for hispanic recovery.
- mimics old opp

### Issues:
- The other main value of "Contact Type" is "Public Contact". It is unclear whether a warning is issued in the case of "Public Contact". This needs to be clarified.
- Seems like there are very few instances when ContrabandDesc, which is a free field, indicates either no search was conducted or no contraband was recovered, etc. Does not seem large enough that trends would change, but may be worth in the future doing some work to extract contraband vs no contraband from this ContrabandDesc field.


## Statewide, SD
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 83.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 1.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 24.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 7.56% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 20.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 1.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 22.84% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- there still appear to be slight count differences between old opp and our  cleaned data. However, it appears that our data formats have changed since the last pull/process (of old opp), which may account for some of the differences. Furthermore, the data has no race or outcome information, so it was not used in the old analysis and will not be used in our analysis.
- For 2012 we only have the last quarter or so of stops. For 2016 we only have the first quarter. The years in between are complete, except for maybe April 2013, where there is a dip, and Sept 2015 (see note below).
- in Sept of 2015, the format changes a bit, where superfluous asterisk rows and which column contains true county name is not a problem anymore and leads to improper filterings. We import months thereafter separately to  deal with them accordingly.
- when first column (X1) is not NA, it's a summation description and all  other columns are NA, so we drop these summation rows
- when County is given, all other rows are NA or string of asterisks, so we filter to only cases when County is NA, and then remove that column. (County Freeform contains actual county information for rows with data, so we rename it to county_name)
- when first column (X1) is not NA, it's a summation description and all  other columns are NA, so we drop these summation rows
- only have vehicular data for SD

### Issues:
- The format changes within the month of Sept 2015, so at some point we should address that month in a more nuanced way (right now it's being processed in the format that corresponds to the majority of rows, but in doing so we lose some data)
- missing reason_for_stop/search/contraband/race/etc fields


## Statewide, TN
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 28.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.95% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 7.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 4.53% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 5.53% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Assume times without AM/PM flag are in 24-hour time.
- The dataset is specifically vehicular citations.

### Issues:


## Nashville, TN
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 5.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 5.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 14.83% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reporting_area </td>
   <td style="text-align:left;"> 12.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 14.83% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 20.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 14.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 0.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> notes </td>
   <td style="text-align:left;"> 80.50% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Nashville PD's Annual Report only lists violent and property crime statistics, but this lab did an in-depth study here that aligns well with the public data received here: https://policylab.stanford.edu/projects/nashville-traffic-stops.html

### Notes:
- all the files are traffic_stop_* and the violations are vehicle related

### Issues:


## Houston, TX
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 6.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 6.60% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 6.60% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 11.65% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 11.65% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 18.63% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 3.95% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 1.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 3.27% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Houston PD's Annual Reports don't list traffic figures, but the stop counts don't appear unreasonable for a city of 2M people. 2018 only has partial data.

### Notes:

### Issues:
- missing search/contraband fields
- can we confirm these are all vehicle related incidents?
- missing other outcomes arrests/warnings


## Austin, TX
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 3.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 1.78% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 18.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 52.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 50.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 39.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 97.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 17.66% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 10.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 16.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 2.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 68.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 3.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 25.48% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Austin PD's Annual Report doesn't list traffic statistics. 2016 only has partial data. That said, the aggregate annual stops appear to be reasonable given the population.

### Notes:
- reason checked sometimes contains spaces, which are not entries
- SUSPICIOUS PERSON / VEHICLE is one category, so this will pick up some suspicious persons unfortunately; there are no clear pedestrian-only discretionary stops in reason_checked_description

### Issues:
- missing location and outcome
- we appear to lose about 10% by predicating on search
- add shapefiles after location given


## Plano, TX
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.63% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 50.67% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 51.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 51.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 53.78% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 53.78% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 77.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 77.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 51.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unit </td>
   <td style="text-align:left;"> 77.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 2.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 13.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 67.83% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 1.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 99.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 19.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 95.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 86.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 85.64% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 77.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 77.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 77.77% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 78.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> notes </td>
   <td style="text-align:left;"> 77.39% </td>
  </tr>
</tbody>
</table>

### Validation:
- These data sources are extremely disparate and the annual report from 2017 reports that there were ~85k and ~89k traffic stops in 2016 and 2017, respectively (the two years after this data ends). This would represent a huge increase from 62k and 59k for 2014 and 2015 in this data.

### Notes:
- 'yes' has more variation in expression, so match on 'no's
- officer names are in two formats: (1) <last_name>, <first_initial> (2) <first_initial>. <last_name>
- each column indpendently is at least 75% null
- curiously, every search was search constent in this dataset
- offense seems to be the closest thing to the violation violation_description is 73.81% null primary_violation is 99.35% null type is 98.16% null offense is 49.69% null
- coalesce rather than join since they seem to be redundant
- there is only one aberrant date from 2016

### Issues:
- missing updated data, i.e. 2016-2018 Also, if the Annual Report is correct, stops went up by more than 30% from 2015 to 2016/7 -- why is this
- what are the B/R prefixes?
- how can we join these in? incident # is populated ~15%  stops_fname <- str_c("all_traffic_stops_", year, "_sheet_1.csv") stops <- read_csv(file.path(raw_data_dir, stops_fname)) loading_problems[] <- problems(stops)
- get geolocation data
- fix str_c_na


## Arlington, TX
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 0.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 0.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.13% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- There is only 2016 data and there are a lot of missing data dictionary mappings from features to descriptions, but the 2016 Annual Report's total number of traffic stops very closely matches this data.

### Notes:

### Issues:
- missing more than just 2016
- what are PRA, xCoordinate, yCoordinate?
- missing a data dictionary for this X, N, I
- missing a data dictionary for this R, C, K, L
- missing a data dictionary for `6th digit (Search Outcome)`


## Statewide, TX
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 8.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 41.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 41.84% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 8.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 67.07% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> region </td>
   <td style="text-align:left;"> 8.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 35.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 8.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 76.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 54.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 28.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 33.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 0.06% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 32.90% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- In line with census definitions, we define middle eastern as white This is in contrast to old OPP definitions, which classified as other     M = "white", # Middle Eastern
- Normalizes a name for joining the dataset with last name race statistics.
- Removing punctuation.
- Removing suffix.
- Dataset with race statistics for last names to help correct race, in particular, hispanic not being correctly recorded. Source: http://www.census.gov/topics/population/genealogy/data/2000_surnames.html
- Replacing "(S)" with NA everywhere; "(S)" represents values suppressed for confidentiality.
- Only vehicular traffic stops were requested in the data request.
- If the race is white or NA, and the last name is more than 75% likely to be hispanic, we set race as hispanic.

### Issues:
- We don't know from the data if an arrest was made. Figure out if outcome should be NA or if we should take the most severe of citation and warning.


## San Antonio, TX
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 0.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 7.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> substation </td>
   <td style="text-align:left;"> 7.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.23% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 1.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 82.47% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 13.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 12.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 13.36% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 12.94% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 14.03% </td>
  </tr>
</tbody>
</table>

### Validation:
- Only partial data for 2018. The San Antonio PD doesn't appear to issue annual reports or traffic statistics. That said, the number of stops seems reasonable if not a little low for a state of 1.4M people.

### Notes:
- warnings are not recorded
- 0 seems to indicate not recorded rather than 2000
- SUBCODE is just the first letter of SUBSTN

### Issues:
- is this Latino?
- what is this?


## Statewide, VA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 12.67% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 100.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Jurisdictions data file comes from a Word doc that we converted to a CSV by hand. It's used for getting place names from jurisdiction codes.
- Columns in raw data are codes. The documentation in the raw data directory defines the codes, which these column names are derived from.
- The source data aggregates data by week. In the following pipeline we will reshape the source data to move some columns to rows, and then disaggregate the weekly sums so we have one row per stop.
- There are ~4k duplicate rows in the data. Some are completely identical rows, but a few identical in every way except for the number of stops (which indicates one of the entries is wrong).
- De-duplicate by taking the last row in a group.
- Race data for each event type are given in separate columns, e.g. number_of_search_stops_hispanic. We want to treat race as a variable; i.e., we want to move race to its own column. To do this we will first convert the wide table columns to long as rows, then extract the race component, and finally move the event type back to columns.
- Sum together granular event types to get number of searches and total number of stops in a week. Note also that the granular events in the data are mutually exclusive, i.e. number_of_search_arrests can be non-zero while number_of_search_stops is zero.
- Treat NA as 0 for search counts; they'll be dropped in the disaggregate step if they are 0.
- De-aggregate the data, so that one row represents one stop. Create one row for each search conducted in a week, and another row for each stop conducted without a search.
- Date is the Saturday ending a given week of data, per the documentation included in the raw data directory.
- Source files are all traffic stops.

### Issues:
- missing unaggregated data, along with more details about the stop (reason_for_stop/search/contraband fields)
- In the old opp, for the jurisdictions that are cities, the county column was populated with city; we leave it as NA. The  optimal solution is mapping from city to county (with google's geocoder)


## Burlington, VT
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 1.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 1.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 1.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 1.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 3.19% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 2.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 1.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 1.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 1.08% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 1.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.21% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 1.78% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 1.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 81.74% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Burlington PD's 2017 Annual Report lists figures that are very close to those in the data; the discrepancy is likely due to the exclusion of warrants and other small filters.

### Notes:
- calls/incidents are also in the raw data, but aren't loaded here
- while not included here, violation_group provides a simpler grouping of specific violations
- all violations appear to be vehicle related

### Issues:


## Statewide, VT
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 7.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 7.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 1.41% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.60% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 0.79% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.77% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Passenger searches conducted in Winooski don't specify a reason; we assume they are based on probable cause.

### Issues:
- old opp ran StopCity through google geocoder to get county; at some point we should do the same
- There are highway milemarkers such as `I 89 N; MM 87` in the `Stop Address` field that have no `Stop City` or `Stop Zip`. We need some special handling to get useful location / geocodes for these.


## Statewide, WA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 8.78% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 13.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 13.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 13.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 26.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 26.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 26.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 67.12% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 36.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 27.32% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 26.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 26.63% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Replacing "NULL" with NA everywhere.
- Removing weigh stations stops (W). These are not normal traffic stops; they are all related to truck weigh station violations.
- Normalize road numbers to properly join with wa_location.
- This normailization is to match the normalization done to generate wa_location in the old openpolicing project; matches the WA mile marker database road numbers.
- The data received up until Oct 2016 are vehicular stops by the Washington State Patrol.
- A "1" in enforcements corresponds to arrest or citation. In this case, we set arrest_made to NA and citation_issued to TRUE.
- "P1" and "P2" correspond to "Pat Down Search", which we are considering to be a protective frisk that does not lead to a further search.

### Issues:


## Tacoma, WA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 17.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 17.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 20.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subsector </td>
   <td style="text-align:left;"> 20.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 35.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Tacoma PD hosts a crime map on their website, but doesn't appear to produce annual reports or traffic statistics. 2007 and 2017 only have partial data. That said, that data looks relatively reasonable.

### Notes:
- reason for stop not recorded
- search/contraband not in database, only in written reports
- subject race is not recorded
- this is actually closer to outcome, but doesn't seem to have rigid categories, so passing through as reason_for_stop and providing the more standardized classification in `outcome`
- T = "Traffic Stop", SS = "Subject Stop"

### Issues:
- Why does the number of stops decrease so dramatically from 2009 to 2017?
- do we want to filter out outcomes we don't care about?


## Seattle, WA
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 8.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 8.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 9.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 9.85% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 9.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 68.94% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 68.97% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.89% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 3.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 3.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 14.69% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 3.99% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 41.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 95.61% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 96.55% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 96.73% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 93.68% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 99.81% </td>
  </tr>
</tbody>
</table>

### Validation:
- The Seattle PD doesn't appear to put out Annual Reports or statistics on all traffic stops, but the numbers seem reasonable given the population. Unfortunately, a lot of relevant demographic data appears to be missing.

### Notes:
- The Seattle PD has a smaller dataset focused only on Terry stops here: https://www.seattle.gov/police/information-and-data/terry-stops
- pri in original dataset means 'priority'
- when rin is null, almost every column is null, so filter out
- includes criminal and non-criminal citations

### Issues:


## Madison, WI
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 5.81% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 7.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 7.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 14.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 14.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 1.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.52% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 75.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 75.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 6.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 2.69% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 75.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 1.28% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 2.18% </td>
  </tr>
</tbody>
</table>

### Validation:
- Data prior to 2009 looks like it could be incomplete, and 2017 only has part of the year. The Madison PD's Annual Report doesn't seem to contain traffic figures, but it does contain calls for service, which are around 200k each year. Given there are around 30k warnings and citations each year, this seems reasonable.

### Notes:
- "IBM" is the officers department ID
- Statute Descriptions are almost all vehicular, there are a few pedestrian related Statute Descriptions, but it's unclear whether the pedestrian or vehicle is failing to yield, but this represents a quarter of a percent maximum
- shapefiles don't appear to include district 2 and accompanying sectors

### Issues:
- missing reason_for_stop/search/contraband data
- missing arrests


## Statewide, WI
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 67.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 67.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 14.51% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 14.44% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 0.37% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.10% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 32.82% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 8.63% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 21.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 99.20% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 99.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 14.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 14.35% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 0.09% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 13.15% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 13.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 25.42% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 12.65% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 27.75% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 22.68% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Every last cell in source ends with a lot of extraneous commas, including the header. Get rid of all of these.
- Make names consistent with wi_cit_1 for binding rows.
- Each row represents a single violation for a stop; an entire stop may span multiple rows. Collapse to one row per stop, combining violations into a list. Note that we're grouping by all the columns except for those containing statute info, so that each group represents a single stop and the items within that group represent individual charges alleged in that stop.
- County column mostly uses two-digit codes, but some use the format `<NAME> - <CODE>`. Normalize column to use two-digit codes to join with county data.
- Date and time columns are both full `datetime` columns, but only the relevant half of each is useful. That is, for the date column all times are midnight and for the time column all dates are Jan 1, 1900. In addition, some time values only use HH:MM instead of HH:MM:SS; but even if seconds are given, they are always :00.
- There are a few dates that can't possibly be correct given the years the source files represent. Eliminate them.
- Sources only include vehicle stops.
- Outcome codes come from data dictionary. A stop may have one or more of these codes.
- Search codes come from data dictionary. There is no code for "plain view."  the rest of the search basis categories are are Warrant, Incident to  Arrest, Inventory, and Exigent Circumstances
- Contraband codes come from data dictionary: 03,"ILLICIT DRUG(S)/PARAPHERNALIA" 05,INTOXICANT(S) 01,WEAPON(S) 04,"EVIDENCE OF A CRIME" 06,"STOLEN GOODS" 02,"EXCESSIVE CASH" 00,NONE 99,OTHER

### Issues:


## Statewide, WY
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> features </th>
   <th style="text-align:left;"> null rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> raw_row_number </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 0.21% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.01% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 0.63% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 1.34% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.41% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 6.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.00% </td>
  </tr>
</tbody>
</table>

### Validation:

### Notes:
- Second 2012 file is missing `trci_id` column but is otherwise the same.
- There are lots of empty columns from the spreadsheet conversion that we drop here.
- Each row represents an individual event in a stop. The following grouping will get us to the stop level. Combine the events (statutes and charges) as a string list to summarize the stop.
- Also combine street information, since minor typos and discrepancies  in describing the same location overcount number of stops if included in grouping
- Old OPP chooses to group violation information by the information below plus street (but not streetnbr); after investigating a bit, there are enough minor variations in what is clearly the same street, that in our deduping, we choose not to group by this and instead to collect all those variations in the  location field. This difference is minor (it leads us to have 144 fewer stops than the old OPP -- only about 0.08% of stops)
- `city` column actually holds county
- All stops in data are vehicle stops.

### Issues:
- missing reason_for_stop/search/contraband fields


