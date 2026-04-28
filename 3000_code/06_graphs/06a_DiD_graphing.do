* 06a_DiD_graphing.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
*cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/06_graphs/06_SMCL_logs/06a_DiD_graphing", smcl replace

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




foreach variant in A00 main A01 A02 A03 A04 A05 A06 A07 A08 TWM {
	display ""

	* generating subtitles: 
	if ("`variant'" ==  "A00") local subtitle =  "A00, Full Sample, Unbalanced"
	if ("`variant'" == "main") local subtitle = "Main, Department-Event-Year FEs, Balanced"
	if ("`variant'" ==  "A01") local subtitle =  "A01, Department-Event FEs, Balanced"
	if ("`variant'" ==  "A02") local subtitle =  "A02, Day-of-Week FEs, Balanced"
	if ("`variant'" ==  "A03") local subtitle =  "A03, Log Outcomes, Balanced"
	if ("`variant'" ==  "A04") local subtitle =  "A04, Strongly Balanced"
	if ("`variant'" ==  "A05") local subtitle =  "A05, Single-Event Departments, Balanced"
	if ("`variant'" ==  "A06") local subtitle =  "A06, Multi-Event Deaprtments, Balanced"
	if ("`variant'" ==  "A07") local subtitle =  "A07, Only Statewide Departments, Balanced"
	if ("`variant'" ==  "A08") local subtitle =  "A08, Without Statewide Departments, Balanced"
	if ("`variant'" ==  "TWM") local subtitle =  "TWM, Heterogeneity Check, Balanced"
	
	set graphics off
	
	**************************************************
	*** DiD_1 Graphs: 
	**************************************************
	if ("`variant'" != "A03") {
		foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio {
			display "`o'"
			estimates use "4000_outputs/`k'_days/eq1/`o'/DiD_`variant'`suffix'.ster"
			estimate
			estimates store `o'
		}
		
		* plotting DiD_1 estimates: 
		coefplot bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio, ///
			keep(post0) transform(*=@/@se) xline(0) ///
			name("DiD_r_`variant'`suffix'") title("Eq1: All Events") ytitle("") xtitle("T-Statistic") ylabel(, nolabels) ///
			legend(cols(3) order(2 "Share of Stops" 4 "Share of Searches" 6 "Share of Hits" 8 "Search Rate" 10 "Hit Rate" 12 "Hits to Stops Ratio")) ///
			saving("5000_figures/`k'_days/DiD_r_`variant'`suffix'.gph", replace) 
	}

	**************************************************
	*** DiD_2 Graphs: 
	**************************************************
	foreach o in n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
		display "`o'"
		estimates use "4000_outputs/`k'_days/eq1/`o'/DiD_`variant'`suffix'.ster"
		estimate
		estimates store `o'
	}

	* plotting DiD_2 estimates: 
	coefplot n_stops n_bstops n_searches n_bsearches n_hits n_bhits, ///
		keep(post0) transform(*=@/@se) xline(0) ///
		name("DiD_v_`variant'`suffix'") title("Eq1: All Events") ytitle("") xtitle("T-Statistic") ylabel(, nolabels) ///
		legend(cols(3) order(2 "Stop Volume" 4 "Black Stop Volume" 6 "Search Volume " 8 "Black Search Volume" 10 "Hit Volume" 12 "Black Hit Volume")) ///
		saving("5000_figures/`k'_days/DiD_v_`variant'`suffix'.gph", replace) 

	**************************************************
	*** DiDiD_1 Graphs: 
	**************************************************
	if ("`variant'" != "A03") {
		foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio {
			estimates use "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
			estimate
			estimates store `o'1
			
			estimates use "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
			estimate
			estimates store `o'2
		}

		* plotting DiDiD_1_lo estimates: 
		coefplot bstop_share1 bsearch_share1 bhit_share1 bsearch_rate1 bhit_rate1 bhit_bstop_ratio1, ///
			keep(post1) transform(*=@/@se) xline(0) ///
			name("DiDiD_`variant'_r_lo`suffix'") title("Eq3: Low Scrutiny") ytitle("") xtitle("T-Statistic") ylabel(, nolabels) ///
			legend(off) ///
			saving("5000_figures/`k'_days/DiDiD_`variant'_r_lo`suffix'.gph", replace) 
		
		* plotting DiDiD_1_hi estimates: 
		coefplot bstop_share2 bsearch_share2 bhit_share2 bsearch_rate2 bhit_rate2 bhit_bstop_ratio2, ///
			keep(post2) transform(*=@/@se) xline(0) ///
			name("DiDiD_`variant'_r_hi`suffix'") title("Eq3: High Scrutiny") ytitle("") xtitle("T-Statistic") ylabel(, nolabels) ///
			legend(off) ///
			saving("5000_figures/`k'_days/DiDiD_`variant'_r_hi`suffix'.gph", replace) 
	}

	**************************************************
	*** DiDiD_2 Graphs: 
	**************************************************
	foreach o in n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
		estimates use "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
		estimate
		estimates store `o'1

		estimates use "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
		estimate
		estimates store `o'2
	}

	* plotting DiDiD_2_lo estimates: 
	coefplot n_stops1 n_bstops1 n_searches1 n_bsearches1 n_hits1 n_bhits1, ///
		keep(post1) transform(*=@/@se) xline(0) ///
		name("DiDiD_`variant'_v_lo`suffix'") title("Eq3: Low Scrutiny") ytitle("") xtitle("T-Statistic") ylabel(, nolabels) ///
		legend(off) ///
		saving("5000_figures/`k'_days/DiDiD_`variant'_v_lo`suffix'.gph", replace) 

	* plotting DiDiD_2_hi estimates: 
	coefplot n_stops2 n_bstops2 n_searches2 n_bsearches2 n_hits2 n_bhits2, ///
		keep(post2) transform(*=@/@se) xline(0) ///
		name("DiDiD_`variant'_v_hi`suffix'") title("Eq3: High Scrutiny") ytitle("") xtitle("T-Statistic") ylabel(, nolabels) ///
		legend(off) ///
		saving("5000_figures/`k'_days/DiDiD_`variant'_v_hi`suffix'.gph", replace) 


		
	**************************************************
	*** Combining Graphs: 
	**************************************************
	set graphics on

	if ("`variant'" != "A03") {
		grc1leg "5000_figures/`k'_days/DiD_r_`variant'`suffix'" "5000_figures/`k'_days/DiDiD_`variant'_r_lo`suffix'" "5000_figures/`k'_days/DiDiD_`variant'_r_hi`suffix'", col(3) name("grc_DiD_r_`variant'`suffix'", replace) title("Diff-in-Diff Rate Estimates") subtitle("`subtitle'") 
*		graph export "5000_figures/`k'_days/DiD_graphs/DiD_r_`variant'`suffix'.pdf", replace
		graph export "6000_LaTeX/figures/DiD_r_`variant'`suffix'.eps", replace
		graph export "6000_LaTeX/figures/DiD_r_`variant'`suffix'.pdf", replace
	}

	grc1leg "5000_figures/`k'_days/DiD_v_`variant'`suffix'" "5000_figures/`k'_days/DiDiD_`variant'_v_lo`suffix'" "5000_figures/`k'_days/DiDiD_`variant'_v_hi`suffix'", col(3) name("grc_DiD_v_`variant'`suffix'", replace) title("Diff-in-Diff Volume Estimates") subtitle("`subtitle'") 
*	graph export "5000_figures/`k'_days/DiD_graphs/DiD_v_`variant'`suffix'.pdf", replace
	graph export "6000_LaTeX/figures/DiD_v_`variant'`suffix'.eps", replace
	graph export "6000_LaTeX/figures/DiD_v_`variant'`suffix'.pdf", replace
}

log close
