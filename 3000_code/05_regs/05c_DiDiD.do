* 05c_DiDiD.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/05_regs/05_SMCL_logs/05c_DiDiD", smcl replace

* Variant Key: 
* A00	: Full, Unbalanced 
* main	: Department-Event-Year FEs 
* A01	: Department-Event FEs 
* A02	: Day-of-Week FEs 
* A03	: Log Outcomes 
* A04	: Strongly Balanced
* A05	: Single-Event Departments 
* A06	: Multi-Event Departments 
* A07	: Only Statewide 
* A08	: Without Statewide 
* TWM	: Heterogeneity Check 

about 

set maxvar 32767

set varabbrev off

* bin-size: 
local k=14

* event-window, +/- b: 
local b=14

* suffix: 
local suffix = "_full"

* load-if: 
local load_if = "(unreliable_bstops!=1)"

********************************************************************************

* loading dataset: 
use "2000_data/500_working/`k'_days/reg_prep.dta" if `load_if', replace

save "2000_data\500_working\14_days\eq3\05c_use_in_loop.dta", replace

foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
	display ""
	display "`o' loop:"
	
	use "2000_data\500_working\14_days\eq3\05c_use_in_loop.dta", replace
	
	* setting i_absorbs for main variants, and xits for TWM
	local xit = "post1 post2 memorial labor fourth tg xmas nye NOLA_Bourbon Philly_DNC WA_mar_2017"
	local i_absorb  = "i.pseudo_year i.year_mo i.memorial i.labor i.fourth i.tg i.xmas i.nye i.NOLA_Bourbon i.Philly_DNC i.WA_mar_2017"
	local i_absorb2 = "i.pseudo_dept i.year_mo i.memorial i.labor i.fourth i.tg i.xmas i.nye i.NOLA_Bourbon i.Philly_DNC i.WA_mar_2017"
	local i_absorb3 = "`i_absorb' i.dow"
	
	* Setting AWEIGHTS: 
	if ("`o'" == "bstop_share") local aweight = "[aweight=n_stops_weight]"
	if ("`o'" == "bsearch_share") local aweight = "[aweight=n_searches_weight]"
	if ("`o'" == "bhit_share") local aweight = "[aweight=n_hits_weight]"
	if ("`o'" == "bsearch_rate") local aweight = "[aweight=n_bstops_weight]"
	if ("`o'" == "bhit_rate") local aweight = "[aweight=n_bsearches_weight]"
	if ("`o'" == "bhit_bstop_ratio") local aweight = "[aweight=n_bstops_weight]"
	if ("`o'" == "n_stops") local aweight = ""
	if ("`o'" == "n_bstops") local aweight = ""
	if ("`o'" == "n_searches") local aweight = ""
	if ("`o'" == "n_bsearches") local aweight = ""
	if ("`o'" == "n_hits") local aweight = ""
	if ("`o'" == "n_bhits") local aweight = ""
	
	* Setting IFS: 
	if ("`o'" == "bstop_share") local ifs = ""
	if ("`o'" == "bsearch_share") local ifs = "& (unreliable_searches!=1)"
	if ("`o'" == "bhit_share") local ifs = "& (unreliable_searches!=1) & (unreliable_hits!=1)"
	if ("`o'" == "bsearch_rate") local ifs = "& (unreliable_searches!=1)"
	if ("`o'" == "bhit_rate") local ifs = "& (unreliable_searches!=1) & (unreliable_hits!=1)"
	if ("`o'" == "bhit_bstop_ratio") local ifs = "& (unreliable_searches!=1) & (unreliable_hits!=1)"
	if ("`o'" == "n_stops") local ifs = ""
	if ("`o'" == "n_bstops") local ifs = ""
	if ("`o'" == "n_searches") local ifs = "& (unreliable_searches!=1)"
	if ("`o'" == "n_bsearches") local ifs = "& (unreliable_searches!=1)"
	if ("`o'" == "n_hits") local ifs = "& (unreliable_searches!=1) & (unreliable_hits!=1)"
	if ("`o'" == "n_bhits") local ifs = "& (unreliable_searches!=1) & (unreliable_hits!=1)"
	
	* Setting OUTCOME DESCRIPTIONS: 
	if ("`o'" == "bstop_share") local o_desc = "Black Share of Stops"
	if ("`o'" == "bsearch_share") local o_desc = "Black Share of Searches"
	if ("`o'" == "bhit_share") local o_desc = "Black Share of Hits"
	if ("`o'" == "bsearch_rate") local o_desc = "Black Search Rate"
	if ("`o'" == "bhit_rate") local o_desc = "Black Hit Rate"
	if ("`o'" == "bhit_bstop_ratio") local o_desc = "Black Hits-to-Stops Ratio"
	if ("`o'" == "n_stops") local o_desc = "Overall Stop Volume"
	if ("`o'" == "n_bstops") local o_desc = "Black Stop Volume"
	if ("`o'" == "n_searches") local o_desc = "Overall Search Volume"
	if ("`o'" == "n_bsearches") local o_desc = "Black Search Volume"
	if ("`o'" == "n_hits") local o_desc = "Overall Hit Volume"
	if ("`o'" == "n_bhits") local o_desc = "Black Hit Volume"
	
	display ""
	display "*********************************************************************"
	display "Eq3: DiDiD, outcome=""`o'"": `o_desc'"
	display "*********************************************************************"

	* running regressions: 
	xtset num_dept date 
	
	display ""
	local variant = "A00"
	display " `variant': Full, Unbalanced" 
	reghdfe `o' post1 post2 `aweight' if (date>1) `ifs', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	* Using balanced panel for the rest: 
	local ifs1 = "`ifs' & (weak_bal>=`b')"
	local ifs2 = "`ifs' & (str_bal>=`b')"
	
	display ""
	local variant = "main"
	display " `variant': Department-Event-Year FEs"
	reghdfe `o' post1 post2 `aweight' if (date>1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	local variant = "A01"
	display "`variant': Department-Event FEs"
	reghdfe `o' post1 post2 `aweight' if (date>1) `ifs1', a(`i_absorb2') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	local variant = "A02"
	display " `variant': Day-of-Week FEs"
	reghdfe `o' post1 post2 `aweight' if (date>1) `ifs1', a(`i_absorb3') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	if ("`o'" == "n_stops") | ("`o'" == "n_bstops") | ("`o'" == "n_searches") | ("`o'" == "n_bsearches") | ("`o'" == "n_hits") | ("`o'" == "n_bhits") {
		display ""
		local variant = "A03"
		display " `variant': Log Outcomes"
		reghdfe log_`o' post1 post2 1b0.treat `aweight' if (date>1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
		est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
		gen e_`o'_`variant' = (e(sample)==1)
	}

	display ""
	local variant = "A04"
	display " `variant': Strongly Balanced"
	reghdfe `o' post1 post2 `aweight' if (date>1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	local variant = "A05"
	display " `variant': Single-Event Departments"
	reghdfe `o' post1 post2 `aweight' if (multi_dept==0) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	local variant = "A06"
	display " `variant': Multi-Event Departments"
	reghdfe `o' post1 post2 `aweight' if (multi_dept==1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	local variant = "A07"
	display " `variant': Only Statewide"
	reghdfe `o' post1 post2 1b0.treat `aweight' if (statewide==1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	local variant = "A08"
	display " `variant': Without Statewide"
	reghdfe `o' post1 post2 1b0.treat `aweight' if (statewide==0) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	display ""
	display "Setting up Macros for TWM:"
	local x_tbar = ""
	local x_ibar = ""
	local x_t_diff = ""
	local x_i_diff = ""

	* xit, for main variant
	* generating overall averages: 
	display "generating overall averages:"
	foreach x of local xit {
		egen `x'_bar = mean(`x') if (e_`o'_main==1)
	}

	* generating time-averages + (time-averages - overall-averages): 
	display "generating time-averages + (time-averages - overall-averages):"
	foreach x of local xit {
		bysort year_mo: egen `x'_tbar = mean(`x') if (e_`o'_main==1)
		gen post_`x'_t_diff = post0*(`x'_tbar - `x'_bar) if (e_`o'_main==1)
		local x_tbar = "`x_tbar'`x'_tbar "
		local x_t_diff = "`x_t_diff'post_`x'_t_diff "
	}

	* generating unit-averages + (unit-averages - overall-averages): 
	display "generating unit-averages + (unit-averages - overall-averages):" 
	foreach x of local xit {
		bysort pseudo_dept: egen `x'_ibar = mean(`x') if (e_`o'_main==1)
		gen post_`x'_i_diff = post0*(`x'_ibar - `x'_bar) if (e_`o'_main==1)
		local x_ibar = "`x_ibar'`x'_ibar "
		local x_i_diff = "`x_i_diff'post_`x'_i_diff "
	}

	xtset num_dept date

	display ""
	local variant = "TWM"
	display " `variant': Heterogeneity Check"
	xtreg `o' `xit' `x_tbar' `x_ibar' `x_t_diff' `x_i_diff' `aweight' if (e_`o'_main==1) `ifs1', fe vce(cl num_dept)
	est save "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	* joint F-test, to see if new interactions are relevant: 
	test `x_t_diff' 
	test `x_i_diff' 
	test `x_t_diff' `x_i_diff' 
	
	save "2000_data/500_working/`k'_days/eq3/`o'/e_DiDiD`suffix'.dta", replace
}

* merging-together all 12 outcome datasets (useful for descriptive statistics table)
use "2000_data/500_working/`k'_days/eq3/bstop_share/e_DiDiD`suffix'.dta", replace
foreach o in bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
	merge 1:1 num_dept date using "2000_data/500_working/`k'_days/eq3/`o'/e_DiDiD`suffix'.dta", nogen
}

save "2000_data/500_working/`k'_days/eq3/e_DiDiD`suffix'.dta", replace

log close
