* 05b_estudy.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/05_regs/05_SMCL_logs/05b_estudy", smcl replace

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

save "2000_data\500_working\14_days\eq2\05b_use_in_loop.dta", replace

foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
	display ""
	display "`o' loop:"
	
	use "2000_data\500_working\14_days\eq2\05b_use_in_loop.dta", replace
	
	* setting i_absorbs for main variants, and xits for TWM
	local xit = "post0 memorial labor fourth tg xmas nye NOLA_Bourbon Philly_DNC WA_mar_2017"
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
	display "Eq2: Estudy, outcome=""`o'"": `o_desc'"
	display "*********************************************************************"

	* running regressions: 
	xtset num_dept date 
	
	display ""
	local variant = "A00"
	display " `variant': Full, Unbalanced" 
	reghdfe `o' ib26.b_`k' `aweight' if (date>1) `ifs', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	* Using balanced panel for the rest: 
	local ifs1 = "`ifs' & (weak_bal>=`b')"
	local ifs2 = "`ifs' & (str_bal>=`b')"
	
	display ""
	local variant = "main"
	display " `variant': Department-Event-Year FEs"
	reghdfe `o' ib26.b_`k' `aweight' if (date>1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	display ""
	local variant = "A01"
	display "`variant': Department-Event FEs"
	reghdfe `o' ib26.b_`k' `aweight' if (date>1) `ifs1', a(`i_absorb2') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	display ""
	local variant = "A02"
	display " `variant': Day-of-Week FEs"
	reghdfe `o' ib26.b_`k' `aweight' if (date>1) `ifs1', a(`i_absorb3') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	if ("`o'" == "n_stops") | ("`o'" == "n_bstops") | ("`o'" == "n_searches") | ("`o'" == "n_bsearches") | ("`o'" == "n_hits") | ("`o'" == "n_bhits") {
		display ""
		local variant = "A03"
		display " `variant': Log Outcomes"
		reghdfe log_`o' ib26.b_`k' `aweight' if (date>1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
		est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
		gen e_`o'_`variant' = (e(sample)==1)
	}

	display ""
	local variant = "A04"
	display " `variant': Strongly Balanced"
	reghdfe `o' ib26.b_`k' `aweight' if (date>1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	display ""
	local variant = "A05"
	display " `variant': Single-Event Departments"
	reghdfe `o' ib26.b_`k' `aweight' if (multi_dept==0) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	display ""
	local variant = "A06"
	display " `variant': Multi-Event Departments"
	reghdfe `o' ib26.b_`k' `aweight' if (multi_dept==1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	display ""
	local variant = "A07"
	display " `variant': Only Statewide"
	reghdfe `o' ib26.b_`k' `aweight' if (statewide==1) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)
	
	display ""
	local variant = "A08"
	display " `variant': Without Statewide"
	reghdfe `o' ib26.b_`k' `aweight' if (statewide==0) `ifs1', a(`i_absorb') cl(num_dept) base resid 
	est save "4000_outputs/`k'_days/eq2/`o'/estudy_`variant'`suffix'", replace
	gen e_`o'_`variant' = (e(sample)==1)

	save "2000_data/500_working/`k'_days/eq2/`o'/e_estudy_`variant'`suffix'.dta", replace
}

log close
