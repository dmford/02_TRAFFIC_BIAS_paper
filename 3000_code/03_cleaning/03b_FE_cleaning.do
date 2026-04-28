* 03b_FE_cleaning.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/03_cleaning/03_SMCL_logs/03b_FE_cleaning", smcl replace

import delimited "2000_data/100_original/10_FE_CSVs/FE_rough_clean.csv", clear

* (2017 MS John Doe ---> identified later as Michael Len West)
replace fe_subject_name = "Michael Len West" if (fe_subject_name == "John Doe") & (fe_id == 23315)

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

* dropping a handful of unusable event-observations 
drop if state == ""
drop if dept_name == ""
drop if substr(fe_armed,1,9) == "Duplicate"

* problem: dept = "A, B, C, D, ..." for some event-obs 
	* solution: split into separate depts, stack (now repeating events)
split dept_name, parse(,)
drop dept_name

order state city zip dept_name*

sort state city dept_name1 dept_name2 dept_name3 dept_name4 dept_name5 dept_name6 

foreach dept of varlist dept_name* {
	qui replace `dept' = "georgia state patrol" if `dept' == "georgia state police"

	qui replace `dept' = "macoupin county sheriff's office" if `dept' == "macoupin county county sheriff's office"

	qui replace `dept' = "peoria police department" if `dept' == "peoria police police department"

	qui replace `dept' = "vermilion county sheriff's office" if `dept' == "vermillion county sheriff's office"

	qui replace `dept' = "louisville metro police department" if `dept' == "louisville metropolitan police department"

	qui replace `dept' = "baltimore police department" if `dept' == "baltimore city police department"

	qui replace `dept' = "montgomery county police department" if `dept' == "montgomery county department of police"
	qui replace `dept' = "maryland transportation authority police" if `dept' == "maryland transportation police authority" 
	qui replace `dept' = "st. mary's county sheriff's office" if `dept' == "saint mary's county sheriff's office"
	qui replace `dept' = "st. louis county police department" if `dept' == "`st. louis county police department"
	qui replace `dept' = "kansas city (mo) police department" if `dept' == "kansas city police department (mo)"
	qui replace `dept' = "missouri state highway patrol" if `dept' == "missouri highway patrol"

	qui replace `dept' = "mississippi highway patrol" if `dept' == "mississippi highway safety patrol"

	qui replace `dept' = "charlotte-mecklenburg police department" if `dept' == "charlotte police department" & state == "NC"
	qui replace `dept' = "charlotte-mecklenburg police department" if `dept' == "charlotte-mecklenburg" & state == "NC"
	qui replace `dept' = "hertford county sheriff's office" if `dept' == "hertford county chief deputy will liverman"
	qui replace `dept' = "north carolina state highway patrol" if `dept' == "north carolina highway patrol" | dept_name1 == "north carolina state patrol"

	qui replace `dept' = "lincoln county sheriff's office" if `dept' == "lincoln county sheriff's department" & state == "NE"
	qui replace `dept' = "omaha police department" if `dept' == "omaha police department'" & state == "NE"

	qui replace `dept' = "columbus division of police" if `dept' == "columbus police department" & state == "OH"
	qui replace `dept' = "ohio state highway patrol" if `dept' == "ohio highway patrol" | dept_name1 == "ohio state patrol"

	qui replace `dept' = "oklahoma city police department" if `dept' == "oklahoma police department"

	qui replace `dept' = "south carolina highway patrol" if `dept' == "south carolina state highway patrol"

	qui replace `dept' = "metro nashville police department" if `dept' == "metropolitan nashville police department" 
}

save "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace

****************************************************************************************************

* stacking split dept_name variables, making dataset longer
	* this will attribute some events to multiple departments
	* (emailed Brian from FE - he says no rhyme or reason to listed dept orders)
use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name1 == ""
drop dept_name2 dept_name3 dept_name4 dept_name5 dept_name6 dept_name7 dept_name8
rename dept_name1 dept_name
gen fe_dept_order = 1
save "2000_data/200_raw/10_FE_DTAs/FE_raw_1", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name2 == ""
drop dept_name1 dept_name3 dept_name4 dept_name5 dept_name6 dept_name7 dept_name8
rename dept_name2 dept_name
gen fe_dept_order = 2
save "2000_data/200_raw/10_FE_DTAs/FE_raw_2", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name3 == ""
drop dept_name1 dept_name2 dept_name4 dept_name5 dept_name6 dept_name7 dept_name8
rename dept_name3 dept_name
gen fe_dept_order = 3
save "2000_data/200_raw/10_FE_DTAs/FE_raw_3", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name4 == ""
drop dept_name1 dept_name2 dept_name3 dept_name5 dept_name6 dept_name7 dept_name8
rename dept_name4 dept_name
gen fe_dept_order = 4
save "2000_data/200_raw/10_FE_DTAs/FE_raw_4", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name5 == ""
drop dept_name1 dept_name2 dept_name3 dept_name4 dept_name6 dept_name7 dept_name8
rename dept_name5 dept_name
gen fe_dept_order = 5
save "2000_data/200_raw/10_FE_DTAs/FE_raw_5", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name6 == ""
drop dept_name1 dept_name2 dept_name3 dept_name4 dept_name5 dept_name7 dept_name8
rename dept_name6 dept_name
gen fe_dept_order = 6
save "2000_data/200_raw/10_FE_DTAs/FE_raw_6", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name7 == ""
drop dept_name1 dept_name2 dept_name3 dept_name4 dept_name5 dept_name6 dept_name8
rename dept_name7 dept_name
gen fe_dept_order = 7
save "2000_data/200_raw/10_FE_DTAs/FE_raw_7", replace

