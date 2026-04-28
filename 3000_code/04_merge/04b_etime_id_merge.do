*  04b_etime_id_merge.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/04_merge/04_SMCL_logs/04b_etime_id_merge", smcl replace

use "2000_data/300_cleaning/10_FE/FEgtrend_pre_id.dta", replace

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

* making a decision: using (post-mean)-(pre-mean) instead of (post_peak)-(pre-mean)
drop scr_*_postp
rename scr_nl_postm scr_nl
rename scr_nu_postm scr_nu
rename scr_dl_postm scr_dl
rename scr_du_postm scr_du

**********   identifying nearest any-events   **********************************

* At this stage I have (602 events * 840 days) = 505,680 observations

* making a list of all departments: 
qui levelsof st_dept, local(reg_depts)

* making some placeholders, note: e_1 is closest "by default" in this approach
	*note: this is only using TREATED st_depts
* 0 if any event, 1 if (scr_nl>0), 2 if (scr_nu>0), 3 if (scr_dl>0), 4 if (scr_du>0)
gen reg_etime0 = .
gen reg_etime1 = .
gen reg_etime2 = .
gen reg_etime3 = .
gen reg_etime4 = .

gen reg_edate0 = .
gen reg_edate1 = .
gen reg_edate2 = .
gen reg_edate3 = .
gen reg_edate4 = .

gen nearest_etime0 = "e0_1"
gen nearest_etime1 = "e1_1"
gen nearest_etime2 = "e2_1"
gen nearest_etime3 = "e3_1"
gen nearest_etime4 = "e4_1"

gen nearest_edate0 = .
gen nearest_edate1 = .
gen nearest_edate2 = .
gen nearest_edate3 = .
gen nearest_edate4 = .

* figures out how many events does each dept have (max=19)
	*make e_`i' variables for this many potential-events
egen reg_event_tag0 = tag(st_dept edate) 
egen reg_event_tag1 = tag(st_dept edate) if (scr_nl != .)
egen reg_event_tag2 = tag(st_dept edate) if (scr_nu != .)
egen reg_event_tag3 = tag(st_dept edate) if (scr_dl != .)
egen reg_event_tag4 = tag(st_dept edate) if (scr_du != .)

bysort st_dept: egen reg_event_count0 = sum(reg_event_tag0)
bysort st_dept: egen reg_event_count1 = sum(reg_event_tag1)
bysort st_dept: egen reg_event_count2 = sum(reg_event_tag2)
bysort st_dept: egen reg_event_count3 = sum(reg_event_tag3)
bysort st_dept: egen reg_event_count4 = sum(reg_event_tag4)

* identifying max #events: 
summ reg_event_count0 
local reg_event_max0 = r(max)
drop reg_event_tag0 reg_event_count0

summ reg_event_count1 
local reg_event_max1 = r(max)
drop reg_event_tag1 reg_event_count1

summ reg_event_count2 
local reg_event_max2 = r(max)
drop reg_event_tag2 reg_event_count2

summ reg_event_count3 
local reg_event_max3 = r(max)
drop reg_event_tag3 reg_event_count3

summ reg_event_count4 
local reg_event_max4 = r(max)
drop reg_event_tag4 reg_event_count4

* making placeholder series of e_* based on max #events: 
display `reg_event_max0'
forvalues i=1(1)`reg_event_max0' {
	gen e0_`i' = .
}

display `reg_event_max1'
forvalues i=1(1)`reg_event_max1' {
	gen e1_`i' = .
}

display `reg_event_max2'
forvalues i=1(1)`reg_event_max2' {
	gen e2_`i' = .
}

display `reg_event_max3'
forvalues i=1(1)`reg_event_max3' {
	gen e3_`i' = .
}

display `reg_event_max4'
forvalues i=1(1)`reg_event_max4' {
	gen e4_`i' = .
}

* for all treated depts, pull list of edates
	* determine etime, iteratively determine lowest-etime, i.e. nearest-event
* look at all depts d, make list of edates, replace e_1 with etime relative to dept's 1st edate
	* continue, replacing e_2 with etime relative to dept's 2nd edate, up to (max #events)
