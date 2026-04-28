*  03c_gtrends_cleaning.do	

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/03_cleaning/03_SMCL_logs/03c_gtrends_cleaning", smcl replace

* Converting Google Trend CSVs to DTAs:
* using Michael Brown (MB) as reference subject: 
filelist, dir("2000_data/100_original/30_gtrend_CSVs/1_subject_trends/monthly/CSV_MB") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)
drop dirname filename fsize csv_path

set obs 1 
gen date = . 
local j = 0

foreach file of local toconvert {
	import delimited "`file'", varnames(3) rowrange(3:) clear
	local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/1_subject_trends/monthly/CSV_MB", "200_raw/30_gtrend_DTAs/1_subject_trends/monthly/DTA_MB/", .)
	local save2 = subinstr("`save1'", ".csv", "", .)
	* (manually-removed ": (united states)" from all)
	gen temp = monthly(month, "YM")
	drop month 
	rename temp month
	format month %tm
	* de-stringing <1 obs
	foreach var of varlist _all {
			rename `var' n_`var'
			capture confirm string variable n_`var'
			if _rc==7 continue
			replace n_`var' = "0.5" if n_`var' == "<1"
			destring n_`var', replace
	}
	rename n_month month
	reshape long n_, i(month) j(name, string)
	rename n_ monthly_name_trends_upper
	gen upper_name_quad = `j'
	local ++j
	save "`save2'", replace
}

* Merging Google Trend DTAs together: 
filelist, dir("2000_data/200_raw/30_gtrend_DTAs/1_subject_trends/monthly/DTA_MB") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename
qui levelsof dta_path, local(toappend)
drop dirname filename fsize dta_path

set obs 1 
gen month = .
format month %tm

foreach file of local toappend {
	append using "`file'"
	drop if month == .
}

bysort upper_name_quad: egen temp_denom = max(monthly_name_trends_upper) if name=="michaelbrown"
bysort upper_name_quad: egen denom = max(temp_denom)
bysort name upper_name_quad: egen num = max(monthly_name_trends_upper)
gen upper_name_key = num / denom
drop temp* num denom

sort upper_name_quad name month

* don't want repeats 
drop if (name=="michaelbrown") & (upper_name_quad!=0)

save "2000_data/300_cleaning/30_gtrend/prep/MB_merged", replace

***************************************************************************************************

* using David Joseph (DJ) as reference subject: 
filelist, dir("2000_data/100_original/30_gtrend_CSVs/1_subject_trends/monthly/CSV_DJ") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)
drop dirname filename fsize csv_path

set obs 1
gen date = .
local j = 0

foreach file of local toconvert {
	import delimited "`file'", varnames(3) rowrange(3:) clear
	local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/1_subject_trends/monthly/CSV_DJ/", "200_raw/30_gtrend_DTAs/1_subject_trends/monthly/DTA_DJ/", .)
	local save2 = subinstr("`save1'", ".csv", "", .)
	* (manually-removed ": (united states)" from all)
	gen temp = monthly(month, "YM")
	drop month 
	rename temp month
	format month %tm
	* de-stringing <1 obs
	foreach var of varlist _all {
			rename `var' n_`var'
			capture confirm string variable n_`var'
			if _rc==7 continue
			replace n_`var' = "0.5" if n_`var' == "<1"
			destring n_`var', replace
	}
	rename n_month month
	reshape long n_, i(month) j(name, string)
	rename n_ monthly_name_trends_lower
	gen lower_name_quad = `j'
	local ++j
	save "`save2'", replace
}

* Merging Google Trend DTAs together: 
filelist, dir("2000_data/200_raw/30_gtrend_DTAs/1_subject_trends/monthly/DTA_DJ") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename
qui levelsof dta_path, local(toappend2)
drop dirname filename fsize dta_path

set obs 1 
gen month = .
format month %tm

foreach file of local toappend2 {
	append using "`file'"
	drop if month == .
}

bysort lower_name_quad: egen temp_denom = max(monthly_name_trends_lower) if name=="davidjoseph"
bysort lower_name_quad: egen denom = max(temp_denom)
bysort name lower_name_quad: egen num = max(monthly_name_trends_lower) 
gen lower_name_key = num / denom
drop temp* num denom

sort lower_name_quad name month

* don't want repeats
drop if (name=="davidjoseph") & (lower_name_quad!=0)

save "2000_data/300_cleaning/30_gtrend/prep/DJ_merged", replace

* merging (upper reference / michael brown) with (lower reference / david joseph)
merge 1:1 name month using "2000_data/300_cleaning/30_gtrend/prep/MB_merged", nogen

save "2000_data/300_cleaning/30_gtrend/monthly_name_trends", replace

***************************************************************************************************

* using ferguson as reference department: 
filelist, dir("2000_data/100_original/30_gtrend_CSVs/2_dept_trends/monthly/CSV_ferguson") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)
drop dirname filename fsize csv_path