use "2000_data/200_raw/10_FE_DTAs/FE_raw_0", replace
drop if dept_name8 == ""
drop dept_name1 dept_name2 dept_name3 dept_name4 dept_name5 dept_name6 dept_name7 
rename dept_name8 dept_name
gen fe_dept_order = 8
save "2000_data/200_raw/10_FE_DTAs/FE_raw_8", replace

****************************************************************************************************

* appending the split-dept datasets back together 
use "2000_data/200_raw/10_FE_DTAs/FE_raw_1", replace
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_2"
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_3"
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_4"
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_5"
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_6"
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_7"
append using "2000_data/200_raw/10_FE_DTAs/FE_raw_8"

****************************************************************************************************

* renaming things ahead of merge
rename dept_name department_name
replace department_name = strtrim(department_name)
replace department_name = stritrim(department_name)
rename city fe_city
rename county_name fe_county_name

* FE dates --> shooting_date
gen shooting_date = date(fe_date, "MDY")
drop fe_date
format %td shooting_date

* generating dept, state-specific unique department names: = state + _ + dept
gen st_dept = state + "_" + department_name

* re-framing FE's fe_subject_race variable: 
rename fe_subject_race orig_fe_subject_race
gen fe_subject_race = 1 if inlist(orig_fe_subject_race, "European-American/White", "European-American/European-American/White", "european-American/White", "Christopher Anthony Alexander")
replace fe_subject_race = 2 if inlist(orig_fe_subject_race, "African-American/Black", "African-American/Black African-American/Black Not imputed")
replace fe_subject_race = 3 if inlist(orig_fe_subject_race, "Hispanic/Latino")
replace fe_subject_race = 4 if inlist(orig_fe_subject_race, "Asian/Pacific Islander")
replace fe_subject_race = 5 if inlist(orig_fe_subject_race, "Native American/Alaskan")
replace fe_subject_race = 6 if inlist(orig_fe_subject_race, "Middle Eastern")
replace fe_subject_race = 8 if inlist(orig_fe_subject_race, "Race unspecified")
gen fe_subject_race_flag = (fe_subject_race == 8 | fe_subject_race == 9)
label values fe_subject_race races
drop orig_fe_subject_race

* re-framing fe_highest_force variable: 
label define force_levels 1 "Gunshot" 2 "Vehicle" 3 "Tasered" 4 "Medical emergency" 5 "Asphyxiated/Restrained" 6 "Drowned" 7 "Beaten/Bludgeoned with instrument" 8 "Drug overdose" 9 "Fell from a height" 10 "Stabbed" 11 "Burned/Smoke inhalation" 12 "Chemical agent/Pepper spray" 13 "Less-than-lethal force" 14 "Other" 99 "Undetermined"
replace fe_highest_force = "Asphyxiated/Restrained" if fe_highest_force == "Asphyxiation/Restrain" | fe_highest_force == "Asphyxiation/Restrained" | fe_highest_force == "Restrain/Asphyxiation"
rename fe_highest_force orig_fe_highest_force
gen fe_highest_force = .
replace fe_highest_force = 1 if orig_fe_highest_force == "Gunshot"
replace fe_highest_force = 2 if orig_fe_highest_force == "Vehicle"
replace fe_highest_force = 3 if orig_fe_highest_force == "Tasered"
replace fe_highest_force = 4 if orig_fe_highest_force == "Medical emergency"
replace fe_highest_force = 5 if orig_fe_highest_force == "Asphyxiated/Restrained"
replace fe_highest_force = 6 if orig_fe_highest_force == "Drowned"
replace fe_highest_force = 7 if orig_fe_highest_force == "Beaten/Bludgeoned with instrument"
replace fe_highest_force = 8 if orig_fe_highest_force == "Drug overdose"
replace fe_highest_force = 9 if orig_fe_highest_force == "Fell from a height"
replace fe_highest_force = 10 if orig_fe_highest_force == "Stabbed"
replace fe_highest_force = 11 if orig_fe_highest_force == "Burned/Smoke inhalation"
replace fe_highest_force = 12 if orig_fe_highest_force == "Chemical agent/Pepper spray"
replace fe_highest_force = 13 if orig_fe_highest_force == "Less-than-lethal force"
replace fe_highest_force = 14 if orig_fe_highest_force == "Other"
replace fe_highest_force = 99 if orig_fe_highest_force == "Undetermined"
label values fe_highest_force force_levels
drop orig_fe_highest_force

