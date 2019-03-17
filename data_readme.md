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
    <td>The date of the stop, in YYYY-MM-DD format. Some states do not provide
    the exact stop date: for example, they only provide the year or quarter in
    which the stop occurred. For these states, stop_date is set to the date at
    the beginning of the period: for example, January 1 if only year is
    provided.</td>
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
    <td>The latitude of the stop. If not provided by the department, we
    attempt to geocode any provided address or location using
    Google Maps. Google Maps returns a "best effort" response, which may not
    be completely accurate if the provided location was malformed or
    underspecified. To protect against suprious responses, geocodes more than
    4 standard deviations from the median stop lat/lng are set to NA.
    <td>72.23545</td>
  </tr>
  <tr>
    <td>lng</td>
    <td>The longitude of the stop. If not provided by the department, we
    attempt to geocode any provided address or location using
    Google Maps. Google Maps returns a "best effort" response, which may not
    be completely accurate if the provided location was malformed or
    underspecified. To protect against suprious responses, geocodes more than
    4 standard deviations from the median stop lat/lng are set to NA.
    </td>
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

**Data notes**:
- Data is deduplicated on call_id, reducing the number of records 17.6%; this
  was equivalent to deduping on date, time, location, and officer_id; subject
  name appears to have been entered multiple times per call_id, and often in
  subtly different formats
- Most important data is missing, including outcome (arrest, citation,
  warning), reason for stop, search, contraband, and demographic information
  on the subject (except name, which is redacted for privacy)

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

**Data notes**:
- INCIDENT_NO appears to refer to the same incident but can involve
  multiple people, i.e. 20150240096, which appears to be an alcohol bust of
  several underage teenagers; in other instances, the rows look nearly
  identical, but given this information and checking several other seeming
  duplicates, it appears as though there is one row per person per incident

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

**Data notes**:
- lat/lng data doesn't appear totally accurate, there are ~18k lat/lngs that
  were coerced to NA because they all equalled "-1.79769313486232E+308"
- Data is deduplicated on date, time, lat, lng, race, sex, and officer name,
  reducing the number of records by ~30.6%
- Data consists only of citations

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

