* 07a_descriptive_statistics.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
*cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/07a_descriptive_statistics", smcl replace

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


* suffix: 
local suffix = "_full"

use "2000_data/500_working/`k'_days/eq1/e_DiD`suffix'.dta", replace

* some variants have same raw stats, irrelevant 
foreach variant in A00 main A03 A04 A05 A06 A07 A08 {
	display ""
	
	* generating title suffixes: 
	if ("`variant'" ==  "A00") local title_suffix =  "A00, Full Sample, Unbalanced"
	if ("`variant'" == "main") local title_suffix =  "Balanced"
*	if ("`variant'" ==  "A01") local title_suffix =  "A01, Balanced"
*	if ("`variant'" ==  "A02") local title_suffix =  "A02, Balanced"
	if ("`variant'" ==  "A03") local title_suffix =  "A03, Log Outcomes, Balanced"
	if ("`variant'" ==  "A04") local title_suffix =  "A04, Strongly Balanced"
	if ("`variant'" ==  "A05") local title_suffix =  "A05, Single-Event Departments, Balanced"
	if ("`variant'" ==  "A06") local title_suffix =  "A06, Multi-Event Deaprtments, Balanced"
	if ("`variant'" ==  "A07") local title_suffix =  "A07, Only Statewide Departments, Balanced"
	if ("`variant'" ==  "A08") local title_suffix =  "A08, Without Statewide Departments, Balanced"
*	if ("`variant'" ==  "TWM") local title_suffix =  "TWM, Heterogeneity Check, Balanced"
	
	preserve 
	* note: n_stops, n_bstops, bstop_share are largest sample (most relevant for dstats)
	keep if (e_n_stops_`variant'==1)
	
	* Treatment Status DTable:
	collect clear

	dtable bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio, by(treat) ///
		name(Rates) nformat(%3.2f) nosample title("Raw Differences in Outcomes, `title_suffix'") 
	dtable n_stops n_bstops n_searches n_bsearches n_hits n_bhits, by(treat) ///
		name(Volumes) nformat(%9.2f)

	collect combine all = Rates Volumes
	collect style cell result[mean sd]
	collect layout (collection#var) (result#treat)
	collect export "6000_LaTeX/tables/descriptive_statistics_`variant'`suffix'.tex", replace tableonly 
	collect export "6000_LaTeX/tables/descriptive_statistics_`variant'`suffix'.pdf", replace 

	* Scrutiny Levels DTable:
	collect clear

	drop if scr==0

	dtable bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio, by(scr) ///
		name(Rates) nformat(%3.2f) nosample title("Raw Differences in Outcomes, `title_suffix', by Scrutiny") 
	dtable n_stops n_bstops n_searches n_bsearches n_hits n_bhits, by(scr) ///
		name(Volumes) nformat(%9.2f)

	collect combine all = Rates Volumes
	collect style cell result[mean sd]
	collect layout (collection#var) (result#scr)
	collect export "6000_LaTeX/tables/descriptive_statistics_scr_`variant'`suffix'.tex", replace tableonly 
	collect export "6000_LaTeX/tables/descriptive_statistics_scr_`variant'`suffix'.pdf", replace 
	
	restore
}

log close