set obs 1
gen date = .
local j = 0

foreach file of local toconvert {
	import delimited "`file'", varnames(3) rowrange(3:) clear
	local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/2_dept_trends/monthly/CSV_ferguson", "200_raw/30_gtrend_DTAs/2_dept_trends/monthly/DTA_ferguson", .)
	local save2 = subinstr("`save1'", ".csv", "", .)
	* (manually-removed ": (united states)" from all)
		* (renamed "arizona department..." to "arizona dept" in 4)
		* (and "maryland transportation..." to "maryland transp" in 8)
		* (and "north carolina state highway..." to "north carolina state hwy" in 17)
		* (and "north carolina department..." to "north carolina DMV" in 18)
		* (and "sikeston department..." to "sikeston dept" in 19)
	gen temp = monthly(month, "YM")
	drop month 
	rename temp month
	format month %tm
	* de-stringing <1 obs
	foreach var of varlist _all {
			rename 	`var' n_`var'
			capture confirm string variable n_`var'
			if _rc==7 continue
			replace n_`var' = "0.5" if n_`var' == "<1"
			destring n_`var', replace
	}
	rename n_month month
	reshape long n_, i(month) j(dept, string)
	rename n_ monthly_dept_trends_upper
	gen upper_dept_quad = `j'
	local ++j
	save "`save2'", replace
}

* Merging Google Trend DTAs together: 
filelist, dir("2000_data/200_raw/30_gtrend_DTAs/2_dept_trends/monthly/DTA_ferguson") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename
qui levelsof dta_path, local(toappend1)
drop dirname filename fsize dta_path

set obs 1 
gen month = .
format month %tm

foreach file of local toappend1 {
	append using "`file'"
	drop if month == .
}

* with depts, I had issues with string length - shortened earlier (manually), now restoring 
replace dept = "arizonadepartmentofpublicsafety" if (dept == "arizonadeptofpublicsafety")
replace dept = "marylandtransportationauthoritypolice" if (dept == "marylandtranspauthoritypolice")
replace dept = "northcarolinastatehighwaypatrol" if (dept == "northcarolinastatehwypatrol")
replace dept = "sikestondepartmentofpublicsafety" if (dept == "sikestondeptofpublicsafety")
replace dept = "northcarolinadepartmentofmotorvehicles" if (dept == "northcarolinadmv")

bysort upper_dept_quad: egen temp_denom = max(monthly_dept_trends_upper) if dept=="fergusonpolice"
bysort upper_dept_quad: egen denom = max(temp_denom)
bysort dept upper_dept_quad: egen num = max(monthly_dept_trends_upper)
gen upper_dept_key = num / denom
drop temp* num denom

sort upper_dept_quad dept month 

* don't want repeats
drop if (dept=="fergusonpolice") & (upper_dept_quad!=0)

save "2000_data/300_cleaning/30_gtrend/prep/ferguson_merged", replace

***************************************************************************************************

* using champaign as reference department: 
filelist, dir("2000_data/100_original/30_gtrend_CSVs/2_dept_trends/monthly/CSV_champaign") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)
drop dirname filename fsize csv_path