**Data notes**:
- Counties were mapped in two ways. First, we determined which counties the
  codes in the County field referred to by using the highways which appeared
  most frequently in each coded county. Second, for stops which had no data in
  the County field, we used the values in the Highway and Milepost fields to
  estimate where the stop took place. For this, we relied on highway marker
  maps (sources:
  [here](https://azdot.gov/docs/business/state-milepost-map.pdf?sfvrsn=0) and
  [here](http://adot.maps.arcgis.com/apps/Viewer/index.html?appid=4f19dfc238c44815b310bc72a9827bc2)
  to map the most frequently traversed highways, which covered the vast
  majority of stops. Using these two methods, we were able to map 95% of stops
  which had any location data (i.e., values in either County or Highway and
  Milepost), and 89% of stops overall.
- It would be possible to map the highway and mile marker data to geo
  coordinates, like we did in Washington.
- Data for violation reason is largely missing. 
- VehicleSearchAuthority might provide search type but we lack a mapping for
  the codes. TypeOfSearch includes information on whom was searched (e.g.,
  driver vs. passenger), but does not provide information on the type of search
  (e.g., probable cause vs. consent). ConsentSearchAccepted gives us
  information on search type for a small fraction of searches.  
- There is a two-week period in October 2012 and a two-week period in November
  2013 when no stops are recorded. Dates are sparse in 2009–2010.
- We also received a file with partial data on traffic stops pre-2009; this is
  not included in the cleaned dataset. 
- Some contraband information is available and so we define a contraband_found
  column in case it is useful to other researchers. But the data is messy and
  there are multiple ways contraband_found might be defined, and so we do not
  include Arizona in our contraband analysis. 

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

**Data notes**:
- Very little information received, only a reference number, date, year, case
  type (with no translation), and a case type (with no translation)

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

**Data notes**:
- Data is deduplicated on raw columns date_of_birth, subject_address,
  ethnicity, gender_code, occ_date, occ_time, reducing the number of records by
  ~1.2% 
- Data does not include reason for stop, search, contraband fields
- Missing data dictionaries for ticket classes, ticket statuses, and
  statute section
- Data consists only of citations

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

**Data notes**:
- Data is deduplicated on raw columns CreateDateTime, Address, and CallType,
  removing ~26.3% of records
- Data does not include most useful information, including demographic,
  outcome, and search/contraband information, so the deduplication above
  potentially over-deduplicates

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

**Data notes**:
- Data is deduplicated on raw columns Date, Location, Race, Sex, and Officer
  DID, reducing the number of records by ~14.3%
- Data does not include reason for stop, search, or contraband fields 

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

**Data notes**:
- stop_id in raw data doesn't appear to apply to unique events, as the same
  id has different service_area, subject_race, subject_age, and subject_sex,
  i.e.1099162
- Data is deduplicated on raw columns timestamp, subject_race, subject_sex,
  subject_age, and service_area, reducing the number or records by X%
- There are no locations, but service_area is provided

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

**Data notes**:
- Search basis in the raw data is only "No Search", consent, or other
  (inventory, incident to arrest, and parole searches) 
- Data is deduplicated on raw columns date, time, race_description, sex, age,
  location, removing ~0.3% of stops

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

**Data notes**:
- event_number in raw data has indeterminate meaning, several event numbers
  occur at the same time but have up to 16 duplicates; however, some of these
  involve different subjects, so it's unclear whether they are distinct
  incidents or large incidents involving many people
- Data is deduplicated using date, time, location, and subject race; this
  removes about 5.0% of rows, but many of these rows are lacking sufficient
  information for differentiation, i.e. they have NA for many of their values

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

**Data notes**:
- Deduping on raw columns Date, Race, Sex, Violation Description, Officer
  (Badge), and Primary Street would reduce this dataset by ~9.7%, but there is
  insufficient information to justify this without the incident time. For
  instance, the highest frequency "incident" deduping on that critera was 16
  male Hispanic drivers failing to stop at a stop sign by the same officer on
  5th Street; while this could be 16 duplicates, it could also be the same
  officer pulling over 16 people throughtout that day
- Data does not include search or contraband information
- Data includes only citations

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

**Data notes**:
- CHP districts roughly map to counties, so we mapped stops to counties using
  the map of CHP districts, which is included in the raw data. Some counties
  appear to have very high stop rates; this is because they have very small
  populations. It seems likely that the stops occurring in those counties are
  not actually the resident population.
- Driver age categories are included in the raw data; these cannot be mapped to
  granular values, so we cannot fill out the driver_age field. 
- Very few consent searches are conducted relative to other states. 
- Contraband found information is only available for a small subset of
  searches: the raw data can tell you if a probable cause search or a consent
  search yielded contraband, but cannot tell you if contraband was located
  during a search conducted incident to arrest. We therefore exclude California
  from our contraband analysis. 
- Shift time is included, but is not sufficiently granular to yield reliable
  stop time. 

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

**Data notes**:
- Data consists of two sets of files, traffic stop surveys and CAD stop files,
  but currently there is no information on how to join them; location is in the
  stop files, but all other demographic information is in the traffic stop
  survey files
- There may be duplicates, but unclear how to identify them, as date, age,
  gender, and race are the only consistently filled in fields, and the maximum
  number of stops for any date, age, gender, race combination is 10, which is a
  reasonable number of stops for that combination over the course of a day in
  the entire city occasionally
- officer_id is coalesced officer_id and officer_id2, the former being 90% null
  and the latter 50% null in the dataset

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

**Data notes**:
- Data is deduplicated on raw columns Ticket Date, Ticket Time, Ticket
  Location, First Name, Last Name, sex, and Date of Birth, reducing the number
  of records by ~1.0%

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

**Data notes**:
- MASTER_INCIDENT_NUMBER has many duplicates, but it's unclear what it
  corresponds to or how to deduplicate it if that is the correct thing to do,
  since the records are nearly identical except for the NEIGHBORHOOD_NAME
- Data does not contain subject demographic or search/contraband information

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

**Data notes**:
- The state did not provide us with mappings for every police department code
  to police department name.
- Arrest and citation data are unreliable from 2014 onward. Arrest rates drop
  essentially to zero. 
- Counties were mapped using a dictionary provided by the agency. Denver County
  has many fewer stops than expected given the residential population; this is
  because it only contains a small section of highway which is policed by the
  state patrol.
- Rows represent violations, not stops, so we remove duplicates by grouping by
  the other fields.

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

**Data notes**:
- Counties were mapped by running the cities in the `Intervention Location
  Name` field through Google's geocoder.
- Rows appear to represent violations, not individual stops, because a small
  proportion of rows (1%) report the same officer making multiple stops at the
  same location at the same time. We grouped the data to combine these
  duplicates. We don't want to be overly aggressive in grouping together stops,
  so we only group if the other fields are the same. 
- While there is some search type data, a high fraction of searches are marked
  as "Other", so we exclude Connecticut from our consent search analysis.
- While there is some violation data, we exclude Connecticut from the speeding
  analysis because it has too much missing data in the violation field.
- The Connecticut state patrol created another website
  ([link](http://ctrp3.ctdata.org/)), where new data will get uploaded going
  forward. We haven't processed this yet.

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

**Data notes**:
- Data is deduplicated on raw columns InterventionDateTime,
  ReportingOfficerIdentificationID, InterventionLocationDescriptionText,
  SubjectRaceCode, SubjectSexCode, and SubjectAge, reducing the number of rows
  by ~1.1%

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

**Data notes**:
- 

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

- Data is missing search and contraband information, as well as outcomes other
  than citations
- The data sources are public:
  - https://publicrec.hillsclerk.com/Traffic/Civil_Traffic_Name_Index_files/
  - https://publicrec.hillsclerk.com/Traffic/Criminal_Traffic_Name_Index_files/


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

**Data notes**:
- The raw data is very messy. Two different data sets were supplied, both with
  slightly different schemas. However, they were joined by uniquely identifying
  features. The second data dump goes until 2016, while the first only goes
  until 2015. The fields missing in the second data set are thus missing for
  some rows.
- There are many duplicates in the raw data, which we remove in two stages.
  First, we remove identical duplicate rows. Second, we group together rows
  which correspond to the same stop but to different violations or passengers. 
- The original data has a few parsing errors, but they don't seem important as
  they are spurious new lines in the last 'Comments' field.
- The Florida PD clarified to us that both UCC Issued and DVER Issued in the
  `EnforcementAction` column indicated citations, and we consequently coded
  them as such. 
- While there is some data on whether items were seized, it is not clear if
  these are generally seized as a result of a search, and we thus do not define
  a contraband_found column for consistency with other states. 

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

**Data notes**:
- The data represent warnings.
- The provided `.txt` was comma-separated, but not quoted. Therefor we had to
  write a script (`convert_GA.py`) to iron out some obviously misaligned
  columns.
- Rows represent individual warnings, and thus need to be aggregated to
  represent a single stop.
- The race field on the warnings form is optional.

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

**Data notes**: 
- The data separates warnings and citations. They are very different with
  respect to which fields they have available. Both contain duplicates. This
  happens when individuals receive more than one warning or citation within the
  same stop. We remove these by grouping by the remaining fields by the stop
  key and date.
- In some cases, there are multiple time stamps per unique (key, date)
  combination. In most of these cases, the timestamps differ by a few minutes,
  but all other fields (except for violation) are the same. In 0.1% of stops,
  the max span between timestamps is more than 60 minutes. In those cases it
  looks like the same officer stopped the same individual more than once in the
  same day.   
- Only citations have `Ethnicity`, which only provides information on whether
  the driver is Hispanic. We therefore exclude Iowa from our main analysis
  because race data is lacking. 
- Only (some) citations have county, the warnings only have trooper district.
  The mapping for the districts is provided in the resources folder. Counties
  were mapped by comparing the identifiers in the `LOCKCOUNTY` field with the
  cities in the `LOCKCITY` field.
- The codes in the county field represent counties ordered alphabetically.

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

**Data notes**:
- The data is very messy. The presence and meaning of fields relating to search
  and contraband vary year by year. Caution should be used when inspecting
  search and hit rates over time. We exclude Illinois from our time trend
  marijuana analysis for this reason. 
- For state patrol stops, there is mostly no information on the county of the
  stop. Instead, stops are mapped to districts (see the district column), which
  have a one-to-many relationship with counties. See the relevant map
  [here](http://www.isp.state.il.us/districts/districtfinder.cfm). There is one
  district (#15) with a lot of stops that does not directly map to counties, as
  it refers to stops made on the Chicago tollways. We use districts in our
  analysis. 
- Counties for local stops were mapped by running the police departments in the
  AgencyName field through Google's geocoder.
- The `search_type_raw` field is occasionally "Consent search denied", when a
  search was conducted. This occurs because the search request might be denied
  but a search was conducted anyway. Many searches have missing search type
  data, so we exclude Illinois from our search type analysis. 

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

**Data notes**:
- The search and outcome fields are inconsistent. We take the most progressive
  interpretation: if one of `SearchYN`, `SearchDescr` or the outcome columns
  indicates that there was a search, we label them as such.
- While we define a contraband_found column in case it is useful to other
  researchers, it is sufficiently messy (there are multiple ways you might
  define `contraband_found`, and they are quite inconsistent) that we exclude
  it from our contraband analysis.
- Violation data is not very granular.
- Counties were mapped by running the cities in the `CITY_TOWN_NAME` field
  through Google's geocoder.

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

**Data notes**:
- The data is very messy. It comes from three different time periods: 2007,
  2009-2012, 2013-2014. They all have different column and slightly different
  conventions of how things are recorded. We attempted to standardize the
  fields as much as possible.
- Time resolution of the data varies by year. Prior to 2013, data is reported
  annually. From 2013 onward, data is reported daily. So stop dates prior to
  2013 are not precise to the nearest day and are just reported as Jan 1. 
- Counties were mapped by running the police departments in the `Agency` field
  through Google's geocoder, but this does not work for state patrol stops, for
  which we have no county information. 
- While there is information on violation, speeding stops constitute a very
  small fraction of stops compared to other states, and we therefore exclude
  Maryland from our speeding analysis. 

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

**Data notes**:
- The original data had some unquoted fields (`VoidReason` and `Description`)
  which had commas in them. We manually fixed these with a python script, which
  can be found in the `/scripts` folder.
- Driver race data has more than 50% missing data, so we excluded Michigan from
  the analysis in the paper.
- The codes in the `CountyCode` field represent counties ordered
  alphabetically.
- Rows represent violations, not stops, so we remove duplicates by grouping by
  the other fields.

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

**Data notes**:
- The original data was aggregated. There is detail on a number of fields (age,
  stop purpose, outcome) that is not usable as it is not cross-tabulated with
  the other fields.
- Because this is aggregate data, stop date is only precise to the nearest
  year, and is recorded as Jan 1 for all stops. 
- Counties for local stops were mapped by running the cities in the city field
  through Google's geocoder, but there is no county information for state
  patrol stops. 

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

**Data notes**:
- Counties were mapped using the dictionary provided, which is added to the raw
  data folder. Counties are numbered alphabetically.
- There is no data on Hispanic drivers, so we exclude Mississippi from our main
  analysis. 

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

**Data notes**: none

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

**Data notes**:
- Stop time is often unreliable — we have a large overdensity of 00:00 values,
  which we set to NA. 
- The location of the stop is recorded in two different ways. Some stops have a
  county code, which can be mapped using the provided dictionary, which is
  included in the raw data. Other stops are only labeled with the state patrol
  district. Some districts map directly onto counties, in which case we label
  the stop with that county. However, some districts cover multiple counties.
  Stops in these districts can thus not be unambiguously mapped to a single
  county. In both cases, district of the stop is provided in the "district"
  column, providing granular location data for the vast majority of stops.
- Action is sometimes "No Action" or a similarly minor enforcement action even
  when `DriverArrest` or `PassengerArrest` is TRUE. In these cases, we set
  stop_outcome to be "Arrest" because the stop_outcome field represents the
  most severe outcome of the stop.
- `search_conducted` is TRUE if either the driver or passenger is searched. In
  3.6% of cases, the passenger is searched. As their names suggest,
  `driver_race`, `driver_gender`, and `driver_age` always refer to the driver.

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

STOP
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

**Data notes**:
- The data contain records only for citations, not warnings, so we exclude
  North Dakota from our analysis.
- Rows represent individual citations, not stops, so we remove duplicates by
  grouping by the other fields.
- The `stop_purpose` field is populated by citation codes.

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

**Data notes**:
- The original data was aggregated. It was grouped by stop reason, outcome and
  whether there was a search separately. Therefore, it is not possible to cross
  tabulate them together. We only use the last grouping.
- State and local stops are mixed together, but identifiable by the `dept_lvl`
  field.
- The data is by quarter, not by day. So all stop_dates are the first date of
  the quarter.
- For state patrol stops, there is a strange jump (Q1) and then dip (Q2–4) in
  the data for 2012. It looks like for 2012 all stops are recorded as happening
  in the first quarter.

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

**Data notes**:
- The `driver_race` field was populated by hand-written codes that we manually
  decoded. They are prone to mislabeling and should be used with caution only.
  Also, a very high percentage of stops (>30%) are missing race data entirely.
  We map the most common codes, covering more than 99% of stops with data, but
  we do not interpret the long tail of misspellings because many of them are
  ambiguous, we do not want to make assumptions, and it does not significantly
  improve the data. We exclude this dataset from our analysis because it has
  too much missing race data. 
- The stop_purpose field is populated by infraction codes. Code descriptions
  can be found [here](http://www.gencourt.state.nh.us/rsa/html/)
- The driver_age field was not populated for the 2014.2 dataset.
- Rows represent violations, not stops, so we remove duplicates by grouping by
  the other fields.

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

**Data notes**:
- New Jersey data may be updated: we received the data very recently, and still
  have a number of questions we are waiting on the state to answer. 
- New Jersey uses sofware produced by [LawSoft
  Inc.](http://www.lawsoft-inc.com). There are two sets of data: CAD (computer
  aided dispatch, recorded at the time of stop) and RMS (record management
  system, recorded later). They have almost completely disjoint fields, and
  only RMS records have information on searches. We believe the data from the
  two systems should really be joined, but according to the NJSP there is not a
  programmatic way to do so. Therefore, we process just the CAD data, which
  appears to be the dataset which corresponds to traffic stops. 
- In the CAD data, there are often multiple rows per incident. Some of these
  are identical duplicates, which we remove. For the remaining records, we
  group by `CAD_INCIDENT`, because the NJSP told us that each `CAD_INCIDENT` ID
  refers to one stop. We verified that more than 99.9% of `CAD_INCIDENT` IDs
  had unique location and time, implying that they did, in fact, correspond to
  distinct events. 
- `driver_race` and `driver_gender` correspond to the race of the driver, not
  the passenger. 
- Statutes are mapped using the [traffic
  code](http://law.justia.com/codes/new-jersey/2013/title-39), where possible.
- The CAD records were mapped to a county by running the `TOWNSHIP` values
  through the Google geocoder. 

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

**Data notes**:
- Nevada does not seem to record Ethnicity or have any records of Hispanic
  drivers, so we exclude it from our analysis. 
- The violation field is populated by infraction codes.

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

**Data notes**:
- The data include only citations.
- There is no data on searches.
- The data stops at 2017-12-13.

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

**Data notes**:
  - `Incident Number` in the original data seems unreliable as it has several
    hundred entries for 9999 and 99999; furthermore, occasionally, it does
    appear to reference the same incident, but is duplicated for every
    distinct action taken against the subject
  - The raw data is deduplicated on `Stop Date`, `Contact End Date`, Ethnicity,
    Gender, ViolationStreet, and ViolationCrossStreet
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

**Data notes**:
- The stop_purpose field is populated by infraction codes. The corresponding
  laws can be read [here](http://codes.ohio.gov/orc/).
- There is no data for contraband being found, but a related field could
  potentially be reconstructed by looking at searches involving drugs and an
  arrest.
- Counties were mapped using the provided dictionary, which is included in the
  raw data folder.
- We cannot find disposition codes (in `DISP_STRING`) which clearly indicate
  whether a citation as opposed to a warning was given, although there is a
  disposition for warnings.
- The data contains stops of both type TS and TSA, standing for "traffic stop""
  and "traffic stop additional". The latter have a higher search rate and tend
  to have additional information (i.e., `ASINC_STRING` is not NA). We include
  both types in analysis, as they do not appear to be duplicates (addresses and
  times do not match) and we do not have a clear reason to exclude either. 
- While there is data on search types, they only include consent and K9
  searches, suggesting a potential difference in recording policy (many other
  states have probable cause searches and incident to arrest searches, for
  example).
- `officer_id` refers to a single officer throughout their tenure on the state
  patrol, but it is re-assigned to a new trooper upon an officer's retirement.

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

**Data notes**:
- There is basically no data, including no data on Hispanic drivers, so we
  exclude Oregon from our analysis.
- Counts for 2015 and 2016 are much lower than in earlier years. 

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

**Data notes**:
- Data is deduplicated on raw columns datetimeoccur, location, districtoccur,
  lat, lng, gender, age, and race, reducing the number of records by ~1.6%
- Information on citations and warnings is missing, but arrests are included

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

**Data notes**:
- The stops are mapped to state patrol zones, which represent police barrack
  juridisdiction areas. However, there is no simple mapping between zones and
  counties. We store state patrol zones in the `district` column and use this
  column in our granular location analyses. 

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

**Data notes**:
- The `police_department` field is populated by state patrol agency.
- More data on local stops is available
  [here](http://afc5102.scdps.gov/SCDPS_Exweb/SCDPS/PublicContact/PublicContact-012).
  It is aggregated by race and age group — potentially scrapable if useful.
- While there is data on violation, many of the stops have missing data, so we
  exclude South Carolina from our speeding analysis. 

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

**Data notes**:
- Race data is missing, so we exclude South Dakota from our analysis. 
- Some county names were misrecorded and needed editing.

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

**Data notes**:
- The data contain only citations, so we exclude Tennessee from our analysis. 
- The codes in the `CNTY_NBR` field represent counties ordered alphabetically.
- It would be possible to map the highway and mile marker data to geo
  coordinates, as we did in Washington.

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

**Data notes**:
- There is evidence that minority drivers are labeled as white in the data. For
  example, see
  [this](http://kxan.com/investigative-story/texas-troopers-ticketing-hispanics-motorists-as-white/)
  report from KXAN. We remapped the driver race field as provided using the
  2000 surnames dataset released by the U.S. Census. See the processing script
  or paper for details.
- We asked whether there was a field which provided arrest data, but received
  no clarification. There is data on incident to arrest searches, but this does
  not necessarily identify all arrests. 
- Based on the provided data dictionary as well as clarification from DPS via
  email, we classify THP6 and TLE6 in `HA_TICKET_TYPE` as citations and HP3 as
  warnings.
- The data only records when citations and warnings were issued, but not
  arrests.

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

**Data notes**:
- The original data was aggregated.
- The data is aggregated by week, not by day.
- Some rows have an unlikely high number of stops or searches. We have an
  outstanding inquiry on this, but for now it is assumed to be correct.
- Counties were mapped using the provided dictionary, which is included in the
  raw data folder.
- There are no written warnings in Virginia and verbal warnings are not
  recorded, so all records are citations or searches without further action
  taken. We, therefore, exclude Virginia from our analysis, because they do not
  record the same set of stops as other states. 
- In the raw data, "Traffic arrests" refer to citations without a search.
  "Search arrests" refer to a citation and a search (either before or after the
  citation). "Search stops" refer to searches without a corresponding citation.

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

**Data notes**:
- Stop purpose information is not very granular — there are only five
  categories, and we have no way of identifying speeding. 
- The search type field includes "Consent search — probable cause" and “Consent
  search — reasonable suspicion". It is not entirely clear what these mean; we
  cannot find analogues in other states.
- Counties were mapped by running the cities in the `Stop City` field through
  Google's geocoder.

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

**Data notes**:
- Counties were mapped by doing a reverse look-up of the geo lat/long
  coordinate of the highway post that was recorded for the stop, then mapping
  that latitude and longitude to a county using a shapefile. Details are in the
  `WA_map_locations.R` script.
- We created an officer ID field based on officer name. Duplicates are possible
  if officers have the same first and last name, however this is unlikely.
- Arrests and citations are grouped together in the `stop_outcome`, so we
  cannot reliably identify arrests. There is data on incident to arrest
  searches, but this does not necessarily identify all arrests.

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

**Data notes**:
- The data come from two systems ("7.3" and “10.0”) that succeeded each other.
  They have different field names and are differently coded. This is
  particularly relevant for the violation field, which has a different encoding
  between the two systems; in order to map violations, we used the dictionaries
  provided by the state for both systems.
- There are two copies of the data: warnings and citations. Citations seems to
  be a strict subset of warnings, with some citation codes being different.
- The `police_department` field is populated by highway patrol agencies. There
  are only 6 of them.
- There are very few consent searches relative to other states, suggesting a
  potential difference in recording policy. 
- `countyDMV` field refers to the county of the stop, as the WI police
  clarified for us. 

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

**Data notes**:
- Only citations are included in the data, so we exclude Wyoming from our
  analysis. 
- The `police_department` field is populated by the state trooper division.
- The violation field is populated by violated statute codes.
- We found an external mapping of statute codes and provide them in the raw
  data.
- Some county names were misrecorded and required editing.
- Rows represent citations, not stops, so we remove duplicates by grouping by
  the other fields. 
- `contraband_found` could potentially be derived from violation codes
  (drug/alcohol/weapons), but it would be less reliable and not necessarily
  comparable to how we defined contraband_found for other states. 