* replacing "nearest etime=e_1" variable with #days relative to nearest event for each dept*event
foreach d of local reg_depts {
	display ""
	display "Department: `d'"
	qui levelsof edate if (st_dept=="`d'"), local(edates)
	local j = 1
	foreach e of local edates {
		display "Event-Date: " %td `e'
		replace e0_`j' = date - `e' if (st_dept=="`d'")
		local ++j
	}
	qui replace nearest_etime0 = "e0_2" if (abs(e0_2) < abs(e0_1)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_3" if (abs(e0_3) < abs(e0_2)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_4" if (abs(e0_4) < abs(e0_3)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_5" if (abs(e0_5) < abs(e0_4)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_6" if (abs(e0_6) < abs(e0_5)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_7" if (abs(e0_7) < abs(e0_6)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_8" if (abs(e0_8) < abs(e0_7)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_9" if (abs(e0_9) < abs(e0_8)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_10" if (abs(e0_10) < abs(e0_9)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_11" if (abs(e0_11) < abs(e0_10)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_12" if (abs(e0_12) < abs(e0_11)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_13" if (abs(e0_13) < abs(e0_12)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_14" if (abs(e0_14) < abs(e0_13)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_15" if (abs(e0_15) < abs(e0_14)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_16" if (abs(e0_16) < abs(e0_15)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_17" if (abs(e0_17) < abs(e0_16)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_18" if (abs(e0_18) < abs(e0_17)) & (st_dept=="`d'")
	qui replace nearest_etime0 = "e0_19" if (abs(e0_19) < abs(e0_18)) & (st_dept=="`d'")
}

* determining nearest_edate for each (treated) dept*date
qui replace nearest_edate0 = date - e0_1 if (nearest_etime0 == "e0_1")
qui replace nearest_edate0 = date - e0_2 if (nearest_etime0 == "e0_2")
qui replace nearest_edate0 = date - e0_3 if (nearest_etime0 == "e0_3")
qui replace nearest_edate0 = date - e0_4 if (nearest_etime0 == "e0_4")
qui replace nearest_edate0 = date - e0_5 if (nearest_etime0 == "e0_5")
qui replace nearest_edate0 = date - e0_6 if (nearest_etime0 == "e0_6")
qui replace nearest_edate0 = date - e0_7 if (nearest_etime0 == "e0_7")
qui replace nearest_edate0 = date - e0_8 if (nearest_etime0 == "e0_8")
qui replace nearest_edate0 = date - e0_9 if (nearest_etime0 == "e0_9")
qui replace nearest_edate0 = date - e0_10 if (nearest_etime0 == "e0_10")
qui replace nearest_edate0 = date - e0_11 if (nearest_etime0 == "e0_11")
qui replace nearest_edate0 = date - e0_12 if (nearest_etime0 == "e0_12")
qui replace nearest_edate0 = date - e0_13 if (nearest_etime0 == "e0_13")
qui replace nearest_edate0 = date - e0_14 if (nearest_etime0 == "e0_14")
qui replace nearest_edate0 = date - e0_15 if (nearest_etime0 == "e0_15")
qui replace nearest_edate0 = date - e0_16 if (nearest_etime0 == "e0_16")
qui replace nearest_edate0 = date - e0_17 if (nearest_etime0 == "e0_17")
qui replace nearest_edate0 = date - e0_18 if (nearest_etime0 == "e0_18")
qui replace nearest_edate0 = date - e0_19 if (nearest_etime0 == "e0_19")

replace reg_etime0 = date - nearest_edate0
replace reg_edate0 = nearest_edate0
drop nearest_etime0 nearest_edate0 e0_*
format reg_edate0 %td

* temp adjustment to allow below loop to work: 
rename scr_nl scr_1
rename scr_nu scr_2
rename scr_dl scr_3
rename scr_du scr_4

* above but for popular treatment definition (based on high scrutiny)
forvalues i=1(1)4 {
	foreach d of local reg_depts {
		display ""
		display "Department: `d'"
		qui levelsof edate if (st_dept=="`d'") & (scr_`i' != .), local(edates)
		local j = 1
		foreach e of local edates {
			display "Event-Date: " %td `e'
			replace e`i'_`j' = date - `e' if (st_dept=="`d'")
			local ++j
		}
		qui replace nearest_etime`i' = "e`i'_2" if (abs(e`i'_2) < abs(e`i'_1)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_3" if (abs(e`i'_3) < abs(e`i'_2)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_4" if (abs(e`i'_4) < abs(e`i'_3)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_5" if (abs(e`i'_5) < abs(e`i'_4)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_6" if (abs(e`i'_6) < abs(e`i'_5)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_7" if (abs(e`i'_7) < abs(e`i'_6)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_8" if (abs(e`i'_8) < abs(e`i'_7)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_9" if (abs(e`i'_9) < abs(e`i'_8)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_10" if (abs(e`i'_10) < abs(e`i'_9)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_11" if (abs(e`i'_11) < abs(e`i'_10)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_12" if (abs(e`i'_12) < abs(e`i'_11)) & (st_dept=="`d'")
		qui replace nearest_etime`i' = "e`i'_13" if (abs(e`i'_13) < abs(e`i'_12)) & (st_dept=="`d'")
	}

	* determining nearest_edate for each (treated) dept*date
	qui replace nearest_edate`i' = date - e`i'_1 if (nearest_etime`i' == "e`i'_1")
	qui replace nearest_edate`i' = date - e`i'_2 if (nearest_etime`i' == "e`i'_2")
	qui replace nearest_edate`i' = date - e`i'_3 if (nearest_etime`i' == "e`i'_3")
	qui replace nearest_edate`i' = date - e`i'_4 if (nearest_etime`i' == "e`i'_4")
	qui replace nearest_edate`i' = date - e`i'_5 if (nearest_etime`i' == "e`i'_5")
	qui replace nearest_edate`i' = date - e`i'_6 if (nearest_etime`i' == "e`i'_6")
	qui replace nearest_edate`i' = date - e`i'_7 if (nearest_etime`i' == "e`i'_7")
	qui replace nearest_edate`i' = date - e`i'_8 if (nearest_etime`i' == "e`i'_8")
	qui replace nearest_edate`i' = date - e`i'_9 if (nearest_etime`i' == "e`i'_9")
	qui replace nearest_edate`i' = date - e`i'_10 if (nearest_etime`i' == "e`i'_10")
	qui replace nearest_edate`i' = date - e`i'_11 if (nearest_etime`i' == "e`i'_11")
	qui replace nearest_edate`i' = date - e`i'_12 if (nearest_etime`i' == "e`i'_12")
	qui replace nearest_edate`i' = date - e`i'_13 if (nearest_etime`i' == "e`i'_13")

	replace reg_etime`i' = date - nearest_edate`i'
	replace reg_edate`i' = nearest_edate`i'
	drop nearest_etime`i' nearest_edate`i' e`i'_*
	format reg_edate`i' %td
}

* reverting above adjustment, easier to have scrutiny type within its own name
rename scr_1 scr_nl
rename scr_2 scr_nu
rename scr_3 scr_dl
rename scr_4 scr_du

* reducing step: if not (nearest shooting date) can't be (nearest scrutinized date) or (nearest un-scrutinized date)
	* I have event*date obs, but events outnumber depts, so multiple dates for many depts 
		* want only 1 date for each dept; (dropping dept-edate combinations that are not nearest)
drop if (edate != reg_edate0) & (edate != reg_edate1) & (edate != reg_edate2) & (edate != reg_edate3) & (edate!= reg_edate4)

* instead of dropping, marking rows as "samples", hopefully this works out? 
	* reg_edate`i' based on scr_* gtrend data; should be obs with an edate (treated) which (aligns with the edate based on scr)