set obs 1
gen date = .
local j = 0

foreach file of local toconvert {
	import delimited "`file'", varnames(3) rowrange(3:) clear
	local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/2_dept_trends/monthly/CSV_champaign/", "200_raw/30_gtrend_DTAs/2_dept_trends/monthly/DTA_champaign/", .)
	local save2 = subinstr("`save1'", ".csv", "", .)
	* (manually-removed ": (united states)" from all)
		* (renamed "arizona department..." to "arizona dept" in 4)
		* (and "maryland transportation..." to "maryland transp" in 8)
		* (and "north carolina state highway..." to "north carolina state hwy" in 17)
		* (and "north carolina department..." to "north carolina DMV" in 18)
		* (and "sikeston department..." to "sikeston dept" in 19)
	gen temp = monthly(month, "YM")
	drop month 
	rename temp month
	format month %tm
	* de-stringing <1 obs
	foreach var of varlist _all {
			rename 	`var' n_`var'
			capture confirm string variable n_`var'
			if _rc==7 continue
			replace n_`var' = "0.5" if n_`var' == "<1"
			destring n_`var', replace
	}
	rename n_month month
	reshape long n_, i(month) j(dept, string)
	rename n_ monthly_dept_trends_lower
	gen lower_dept_quad = `j'
	local ++j
	save "`save2'", replace
}

* Merging Google Trend DTAs together: 
filelist, dir("2000_data/200_raw/30_gtrend_DTAs/2_dept_trends/monthly/DTA_champaign") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename
qui levelsof dta_path, local(toappend)
drop dirname filename fsize dta_path

set obs 1 
gen month = .
format month %tm

foreach file of local toappend {
	append using "`file'"
	drop if month == .
}

* same as above, manually shortened a few dept names, now restoring 
replace dept = "arizonadepartmentofpublicsafety" if (dept == "arizonadeptofpublicsafety")
replace dept = "marylandtransportationauthoritypolice" if (dept == "marylandtranspauthoritypolice")
replace dept = "northcarolinastatehighwaypatrol" if (dept == "northcarolinastatehwypatrol")
replace dept = "sikestondepartmentofpublicsafety" if (dept == "sikestondeptofpublicsafety")
replace dept = "northcarolinadepartmentofmotorvehicles" if (dept == "northcarolinadmv")

bysort lower_dept_quad: egen temp_denom = max(monthly_dept_trends_lower) if dept=="champaignpolice"
bysort lower_dept_quad: egen denom = max(temp_denom)
bysort dept lower_dept_quad: egen num = max(monthly_dept_trends_lower)
gen lower_dept_key = num / denom
drop temp* num denom

sort lower_dept_quad dept month

* don't want repeats
drop if (dept=="champaignpolice") & (lower_dept_quad!=0)

save "2000_data/300_cleaning/30_gtrend/prep/champaign_merged", replace

* merging (name upper / ferguson) with (name lower / champaign)
merge 1:1 dept month using "2000_data/300_cleaning/30_gtrend/prep/ferguson_merged", nogen

save "2000_data/300_cleaning/30_gtrend/monthly_dept_trends", replace

***************************************************************************************************

filelist, dir("2000_data/100_original/30_gtrend_CSVs/1_subject_trends/daily/time_series") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)
drop dirname filename fsize csv_path

set obs 1
gen date = .

* Manually changed all individual named-based time series Gtrend files: 
	* example: "davidfordunitedstates" --> "davidford"
	* "rename "*unitedsta* *" worked on laptop but not cluster??
