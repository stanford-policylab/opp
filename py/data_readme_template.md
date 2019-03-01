This readme explains how to make best use of the data from the Stanford Open
Policing Project. We provide an overview of the data and a list of best
practices for working with the data. 

Our analysis code and further documentation are available at
[https://github.com/5harad/openpolicing](https://github.com/5harad/openpolicing).

### Overview of the data file structure

For each dataset, we provide 4 files:

1. A zipped csv file of the cleaned data
2. An RDS of the cleaned data
3. Tarballed (zipped) shapefiles
4. Tarballed (zipped) raw data (available upon request)

### Description of standardized data

Each row in the cleaned data represents a stop. The following details the
maximal set of features we attempted to extract from each location. Coverage
varies by location. Fields with an asterisk were removed for public release due
to privacy concerns.

<table>
  <tr>
    <td>Column name</td>
    <td>Column meaning</td>
    <td>Example value</td>
  </tr>
  <tr>
    <td>raw_row_number</td>
    <td>An number used to join clean data back to the raw data</td>
    <td>38299</td>
  </tr>
  <tr>
    <td>date</td>
    <td>The date of the stop, in YYYY-MM-DD format. Some states do not provide the exact stop date: for example, they only provide the year or quarter in which the stop occurred. For these states, stop_date is set to the date at the beginning of the period: for example, January 1 if only year is provided.</td>
    <td>"2017-02-02"</td>
  </tr>
  <tr>
    <td>time</td>
    <td>The 24-hour time of the stop, in HH:MM format.</td>
    <td>20:15</td>
  </tr>
  <tr>
    <td>location</td>
    <td>The freeform text of the location. Occasionally, this represents the
    concatenation of several raw fields, i.e. street_number, street_name</td>
    <td>"248 Stockton Rd."</td>
  </tr>
  <tr>
    <td>lat</td>
    <td>The latitude of the stop. If not provided, we attempt to geocode this
    using the location field. Stops with geocodes more than 4 standard
    deviations from the median stop lat/lng are set to NA. </td>
    <td>72.23545</td>
  </tr>
  <tr>
    <td>lng</td>
    <td>The longitude of the stop. If not provided, we attempt to geocode this
    using the location field. Stops with geocodes more than 4 standard
    deviations from the median stop lat/lng are set to NA. </td>
    <td>115.2808</td>
  </tr>
  <tr>
    <td>county_name</td>
    <td>County name where provided</td>
    <td>"Allegheny County"</td>
  </tr>
  <tr>
    <td>neighborhood</td>
    <td>This is the neighborhood of the stop and some police departments will
    provide this instead of a location or beat.</td>
    <td>"GRNBELT"</td>
  </tr>
  <tr>
    <td>beat</td>
    <td>Police beat. If not provided, but we have retrieved police department
    shapfiles and the location of the stop, we geocode the stop and find the
    beat using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>district</td>
    <td>Police district. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the district using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>subdistrict</td>
    <td>Police subdistrict. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the subdistrict using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>division</td>
    <td>Police division. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the division using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>subdivision</td>
    <td>Police subdivision. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the subdivision using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>police_grid_number</td>
    <td>Police grid number. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the police grid number using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>precinct</td>
    <td>Police precinct. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the precinct using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>region</td>
    <td>Police region. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the region using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>reporing_area</td>
    <td>Police reporting area. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the reporting area using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>sector</td>
    <td>Police sector. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the sector using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>subsector</td>
    <td>Police subsector. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the subsector using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>substation</td>
    <td>Police substation. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the substation using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>service_area</td>
    <td>Police service area. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the service area using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>zone</td>
    <td>Police zone. If not provided, but we have retrieved police
    department shapfiles and the location of the stop, we geocode the stop and
    find the zone using the shapefiles.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>subject_age</td>
    <td>The age of the stopped subject. When date of birth is given, we
    calculate the age based on the stop date. Values outside the range of
    10-110 are coerced to NA.</td>
    <td>54.23</td>
  </tr>
  <tr>
    <td>subject_dob*</td>
    <td>The date of birth of the stopped subject.</td>
    <td>"1956-02-23"</td>
  </tr>
  <tr>
    <td>subject_yob*</td>
    <td>The year of birth of the subject.</td>
    <td>1983</td>
  </tr>
  <tr>
    <td>subject_race</td>
    <td>The race of the stopped subject. Values are standardized to white,
    black, hispanic, asian/pacific islander, and other/unknown</td>
    <td>"hispanic"</td>
  </tr>
  <tr>
    <td>subject_sex</td>
    <td>The recorded sex of the stopped subject.</td>
    <td>"female"</td>
  </tr>
  <tr>
    <td>officer_id*</td>
    <td>Officer badge number or other form of identification provided by the
    department.</td>
    <td>8</td>
  </tr>
  <tr>
    <td>officer_id_hash</td>
    <td>A unique hash of the officer id used to identify individual officers
    within a location.</td>
    <td>"a888fdc120"</td>
  </tr>
  <tr>
    <td>officer_age</td>
    <td>The age of the stopped officer. When date of birth is given, we
    calculate the age based on the stop date. Values outside the range of
    10-100 are coerced to NA.</td>
    <td>54.23</td>
  </tr>
  <tr>
    <td>officer_dob*</td>
    <td>The date of birth of the stopped officer.</td>
    <td>"1956-02-23"</td>
  </tr>
  <tr>
    <td>officer_race</td>
    <td>The race of the stopped officer. Values are standardized to white,
    black, hispanic, asian/pacific islander, and other/unknown</td>
    <td>"hispanic"</td>
  </tr>
  <tr>
    <td>officer_sex</td>
    <td>The recorded sex of the stopped officer.</td>
    <td>"female"</td>
  </tr>
  <tr>
    <td>officer_first_name*</td>
    <td>First name of the officer when provided.</td>
    <td>"MIGUEL"</td>
  </tr>
  <tr>
    <td>officer_last_name*</td>
    <td>Last name of the officer when provided.</td>
    <td>"JEFFERSON"</td>
  </tr>
  <tr>
    <td>officer_years_of_service</td>
    <td>Number of years officer has been with the police department.</td>
    <td>22</td>
  </tr>
  <tr>
    <td>officer_assignment</td>
    <td>Department or subdivision to which officer has been assigned.</td>
    <td>"8th District"</td>
  </tr>
  <tr>
    <td>department_id</td>
    <td>ID of department or subdivision to which officer has been assigned.</td>
    <td>90</td>
  </tr>
  <tr>
    <td>department_name</td>
    <td>Name of department or subdivision to which officer has been
    assigned.</td>
    <td>90</td>
  </tr>
  <tr>
    <td>unit</td>
    <td>Unit to which officer has been assigned.</td>
    <td>"Patrol-1st"</td>
  </tr>
  <tr>
    <td>type</td>
    <td>Type of stop: vehicular or pedestrian.</td>
    <td>"vehicular"</td>
  </tr>
  <tr>
    <td>disposition</td>
    <td>Disposition of stop where provided. What is recorded here varies widely
    across police departments.</td>
    <td>"GUILTY"</td>
  </tr>
  <tr>
    <td>violation</td>
    <td>Specific violation of stop where provided. What is recorded here varies
    widely across police departments.</td>
    <td>"SPEEDING 15-20 OVER"</td>
  </tr>
  <tr>
    <td>arrest_made</td>
    <td>Indicates whether an arrest made.</td>
    <td>FALSE</td>
  </tr>
  <tr>
    <td>citation_issued</td>
    <td>Indicates whether a citation was issued.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>warning_issued</td>
    <td>Indicates whether a warning was issued.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>outcome</td>
    <td>The strictest action taken among arrest, citation, warning, and
    summons.</td>
    <td>"citation"</td>
  </tr>
  <tr>
    <td>contraband_found</td>
    <td>Indicates whether contraband was found. When search_conducted is NA,
    this is coerced to NA under the assumption that contraband_found shouldn't
    be discovered when no search occurred and likely represents a data
    error.</td>
    <td>FALSE</td>
  </tr>
  <tr>
    <td>contraband_drugs</td>
    <td>Indicates whether drugs were found. This is only defined when
    contraband_found is true.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>contraband_weapons</td>
    <td>Indicates whether weapons were found. This is only defined when
    contraband_found is true.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>contraband_other</td>
    <td>Indicates whether contraband other than drugs and weapons were found.
    This is only defined when contraband_found is true.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>frisk_performed</td>
    <td>Indicates whether a frisk was performed. This is technically different
    from a search, but departments will sometimes include frisks as a search
    type.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>search_conducted</td>
    <td>Indicates whether any type of search was conducted, i.e. driver,
    passenger, vehicle. Frisks are excluded where the department has provided
    resolution on both.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>search_person</td>
    <td>Indicates whether a search of a person has occurred. This is only
    defined when search_conducted is TRUE.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>search_vehicle</td>
    <td>Indicates whether a search of a vehicle has occurred. This is only
    defined when search_conducted is TRUE.</td>
    <td>TRUE</td>
  </tr>
  <tr>
    <td>search_basis</td>
    <td>This provides the reason for the search where provided and is
    categorized into k9, plain view, consent, probable cause, and other. If a
    serach occurred but the reason wasn't listed, we assume probable cause.
    </td>
    <td>"consent"</td>
  </tr>
  <tr>
    <td>reason_for_arrest</td>
    <td>A freeform text field indicating the reason for arrest where
    provided.</td>
    <td>"outstanding warrant"</td>
  </tr>
  <tr>
    <td>reason_for_frisk</td>
    <td>A freeform text field indicating the reason for frisk where
    provided.</td>
    <td>"suspicious movement"</td>
  </tr>
  <tr>
    <td>reason_for_search</td>
    <td>A freeform text field indicating the reason for search where
    provided.</td>
    <td>"odor of marijuana"</td>
  </tr>
  <tr>
    <td>reason_for_stop</td>
    <td>A freeform text field indicating the reason for the stop where
    provided.</td>
    <td>"EQUIPMENT MALFUNCTION"</td>
  </tr>
  <tr>
    <td>speed</td>
    <td>The recorded speed of the vehicle for the stop.</td>
    <td>76.2</td>
  </tr>
  <tr>
    <td>posted_speed</td>
    <td>The speed limit where the stop was recorded.</td>
    <td>55</td>
  </tr>
  <tr>
    <td>use_of_force_description</td>
    <td>A freeform text field describing the use of force.</td>
    <td>"handcuffed"</td>
  </tr>
  <tr>
    <td>use_of_force_reason</td>
    <td>A freeform text field describing the reason for the use of force.</td>
    <td>"weapons / violence related incident"</td>
  </tr>
  <tr>
    <td>vehicle_color</td>
    <td>A freeform text of the vehicle color where provided; format varies
    widely.</td>
    <td>"BLK"</td>
  </tr>
  <tr>
    <td>vehicle_make</td>
    <td>A freeform text of the vehicle make where provided; format varies
    widely.</td>
    <td>"TOYOTA"</td>
  </tr>
  <tr>
    <td>vehicle_model</td>
    <td>A freeform text of the vehicle model where provided; format varies
    widely.</td>
    <td>"Cherokee"</td>
  </tr>
  <tr>
    <td>vehicle_type</td>
    <td>A freeform text of the vehicle type where provided; format varies
    widely.</td>
    <td>"TRUCK"</td>
  </tr>
  <tr>
    <td>vehicle_registration_state</td>
    <td>A freeform text of the vehicle registration state where provided;
    format varies widely.</td>
    <td>"CA"</td>
  </tr>
  <tr>
    <td>vehicle_year</td>
    <td>Vehicle manufacture year where provided. This value is NA for any year
    before 1800.</td>
    <td>2007</td>
  </tr>
  <tr>
    <td>notes</td>
    <td>A freeform text field containing any officer notes.</td>
    <td>"NO PASSENGERS"</td>
  </tr>
</table>
* Removed for public release for privacy reasons.

### Best practices

We provide some lessons we’ve learned from working with this rich, but
complicated data. 

1. Read over the notes and processing code if you are going to focus on a
   particular location, so you’re aware of the judgment calls we made in
   processing the data. Taking a look at the original raw data is also wise
   (and may uncover additional fields of interest). 
2. Start with the cleaned data from a single small location to get a feel for
   the data. Rhode Island, Vermont, and Connecticut are all load quickly. 
3. Note that loading and analyzing every state simultaneously takes significant
   time and computing resources. One way to get around this is to compute
   aggregate statistics from each state. For example, you can compute search
   rates for each age, gender, and race group in each state, save those rates,
   and then quickly load them to compute national-level statistics broken down
   by age, race, and gender. 
4. Take care when making direct comparisons between locations. For example, if
   one state has a far higher consent search rate than another state, that may
   reflect a difference in search recording policy across states, as opposed to
   an actual difference in consent search rates. 
5. Examine counts over time in each state: for example, total numbers of stops
   and searches by month or year. This will help you find years for which data
   is very sparse (which you may not want to include in analysis). 
6. Do not assume that all disparities are due to discrimination. For example,
   if young men are more likely to receive citations after being stopped for
   speeding, this might simply reflect the fact that they are driving faster.  
7. Do not assume the standardized data are absolutely clean. We discovered and
   corrected numerous errors in the original data, which were often very
   sparsely documented and changed from year to year, requiring us to make
   educated guesses. This messy nature of the original data makes it unlikely
   the cleaned data are perfectly correct. 
8. Do not read too much into very high stop, search, or other rates in
   locations with very small populations or numbers of stops. For example, if a
   county has only 100 stops of Hispanic drivers, estimates of search rates for
   Hispanic drivers will be very noisy and hit rates will be even noisier.
   Similarly, if a county with very few residents has a very large number of
   stops, it may be that the stops are not of county residents, making stop
   rate computations misleading. 

The following contains date ranges, coverage rates, and some notes on each
location.  A coverage rate is 1 - null rate, so it represents the proportion of
data that have values for that feature. The reported coverage rates are also
predicated, which means that some columns coverage is calculated only after
considering another column. For instance, the coverage for contraband_found is
reported after filtering to instances where search_conducted was true. In a
similar fashion, search_basis and reason_for_search are only calculated when
search conducted is true, reason_for_arrest when arrest_made is true, and
contraband_drugs, contraband_weapons, and contraband_alcohol, and
_contraband__other when contraband_found is true.

The notes are not intended to be a comprehensive
description of all the data features in every state, since this would be
prohibitively lengthy. Rather, they are brief observations we made while
processing the data. We hope they will be useful to others. They are worth
reading prior to performing detailed analysis of a location.

Our analysis only scratches the surface of what’s possible with these data.
We’re excited to see what you come up with!


## Little Rock, AR
### 2017-01-01 to 2017-11-03
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, AZ
### 2009-01-06 to 2015-11-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 89.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 52.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 89.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 2.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 4.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 94.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 98.6% </td>
  </tr>
</tbody>
</table>


## Gilbert, AZ
### 2008-01-01 to 2018-05-23
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
</tbody>
</table>


## Mesa, AZ
### 2014-01-01 to 2017-03-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 93.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## San Diego, CA
### 2014-01-01 to 2017-03-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> service_area </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 96.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 91.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 91.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 91.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 89.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 66.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 90.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 3.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 3.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 87.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
</tbody>
</table>


## San Bernardino, CA
### 2011-12-13 to 2017-09-19
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 98.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 93.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 93.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 70.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 38.0% </td>
  </tr>
</tbody>
</table>


## Anaheim, CA
### 2012-01-01 to 2017-03-14
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## San Francisco, CA
### 2007-01-01 to 2016-06-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 94.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 93.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 98.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
</tbody>
</table>


## Long Beach, CA
### 2008-01-01 to 2017-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 74.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 74.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 66.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 66.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subdistrict </td>
   <td style="text-align:left;"> 66.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 66.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_years_of_service </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 84.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 83.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 84.5% </td>
  </tr>
</tbody>
</table>


## Santa Ana, CA
### 2014-06-11 to 2018-04-13
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 96.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> region </td>
   <td style="text-align:left;"> 96.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## San Jose, CA
### 2013-09-01 to 2018-03-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 92.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 88.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 88.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 96.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 88.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 38.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 93.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 94.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> use_of_force_description </td>
   <td style="text-align:left;"> 87.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> use_of_force_reason </td>
   <td style="text-align:left;"> 91.6% </td>
  </tr>
</tbody>
</table>


## Stockton, CA
### 2012-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 54.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 54.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
</tbody>
</table>


## Bakersfield, CA
### 2008-03-09 to 2018-03-09
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 98.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 98.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 91.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, CA
### 2009-07-01 to 2016-06-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 69.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 69.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 69.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 69.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 4.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 0.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 0.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Denver, CO
### 2010-12-31 to 2018-07-19
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 51.4% </td>
  </tr>
</tbody>
</table>


## Aurora, CO
### 2012-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 81.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 81.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 80.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 96.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 96.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 97.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 98.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, CO
### 2010-01-01 to 2017-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 75.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 85.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 76.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 89.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 89.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 34.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 89.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 89.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 83.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 58.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 58.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 58.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 45.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 98.1% </td>
  </tr>
</tbody>
</table>


## Statewide, CT
### 2013-10-01 to 2015-10-01
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 21.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 21.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 89.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 89.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 98.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 95.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 50.4% </td>
  </tr>
</tbody>
</table>


## Hartford, CT
### 2013-10-13 to 2016-09-29
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 93.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 86.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Tampa, FL
### 2000-03-02 to 2018-03-07
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 97.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 93.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 93.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 97.6% </td>
  </tr>
</tbody>
</table>


## Saint Petersburg, FL
### 2010-01-01 to 2010-07-29
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 89.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 89.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 98.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, FL
### 2010-01-01 to 2016-10-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 22.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 75.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 75.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 81.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 77.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 86.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 75.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_years_of_service </td>
   <td style="text-align:left;"> 92.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 75.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unit </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 92.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 92.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 91.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 75.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 92.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 92.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 65.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 75.4% </td>
  </tr>
</tbody>
</table>


## Statewide, GA
### 2012-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 34.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 52.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 96.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 98.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 96.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 95.2% </td>
  </tr>
</tbody>
</table>


## Statewide, IA
### 2006-01-01 to 2016-04-25
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 84.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 89.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 4.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 39.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 26.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 39.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 57.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 57.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 57.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 85.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 92.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 84.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 84.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 84.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 53.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 54.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 52.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 38.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 38.3% </td>
  </tr>
</tbody>
</table>


## Idaho Falls, ID
### 2008-08-13 to 2016-07-25
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 84.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 84.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> neighborhood </td>
   <td style="text-align:left;"> 93.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 59.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subdivision </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 92.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 31.8% </td>
  </tr>
</tbody>
</table>


## Statewide, IL
### 2012-01-01 to 2017-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 98.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_yob </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 32.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 97.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
</tbody>
</table>


## Chicago, IL
### 2012-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 91.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 75.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 75.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 25.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 26.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 18.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 18.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 7.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 93.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 93.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 93.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 93.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_years_of_service </td>
   <td style="text-align:left;"> 92.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 25.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 75.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Fort Wayne, IN
### 2007-09-01 to 2017-09-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 66.3% </td>
  </tr>
</tbody>
</table>


## Wichita, KS
### 2006-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 97.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 97.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 97.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 81.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 97.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 82.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 97.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 30.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 93.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 95.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 46.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 28.2% </td>
  </tr>
</tbody>
</table>


## Owensboro, KY
### 2015-09-01 to 2017-09-01
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
</tbody>
</table>


## New Orleans, LA
### 2001-03-03 to 2018-07-18
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 81.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 50.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 50.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 97.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 97.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 97.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_assignment </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 70.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 65.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 53.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 54.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 50.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 53.1% </td>
  </tr>
</tbody>
</table>


## Statewide, MA
### 2007-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 95.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 90.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 51.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
</tbody>
</table>


## Baltimore, MD
### 2011-01-01 to 2017-12-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 63.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 60.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 89.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 89.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 97.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, MD
### 2007-01-01 to 2014-03-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 97.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 23.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 23.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 22.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 22.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 98.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 1.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 94.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 93.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 93.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 78.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 82.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 2.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 2.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 14.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_arrest </td>
   <td style="text-align:left;"> 87.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
</tbody>
</table>


## Statewide, MI
### 2001-07-06 to 2016-05-09
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 97.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Saint Paul, MN
### 2001-01-01 to 2016-12-13
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> police_grid_number </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 13.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 82.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 84.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 13.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 84.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 84.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 84.2% </td>
  </tr>
</tbody>
</table>


## Statewide, MO
### 2010-01-01 to 2015-01-01
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, MS
### 2013-01-01 to 2016-07-27
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, MT
### 2009-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 97.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 92.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 96.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
</tbody>
</table>


## Raleigh, NC
### 2002-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 97.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 3.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 3.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 3.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 98.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, NC
### 2000-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 49.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 97.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 3.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 3.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 3.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 96.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Winston-Salem, NC
### 2000-01-11 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 78.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 97.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 2.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 2.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 2.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 99.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Greensboro, NC
### 2000-01-04 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 97.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 5.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 5.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 5.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 97.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Durham, NC
### 2001-12-28 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 85.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 96.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 6.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 6.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 6.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 96.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Fayetteville, NC
### 2000-01-07 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 96.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 97.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 5.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 5.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 5.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 95.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Charlotte, NC
### 2000-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 95.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 5.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 5.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 5.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_frisk </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Grand Forks, ND
### 2007-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 93.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 93.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 60.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, ND
### 2010-01-01 to 2015-06-25
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, NE
### 2002-01-01 to 2016-10-01
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 47.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, NH
### 2014-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 87.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 87.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 52.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 52.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 63.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 98.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 94.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
</tbody>
</table>


## Statewide, NJ
### 2009-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 97.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 77.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 3.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 77.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 77.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 78.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 3.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 3.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 97.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 96.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 24.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 99.3% </td>
  </tr>
</tbody>
</table>


## Camden, NJ
### 2013-05-01 to 2018-06-13
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 98.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 98.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 98.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unit </td>
   <td style="text-align:left;"> 42.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 47.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 71.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 71.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 71.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 74.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 70.8% </td>
  </tr>
</tbody>
</table>


## Statewide, NV
### 2012-02-14 to 2016-05-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 91.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, NY
### 2010-01-01 to 2017-12-14
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 88.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 33.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 33.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 99.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
</tbody>
</table>


## Albany, NY
### 2008-01-01 to 2017-12-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 90.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 90.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 90.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 61.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 98.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 98.8% </td>
  </tr>
</tbody>
</table>


## Columbus, OH
### 2012-01-01 to 2016-12-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 89.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 89.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 90.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, OH
### 2010-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 91.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 91.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 50.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 39.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 18.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Cincinnati, OH
### 2001-04-04 to 2018-05-28
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> neighborhood </td>
   <td style="text-align:left;"> 24.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 23.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_assignment </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> disposition </td>
   <td style="text-align:left;"> 24.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 86.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 12.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 98.8% </td>
  </tr>
</tbody>
</table>


## Oklahoma City, OK
### 2007-07-01 to 2017-10-18
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 89.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 89.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 84.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> division </td>
   <td style="text-align:left;"> 84.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 84.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 89.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 85.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 85.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 47.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 81.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 77.9% </td>
  </tr>
</tbody>
</table>


## Tulsa, OK
### 2009-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 90.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 90.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 37.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 39.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 90.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 93.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 82.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 92.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 93.2% </td>
  </tr>
</tbody>
</table>


## Statewide, OR
### 2010-01-01 to 2014-01-01
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Philadelphia, PA
### 2014-01-01 to 2018-04-14
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 98.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 94.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 94.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> service_area </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 5.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, RI
### 2005-01-02 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_yob </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 93.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 73.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 9.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 0.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 94.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 62.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 45.1% </td>
  </tr>
</tbody>
</table>


## Statewide, SC
### 2005-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 23.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 23.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_age </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 66.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 66.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, SD
### 2012-01-01 to 2016-02-29
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 16.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 76.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 92.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 79.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 77.2% </td>
  </tr>
</tbody>
</table>


## Statewide, TN
### 2000-01-01 to 2016-06-26
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 71.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 99.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 92.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 95.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 94.5% </td>
  </tr>
</tbody>
</table>


## Nashville, TN
### 2010-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 94.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 94.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 85.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reporting_area </td>
   <td style="text-align:left;"> 87.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> zone </td>
   <td style="text-align:left;"> 85.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 79.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 85.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> notes </td>
   <td style="text-align:left;"> 19.5% </td>
  </tr>
</tbody>
</table>


## Houston, TX
### 2014-01-01 to 2018-04-08
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 93.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 93.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 93.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 88.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 88.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 81.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 96.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 96.7% </td>
  </tr>
</tbody>
</table>


## Austin, TX
### 2006-01-01 to 2016-06-30
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 96.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 81.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 48.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 49.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 60.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 2.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 82.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 89.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 83.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 97.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 31.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 97.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 74.5% </td>
  </tr>
</tbody>
</table>


## Plano, TX
### 2012-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 49.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 48.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 48.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 46.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 46.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 0.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 22.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 22.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 48.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unit </td>
   <td style="text-align:left;"> 22.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 98.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 86.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 32.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 0.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 80.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 4.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 13.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 14.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 22.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 22.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 22.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 21.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> notes </td>
   <td style="text-align:left;"> 22.6% </td>
  </tr>
</tbody>
</table>


## Arlington, TX
### 2016-01-01 to 2016-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 99.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 99.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Statewide, TX
### 2006-01-01 to 2017-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 92.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 58.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 58.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 92.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 32.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> region </td>
   <td style="text-align:left;"> 92.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 64.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 92.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 23.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 45.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 71.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 66.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 67.1% </td>
  </tr>
</tbody>
</table>


## San Antonio, TX
### 2012-01-01 to 2018-04-19
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> substation </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 98.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 17.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 86.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 87.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 86.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 87.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 86.0% </td>
  </tr>
</tbody>
</table>


## Statewide, VA
### 2006-01-07 to 2016-04-23
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 87.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 0.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Burlington, VT
### 2012-01-01 to 2017-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 98.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 98.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 96.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 97.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 98.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 98.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 98.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 18.3% </td>
  </tr>
</tbody>
</table>


## Statewide, VT
### 2010-07-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 92.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 98.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 99.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_search </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 99.2% </td>
  </tr>
</tbody>
</table>


## Statewide, WA
### 2009-01-01 to 2016-03-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 91.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 87.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 87.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 87.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 73.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 73.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 73.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_race </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_sex </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 32.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 63.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 72.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> frisk_performed </td>
   <td style="text-align:left;"> 73.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 73.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Tacoma, WA
### 2007-09-11 to 2017-09-10
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 82.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 82.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 79.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subsector </td>
   <td style="text-align:left;"> 79.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 64.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


## Seattle, WA
### 2006-01-01 to 2015-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 91.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 91.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> beat </td>
   <td style="text-align:left;"> 90.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precinct </td>
   <td style="text-align:left;"> 90.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 90.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 31.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_dob </td>
   <td style="text-align:left;"> 31.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 0.1% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 96.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 96.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 85.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 96.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 58.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> reason_for_stop </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 4.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 3.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 3.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 6.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 0.2% </td>
  </tr>
</tbody>
</table>


## Madison, WI
### 2007-09-28 to 2017-09-28
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 94.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 92.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 92.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> district </td>
   <td style="text-align:left;"> 85.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sector </td>
   <td style="text-align:left;"> 85.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 98.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> speed </td>
   <td style="text-align:left;"> 24.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> posted_speed </td>
   <td style="text-align:left;"> 24.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 93.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 97.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 24.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 97.8% </td>
  </tr>
</tbody>
</table>


## Statewide, WI
### 2010-01-01 to 2016-05-16
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lat </td>
   <td style="text-align:left;"> 32.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lng </td>
   <td style="text-align:left;"> 32.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 85.5% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 85.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_first_name </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_last_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_name </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> arrest_made </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> citation_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> warning_issued </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> outcome </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_found </td>
   <td style="text-align:left;"> 67.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_drugs </td>
   <td style="text-align:left;"> 91.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_weapons </td>
   <td style="text-align:left;"> 78.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_alcohol </td>
   <td style="text-align:left;"> 0.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> contraband_other </td>
   <td style="text-align:left;"> 0.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_conducted </td>
   <td style="text-align:left;"> 85.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_person </td>
   <td style="text-align:left;"> 85.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_vehicle </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> search_basis </td>
   <td style="text-align:left;"> 99.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_color </td>
   <td style="text-align:left;"> 86.9% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_make </td>
   <td style="text-align:left;"> 87.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_model </td>
   <td style="text-align:left;"> 74.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_type </td>
   <td style="text-align:left;"> 87.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_registration_state </td>
   <td style="text-align:left;"> 72.2% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vehicle_year </td>
   <td style="text-align:left;"> 77.3% </td>
  </tr>
</tbody>
</table>


## Statewide, WY
### 2011-01-01 to 2012-12-31
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> feature </th>
   <th style="text-align:left;"> coverage rate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 99.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> time </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> location </td>
   <td style="text-align:left;"> 99.4% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> county_name </td>
   <td style="text-align:left;"> 98.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_age </td>
   <td style="text-align:left;"> 99.6% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_race </td>
   <td style="text-align:left;"> 99.7% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> subject_sex </td>
   <td style="text-align:left;"> 99.3% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> officer_id_hash </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> department_id </td>
   <td style="text-align:left;"> 93.8% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> type </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> violation </td>
   <td style="text-align:left;"> 100.0% </td>
  </tr>
</tbody>
</table>