gen sample0 = (edate == reg_edate0)
gen sample1 = (edate == reg_edate1)
gen sample2 = (edate == reg_edate2)
gen sample3 = (edate == reg_edate3)
gen sample4 = (edate == reg_edate4)

save "2000_data/300_cleaning/10_FE/FE_pre_merge_stop_level_reg.dta", replace

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

********************************************************************************

* Dates for consideration: 
	* 01Jan2011 = 18628, 31Dec2020 = 22280
* So WHY did I have: 
	*if ((date>=18053) & (date<22646)), 05Jun2009-01Jan2022? 575 and 366 days wrong?
use state county_name st_dept search_conducted contraband_found subject_race stop_date search_basis officer_race type rep_monthly rep_annually if (stop_date>=18628 & stop_date<=22280) using "2000_data/300_cleaning/20_SOPP/SOPP_clean.dta", replace

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

gen temp_st_dept = st_dept
drop st_dept
rename temp_st_dept st_dept

rename stop_date date 

sort st_dept date

joinby st_dept date using "2000_data/300_cleaning/10_FE/FE_pre_merge_stop_level_reg.dta", unmatched(both) _merge(FEgtrend_SOPP_merge)

* joinby _merge: (1=master, 2=using, 3=both)
* dropping FE-only (using) departments, i.e. depts with ZERO stop obs
	* (no st_dept*date) data & (_merge variable invariant)
bysort st_dept: egen temp_max = max(FEgtrend_SOPP_merge)
bysort st_dept: egen temp_min = min(FEgtrend_SOPP_merge)
gen temp_test = temp_max - temp_min 
drop if ((FEgtrend_SOPP_merge == 2) & (temp_test == 0))
drop temp_*

* want control group in all samples 
	* control should be "anything not already defined in/out of sample"
	* should be very low not-sample #obs, because it is only (dept*date > +/- 18*`k' days from event)
replace sample0 = 1 if sample0==.
replace sample1 = 1 if sample1==.
replace sample2 = 1 if sample2==.
replace sample3 = 1 if sample3==.
replace sample4 = 1 if sample4==.

* generating a few variables to use in regressions: 
gen white = 0
gen black = 0
gen hispanic = 0
replace white = 1 if (subject_race==1)
replace black = 1 if (subject_race==2)

gen n_stops = 1
encode st_dept, gen(num_dept)

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/400_base/10_merged/merged_gtrends", replace

log close