foreach file of local toconvert {
	import delimited "`file'", varnames(3) rowrange(3:) clear

	* this loop for trends without search data (too few): 
	if (_N==0) {
		set obs 270
		gen fe_id = substr("`file'",74,5)			
		replace fe_id = subinstr(fe_id,"_","",.)
		destring fe_id, replace
		if (fe_id < 10000) {
			gen temp = substr("`file'",79,5)
		}
		else {
			gen temp = substr("`file'",80,5)
		}
		destring temp, replace
		gen date = temp - 134 in 1
		replace date = date[_n-1]+1 if (_n>1)
		gen event = (date == temp)
		format date %td
		drop temp day
		describe, varlist
		local var3 : word 1 of `r(varlist)'
		gen name = "`var3'"
		rename `var3' daily_name_trends
		order fe_id name date daily_name_trends
		local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/1_subject_trends/daily/time_series", "200_raw/30_gtrend_DTAs/1_subject_trends/daily/time_series", .)
		local save2 = subinstr("`save1'", ".csv", "", .)
		if _rc==0 {
			replace daily_name_trends = "0.5" if daily_name_trends == "<1"
			destring daily_name_trends, replace
		}
		save "`save2'", replace
	}

	* this loop for trends that were non-blank:
	else {
		gen fe_id = substr("`file'",74,5)
		replace fe_id = subinstr(fe_id,"_","",.)
		destring fe_id, replace
		if (fe_id < 10000) {
			gen temp = substr("`file'",79,5)
		}
		else {
			gen temp = substr("`file'",80,5)
		}
		destring temp, replace
		gen date = daily(day,"MDY")
		gen event = (date == temp)
		format date %td
		drop temp day
		describe, varlist
		local var3 : word 1 of `r(varlist)'
		gen name = "`var3'"
		rename `var3' daily_name_trends
		order fe_id name date daily_name_trends
		local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/1_subject_trends/daily/time_series", "200_raw/30_gtrend_DTAs/1_subject_trends/daily/time_series", .)
		local save2 = subinstr("`save1'", ".csv", "", .)
			capture confirm string variable daily_name_trends
		if _rc==0 {
			replace daily_name_trends = "0.5" if daily_name_trends == "<1"
			destring daily_name_trends, replace
		}
		save "`save2'", replace
	}
}

filelist, dir("2000_data/200_raw/30_gtrend_DTAs/1_subject_trends/daily/time_series") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename
qui levelsof dta_path, local(toappend)
drop dirname filename fsize dta_path

set obs 1
gen date = .
format date %td

foreach file of local toappend {
	append using "`file'"
	drop if date == .
}

gen month = mofd(date)
format month %tm

sort fe_id date

save "2000_data/300_cleaning/30_gtrend/daily_name_trends", replace

***************************************************************************************************

filelist, dir("2000_data/100_original/30_gtrend_CSVs/2_dept_trends/daily/time_series") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)
drop dirname filename fsize csv_path

set obs 1
gen date = .

foreach file of local toconvert {
	import delimited "`file'", varnames(3) rowrange(3:) clear
	* (some trends had NO data, too few searches)
	if (_N==0) {
		set obs 270
		gen fe_id = substr("`file'",71,5)
		replace fe_id = subinstr(fe_id,"_","",.)
		destring fe_id, replace
		if (fe_id < 10000) {
			gen temp = substr("`file'",76,5)
		}
		else {
			gen temp = substr("`file'",77,5)
		}
		destring temp, replace
		gen date = temp - 134 in 1
		replace date = date[_n-1]+1 if (_n>1)
		gen event = (date == temp)
		format date %td
		drop temp day
		describe, varlist
		local var3 : word 1 of `r(varlist)'
		gen dept = "`var3'"
		rename `var3' daily_dept_trends
		order fe_id dept date daily_dept_trends
		local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/2_dept_trends/daily/time_series", "200_raw/30_gtrend_DTAs/2_dept_trends/daily/time_series", .)
		local save2 = subinstr("`save1'", ".csv", ".dta", .)
		if _rc==0 {
			replace daily_dept_trends = "0.5" if daily_dept_trends == "<1"
			destring daily_dept_trends, replace
		}
		save "`save2'", replace
	}
	else {
		gen fe_id = substr("`file'",71,5)
		replace fe_id = subinstr(fe_id,"_","",.)
		destring fe_id, replace
		if (fe_id < 10000) {
			gen temp = substr("`file'",76,5)
		}
		else {
			gen temp = substr("`file'",77,5)
		}
		destring temp, replace
		gen date = daily(day,"MDY")
		gen event = (date == temp)
		format date %td
		drop temp day
		describe, varlist
		local var3 : word 1 of `r(varlist)'
		gen dept = "`var3'"
		rename `var3' daily_dept_trends
		order fe_id dept date daily_dept_trends
		local save1 = subinstr("`file'", "100_original/30_gtrend_CSVs/2_dept_trends/daily/time_series", "200_raw/30_gtrend_DTAs/2_dept_trends/daily/time_series", .)
		local save2 = subinstr("`save1'", ".csv", ".dta", .)
			capture confirm string variable daily_dept_trends
		if _rc==0 {
			replace daily_dept_trends = "0.5" if daily_dept_trends == "<1"
			destring daily_dept_trends, replace
		}
		save "`save2'", replace
	}
}

