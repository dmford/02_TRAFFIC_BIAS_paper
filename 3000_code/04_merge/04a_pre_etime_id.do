* 04a_pre_etime_id.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/04_merge/04_SMCL_logs/04a_pre_etime_id", smcl replace

use "2000_data/300_cleaning/10_FE/FE_clean.dta", replace

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

* (NOTE: Now keeping STN + STN_stories, for alternate sig_event definition)
keep fe_id st_dept shooting_date fe_subject_race fe_highest_force fe_armed STN STN_stories

* on multi-death dates, how many deaths are observed:
duplicates tag st_dept shooting_date, gen(temp_num_deaths_any)
bysort st_dept shooting_date: egen num_deaths_any = count(temp_num_deaths_any)
drop temp_*

keep if inlist(fe_highest_force, 1, 5, 7)
keep if (shooting_date>=18628) & (shooting_date<=22280)
keep if fe_subject_race==2
keep if fe_armed==0
drop fe_highest_force fe_subject_race fe_armed

*on multi-focal-death dates, how many deaths are observed: 
duplicates tag st_dept shooting_date, gen(temp_num_deaths_focal)
bysort st_dept shooting_date: egen num_deaths_focal = count(temp_num_deaths_focal)
drop temp_*

* renaming so that it matches with gtrend data: 
gen edate = shooting_date
format edate %td

* Dropping Unusable Events
*drop if inlist(fe_id, 10634, 10881, 26126, 26621, 14028, 24794, 28135, 27252)
* may not have been armed, but the other robbers were
drop if fe_id == 10634
* murder-suicide hostage situation
drop if fe_id == 10881 
* hostage execution
drop if fe_id == 26126
* shot-and-killed by bf, prompting officer to kill the bf 
drop if fe_id == 26621
* evidently a gun WAS found on the scene
drop if fe_id == 14028
* shot by someone else (not LEO)
drop if fe_id == 24794
* shot by own son, not police
drop if fe_id == 28135
* hostage execution 
drop if fe_id == 27252

* I was having an issue with treated observations being limited to +/-135 days from an event
	* here, I expand each unique fe_id obs (into 2*14*30, twice my largest bin size) 
	* I think use tag to identify the first obs for each one, and "pin" the rest to that date
			* (this should increase my "event sample" by 840x)
expand (2*14*30)
egen temp_tag = tag(fe_id)
gen date = (edate-(14*30)) if (temp_tag==1)
gsort fe_id -temp_tag
by fe_id: replace date = date[_n-1]+1 if (date==.)
format date %td
drop temp*

* Merging FE data with Google Trends data: 
merge 1:m fe_id date using "2000_data/400_base/30_gtrend/google_trends", nogen
* (merged all from Google Trends, only un-merged are ones I know will not match to SOPP)

********************************************************************************

bysort fe_id: egen temp1 = max(STN)
bysort fe_id: egen temp2 = max(STN_stories)
replace STN = temp1
replace STN_stories = temp2
drop temp*

drop local_name_blank local_dept_blank

* 8/23/24: FE + SOPP fe_id matches
gen match_tag = 1 if inlist(fe_id, 9779, 9788, 9820, 9929, 10092, 10191, 10229, 10634, 10787, 10797, 10827, 10881, 11121, 11164, 11223, 11237, 11264, 11432, 11455, 11604, 11680, 11688, 12008, 12109, 12208, 12577, 12605, 12737, 12752, 12853, 13044, 13115, 13130, 13160, 13232, 13248, 13311, 13340, 13379, 13406, 13480, 13489, 13539, 13556, 13715, 13951, 14028, 14200, 14203, 14224, 14243, 14353, 14384, 14442, 14446, 14449, 14481, 14483, 14563, 14584, 14615, 14622, 14754, 14827, 14895, 14918, 14934, 15045, 15090, 15177, 15296, 15524, 15767, 15779, 15792, 15805, 15806, 15829, 15934, 16009, 16069, 16332, 16398, 16467, 16486, 17046, 17065, 17221, 17241, 17270, 17396, 17544, 17676, 17698, 17767, 17798, 17904, 17988, 18137, 18210, 18248, 18496, 18500, 19288, 21825, 21826, 21828, 21831, 21834, 21884, 22047, 22072, 22771, 23267, 23273, 23315, 23411, 23468, 23535, 23538, 23687, 23689, 23697, 23882, 24278, 24794, 24951, 24990, 25030, 25084, 25379, 25411, 25618, 25705, 25818, 25891, 26080, 26126, 26289, 26489, 26621, 27015, 27250, 27252, 27456, 27472, 27945, 28135, 28184, 28992, 29348, 29387)

* using above match-data to expand this GTrend scrutiny data (which is fe_id invariant) to the full series of event-obs 
foreach scr in scr_nl_postm scr_nl_postp scr_nu_postm scr_nu_postp scr_dl_postm scr_dl_postp scr_du_postm scr_du_postp {
	bysort fe_id: egen temp_max = max(`scr') if match_tag==1
	replace `scr' = temp_max if `scr'==.
	drop temp_*
}

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/300_cleaning/10_FE/FEgtrend_pre_id.dta", replace

log close
