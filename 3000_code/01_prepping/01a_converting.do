* 01a_converting

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/01_prepping/01_SMCL_logs/01a_converting", smcl replace

* non-standard packages needed: ssc install {_gwtmean egenmore unique filelist coefplot}

* this ugly piece is used to reduce data-crunching: 
local my_sopp_vars = "state locale date subject_race subject_age subject_sex department_name county_name search_conducted officer_race officer_age officer_sex contraband_found search_basis search_vehicle search_person contraband_alcohol contraband_drugs contraband_weapons contraband_other type reason_for_search department_id type"

* pulling list of 88 SOPP CSVs, generating vector of filepaths to convert
filelist, dir("2000_data/100_original/20_SOPP_CSVs") pat("*.csv") maxdeep(1)
gen csv_path = dirname + "/" + filename
qui levelsof csv_path, local(toconvert)

foreach file of local toconvert {
	display ""
	display "$S_TIME: `file'" 
	import delimited "`file'", varnames(1) bindquote(strict) maxquotedrows(80) clear 
	display "string variables:"
	ds, has(type string) var(32)
	display ""
	display "non-string variables:"
	ds, not(type string) var(32)
	display ""
	*NOTE: IF FILES CHANGE, UPDATE THESE SUBSTR COMMAND VALUES
	gen state=upper(substr("`file'", 37, 2))
	gen locale=upper(substr("`file'", 40, .))
	replace locale=subinstr(locale,".CSV","",.)
	gen state_locale = state + "_" + locale
	order state locale state_locale
	local save1 = subinstr("`file'", "100_original/20_SOPP_CSVs", "200_raw/20_SOPP_DTAs", .)
	local save2 = subinstr("`save1'", ".csv", "", .)
	drop raw_row_number
	foreach var of local my_sopp_vars {
		capture confirm variable `var'
		if !_rc {
		}
		else {
			gen `var' = ""
		}
	}
	save "`save2'", replace
	display ""
}

log close