filelist, dir("2000_data/200_raw/30_gtrend_DTAs/2_dept_trends/daily/time_series") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename
qui levelsof dta_path, local(toappend)
drop dirname filename fsize dta_path

set obs 1
gen date = .
format date %td

foreach file of local toappend {
	append using "`file'"
	drop if date == .
}

gen month = mofd(date)
format month %tm

sort fe_id date

* same as above, shortened before now restoring full dept names 
replace dept = "arizonadepartmentofpublicsafety" if (dept == "arizonadeptofpublicsafety")
replace dept = "marylandtransportationauthoritypolice" if (dept == "marylandtranspauthoritypolice")
replace dept = "northcarolinastatehighwaypatrol" if (dept == "northcarolinastatehwypatrol")
replace dept = "sikestondepartmentofpublicsafety" if (dept == "sikestondeptofpublicsafety")
replace dept = "northcarolinadepartmentofmotorvehicles" if (dept == "northcarolinadmv")

save "2000_data/300_cleaning/30_gtrend/daily_dept_trends", replace

* this should merge ~perfectly~
merge 1:1 fe_id date using "2000_data/300_cleaning/30_gtrend/daily_name_trends"

* (NOTE: daily_name_trends==. iff . for each date)
	* (same for daily_dept_trends)
gen local_name_blank = (daily_name_trends==.)
gen local_dept_blank = (daily_dept_trends==.)
replace daily_name_trends = 0 if (daily_name_trends==.)
replace daily_dept_trends = 0 if (daily_dept_trends==.)

save "2000_data/400_base/30_gtrend/prep/daily_trends", replace

***************************************************************************************************

merge m:1 name month using "2000_data/300_cleaning/30_gtrend/monthly_name_trends", gen(monthly_name_merge)
* matches for all daily-obs, only monthly-obs unmatched (as expected)

merge m:1 dept month using "2000_data/300_cleaning/30_gtrend/monthly_dept_trends", gen(monthly_dept_merge)

* this should merge ~as expected~ with three distinct groups: 
tab monthly_name_merge monthly_dept_merge
drop if date==.
tab monthly_name_merge monthly_dept_merge

* using relative weight to reference-term to scale the +/- 135-day trends comparably
gen gt_name_lower = daily_name_trends * lower_name_key
gen gt_name_upper = daily_name_trends * upper_name_key
gen gt_dept_lower = daily_dept_trends * lower_dept_key
gen gt_dept_upper = daily_dept_trends * upper_dept_key

gen temp_edate = date if event==1
bysort fe_id: egen edate = max(temp_edate)
format edate %td
drop temp*

sort fe_id date 
drop *_merge month *_quad monthly_* *_key daily_*_trends 
order fe_id date name gt_name_lower gt_name_upper dept gt_dept_lower gt_dept_upper event

gen post = date >= edate

