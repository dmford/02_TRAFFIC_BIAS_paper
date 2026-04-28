* 01c_LEMAS_prep.do	

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/01_prepping/01_SMCL_logs/01c_LEMAS_prep", smcl replace

***** DROPPING MOSTLY-BLANK VARIABLES *****

filelist, dir("2000_data/100_original/40_LEMAS_orig") pat("*.dta") maxdeep(1)
gen orig_path = dirname + "/" + filename
qui levelsof orig_path, local(SparseDrop)

local j = 1
local J = _N

foreach orig_file of local SparseDrop {
	display ""
	display "#`j'/`J' | `orig_file'"
	local ++j
	use "`orig_file'", replace
	local K = c(k)
	foreach threshold in 100 {
		foreach var of varlist _all {
			egen a = count(`var')
			if (a < `threshold') display "dropping `var': `: var label `var''"
			if (a < `threshold') drop `var'
			drop a
		}
		display "Variables remaining for threshold=`threshold': "c(k) "/`K'"
	}
	local save = subinstr("`orig_file'", "100_original\40_LEMAS_orig", "200_raw\40_LEMAS_raw", .)
	save "`save'", replace
}



***** RENAMING LEMAS VARIABLES *****
* instead of {V1, V2, ...} --> {year, agency_name, ...}

*** 1987 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_1987.dta", replace

* 1987: govt_id_number census_check_digit agency_id_short service_call_total_inc_cit service_call_total_inc_off service_call_total_inc_alarm service_call_total_inc_walk_in service_call_total_inc_other sidearm_ammo baton handcuffs equipment_other_specify rev_caliber semi_caliber fiscal_start_full fiscal_end_full res_req_juris spu_drug_screen educ_sgt_req 

gen year = 1987
order year
* invariant icpsr vars
drop V1 V2 V3
*rename V1 icpsr_study_number
*rename V2 icpsr_version_number
*rename V3 icpsr_part_number
rename V4 icpsr_seq_id
rename V5 form_type
gen form_long = (form_type=="044")
rename V6 govt_id_number
rename V7 census_check_digit
rename V8 agency_id_short
rename V9 agency_name
* county_fips should be a string
rename V10 temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
drop temp_county_fips

*** attempting to construct agency_id_unique
*** 2+1+3+3+2+5 = state code + govt id type + county code + city code + sector id + agency id short
*** here, govt_id_number is state+govt_id_type+county_code+city_code
tostring govt_id_number, gen(temp_govt_id_place) format("%09.0f")
gen temp_sector_place = "0"
tostring agency_id_short, gen(temp_agency_id_short)
gen agency_id_unique = temp_govt_id_place + temp_sector_place + temp_agency_id_short 
drop temp_*

rename V11 msa_cmsa
rename V12 population
rename V13 stratum
rename V14 weight

*** 1987 | SECTION I: OPERATIONS ***
rename V15 duties_traffic
rename V16 duties_accident_investigation
rename V17 duties_patrol
rename V18 duties_emergency_medical
rename V19 duties_property_crime
rename V20 duties_death_investigation
rename V21 duties_narcotics_vice
rename V22 duties_robbery_rape
rename V23 duties_other_crime
rename V24 duties_fingerprinting
rename V25 duties_lab_testing
rename V26 duties_ballistics
rename V27 duties_dispatch
rename V28 duties_court_security
rename V29 duties_jail_ops
rename V30 duties_civil_serving
rename V31 duties_civil_defense
rename V32 duties_fire
rename V33 duties_animal_control
rename V34 duties_academy_training
rename V35 duties_other_leo_functions
rename V36 agency_type
rename V37 orig_sworn_personnel

* shift-timing variables only supposed to be populated "if your department performs patrol functions"
gen performs_routine_patrols = .
replace performs_routine_patrols = 1 if (V47 | V48 | V49 | V50 | V51 | V54 | V55 | V56 | V57 | V58 | V61 | V62 | V63 | V64 | V65 | V68 | V69 | V70 | V71 | V72 | V75 | V76 | V77 | V78 | V79 | V82 | V83 | V84 | V85 | V86 | V89 | V90 | V91 | V92 | V93 | V96 | V97 | V98 | V99 | V100 | V103 | V104 | V105 | V106 | V107 | V108 | V109 | V110)!=0

* dropping 1987's cumbersome shift time info: 
drop V52 V53 V59 V60 V66 V67 V73 V74 V80 V81 V87 V88 V94 V95 V101 V102

* dropping now-useless shift count info: 
drop V47 V48 V49 V50 V51 V54 V55 V56 V57 V58 V61 V62 V63 V64 V65 V68 V69 V70 V71 V72 V75 V76 V77 V78 V79 V82 V83 V84 V85 V86 V89 V90 V91 V92 V93 V96 V97 V98 V99 V100 V103 V104 V105 V106 V107 V108 V109 V110

rename V111 service_call_total
rename V112 service_call_disp
rename V113 service_call_no_disp
rename V114 service_call_total_inc_cit
rename V115 service_call_total_inc_off
rename V116 service_call_total_inc_alarm
rename V117 service_call_total_inc_walk_in
rename V118 service_call_total_inc_other
rename V119 operational_911_detail
gen operational_911 = .
replace operational_911 = (operational_911_detail == 1 | operational_911_detail == 2)
rename V120 has_holding_cells
rename V121 number_holding_cells
rename V122 max_holding_time
rename V123 lockup_cap
rename V124 lockup_adult_cap
rename V125 admissions_tot
rename V126 admissions_adult
rename V127 admissions_juvenile

*** 1987 | SECTION II: EQUIPMENT ***
rename V128 uniforms
rename V129 sidearm
rename V130 sidearm_ammo
rename V131 bodyarmor
rename V132 baton
rename V133 handcuffs
rename V134 equipment_other_specify

* re-framing supplied/cash allowance variables 
gen uniforms_supplied = (uniforms==1)
gen uniforms_cash_allowance = (uniforms==2)
gen uniforms_none = (uniforms==3)
replace uniforms_supplied = . if uniforms==0
replace uniforms_cash_allowance = . if uniforms==0
replace uniforms_none = . if uniforms==0
drop uniforms

gen sidearm_supplied = (sidearm==1)
gen sidearm_cash_allowance = (sidearm==2)
gen sidearm_none = (sidearm==3)
replace sidearm_supplied = . if sidearm==0
replace sidearm_cash_allowance = . if sidearm==0
replace sidearm_none = . if sidearm==0
drop sidearm

gen bodyarmor_supplied = (bodyarmor==1)
gen bodyarmor_cash_allowance = (bodyarmor==2)
gen bodyarmor_none = (bodyarmor==3)
replace bodyarmor_supplied = . if bodyarmor==0
replace bodyarmor_cash_allowance = . if bodyarmor==0
replace bodyarmor_none = . if bodyarmor==0
drop bodyarmor

la var sidearm_ammo "1-Agency Supplies, 2-Cash Allowance, 3-Not Supplied"
la var baton "1-Agency Supplies, 2-Cash Allowance, 3-Not Supplied"
la var handcuffs "1-Agency Supplies, 2-Cash Allowance, 3-Not Supplied"
la var equipment_other_specify "1-Agency Supplies, 2-Cash Allowance, 3-Not Supplied"

rename V135 rev_supplied
rename V136 rev_caliber
rename V137 semi_supplied
rename V138 semi_caliber
replace sidearm_supplied=1 if (rev_supplied==1 | semi_supplied==1)

rename V139 vehicles_marked_cars
rename V140 vehicles_unmarked_cars
rename V141 vehicles_4_wheel_misc
rename V142 vehicles_3_wheel
rename V143 vehicles_2_wheel
rename V144 vehicles_aircraft
rename V145 vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename V146 vehicles_boats
rename V147 vehicles_other
rename V148 temp_marked_take_home
gen marked_take_home = .
replace marked_take_home = (temp_marked_take_home==1)
rename V149 marked_off_duty_use
rename V150 comp_mainframe
rename V151 comp_mini
rename V152 comp_personal
rename V153 comp_fc_dispatch
rename V154 comp_fc_investigations
rename V155 comp_fc_analysis
rename V156 comp_fc_scheduling
rename V157 comp_fc_budgeting
rename V158 comp_fc_records
rename V159 comp_fc_fleet_mgmt
rename V160 comp_fc_other
rename V161 comp_files_arrests
rename V162 comp_files_calls
rename V163 comp_files_crim_hist
rename V164 comp_files_lic_reg
rename V165 comp_files_payroll
rename V166 comp_files_stolen_prop
rename V167 comp_files_citations
rename V168 comp_files_warrants
rename V169 comp_files_ucr
rename V170 comp_files_other

*** 1987 | SECTION III: PERSONNEL ***
rename V171 ft_avg_hours
rename V172 pt_pay_freq
rename V173 pt_pay_hours
* dropping fine-detail sworn/nonsworn m/f staff vars, cumbersome
drop V182 V183 V184 V185 V186 V187 V188 V189 V190 V191 V192 V193 V194 V195 V196 V197 V198 V199 V200 V201 V202 V203 V204 V205
rename V174 auth_sworn_ft
rename V175 auth_sworn_pt
rename V176 auth_nonsworn_ft
rename V177 auth_nonsworn_pt
rename V178 staff_sworn_ft
rename V179 staff_sworn_pt
rename V180 staff_nonsworn_ft
rename V181 staff_nonsworn_pt
* dropping most demographic vars, cumbersome
drop V218 V219 V220 V221 V222 V223 V224 V225 V226 V227 V228 V229 V230 V231 V232 V233 V234 V235 V236 V237
rename V206 sworn_males
rename V207 sworn_females
rename V208 nonsworn_males
rename V209 nonsworn_females
rename V210 sworn_white_males
rename V211 sworn_white_females
rename V212 nonsworn_white_males
rename V213 nonsworn_white_females
rename V214 sworn_black_males
rename V215 sworn_black_females
rename V216 nonsworn_black_males
rename V217 nonsworn_black_females

*** 1987 | SECTION IV: SALARIES ***
rename V238 fiscal_start_full
rename V239 fiscal_end_full
rename V240 salary_chief_min
rename V241 salary_chief_max
rename V242 salary_sgt_min
rename V243 salary_sgt_max
rename V244 salary_srpatrol_min
rename V245 salary_srpatrol_max
rename V246 salary_entry_min
rename V247 salary_entry_max
rename V248 ot_hours_total
rename V249 ot_hours_pay

*** 1987 | SECTION V: EXPENDITURES ***
rename V250 gross_salary
rename V251 gross_salary_benefit_pct
rename V252 op_exp_other
rename V253 capex_equipment
* only appears in this year
drop V254 V255
*rename V254 capex_construction
*rename V255 capex_other

*** 1987 | SECTION VI: POLICIES/PROGRAMS ***
rename V256 res_req
rename V257 res_req_juris
rename V258 res_req_miles
* shift rotation info only appears in 1987
drop V259 V260 V261 V262 V263 V264 V265 V266 V267 V268
*rename V259 shift_rot_y
*rename V260 shift_rot_y_wk
*rename V261 shift_rot_y_mo
*rename V262 shift_rot_y_qtr
*rename V263 shift_rot_y_other
*rename V264 shift_rot_n
*rename V265 shift_rot_n_off_pick
*rename V266 shift_rot_n_dept_asgmt
*rename V267 shift_rot_n_seniority
*rename V268 shift_rot_n_other
rename V269 temp_pay_hazard
rename V270 temp_pay_shift_diff
rename V271 temp_pay_ed_incentive
gen pay_hazard = (temp_pay_hazard==1)
gen pay_shift_diff = (temp_pay_shift_diff==1)
gen pay_ed_incentive = (temp_pay_ed_incentive==1)
replace pay_hazard = . if temp_pay_hazard == 0
replace pay_shift_diff = . if temp_pay_shift_diff == 0
replace pay_ed_incentive = . if temp_pay_shift_diff == 0

rename V272 educ_hs_rec
rename V273 educ_hs_sgt
rename V274 educ_1yr_coll_rec
rename V275 educ_1yr_coll_sgt
rename V276 educ_2yr_coll_rec
rename V277 educ_2yr_coll_sgt
rename V278 educ_bach_rec
rename V279 educ_bach_sgt
rename V280 educ_other_rec
rename V281 educ_other_sgt
* replacing clunky recruit education variables with 1990/1993 equivalencies
gen educ_recruit_req = .
replace educ_recruit_req = 1 if educ_bach_rec==1
replace educ_recruit_req = 2 if educ_2yr_coll_rec==1
replace educ_recruit_req = 3 if educ_1yr_coll_rec==1
replace educ_recruit_req = 4 if educ_hs_rec==1
replace educ_recruit_req = 5 if educ_other_rec
replace educ_recruit_req = 6 if educ_bach_rec==0 & educ_2yr_coll_rec==0 & educ_1yr_coll_rec==0 & educ_hs_rec==0 & educ_other_rec==0
drop educ_bach_rec educ_2yr_coll_rec educ_1yr_coll_rec educ_hs_rec educ_other_rec

gen educ_sgt_req = .
replace educ_sgt_req = 1 if educ_bach_sgt==1
replace educ_sgt_req = 2 if educ_2yr_coll_sgt==1
replace educ_sgt_req = 3 if educ_1yr_coll_sgt==1
replace educ_sgt_req = 4 if educ_hs_sgt==1
replace educ_sgt_req = 5 if educ_other_sgt
replace educ_sgt_req = 6 if educ_bach_sgt==0 & educ_2yr_coll_sgt==0 & educ_1yr_coll_sgt==0 & educ_hs_sgt==0 & educ_other_sgt==0
drop educ_bach_sgt educ_2yr_coll_sgt educ_1yr_coll_sgt educ_hs_sgt educ_other_sgt

rename V282 new_off_train
rename V283 new_off_train_class_hrs
rename V284 new_off_train_field_hrs
rename V285 new_off_train_cost
rename V286 allows_coll_bargain
rename V287 memb_org
rename V288 memb_org_nat_nonpolice
rename V289 memb_org_nat_police
rename V290 memb_org_local_police_union
rename V291 memb_org_local_unaff_union
rename V292 memb_org_local_police_assn
rename V293 memb_org_reg_police_assn
rename V294 memb_org_other
rename V295 spu_victim_assist
rename V296 spu_nbhd_crime_prev
rename V297 spu_career_crim
rename V298 spu_prosec_rel
rename V299 spu_dom_abuse
rename V300 spu_child_abuse
rename V301 spu_missing_child
rename V302 spu_drug_screen
rename V303 spu_drug_educ
rename V304 spu_drunk_drivers

rename V305 direc_deadly_force
rename V306 direc_mentally_ill
rename V307 direc_homeless
rename V308 direc_dom_abuse
rename V309 direc_juveniles
rename V310 direc_pursuits
rename V311 direc_private_sec
rename V312 direc_off_duty_empl
rename V313 direc_strip_search
rename V314 direc_code_of_conduct

label define no0yes1 0 "No" 1 "Yes"

foreach var of varlist direc_* {
	tab `var'
	replace `var' = . if `var'==0
	replace `var' = 0 if `var'==2
	label values `var' no0yes1
	tab `var'
}

rename V315 litigations_by_empl
rename V316 litigations_by_nonempl

drop icpsr_seq_id 

order county_fips 

* making agency_type match across time, keeping old variation 
rename agency_type agency_type_old
gen agency_type = .
replace agency_type = 2 if agency_type_old == 1
replace agency_type = 1 if agency_type_old == 2 | agency_type_old == 3 | agency_type_old == 6
replace agency_type = 3 if agency_type_old == 5

drop temp_*

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1987_renamed.dta", replace



*** 1990 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_1990.dta", replace

* 1990: auth_chem_agent auth_impact_dev auth_restr_dev auth_other auth_none seized_other seized_none res_req_detail_miles sheriff_law_enforcement_pct sheriff_jail_pct sheriff_court_pct sheriff_other_pct drug_unit_cost_flag weight_edited_base 

gen year=1990 
order year
* invariant icpsr vars
drop V1 V2 V3 
* sequential count
rename V4 icpsr_seq_id

*** 1990 | SECTION I: DESCRIPTION INFORMATION ***
rename V5 form_type 
rename V6 temp_agency_id_num

destring temp_agency_id_num, gen(temp_agency_id_unique)
gen agency_id_unique=string(temp_agency_id_unique, "%017.0f")
drop temp_*

rename V7 agency_name
rename V8 city
rename V9 county
rename V10 agency_type_orig
rename V11 orig_sworn_personnel

* county_fips should be a string
rename V12 temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
drop temp_county_fips

rename V13 msa_cmsa
rename V14 population
rename V15 form_code
rename V16 weight_base
rename V17 agency_type
rename V18 sheriff_law_enforcement
rename V19 sheriff_jail
rename V20 sheriff_court
rename V21 sheriff_other

*** 1990 | SECTION II: OPERATIONS ***
rename V22 duties_traffic
rename V23 duties_accident_investigation
rename V24 duties_patrol
rename V25 duties_emergency_medical
rename V26 duties_property_crime
rename V27 duties_death_investigation
rename V28 duties_narcotics_vice
rename V29 duties_robbery_rape
rename V30 duties_other_crime
rename V31 duties_fingerprinting
rename V32 duties_ballistics
rename V33 duties_lab_testing
rename V34 duties_search_rescue
rename V35 duties_dispatch
rename V36 duties_court_security
rename V37 duties_jail_ops
rename V38 duties_civil_serving
rename V39 duties_civil_defense
rename V40 duties_fire
rename V41 duties_animal_control
rename V42 duties_academy_training
rename V43 duties_other_leo_functions
rename V44 performs_routine_patrols
rename V45 service_call_total
rename V46 service_call_total_cit
rename V47 service_call_total_alarm
rename V48 service_call_total_off
rename V49 service_call_total_other
rename V50 service_call_resp
rename V51 service_call_disp
rename V52 service_call_no_disp
rename V53 operational_911_detail
gen operational_911 = 0 if operational_911_detail == 3
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2
rename V54 has_holding_cells
rename V55 number_holding_cells
rename V56 max_holding_time
rename V57 lockup_cap
rename V58 admissions_tot
rename V59 admissions_adult
rename V60 admissions_juvenile

*** 1990 | SECTION III: EQUIPMENT ***
rename V61 temp_sidearm_supplied
gen sidearm_supplied = (temp_sidearm_supplied ==1)
drop temp_*

rename V62 supplies_rev_357
rename V63 supplies_rev_38
rename V64 supplies_rev_45
rename V65 supplies_rev_9m
rename V66 supplies_rev_10m
rename V67 supplies_rev_other
gen rev_supplied = 0
replace rev_supplied = 1 if (supplies_rev_357==1 | supplies_rev_38==1 | supplies_rev_45==1 | supplies_rev_9m==1 | supplies_rev_10m==1 | supplies_rev_other==1)

rename V68 supplies_semi_357
rename V69 supplies_semi_38
rename V70 supplies_semi_45 
rename V71 supplies_semi_9m
rename V72 supplies_semi_10m
rename V73 supplies_semi_other
gen semi_supplied = 0
replace semi_supplied = 1 if (supplies_semi_357==1 | supplies_semi_38==1 | supplies_semi_45==1 |supplies_semi_9m==1 | supplies_semi_10m==1 | supplies_semi_other==1) 

rename V74 supplies_other_357
rename V75 supplies_other_38
rename V76 supplies_other_45
rename V77 supplies_other_9m
rename V78 supplies_other_10m
rename V79 supplies_other_other

rename V80 sidearm_auth

rename V81 auth_rev_357
rename V82 auth_rev_38
rename V83 auth_rev_45
rename V84 auth_rev_9m
rename V85 auth_rev_10m
rename V86 auth_rev_other
gen rev_auth = 0
replace rev_auth = 1 if (auth_rev_357==1 | auth_rev_38==1 | auth_rev_45==1 | auth_rev_9m==1 | auth_rev_10m==1 | auth_rev_other==1)

rename V87 auth_semi_357
rename V88 auth_semi_38
rename V89 auth_semi_45
rename V90 auth_semi_9m
rename V91 auth_semi_10m
rename V92 auth_semi_other
gen semi_auth = 0
replace semi_auth = 1 if (auth_semi_357==1 | auth_semi_38==1 | auth_semi_45==1 | auth_semi_9m==1 | auth_semi_10m==1 | auth_semi_other==1)

rename V93 auth_other_357
rename V94 auth_other_38
rename V95 auth_other_45
rename V96 auth_other_9m
rename V97 auth_other_10m
rename V98 auth_other_other

rename V99 bodyarmor
rename V100 bodyarmor_po_supplied
rename V101 bodyarmor_specops_supplied
rename V102 bodyarmor_po_allowance
rename V103 bodyarmor_specops_allowance
rename V104 bodyarmor_required
rename V105 bodyarmor_po_req
rename V106 bodyarmor_specops_req
rename V107 auth_elec_dev
rename V108 auth_chem_agent
rename V109 auth_impact_dev
rename V110 auth_restr_dev
rename V111 auth_other
rename V112 auth_none
rename V113 vehicles_marked_cars
rename V114 vehicles_unmarked_cars
rename V115 vehicles_buses
rename V116 vehicles_armored_car
rename V117 vehicles_4_wheel_misc
rename V118 vehicles_3_wheel
rename V119 vehicles_2_wheel
rename V120 vehicles_aircraft
rename V121 vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename V122 vehicles_boats
rename V123 vehicles_bicycles
rename V124 vehicles_other
rename V125 marked_take_home
tab marked_take_home
replace marked_take_home = 0 if marked_take_home == 2
rename V126 marked_off_duty_use
rename V127 afis_ownership
rename V128 afis_access
rename V129 comp_mainframe
rename V130 comp_mini
rename V131 comp_personal
rename V132 comp_laptop
rename V133 comp_car_mounted_term
rename V134 comp_handheld_term
rename V135 comp_other
rename V136 comp_fc_dispatch
rename V137 comp_fc_investigations
rename V138 comp_fc_analysis
rename V139 comp_fc_scheduling
rename V140 comp_fc_budgeting
rename V141 comp_fc_records
rename V142 comp_fc_fleet_mgmt
rename V143 comp_fc_jail_mgmt
rename V144 comp_fc_other
rename V145 comp_files_arrests
rename V146 comp_files_calls
rename V147 comp_files_crim_hist
rename V148 comp_files_lic_reg
rename V149 comp_files_payroll
rename V150 comp_files_stolen_prop
rename V151 comp_files_citations
rename V152 comp_files_warrants
rename V153 comp_files_summons
rename V154 comp_files_ucr
rename V155 comp_files_inventory
rename V156 comp_files_evidence
rename V157 comp_files_other

*** 1990 | SECTION IV: PERSONNEL ***
* dropping fine-detail sworn/nonsworn m/f staff vars, cumbersome
drop V166 V167 V168 V169 V170 V171 V172 V173 V174 V175 V176 V177 V178 V179 V180 V181 V182 V183 V184 V185 V186 V187 V188 V189
rename V158 auth_sworn_ft
rename V159 auth_sworn_pt
rename V160 auth_nonsworn_ft
rename V161 auth_nonsworn_pt
rename V162 staff_sworn_ft
rename V163 staff_sworn_pt
rename V164 staff_nonsworn_ft
rename V165 staff_nonsworn_pt
* dropping most demographic vars, cumbersome
drop V202 V203 V204 V205 V206 V207 V208 V209 V210 V211 V212 V213 V214 V215 V216 V217 V218 V219 V220 V221
rename V190 sworn_males
rename V191 sworn_females
rename V192 nonsworn_males
rename V193 nonsworn_females
rename V194 sworn_white_males
rename V195 sworn_white_females
rename V196 nonsworn_white_males
rename V197 nonsworn_white_females
rename V198 sworn_black_males
rename V199 sworn_black_females
rename V200 nonsworn_black_males
rename V201 nonsworn_black_females

*** 1990 | SECTION V: SALARIES ***
rename V222 fiscal_start_month
rename V223 fiscal_start_day
rename V224 fiscal_start_year
rename V225 fiscal_end_month
rename V226 fiscal_end_day
rename V227 fiscal_end_year
rename V228 salary_chief_min
rename V229 salary_chief_max
rename V230 salary_sgt_min
rename V231 salary_sgt_max
rename V232 salary_entry_min
rename V233 salary_entry_max
rename V234 ot_hours_total
rename V235 ot_hours_pay

*** 1990 | SECTION VI: EXPENDITURES ***
rename V236 gross_salary_benefit_pct
rename V237 gross_salary
rename V238 op_exp_other
rename V239 capex_equipment

*** 1990 | SECTION VII: POLICIES/PROGRAMS ***
rename V240 res_req
rename V241 res_req_detail
rename V242 pay_hazard
rename V243 pay_shift_diff
rename V244 pay_ed_incentive
rename V245 pay_merit

foreach var of varlist pay_* {
	replace `var'=0 if `var'==2
	label values `var' no0yes1 
}

rename V246 educ_recruit_req
rename V248 new_off_train
rename V249 new_off_train_class_hrs
rename V250 new_off_train_field_hrs
rename V251 allows_coll_bargain
rename V252 memb_org
rename V253 memb_org_nat_nonpolice
rename V254 memb_org_nat_police
rename V255 memb_org_local_police_union
rename V256 memb_org_local_unaff_union
rename V257 memb_org_local_police_assn
rename V258 memb_org_reg_police_assn
rename V259 memb_org_other
rename V260 spu_victim_assist
rename V261 spu_nbhd_crime_prev
rename V262 spu_career_crim
rename V263 spu_prosec_rel
rename V264 spu_dom_abuse
rename V265 spu_child_abuse
rename V266 spu_missing_child
rename V267 spu_juvenile_delinq
rename V268 spu_gangs
rename V269 spu_drug_educ
rename V270 spu_drunk_drivers
rename V271 spu_hate_crimes
rename V272 direc_deadly_force
rename V273 direc_mentally_ill
rename V274 direc_homeless
rename V275 direc_dom_abuse
rename V276 direc_juveniles
rename V277 direc_pursuits
rename V278 direc_private_sec
rename V279 direc_off_duty_empl
rename V280 direc_strip_search
rename V281 direc_code_of_conduct
rename V282 direc_use_of_funds
rename V283 direc_empl_counseling
rename V284 direc_citizen_compl

la define no0yes1 0 "No" 1 "Yes"
foreach var of varlist direc_* {
	replace `var' = 0 if `var'==2
	la values `var' no0yes1
}

*** 1990 | SECTION VIII: DRUG-RELATED POLICIES ***
rename V285 drug_unit
rename V286 drug_unit_officers
rename V287 drug_unit_cost
rename V288 multi_force_drug
rename V289 multi_force_drug_officers
rename V290 drug_asset_forf
rename V291 seized_amphetamines
rename V292 seized_barbiturates
rename V293 seized_crack
rename V294 seized_cocaine
rename V295 seized_hashish
rename V296 seized_heroin
rename V297 seized_lsd
rename V298 seized_marijuana
rename V299 seized_methamphetamines
rename V300 seized_methaqualone
rename V301 seized_morphine
rename V302 seized_opium
rename V303 seized_pcp
rename V304 seized_synthetics
rename V305 seized_other
rename V306 seized_none
rename V307 test_arrestees
rename V308 dept_drug_test_op
rename V309 empl_drug_testing
* V310-V339 vars detail drug testing policies
drop V310 V311 V312 V313 V314 V315 V316 V317 V318 V319 V320 V321 V322 V323 V324 V325 V326 V327 V328 V329 V330 V331 V332 V333 V334 V335 V336 V337 V338 V339
rename V340 specific_drug_sanctions
* V341-V350 vars detail drug testing sanctions
drop V341 V342 V343 V344 V345 V346 V347 V348 V349 V350

*** 1990 | OTHER ***
* V351+ are recodes, flags, and "other, specify"
rename V351 res_req_detail_miles
rename V352 sheriff_law_enforcement_pct
rename V353 sheriff_jail_pct
rename V354 sheriff_court_pct
rename V355 sheriff_other_pct
rename V356 service_call_total_flag
rename V357 service_call_total_cit_flag
rename V358 service_call_total_alarm_flag
rename V359 service_call_total_off_flag
rename V360 service_call_total_other_flag
rename V361 service_call_resp_flag
rename V362 service_call_disp_flag
rename V363 service_call_no_disp_flag
rename V364 lockup_cap_flag
rename V365 admissions_tot_flag
rename V366 admissions_adult_flag
rename V367 admissions_juvenile_flag
* dropping flags for unused vars
drop V368 V369 V370 V371 V372 V373 V374 V375 V376 V377 V378 V379
rename V380 sworn_males_flag
rename V381 sworn_females_flag
rename V382 nonsworn_males_flag
rename V383 nonsworn_females_flag
rename V384 sworn_white_males_flag
rename V385 sworn_white_females_flag
rename V386 sworn_black_males_flag
rename V387 sworn_black_females_flag
* dropping flags for unused vars
drop V388 V389 V390 V391 V392 V393 V394 V395 V396 V397 V398 V399 V400 V401 V402 V403 V404 V405 V406 V407 V408 V409 V410 V411
rename V412 salary_chief_min_flag
rename V413 salary_chief_max_flag
rename V414 salary_sgt_min_flag
rename V415 salary_sgt_max_flag
rename V416 salary_entry_min_flag
rename V417 salary_entry_max_flag
rename V418 ot_hours_total_flag
rename V419 ot_hours_pay_flag
rename V420 gross_salary_benefit_pct_flag
rename V421 gross_salary_flag
rename V422 op_exp_other_flag
rename V423 capex_equipment_flag
rename V425 new_off_train_class_hrs_flag
rename V426 new_off_train_field_hrs_flag
rename V427 drug_unit_officers_flag
rename V428 drug_unit_cost_flag
rename V429 multi_force_drug_off_flag
rename V430 agency_type_recode
rename V431 weight_and_imputation
rename V432 var_estimation
rename V433 population_categorical
rename V434 respondent_num_sworn_off
rename V435 weight_edited_base
rename V436 agency_nonresp_factor
rename V437 weight_final
* V424 invariant
drop V424 

* restructuring problem vars
gen temp_drug_unit = (drug_unit==1)
replace drug_unit = temp_drug_unit

drop temp_*

drop icpsr_seq_id
order county_fips 

rename agency_type agency_type_old
gen agency_type=.
replace agency_type = 1 if agency_type_recode == 2 | agency_type_recode == 6
replace agency_type = 2 if agency_type_recode == 1
replace agency_type = 3 if agency_type_recode == 5

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1990_renamed.dta", replace



*** 1993 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_1993.dta", replace

* 1993: govt_id_state govt_id_county govt_id_check_digit govt_id_sector govt_id_unique avg_sworn_officers duties_calls_dispatching duties_violent_rape duties_violent_robbery duties_violent_assault duties_property_crime_burglary duties_property_crime_larceny duties_property_crime_mv service_call_total_cit_oth service_call_telephone_resp service_call_oth_resp service_call_oth_entry supplies_rev_other_entry supplies_semi_other_entry supplies_other_other_entry supplies_other_specify auth_rev_other_entry auth_other_other_entry auth_other_specify auth_impact_other1 auth_impact_other2 auth_impact_other3 auth_elec_dev_other1 auth_elec_dev_other2 auth_elec_dev_other3 auth_chem_agent_tranq_dart auth_chem_agent_other1 auth_chem_agent_other2 auth_chem_agent_other3 auth_carotid_hold auth_other2 auth_other3 comp_other_entry comp_fc_research comp_fc_other1 comp_fc_other2 comp_fc_other3 comp_files_other1 comp_files_other2 comp_files_other3 educ_recruit_other_entry memb_org_other_entry spu_other_entry cit_rev_acc_other_entry exc_force_invest_other_entry disp_act_rec_other_entry exc_force_final_resp_other seized_any drug_test_op_other_entry agency_name_sample avg_sworn_officers_revised service_call_total_cit_oth_flag service_call_total_other_flag_e service_call_telephone_resp_flag service_call_oth_flag vehicles_buses_flag vehicles_armored_car_flag vehicles_atv_flag vehicles_3_wheel_flag vehicles_other_flag temp_agency_id_unique 

gen year=1993
order year

* invariant ICPSR vars
drop V1 V2 V3 
* sequential count 
rename V4 icpsr_seq_id
rename V5 form_type
rename V6 govt_id_state
rename V7 govt_id_type
rename V8 govt_id_county
rename V9 govt_id_city
rename V10 govt_id_check_digit
rename V11 govt_id_sector
rename V12 govt_id_unique
rename V13 agency_name
rename V14 city
rename V15 county
rename V17 avg_sworn_officers

* county_fips should be a string
rename V18 temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
drop temp_county_fips

rename V19 msa_cmsa
rename V20 population
rename V21 form_code
rename V22 weight_base

*** constructing agency_id_unique
*** 2+1+3+3+2+5 = state code + govt id type + county code + city code + sector id + agency id short
*** here, figured out how to string with leading zeroes, unknown invariant 2 too
gen temp_state_code = string(govt_id_state, "%02.0f")
gen temp_govt_id_type = string(govt_id_type, "%1.0f")
gen temp_county_code = string(govt_id_county, "%003.0f")
gen temp_city_code = string(govt_id_city, "%003.0f")
gen temp_sector_id = string(2, "%02.0f")
gen temp_unk_id = string(2,"%1.0f")
gen temp_agency_id_short = string(govt_id_unique, "%05.0f")
gen agency_id_unique = temp_state_code + temp_govt_id_type + temp_county_code + temp_city_code + temp_sector_id + temp_unk_id + temp_agency_id_short
drop temp_*

*** 1993 | SECTION I: DESCRIPTIVE INFORMATION ***
rename V16 agency_type_orig

*** 1993 | SECTION II: OPERATIONS ***
rename V23 duties_traffic_enforcement
rename V24 duties_traffic_control
rename V25 duties_accident_investigation
rename V26 duties_patrol
rename V27 duties_emergency_medical
rename V28 duties_vice
rename V29 duties_fingerprinting
rename V30 duties_ballistics
rename V31 duties_lab_testing
rename V32 duties_search_rescue
rename V33 duties_calls_receiving
rename V34 duties_calls_dispatching
rename V35 duties_court_security
rename V36 duties_jail_ops
rename V37 duties_civil_serving
rename V38 duties_civil_defense
rename V39 duties_fire
rename V40 duties_animal_control
rename V41 duties_academy_training
rename V42 duties_environmental_crime
rename V43 duties_violent_homicide
rename V44 duties_violent_rape
rename V45 duties_violent_robbery
rename V46 duties_violent_assault
rename V47 duties_property_crime_burglary
rename V48 duties_property_crime_larceny
rename V49 duties_property_crime_mv
rename V50 duties_property_crime_arson
rename V51 performs_routine_patrols

foreach var of varlist duties_* {
	replace `var' = 0 if `var'==2
}

replace duties_court_security = 0 if duties_court_security==2
replace duties_jail_op = 0 if duties_jail_op==2
replace duties_civil_serving = 0 if duties_civil_serving==2

* dropping cumbersome shift info, and flags
drop V52 V53 V54 V55 V56 V57 V58 V59 V60 V61 V62 V63 V64 V65 V66 V67 V68 V69 V70 V71 V72 V73 V74 V75 V76 V77 V78 V79 V80 V81 V82 V83 V84 V85 V86 V87 V88 V89 V90 V91 V92 V93 V94 V95 V96 V97 V98 V99 V100 V101 V102 V103 V104
drop V527 V528 V529 V530 V531 V532 V533 V534 V535 V536 V537 V538 V539 V540 V541 V542 V543 V544 V545 V546 V547 V548 V549 V550 V551 V552 V553 V554 V555 V556 V557 V558 V559 V560 V561 V562 V563 V564 V565 V566 V567 V568 V569 V570 V571 V572 V573 V574 V575 V576 V577 V578
rename V105 operational_911_detail
gen operational_911 = .
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2
replace operational_911 = 0 if operational_911_detail==3
rename V106 service_call_total
rename V107 service_call_total_cit_911
rename V108 service_call_total_cit_oth
rename V579 service_call_total_flag
rename V580 service_call_total_cit_911_flag
rename V581 service_call_total_cit_oth_flag
gen service_call_total_cit = service_call_total_cit_911 + service_call_total_cit_oth
gen service_call_total_cit_flag = 0
replace service_call_total_cit_flag = 2 if (service_call_total_cit_911_flag!=0 | service_call_total_cit_oth_flag!=0)

rename V109 service_call_total_alarm
rename V582 service_call_total_alarm_flag
rename V110 service_call_total_off
rename V583 service_call_total_off_flag
rename V111 service_call_total_other
rename V112 service_call_total_other_flag
rename V584 service_call_total_other_flag_e
rename V113 service_call_resp
rename V585 service_call_resp_flag
rename V114 service_call_disp_911
rename V586 service_call_disp_911_flag
rename V115 service_call_disp_oth
rename V587 service_call_disp_oth_flag
gen service_call_disp = service_call_disp_911 + service_call_disp_oth
gen service_call_disp_flag = 0 
replace service_call_disp_flag = 2 if (service_call_disp_911_flag!=0 | service_call_disp_oth_flag!=0)

rename V116 service_call_telephone_resp
rename V588 service_call_telephone_resp_flag
rename V117 service_call_oth_resp
rename V118 service_call_oth_entry
rename V589 service_call_oth_flag
gen service_call_no_disp = service_call_telephone_resp + service_call_oth_resp
gen service_call_no_disp_flag = 0 
replace service_call_no_disp_flag = 2 if (service_call_telephone_resp_flag!=0 | service_call_oth_flag!=0)

rename V119 dogs
rename V590 dogs_flag
rename V120 horses
rename V591 horses_flag
rename V121 has_holding_cells
rename V122 number_holding_cells
rename V123 lockup_cap
rename V593 lockup_cap_flag
rename V124 admissions_tot
rename V594 admissions_tot_flag
rename V125 admissions_adult
rename V595 admissions_adult_flag
rename V126 admissions_juvenile
rename V596 admissions_juvenile_flag
rename V127 max_holding_time_adult
rename V597 max_holding_time_adult_flag
rename V128 max_holding_time_juvenile

*** 1993 | SECTION III: EQUIPMENT ***
rename V129 temp_sidearm_supplied
gen sidearm_supplied = (temp_sidearm_supplied==1)
drop temp_*

rename V130 supplies_rev_357
rename V131 supplies_rev_38
rename V132 supplies_rev_45
rename V133 supplies_rev_9m
rename V134 supplies_rev_10m
rename V135 supplies_rev_other
rename V136 supplies_rev_other_entry
gen rev_supplied = 0
replace rev_supplied = 1 if (supplies_rev_357==1 | supplies_rev_38==1 | supplies_rev_45==1 | supplies_rev_9m==1 | supplies_rev_10m==1 | supplies_rev_other==1)

rename V137 supplies_semi_357
rename V138 supplies_semi_38
rename V139 supplies_semi_45
rename V140 supplies_semi_9m
rename V141 supplies_semi_10m
rename V142 supplies_semi_other
rename V143 supplies_semi_other_entry
gen semi_supplied = 0
replace semi_supplied = 1 if (supplies_semi_357==1 | supplies_semi_38==1 | supplies_semi_45==1 |supplies_semi_9m==1 | supplies_semi_10m==1 | supplies_semi_other==1) 

rename V144 supplies_other_357
rename V145 supplies_other_38
rename V146 supplies_other_45
rename V147 supplies_other_9m
rename V148 supplies_other_10m
rename V149 supplies_other_other
rename V150 supplies_other_other_entry
rename V151 supplies_other_specify

rename V152 sidearm_auth

rename V153 auth_rev_357
rename V154 auth_rev_38
rename V155 auth_rev_45
rename V156 auth_rev_9m
rename V157 auth_rev_10m
rename V158 auth_rev_other
rename V159 auth_rev_other_entry
gen rev_auth = 0
replace rev_auth = 1 if (auth_rev_357==1 | auth_rev_38==1 | auth_rev_45==1 | auth_rev_9m==1 | auth_rev_10m==1 | auth_rev_other==1)

rename V160 auth_semi_357
rename V161 auth_semi_38
rename V162 auth_semi_45
rename V163 auth_semi_9m
rename V164 auth_semi_10m
rename V165 auth_semi_other
rename V166 auth_semi_other_entry
gen semi_auth = 0
replace semi_auth = 1 if (auth_semi_357==1 | auth_semi_38==1 | auth_semi_45==1 | auth_semi_9m==1 | auth_semi_10m==1 | auth_semi_other==1)

rename V167 auth_other_357
rename V168 auth_other_38
rename V169 auth_other_45
rename V170 auth_other_9m
rename V171 auth_other_10m
rename V172 auth_other_other
rename V173 auth_other_other_entry
rename V174 auth_other_specify

rename V175 temp_sidearm_cash_allowance
gen sidearm_cash_allowance = (temp_sidearm_cash_allowance==1)
drop temp_*

rename V176 bodyarmor
rename V177 bodyarmor_po_supplied_all
rename V178 bodyarmor_po_supplied_some
rename V179 bodyarmor_po_supplied_none
rename V180 bodyarmor_specops_supplied_all
rename V181 bodyarmor_specops_supplied_some
rename V182 bodyarmor_specops_supplied_none
rename V183 bodyarmor_po_allowance_all
rename V184 bodyarmor_po_allowance_some
rename V185 bodyarmor_po_allowance_none
rename V186 bodyarmor_specops_allowance_all
rename V187 bodyarmor_specops_allowance_som
rename V188 bodyarmor_specops_allowance_non
rename V189 bodyarmor_required
rename V190 bodyarmor_po_req_all
rename V191 bodyarmor_po_req_some
rename V192 bodyarmor_po_req_none
rename V193 bodyarmor_specops_req_all
rename V194 bodyarmor_specops_req_some
rename V195 bodyarmor_specops_req_none
rename V196 auth_impact_baton
rename V197 auth_impact_baton_pr24
rename V198 auth_impact_baton_cllpsbl

gen auth_baton=0
replace auth_baton=1 if (auth_impact_baton==1 | auth_impact_baton_pr24==1 | auth_impact_baton_cllpsbl==1)

rename V199 auth_impact_soft_proj
rename V200 auth_impact_rubber_bullet
rename V201 auth_impact_other1
rename V202 auth_impact_other2
rename V203 auth_impact_other3

rename V204 auth_elec_dev_stun_gun
rename V205 auth_elec_dev_other1
rename V206 auth_elec_dev_other2
rename V207 auth_elec_dev_other3

rename V208 auth_chem_agent_tear_personal
rename V209 auth_chem_agent_tear_tactical
gen auth_chem_agent_tear = 0
replace auth_chem_agent_tear = 1 if (auth_chem_agent_tear_personal==1 | auth_chem_agent_tear_tactical==1)

rename V210 auth_chem_agent_pepper
rename V211 auth_chem_agent_tranq_dart
rename V212 auth_chem_agent_other1
rename V213 auth_chem_agent_other2
rename V214 auth_chem_agent_other3

rename V215 auth_choke_hold
rename V216 auth_carotid_hold
gen auth_neck_hold = 0
replace auth_neck_hold = 1 if (auth_choke_hold==1 | auth_carotid_hold==1)
drop auth_choke_hold auth_carotid_hold

rename V217 auth_capture_net

* three-pole trip only appears in this survey year, dropping
drop V218 

rename V219 auth_flashbang
rename V220 auth_other1
rename V221 auth_other2
rename V222 auth_other3
rename V223 vehicles_marked_cars
rename V224 vehicles_unmarked_cars
rename V225 vehicles_buses
rename V226 vehicles_armored_car
rename V227 vehicles_atv
rename V228 vehicles_4_wheel_misc
rename V229 vehicles_3_wheel
rename V230 vehicles_2_wheel
rename V231 vehicles_aircraft
rename V232 vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename V233 vehicles_boats
rename V234 vehicles_bicycles
rename V235 vehicles_other
rename V236 vehicles_other_entry
rename V599 vehicles_marked_cars_flag
rename V600 vehicles_unmarked_cars_flag
rename V601 vehicles_buses_flag
rename V602 vehicles_armored_car_flag
rename V603 vehicles_atv_flag
rename V604 vehicles_4_wheel_misc_flag
rename V605 vehicles_3_wheel_flag
rename V606 vehicles_2_wheel_flag
rename V607 vehicles_aircraft_flag
rename V608 vehicles_helicopters_flag
rename V609 vehicles_boats_flag
rename V610 vehicles_bicycles_flag
rename V611 vehicles_other_flag
rename V237 marked_take_home
replace marked_take_home=0 if marked_take_home==2
rename V238 marked_off_duty_use
rename V239 afis_ownership
rename V240 afis_access
rename V241 comp_mainframe
rename V242 comp_mini
rename V243 comp_personal
rename V244 comp_laptop
rename V245 comp_car_mounted_term
rename V246 comp_handheld_term
rename V247 comp_other
rename V248 comp_other_entry
rename V249 comp_fc_dispatch
rename V250 comp_fc_investigations
rename V251 comp_fc_analysis
rename V252 comp_fc_scheduling
rename V253 comp_fc_budgeting
rename V254 comp_fc_records
rename V255 comp_fc_fleet_mgmt
rename V256 comp_fc_jail_mgmt
rename V257 comp_fc_research
rename V258 comp_fc_other1

foreach var of varlist comp_fc_* {
	replace `var' = 0 if `var'==2
}

rename V261 comp_files_arrests
rename V262 comp_files_calls
rename V263 comp_files_crim_hist
rename V264 comp_files_veh_reg
rename V265 comp_files_lic_reg
rename V266 comp_files_payroll
rename V267 comp_files_personnel
rename V268 comp_files_stolen_veh
rename V269 comp_files_stolen_prop
rename V270 comp_files_citations
rename V271 comp_files_accidents
rename V272 comp_files_warrants
rename V273 comp_files_summons
rename V274 comp_files_ucr_summary
rename V275 comp_files_ucr_incident
rename V276 comp_files_inventory
rename V277 comp_files_evidence
rename V278 comp_files_prints
rename V279 comp_files_other1
rename V280 comp_files_other2
rename V281 comp_files_other3
replace comp_files_arrests = 0 if comp_files_arrests==2
replace comp_files_calls  = 0 if comp_files_calls==2
replace comp_files_crim_hist = 0 if comp_files_crim_hist==2
replace comp_files_stolen_prop = 0 if comp_files_stolen_prop==2
replace comp_files_citations = 0 if comp_files_citations==2
replace comp_files_warrants = 0 if comp_files_warrants==2

*** 1993 | SECTION IV: PERSONNEL ***
* dropping fine-detail sworn/nonsworn m/f staff vars, cumbersome, +flags
drop V290 V291 V292 V293 V294 V295 V296 V297 V298 V299 V300 V301 V302 V303 V304 V305 V306 V307 V308 V309 V310 V311 V312 V313 V314
drop V620 V621 V622 V623 V624 V625 V626 V627 V628 V629 V630 V631 V632 V633 V634 V635 V636 V637 V638 V639 V640 V641 V642 V643
rename V282 auth_sworn_ft
rename V283 auth_sworn_pt 
rename V284 auth_nonsworn_ft 
rename V285 auth_nonsworn_pt
rename V286 staff_sworn_ft
rename V287 staff_sworn_pt
rename V288 staff_nonsworn_ft
rename V289 staff_nonsworn_pt
rename V315 ft_resp_officers
rename V612 auth_sworn_ft_flag
rename V613 auth_sworn_pt_flag
rename V614 auth_nonsworn_ft_flag
rename V615 auth_nonsworn_pt_flag
rename V616 staff_sworn_ft_flag
rename V617 staff_sworn_pt_flag
rename V618 staff_nonsworn_ft_flag
rename V619 staff_nonsworn_pt_flag
rename V644 ft_resp_officers_flag
* dropping most demographic vars, cumbersome, +flags
drop V328 V329 V330 V331 V332 V333 V334 V335 V336 V337 V338 V339 V340 V341 V342 V343 V344 V345 V346 V347
drop V657 V658 V659 V660 V661 V662 V663 V664 V665 V666 V667 V668 V669 V670 V671 V672 V673 V674 V675 V676
rename V316 sworn_males
rename V317 sworn_females
rename V318 nonsworn_males
rename V319 nonsworn_females
rename V320 sworn_white_males
rename V321 sworn_white_females
rename V322 nonsworn_white_males
rename V323 nonsworn_white_females
rename V324 sworn_black_males
rename V325 sworn_black_females
rename V326 nonsworn_black_males
rename V327 nonsworn_black_females
rename V645 sworn_males_flag
rename V646 sworn_females_flag
rename V647 nonsworn_males_flag
rename V648 nonsworn_females_flag
rename V649 sworn_white_males_flag
rename V650 sworn_white_females_flag
rename V651 nonsworn_white_males_flag
rename V652 nonsworn_white_females_flag
rename V653 sworn_black_males_flag
rename V654 sworn_black_females_flag
rename V655 nonsworn_black_males_flag
rename V656 nonsworn_black_females_flag

*** 1993 | SECTION V: SALARIES ***
rename V348 salary_chief_min
rename V349 salary_chief_max
rename V350 salary_sgt_min
rename V351 salary_sgt_max
rename V352 salary_entry_min
rename V353 salary_entry_max
rename V354 ot_hours_total
rename V355 ot_hours_pay
rename V356 ot_comp_hours_earned
rename V677 salary_chief_min_flag
rename V678 salary_chief_max_flag
rename V679 salary_sgt_min_flag
rename V680 salary_sgt_max_flag
rename V681 salary_entry_min_flag
rename V682 salary_entry_max_flag
rename V683 ot_hours_total_flag
rename V684 ot_hours_pay_flag
rename V685 ot_comp_hours_earned_flag

*** 1993 | SECTION VI: EXPENDITURES ***
rename V357 gross_salary
rename V358 op_exp_other
rename V359 capex_equipment
rename V686 gross_salary_flag
rename V687 op_exp_other_flag
rename V688 capex_equipment_flag

*** 1993 | SECTION VII: POLICIES/PROGRAMS ***
rename V360 res_req
rename V361 res_req_juris_extra
rename V362 res_req_detail_miles
rename V363 pay_hazard
rename V364 pay_shift_diff
rename V365 pay_ed_incentive
rename V366 pay_merit

foreach var of varlist pay_* {
	replace `var'=0 if `var'==2
}

rename V367 educ_recruit_req
rename V368 educ_recruit_req_hours
rename V369 educ_recruit_other_entry
rename V370 new_off_train
rename V371 new_off_train_class_hrs
rename V372 new_off_train_field_hrs
rename V689 new_off_train_class_hrs_flag
rename V690 new_off_train_field_hrs_flag
rename V373 allows_coll_bargain_sworn
rename V374 allows_coll_bargain_nonsworn
rename V375 memb_org
rename V376 memb_org_nat_nonpolice
rename V377 memb_org_nat_police
rename V378 memb_org_local_police_union
rename V379 memb_org_local_unaff_union
rename V380 memb_org_local_police_assn
rename V381 memb_org_state_police_assn
rename V382 memb_org_reg_police_assn
rename V383 memb_org_other
rename V384 memb_org_other_entry
rename V385 spu_victim_assist
rename V386 spu_nbhd_crime_prev
rename V387 spu_career_crim
rename V388 spu_prosec_rel
rename V389 spu_dom_abuse
rename V390 spu_child_abuse
rename V391 spu_missing_child
rename V392 spu_juvenile_delinq
rename V393 spu_gangs
rename V394 spu_drug_educ
rename V395 spu_drunk_drivers
rename V396 spu_hate_crimes
rename V397 spu_env_crime
rename V398 spu_other
rename V399 spu_other_entry
rename V400 direc_deadly_force
rename V401 direc_mentally_ill
rename V402 direc_homeless
rename V403 direc_dom_abuse
rename V404 direc_juveniles
rename V405 direc_pursuits
rename V406 direc_private_sec
rename V407 direc_off_duty_empl
rename V408 direc_strip_search
rename V409 direc_code_of_conduct
rename V410 direc_use_of_funds
rename V411 direc_empl_counseling
rename V412 direc_citizen_compl

la define no0yes1 0 "No" 1 "Yes"
foreach var of varlist direc_* {
	replace `var'=0 if `var'==2
	la values `var' no0yes1
}

rename V413 cit_review_board
rename V414 cit_rev_acc_chief
rename V415 cit_rev_acc_govt_exec
rename V416 cit_rev_acc_govt_body
rename V417 cit_rev_acc_other
rename V418 cit_rev_acc_other_entry
rename V419 exc_force_invest_chief
rename V420 exc_force_invest_int_aff
rename V421 exc_force_invest_sworn
rename V422 exc_force_invest_nonsworn
rename V423 exc_force_invest_civil_board
rename V424 exc_force_invest_off_prof_stand
rename V425 exc_force_invest_dist_attorney
rename V426 exc_force_invest_other
rename V427 exc_force_invest_other_entry
rename V428 rev_exc_force_outside_chain
rename V429 disp_act_rec_chief
rename V430 disp_act_rec_govt_exec
rename V431 disp_act_rec_superior
rename V432 disp_act_rec_other_sup
rename V433 disp_act_rec_int_aff
rename V434 disp_act_rec_civil_board
rename V435 disp_act_rec_commiss_board
rename V436 disp_act_rec_dist_attorney
rename V437 disp_act_rec_other
rename V438 disp_act_rec_other_entry
rename V439 exc_force_final_resp
rename V440 exc_force_final_resp_other
rename V441 exc_force_appeal_citizen
rename V442 exc_force_appeal_officers

*** 1993 | SECTION VIII: DRUG-RELATED POLICIES ***
rename V443 drug_enforcement_resp
rename V444 drug_enforcement_resp_other
rename V445 drug_unit
rename V446 drug_unit_officers
rename V691 drug_unit_officers_flag
rename V447 multi_force_drug
rename V448 multi_force_drug_officers
rename V692 multi_force_drug_off_flag
rename V449 drug_asset_forf
rename V450 drug_asset_forf_tot_value
rename V451 drug_asset_forf_money_value
rename V452 drug_asset_forf_goods_value
rename V693 drug_asset_forf_tot_value_flag
rename V694 drug_asset_forf_money_value_flag
rename V695 drug_asset_forf_goods_value_flag
rename V453 seized_any
rename V454 seized_amphetamines
rename V455 seized_barbiturates
rename V456 seized_crack
rename V457 seized_cocaine
rename V458 seized_hashish
rename V459 seized_heroin
rename V460 seized_lsd
rename V461 seized_marijuana
rename V462 seized_methamphetamines
rename V463 seized_methaqualone
rename V464 seized_morphine
rename V465 seized_opium
rename V466 seized_pcp
rename V467 seized_synthetics
rename V468 seized_no_info
rename V469 test_arrestees
rename V470 dept_drug_test_op
rename V471 drug_test_op_jail
rename V472 drug_test_op_court
rename V473 drug_test_op_other_lea
rename V474 drug_test_op_pretrial_agency
rename V475 drug_test_op_private
rename V476 drug_test_op_other
rename V477 drug_test_op_other_entry
rename V478 empl_drug_testing
rename V509 specific_drug_sanctions
* V479-V508 vars detail drug testing policies
drop V479 V480 V481 V482 V483 V484 V485 V486 V487 V488 V489 V490 V491 V492 V493 V494 V495 V496 V497 V498 V499 V500 V501 V502 V503 V504 V505 V506 V507 V508
* V510-V522 vars detail drug testing sanctions
drop V510 V511 V512 V513 V514 V515 V516 V517 V518 V519 V520 V521 V522

*** 1993 | OTHER *** 
rename V523 ori_9
replace ori_9 = "" if ori_9 == "999999999"
rename V524 agency_name_sample
rename V525 avg_sworn_officers_revised
rename V526 agency_type_recode
drop V592
rename V696 weight_and_imputation
rename V697 var_estimation
rename V698 respondent_num_sworn_off
rename V699 agency_nonresp_factor
rename V700 weight_final
rename V598 number_holding_cells_flag

* dropping for merge
* temporary fix, may correct later 
drop service_call_total_other_flag res_req_detail_miles

order county_fips 

* in 1997, Dade county changed its name to Miami-Dade
replace county_fips = "12086" if county_fips == "12025"  

* similarly, appears to be a county-entry error for Willow Park PD in TX
replace county="PARKER" if ori_9=="TX1840500"
replace county_fips="48367" if ori_9=="TX1840500"

* making agency_type match across time, keeping old variation 
gen agency_type=.
replace agency_type = 1 if agency_type_recode == 2 | agency_type_recode == 6
replace agency_type = 2 if agency_type_recode == 1
replace agency_type = 3 if agency_type_recode == 5
replace agency_type = 1 if county_fips == "04013" & agency_name == "TEMPE POLICE DEPT"

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1993_renamed.dta", replace



*** 1997 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_1997.dta", replace

* 1997: service_call_no_disp_alarm multi_force_drug_off_ft_flag multi_force_drug_off_pt_flag lockup_adult_facilities_flag lockup_juvenile_facilities_flag service_call_total_cit_other_f service_call_disp_alarm_flag service_call_no_disp_alarm_flag service_call_no_disp_other_flag po_training_freq_flag salary_1yr_min_flag salary_1yr_max_flag spu_hate_crimes_sworn_flag spu_hate_crimes_nonsworn_flag spu_child_abuse_sworn_flag spu_child_abuse_nonsworn_flag spu_nbhd_crime_prev_sworn_flag spu_nbhd_crime_prev_nonsworn_f spu_community_policing_sworn_f spu_community_policing_nonswornf spu_crime_analysis_sworn_flag spu_crime_analysis_nonsworn_flag spu_dom_abuse_sworn_flag spu_dom_abuse_nonsworn_flag spu_drug_educ_sworn_flag spu_drug_educ_nonsworn_flag spu_drunk_drivers_sworn_flag spu_drunk_drivers_nonsworn_flag spu_env_crime_sworn_flag spu_env_crime_nonsworn_flag spu_gangs_sworn_flag spu_gangs_nonsworn_flag spu_juvenile_delinq_sworn_flag spu_juvenile_delinq_nonsworn_f spu_missing_child_sworn_flag spu_missing_child_nonsworn_flag spu_prosec_rel_sworn_flag spu_prosec_rel_nonsworn_flag spu_career_crim_sworn_flag spu_career_crim_nonsworn_flag spu_research_planning_sworn_flag spu_research_planning_nonsworn_f spu_victim_assist_sworn_flag spu_victim_assist_nonsworn_flag spu_youth_outreach_sworn_flag spu_youth_outreach_nonsworn_flag comm_pol_officers_flag weight_2 weight_3 sample_type 

gen year=1997
order year

* invariant vars
drop V1 V2 V3 V9
* arbitrary sequencial identifier
rename V4 icpsr_seq_id
rename V5 temp_agency_id_unique
gen agency_id_unique = string(temp_agency_id_unique, "%016.0f")
drop temp_*
rename V6 state_code
rename V7 govt_id_type
rename V8 govt_id_city
rename V10 agency_name
rename V11 city

* county_fips should be a string
rename V12 temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
drop temp_county_fips

rename V13 msa_cmsa
rename V14 population
rename V15 county
rename V16 agency_type
rename V17 weight_base
rename V18 form_code

*** 1997 | SECTION I: OPERATIONS ***
rename V19 num_precinct_stations
rename V20 num_fixed_nbhd_substations
rename V21 num_mob_nbhd_substations
rename V22 num_other
rename FLAG19 num_precinct_stations_flag
rename FLAG20 num_fixed_nbhd_substations_flag
rename FLAG21 num_mob_nbhd_substations_flag
rename FLAG22 num_other_flag
rename V23 num_other_entry
rename V24 duties_traffic_enforcement
rename V25 duties_traffic_control
rename V26 duties_accident_investigation
rename V27 duties_dispatch
rename V28 duties_emergency_medical
rename V29 duties_vice
rename V30 duties_fingerprinting
rename V31 duties_ballistics
rename V32 duties_lab_testing
rename V33 duties_underwater_recovery
rename V34 duties_bomb_disposal
rename V35 duties_search_rescue
rename V36 duties_school_crossing
rename V37 duties_tactical_ops
rename V38 duties_parking
rename V39 duties_executing_warrants
rename V40 duties_court_security
rename V41 duties_jail_ops
rename V42 duties_civil_serving
rename V43 duties_civil_defense
rename V44 duties_fire
rename V45 duties_animal_control
rename V46 duties_service_call_response
rename V47 duties_violent_homicide
rename V48 duties_violent_other
rename V49 duties_property_crime_arson
rename V50 duties_property_crime_other
rename V51 duties_environmental_crime

rename V52 drug_enforcement_resp
rename V53 drug_enforcement_resp_other
rename V54 drug_unit_officers_ft
rename V55 drug_unit_officers_pt
rename V56 multi_force_drug_off_ft
rename V57 multi_force_drug_off_pt
rename V58 test_arrestees
rename V59 lockup_adult_facilities
rename V60 lockup_juvenile_facilities
rename V61 lockup_adult_cap
rename V62 lockup_juvenile_cap
rename V63 max_holding_time_adult
rename V64 max_holding_time_juvenile
rename FLAG54 drug_unit_officers_ft_flag
rename FLAG55 drug_unit_officers_pt_flag
rename FLAG56 multi_force_drug_off_ft_flag
rename FLAG57 multi_force_drug_off_pt_flag
rename FLAG59 lockup_adult_facilities_flag
rename FLAG60 lockup_juvenile_facilities_flag
rename FLAG61 lockup_adult_cap_flag
rename FLAG62 lockup_juvenile_cap_flag
rename FLAG63 max_holding_time_adult_flag
rename FLAG64 max_holding_time_juvenile_flag
rename V65 patrol_auto_routine
rename V66 patrol_auto_special
rename V67 patrol_auto_none
rename V68 patrol_motorcycle_routine
rename V69 patrol_motorcycle_special
rename V70 patrol_motorcycle_none
rename V71 patrol_foot_routine
rename V72 patrol_foot_special
rename V73 patrol_foot_none
rename V74 patrol_horse_routine
rename V75 patrol_horse_special
rename V76 patrol_horse_none
rename V77 patrol_bicycle_routine
rename V78 patrol_bicycle_special
rename V79 patrol_bicycle_none
rename V80 patrol_marine_routine
rename V81 patrol_marine_special
rename V82 patrol_marine_none
* dropping cumbersome shift info 
drop V83 V84 V85 V86 V87 V88 V89 V90 V91 V92 V93 V94 V95 V96 V97 V98 V99 V100 V101 V102 V103 V104 V105 V106 V107 V108 V109 V532 V533 V534
drop FLAG83 FLAG84 FLAG85 FLAG86 FLAG87 FLAG88 FLAG89 FLAG90 FLAG91 FLAG92 FLAG93 FLAG94 FLAG95 FLAG96 FLAG97 FLAG98 FLAG99 FLAG100 FLAG101 FLAG102 FLAG103 FLAG104 FLAG105 FLAG106 FLAG107 FLAG108
rename V110 operational_911_detail
gen operational_911 = 0 if operational_911_detail ==3
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2
rename V111 three_digit_nonemer_num
rename V112 phone_based_mass_notifications
rename V113 fax_based_mass_notifications
* total calls/requests for service received
rename V114 service_call_total
rename V115 service_call_total_cit_911
rename V116 service_call_total_cit_other
gen service_call_total_cit = service_call_total_cit_911 + service_call_total_cit_other
rename V117 service_call_total_alarm
rename V118 service_call_total_other
rename FLAG114 service_call_total_flag
rename FLAG115 service_call_total_cit_911_flag
rename FLAG116 service_call_total_cit_other_f
gen service_call_total_cit_flag = 0
replace service_call_total_cit_flag = 2 if (service_call_total_cit_911_flag!=0 | service_call_total_cit_other_f!=0)
rename FLAG117 service_call_total_alarm_flag
rename FLAG118 service_call_total_other_flag
* calls/requests with officer(s) dispatched
rename V119 service_call_disp
rename V120 service_call_disp_911
rename V121 service_call_disp_nonemer
rename V122 service_call_disp_alarm
rename V123 service_call_disp_oth
rename FLAG119 service_call_disp_flag
rename FLAG120 service_call_disp_911_flag
rename FLAG121 service_call_disp_nonemer_flag
rename FLAG122 service_call_disp_alarm_flag
rename FLAG123 service_call_disp_oth_flag
* calls/requests with no officer dispatched
rename V124 service_call_no_disp
rename V125 service_call_no_disp_911
rename V126 service_call_no_disp_nonemer
rename V127 service_call_no_disp_alarm
rename V128 service_call_no_disp_other
gen service_call_resp = service_call_disp + service_call_no_disp 
* flags
rename FLAG124 service_call_no_disp_flag
rename FLAG125 service_call_no_disp_911_flag
rename FLAG126 service_call_no_disp_nonemer_f
rename FLAG127 service_call_no_disp_alarm_flag
rename FLAG128 service_call_no_disp_other_flag
gen service_call_resp_flag = 0
replace service_call_resp_flag = 2 if (service_call_disp_flag!=0 | service_call_no_disp!=0)

*** 1997 | SECTION II: EQUIPMENT ***
rename V129 temp_sidearm_supplied
gen sidearm_supplied = (temp_sidearm_supplied==1)
drop temp_*

rename V130 supplies_rev_357
rename V131 supplies_rev_38
rename V132 supplies_rev_40
rename V133 supplies_rev_45
rename V134 supplies_rev_9m
rename V135 supplies_rev_10m
gen rev_supplied = 0
replace rev_supplied = 1 if (supplies_rev_357==1 | supplies_rev_38==1 | supplies_rev_40==1 | supplies_rev_45==1 | supplies_rev_9m==1 | supplies_rev_10m==1)

rename V137 supplies_semi_357
rename V138 supplies_semi_38
rename V139 supplies_semi_40
rename V140 supplies_semi_45
rename V141 supplies_semi_9m
rename V142 supplies_semi_10m
gen semi_supplied = 0
replace semi_supplied = 1 if (supplies_semi_357==1 | supplies_semi_38==1 | supplies_semi_40==1 | supplies_semi_45==1 |supplies_semi_9m==1 |supplies_semi_10m==1)
rename V144 sidearm_auth

rename V145 auth_rev_357
rename V146 auth_rev_38
rename V147 auth_rev_40
rename V148 auth_rev_45
rename V149 auth_rev_9m
rename V150 auth_rev_10m
gen rev_auth = 0
replace rev_auth = 1 if (auth_rev_357==1 | auth_rev_38==1 |auth_rev_40==1 |auth_rev_45==1 |auth_rev_9m==1 |auth_rev_10m==1)

rename V152 auth_semi_357
rename V153 auth_semi_38
rename V154 auth_semi_40
rename V155 auth_semi_45
rename V156 auth_semi_9m
rename V157 auth_semi_10m
gen semi_auth = 0
replace semi_auth = 1 if (auth_semi_357==1 | auth_semi_38==1 |auth_semi_40==1 |auth_semi_45==1 |auth_semi_9m==1 |auth_semi_10m==1)

rename V159 temp_sidearm_cash_allowance
gen sidearm_cash_allowance = (temp_sidearm_cash_allowance==1)
drop temp_*

rename V160 bodyarmor_po_supplied
rename V161 bodyarmor_po_allowance
rename V162 bodyarmor_po_req
rename V163 auth_impact_baton
rename V164 auth_impact_baton_pr24
rename V165 auth_impact_baton_cllpsbl

gen auth_baton = 0
replace auth_baton = 1 if (auth_impact_baton==1 | auth_impact_baton_pr24==1 | auth_impact_baton_cllpsbl==1)

rename V166 auth_impact_soft_proj
rename V167 auth_impact_rubber_bullet
rename V168 auth_impact_other
rename V169 auth_chem_agent_pepper_personal
rename V170 auth_chem_agent_pepper_tactical
rename V171 auth_chem_agent_tear_personal
rename V172 auth_chem_agent_tear_tactical
rename V173 auth_chem_agent_cs_gas_personal
rename V174 auth_chem_agent_cs_gas_tactical
rename V175 auth_chem_agent_other_personal
rename V176 auth_chem_agent_other_tactical
rename V177 auth_elec_dev_stun_gun
rename V178 auth_elec_dev_taser
rename V179 auth_choke_carotid_hold
rename V180 auth_capture_net
rename V181 auth_flashbang
rename V182 auth_other1
rename V183 auth_other_entry
* if count is zero, naturally use=0, dropping use vars
drop V184 V186 V188 V190 V192 FLAG188
rename V185 vehicles_marked_cars
rename V187 vehicles_unmarked_cars
rename V189 vehicles_aircraft
rename V191 vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename V193 vehicles_boats
rename FLAG185 vehicles_marked_cars_flag
rename FLAG187 vehicles_unmarked_cars_flag
rename FLAG191 vehicles_helicopters_flag
rename FLAG193 vehicles_boats_flag
rename V194 vehicles_armored_car
rename V195 vehicles_atv
rename V196 vehicles_mobile_command_post
rename V197 vehicles_buses
rename V198 vehicles_2_wheel
rename V199 vehicles_3_wheel
rename V200 vehicles_vans
rename V201 vehicles_other
rename V202 vehicles_other_entry
rename V203 marked_take_home
replace marked_take_home = 0 if marked_take_home==2
rename V204 marked_off_duty_use
rename V205 dogs
rename V206 horses
rename FLAG205 dogs_flag
rename FLAG206 horses_flag
rename V207 cameras_patrol_car
rename V208 cameras_mobile_surv
rename V209 cameras_fixed_surv
rename V210 cameras_other
rename V211 dig_imaging_prints
rename V212 dig_imaging_mugshots
rename V213 dig_imaging_composites
rename V214 dig_imaging_other
rename V215 night_vis_image_intensifier
rename V216 night_vis_infrared
rename V217 night_vis_laser_rangefinder
rename V218 night_vis_other
rename V219 veh_stop_roadspikes
rename V220 veh_stop_engine_disrupt
rename V221 veh_stop_lojack
rename V222 veh_stop_other

*** 1997 | SECTION III: COMPUTERS AND INFORMATION SYSTEMS ***
rename V223 comp_mainframe
rename V224 comp_mini
rename V225 comp_personal
rename V226 comp_laptop
rename V227 comp_car_mounted_term
rename V228 comp_car_mounted_computer
rename V229 comp_handheld_term
rename V230 comp_other
rename V232 comp_fc_analysis
rename V233 comp_fc_crime_mapping
rename V234 comp_fc_investigations
rename V235 comp_fc_dispatch
rename V236 comp_fc_fleet_mgmt
rename V237 comp_fc_in_field_comms
rename V238 comp_fc_in_field_reports
rename V239 comp_fc_internet_access
rename V240 comp_fc_records
rename V241 comp_fc_resource_alloc
rename V242 comp_files_alarms
rename V243 comp_files_arrests
rename V244 comp_files_calls
rename V245 comp_files_crim_hist
rename V246 comp_files_inventory
rename V247 comp_files_lic_reg
rename V248 comp_files_evidence
rename V249 comp_files_field_interviews
rename V250 comp_files_incident_report
rename V251 comp_files_linked_analysis
rename V252 comp_files_payroll
rename V253 comp_files_personnel
rename V254 comp_files_stolen_veh
rename V255 comp_files_stolen_prop
rename V256 comp_files_summons
rename V257 comp_files_accidents
rename V258 comp_files_citations
rename V259 comp_files_ucr_incident
rename V260 comp_files_ucr_summary
rename V261 comp_files_veh_reg
rename V262 comp_files_warrants
rename V263 auto_finger_id_system
rename V264 afis_remote
rename V265 geocode_service_call
rename V266 geocode_arrests
rename V267 geocode_incidents
rename V268 field_access_veh_records
rename V269 field_access_driving_records
rename V270 field_access_crim_hist
rename V271 field_access_linked_files
rename V272 field_access_service_call
rename V273 data_transfer_criminal_inc
rename V274 data_transfer_traffic_inc
rename V275 has_website

*** 1997 | SECTION IV: PERSONNEL ***
* dropping cumbersome personnel vars
drop V284 V285 V286 V287 V288 V289 V290 V291 V292 V293 V294 V295 V296
drop FLAG284 FLAG285 FLAG286 FLAG287 FLAG288 FLAG289 FLAG290 FLAG291 FLAG292 FLAG293 FLAG294 FLAG295
rename V276 auth_sworn_ft
rename V277 auth_sworn_pt
rename V278 auth_nonsworn_ft
rename V279 auth_nonsworn_pt
rename V280 staff_sworn_ft
rename V281 staff_sworn_pt
rename V282 staff_nonsworn_ft
rename V283 staff_nonsworn_pt
rename V297 ft_resp_officers
rename V298 performs_community_policing
rename V299 school_resource_officer
rename FLAG276 auth_sworn_ft_flag
rename FLAG277 auth_sworn_pt_flag
rename FLAG278 auth_nonsworn_ft_flag
rename FLAG279 auth_nonsworn_pt_flag
rename FLAG280 staff_sworn_ft_flag
rename FLAG281 staff_sworn_pt_flag
rename FLAG282 staff_nonsworn_ft_flag
rename FLAG283 staff_nonsworn_pt_flag
rename FLAG297 ft_resp_officers_flag
rename FLAG298 performs_community_policing_flag
rename FLAG299 school_resource_officer_flag
* dropping many demographic vars
drop V312 V313 V314 V315 V316 V317 V318 V319 V320 V321 V322 V323
drop FLAG312 FLAG313 FLAG314 FLAG315 FLAG316 FLAG317 FLAG318 FLAG319 FLAG320 FLAG321 FLAG322 FLAG323
rename V300 sworn_males
rename V301 sworn_females
rename V302 nonsworn_males
rename V303 nonsworn_females
rename V304 sworn_white_males
rename V305 sworn_white_females
rename V306 nonsworn_white_males
rename V307 nonsworn_white_females
rename V308 sworn_black_males
rename V309 sworn_black_females
rename V310 nonsworn_black_males
rename V311 nonsworn_black_females
rename FLAG300 sworn_males_flag
rename FLAG301 sworn_females_flag
rename FLAG302 nonsworn_males_flag
rename FLAG303 nonsworn_females_flag
rename FLAG304 sworn_white_males_flag
rename FLAG305 sworn_white_females_flag
rename FLAG306 nonsworn_white_males_flag
rename FLAG307 nonsworn_white_females_flag
rename FLAG308 sworn_black_males_flag
rename FLAG309 sworn_black_females_flag
rename FLAG310 nonsworn_black_males_flag
rename FLAG311 nonsworn_black_females_flag
* dropping detailed drug-testing protocols
drop V324 V325 V326 V327 V328 V329 V330 V331 V332 V333 V334 V335 V336 V337 V338
rename V339 off_screen_interview
rename V340 off_screen_psych
rename V341 off_screen_poly
rename V342 off_screen_voice_analyzer
rename V343 off_screen_physical_test
rename V344 off_screen_apt_test
rename V345 off_screen_crim_record
rename V346 off_screen_background
rename V347 off_screen_med_exam
rename V348 off_screen_driving_record
rename V349 off_screen_other
rename V350 off_screen_other_entry
rename V351 res_req
rename V352 educ_recruit_req
rename V353 educ_recruit_req_hours
rename V354 new_off_train_class_hrs
rename V355 new_off_train_field_hrs
rename V356 has_academy
rename V357 po_training_hours
rename V358 po_training_freq
rename FLAG353 educ_recruit_req_hours_flag
rename FLAG354 new_off_train_class_hrs_flag
rename FLAG355 new_off_train_field_hrs_flag
rename FLAG357 po_training_hours_flag
rename FLAG358 po_training_freq_flag
rename V359 allows_coll_bargain_sworn
rename V360 allows_coll_bargain_nonsworn
rename V361 memb_org_police_union
rename V362 memb_org_nonpolice_union
rename V363 memb_org_police_assc
rename V364 pay_hazard
rename V365 pay_shift_diff
rename V366 pay_ed_incentive
replace pay_hazard = 0 if pay_hazard==2
replace pay_shift_diff = 0 if pay_shift_diff==2
replace pay_ed_incentive = 0 if pay_ed_incentive==2
rename V367 pay_merit
replace pay_merit = 0 if pay_merit==2

*** 1997 | SECTION V: FINANCIAL INFORMATION ***
rename V368 gross_salary_benefit_pct
rename V369 gross_salary
rename V370 op_exp_other
rename V371 capex_equipment
rename V372 drug_asset_forf_tot_value
rename V373 ot_hours_total
rename V374 ot_hours_pay
rename V375 ot_comp_hours_earned
rename V376 salary_chief_min
rename V377 salary_chief_max
rename V378 salary_sgt_min
rename V379 salary_sgt_max
rename V380 salary_1yr_min
rename V381 salary_1yr_max
rename V382 salary_entry_min
rename V383 salary_entry_max
rename FLAG368 gross_salary_benefit_pct_flag
rename FLAG369 gross_salary_flag
rename FLAG370 op_exp_other_flag
rename FLAG371 capex_equipment_flag
rename FLAG372 drug_asset_forf_tot_value_flag
rename FLAG373 ot_hours_total_flag
rename FLAG374 ot_hours_pay_flag
rename FLAG375 ot_comp_hours_earned_flag
rename FLAG376 salary_chief_min_flag
rename FLAG377 salary_chief_max_flag
rename FLAG378 salary_sgt_min_flag
rename FLAG379 salary_sgt_max_flag
rename FLAG380 salary_1yr_min_flag
rename FLAG381 salary_1yr_max_flag
rename FLAG382 salary_entry_min_flag
rename FLAG383 salary_entry_max_flag

*** 1997 | SECTION VI: POLICIES AND PROGRAMS ***
rename V384 spu_hate_crimes_sworn
rename V385 spu_hate_crimes_nonsworn
rename V386 spu_hate_crimes_none
rename V387 spu_child_abuse_sworn
rename V388 spu_child_abuse_nonsworn
rename V389 spu_child_abuse_none
rename V390 spu_nbhd_crime_prev_sworn
rename V391 spu_nbhd_crime_prev_nonsworn
rename V392 spu_nbhd_crime_prev_none
rename V393 spu_community_policing_sworn
rename V394 spu_community_policing_nonsworn
rename V395 spu_community_policing_none
rename V396 spu_crime_analysis_sworn
rename V397 spu_crime_analysis_nonsworn
rename V398 spu_crime_analysis_none
rename V399 spu_dom_abuse_sworn
rename V400 spu_dom_abuse_nonsworn
rename V401 spu_dom_abuse_none
rename V402 spu_drug_educ_sworn
rename V403 spu_drug_educ_nonsworn
rename V404 spu_drug_educ_none
rename V405 spu_drunk_drivers_sworn
rename V406 spu_drunk_drivers_nonsworn
rename V407 spu_drunk_drivers_none
rename V408 spu_env_crime_sworn
rename V409 spu_env_crime_nonsworn
rename V410 spu_env_crime_none
rename V411 spu_gangs_sworn
rename V412 spu_gangs_nonsworn
rename V413 spu_gangs_none
rename V414 spu_juvenile_delinq_sworn
rename V415 spu_juvenile_delinq_nonsworn
rename V416 spu_juvenile_delinq_none
rename V417 spu_missing_child_sworn
rename V418 spu_missing_child_nonsworn
rename V419 spu_missing_child_none
rename V420 spu_prosec_rel_sworn
rename V421 spu_prosec_rel_nonsworn
rename V422 spu_prosec_rel_none
rename V423 spu_career_crim_sworn
rename V424 spu_career_crim_nonsworn
rename V425 spu_career_crim_none
rename V426 spu_research_planning_sworn
rename V427 spu_research_planning_nonsworn
rename V428 spu_research_planning_none
rename V429 spu_victim_assist_sworn
rename V430 spu_victim_assist_nonsworn
rename V431 spu_victim_assist_none
rename V432 spu_youth_outreach_sworn
rename V433 spu_youth_outreach_nonsworn
rename V434 spu_youth_outreach_none
rename FLAG384 spu_hate_crimes_sworn_flag
rename FLAG385 spu_hate_crimes_nonsworn_flag
rename FLAG387 spu_child_abuse_sworn_flag
rename FLAG388 spu_child_abuse_nonsworn_flag
rename FLAG390 spu_nbhd_crime_prev_sworn_flag
rename FLAG391 spu_nbhd_crime_prev_nonsworn_f
rename FLAG393 spu_community_policing_sworn_f
rename FLAG394 spu_community_policing_nonswornf
rename FLAG396 spu_crime_analysis_sworn_flag
rename FLAG397 spu_crime_analysis_nonsworn_flag
rename FLAG399 spu_dom_abuse_sworn_flag
rename FLAG400 spu_dom_abuse_nonsworn_flag
rename FLAG402 spu_drug_educ_sworn_flag
rename FLAG403 spu_drug_educ_nonsworn_flag
rename FLAG405 spu_drunk_drivers_sworn_flag
rename FLAG406 spu_drunk_drivers_nonsworn_flag
rename FLAG408 spu_env_crime_sworn_flag
rename FLAG409 spu_env_crime_nonsworn_flag
rename FLAG411 spu_gangs_sworn_flag
rename FLAG412 spu_gangs_nonsworn_flag
rename FLAG414 spu_juvenile_delinq_sworn_flag
rename FLAG415 spu_juvenile_delinq_nonsworn_f
rename FLAG417 spu_missing_child_sworn_flag
rename FLAG418 spu_missing_child_nonsworn_flag
rename FLAG420 spu_prosec_rel_sworn_flag
rename FLAG421 spu_prosec_rel_nonsworn_flag
rename FLAG423 spu_career_crim_sworn_flag
rename FLAG424 spu_career_crim_nonsworn_flag
rename FLAG426 spu_research_planning_sworn_flag
rename FLAG427 spu_research_planning_nonsworn_f
rename FLAG429 spu_victim_assist_sworn_flag
rename FLAG430 spu_victim_assist_nonsworn_flag
rename FLAG432 spu_youth_outreach_sworn_flag
rename FLAG433 spu_youth_outreach_nonsworn_flag
rename V435 direc_deadly_force
rename V436 direc_mentally_ill
rename V437 direc_homeless
rename V438 direc_dom_abuse
rename V439 direc_juveniles
rename V440 direc_non_lethal_force
rename V441 direc_private_sec
rename V442 direc_off_duty_empl
rename V443 direc_strip_search
rename V444 direc_code_of_conduct
rename V445 direc_use_of_funds
rename V446 direc_empl_counseling
rename V447 direc_citizen_compl
rename V448 direc_max_work_hours
rename V449 direc_discretionary_arrest

la define no0yes1 0 "No" 1 "Yes"
foreach var of varlist direc_* {
	replace `var'=0 if `var'==2
	la values `var' no0yes1
}

rename V450 pursuit_driving_policy_desc
rename V452 cit_review_board
rename V453 cit_rev_acc_chief
rename V454 cit_rev_acc_govt_exec
rename V455 cit_rev_acc_govt_body
rename V456 cit_rev_acc_other
rename V458 cit_review_board_sub_power
rename V459 exc_force_invest_chief
rename V460 exc_force_invest_int_aff
rename V461 exc_force_invest_sworn
rename V462 exc_force_invest_other
rename V464 exc_force_final_resp_chief
rename V465 exc_force_final_resp_sworn
rename V466 exc_force_final_resp_govt_exec
rename V467 exc_force_final_resp_other
rename V469 rev_exc_force_outside_chain
rename V470 exc_force_appeal_citizen
rename V471 exc_force_appeal_officers

*** 1997 | SECTION VII: COMMUNITY POLICING ACTIVITIES ***
rename V472 comm_pol_plan
rename V473 comm_pol_unit
rename V474 comm_pol_officers
rename FLAG474 comm_pol_officers_flag
rename V475 comm_pol_training_recruits
rename V476 comm_pol_training_sworn
rename V477 comm_pol_training_civilian
rename V478 train_comm_pol_citizens
rename V479 geographic_patrol_beats
rename V480 geographic_detective_asmgt
rename V481 encourage_SARA
rename V482 collab_problem_solving_criteria
rename V483 problem_solving_partnerships
rename V484 no_comm_pol_activities
rename V485 meetings_nbhd_assoc
rename V486 meetings_tenants_assoc
rename V487 meetings_youth_service
rename V488 meetings_advocacy_groups
rename V489 meetings_business_groups
rename V490 meetings_religious_groups
rename V491 meetings_school_groups
rename V492 meetings_other_groups
rename V493 meetings_other_groups_entry
rename V494 meetings_none
rename V495 survey_info_public_satisf
rename V496 survey_info_public_percep
rename V497 survey_info_crime_experiences
rename V498 survey_info_other
rename V500 survey_info_none
rename V501 survey_purpose_resource_alloc
rename V502 survey_purpose_prioritizing
rename V503 survey_purpose_policy_form
rename V504 survey_purpose_redistricting
rename V505 survey_purpose_po_info
rename V506 survey_purpose_other
rename V508 cit_stat_access
rename V509 cit_stat_access_in_person
rename V510 cit_stat_access_phone
rename V511 cit_stat_access_internet
rename V512 cit_stat_access_kiosk
rename V513 cit_stat_access_newsletter
rename V514 cit_stat_access_newpaper
rename V515 cit_stat_access_radio
rename V516 cit_stat_access_tv
rename V517 cit_stat_access_other
rename V518 cit_stat_access_other_entry
rename V519 cit_stat_level_county
rename V520 cit_stat_level_city
rename V521 cit_stat_level_district
rename V522 cit_stat_level_precinct
rename V523 cit_stat_level_census_tract
rename V524 cit_stat_level_patrol_beat
rename V525 cit_stat_level_nbhd
rename V526 cit_stat_level_apt_complex
rename V527 cit_stat_level_census_block
rename V528 cit_stat_level_street
rename V529 cit_stat_level_block
rename V530 cit_stat_level_other
rename V531 cit_stat_level_other_entry

*** 1997 | OTHER ***
* no clue what EXPFLAG could be, takes on actual/estimated/imputed values evidently 
drop EXPFLAG 
rename IMPCELL imputation_cell
rename WEIGHT2 weight_2
rename WEIGHT3 weight_3
rename CNTYCODE county_code
rename TOTALWT weight_final
rename SAMPTYPE sample_type

* dropping for merge
* temporary fix, may correct later 
drop exc_force_final_resp_other

order county_fips 

* making agency_type match across time, keeping old variation 
rename agency_type agency_type_old 
gen agency_type = .
replace agency_type = 1 if agency_type_old==2 | agency_type_old==3 | agency_type_old==6 | agency_type_old==7 | agency_type_old==8 | agency_type_old==9
replace agency_type = 2 if agency_type_old==1
replace agency_type = 3 if agency_type_old==5

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1997_renamed.dta", replace


*** 1999 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_1999.dta", replace

* 1999: reserve_off_ft reserve_off_pt comm_service_off_ft comm_service_off_pt volunteers_ft volunteers_pt comments_attached form_flag service_call_other_flag comp_mainframe_num_flag comp_mini_num_flag comp_personal_num_flag comp_server_num_flag comp_car_mounted_computer_num_f comp_other_num_flag reserve_off_ft_flag reserve_off_pt_flag comm_service_off_ft_flag comm_service_off_pt_flag volunteers_ft_flag volunteers_pt_flag 

gen year=1999
order year

rename STATE state_code
rename GOVTYPE govt_id_type
rename CNTYCODE county_code
rename CITYCODE city_code
* invariant
drop SECTOR
rename AGENCY agency_name
rename AGENCYID agency_id_unique
rename CITY city

* county_fips should be a string
rename FIPS temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
drop temp_county_fips

rename MSA msa_cmsa
rename POP population
rename COUNTY county
rename AGCYTYPE agency_type
rename FTE full_time_equiv
rename WT1 weight_base

*** 1999 | SECTION I: OPERATIONS ***
rename V22 duties_accident_investigation
rename V23 duties_parking
rename V24 duties_school_crossing
rename V25 duties_traffic_control
rename V26 duties_traffic_enforcement
rename V27 duties_comm_veh_enforcement
rename V28 duties_animal_control
rename V29 duties_civil_defense
rename V30 duties_fire
rename V31 duties_emergency_medical
rename V32 duties_ballistics
rename V33 duties_lab_testing
rename V34 duties_fingerprinting
rename V35 duties_violent_homicide
rename V36 duties_violent_other
rename V37 duties_property_crime_arson
rename V38 duties_property_crime_other
rename V39 duties_environmental_crime
rename V40 duties_cybercrime
rename V41 duties_executing_warrants
rename V42 duties_court_security
rename V43 duties_civil_serving
rename V44 duties_bomb_disposal
rename V45 duties_search_rescue
rename V46 duties_tactical_ops
rename V47 duties_underwater_recovery
rename V48 duties_jail_ops
rename V49 duties_holding_temp
rename V50 duties_holding
rename V51 duties_drug_enforcement
rename V52 duties_vice
rename V53 duties_dispatch
rename V54 duties_academy_training

rename V55 num_precinct_stations
rename V282 num_precinct_stations_flag
rename V56 num_fixed_nbhd_substations
rename V283 num_fixed_nbhd_substations_flag
rename V57 num_mob_nbhd_substations
rename V284 num_mob_nbhd_substations_flag
rename V58 num_other
rename V285 num_other_flag
rename V59 num_other_entry
rename V60 patrol_auto_routine
rename V61 patrol_auto_special
rename V62 patrol_auto_none
rename V63 patrol_motorcycle_routine
rename V64 patrol_motorcycle_special
rename V65 patrol_motorcycle_none
rename V66 patrol_foot_routine
rename V67 patrol_foot_special
rename V68 patrol_foot_none
rename V69 patrol_horse_routine
rename V70 patrol_horse_special
rename V71 patrol_horse_none
rename V72 patrol_bicycle_routine
rename V73 patrol_bicycle_special
rename V74 patrol_bicycle_none
rename V75 patrol_marine_routine
rename V76 patrol_marine_special
rename V77 patrol_marine_none
rename V78 operational_911_detail
gen operational_911 = 0 if operational_911_detail==3
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2

rename V79 service_call_alarm_cat

rename V80 service_call_total
rename V286 service_call_total_flag
rename V81 service_call_total_cit_911
rename V287 service_call_total_cit_911_flag
rename V82 service_call_cit_other
rename V288 service_call_cit_other_flag
rename V83 service_call_other
rename V289 service_call_other_flag

rename V84 service_call_disp
rename V290 service_call_disp_flag
rename V85 service_call_no_disp
rename V291 service_call_no_disp_flag
rename V88 service_call_disp_911
rename V294 service_call_disp_911_flag
rename V89 service_call_no_disp_911
rename V295 service_call_no_disp_911_flag

rename V92 service_call_disp_nonemer
rename V298 service_call_disp_nonemer_flag
rename V93 service_call_no_disp_nonemer 
rename V299 service_call_no_disp_nonemer_f

* service_call_refer variables only appears in 1999, dropping
rename V86 service_call_refer_law 
rename V292 service_call_refer_law_flag
rename V87 service_call_refer_other
rename V293 service_call_refer_other_flag
rename V90 service_call_911_refer_law
rename V296 service_call_911_refer_law_flag
rename V91 service_call_911_refer_other
rename V297 service_call_911_refer_other_f
rename V94 service_call_nonemer_refer_law
rename V300 service_call_nonemer_refer_law_f
rename V95 service_call_nonemer_refer_other
rename V301 service_call_nonemer_refer_ot_f
drop service_call_refer_law service_call_refer_other service_call_911_refer_law service_call_911_refer_other service_call_refer_law_flag service_call_refer_other_flag service_call_911_refer_law_flag service_call_911_refer_other_f service_call_nonemer_refer_law service_call_nonemer_refer_law_f service_call_nonemer_refer_other service_call_nonemer_refer_ot_f

*** 1999 | SECTION II: COMPUTERS AND INFORMATION SYSTEMS ***
rename V96 comp_mainframe
rename V97 comp_mainframe_num
rename V302 comp_mainframe_num_flag
rename V98 comp_mini
rename V99 comp_mini_num
rename V303 comp_mini_num_flag
rename V100 comp_personal
rename V101 comp_personal_num
rename V304 comp_personal_num_flag
rename V102 comp_server
rename V103 comp_server_num
rename V305 comp_server_num_flag
rename V104 comp_laptop
rename V105 comp_laptop_num
rename V306 comp_laptop_num_flag
rename V106 comp_car_mounted_term
rename V107 comp_car_mounted_term_num
rename V307 comp_car_mounted_term_num_flag
rename V108 comp_car_mounted_computer
rename V109 comp_car_mounted_computer_num
rename V308 comp_car_mounted_computer_num_f
rename V110 comp_handheld_term
rename V111 comp_handheld_term_num
rename V309 comp_handheld_term_num_flag
rename V112 comp_handheld_comp
rename V113 comp_handheld_comp_num
rename V310 comp_handheld_comp_num_flag
rename V114 comp_other
rename V115 comp_other_num
rename V311 comp_other_num_flag
rename V117 field_access_crim_hist
rename V118 field_access_driving_records
rename V119 field_access_mapping_prog
rename V120 field_access_service_call
rename V121 field_access_stolen_prop
rename V122 field_access_wanted_susp
rename V123 field_access_wanted_veh
rename V124 field_access_software_analysis
rename V125 comp_fc_analysis
rename V126 comp_fc_crime_mapping
rename V127 comp_fc_investigations
rename V128 comp_fc_dispatch
rename V129 comp_fc_in_field_comms
rename V130 comp_fc_in_field_reports
rename V131 comp_fc_internet_access

* redefining binary variable
foreach var of varlist comp_fc_* {
	replace `var' = 0 if `var'==2
}

rename V132 comp_files_alarms
rename V133 comp_files_arrests
rename V134 comp_files_calls
rename V135 comp_files_crim_hist
rename V136 comp_files_inventory
rename V137 comp_files_lic_reg
rename V138 comp_files_evidence
rename V139 comp_files_field_interviews
rename V140 comp_files_incident_based_data
rename V141 comp_files_incident_report
rename V142 comp_files_incident_report_narr
rename V143 comp_files_linked_analysis
rename V144 comp_files_payroll
rename V145 comp_files_personnel
rename V146 comp_files_stolen_veh
rename V147 comp_files_stolen_prop
rename V148 comp_files_summons
rename V149 comp_files_accidents
rename V150 comp_files_citations
rename V151 comp_files_traffic_stops
rename V152 comp_files_ucr_summary
rename V153 comp_files_ucr_incident
rename V154 comp_files_veh_reg
rename V155 comp_files_warrants

* redefining binary variable
foreach var of varlist comp_files_* {
	replace `var' = 0 if `var'==2
}

rename V156 geocode_arrests
rename V157 geocode_business_loc
rename V158 geocode_service_call
rename V159 geocode_census_data
rename V160 geocode_incidents
rename V161 geocode_other
rename V162 geocode_other_entry
rename V163 has_website
rename V164 has_website_address
rename V165 data_transfer_criminal_inc
rename V166 data_transfer_traffic_inc

*** 1999 | SECTION III: PERSONNEL ***
* dropping extra staffing vars, cumbersome, +flags
drop V175 V176 V177 V178 V179 V180 V181 V182 V183 V184 V185 V186 V187 V320 V321 V322 V323 V324 V325 V326 V327 V328 V329 V330 V331
rename V167 auth_sworn_ft
rename V312 auth_sworn_ft_flag
rename V168 auth_sworn_pt
rename V313 auth_sworn_pt_flag
rename V169 auth_nonsworn_ft
rename V314 auth_nonsworn_ft_flag
rename V170 auth_nonsworn_pt
rename V315 auth_nonsworn_pt_flag
rename V171 staff_sworn_ft
rename V316 staff_sworn_ft_flag
rename V172 staff_sworn_pt
rename V317 staff_sworn_pt_flag
rename V173 staff_nonsworn_ft
rename V318 staff_nonsworn_ft_flag
rename V174 staff_nonsworn_pt
rename V319 staff_nonsworn_pt_flag
rename V188 ft_resp_officers
rename V332 ft_resp_officers_flag
rename V189 performs_community_policing
rename V333 performs_community_policing_flag
rename V190 school_resource_officer
rename V334 school_resource_officer_flag
rename V191 reserve_off_ft
rename V335 reserve_off_ft_flag
rename V192 reserve_off_pt
rename V336 reserve_off_pt_flag
rename V193 comm_service_off_ft
rename V337 comm_service_off_ft_flag
rename V194 comm_service_off_pt
rename V338 comm_service_off_pt_flag
rename V195 volunteers_ft
rename V339 volunteers_ft_flag
rename V196 volunteers_pt
rename V340 volunteers_pt_flag

*** 1999 | SECTION IV: POLICIES AND PROCEDURES ***
rename V197 direc_code_of_conduct
rename V198 direc_citizen_compl
rename V199 direc_deadly_force
rename V200 direc_discretionary_arrest
rename V201 direc_dom_abuse
rename V202 direc_homeless
rename V203 direc_juveniles
rename V204 direc_non_lethal_force
rename V205 direc_mentally_ill
rename V206 direc_max_work_hours

foreach var of varlist direc_* {
	replace `var' = 0 if `var'==2
}

*** 1999 | SECTION V: COMMUNITY POLICING ACTIVITIES ***
rename V207 comm_pol_plan
rename V208 comm_pol_training_recruits
rename V209 comm_pol_training_sworn
rename V210 comm_pol_training_civilian
rename V211 train_comm_pol_citizens
rename V212 geographic_patrol_beats
rename V213 geographic_detective_asmgt
rename V214 encourage_SARA
rename V215 collab_problem_solving_criteria
rename V216 problem_solving_partnerships
rename V217 no_comm_pol_activities
rename V218 meetings_advocacy_groups
rename V219 meetings_business_groups
rename V220 meetings_dom_abuse
rename V221 meetings_local_public_ag
rename V222 meetings_nbhd_assoc
rename V223 meetings_religious_groups
rename V224 meetings_school_groups
rename V225 meetings_tenants_assoc
rename V226 meetings_youth_service
rename V227 meetings_senior_cit
rename V228 meetings_other_groups
rename V229 meetings_other_groups_entry
rename V230 meetings_none
rename V231 survey_info_public_satisf
rename V232 survey_info_public_percep
rename V233 survey_info_crime_experiences
rename V234 survey_info_other
rename V236 survey_info_none
rename V237 survey_purpose_resource_alloc
rename V238 survey_purpose_prioritizing
rename V239 survey_purpose_policy_form
rename V240 survey_purpose_redistricting
rename V241 survey_purpose_po_info
rename V242 survey_purpose_eval_prog_effec
rename V243 survey_purpose_training
rename V244 survey_purpose_other
rename V246 cit_stat_access_in_person
rename V247 cit_stat_access_phone
rename V248 cit_stat_access_internet
rename V249 cit_stat_access_kiosk
rename V250 cit_stat_access_newsletter
rename V251 cit_stat_access_newpaper
rename V252 cit_stat_access_fax
rename V253 cit_stat_access_library
rename V254 cit_stat_access_radio
rename V255 cit_stat_access_tv
rename V256 cit_stat_access_agency_rep
rename V257 cit_stat_access_written_req
rename V258 cit_stat_access_other
rename V259 cit_stat_access_other_entry
rename V260 cit_stat_access_none
rename V261 cit_stat_level_state
rename V262 cit_stat_level_county
rename V263 cit_stat_level_city
rename V264 cit_stat_level_district
rename V265 cit_stat_level_precinct
rename V266 cit_stat_level_census_tract
rename V267 cit_stat_level_patrol_beat
rename V268 cit_stat_level_nbhd
rename V269 cit_stat_level_apt_complex
rename V270 cit_stat_level_census_block
rename V271 cit_stat_level_street
rename V272 cit_stat_level_block
rename V273 cit_stat_level_address
rename V274 cit_stat_level_other
rename V275 cit_stat_level_other_entry
rename V276 cit_map_classes

*** 1999 | OTHER ***
rename V277 comments_attached
rename V278 data_date
rename V279 form_flag
rename V280 receipt_type
rename V281 receipt_date
rename V341 factor_1997
rename V342 factor_1999
rename V343 weight_and_imputation
rename V344 agency_nonresp_factor
rename V345 weight_final

order county_fips

* making agency_type match across time, keeping old variation 
rename agency_type agency_type_old 
gen agency_type = .
replace agency_type = 1 if agency_type_old==2 | agency_type_old==3 | agency_type_old==6 | agency_type_old==7 | agency_type_old==8 | agency_type_old==9
replace agency_type = 2 if agency_type_old==1
replace agency_type = 3 if agency_type_old==5

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1999_renamed.dta", replace


*** 2000 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_2000.dta", replace

* 2000: sector_id duties_none_of_above1 duties_none_of_above2 staff_sworn_w_arrest_ft_flag staff_sworn_w_arrest_pt_flag staff_sworn_wo_arrest_ft_flag staff_sworn_wo_arrest_pt_flag staff_total_ft_flag staff_total_pt_flag comp_car_mounted_other_num comp_portable_other_num auth_semi_38_primary auth_impact_none auth_chem_agent_pepper_none auth_chem_agent_tear_none auth_chem_agent_cs_gas_none auth_chem_agent_other_none auth_actions_none auth_semi_38_backup factor_2000 

gen year=2000
order year 

rename V1 state_code
destring state_code, replace
rename V2 govt_id_type
destring govt_id_type, replace
rename V3 county_code
destring county_code, replace
rename V4 city_code
destring city_code, replace
rename V5 sector_id
rename V6 agency_id_short
rename AGENCYID agency_id_unique
rename V7 agency_name
rename V8 city
rename V9 county_fips
rename V10 msa_cmsa
destring msa_cmsa, replace
rename V11 population
rename V12 county
rename V13 agency_type
destring agency_type, replace 
rename V14 full_time_equiv
rename V15 form_type
rename V34 year_began_operating

*** 2000 | SECTION I: CENSUS INFORMATION ***
rename V38 duties_violent_homicide
rename V39 duties_property_crime_arson
rename V40 duties_service_call_response
rename V41 duties_crime_prevention
rename V42 duties_drug_enforcement
rename V43 duties_first_responder
rename V44 duties_patrol
rename V45 duties_calls_receiving
rename V46 duties_traffic_enforcement
rename V47 duties_none_of_above1
rename V52 duties_court_security
rename V53 duties_civil_serving
rename V54 duties_jail_ops
rename V55 duties_executing_warrants
rename V56 multi_force_drug
rename V57 duties_academy_training
rename V58 duties_dispatch
rename V59 duties_search_rescue
rename V60 duties_tactical_ops
rename V61 duties_none_of_above2

rename V62 num_precinct_stations
rename V62F num_precinct_stations_flag
rename V63 num_fixed_nbhd_substations
rename V63F num_fixed_nbhd_substations_flag
rename V64 num_mob_nbhd_substations
rename V64F num_mob_nbhd_substations_flag
rename V65 auth_sworn_ft
rename V65F auth_sworn_ft_flag
rename V66 staff_sworn_w_arrest_ft
rename V66F staff_sworn_w_arrest_ft_flag 
rename V67 staff_sworn_w_arrest_pt
rename V67F staff_sworn_w_arrest_pt_flag
rename V68 staff_sworn_wo_arrest_ft
rename V68F staff_sworn_wo_arrest_ft_flag 
rename V69 staff_sworn_wo_arrest_pt
rename V69F staff_sworn_wo_arrest_pt_flag 
rename V70 staff_nonsworn_ft
rename V70F staff_nonsworn_ft_flag
rename V71 staff_nonsworn_pt
rename V71F staff_nonsworn_pt_flag
rename V72 staff_total_ft
rename V72F staff_total_ft_flag
rename V73 staff_total_pt
rename V73F staff_total_pt_flag
gen staff_sworn_ft = staff_sworn_w_arrest_ft + staff_sworn_wo_arrest_ft
gen staff_sworn_pt = staff_sworn_w_arrest_pt + staff_sworn_wo_arrest_pt
rename V74 ft_resp_officers
rename V74F ft_resp_officers_flag
rename V75 performs_community_policing
rename V75F performs_community_policing_flag
rename V76 school_resource_officer
rename V76F school_resource_officer_flag
rename V77 ft_prim_patrol
rename V77F ft_prim_patrol_flag
rename V78 ft_prim_detective
rename V78F ft_prim_detective_flag
rename V79 ft_prim_jail
rename V79F ft_prim_jail_flag
rename V80 ft_prim_court_sec
rename V80F ft_prim_court_sec_flag
rename V81 ft_prim_serving
rename V81F ft_prim_serving_flag
rename V82 total_op_budget
rename V82F total_op_budget_flag
rename V83 budgeting_period
rename V84 drug_asset_forf_tot_value
rename V84F drug_asset_forf_tot_value_flag

*** 2000 | SECTION II: PERSONNEL ***
* dropping detailed demographic vars, cumbersome
drop V112 V112F V113 V113F V114 V114F V115 V115F V116 V116F V117 V117F V118 V118F V119 V119F V120 V120F V121 V121F
rename V85 off_screen_background
rename V86 off_screen_credit_check
rename V87 off_screen_crim_record
rename V88 off_screen_driving_record
rename V89 off_screen_drug_test
rename V90 off_screen_med_exam
rename V91 off_screen_interview
rename V92 off_screen_personality_inv
rename V93 off_screen_physical_test
rename V94 off_screen_poly
rename V95 off_screen_psych
rename V96 off_screen_second_lang_test
rename V97 off_screen_voice_analyzer
rename V98 off_screen_volunteer_hist
rename V99 off_screen_apt_test
rename V100 educ_recruit_req
rename V101 educ_recruit_req_hours
rename V101F educ_recruit_req_hours_flag
rename V102 new_off_train_class_hrs_state
rename V102F new_off_train_class_hrs_state_f 
rename V103 new_off_train_class_hrs_add
rename V103F new_off_train_class_hrs_add_f
rename V104 new_off_train_field_hrs_state
rename V104F new_off_train_field_hrs_state_f
rename V105 new_off_train_field_hrs_add
rename V105F new_off_train_field_hrs_add_f 
rename V106 po_training_hours_state
rename V106F po_training_hours_state_flag
rename V107 po_training_hours_add
rename V107F po_training_hours_add_flag
rename V108 sworn_white_males
rename V108F sworn_white_males_flag
rename V109 sworn_white_females
rename V109F sworn_white_females_flag
rename V110 sworn_black_males
rename V110F sworn_black_males_flag
rename V111 sworn_black_females
rename V111F sworn_black_females_flag
rename V122 sworn_males
rename V122F sworn_males_flag
rename V123 sworn_females
rename V123F sworn_females_flag 
rename V124 allows_coll_bargain_sworn
rename V125 allows_coll_bargain_nonsworn
rename V126 pay_ed_incentive
rename V127 pay_hazard
rename V128 pay_merit
rename V129 pay_shift_diff
rename V130 pay_special_skills
rename V131 pay_tuition_reimb

foreach var of varlist pay_* {
	replace `var' = 0 if `var'==2
	la values `var' no0yes1
}

rename V132 salary_chief_min
rename V132F salary_chief_min_flag
rename V133 salary_chief_max
rename V133F salary_chief_max_flag
rename V134 salary_sgt_min
rename V134F salary_sgt_min_flag
rename V135 salary_sgt_max
rename V135F salary_sgt_max_flag
rename V136 salary_entry_min
rename V136F salary_entry_min_flag
rename V137 salary_entry_max
rename V137F salary_entry_max_flag

*** 2000 | SECTION III: COMMUNITY POLICING ACTIVITIES ***
rename V138 comm_pol_plan
rename V139 comm_pol_training_recruits
rename V140 comm_pol_training_sworn
rename V141 comm_pol_training_civilian
rename V142 encourage_SARA
rename V143 geographic_detective_asmgt
rename V144 conduct_cit_academy
rename V145 problem_solving_partnerships
rename V146 geographic_patrol_beats
rename V147 collab_problem_solving_criteria
rename V148 train_comm_pol_citizens
rename V149 comm_pol_tech_upgrade
rename V150 no_comm_pol_activities
rename V151 meetings_advocacy_groups
rename V152 meetings_business_groups
rename V153 meetings_dom_abuse
rename V154 meetings_local_public_ag
rename V155 meetings_nbhd_assoc
rename V156 meetings_religious_groups
rename V157 meetings_school_groups
rename V158 meetings_senior_cit
rename V159 meetings_tenants_assoc
rename V160 meetings_youth_service
rename V161 meetings_none
rename V162 survey_info_public_satisf
rename V163 survey_info_public_percep
rename V164 survey_info_crime_experiences
rename V165 survey_info_crime_reporting
rename V166 survey_info_other
rename V168 survey_info_none
rename V169 survey_purpose_resource_alloc
rename V170 survey_purpose_eval_prog_effec
rename V171 survey_purpose_policy_form
rename V172 survey_purpose_prioritizing
rename V173 survey_purpose_po_info
rename V174 survey_purpose_redistricting
rename V175 survey_purpose_training
rename V176 survey_purpose_other

*** 2000 | SECTION IV: COMPUTERS AND INFORMATION SYSTEMS ***
rename V178 comp_car_mounted_laptop
rename V179 comp_car_mounted_laptop_num
rename V179F comp_car_mounted_laptop_num_flag
rename V180 comp_car_mounted_computer
rename V181 comp_car_mounted_computer_num
rename V181F comp_car_mounted_computer_num_fl
rename V182 comp_car_mounted_term
rename V183 comp_car_mounted_term_num
rename V183F comp_car_mounted_term_num_flag
rename V184 comp_car_mounted_other
rename V185 comp_car_mounted_other_num
rename V185F comp_car_mounted_other_num_flag
rename V187 comp_laptop
rename V188 comp_laptop_num
rename V188F comp_laptop_num_flag
rename V189 comp_handheld_comp
rename V190 comp_handheld_comp_num
rename V190F comp_handheld_comp_num_flag
rename V191 comp_handheld_term
rename V192 comp_handheld_term_num
rename V192F comp_handheld_term_num_flag
rename V193 comp_portable_other
rename V194 comp_portable_other_num
rename V194F comp_portable_other_num_flag
rename V196 field_access_veh_records
rename V197 field_access_driving_records
rename V198 field_access_crim_hist
rename V199 field_access_linked_files
rename V200 field_access_service_call
rename V201 data_transfer_criminal_inc
rename V202 afis_ownership
rename V203 afis_access
rename V204 afis_remote
rename V205 afis_none
rename V206 comp_fc_booking
rename V207 comp_fc_analysis
rename V208 comp_fc_crime_mapping
rename V209 comp_fc_investigations
rename V210 comp_fc_dispatch
rename V211 comp_fc_fleet_mgmt
rename V212 comp_fc_in_field_comms
rename V213 comp_fc_in_field_reports
rename V214 comp_fc_sharing_info
rename V215 comp_fc_internet_access
rename V216 comp_fc_personnel_records
rename V217 comp_fc_records
rename V218 comp_fc_resource_alloc
rename V219 comp_fc_none_of_above
rename V220 comp_files_alarms
rename V221 comp_files_arrests
rename V222 comp_files_calls
rename V223 comp_files_crim_hist
rename V224 comp_files_prints
rename V225 comp_files_incident_report
rename V226 comp_files_linked_analysis
rename V227 comp_files_stolen_prop
rename V228 comp_files_summons
rename V229 comp_files_accidents
rename V230 comp_files_citations
rename V231 comp_files_traffic_stops
rename V232 comp_files_use_of_force
rename V233 comp_files_warrants
rename V234 comp_files_none_of_above

*** 2000 | SECTION V: OPERATIONS ***
rename V235 operational_911_detail
gen operational_911 = 0 if operational_911_detail==3
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2
rename V236 patrol_auto
rename V237 patrol_motorcycle
rename V238 patrol_foot
rename V239 patrol_bicycle
rename V240 patrol_marine
rename V241 patrol_horse
rename V242 patrol_other
rename V243 patrol_other_entry
rename V244 drug_unit_officers_ft
rename V244F drug_unit_officers_ft_flag
rename V245 drug_unit_officers_pt
rename V245F drug_unit_officers_pt_flag
rename V246 multi_force_drug_off_ft
rename V246F multi_force_drug_off_ft_f
rename V247 multi_force_drug_off_pt
rename V247F multi_force_drug_off_pt_f
rename V248 lockup_adult_cap
rename V248F lockup_adult_cap_flag
rename V249 lockup_juvenile_cap
rename V249F lockup_juvenile_cap_flag
rename V250 max_holding_time_adult
rename V250F max_holding_time_adult_flag
rename V251 max_holding_time_juvenile
rename V251F max_holding_time_juvenile_flag

*** 2000 | SECTION VI: EQUIPMENT ***
rename V252 sidearm_supplied

rename V253 backup_sidearm_supplied
rename V254 bodyarmor_supplied
rename V255 uniforms_supplied
rename V367 sidearm_cash_allowance
rename V368 backup_sidearm_cash_allowance
rename V369 bodyarmor_cash_allowance
rename V370 uniforms_cash_allowance
rename V371 sidearm_none
rename V372 backup_sidearm_none
rename V373 bodyarmor_none
rename V374 uniforms_none
rename V256 auth_semi_10m_primary
rename V257 auth_semi_9m_primary
rename V258 auth_semi_45_primary
rename V259 auth_semi_40_primary
rename V260 auth_semi_38_primary
rename V261 auth_semi_other_primary
rename V262 auth_semi_other_entry_primary
rename V263 auth_rev_primary
rename V353 auth_semi_10m_backup
rename V354 auth_semi_9m_backup
rename V355 auth_semi_45_backup
rename V356 auth_semi_40_backup
rename V357 auth_semi_38_backup
rename V358 auth_semi_other_backup

rename V359 auth_rev_backup
rename V360 not_auth_semi_10m
rename V361 not_auth_semi_9m
rename V362 not_auth_semi_45
rename V363 not_auth_semi_40
rename V364 not_auth_semi_38
rename V365 not_auth_semi_other
rename V366 not_auth_rev
rename V264 bodyarmor_po_req

rename V265 auth_impact_baton
rename V266 auth_impact_baton_pr24
rename V267 auth_impact_baton_cllpsbl
gen auth_baton=0
replace auth_baton=1 if (auth_impact_baton==1 | auth_impact_baton_pr24==1 | auth_impact_baton_cllpsbl==1)

rename V268 auth_impact_soft_proj
rename V269 auth_impact_blackjack
rename V270 auth_impact_rubber_bullet
rename V271 auth_impact_other
rename V272 auth_impact_other_entry
rename V273 auth_impact_none

rename V274 auth_chem_agent_pepper_personal
rename V275 auth_chem_agent_pepper_tactical
rename V276 auth_chem_agent_pepper_none
rename V277 auth_chem_agent_tear_personal
rename V278 auth_chem_agent_tear_tactical
rename V279 auth_chem_agent_tear_none
rename V280 auth_chem_agent_cs_gas_personal
rename V281 auth_chem_agent_cs_gas_tactical
rename V282 auth_chem_agent_cs_gas_none
rename V283 auth_chem_agent_other_personal
rename V284 auth_chem_agent_other_tactical
rename V285 auth_chem_agent_other_none

rename V286 auth_elec_dev_stun_gun
rename V287 auth_elec_dev_taser

rename V288 auth_neck_hold
rename V289 auth_capture_net
rename V290 auth_flashbang
rename V291 auth_actions_other
rename V292 auth_actions_other_entry
rename V293 auth_actions_none
rename V294 vehicles_marked_cars
rename V294F vehicles_marked_cars_flag
rename V295 vehicles_unmarked_cars
rename V295F vehicles_unmarked_cars_flag
rename V296 vehicles_4_wheel_misc
rename V296F vehicles_4_wheel_misc_flag
rename V297 vehicles_aircraft
rename V297F vehicles_aircraft_flag
rename V298 vehicles_helicopters
rename V298F vehicles_helicopters_flag
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename V299 vehicles_boats
rename V299F vehicles_boats_flag
rename V300 vehicles_2_wheel
rename V300F vehicles_2_wheel_flag
rename V301 vehicles_bicycles
rename V301F vehicles_bicycles_flag
rename V302 marked_take_home
replace marked_take_home = 0 if marked_take_home==2
rename V303 marked_off_duty_use
rename V304 dogs
rename V304F dogs_flag
rename V305 horses
rename V305F horses_flag
rename V306 night_vis_infrared
rename V307 night_vis_image_intensifier
rename V308 night_vis_laser_rangefinder
rename V309 night_vis_none_of_above
rename V310 dig_imaging_prints
rename V311 dig_imaging_mugshots
rename V312 dig_imaging_composites
rename V313 dig_imaging_none_of_above
rename V314 veh_stop_engine_disrupt
rename V315 veh_stop_lojack
rename V316 veh_stop_roadspikes
rename V317 veh_stop_none_of_above
rename V318 cameras_used
rename V319 cameras_patrol_car
rename V319F cameras_patrol_car_flag
rename V320 cameras_fixed_surv
rename V320F cameras_fixed_surv_flag
rename V321 cameras_mobile_surv
rename V321F cameras_mobile_surv_flag
rename V322 cameras_traffic
rename V322F cameras_traffic_flag

*** 2000 | SECTION VII: POLICIES AND PROGRAMS ***
rename V323 direc_deadly_force
rename V324 direc_non_lethal_force
rename V325 direc_code_of_conduct
rename V326 direc_off_duty_empl
rename V327 direc_max_work_hours
foreach var of varlist direc_* {
	replace `var' = 0 if `var'==2
}
la values direc_* no0yes1

rename V328 pursuit_driving_policy_desc
rename V329 pursuit_driving_policy_desc_oth
rename V330 arrests_prot_order_violation
rename V331 arrests_domestic_assault
rename V332 cit_review_board
rename V333 cit_review_board_sub_power
rename V334 spu_hate_crimes
rename V335 spu_child_abuse
rename V336 spu_nbhd_crime_prev
rename V337 spu_community_policing
rename V338 spu_crime_analysis
rename V339 spu_cybercrime
rename V340 spu_dom_abuse
rename V341 spu_drug_educ
rename V342 spu_drunk_drivers
rename V343 spu_env_crime
rename V344 spu_gangs
rename V345 spu_internal_affairs
rename V346 spu_juvenile_delinq
rename V347 spu_missing_child
rename V348 spu_prosec_rel
rename V349 spu_career_crim
rename V350 spu_research_planning
rename V351 spu_victim_assist
rename V352 spu_youth_outreach

* 2000 | OTHER ***
rename V375 weight_base
rename V376 factor_1997
rename V377 factor_1999
rename V378 factor_2000
rename V379 weight_and_imputation
rename V380 agency_nonresp_factor
rename V381 weight_final

* dropping for merge
* temporary fix, may correct later 
drop agency_id_short

order county_fips

* making agency_type match across time, keeping old variation 
rename agency_type agency_type_old 
gen agency_type = .
replace agency_type = 1 if agency_type_old==2 | agency_type_old==3 | agency_type_old==6 | agency_type_old==7 | agency_type_old==8 | agency_type_old==9
replace agency_type = 2 if agency_type_old==1
replace agency_type = 3 if agency_type_old==5

replace population = . if population == 0

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2000_renamed.dta", replace


*** 2003 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_2003.dta", replace

* 2003: address auth_staff_wo_arrest_ft auth_total_ft ft_comm_technicians new_off_train_class_hrs_total new_off_train_field_hrs_total po_training_hours_total ft_sworn_hires_new ft_sworn_hires_other ft_sworn_sep_probationary_rej ft_sworn_called_for_military 

gen year=2003
order year

rename AGENCYID agency_id_unique
rename AGENCYNA agency_name
rename COUNTY county
rename STREET address
rename CITY city
rename STATE state
rename ZIP zip

* county_fips should be a string
rename FIPS temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
drop temp_county_fips


rename MSACSMA msa_cmsa
rename POP population
rename AGCYTYPE agency_type
rename FORMTYPE form_type
gen form_long = (form_type==1)
gen temp_form_type = ""
replace temp_form_type = "L" if form_type == 1
replace temp_form_type = "S" if form_type == 2
drop form_type 
gen form_type = temp_form_type
drop temp_form_type

*** 2003 | SECTION I: DESCRIPTIVE INFORMATION ***
rename V1 duties_service_call_response
rename V2 duties_patrol
rename V3 duties_first_responder
rename V4 duties_drug_enforcement
rename V5 duties_vice
rename V6 duties_traffic_enforcement
rename V7 duties_traffic_control
rename V8 duties_accident_investigation
rename V9 duties_parking
rename V10 duties_comm_veh_enforcement
rename V11 duties_violent_homicide
rename V12 duties_property_crime_arson
rename V13 duties_cybercrime
rename V14 duties_other_crime
rename V15 duties_executing_warrants
rename V16 duties_court_security
rename V17 duties_civil_serving
rename V18 duties_eviction_notices
rename V19 duties_protection_order_enforce
rename V20 duties_child_support_enforcement
rename V21 duties_animal_control
rename V22 duties_school_crossing
rename V23 duties_emergency_medical
rename V24 duties_civil_defense
rename V25 duties_fire
rename V26 duties_crime_prevention
rename V27 duties_bomb_disposal
rename V28 duties_search_rescue
rename V29 duties_tactical_ops
rename V30 duties_underwater_recovery
rename V31 duties_jail_ops
rename V32 duties_holding
rename V33 duties_holding_temp
rename V34 duties_inmate_transport
rename V35 duties_dispatch
rename V36 duties_fire_dispatch
rename V37 duties_academy_training
rename V38 num_precinct_stations
rename V39 num_fixed_nbhd_substations
rename V40 num_mob_nbhd_substations
rename V41 auth_sworn_ft
rename V42 staff_sworn_w_arrest_ft
rename V43 staff_sworn_w_arrest_pt
rename V44 auth_staff_wo_arrest_ft
rename V45 staff_sworn_wo_arrest_ft
rename V46 staff_sworn_wo_arrest_pt
rename V47 auth_nonsworn_ft
rename V48 staff_nonsworn_ft
rename V49 staff_nonsworn_pt
rename V50 auth_total_ft
rename V51 staff_total_ft
rename V52 staff_total_pt
gen staff_sworn_ft = staff_sworn_w_arrest_ft + staff_sworn_wo_arrest_ft
gen staff_sworn_pt = staff_sworn_w_arrest_pt + staff_sworn_wo_arrest_pt
rename V53 reserve_off_sworn_ft
rename V54 reserve_off_sworn_pt
rename V55 reserve_off_nonsworn_ft
rename V56 reserve_off_nonsworn_pt
rename V57 ft_comm_technicians
rename V58 ft_resp_officers
rename V59 performs_community_policing
rename V60 school_resource_officer
rename V61 ft_prim_patrol
rename V62 ft_prim_detective
rename V63 ft_prim_jail
rename V64 ft_prim_court_sec
rename V65 ft_prim_serving
rename V66 total_op_budget
rename V67 total_op_budget_flag
rename V68 drug_asset_forf_tot_value

*** 2003 | SECTION II: PERSONNEL ***
* dropping detailed demographic vars, cumbersome
drop V115 V116 V117 V118 V119 V120 V121 V122 V123 V124
rename V69 educ_recruit_req 
rename V70 educ_recruit_req_hours
rename V71 off_screen_problem_solving
rename V72 off_screen_cultural_underst
rename V73 off_screen_background
rename V74 off_screen_credit_check
rename V75 off_screen_crim_record
rename V76 off_screen_driving_record
rename V77 off_screen_drug_test
rename V78 off_screen_mediation_skills
rename V79 off_screen_med_exam
rename V80 off_screen_interview
rename V81 off_screen_personality_inv
rename V82 off_screen_physical_test
rename V83 off_screen_poly
rename V84 off_screen_psych
rename V85 off_screen_second_lang_test
rename V86 off_screen_voice_analyzer
rename V87 off_screen_volunteer_hist
rename V88 off_screen_apt_test
rename V89 new_off_train_class_hrs_state
rename V90 new_off_train_field_hrs_state
rename V91 new_off_train_class_hrs_add
rename V92 new_off_train_field_hrs_add
rename V93 new_off_train_class_hrs_total
rename V94 new_off_train_field_hrs_total
rename V95 po_training_hours_state
rename V96 po_training_hours_add
rename V97 po_training_hours_total
rename V98 ft_sworn_hires_new
rename V99 ft_sworn_hires_lateral
rename V100 ft_sworn_hires_other
rename V102 ft_sworn_hires_total
rename V103 ft_sworn_sep_resignations
rename V104 ft_sworn_sep_dismissals
rename V105 ft_sworn_sep_disability
rename V106 ft_sworn_sep_retirement
rename V107 ft_sworn_sep_probationary_rej
rename V108 ft_sworn_sep_other
rename V109 ft_sworn_sep_total
rename V110 ft_sworn_called_for_military
rename V111 sworn_white_males
rename V112 sworn_white_females
rename V113 sworn_black_males
rename V114 sworn_black_females
rename V125 sworn_males
rename V126 sworn_females
rename V127 allows_coll_bargain_sworn
rename V128 allows_coll_bargain_nonsworn
rename V129 pay_ed_incentive
rename V130 pay_hazard
rename V131 pay_merit
rename V132 pay_shift_diff
rename V133 pay_special_skills
rename V134 pay_bilingual
rename V135 pay_tuition_reimb
rename V136 pay_military_service
rename V137 salary_chief_min
rename V138 salary_chief_max
rename V139 salary_sgt_min
rename V140 salary_sgt_max
rename V141 salary_entry_min
rename V142 salary_entry_max
rename V137F salary_chief_min_flag
rename V138F salary_chief_max_flag
rename V139F salary_sgt_min_flag
rename V140F salary_sgt_max_flag
rename V141F salary_entry_min_flag
rename V142F salary_entry_max_flag

*** 2003 | SECTION III: OPERATIONS ***
rename V143 lockup_adult_cap
rename V144 lockup_juvenile_cap
rename V145 max_holding_time_adult
rename V146 max_holding_time_juvenile
rename V147 operational_911_detail
gen operational_911 = 0 if operational_911_detail==0
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2
rename V148 operational_911_caller_id
rename V149 operational_911_caller_location

rename V150 service_call_total_cit_911
rename V151 service_call_disp_911
rename V152 service_call_total_cit_other
rename V153 service_call_disp_nonemer
rename V154 service_call_total_311
rename V155 service_call_disp_311
rename V156 service_call_total
rename V157 service_call_disp

rename V152F service_call_cit_other_flag
rename V153F service_call_disp_nonemer_flag
rename V154F service_call_total_311_flag
rename V155F service_call_disp_311_flag
rename V156F service_call_total_flag
rename V157F service_call_disp_flag
rename V158 service_call_any_flag

rename V159 patrol_auto
rename V160 patrol_marine
rename V161 patrol_motorcycle
rename V162 patrol_horse
rename V163 patrol_foot
rename V164 patrol_bicycle
rename V165 patrol_aviation
rename V166 patrol_other
rename V168 drug_unit_officers_ft
rename V169 drug_unit_officers_pt
rename V170 multi_force_drug_off_ft
rename V171 multi_force_drug_off_pt

*** 2003 | SECTION IV: SPECIALIZED UNITS ***
rename V172 spu_hate_crimes
rename V173 spu_bomb_disposal
rename V174 spu_child_abuse
rename V175 spu_nbhd_crime_prev
rename V176 spu_community_policing
rename V177 spu_crime_analysis
rename V178 spu_cybercrime
rename V179 spu_dom_abuse
rename V180 spu_drug_educ
rename V181 spu_gangs
rename V182 spu_impaired_drivers
rename V183 spu_internal_affairs
rename V184 spu_juvenile_delinq
rename V185 spu_meth_labs
rename V186 spu_missing_child
rename V187 spu_prosec_rel
rename V188 spu_career_crim
rename V189 spu_research_planning
rename V190 spu_school_safety
rename V191 spu_terrorism
rename V192 spu_victim_assist
rename V193 spu_youth_outreach

*** 2003 | SECTION V: COMMUNITY POLICING ***
rename V194 comm_pol_training_recruits
rename V195 comm_pol_training_sworn
rename V196 comm_pol_training_civilian
rename V197 encourage_SARA
rename V198 encourage_SARA_pct
rename V199 conduct_cit_academy
rename V200 formal_comm_pol_plan
rename V201 geographic_patrol_beats
rename V202 geographic_patrol_beats_pct
rename V203 collab_problem_solving_criteria
rename V204 train_comm_pol_citizens
rename V205 comm_pol_tech_upgrade
rename V206 problem_solving_partnerships
rename V207 no_comm_pol_activities
rename V208 mission_statement_inc_comm_pol
rename V209 meetings_advocacy_groups
rename V210 meetings_business_groups
rename V211 meetings_religious_groups
rename V212 meetings_local_public_ag
rename V213 meetings_other_lea_groups
rename V214 meetings_nbhd_assoc
rename V215 meetings_senior_cit
rename V216 meetings_school_groups
rename V217 meetings_youth_service
rename V218 meetings_none
rename V219 survey_info_public_satisf
rename V220 survey_info_public_percep
rename V221 survey_info_crime_experiences
rename V222 survey_info_crime_reporting
rename V223 survey_info_other
rename V225 survey_info_none
rename V226 survey_purpose_resource_alloc
rename V227 survey_purpose_eval_agency
rename V228 survey_purpose_eval_off
rename V229 survey_purpose_eval_prog_effec
rename V230 survey_purpose_prioritizing
rename V231 survey_purpose_po_info
rename V232 survey_purpose_redistricting
rename V233 survey_purpose_training
rename V234 survey_purpose_other
rename V236 survey_purpose_none

*** 2003 | SECTION VI: EMERGENCY PREPAREDNESS ***
rename V237 terrorist_plan
rename V238 terrorist_plan_coop_agree
rename V239 shared_radio_network
rename V240 emer_equip_ppe
rename V241 emer_equip_chem_detect
rename V242 emer_equip_radio_detect
rename V243 emer_equip_bio_detect
rename V244 emer_equip_decontam_equip
rename V245 emer_equip_expl_detect
rename V246 emer_equip_none_of_above
rename V247 terrorist_prep_comm_partner
rename V248 terrorist_prep_anti_fear
rename V249 terrorist_prep_dissemination
rename V250 terrorist_prep_comm_meetings
rename V251 terrorist_prep_crit_areas
rename V252 terrorist_prep_none_of_above
rename V253 multi_force_terr_sworn_ft
rename V254 multi_force_terr_sworn_pt
rename V255 multi_force_terr_other_ft
rename V256 multi_force_terr_other_pt
rename V257 ft_prim_terr_intel_sworn
rename V258 ft_prim_terr_intel_nonsworn

*** 2003 | SECTION VII: EQUIPMENT ***
rename V259 sidearm_supplied
rename V260 sidearm_cash_allowance
rename V261 sidearm_none
rename V262 backup_sidearm_supplied
rename V263 backup_sidearm_cash_allowance
rename V264 backup_sidearm_none
rename V265 bodyarmor_supplied
rename V266 bodyarmor_cash_allowance
rename V267 bodyarmor_none
rename V268 uniforms_supplied
rename V269 uniforms_cash_allowance
rename V270 uniforms_none
rename V271 auth_semi_10m_primary
rename V272 auth_semi_10m_backup
rename V273 auth_semi_10m_offduty
rename V274 auth_semi_9m_primary
rename V275 auth_semi_9m_backup
rename V276 auth_semi_9m_offduty
rename V277 auth_semi_45_primary
rename V278 auth_semi_45_backup
rename V279 auth_semi_45_offduty
rename V280 auth_semi_40_primary
rename V281 auth_semi_40_backup
rename V282 auth_semi_40_offduty
rename V283 auth_semi_357_primary
rename V284 auth_semi_357_backup
rename V285 auth_semi_357_offduty
rename V286 auth_semi_380_primary
rename V287 auth_semi_380_backup
rename V288 auth_semi_380_offduty
rename V289 auth_semi_other_primary
rename V290 auth_semi_other_backup
rename V291 auth_semi_other_offduty
rename V292 auth_semi_other_entry
rename V293 auth_semi_any_primary
rename V294 auth_semi_any_backup
rename V295 auth_semi_any_offduty
rename V296 auth_rev_primary
rename V297 auth_rev_backup
rename V298 auth_rev_offduty
rename V299 bodyarmor_po_req
rename V300 dogs
rename V301 horses
rename V302 auth_impact_baton
rename V303 auth_impact_baton_pr24
rename V304 auth_impact_baton_cllpsbl

gen auth_baton=0
replace auth_baton=1 if (auth_impact_baton==1 | auth_impact_baton_pr24==1 | auth_impact_baton_cllpsbl==1)

rename V305 auth_impact_soft_proj
rename V306 auth_impact_blackjack
rename V307 auth_impact_rubber_bullet
rename V308 auth_impact_other
rename V309 auth_chem_agent_pepper
rename V310 auth_chem_agent_tear
rename V311 auth_chem_agent_cs
rename V312 auth_chem_agent_other
rename V313 auth_elec_dev_stun_gun
rename V314 auth_elec_dev_taser
rename V315 auth_neck_hold
rename V316 auth_hi_int_light
rename V317 auth_actions_other
rename V318 dig_imaging_prints
rename V319 dig_imaging_mugshots
rename V320 dig_imaging_composites
rename V321 dig_imaging_facial_recog
rename V322 dig_imaging_photography
rename V323 dig_imaging_other
rename V325 dig_imaging_none_of_above
rename V326 night_vis_infrared
rename V327 night_vis_image_intensifier
rename V328 night_vis_laser_rangefinder
rename V329 night_vis_other
rename V331 night_vis_none_of_above
rename V332 veh_stop_engine_disrupt
rename V333 veh_stop_lojack
rename V334 veh_stop_roadspikes
rename V335 veh_stop_other
rename V337 veh_stop_none_of_above
rename V338 vehicles_marked_cars
rename V339 vehicles_marked_other
rename V340 vehicles_unmarked_cars
rename V341 vehicles_unmarked_other
rename V342 vehicles_aircraft
rename V343 vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename V344 vehicles_boats
rename V345 vehicles_2_wheel
rename V346 vehicles_bicycles
rename V347 marked_take_home
rename V348 marked_off_duty_use
rename V349 cameras_red_light
rename V351 cameras_speeding
rename V353 cameras_used
rename V354 cameras_patrol_car
rename V355 cameras_fixed_surv
rename V356 cameras_mobile_surv
rename V357 cameras_traffic
rename V358 comp_car_mounted_laptop
rename V359 comp_car_mounted_laptop_num
rename V360 comp_car_mounted_laptop_none
rename V361 comp_car_mounted_computer
rename V362 comp_car_mounted_computer_num
rename V363 comp_car_mounted_computer_none
rename V364 comp_car_mounted_term
rename V365 comp_car_mounted_term_num
rename V366 comp_car_mounted_term_none
rename V367 comp_car_mounted_other
rename V370 comp_car_mounted_other_none
rename V371 comp_laptop
rename V372 comp_laptop_num
rename V373 comp_laptop_none
rename V374 comp_handheld_comp
rename V376 comp_handheld_comp_none
rename V377 comp_handheld_term
rename V379 comp_handheld_term_none
rename V380 comp_pdas
rename V381 comp_pdas_num
rename V382 comp_pdas_none
rename V383 comp_portable_other
rename V386 comp_portable_other_none
rename V387 field_access_veh_records
rename V388 field_access_driving_records
rename V389 field_access_crim_hist
rename V390 field_access_warrants
rename V391 field_access_protection_ord
rename V392 field_access_int_agency_files
rename V393 field_access_service_call
rename V394 data_transfer_criminal_inc
rename V395 afis_ownership
rename V396 afis_shared
rename V397 afis_remote
rename V398 afis_access
rename V399 afis_none
rename V400 comp_fc_community_problems
rename V401 comp_fc_booking
rename V402 comp_fc_analysis
rename V403 comp_fc_crime_mapping
rename V404 comp_fc_investigations
rename V405 comp_fc_dispatch
rename V406 comp_fc_fleet_mgmt
rename V407 comp_fc_hotspot_id
rename V408 comp_fc_in_field_comms
rename V409 comp_fc_in_field_reports
rename V410 comp_fc_gathering_intel
rename V411 comp_fc_sharing_info
rename V412 comp_fc_internet_access
rename V413 comp_fc_personnel_records
rename V414 comp_fc_records
rename V415 comp_fc_resource_alloc
rename V416 comp_fc_traffic_stop_data_coll
rename V417 comp_fc_none_of_above
rename V418 comp_fc_all_of_above
rename V419 comp_files_alarms
rename V420 comp_files_arrests
rename V421 comp_files_facial_recog
rename V422 comp_files_calls
rename V423 comp_files_crim_hist
rename V424 comp_files_prints
rename V425 comp_files_incident_report
rename V426 comp_files_firearms
rename V427 comp_files_terrorism
rename V428 comp_files_stolen_prop
rename V429 comp_files_summons
rename V430 comp_files_accidents
rename V431 comp_files_citations
rename V432 comp_files_traffic_stops
rename V433 comp_files_use_of_force
rename V434 comp_files_warrants
rename V435 comp_files_none_of_above
rename V436 comp_files_all_of_above

* incorrectly 0 for "all of the above" boxes
foreach var of varlist comp_fc_* {
	replace `var' = 1 if comp_fc_all_of_above == 1
}

* incorrectly 0 for "all of the above" boxes
foreach var of varlist comp_files_* {
	replace `var' = 1 if comp_files_all_of_above == 1
}

rename V437 early_intervention_system

*** 2003 | SECTION VIII: POLICIES AND PROCEDURES ***
rename V438 direc_deadly_force
rename V439 direc_non_lethal_force
rename V440 direc_code_of_conduct
rename V441 direc_off_duty_empl
rename V442 direc_max_work_hours
rename V443 direc_mentally_ill
rename V444 direc_homeless
rename V445 direc_dom_abuse
rename V446 direc_juveniles
rename V447 direc_strip_search
rename V448 direc_racial_profiling
rename V449 direc_citizen_compl
rename V450 direc_off_duty_conduct
rename V451 direc_media_interactions
rename V452 direc_empl_counseling
rename V453 pursuit_driving_policy_desc
rename V455 use_of_force_total_complaints
rename V456 use_of_force_unfounded
rename V457 use_of_force_exonerated
rename V458 use_of_force_not_sust
rename V459 use_of_force_sustained
rename V460 use_of_force_pending
rename V461 use_of_force_other_disp
rename V455F use_of_force_total_complaints_f
rename V456F use_of_force_unfounded_flag
rename V457F use_of_force_exonerated_flag
rename V458F use_of_force_not_sust_flag
rename V459F use_of_force_sustained_flag
rename V460F use_of_force_pending_flag
rename V461F use_of_force_other_disp_flag
rename V462 cit_review_board
rename V463 cit_review_board_sub_power
rename V464 rev_exc_force_outside_chain
rename V465 exc_force_final_resp_chief
rename V466 exc_force_final_resp_sworn
rename V467 exc_force_final_resp_govt_exec
rename V468 exc_force_final_resp_other
rename V470 exc_force_appeal_citizen
rename V471 exc_force_appeal_officers

* 2003 | OTHER
rename WEIGHT weight

* dropping for merge
* temporary fix, may correct later 
drop exc_force_final_resp_other

order county_fips

* making agency_type match across time, keeping old variation 
rename agency_type agency_type_old 
gen agency_type = .
replace agency_type = 1 if agency_type_old==2 | agency_type_old==3 | agency_type_old==6 | agency_type_old==7 | agency_type_old==8 | agency_type_old==9
replace agency_type = 2 if agency_type_old==1
replace agency_type = 3 if agency_type_old==5

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2003_renamed.dta", replace

*** 2007 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_2007.dta", replace

* 2007: survey_id response_type multi_force_gang_off_flag multi_force_hum_traf_off_flag multi_force_terr_off_flag weight_final_p1 weight_final_p2plus 

gen year=2007
order year

rename SURVEYID survey_id
rename FORMTYPE form_type
rename RESPTYPE response_type
rename AGCYTYPE agency_type
rename AGENCY agency_name
rename CITY city
rename STATE state
rename ZIPCODE zip

*** 2007 | SECTION I: DESCRIPTIVE INFORMATION ***
rename SWNAUTHEMP auth_sworn_ft
rename SWNFTEMP staff_sworn_w_arrest_ft
rename SWNPTEMP staff_sworn_w_arrest_pt
rename CIVFTEMP staff_nonsworn_ft
rename CIVPTEMP staff_nonsworn_pt
rename TOTFTEMP staff_total_ft
rename TOTPTEMP staff_total_pt
* for some reason, LEMAS_2007 only gives part of the table, pulling missing complementary numbers
gen staff_sworn_wo_arrest_ft = staff_total_ft - staff_nonsworn_ft - staff_sworn_w_arrest_ft
gen staff_sworn_wo_arrest_pt = staff_total_pt - staff_nonsworn_pt - staff_sworn_w_arrest_pt
gen staff_sworn_ft = staff_sworn_w_arrest_ft + staff_sworn_wo_arrest_ft
gen staff_sworn_pt = staff_sworn_w_arrest_pt + staff_sworn_wo_arrest_pt
rename FTRESERVESWN reserve_off_sworn_ft
rename PTRESERVESWN reserve_off_sworn_pt
rename FTRESERVECIV reserve_off_nonsworn_ft
rename PTRESERVECIV reserve_off_nonsworn_pt
rename FTGANGOFF multi_force_gang_off_ft
rename PTGANGOFF multi_force_gang_off_pt
rename FTDRUGOFF multi_force_drug_off_ft
rename PTDRUGOFF multi_force_drug_off_pt
rename FTTERROFF multi_force_terr_off_ft
rename PTERROFF multi_force_terr_off_pt
rename FTHUMTRFOFF multi_force_hum_traf_off_ft
rename PTHUMTRFOFF multi_force_hum_traf_off_pt
rename NUMRESPOFF ft_resp_officers
rename NUMCPO performs_community_policing
rename NUMSRO school_resource_officer
rename NUMPATR ft_prim_patrol
rename NUMINVST ft_prim_detective
rename NUMJAIL ft_prim_jail
rename NUMCRTSEC ft_prim_court_sec
rename NUMPROCSERV ft_prim_serving
rename OPBUDGET total_op_budget
rename OPBUDGEST total_op_budget_flag
rename DRUGFORF drug_asset_forf_tot_value
rename GAMBFORF gamb_asset_forf_tot_value
rename OTHRFORF oth_asset_forf_tot_value
rename ASFOREST any_asset_forf_est

*** 2007 | SECTION II: PERSONNEL ***
rename MINEDUC educ_recruit_req
rename EDREQEXM educ_recruit_exceptions
rename BACKGRND off_screen_background
rename CREDHIS off_screen_credit_check
rename CRIMHIS off_screen_crim_record
rename DRIVHIS off_screen_driving_record
rename INTERVW off_screen_interview
rename PERSTEST off_screen_personality_inv
rename POLYEXAM off_screen_poly
rename PSYCHEVAL off_screen_psych
rename VOICESTRESS off_screen_voice_analyzer
rename WRITAPTEST off_screen_apt_test
rename ANPROBSOLV off_screen_problem_solving
rename CULTDIV off_screen_cultural_underst
rename CONFMGT off_screen_mediation_skills
rename SECLANG off_screen_second_lang_test
rename VOLHIS off_screen_volunteer_hist
rename DRUGTEST off_screen_drug_test
rename MEDEXAM off_screen_med_exam
rename PHYSTEST off_screen_physical_test
rename TOTACAD new_off_train_class_hrs
rename TOTFIELD new_off_train_field_hrs
rename TOTINSRV po_training_hours
rename WHITE sworn_white_total
rename BLACK sworn_black_total
* dropping detailed demographic vars
drop HISPANIC ASIAN NATHAW AMERIND MULTRACE UNKRACE
rename MALE sworn_males
rename FEMALE sworn_females
rename TOTGENDER sworn_gender_total
rename SWNBILING sworn_bilingual
rename CIVBILING nonsworn_bilingual
rename SWNINTERP interpretors_sworn
rename CIVINTERP interpretors_nonsworn
rename VOLINTERP interpretors_volunteer
rename CONINTERP interpretors_contractor
rename OTHINTERP interpretors_other
rename INTERPDESC interpretors_other_entry
rename EDUCPAY pay_ed_incentive
rename HAZARDPAY pay_hazard
rename MERITPAY pay_merit
rename SHIFTPAY pay_shift_diff
rename SKILLPAY pay_special_skills
rename LANGPAY pay_bilingual
rename TUITIONPAY pay_tuition_reimb
rename MILPAY pay_military_service
rename COLLBARG allows_coll_bargain
rename RESPAY pay_resid_incent
rename CHIEFMIN salary_chief_min
rename CHIEFMAX salary_chief_max
rename SGTMIN salary_sgt_min
rename SGTMAX salary_sgt_max
rename ENTRYMIN salary_entry_min
rename ENTRYMAX salary_entry_max

*** 2007 | SECTION III: OPERATIONS ***
rename OPER911 operational_911_detail
rename NUMWIRE operational_911_caller_id
rename EXACTLOC operational_911_caller_loc_ex
rename GENLOC operational_911_caller_loc_gen
gen operational_911 = 0 if operational_911_detail == 0
replace operational_911 = 1 if operational_911_detail==1 | operational_911_detail==2

rename CARPAT patrol_auto
rename MOTOPAT patrol_motorcycle
rename FOOTPAT patrol_foot
rename AIRPAT patrol_aviation
rename BOATPAT patrol_marine
rename HORSEPAT patrol_horse
rename BIKEPAT patrol_bicycle
rename SEGPAT patrol_segway
rename OTHERPAT patrol_other
rename OTHPATDESC patrol_other_entry

*** 2007 | SECTION IV: COMMUNITY POLICING ***
rename CPTRNNEW comm_pol_training_recruits
rename CPTRNINSERV comm_pol_training_sworn
rename CPMISSION mission_statement_inc_comm_pol
rename CPSARA encourage_SARA
rename CPSARANUM encourage_SARA_pct
rename CPACADEMY conduct_cit_academy
rename CPPLAN comm_pol_plan
rename CPGEO geographic_patrol_beats
rename CPGEONUM geographic_patrol_beats_pct
rename CPPROBSOLV collab_problem_solving_criteria
rename CPTECHUP comm_pol_tech_upgrade
rename CPPARTNER problem_solving_partnerships
rename CPSURVEY survey_crime_fear_satis
rename CPUNIT comm_pol_unit
rename CPNONE no_comm_pol_activities
rename ADVGRP meetings_advocacy_groups
rename BUSGRP meetings_business_groups
rename FAITHORG meetings_religious_groups
rename LOCGOVT meetings_local_public_ag
rename OTHLOCLEA meetings_other_lea_groups
rename NEIGHASC meetings_nbhd_assoc
rename SENIORGRP meetings_senior_cit
rename SCHOOLGRP meetings_school_groups
rename YOUTHSERV meetings_youth_service
rename EMAILMRKT cit_contact_email
rename WEBFEEDBACK cit_contact_web_feedback
rename WEBMAPS cit_contact_web_maps
rename WEBSTATS cit_contact_web_stats
rename LISTSERV cit_contact_listserv
rename REV911NOT cit_contact_rev_911
rename MASSNOTNUM cit_contact_mass_comm
rename NONEM311 cit_contact_311
rename EREPORTING cit_contact_elect_report
rename ECRIMEREP cit_contact_email_crime_rep
rename OTHRCP cit_contact_other

*** 2007 | SECTION V: EMERGENCY PREPAREDNESS ***
rename TERRPLAN terrorist_plan
rename INTEROP shared_radio_network
rename TERRPREPDIV terrorist_prep_comm_partner
rename TERRPREPFEAR terrorist_prep_anti_fear
rename TERPREPINFO terrorist_prep_dissemination
rename TERRPREPMEET terrorist_prep_comm_meetings
rename TERRPREPINCR terrorist_prep_crit_areas
rename TERRPREPEXER terrorist_prep_emprep_ex
rename OTHTERRPREP terrorist_prep_other
rename TERRPREPDESC terrorist_prep_other_entry
rename SWNINTEL ft_prim_terr_intel_sworn
rename CIVINTEL ft_prim_terr_intel_nonsworn

*** 2007 | SECTION VI: EQUIPMENT ***
rename SEMIPRIM auth_semi_primary
rename SEMIBACK auth_semi_backup
rename PRIM10MM auth_semi_10m_primary
rename BACK10MM auth_semi_10m_backup
rename PRIM9MM auth_semi_9m_primary
rename BACK9MM auth_semi_9m_backup
rename PRIM45 auth_semi_45_primary
rename BACK45 auth_semi_45_backup
rename PRIM40 auth_semi_40_primary
rename BACK40 auth_semi_40_backup
rename PRIM357 auth_semi_357_primary
rename BACK357 auth_semi_357_backup
rename PRIM380 auth_semi_380_primary
rename BACK380 auth_semi_380_backup
rename PRIMOTHCAL auth_semi_other_primary
rename BACKOTHCAL auth_semi_other_backup
rename PRIMANYSEMI auth_semi_any_primary
rename BACKANYSEMI auth_semi_any_backup
rename REVOPRIM auth_rev_primary
rename REVOBACK auth_rev_backup
rename NOBACKUP auth_no_backup
rename ASSLTWEAP auth_secondary_ar
rename SHOTGUN auth_secondary_shotgun
rename CARBINE auth_secondary_carbine
rename RIFLE auth_secondary_rifle
rename OTHSECWP auth_secondary_other
rename NOSECGUN auth_secondary_none
rename ARMORREQ bodyarmor_po_req
rename NUMDOGS dogs
rename NUMHORSES horses
rename TRADBATON auth_impact_baton
rename PR24BATON auth_impact_baton_pr24
rename COLLBATON auth_impact_baton_cllpsbl

gen auth_baton=0
replace auth_baton=1 if (auth_impact_baton==1 | auth_impact_baton_pr24==1 | auth_impact_baton_cllpsbl==1)

rename SOFTPROJ auth_impact_soft_proj
rename BLACKJACK auth_impact_blackjack
rename RUBBULLET auth_impact_rubber_bullet
rename OTHIMP auth_impact_other
rename OTHIMPDESC auth_impact_other_entry
rename OCPEPPER auth_chem_agent_pepper
rename OTHCHEM auth_chem_agent_other
rename OTHCHEMDESC auth_chem_agent_other_entry
rename CED auth_elec_dev
rename NECKHOLD auth_neck_hold
rename OTHNONLETH auth_actions_other
rename OTHACTDESC auth_actions_other_entry
rename DIGPRINTS dig_imaging_prints
rename DIGFACEREG dig_imaging_facial_recog
rename DIGMUGSHOT dig_imaging_mugshots
rename DIGPHOTO dig_imaging_photography
rename DIGCOMP dig_imaging_composites
rename DIGNONE dig_imaging_none_of_above
rename INFRARED night_vis_infrared
rename GOGGLES night_vis_goggles
rename IMAGEINT night_vis_image_intensifier
rename LPREADER night_vis_lic_plate_reader
rename LASERRANGE night_vis_laser_rangefinder
rename OPTICNONE night_vis_none_of_above
rename ENGDISRUPT veh_stop_engine_disrupt
rename TIREDEFLATE veh_stop_roadspikes
rename VEHTRACK veh_stop_lojack
rename NOVEHSTOP veh_stop_none_of_above
rename NUMMRKCARS vehicles_marked_cars
rename NUMOTHMRK vehicles_marked_other
rename NUMUMKCARS vehicles_unmarked_cars
rename NUMOTHUNM vehicles_unmarked_other
rename NUMPLANES vehicles_aircraft
rename NUMCOPTERS vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename NUMBOATS vehicles_boats
rename NUMMOTOR vehicles_2_wheel
rename TAKEHOME marked_take_home
rename PERSUSE marked_off_duty_use
rename OUTSIDEJUR marked_outside_juris_use
rename VIDCAM cameras_used
rename NUMCARCAM cameras_patrol_car
rename NUMFIXCAM cameras_fixed_surv
rename NUMMOBCAM cameras_mobile_surv
rename SHOTSENSOR gunshot_detection_sensors

*** 2007 | SECTION VII: COMPUTERS AND INFORMATION SYSTEMS ***
rename COMCOMMPROB comp_fc_community_problems
rename COMBOOKING comp_fc_booking
rename COMCRIMANL comp_fc_analysis
rename COMCRIMEMAP comp_fc_crime_mapping
rename COMINVEST comp_fc_investigations
rename COMCAD comp_fc_dispatch
rename COMFLEET comp_fc_fleet_mgmt
rename COMHOTSPOT comp_fc_hotspot_id
rename COMINFCOMM comp_fc_in_field_comms
rename COMINFWRIT comp_fc_in_field_reports
rename COMINTEL comp_fc_gathering_intel
rename COMINFOSHAR comp_fc_sharing_info
rename COMINTERNET comp_fc_internet_access
rename COMPERSREC comp_fc_personnel_records
rename COMRECMAN comp_fc_records
rename COMRESALLO comp_fc_resource_alloc
rename COMNONE comp_fc_none_of_above
rename ALARMFILES comp_files_alarms
rename ARRESTFILES comp_files_arrests
rename BIOMETFILES comp_files_facial_recog
rename CFSFILES comp_files_calls
rename CMPLNTFILES comp_files_complaints
rename PRINTFILES comp_files_prints
rename INCREPFILES comp_files_incident_report
rename GUNFILES comp_files_firearms
rename INTELFILES comp_files_terrorism
rename PROPFILES comp_files_stolen_prop
rename SUMMFILES comp_files_summons
rename TRAFCITFILES comp_files_citations
rename TRAFSTOPFILES comp_files_traffic_stops
rename USEFORCEFILES comp_files_use_of_force
rename WARRANTFILES comp_files_warrants
rename GANGFILES comp_files_gangs
rename PAWNFILES comp_files_pawn_shops
rename PROTORDFILES comp_files_prot_orders
rename NONEFILES comp_files_none_of_above
rename USEINFCOM comp_field_use
rename NUMPERM comp_car_mounted_num
rename NUMDOCK comp_port_veh_dock_num
rename NUMPORT comp_port_non_veh_dock_num
rename MVRECACC field_access_veh_records
rename DRIVRECACC field_access_driving_records
rename CRIMRECACC field_access_crim_hist
rename WARRRANTACC field_access_warrants
rename PROTORDACC field_access_protection_ord
rename INFOSHARACC field_access_int_agency_files
rename ADDRINFOACC field_access_service_call
rename WEBACC field_access_internet
rename GISMAPACC field_access_mapping_prog
rename OTHERACC field_access_other
rename OTHACCDESC field_access_other_entry
rename TRANSMIT data_transfer_criminal_inc
rename AFISOWNER afis_ownership
rename AFISTERM afis_remote
rename AFISOTHER afis_access
rename AFISNONE afis_none
rename EARLYWARN early_intervention_system

*** 2007 | SECTION VIII: SPECIAL PROBLEMS/TASKS ***
rename AUTOUNIT spu_auto_theft
rename BIASUNIT spu_hate_crimes
rename BOMBUNIT spu_bomb_disposal
rename CHILDUNIT spu_child_abuse
rename CRPREVUNIT spu_nbhd_crime_prev
rename CRIMANUNIT spu_crime_analysis
rename CYBERUNIT spu_cybercrime
rename DVUNIT spu_dom_abuse
rename DRUGEDUNIT spu_drug_educ
rename FINCRMUNIT spu_fin_crimes
rename DRUGENFUNIT drug_unit
rename GANGUNIT spu_gangs
rename DUIUNIT spu_impaired_drivers
rename INTAFFUNIT spu_internal_affairs
rename JUVCRMUNIT spu_juvenile_delinq
rename METHUNIT spu_meth_labs
rename MISCHDUNIT spu_missing_child
rename REPOFFUNIT spu_career_crim
rename RESPLANUNIT spu_research_planning
rename SCHSAFEUNIT spu_school_safety
rename TERRHOMEUNIT spu_terrorism
rename VICTASSTUNIT spu_victim_assist

*** 2007 | SECTION IX: POLICIES AND PROCEDURES ***
rename DEADFORCPLCY direc_deadly_force
rename LESSTHANPLCY direc_non_lethal_force
rename CODECONDPLCY direc_code_of_conduct
rename OFFDEMPLPLCY direc_off_duty_empl
rename MAXHOURSPLCY direc_max_work_hours
rename OFFDCONDPLCY direc_off_duty_conduct
rename MEDIAPLCY direc_media_interactions
rename EAPPLCY direc_empl_counseling
rename MENTILLPLCY direc_mentally_ill
rename HOMELESSPLCY direc_homeless
rename DOMDISPPLCY direc_dom_abuse
rename JUVENILEPLCY direc_juveniles
rename LIMITENGPLCY direc_limited_eng
rename INCUSDTHPLCY direc_custody_deaths
rename RACIALPRPLCY direc_racial_profiling
rename CITCOMPPLCY direc_citizen_compl
rename IMMSTATPLCY direc_immig_status
rename NUMUOFSUST use_of_force_sustained
rename NUMUOFOTH use_of_force_other_disp
rename NUMUOFPEND use_of_force_pending
rename NUMUOFTOT use_of_force_total_complaints
rename CCRB cit_review_board
rename CCRBPOWERS cit_review_board_sub_power
rename OUTSIDEINV rev_exc_force_outside_chain

*** 2007 | OTHER ***
rename IMPBUDGET total_op_budget_imputed
rename IMPTRNACD new_off_train_class_hrs_flag
rename IMPTRNFLD new_off_train_field_hrs_flag
rename IMPTRNINS po_training_hours_flag
rename IMPCHFMIN salary_chief_min_flag
rename IMPCHFMAX salary_chief_max_flag
rename IMPSGTMIN salary_sgt_min_flag
rename IMPSGTMAX salary_sgt_max_flag
rename IMPENTRYMIN salary_entry_min_flag
rename IMPENTRYMAX salary_entry_max_flag
rename IMPGENDER sworn_gender_total_flag
rename IMPRACE sworn_race_total_flag
rename IMPSWNINTEL ft_prim_terr_intel_sworn_flag
rename IMPCIVINTEL ft_prim_terr_intel_nonsworn_flag
rename IMPCARCAM cameras_patrol_car_flag
rename IMPSITECAM cameras_fixed_surv_flag
rename IMPMOBLCAM cameras_mobile_surv_flag
rename IMPMARKED vehicles_marked_cars_flag
rename IMPOTHMKD vehicles_marked_other_flag
rename IMPUNMARKED vehicles_unmarked_cars_flag
rename IMPOTHUNMKD vehicles_unmarked_other_flag
rename IMPMOTOS vehicles_2_wheel_flag
rename IMPBOATS vehicles_boats_flag
rename IMPPLANES vehicles_aircraft_flag
rename IMPCOPTERS vehicles_helicopters_flag
rename IMPMOUNTED comp_car_mounted_num_flag
rename IMPDOCKING comp_port_veh_dock_num_flag
rename IMPNONDOCK comp_port_non_veh_dock_num_flag
rename IMPSARA encourage_SARA_pct_flag
rename IMPGEOG geographic_patrol_beats_pct_flag
rename IMPDRUGTASK multi_force_drug_off_flag
rename IMPGANGTASK multi_force_gang_off_flag
rename IMPHUMNTASK multi_force_hum_traf_off_flag
rename IMPTERRTASK multi_force_terr_off_flag
rename IMPCELL imputation_cell
* FOUND THE LINKING VARIABLE: ori_7
rename ORI ori_7
gen ori_9 = ori_7 + "00" if ori_7 != ""

rename CSLLEA04_ID csllea_2004_id
rename POPULATION population
rename LPDSAMPGRP stratum
rename FINALWT_PAGE1 weight_final_p1
rename FINALWT_PAGE2ON weight_final_p2plus

order ori_9

* making agency_type match across time, keeping old variation 
rename agency_type agency_type_old 
gen agency_type=.
replace agency_type = 1 if agency_type_old == 3
replace agency_type = 2 if agency_type_old == 1
replace agency_type = 3 if agency_type_old == 5

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2007_renamed.dta", replace

*** 2013 ***
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_2013.dta", replace

* 2013: agency_id_new stratum_desc 

gen year=2013
order year

rename ORI7 ori_7
rename ORI9 ori_9
replace ori_9 = ori_7+"00" if ori_9=="" & ori_7!=""
rename SHERIFF_FLAG sheriff_flag
rename TYPE agency_type
destring agency_type, replace
rename TRIBALPD tribal_pd
rename COUNTYPD county_pd
rename AGENCYID agency_id_new
rename BJS_AGENCYNAME agency_name
rename CITY city
rename STATENAME state
rename STATECODE state_abbr
rename ZIPCODE zip
rename POP2012 population
rename SAMPLETYPE_FINAL  stratum_desc
rename STRATCODE stratum

*** 2013 | SECTION A: PERSONNEL ***
rename FTSWORN staff_sworn_ft
rename FTCIV staff_nonsworn_ft
rename PTSWORN staff_sworn_pt
rename PTCIV staff_nonsworn_pt
rename PERS_PDSW_MFT sworn_males_ft
rename PERS_PDSW_MPT sworn_males_pt
gen sworn_males = sworn_males_ft + sworn_males_pt
rename PERS_PDSW_FFT sworn_females_ft
rename PERS_PDSW_FPT sworn_females_pt
gen sworn_females = sworn_females_ft + sworn_females_pt
rename PERS_FTS_WHT sworn_white_total_ft
rename PERS_FTS_BLK sworn_black_total_ft
* dropping detailed demographic vars, cumbersome 
drop PERS_FTS_HSP PERS_FTS_IND PERS_FTS_ASN PERS_FTS_HAW PERS_FTS_TWO PERS_FTS_UNK
rename PERS_FTS_RACETOT sworn_race_total
rename PERS_RESP_PATRL ft_prim_patrol
rename PERS_RESP_INVST ft_prim_detective
rename PERS_RESP_JAIL ft_prim_jail
rename PERS_RESP_CRT ft_prim_court_sec
rename PERS_RESP_OTHR ft_prim_other
rename PERS_SUP_CHF_M sworn_chief_males
rename PERS_SUP_CHF_F sworn_chief_females
rename PERS_SUP_INTM_M sworn_int_supervisor_males
rename PERS_SUP_INTM_F sworn_int_supervisor_females
rename PERS_SUP_SGT_M sworn_sgt_males
rename PERS_SUP_SGT_F sworn_sgt_females
rename PERS_SSW_FT sworn_seasonal_ft
rename PERS_SSW_PT sworn_seasonal_pt
rename PERS_UPSW reserve_off_sworn_unpaid
drop PERS_DUT_NONE PERS_DUT_ADMN PERS_DUT_CLN PERS_DUT_LGL PERS_DUT_ACCT PERS_DUT_FSCI PERS_DUT_RSRCH PERS_DUT_HR PERS_DUT_IT PERS_DUT_VM PERS_DUT_CD PERS_DUT_CRT PERS_DUT_JAIL PERS_DUT_OTHR PERS_DUT_SPEC

*** 2013 | SECTION B: PAY AND BENEFITS ***
rename PAY_SAL_EXC_MIN salary_chief_min
rename PAY_SAL_EXC_MAX salary_chief_max
rename PAY_SAL_SGT_MIN salary_sgt_min
rename PAY_SAL_SGT_MAX salary_sgt_max
rename PAY_SAL_OFCR_MIN salary_entry_min
rename PAY_SAL_OFCR_MAX salary_entry_max
rename PAY_INCT_EDU pay_ed_incentive
rename PAY_INCT_VOC pay_special_skills
rename PAY_INCT_LANG pay_bilingual
rename PAY_INCT_SPCL pay_special_duty
rename PAY_INCT_HZRD pay_hazard
rename PAY_INCT_SD pay_shift_diff
rename PAY_INCT_RINC pay_resid_incent
rename PAY_INCT_MRT pay_merit
rename PAY_INCT_OTHR pay_other
rename PAY_RMB_TUIT pay_tuition_reimb

foreach var of varlist pay_* {
	replace `var' = 0 if `var'==2
}

rename PAY_INCT_SPEC pay_other_entry
rename PAY_OUT outside_work_allowed
rename PAY_RST_NO outside_work_restr_none
rename PAY_RST_HRS outside_work_restr_hours
rename PAY_RST_TYPE outside_work_restr_type
rename PAY_RST_OTHR outside_work_restr_other
rename PAY_RST_SPEC outside_work_restr_other_entry
rename PAY_BARG has_coll_bargain
rename PAY_SBARG coll_bargain_status
rename PAY_RMB_UNF uniforms_supplied_or_paid
rename PAY_RMB_ARMR bodyarmor_supplied_or_paid
rename PAY_RMB_SFTY safety_eq_other_supplied_or_paid
rename PAY_RMB_FIRE temp_sidearm_supplied_or_paid
gen sidearm_supplied_or_paid = (temp_sidearm_supplied_or_paid==1)
drop temp_*
rename PAY_OVER_SW ot_paid_sworn
rename PAY_OVER_NSW ot_paid_nonsworn
rename PAY_FUNC_CRT ot_auth_court_testimony
rename PAY_FUNC_SHFT ot_auth_ext_shifts
rename PAY_FUNC_PTRL ot_auth_incr_patrols
rename PAY_FUNC_INVS ot_auth_investigations
rename PAY_FUNC_ADMN ot_auth_admin_duties
rename PAY_FUNC_EMRG ot_auth_emergency_resp
rename PAY_FUNC_EVNT ot_auth_special_events
rename PAY_FUNC_OTHR ot_auth_other
rename PAY_FUNC_SPEC ot_auth_other_entry
rename PAY_LMT ot_hours_limited
rename PAY_VEH_MRK marked_take_home_detail
gen marked_take_home = 0 if marked_take_home_detail==3

replace marked_take_home = 1 if marked_take_home_detail==1 | marked_take_home_detail==2

rename PAY_VEH_UMRK unmarked_take_home

*** 2013 | SECTION C: HIRES AND SEPARATIONS ***
rename HIR_FRZ hiring_freeze
rename HIR_MTH_SW10 hiring_freeze_sworn_2010
rename HIR_MTH_SW11 hiring_freeze_sworn_2011
rename HIR_MTH_SW12 hiring_freeze_sworn_2012
rename HIR_MTH_NSW10 hiring_freeze_nonsworn_2010
rename HIR_MTH_NSW11 hiring_freeze_nonsworn_2011
rename HIR_MTH_NSW12 hiring_freeze_nonsworn_2012
rename HIR_NBR sworn_hires_none
rename HIR_NBR_DRCT_FT ft_sworn_hires_direct
rename HIR_NBR_DRCT_PT pt_sworn_hires_direct
rename HIR_NBR_PRE_FT ft_sworn_hires_pre_serv
rename HIR_NBR_PRE_PT pt_sworn_hires_pre_serv
rename HIR_NBR_LAT_FT ft_sworn_hires_lateral
rename HIR_NBR_LAT_PT pt_sworn_hires_lateral
rename HIR_NBR_TFT ft_sworn_hires_total
rename HIR_NBR_TPT pt_sworn_hires_total
rename HIR_TRN_NO_L hire_train_lateral_none
rename HIR_TRN_NO_P hire_train_pre_serv_none
rename HIR_TRN_CRS_L hire_train_lateral_abbr_class
rename HIR_TRN_CRS_P hire_train_pre_serv_abbr_class
rename HIR_TRN_FLD_L hire_train_lateral_abbr_field
rename HIR_TRN_FLD_P hire_train_pre_serv_abbr_field
rename HIR_TRN_DIR_L hire_train_lateral_as_direct
rename HIR_TRN_DIR_P hire_train_pre_serv_as_direct
rename HIR_TRN_OLATS hire_train_lateral_other
rename HIR_TRN_OPRES hire_train_pre_serv_other
rename HIR_NSWT_NO nonsworn_hires_none
rename HIR_NSWT_VAR_FT nonsworn_hires_ft
rename HIR_NSWT_VAR_PT nonsworn_hires_pt
rename HIR_EDU_NO educ_recruit_none
rename HIR_EDU_HS educ_recruit_hs
rename HIR_EDU_SCOL educ_recruit_some_coll
rename HIR_EDU_AD educ_recruit_assoc_deg
rename HIR_EDU_BD educ_recruit_bach_deg
rename HIR_EDU_OTHR educ_recruit_other
rename HIR_MIL educ_recruit_military_replace
rename HIR_BD_VAR hire_ft_bach_deg
rename HIR_RTR_DB retire_defined_ben
rename HIR_RTR_DC retire_defined_contr
rename HIR_RTR_SS retire_social_sec
rename HIR_RTR_OTHR retire_other
rename HIR_SEP_NMED ft_sworn_sep_retirement
rename HIR_SEP_MED ft_sworn_sep_disability
rename HIR_SEP_VOL ft_sworn_sep_resignations
rename HIR_SEP_LAYOFF ft_sworn_sep_layoffs
rename HIR_SEP_DIS ft_sworn_sep_dismissals
rename HIR_SEP_OTHR ft_sworn_sep_other
rename HIR_SEP_TTL ft_sworn_sep_total
rename HIR_SEPNS_LAYOFF nonsworn_sep_layoffs
rename HIR_SEPNS_OTHR nonsworn_sep_other
rename HIR_SEPNS_TTL nonsworn_sep_total

*** 2013 | SECTION D: BUDGET AND FISCAL ISSUES ***
rename BDGT_MNTH fiscal_start_month
rename BDGT_TTL total_op_budget
rename BDGT_TTL_EST total_op_budget_flag
rename BDGT_SRC_MNC funding_source_govt_mun
rename BDGT_SRC_CNTY funding_source_govt_county
rename BDGT_SRC_STATE funding_source_govt_state
rename BDGT_SRC_FED funding_source_govt_fed
rename BDGT_SRC_CONT funding_source_contr_service
rename BDGT_SRC_ASST funding_source_asset_forf
rename BDGT_SRC_FEE funding_source_user_fees
rename BDGT_SRC_OTHR funding_source_other
rename BDGT_SRC_SPEC funding_source_other_entry
rename BDGT_RED salary_reductions
rename BDGT_PCT_SW salary_reductions_sworn_pct
rename BDGT_PCT_NSW salary_reduction_nonsworn_pct
rename BDGT_FUR furlough
rename BDGT_FUR2_SW10 furlough_sworn_2010
rename BDGT_FUR2_SW11 furlough_sworn_2011
rename BDGT_FUR2_SW12 furlough_sworn_2012
rename BDGT_FUR2_NSW10 furlough_nonsworn_2010
rename BDGT_FUR2_NSW11 furlough_nonsworn_2011
rename BDGT_FUR2_NSW12 furlough_nonsworn_2012

*** 2013 | SECTION E: COMMUNITY POLICING ***
rename COM_MIS mission_statement_inc_comm_pol
rename COM_TRN_REC comm_pol_training_recruits
rename COM_TRN_INSRV comm_pol_training_sworn
rename COM_SARA encourage_SARA
rename COM_NSARA encourage_SARA_num
rename COM_COL collab_problem_solving_criteria
rename COM_PTNR problem_solving_partnerships
rename COM_BT geographic_patrol_beats
rename COM_NBT geographic_patrol_beats_num
rename COM_SURV survey_crime_fear_satis

*** 2013 | SECTION F: TECHNOLOGY AND INFORMATION SYSTEMS ***
rename TECH_TYP_GUN gunshot_detection_sensors
rename TECH_TYP_LIC night_vis_lic_plate_reader
rename TECH_TYP_SMRT tech_smartphones
rename TECH_TYP_VPUB cameras_public_surv
rename TECH_TYP_VVEH cameras_patrol_car
rename TECH_TYP_VPAT cameras_patrol_off
rename TECH_TYP_VWPN cameras_weapons
rename TECH_TYP_VOTHR cameras_other
rename TECH_EAC_MREC field_access_veh_records
rename TECH_EAC_DREC field_access_driving_records
rename TECH_EAC_CRIM field_access_crim_hist
rename TECH_EAC_WARR field_access_warrants
rename TECH_EAC_PROT field_access_protection_ord
rename TECH_EAC_ADRS field_access_service_call
rename TECH_CIR data_transfer_criminal_inc

rename TECH_CRS comp_files_cr_inc
rename TECH_CREC_INC comp_files_cr_inc_type_stats_rec
rename TECH_CREC_SUM comp_files_cr_inc_type_sum_stats
rename TECH_CREC_NAR comp_files_cr_inc_type_off_narr
rename TECH_CREC_OTHR comp_files_cr_inc_type_oth
rename TECH_REC_NAR comp_files_cr_inc_narr_desc
rename TECH_REC_CODE comp_files_cr_inc_off_code
rename TECH_REC_STAT comp_files_cr_inc_statutes
rename TECH_REC_VIC comp_files_cr_inc_victim_char
rename TECH_REC_SUS comp_files_cr_inc_susp_char
rename TECH_REC_LOC comp_files_cr_inc_location
rename TECH_REC_GEO comp_files_cr_inc_geo_address
rename TECH_REC_DATE comp_files_cr_inc_date_time

la define no0yes1 0 "No" 1 "Yes"
foreach var of varlist comp_files_* {
	replace `var'=0 if `var'==2
	la values `var' no0yes1
}

rename TECH_CREC_SPEC comp_files_cr_inc_type_oth_entry

rename TECH_WHO_NO who_research_none
rename TECH_WHO_STAFF who_research_agency_staff
rename TECH_WHO_EXTR who_research_external_org
rename TECH_MANY_FTS stat_analysis_sworn_ft_num
rename TECH_MANY_PTS stat_analysis_sworn_pt_num
rename TECH_MANY_FTNS stat_analysis_nonsworn_ft_num
rename TECH_MANY_PTNS stat_analysis_nonsworn_pt_num
rename TECH_OUT_LAW stat_analysis_outside_lea
rename TECH_OUT_GOV stat_analysis_outside_govt
rename TECH_OUT_UNIV stat_analysis_outside_univ
rename TECH_OUT_VEND stat_analysis_outside_commercial
rename TECH_OUT_OTHR stat_analysis_outside_other
rename TECH_WEB_NONE website_none
rename TECH_WEB_JUR website_jurisdiction_stats
rename TECH_WEB_BEAT website_beat_stats
rename TECH_WEB_MAP website_map_stats
rename TECH_WEB_OFFND website_sex_off_maps
rename TECH_WEB_OTHR website_other_stats
rename TECH_WEB_SPEC website_other_stats_entry
rename TECH_PUBL_REP website_cit_report_crimes
rename TECH_PUBL_ASK website_cit_questions_feedback
rename TECH_PUBL_FILE website_cit_complaints
rename TECH_PUBL_OTHR website_cit_other
rename TECH_PUBL_SPEC website_cit_other_entry
rename TECH_REPT email_text_crime_reporting
rename TECH_RECV cit_request_electronic_info
rename TECH_MEDIA_TW agency_uses_twitter
rename TECH_MEDIA_FB agency_uses_facebook
rename TECH_MEDIA_BLOG agency_uses_blog
rename TECH_MEDIA_YTBE agency_uses_youtube
rename TECH_MEDIA_MASS agency_uses_mass_comm
rename TECH_MEDIA_OTHR agency_uses_other
rename TECH_MEDIA_SPEC agency_uses_other_entry

*** 2013 | SECTION G: VEHICLES AND PURSUITS ***
rename VEH_OPRT_MK vehicles_marked_cars
rename VEH_OPRT_UNMK vehicles_unmarked_cars
rename VEH_TYP_MTR vehicles_2_wheel
rename VEH_TYP_ATV vehicles_atv
rename VEH_TYP_AIR vehicles_aircraft
rename VEH_TYP_HCOP vehicles_helicopters
* generating heli/aircraft variable, because 2016 does not separate
gen vehicles_heli_aircraft = vehicles_aircraft + vehicles_helicopters
rename VEH_TYP_BOAT vehicles_boats
rename VEH_TYP_DRONE vehicles_drones
rename VEH_TYP_OTHR vehicles_other
rename VEH_TYP_SPEC vehicles_other_entry
rename VEH_WPUR pursuit_driving_policy_desc
rename VEH_DOC pursuit_driving_inc_doc
rename VEH_DOC_SPEC pursuit_driving_inc_doc_entry
rename VEH_NPUR pursuit_driving_num
rename VEH_NPUR_EST pursuit_driving_num_est
rename VEH_NPUR_UNK pursuit_driving_num_unk
rename VEH_REST_NO pursuit_foot_restr_none
rename VEH_REST_ALN pursuit_foot_restr_alone
rename VEH_REST_VISL pursuit_foot_restr_vis_cont
rename VEH_REST_SEPR pursuit_foot_restr_off_sep
rename VEH_REST_RADIO pursuit_foot_restr_radio_loss
rename VEH_REST_ARM pursuit_foot_restr_armed
rename VEH_REST_OTHR pursuit_foot_restr_other
rename VEH_CNTN pursuit_foot_enc_contain

*** 2013 | SECTION H: USE OF FORCE AND OFFICER SAFETY ***
rename SAFE_AUTH_HGN auth_handguns
rename SAFE_AUTH_RFL auth_rifles
rename SAFE_AUTH_SGN auth_shotguns
rename SAFE_AUTH_BTN auth_baton_detail
gen auth_baton = 0 if auth_baton_detail==3
replace auth_baton = 1 if auth_baton_detail==1 | auth_baton_detail==2

rename SAFE_AUTH_IMP auth_impact_other

rename SAFE_AUTH_SOFT auth_impact_soft_proj
rename SAFE_AUTH_SPRAY auth_chem_agent_pepper
rename SAFE_AUTH_CHEM auth_chem_agent_other
rename SAFE_AUTH_TASR auth_elec_dev
rename SAFE_AUTH_NECK auth_neck_hold
rename SAFE_AUTH_TKDWN auth_takedowns
rename SAFE_AUTH_OHAND auth_open_hand
rename SAFE_AUTH_CHAND auth_closed_hand
rename SAFE_AUTH_LEG auth_leg_hobbles
rename SAFE_DOC_DISF req_doc_firearm_display
rename SAFE_DOC_DCHF req_doc_firearm_discharge
rename SAFE_DOC_BAT req_doc_baton
rename SAFE_DOC_IMP req_doc_other_impact
rename SAFE_DOC_SOFT req_doc_soft_proj
rename SAFE_DOC_SPRAY req_doc_pepper_spray
rename SAFE_DOC_CHEM req_doc_other_chem_agent
rename SAFE_DOC_DIST req_doc_elec_dev_display
rename SAFE_DOC_DCHT req_doc_elec_dev_discharge
rename SAFE_DOC_NECK req_doc_neck_hold
rename SAFE_DOC_TKDWN req_doc_takedowns
rename SAFE_DOC_OHAND req_doc_open_hand
rename SAFE_DOC_CHAND req_doc_closed_hand
rename SAFE_DOC_LEG req_doc_leg_hobble
rename SAFE_FINC use_of_force_doc_desc
rename NO_RECORD_FORCE use_of_force_doc_none
rename SAFE_FRC_INC use_of_force_doc_per_inc
rename SAFE_FRC_OFFC use_of_force_doc_per_off
rename SAFE_FRC_OTHR use_of_force_doc_other
rename SAFE_FRC_SPEC use_of_force_doc_other_entry
rename SAFE_FTTL use_of_force_inc_num
rename SAFE_FTTL_EST use_of_force_inc_num_est
rename SAFE_FTTL_UNK use_of_force_inc_num_unk
rename SAFE_SEPR use_of_force_rec_num
rename SAFE_SEPR_EST use_of_force_rec_num_est
rename SAFE_SEPR_UNK use_of_force_rec_num_unk
rename SAFE_ARMR bodyarmor_selector
rename SAFE_RQUR_ACC bodyarmor_po_access_always
rename SAFE_RQUR_RSK bodyarmor_po_req_risky
rename SAFE_RQUR_ALL bodyarmor_po_always
rename SAFE_RQUR_CSTM bodyarmor_custom_fit
rename SAFE_RQUR_TRN bodyarmor_training
rename SAFE_RQUR_COMP bodyarmor_sup_inspect
rename SAFE_RQUR_BLST bodyarmor_nij_std
rename NO_BODY_ARMOR bodyarmor_none
rename SAFE_PAY_DPT bodyarmor_pay_dept
rename SAFE_PAY_IND bodyarmor_pay_off
rename SAFE_PAY_GRNT bodyarmor_pay_grant
rename SAFE_PAY_OTHR bodyarmor_pay_other
rename SAFE_PAY_SPEC bodyarmor_pay_other_entry

*** 2013 | SECTION I: ORGANIZATIONAL RESPONSES TO ISSUES/PROBLEMS ***
rename ISSU_ADDR_BIAS spu_hate_crimes
rename ISSU_ADDR_BOMB spu_bomb_disposal
rename ISSU_ADDR_ABSE spu_child_abuse
rename ISSU_ADDR_CYBR spu_cybercrime
rename ISSU_ADDR_DPV spu_dom_abuse
rename ISSU_ADDR_TERR spu_terrorism
rename ISSU_ADDR_TRAF spu_human_traf
rename ISSU_ADDR_DUI spu_impaired_drivers
rename ISSU_ADDR_JUV spu_juvenile_delinq
rename ISSU_ADDR_GANG spu_gangs_none
rename ISSU_ADDR_REEN spu_reentry_surv
rename ISSU_ADDR_FUG spu_warrants
rename ISSU_ADDR_VIC spu_victim_assist
rename ISSU_ADDR_SWAT spu_swat
rename ISSU_SPEC spu_number
rename ISSU_MULTI multi_force_part
rename ISSU_TASK_SWAT multi_force_swat
rename ISSU_TASK_DRUG multi_force_drug
rename ISSU_TASK_GANG multi_force_gang
rename ISSU_TASK_TRAF multi_force_hum_traf
rename ISSU_TASK_OTHR multi_force_other
rename ISSU_TASK_SPEC multi_force_other_entry

*** 2013 | OTHER ***
rename BASEWT weight_base
rename NRADJUST agency_nonresp_factor
rename FINALWT weight_final

order ori_9 zip

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2013_renamed.dta", replace

*** 2016 *** 
use "2000_data/200_raw/40_LEMAS_raw/LEMAS_2016.dta", replace

* 2016: lear_id weight_final_hire_sep 

gen year=2016
order year

rename LEAR_ID lear_id
rename AGENCYNAME agency_name
rename CITY city
rename ZIPCODE zip
rename STATE state
rename COUNTY county

* county_fips should be a string
rename FIPS temp_county_fips
gen county_fips = string(temp_county_fips, "%05.0f")
replace county_fips = "" if county_fips == "."
drop temp_county_fips

rename ORI9 ori_9
rename POPSERVED population
rename POPGROUP population_categorical
rename AGENCYTYPE agency_type
rename STRATA stratum

*** 2016 | SECTION I: DESCRIPTIVE INFORMATION ***
rename FTSAUTH auth_sworn_ft
rename FTSWORN staff_sworn_ft
rename EDIT_FTSWORN staff_sworn_ft_flag
rename FTLIM staff_sworn_wo_arrest_ft
rename FTNON staff_nonsworn_ft
rename TOTFTEMP staff_total_ft
rename PTSWORN staff_sworn_pt
rename PTLIM staff_sworn_wo_arrest_pt
rename PTNON staff_nonsworn_pt
rename TOTPTEMP staff_total_pt
rename NUMRESPOFF ft_resp_officers
rename NUMCPO performs_community_policing
rename NUMSRO school_resource_officer
rename FTRES_SWN reserve_off_sworn_ft
rename PTRES_SWN reserve_off_sworn_pt
rename FTRES_LIM reserve_off_sworn_ft_lim
rename PTRES_LIM reserve_off_sworn_pt_lim
rename FTRES_NON reserve_off_nonsworn_ft
rename PTRES_NON reserve_off_nonsworn_pt
* dropping detailed staffing vars, cumbersome 
drop ADMIN_SWN FIELD_SWN PATR_SWN DET_SWN TECH_SWN JAIL_SWN COURT_SWN OTHER_SWN ADMIN_LIM FIELD_LIM PATR_LIM DET_LIM TECH_LIM JAIL_LIM COURT_LIM OTHER_LIM ADMIN_NON FIELD_NON PATR_NON DET_NON TECH_NON JAIL_NON COURT_NON OTHER_NON
rename OPBUDGET total_op_budget
rename OPBUDGET_EST total_op_budget_flag
rename EDIT_OPBUDGET total_op_budget_imputed
rename FY_BEGMO fiscal_start_month
rename FY_BEGDAY fiscal_start_day
rename FY_ENDMO fiscal_end_month
rename FY_ENDDAY fiscal_end_day
rename ASSETFOR asset_forfeiture_value
rename ASSETFOR_EST asset_forfeiture_value_est

*** 2016 | SECTION II: PERSONNEL ***
rename PERS_EDU_MIN educ_recruit_req
rename PERS_EDU_HRS educ_recruit_req_hours
rename PERS_MIL educ_recruit_military_replace
rename PERS_CITZN new_off_citizenship
rename PERS_TRN_ACAD new_off_train_class_hrs
rename PERS_TRN_FIELD new_off_train_field_hrs
rename PERS_TRN_INSVC po_training_hours
rename PERS_BACKINV off_screen_background
rename PERS_CREDHIS off_screen_credit_check
rename PERS_CRIMHIS off_screen_crim_record
rename PERS_DRIVHIS off_screen_driving_record
rename PERS_SOCMED off_screen_social_media
rename PERS_INTERVW off_screen_interview
rename PERS_PERSTEST off_screen_personality_inv
rename PERS_POLY off_screen_poly
rename PERS_PSYCH off_screen_psych
rename PERS_VOICE off_screen_voice_analyzer
rename PERS_APTEST off_screen_apt_test
rename PERS_PROBSOLV off_screen_problem_solving
rename PERS_CULTURE off_screen_cultural_underst
rename PERS_CONFLICT off_screen_mediation_skills
rename PERS_DRUG off_screen_drug_test
rename PERS_MED off_screen_med_exam
rename PERS_VISN off_screen_vision_test
rename PERS_PHYS off_screen_physical_test
rename PERS_BILING_SWN bilingual_sworn
rename PERS_BILING_LIM bilingual_sworn_lim
rename PERS_BILING_NON bilingual_nonsworn
rename PERS_NEW_WHT new_hires_white
rename PERS_NEW_BLK new_hires_black
rename PERS_NEW_HSP new_hires_hisp
rename PERS_NEW_IND new_hires_indian
rename PERS_NEW_ASN new_hires_asian
rename PERS_NEW_HAW new_hires_hawaiian
rename PERS_NEW_TWO new_hires_two_plus
rename PERS_NEW_UNK new_hires_unk
rename PERS_NEW_TOTR new_hires_race_total
rename PERS_NEW_MALE new_hires_male
rename PERS_NEW_FEM new_hires_female
rename PERS_NEW_TOTS new_hires_gender_total
rename PERS_SEP_WHT separations_white
rename PERS_SEP_BLK separations_black
rename PERS_SEP_HSP separations_hisp
rename PERS_SEP_IND separations_indian
rename PERS_SEP_ASN separations_asian
rename PERS_SEP_HAW separations_hawaiian
rename PERS_SEP_TWO separations_two_plus
rename PERS_SEP_UNK separations_unk
rename PERS_SEP_TOTR separations_race_total
rename PERS_SEP_MALE separations_male
rename PERS_SEP_FEM separations_female
rename PERS_SEP_TOTS separations_gender_total
rename PERS_WHITE_MALE sworn_white_males
rename PERS_BLACK_MALE sworn_black_males
* dropping detailed demographic vars, cumbersome 
drop PERS_HISP_MALE PERS_AMIND_MALE PERS_ASIAN_MALE PERS_HAWPI_MALE PERS_MULTI_MALE PERS_UNK_MALE PERS_HISP_FEM PERS_AMIND_FEM PERS_ASIAN_FEM PERS_HAWPI_FEM PERS_MULTI_FEM PERS_UNK_FEM
rename PERS_MALE sworn_males
rename PERS_WHITE_FEM sworn_white_females
rename PERS_BLACK_FEM sworn_black_females
rename PERS_FEMALE sworn_females
rename PERS_CHF_SEX chief_sex
rename PERS_CHF_RACE chief_race
rename PERS_SUP_INTM_WH sworn_int_supervisor_white
rename PERS_SUP_INTM_BK sworn_int_supervisor_black
* dropping more detailed demographic vars
drop PERS_SUP_INTM_HS PERS_SUP_INTM_AI PERS_SUP_INTM_AS PERS_SUP_INTM_HA PERS_SUP_INTM_MUL PERS_SUP_INTM_UNK PERS_SUP_SGT_HS PERS_SUP_SGT_AI PERS_SUP_SGT_AS PERS_SUP_SGT_HA PERS_SUP_SGT_MUL PERS_SUP_SGT_UNK
rename PERS_SUP_INTM_TOTR sworn_int_supervisor_race_total
rename PERS_SUP_INTM_MALE sworn_int_supervisor_males
rename PERS_SUP_INTM_FEM sworn_int_supervisor_females
rename PERS_SUP_INTM_TOTS sworn_int_supervisor_gender_tot
rename PERS_SUP_SGT_WH sworn_sgt_white
rename PERS_SUP_SGT_BK sworn_sgt_black
rename PERS_SUP_SGT_TOTR sworn_sgt_race_total
rename PERS_SUP_SGT_MALE sworn_sgt_males
rename PERS_SUP_SGT_FEM sworn_sgt_females
rename PERS_SUP_SGT_TOTS sworn_sgt_gender_total
rename PERS_COLBAR_SWN coll_bargain_sworn
rename PERS_COLBAR_LIM coll_bargain_sworn_lim
rename PERS_COLBAR_NON coll_bargain_nonsworn

*** 2016 | SECTION III: OPERATIONS ***
rename OPER_CFS service_call_total
rename OPER_CFS_EST service_call_total_flag
rename OPER_DIS service_call_disp
rename OPER_DIS_EST service_call_disp_flag

rename OPER_CARPAT patrol_auto
rename OPER_MOTOPAT patrol_motorcycle
rename OPER_FOOTPAT patrol_foot
rename OPER_HORSPAT patrol_horse
rename OPER_BIKEPAT patrol_bicycle
rename OPER_SEGPAT patrol_segway
rename OPER_AIRPAT patrol_aviation
rename OPER_BOATPAT patrol_marine
rename OPER_OTHPAT patrol_other
rename OPER_OTHPAT_FLAG patrol_other_entry
rename OPER_OFFROAD patrol_other_atvs
rename OPER_SNOWMOB patrol_other_snowmob
rename OPER_UAV patrol_other_uav
rename OPER_GOLF patrol_other_golfcart

*** 2016 | SECTION IV: COMMUNITY POLICING ***
rename CP_MISSION mission_statement_inc_comm_pol
rename CP_PLAN written_comm_pol_plan
rename CP_TECH analyze_comm_prob_w_tech
rename CP_CPACAD conduct_cit_academy
rename CP_TRN_NEW comm_pol_training_recruits
rename CP_TRN_INSRV comm_pol_training_sworn
rename CP_SARA_NUM encourage_SARA_num
rename CP_BEATS_NUM geographic_patrol_beats_num
rename CP_PSP_ADVGRP meetings_advocacy_groups
rename CP_PSP_BUSGRP meetings_business_groups
rename CP_PSP_LEA meetings_other_lea_groups
rename CP_PSP_NEIGH meetings_nbhd_assoc
rename CP_PSP_UNIV meetings_univ
rename CP_PSP_OTH meetings_other_groups
rename CP_PSP_OTH_FLAG meetings_other_groups_entry
rename CP_PSP_SCHOOL meetings_school_groups
rename CP_PSP_FAITH meetings_religious_groups
rename CP_PSP_HEALTH meetings_healthcare_groups
rename CP_PSP_GOV meetings_local_public_ag
rename CP_PSP_COMM meetings_comm_adv
rename CP_SURVEY survey_crime_fear_satis
rename CP_NOSURV survey_purpose_none
rename CP_SURV_CRPROB survey_purpose_prioritizing
rename CP_SURV_RESOURCE survey_purpose_resource_alloc
rename CP_SURV_PERFORM survey_purpose_eval_agency
rename CP_SURV_TRAINING survey_purpose_training
rename CP_SURV_POLICY survey_purpose_po_info

*** 2016 | SECTION V: EQUIPMENT ***
rename EQ_PRM_AGCY temp_sidearm_supplied
gen sidearm_supplied = (temp_sidearm_supplied==1)
drop temp_*

rename EQ_PRM_CASH temp_sidearm_cash_allowance
gen sidearm_cash_allowance = (temp_sidearm_cash_allowance==1)
drop temp_*

rename EQ_PRM_IND sidearm_officer_pays
rename EQ_PRM_NOAUTH sidearm_not_auth
rename EQ_BCK_AGCY backup_sidearm_supplied
rename EQ_BCK_CASH backup_sidearm_cash_allowance
rename EQ_BCK_IND backup_sidearm_officer_pays
rename EQ_BCK_NOAUTH backup_sidearm_not_auth
rename EQ_BDYARM_AGCY bodyarmor_supplied
rename EQ_BDYARM_CASH bodyarmor_cash_allowance
rename EQ_BDYARM_IND bodyarmor_officer_pays
rename EQ_BDYARM_NOAUTH bodyarmor_not_auth
rename EQ_UNI_AGCY uniforms_supplied
rename EQ_UNI_CASH uniforms_cash_allowance
rename EQ_UNI_IND uniforms_officer_pays
rename EQ_UNI_NOAUTH uniforms_not_auth
rename EQ_SEMI_ON_PRIM auth_semi_primary
rename EQ_SEMI_ON_BACK auth_semi_backup
rename EQ_SEMI_OFF auth_semi_offduty
rename EQ_SEMI_NOAUTH semi_unauthorized
rename EQ_REV_ON_PRIM auth_rev_primary
rename EQ_REV_ON_BACK auth_rev_backup
rename EQ_REV_OFF auth_rev_offduty
rename EQ_REV_NOAUTH rev_unauthorized
rename EQ_SEC_FULLAUTO auth_secondary_rifles_auto
rename EQ_SEC_SEMIAUTO auth_secondary_rifles_semi
rename EQ_SEC_MANUAL auth_secondary_rifles_manual
rename EQ_SEC_SHOTGUN auth_secondary_shotguns
rename EQ_SEC_OTH auth_secondary_other
rename EQ_SEC_OTH_FLAG auth_secondary_other_entry
rename EQ_SEC_NOAUTH auth_secondary_none
rename EQ_SEC_HANDGUN auth_secondary_handgun
rename EQ_SEC_LTHLETH auth_secondary_nonlethal
rename EQ_AUTH_OHAND auth_open_hand
rename EQ_AUTH_CHAND auth_closed_hand
rename EQ_AUTH_TKDWN auth_takedowns
rename EQ_AUTH_NECK auth_neck_hold
rename EQ_AUTH_LEG auth_leg_hobbles
rename EQ_AUTH_OC auth_chem_agent_pepper
rename EQ_AUTH_CHEM auth_chem_agent_proj
rename EQ_AUTH_BTN auth_baton_detail
gen auth_baton = 0 if auth_baton_detail==3
replace auth_baton = 1 if auth_baton_detail==1 | auth_baton_detail==2

rename EQ_AUTH_BLNT auth_impact_soft_proj
rename EQ_AUTH_CED auth_elec_dev
rename EQ_AUTH_EXP auth_explosives
rename EQ_DOC_OHAND req_doc_open_hand
rename EQ_DOC_CHAND req_doc_closed_hand
rename EQ_DOC_TKDWN req_doc_takedowns
rename EQ_DOC_NECK req_doc_neck_hold
rename EQ_DOC_LEG req_doc_leg_hobble
rename EQ_DOC_OC req_doc_pepper_spray
rename EQ_DOC_CHEM req_doc_other_chem_agent
rename EQ_DOC_BTN req_doc_baton
rename EQ_DOC_BLNT req_doc_soft_proj
rename EQ_DOC_DIS_CED req_doc_elec_dev_display
rename EQ_DOC_USE_CED req_doc_elec_dev_discharge
rename EQ_DOC_EXP req_doc_explosives
rename EQ_DOC_DIS_GUN req_doc_firearm_display
rename EQ_DOC_DCHG_GUN req_doc_firearm_discharge
rename EQ_DOC_OTH_FLAG req_doc_other
rename EQ_BDYARM bodyarmor_po_req
rename EQ_SEATBELT seatbelt_req
rename EQ_VEH_MRK vehicles_marked_cars
rename EQ_VEH_OTHMRK vehicles_marked_other
rename EQ_VEH_UNMRK vehicles_unmarked_cars
rename EQ_VEH_OTHUNMRK vehicles_unmarked_other
rename EQ_VEH_ARMOR vehicles_armored_car
rename EQ_VEH_ATV vehicles_atv
rename EQ_VEH_MTRCYCL vehicles_2_wheel
rename EQ_VEH_BOAT vehicles_boats
* 2016 doesn't separate vehicles_helicopters & vehicles_aircraft, retroactively constructing combined var
rename EQ_VEH_MANAIR vehicles_heli_aircraft
rename EQ_VEH_DRONE vehicles_drones
rename EQ_VEH_OTH vehicles_other
rename EQ_VEH_OHV vehicles_off_highway_veh
rename EQ_VEH_SNOWMOB vehicles_snowmob
rename EQ_VEH_BIKE vehicles_bicycles
rename EQ_VEH_HUMVEE vehicles_humvees
rename EQ_VEH_SEGWAY vehicles_segways
rename EQ_VID_FIXED cameras_fixed_surv
rename EQ_VID_MOBILE cameras_mobile_surv
rename EQ_VID_CAR cameras_patrol_car
rename EQ_VID_BWC cameras_patrol_off
rename EQ_VID_WEAP cameras_weapons
rename EQ_VID_DRONE cameras_drones

*** 2016 | SECTION VI: TECHNOLOGY ***
rename TECH_WEB_NONE website_none
rename TECH_WEB_STAT website_stats_crime
rename TECH_WEB_STOP website_stats_stop
rename TECH_WEB_ARR website_stats_arrest
rename TECH_WEB_REPORT website_cit_report_crimes
rename TECH_WEB_ASK website_cit_questions_feedback
rename TECH_WEB_COMPL website_cit_complaints
rename TECH_SM_TWITTER agency_uses_twitter
rename TECH_SM_FB agency_uses_facebook
rename TECH_SM_BLOG agency_uses_blog
rename TECH_SM_YOUTUBE agency_uses_youtube
rename TECH_SM_MASSNOT agency_uses_mass_comm
rename TECH_COMP_CRMANL comp_fc_analysis
rename TECH_COMP_SNA comp_fc_social_net_analysis
rename TECH_COMP_INTEL comp_fc_gathering_intel
rename TECH_COMP_INFSHR comp_fc_sharing_info
rename TECH_COMP_BOOK comp_fc_booking

foreach var of varlist comp_fc_* {
	replace `var' = 0 if `var'==2
}

rename TECH_CIR data_transfer_criminal_inc
rename TECH_TYP_AFIS afis_use
rename TECH_TYP_FACEREC dig_imaging_facial_recog
rename TECH_TYP_LPR night_vis_lic_plate_reader
rename TECH_TYP_INFR night_vis_infrared
rename TECH_TYP_ENGD veh_stop_engine_disrupt
rename TECH_TYP_VTRC veh_stop_lojack
rename TECH_TYP_TIREDFL veh_stop_roadspikes
rename TECH_TYP_GUNSHOT gunshot_detection_sensors
rename TECH_TYP_TRACE firearm_tracing
rename TECH_TYP_BALL ballistic_imaging
rename TECH_TYP_GPS gps
rename TECH_NO_IFC field_access_none
rename TECH_IFC_MVREC field_access_veh_records
rename TECH_IFC_DRVREC field_access_driving_records
rename TECH_IFC_CRIMREC field_access_crim_hist
rename TECH_IFC_WARR field_access_warrants
rename TECH_IFC_PRTORD field_access_protection_ord
rename TECH_IFC_INFSHR field_access_int_agency_files
rename TECH_IFC_ADDHIS field_access_service_call
rename TECH_IFC_GISMAP field_access_mapping_prog
rename TECH_EIS early_intervention_system
rename TECH_FILE_ARR comp_files_arrests
rename TECH_FILE_CFS comp_files_calls
rename TECH_FILE_COMPL comp_files_complaints
rename TECH_FILE_CRS comp_files_cr_inc
rename TECH_FILE_GUNS comp_files_firearms
rename TECH_FILE_GANG comp_files_gangs
rename TECH_FILE_INFORM comp_files_informants
rename TECH_ILES_INTEL comp_files_terrorism
rename TECH_FILE_MVSTOP comp_files_traffic_stops
rename TECH_FILE_MVACC comp_files_accidents
rename TECH_FILE_PAWN comp_files_pawn_shops
rename TECH_FILE_PRTORD comp_files_prot_orders
rename TECH_FILE_PROP comp_files_stolen_prop
rename TECH_FILE_STOPS comp_files_street_stops
rename TECH_FILE_UOF comp_files_use_of_force
rename TECH_FILE_VIDEO comp_files_video_surv
rename TECH_FILE_WARR comp_files_warrants

foreach var of varlist comp_files_* {
	replace `var' = 0 if `var' == 2
}

*** 2016 | SECTION VII: POLICIES AND PROCEDURES ***
rename POL_VEHPURS pursuit_driving_policy_desc
rename POL_DEADFORC direc_deadly_force
rename POL_LESSLETHAL direc_non_lethal_force
rename POL_CONDUCT direc_code_of_conduct
rename POL_MAXHRS direc_max_work_hours
rename POL_OFFDTY direc_off_duty_conduct
rename POL_MENTILL direc_mentally_ill
rename POL_HOMELESS direc_homeless
rename POL_DOMDISP direc_dom_abuse
rename POL_JUV direc_juveniles
rename POL_INCUSDTH direc_custody_deaths
rename POL_RACPROF direc_racial_profiling
rename POL_COMPL direc_citizen_compl
rename POL_STRPSRCH direc_strip_search
rename POL_TERROR terrorist_plan
rename POL_ACTSHOOT direc_active_shooter
rename POL_STFRSK direc_stop_and_frisk
rename POL_FOOT direc_foot_pursuits
rename POL_MVSTOP direc_mv_stops
rename POL_MSCOND direc_empl_misconduct
rename POL_PRISTRP direc_prisoner_transp
rename POL_MASSDEM direc_mass_demonstr
rename POL_REPUOF direc_rep_use_of_force
rename POL_BWC direc_body_cams
rename POL_SOCMED direc_social_media
rename POL_CULTAW direc_culture_aware

foreach var of varlist direc_* {
	replace `var' = 0 if `var' == 2
}

rename POL_INV_INJRY ext_rev_force_injury
rename POL_INV_DTH ext_rev_force_death
rename POL_INV_ICD ext_rev_nonforce_death
rename POL_INV_DCHG_GUN ext_rev_gun_discharge
rename POL_CCRB cit_review_board
rename POL_CCRB_SUBPWR cit_review_board_sub_power
rename POL_COMP_EXTINV rev_exc_force_outside_chain

*** 2016 | SECTION VIII: SPECIAL PROBLEMS/TASKS ***
rename ISSU_ADDR_BIAS spu_hate_crimes
rename ISSU_ADDR_BOMB spu_bomb_disposal
rename ISSU_ADDR_CHILD spu_child_abuse
rename ISSU_ADDR_CRMPREV spu_nbhd_crime_prev
rename ISSU_ADDR_CP spu_community_policing
rename ISSU_ADDR_CRMANL spu_crime_analysis
rename ISSU_ADDR_CYBER spu_cybercrime
rename ISSU_ADDR_DOM spu_dom_abuse
rename ISSU_ADDR_DRUG_ED spu_drug_educ
rename ISSU_ADDR_DRUG_ENF drug_unit
rename ISSU_ADDR_ENV spu_env_crime
rename ISSU_ADDR_FIN spu_fin_crimes
rename ISSU_ADDR_GUNS spu_guns
rename ISSU_ADDR_GANG spu_gangs
rename ISSU_ADDR_HUMTRF spu_human_traf
rename ISSU_ADDR_DUI spu_impaired_drivers
rename ISSU_ADDR_IA spu_internal_affairs
rename ISSU_ADDR_JUV spu_juvenile_delinq
rename ISSU_ADDR_MISCHD spu_missing_child
rename ISSU_ADDR_REPOFF spu_career_crim
rename ISSU_ADDR_RESRCH spu_research_planning
rename ISSU_ADDR_SCH spu_school_safety
rename ISSU_ADDR_SWAT spu_swat
rename ISSU_ADDR_TERROR spu_terrorism
rename ISSU_ADDR_VIC spu_victim_assist

*** 2016 | OTHER ***
rename FINALWGT weight_final
rename NEW_TOT_HIRES new_hires_gender_total_corr
rename NEW_TOT_SEP separations_gender_total_corr
rename FINALWGT_NTH_NTS weight_final_hire_sep

* staffing_discrepancy flags only appear in 2016, dropping
rename FLAG1 staffing_discrepancy_1
rename FLAG2 staffing_discrepancy_2
rename FLAG3 staffing_discrepancy_3
rename FLAG4 staffing_discrepancy_4
rename FLAG5 staffing_discrepancy_5
rename FLAG6 staffing_discrepancy_6
rename FLAG7 staffing_discrepancy_7
drop staffing_discrepancy_1 staffing_discrepancy_2 staffing_discrepancy_3 staffing_discrepancy_4 staffing_discrepancy_5 staffing_discrepancy_6 staffing_discrepancy_7

* dropping for merge
* temporary fix, may correct later 
drop patrol_other_entry meetings_other_groups_entry

order ori_9 county_fips

* I checked this department, it is in Union County: fips 34039
replace county_fips = "34039" if ori_9 == "NJ0201900"

* similarly, Philly PD is listed as being in Indiana County, PA. 
* total population of this county is ~ 70k, which contradicts their claimed 1.5M population
* seems to be a clear error, should be in Philadelphia Co: fips 42101
replace county_fips = "42101" if ori_9 == "PAPEP0000"

save "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2016_renamed.dta", replace



***** APPENDING, CONSTRUCTING FULL STATE_FIPS, MOSTLY-FULL COUNTY_FIPS *****
* within above: dropping type mismatch vars for now, may fix later if relevant 
use "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1987_renamed.dta", replace
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1990_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1993_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1997_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_1999_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2000_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2003_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2007_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2013_renamed.dta", force
append using "2000_data/300_cleaning/40_LEMAS/pre_append/LEMAS_2016_renamed.dta", force

replace population = 999999 if population ==.
gen population_flag = (population == 999999)
la var population_flag "DMF Imputed 999999 for 419 missing population observations"

replace state_abbr = state if inrange(length(state),1,2)
* county_fips are ABCDE, where AB=state_fips 
gen state_fips = substr(county_fips,-5,2)
destring state_fips, replace
statastates, fips(state_fips) nogen
replace state_abbrev = state_abbr if state_abbrev==""
drop state_name state_fips state_abbr state state_code
statastates, abbreviation(state_abbrev) nogen
order state_fips state_name state_abbrev county_fips year agency_type staff_nonsworn_ft staff_nonsworn_pt 
sort state_fips county_fips year

foreach var in ori_9 ori_7 agency_name_sample city county {
	replace `var' = upper(`var')
}

bysort year: egen N_by_year = count(_N) 
levelsof year, local(year_levels)
levelsof N_by_year, local(year_sample_sizes)
* Thursday, 11/17/22: 1673 variables 

*** pulling county_fips, missing for 2007 & 2013 ***
tab year if county_fips == ""
* need an ORI within relevant years
gen temp_has_ori = (ori_9!="") & (year==1993 | year>2003)
* ORI also needs to exist in either 1993 or 2016
bysort ori_9: egen temp_ori_match = count(year) if year==1993 | year==2016
replace temp_ori_match = (temp_ori_match >= 1)
* county_fips also needs to appear in one or more years
bysort ori_9: egen temp_fips_exists = count(county_fips) if temp_has_ori==1 & temp_ori_match==1
replace temp_fips_exists = (temp_fips_exists >= 1)
* imputation is possible under all three conditions
gen imputation_possible = temp_has_ori * temp_ori_match * temp_fips_exists 
* some shenanigans to find relevant county_fips string
bysort ori_9: egen temp_fips = mode(county_fips) if imputation_possible==1, maxmode
* identifying mis-matches, went back and manually checked them
egen temp_diff = diff(temp_fips county_fips) if imputation_possible==1 & county_fips!=""
bysort ori_9: egen temp_max_diff = max(temp_diff) 
replace county_fips = "temp_fips" if county_fips == "" & imputation_possible==1 & temp_max_diff==0
drop temp_* imputation_possible
* originally 2875 missing for 2007, 2826 missing for 2013
* gain of 2636=(2875-1534)+(2826-1531)

* this agency_type variable should be cohesive across all years
la var agency_type "1=local/county/regional, 2=sheriff, 3=state/highway patrol"

order state_fips state_name state_abbrev county_fips year agency_type staff_nonsworn_ft staff_nonsworn_pt 
sort state_fips county_fips year

* 1987 already has form_long variable
replace form_long = (form_code==1) if year==1990
replace form_long = (form_code==1) if year==1993
replace form_long = (form_code==1 | form_code==2) if year==1997
replace form_long = 0 if year==1999
replace form_long = (form_type!="") if year==2000
* 2003 already has form_long variable
replace form_long = (form_type=="L") if year==2007
replace form_long = 1 if year==2013
replace form_long = 1 if year==2016

gen sidearm_covered = .
replace sidearm_covered = 1 if sidearm_supplied_or_paid == 1 | sidearm_supplied==1 | sidearm_cash_allowance==1

* dropping variables that only appear in one year
drop govt_id_number census_check_digit agency_id_short service_call_total_inc_cit service_call_total_inc_off service_call_total_inc_alarm service_call_total_inc_walk_in service_call_total_inc_other sidearm_ammo baton handcuffs equipment_other_specify rev_caliber semi_caliber ft_avg_hours pt_pay_freq pt_pay_hours fiscal_start_full fiscal_end_full salary_srpatrol_min salary_srpatrol_max res_req_juris res_req_miles new_off_train_cost spu_drug_screen litigations_by_empl litigations_by_nonempl educ_sgt_req sheriff_law_enforcement sheriff_jail sheriff_court sheriff_other bodyarmor_specops_supplied bodyarmor_specops_allowance bodyarmor_specops_req auth_chem_agent auth_impact_dev auth_restr_dev auth_other auth_none fiscal_start_year fiscal_end_year res_req_detail drug_unit_cost seized_other seized_none res_req_detail_miles sheriff_law_enforcement_pct sheriff_jail_pct sheriff_court_pct sheriff_other_pct drug_unit_cost_flag weight_edited_base govt_id_state govt_id_county govt_id_check_digit govt_id_sector govt_id_unique avg_sworn_officers duties_calls_dispatching duties_violent_rape duties_violent_robbery duties_violent_assault duties_property_crime_burglary duties_property_crime_larceny duties_property_crime_mv service_call_total_cit_oth service_call_telephone_resp service_call_oth_resp service_call_oth_entry supplies_rev_other_entry supplies_semi_other_entry supplies_other_other_entry supplies_other_specify auth_rev_other_entry auth_other_other_entry auth_other_specify bodyarmor_po_supplied_all bodyarmor_po_supplied_some bodyarmor_po_supplied_none bodyarmor_specops_supplied_all bodyarmor_specops_supplied_some bodyarmor_specops_supplied_none bodyarmor_po_allowance_all bodyarmor_po_allowance_some bodyarmor_po_allowance_none bodyarmor_specops_allowance_all bodyarmor_specops_allowance_som bodyarmor_specops_allowance_non bodyarmor_po_req_all bodyarmor_po_req_some bodyarmor_po_req_none bodyarmor_specops_req_all bodyarmor_specops_req_some bodyarmor_specops_req_none auth_impact_other1 auth_impact_other2 auth_impact_other3 auth_elec_dev_other1 auth_elec_dev_other2 auth_elec_dev_other3 auth_chem_agent_tranq_dart auth_chem_agent_other1 auth_chem_agent_other2 auth_chem_agent_other3 auth_other2 auth_other3 comp_other_entry comp_fc_research comp_fc_other1 V259 V260 comp_files_other1 comp_files_other2 comp_files_other3 res_req_juris_extra educ_recruit_other_entry memb_org_state_police_assn memb_org_other_entry spu_other spu_other_entry cit_rev_acc_other_entry exc_force_invest_nonsworn exc_force_invest_civil_board exc_force_invest_off_prof_stand exc_force_invest_dist_attorney exc_force_invest_other_entry disp_act_rec_chief disp_act_rec_govt_exec disp_act_rec_superior disp_act_rec_other_sup disp_act_rec_int_aff disp_act_rec_civil_board disp_act_rec_commiss_board disp_act_rec_dist_attorney disp_act_rec_other disp_act_rec_other_entry exc_force_final_resp exc_force_final_resp_other drug_asset_forf_money_value drug_asset_forf_goods_value seized_any seized_no_info drug_test_op_jail drug_test_op_court drug_test_op_other_lea drug_test_op_pretrial_agency drug_test_op_private drug_test_op_other drug_test_op_other_entry agency_name_sample avg_sworn_officers_revised service_call_total_cit_oth_flag service_call_total_other_flag_e service_call_telephone_resp_flag service_call_oth_flag number_holding_cells_flag vehicles_buses_flag vehicles_armored_car_flag vehicles_atv_flag vehicles_3_wheel_flag vehicles_other_flag drug_asset_forf_money_value_flag drug_asset_forf_goods_value_flag lockup_adult_facilities lockup_juvenile_facilities three_digit_nonemer_num phone_based_mass_notifications fax_based_mass_notifications service_call_disp_alarm service_call_no_disp_alarm service_call_no_disp_other supplies_rev_40 supplies_semi_40 auth_rev_40 auth_semi_40 auth_choke_carotid_hold auth_other_entry vehicles_mobile_command_post vehicles_vans auto_finger_id_system off_screen_other off_screen_other_entry has_academy po_training_freq memb_org_police_union memb_org_nonpolice_union memb_org_police_assc salary_1yr_min salary_1yr_max spu_hate_crimes_sworn spu_hate_crimes_nonsworn spu_hate_crimes_none spu_child_abuse_sworn spu_child_abuse_nonsworn spu_child_abuse_none spu_nbhd_crime_prev_sworn spu_nbhd_crime_prev_nonsworn spu_nbhd_crime_prev_none spu_community_policing_sworn spu_community_policing_nonsworn spu_community_policing_none spu_crime_analysis_sworn spu_crime_analysis_nonsworn spu_crime_analysis_none spu_dom_abuse_sworn spu_dom_abuse_nonsworn spu_dom_abuse_none spu_drug_educ_sworn spu_drug_educ_nonsworn spu_drug_educ_none spu_drunk_drivers_sworn spu_drunk_drivers_nonsworn spu_drunk_drivers_none spu_env_crime_sworn spu_env_crime_nonsworn spu_env_crime_none spu_gangs_sworn spu_gangs_nonsworn spu_juvenile_delinq_sworn spu_juvenile_delinq_nonsworn spu_juvenile_delinq_none spu_missing_child_sworn spu_missing_child_nonsworn spu_missing_child_none spu_prosec_rel_sworn spu_prosec_rel_nonsworn spu_prosec_rel_none spu_career_crim_sworn spu_career_crim_nonsworn spu_career_crim_none spu_research_planning_sworn spu_research_planning_nonsworn spu_research_planning_none spu_victim_assist_sworn spu_victim_assist_nonsworn spu_victim_assist_none spu_youth_outreach_sworn spu_youth_outreach_nonsworn spu_youth_outreach_none comm_pol_officers cit_stat_access multi_force_drug_off_ft_flag multi_force_drug_off_pt_flag lockup_adult_facilities_flag lockup_juvenile_facilities_flag service_call_total_cit_other_f service_call_disp_alarm_flag service_call_no_disp_alarm_flag service_call_no_disp_other_flag po_training_freq_flag salary_1yr_min_flag salary_1yr_max_flag spu_hate_crimes_sworn_flag spu_hate_crimes_nonsworn_flag spu_child_abuse_sworn_flag spu_child_abuse_nonsworn_flag spu_nbhd_crime_prev_sworn_flag spu_nbhd_crime_prev_nonsworn_f spu_community_policing_sworn_f spu_community_policing_nonswornf spu_crime_analysis_sworn_flag spu_crime_analysis_nonsworn_flag spu_dom_abuse_sworn_flag spu_dom_abuse_nonsworn_flag spu_drug_educ_sworn_flag spu_drug_educ_nonsworn_flag spu_drunk_drivers_sworn_flag spu_drunk_drivers_nonsworn_flag spu_env_crime_sworn_flag spu_env_crime_nonsworn_flag spu_gangs_sworn_flag spu_gangs_nonsworn_flag spu_juvenile_delinq_sworn_flag spu_juvenile_delinq_nonsworn_f spu_missing_child_sworn_flag spu_missing_child_nonsworn_flag spu_prosec_rel_sworn_flag spu_prosec_rel_nonsworn_flag spu_career_crim_sworn_flag spu_career_crim_nonsworn_flag spu_research_planning_sworn_flag spu_research_planning_nonsworn_f spu_victim_assist_sworn_flag spu_victim_assist_nonsworn_flag spu_youth_outreach_sworn_flag spu_youth_outreach_nonsworn_flag comm_pol_officers_flag weight_2 weight_3 sample_type service_call_alarm_cat service_call_cit_other service_call_other comp_mainframe_num comp_mini_num comp_personal_num comp_server comp_server_num comp_other_num field_access_stolen_prop field_access_wanted_susp field_access_wanted_veh field_access_software_analysis comp_files_incident_based_data comp_files_incident_report_narr geocode_business_loc geocode_census_data geocode_other geocode_other_entry has_website_address reserve_off_ft reserve_off_pt comm_service_off_ft comm_service_off_pt volunteers_ft volunteers_pt cit_stat_access_fax cit_stat_access_library cit_stat_access_agency_rep cit_stat_access_written_req cit_stat_access_none cit_stat_level_state cit_stat_level_address cit_map_classes comments_attached data_date form_flag receipt_type receipt_date service_call_other_flag comp_mainframe_num_flag comp_mini_num_flag comp_personal_num_flag comp_server_num_flag comp_car_mounted_computer_num_f comp_other_num_flag reserve_off_ft_flag reserve_off_pt_flag comm_service_off_ft_flag comm_service_off_pt_flag volunteers_ft_flag volunteers_pt_flag sector_id year_began_operating duties_none_of_above1 duties_none_of_above2 staff_sworn_w_arrest_ft_flag staff_sworn_w_arrest_pt_flag staff_sworn_wo_arrest_ft_flag staff_sworn_wo_arrest_pt_flag staff_total_ft_flag staff_total_pt_flag ft_prim_patrol_flag ft_prim_detective_flag ft_prim_jail_flag ft_prim_court_sec_flag ft_prim_serving_flag budgeting_period new_off_train_class_hrs_state_f new_off_train_class_hrs_add_f new_off_train_field_hrs_state_f new_off_train_field_hrs_add_f po_training_hours_state_flag po_training_hours_add_flag comp_car_mounted_laptop_num_flag comp_car_mounted_computer_num_fl comp_car_mounted_other_num comp_car_mounted_other_num_flag comp_portable_other_num comp_portable_other_num_flag multi_force_drug_off_ft_f multi_force_drug_off_pt_f auth_semi_38_primary auth_semi_other_entry_primary auth_impact_none auth_chem_agent_pepper_none auth_chem_agent_tear_none auth_chem_agent_cs_gas_none auth_chem_agent_other_none auth_actions_none cameras_traffic_flag pursuit_driving_policy_desc_oth arrests_prot_order_violation arrests_domestic_assault auth_semi_38_backup not_auth_semi_10m not_auth_semi_9m not_auth_semi_45 not_auth_semi_40 not_auth_semi_38 not_auth_semi_other not_auth_rev factor_2000 address duties_eviction_notices duties_protection_order_enforce duties_child_support_enforcement duties_inmate_transport duties_fire_dispatch auth_staff_wo_arrest_ft auth_total_ft ft_comm_technicians new_off_train_class_hrs_total new_off_train_field_hrs_total po_training_hours_total ft_sworn_hires_new ft_sworn_hires_other ft_sworn_sep_probationary_rej ft_sworn_called_for_military operational_911_caller_location service_call_total_311 service_call_disp_311 service_call_any_flag formal_comm_pol_plan survey_purpose_eval_off terrorist_plan_coop_agree emer_equip_ppe emer_equip_chem_detect emer_equip_radio_detect emer_equip_bio_detect emer_equip_decontam_equip emer_equip_expl_detect emer_equip_none_of_above terrorist_prep_none_of_above multi_force_terr_sworn_ft multi_force_terr_sworn_pt multi_force_terr_other_ft multi_force_terr_other_pt auth_semi_10m_offduty auth_semi_9m_offduty auth_semi_45_offduty auth_semi_40_offduty auth_semi_357_offduty auth_semi_380_offduty auth_semi_other_offduty auth_semi_any_offduty auth_chem_agent_cs auth_hi_int_light cameras_red_light cameras_speeding comp_car_mounted_laptop_none comp_car_mounted_computer_none comp_car_mounted_term_none comp_car_mounted_other_none comp_laptop_none comp_handheld_comp_none comp_handheld_term_none comp_pdas comp_pdas_num comp_pdas_none comp_portable_other_none afis_shared comp_fc_traffic_stop_data_coll comp_fc_all_of_above comp_files_all_of_above use_of_force_unfounded use_of_force_exonerated use_of_force_not_sust service_call_total_311_flag service_call_disp_311_flag use_of_force_total_complaints_f use_of_force_unfounded_flag use_of_force_exonerated_flag use_of_force_not_sust_flag use_of_force_sustained_flag use_of_force_pending_flag use_of_force_other_disp_flag survey_id response_type multi_force_gang_off_ft multi_force_gang_off_pt multi_force_terr_off_ft multi_force_terr_off_pt multi_force_hum_traf_off_ft multi_force_hum_traf_off_pt gamb_asset_forf_tot_value oth_asset_forf_tot_value any_asset_forf_est educ_recruit_exceptions sworn_white_total sworn_black_total sworn_gender_total sworn_bilingual nonsworn_bilingual interpretors_sworn interpretors_nonsworn interpretors_volunteer interpretors_contractor interpretors_other interpretors_other_entry operational_911_caller_loc_ex operational_911_caller_loc_gen cit_contact_email cit_contact_web_feedback cit_contact_web_maps cit_contact_web_stats cit_contact_listserv cit_contact_rev_911 cit_contact_mass_comm cit_contact_311 cit_contact_elect_report cit_contact_email_crime_rep cit_contact_other terrorist_prep_emprep_ex terrorist_prep_other terrorist_prep_other_entry auth_no_backup auth_secondary_ar auth_secondary_shotgun auth_secondary_carbine auth_secondary_rifle auth_chem_agent_other_entry night_vis_goggles marked_outside_juris_use comp_field_use comp_car_mounted_num comp_port_veh_dock_num comp_port_non_veh_dock_num field_access_internet field_access_other field_access_other_entry spu_auto_theft direc_limited_eng direc_immig_status sworn_gender_total_flag sworn_race_total_flag ft_prim_terr_intel_sworn_flag ft_prim_terr_intel_nonsworn_flag vehicles_marked_other_flag vehicles_unmarked_other_flag comp_car_mounted_num_flag comp_port_veh_dock_num_flag comp_port_non_veh_dock_num_flag encourage_SARA_pct_flag geographic_patrol_beats_pct_flag multi_force_gang_off_flag multi_force_hum_traf_off_flag multi_force_terr_off_flag csllea_2004_id weight_final_p1 weight_final_p2plus sheriff_flag tribal_pd county_pd agency_id_new stratum_desc sworn_males_ft sworn_males_pt sworn_females_ft sworn_females_pt sworn_white_total_ft sworn_black_total_ft sworn_race_total ft_prim_other sworn_chief_males sworn_chief_females sworn_seasonal_ft sworn_seasonal_pt reserve_off_sworn_unpaid pay_special_duty pay_other pay_other_entry outside_work_allowed outside_work_restr_none outside_work_restr_hours outside_work_restr_type outside_work_restr_other outside_work_restr_other_entry has_coll_bargain coll_bargain_status uniforms_supplied_or_paid bodyarmor_supplied_or_paid safety_eq_other_supplied_or_paid ot_paid_sworn ot_paid_nonsworn ot_auth_court_testimony ot_auth_ext_shifts ot_auth_incr_patrols ot_auth_investigations ot_auth_admin_duties ot_auth_emergency_resp ot_auth_special_events ot_auth_other ot_auth_other_entry ot_hours_limited marked_take_home_detail unmarked_take_home hiring_freeze hiring_freeze_sworn_2010 hiring_freeze_sworn_2011 hiring_freeze_sworn_2012 hiring_freeze_nonsworn_2010 hiring_freeze_nonsworn_2011 hiring_freeze_nonsworn_2012 sworn_hires_none ft_sworn_hires_direct pt_sworn_hires_direct ft_sworn_hires_pre_serv pt_sworn_hires_pre_serv pt_sworn_hires_lateral pt_sworn_hires_total hire_train_lateral_none hire_train_pre_serv_none hire_train_lateral_abbr_class hire_train_pre_serv_abbr_class hire_train_lateral_abbr_field hire_train_pre_serv_abbr_field hire_train_lateral_as_direct hire_train_pre_serv_as_direct hire_train_lateral_other hire_train_pre_serv_other nonsworn_hires_none nonsworn_hires_ft nonsworn_hires_pt educ_recruit_none educ_recruit_hs educ_recruit_some_coll educ_recruit_assoc_deg educ_recruit_bach_deg educ_recruit_other hire_ft_bach_deg retire_defined_ben retire_defined_contr retire_social_sec retire_other ft_sworn_sep_layoffs nonsworn_sep_layoffs nonsworn_sep_other nonsworn_sep_total funding_source_govt_mun funding_source_govt_county funding_source_govt_state funding_source_govt_fed funding_source_contr_service funding_source_asset_forf funding_source_user_fees funding_source_other funding_source_other_entry salary_reductions salary_reductions_sworn_pct salary_reduction_nonsworn_pct furlough furlough_sworn_2010 furlough_sworn_2011 furlough_sworn_2012 furlough_nonsworn_2010 furlough_nonsworn_2011 furlough_nonsworn_2012 tech_smartphones cameras_public_surv comp_files_cr_inc_type_stats_rec comp_files_cr_inc_type_sum_stats comp_files_cr_inc_type_off_narr comp_files_cr_inc_type_oth comp_files_cr_inc_type_oth_entry comp_files_cr_inc_narr_desc comp_files_cr_inc_off_code comp_files_cr_inc_statutes comp_files_cr_inc_victim_char comp_files_cr_inc_susp_char comp_files_cr_inc_location comp_files_cr_inc_geo_address comp_files_cr_inc_date_time who_research_none who_research_agency_staff who_research_external_org stat_analysis_sworn_ft_num stat_analysis_sworn_pt_num stat_analysis_nonsworn_ft_num stat_analysis_nonsworn_pt_num stat_analysis_outside_lea stat_analysis_outside_govt stat_analysis_outside_univ stat_analysis_outside_commercial stat_analysis_outside_other website_jurisdiction_stats website_beat_stats website_map_stats website_sex_off_maps website_other_stats website_other_stats_entry website_cit_other website_cit_other_entry email_text_crime_reporting cit_request_electronic_info agency_uses_other agency_uses_other_entry pursuit_driving_inc_doc pursuit_driving_inc_doc_entry pursuit_driving_num pursuit_driving_num_est pursuit_driving_num_unk pursuit_foot_restr_none pursuit_foot_restr_alone pursuit_foot_restr_vis_cont pursuit_foot_restr_off_sep pursuit_foot_restr_radio_loss pursuit_foot_restr_armed pursuit_foot_restr_other pursuit_foot_enc_contain auth_handguns auth_rifles auth_shotguns req_doc_other_impact use_of_force_doc_desc use_of_force_doc_none use_of_force_doc_per_inc use_of_force_doc_per_off use_of_force_doc_other use_of_force_doc_other_entry use_of_force_inc_num use_of_force_inc_num_est use_of_force_inc_num_unk use_of_force_rec_num use_of_force_rec_num_est use_of_force_rec_num_unk bodyarmor_selector bodyarmor_po_access_always bodyarmor_po_req_risky bodyarmor_po_always bodyarmor_custom_fit bodyarmor_training bodyarmor_sup_inspect bodyarmor_nij_std bodyarmor_pay_dept bodyarmor_pay_off bodyarmor_pay_grant bodyarmor_pay_other bodyarmor_pay_other_entry spu_reentry_surv spu_warrants spu_number multi_force_part multi_force_swat multi_force_gang multi_force_hum_traf multi_force_other multi_force_other_entry sidearm_supplied_or_paid lear_id reserve_off_sworn_ft_lim reserve_off_sworn_pt_lim asset_forfeiture_value asset_forfeiture_value_est new_off_citizenship off_screen_social_media off_screen_vision_test bilingual_sworn bilingual_sworn_lim bilingual_nonsworn new_hires_white new_hires_black new_hires_hisp new_hires_indian new_hires_asian new_hires_hawaiian new_hires_two_plus new_hires_unk new_hires_race_total new_hires_male new_hires_female new_hires_gender_total separations_white separations_black separations_hisp separations_indian separations_asian separations_hawaiian separations_two_plus separations_unk separations_race_total separations_male separations_female separations_gender_total chief_sex chief_race sworn_int_supervisor_white sworn_int_supervisor_black sworn_int_supervisor_race_total sworn_int_supervisor_gender_tot sworn_sgt_white sworn_sgt_black sworn_sgt_race_total sworn_sgt_gender_total coll_bargain_sworn coll_bargain_sworn_lim coll_bargain_nonsworn patrol_other_atvs patrol_other_snowmob patrol_other_uav patrol_other_golfcart written_comm_pol_plan analyze_comm_prob_w_tech meetings_univ meetings_healthcare_groups meetings_comm_adv sidearm_officer_pays sidearm_not_auth backup_sidearm_officer_pays backup_sidearm_not_auth bodyarmor_officer_pays bodyarmor_not_auth uniforms_officer_pays uniforms_not_auth auth_semi_offduty semi_unauthorized rev_unauthorized auth_secondary_rifles_auto auth_secondary_rifles_semi auth_secondary_rifles_manual auth_secondary_shotguns auth_secondary_other_entry auth_secondary_handgun auth_secondary_nonlethal auth_chem_agent_proj auth_explosives req_doc_explosives req_doc_other seatbelt_req vehicles_off_highway_veh vehicles_snowmob vehicles_humvees vehicles_segways cameras_drones website_stats_crime website_stats_stop website_stats_arrest comp_fc_social_net_analysis afis_use firearm_tracing ballistic_imaging gps field_access_none comp_files_informants comp_files_street_stops comp_files_video_surv direc_active_shooter direc_stop_and_frisk direc_foot_pursuits direc_mv_stops direc_empl_misconduct direc_prisoner_transp direc_mass_demonstr direc_rep_use_of_force direc_body_cams direc_social_media direc_culture_aware ext_rev_force_injury ext_rev_force_death ext_rev_nonforce_death ext_rev_gun_discharge spu_guns new_hires_gender_total_corr separations_gender_total_corr weight_final_hire_sep

* ordering by: full variables > missing one year > rest
order state_fips state_name state_abbrev year county_fips city agency_id_unique ori_9 agency_name agency_type staff_nonsworn_ft staff_nonsworn_pt population staff_sworn_ft staff_sworn_pt form_long population_flag N_by_year vehicles_marked_cars vehicles_unmarked_cars vehicles_2_wheel vehicles_boats comp_fc_analysis comp_files_arrests comp_files_calls comp_files_stolen_prop comp_files_warrants auth_sworn_ft sworn_males sworn_females direc_deadly_force direc_code_of_conduct vehicles_heli_aircraft 

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/300_cleaning/40_LEMAS/LEMAS_appended.dta", replace

log close