* re-framing FE's fe_armed variable: 
rename fe_armed orig_fe_armed
gen fe_armed = .
replace fe_armed = 0 if inlist(orig_fe_armed, "Unarmed", "None")
replace fe_armed = 1 if inlist(orig_fe_armed, "Armed", "Arrmed")
replace fe_armed = 8 if orig_fe_armed == "Uncertain"
label values fe_armed false_true_unk_na
drop orig_fe_armed

* re-framing FE's fe_subject_age variable: 
* NOTE: assuming dist'n of 18-25 y/o's is uniform, replacing with 21.5, the median. 
gen fe_subject_age_18_25 = (fe_subject_age == "18-25")
replace fe_subject_age = "21.5" if fe_subject_age == "18-25"
replace fe_subject_age = "999" if fe_subject_age == "NA"
destring fe_subject_age, replace
gen fe_subject_age_nines = (fe_subject_age == 999)
egen temp_age = max(fe_subject_age_nines) 
if temp_age == 0 drop fe_subject_age_nines
drop temp_age

* re-framing FE's fe_subject_sex variable: (1=male, 2=female, 3=trans, 9=NA)
rename fe_subject_gender fe_subject_sex
label define sex 1 "male" 2 "female" 3 "transgender" 9 "NA"
replace fe_subject_sex = "1" if fe_subject_sex == "Male"
replace fe_subject_sex = "2" if fe_subject_sex == "Female"
replace fe_subject_sex = "3" if fe_subject_sex == "Transgender"
destring fe_subject_sex, replace
label values fe_subject_sex sex
gen fe_subject_sex_flag = (fe_subject_sex == 9)

* fe_id*date repeats: 10092 10465 11759 12841 13497 13539 14224 14442 15098 16374 23812 24777 24916 25618 25869 26238 28057 28135
	* multi-depts among (black*unarmed*shot/bludgeoned/asphyxiated) events, 
drop if (fe_id == 10092) & (st_dept != "KY_louisville metro police department") 
drop if (fe_id == 10465) & (st_dept != "SC_denmark police department")
drop if (fe_id == 11759) & (st_dept != "MO_u.s. bureau of alcohol tobacco firearms and explosives")
drop if (fe_id == 12841) & (st_dept != "WA_lakewood police department")
drop if (fe_id == 13497) & (st_dept != "DC_u.s. secret service")
drop if (fe_id == 13539) & (st_dept != "NC_new hanover county sheriff's office")
drop if (fe_id == 14224) & (st_dept != "MD_maryland state police")
drop if (fe_id == 14442) & (st_dept != "TX_texas department of public safety")
drop if (fe_id == 15098) & (st_dept != "NJ_lyndhurst police department")
drop if (fe_id == 16374) 
drop if (fe_id == 23812) & (st_dept != "VA_immigration and customs enforcement")
drop if (fe_id == 24777) & (st_dept != "TX_harris county sheriff's office")
drop if (fe_id == 24916) & (st_dept != "NJ_essex county sheriff's office")
* (can't quite tell if this one was "connecticut state police" or "willimantic police department")
drop if (fe_id == 25618) & (st_dept != "CT_connecticut state police")
drop if (fe_id == 25869) 
drop if (fe_id == 26238) & (st_dept != "PA_pennsylvania state constable")
drop if (fe_id == 28057) 
drop if (fe_id == 28135) & (st_dept != "ND_grand forks police department")

drop fe_dept_order

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

* SAVING RESULTING DATASET
save "2000_data/300_cleaning/10_FE/FE_clean_pre_STN.dta", replace

import excel "2000_data\100_original\10_FE_CSVs\saytheirnames.xlsx", sheet("Sheet1") firstrow clear

* need this to align for merging 
rename Names fe_subject_name
* necessary + sufficient conditions for caring about "SayTheirName"
keep if (FE_SOPP_match == 1) & (match_plus_STN == 1)
* no longer need any of these variables - identified 19 "STN_events" with 5 "STN_stories"
keep fe_subject_name STN STN_stories

merge 1:m fe_subject_name using "2000_data/300_cleaning/10_FE/FE_clean_pre_STN.dta", gen(STN_merge)

replace STN = 0 if (STN != 1)
replace STN_stories = 0 if (STN_stories != 1)

* Moving Incorrect Event-Dates
* one day later than reported
replace shooting_date = 20214 if (fe_id == 16069)
* one day earlier than reported
replace shooting_date = 19094 if (fe_id == 11223)
* died just after midnight, one day later than reported 
replace shooting_date = 20444 if (fe_id == 17046)
* died just after midnight, one day later than reported
replace shooting_date = 19602 if (fe_id == 13340)
* one day earlier than reported
replace shooting_date = 19504 if (fe_id == 12853)
* one day later than reported
replace shooting_date = 20029 if (fe_id == 15296)
* shooting was off by an entire month, (suspected armed)
replace shooting_date = 21500 if (fe_id == 25084)

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/300_cleaning/10_FE/FE_clean.dta", replace

log close