* identifying pre-event mean, and post-event mean/peak:
foreach var in gt_name_lower gt_name_upper gt_dept_lower gt_dept_upper {
	bysort fe_id: egen temp_pre_`var' = mean(`var') if (post==0)
	bysort fe_id: egen temp_mean_`var' = mean(`var') if (post==1)
	bysort fe_id: egen temp_post_`var' = max(`var') if (post==1)
	bysort fe_id: egen pre_`var' = max(temp_pre_`var')
	bysort fe_id: egen mean_`var' = max(temp_mean_`var')
	bysort fe_id: egen post_`var' = max(temp_post_`var')
	drop temp_*
}

* identifying post-mean - pre-mean, and post-peak - pre-mean: 
gen nl_postm = mean_gt_name_lower - pre_gt_name_lower 
gen nl_postp = post_gt_name_lower - pre_gt_name_lower 
gen nu_postm = mean_gt_name_upper - pre_gt_name_upper
gen nu_postp = post_gt_name_upper - pre_gt_name_upper
gen dl_postm = mean_gt_dept_lower - pre_gt_dept_lower
gen dl_postp = post_gt_dept_lower - pre_gt_dept_lower
gen du_postm = mean_gt_dept_upper - pre_gt_dept_upper
gen du_postp = post_gt_dept_upper - pre_gt_dept_upper
drop name dept event gt_* mean* post*
* keeping pre*, to be able to have relative measures in addition to absolute

* correlations between (lower vs upper), (name vs dept), and (mean vs peak):
corr nl_* nu_*
corr dl_* du_*
corr nl* dl*
corr nu* du*
corr *_postm *_postp

* converting above absolute-measurements into above/below median identifiers: 

xtile scr_nl_postm = nl_postm, nq(2)
xtile scr_nl_postp = nl_postp, nq(2)
xtile scr_nu_postm = nu_postm, nq(2)
xtile scr_nu_postp = nu_postp, nq(2)
xtile scr_dl_postm = dl_postm, nq(2)
xtile scr_dl_postp = dl_postp, nq(2)
xtile scr_du_postm = du_postm, nq(2)
xtile scr_du_postp = du_postp, nq(2)

*foreach scr in nl_postm nl_postp dl_postm dl_postp {
*	twoway (scatter `scr' date if (scr_`scr'==1)) || (scatter `scr' date if (scr_`scr'==2)), leg(off) name("scr_`scr'", replace)
*}

gen n_scr = scr_nl_postm 
gen d_scr = scr_dl_postm
gen or_scr = 1
replace or_scr = 2 if (scr_nl_postm==2) | (scr_dl_postm==2)
gen and_scr = 1
replace and_scr = (scr_nl_postm==2) & (scr_dl_postm==2)

*** BASED ON ABOVE, USE n_scr=(scr_nl_postm) and d_scr=(scr_dl_postm) ***

*** how to combine them? 

* dropping the absolute-measurements, currently only using above/below median:
*drop nl_post* nu_post* dl_post* du_post*

* correlations between binary versions of the above: 
corr scr_nl_* scr_nu_*
corr scr_dl_* scr_du_*
corr scr_nl_* scr_dl_*
corr scr_nu_* scr_du_*
corr scr_*_postm scr_*_postp

* tabulating lowers vs uppers:
tab scr_nl_postm scr_nu_postm
tab scr_nl_postp scr_nu_postp
tab scr_dl_postm scr_du_postm
tab scr_dl_postp scr_du_postp

* tabulating names vs depts: 
tab scr_nl_postm scr_dl_postm
tab scr_nl_postp scr_dl_postp
tab scr_nu_postm scr_du_postm
tab scr_nu_postp scr_du_postp

* tabulating post-means vs post-peaks: 
tab scr_nl_postm scr_nl_postp
tab scr_nu_postm scr_nu_postp
tab scr_dl_postm scr_dl_postp
tab scr*du_postm scr*du_postp

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/400_base/30_gtrend/google_trends", replace

* Dates for consideration: 
	* 01Jan2011 = 18628, 31Dec2020 = 22280

log close
