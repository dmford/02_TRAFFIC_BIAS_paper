* 03a_SOPP_cleaning.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/03_cleaning/03_SMCL_logs/03a_SOPP_cleaning", smcl replace

use "2000_data/300_cleaning/20_SOPP/SOPP_appended.dta", replace

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

* dept non-unique, (state+dept) should be unique --> st_dept
gen st_dept = state + "_" + department_name

* SOPP dates --> stop_date
gen stop_date = date(date, "YMD")
drop date
format %td stop_date

* Assn: if max=min, no variation in days (months)--> monthly (annual) reporter
gen stop_day = day(stop_date)
gen stop_month = month(stop_date)
gen stop_year = year(stop_date)

bysort st_dept stop_month: egen max_stop_day = max(stop_day)
bysort st_dept stop_month: egen min_stop_day = min(stop_day)
gen temp_stop_day_diff = max_stop_day - min_stop_day
gen rep_monthly = (temp_stop_day_diff == 0)
drop temp_* max_stop_day min_stop_day

bysort st_dept stop_year: egen max_stop_month = max(stop_month)
bysort st_dept stop_year: egen min_stop_month = min(stop_month)
gen temp_stop_month_diff = max_stop_month - min_stop_month
gen rep_annually = (temp_stop_month_diff == 0)
drop temp_* max_stop_month min_stop_month 

drop stop_day stop_month stop_year

* re-framing SOPP's subject_race variable: (1=white, 2=black, 3=hispanic, 4=API, 5=NAmerican, 6=ME, 7=other, 8=unk, 9=NA)
label define races 1 "white" 2 "black" 3 "hispanic" 4 "asian/pacific islander" 5 "native american/alaskan" 6 "middle eastern" 7 "other" 8 "unknown" 9 "NA"
rename subject_race orig_subject_race
gen subject_race = 1 if orig_subject_race == "white"
replace subject_race = 2 if orig_subject_race == "black"
replace subject_race = 3 if orig_subject_race == "hispanic"
replace subject_race = 4 if orig_subject_race == "asian/pacific islander"
replace subject_race = 5 if orig_subject_race == "native american/alaskan"
replace subject_race = 6 if orig_subject_race == "middle eastern"
replace subject_race = 7 if orig_subject_race == "other"
replace subject_race = 8 if orig_subject_race == "unknown"
replace subject_race = 9 if orig_subject_race == "NA"
label values subject_race races
drop orig_subject_race
gen subj_race_flag = (subject_race == 8 | subject_race == 9)

* re-framing SOPP's officer_race variable: (1=white, 2=black, 3=hispanic, 4=API, 5=NAmerican, 6=ME, 7=other, 8=unk, 9=NA)
rename officer_race orig_officer_race
gen officer_race = 1 if orig_officer_race == "white"
replace officer_race = 2 if orig_officer_race == "black"
replace officer_race = 3 if orig_officer_race == "hispanic"
replace officer_race = 4 if orig_officer_race == "asian/pacific islander"
replace officer_race = 5 if orig_officer_race == "native american/alaskan"
replace officer_race = 6 if orig_officer_race == "middle eastern"
replace officer_race = 7 if orig_officer_race == "other"
replace officer_race = 8 if orig_officer_race == "unknown"
replace officer_race = 9 if orig_officer_race == "NA"
gen officer_race_flag = (officer_race ==  8 | officer_race == 9)
label values officer_race races
drop orig_officer_race

* re-framing SOPP's subject_age and officer_age variables: 
foreach var of varlist subject_age officer_age {
	replace `var' = "999" if `var' == "NA"
	destring `var', replace
	gen `var'_nines = (`var' == 999)
	egen temp_age = max(`var'_nines) 
	if temp_age == 0 drop `var'_nines
	drop temp_age
}

* re-framing SOPP's subject_sex and officer_sex variables: (1=male, 2=female, 3=trans, 9=NA)
label define sex 1 "male" 2 "female" 3 "transgender" 9 "NA"
foreach var of varlist subject_sex officer_sex {
	replace `var' = "1" if `var' == "male"
	replace `var' = "2" if `var' == "female"
	replace `var' = "3" if `var' == "transgender"
	replace `var' = "9" if `var' == "NA"
	destring `var', replace
	label values `var' sex
	gen `var'_flag = (`var' == 9)
}

* re-framing SOPP's search variables: (0=false, 1=true, 8=unknown, 9=NA)
label define false_true_unk_na 0 "false" 1 "true" 8 "unknown" 9 "NA"
foreach var of varlist search_conducted search_vehicle search_person {
	replace `var' = "0" if `var' == "FALSE"
	replace `var' = "1" if `var' == "TRUE"
	replace `var' = "8" if `var' == "UNKNOWN"
	replace `var' = "9" if `var' == "NA"
	destring `var', replace
	label values `var' false_true_unk_na
	gen flag_`var' = (`var' == 9)
}

* ensuring that any_search --> search_conducted
replace search_conducted = 1 if (search_vehicle==1) | (search_person==1)

* re-framing SOPP's contraband variables: (0=false, 1=true, 8=unknown, 9=NA)
foreach var of varlist contraband_found contraband_alcohol contraband_drugs contraband_weapons contraband_other {
	replace `var' = "0" if `var' == "FALSE"
	replace `var' = "1" if `var' == "TRUE"
	replace `var' = "8" if `var' == "UNKNOWN"
	replace `var' = "9" if `var' == "NA"
	destring `var', replace
	label values `var' false_true_unk_na
	gen flag_`var' = (`var' == 9)
}

* ensuring that any_contraband --> contraband_found 
replace contraband_found = 1 if (contraband_alcohol==1) | (contraband_drugs==1) | (contraband_weapons==1) | (contraband_other==1)

* re-framing SOPP's search_basis variable: 
label define basis 0 "plain view" 1 "consent" 2 "probable cause" 3 "k9" 4 "other" 9 "NA"
replace search_basis = "0" if search_basis == "plain view"
replace search_basis = "1" if search_basis == "consent"
replace search_basis = "2" if search_basis == "probable cause"
replace search_basis = "3" if search_basis == "k9"
replace search_basis = "4" if search_basis == "other"
replace search_basis = "9" if search_basis == "NA"
destring search_basis, replace
label values search_basis basis

save "2000_data/400_base/SOPP_clean.dta", replace

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

log close 
