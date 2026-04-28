* 01b_deduping

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/01_prepping/01_SMCL_logs/01b_deduping", smcl replace

* manually selected states with potential-duplicates to loop over
	* this was determined by looking over the 88 SOPP locations
foreach state in ct il md nc {
	display ""
	local temp_state = upper("`state'")
	display "Deduping `state' at $S_TIME" 
	filelist, dir("2000_data/200_raw/20_SOPP_DTAs") pat("`state'*") maxdeep(1)
	gen path = dirname + "/" + filename
	gen backup_dirname = dirname + "/" + "1_pre_dedupe"
	gen backup_filename = subinstr(filename, ".dta", "_pre_dedupe.dta", .)
	gen backup_path = backup_dirname + "/" + backup_filename
	local N = _N
	local Np1 = _N+1
	forvalues i=1/`N' {
	local temp_path = path[`i']
	local temp_backup_path = backup_path[`i']
	copy `temp_path' `temp_backup_path', replace
	}
	qui levelsof path if path != "", clean local(dedupe_path)
	foreach dupe_check of local dedupe_path {
	append using `dupe_check', force
	}
	display "finished loading `state' files"
	display _N
	local N2 = _N
	la var locale "not for dupe checking"
	la var state_locale "not for dupe checking"
	la var dirname "not for dupe checking"
	la var filename "not for dupe checking"
	la var fsize "not for dupe checking"
	la var path "not for dupe checking"
	la var backup_path "not for dupe checking"
	la var backup_dirname "not for dupe checking"
	la var backup_filename "not for dupe checking"
	ds, not(varlabel "not for dupe checking")
	duplicates tag `r(varlist)' in `Np1'/`N2', generate(dupe)
	ds, not(varlabel "not for dupe checking")
	duplicates drop `r(varlist)' in `Np1'/`N2', force
	display ""	
	qui levelsof state_locale, clean local(dedupe_locales)
	display "locales for save loop: `dedupe_locales'"
	foreach locale of local dedupe_locales {
    local state_locale_lower = lower("`locale'")
	preserve
	keep if state_locale == "`locale'"
	display "`state' string variables:"
	ds, has(type string) var(32)
	display ""
	display "`state' non-string variables:"
	ds, not(type string) var(32)
	save "2000_data/200_raw/20_SOPP_DTAs/`state_locale_lower'.dta", replace
	restore
	display ""
	}
}

log close
