* 06b_estudy_graphing.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
*cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/06_graphs/06_SMCL_logs/06b_estudy_graphing", smcl replace

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
local obs=2*`k'

* suffix: 
local suffix = "_full"




foreach variant in A00 main A01 A02 A03 A04 A05 A06 A07 A08 {
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
*	if ("`variant'" ==  "TWM") local subtitle =  "TWM, Heterogeneity Check, Balanced"
	
	foreach eq in eq2 eq4 {
		foreach o in n_stops n_bstops n_searches n_bsearches n_hits n_bhits bstop_share bsearch_share bsearch_rate bhit_share bhit_rate bhit_bstop_ratio {
			if (("`variant'" == "A03") & (("`o'" == "bstop_share") | ("`o'" == "bsearch_share") | ("`o'" == "bsearch_rate") | ("`o'" == "bhit_share") | ("`o'" == "bhit_rate") | ("`o'" == "bhit_bstop_ratio"))) {
				continue
			}
			
			* Defining graph name: 
			if ("`eq'" == "eq2") local name = "`o'_estudy"
			if ("`eq'" == "eq4") local name = "`o'_estudy_int_lo"
			
			* Loading estimates: 
			if ("`eq'" == "eq2") estimates use "4000_outputs/`k'_days/`eq'/`o'/estudy_`variant'`suffix'.ster"
			if ("`eq'" == "eq4") estimates use "4000_outputs/`k'_days/`eq'/`o'/estudy_int_`variant'`suffix'.ster"
			estimate

			* Creating placeholder variables for x-axis: 
			set obs `obs'
			qui gen x = _n
			
			*Defining graph titles: 
			if ("`eq'" == "eq2") local title = "Eq2: All Events" 
			if ("`eq'" == "eq4") local title = "Eq4: Low Scrutiny" 
			
			* Defining y-titles: 
			local ytitle ""
			if ("`eq'" == "eq2") local ytitle "Coef. Estimate"
			
			if ("`eq'" == "eq2") {
				* Constructing x-label bins for plotting: 
				qui 	gen b_`k' = _b[13.b_`k'] in 1
				qui replace b_`k' = _b[14.b_`k'] in 2
				qui replace b_`k' = _b[15.b_`k'] in 3
				qui replace b_`k' = _b[16.b_`k'] in 4
				qui replace b_`k' = _b[17.b_`k'] in 5
				qui replace b_`k' = _b[18.b_`k'] in 6
				qui replace b_`k' = _b[19.b_`k'] in 7
				qui replace b_`k' = _b[20.b_`k'] in 8
				qui replace b_`k' = _b[21.b_`k'] in 9
				qui replace b_`k' = _b[22.b_`k'] in 10
				qui replace b_`k' = _b[23.b_`k'] in 11
				qui replace b_`k' = _b[24.b_`k'] in 12
				qui replace b_`k' = _b[25.b_`k'] in 13
				* T-1 bin: 
				qui replace b_`k' = _b[26.b_`k'] in 14
				qui replace b_`k' = _b[27.b_`k'] in 15
				qui replace b_`k' = _b[28.b_`k'] in 16
				qui replace b_`k' = _b[29.b_`k'] in 17
				qui replace b_`k' = _b[30.b_`k'] in 18
				qui replace b_`k' = _b[31.b_`k'] in 19
				qui replace b_`k' = _b[32.b_`k'] in 20
				qui replace b_`k' = _b[33.b_`k'] in 21
				qui replace b_`k' = _b[34.b_`k'] in 22
				qui replace b_`k' = _b[35.b_`k'] in 23
				qui replace b_`k' = _b[36.b_`k'] in 24
				qui replace b_`k' = _b[37.b_`k'] in 25
				qui replace b_`k' = _b[38.b_`k'] in 26
				qui replace b_`k' = _b[39.b_`k'] in 27
				qui replace b_`k' = _b[40.b_`k'] in 28

				* Constructing b_`k' standard errors: 
				qui 	gen b_`k'_se= _se[13.b_`k'] in 1
				qui replace b_`k'_se= _se[14.b_`k'] in 2
				qui replace b_`k'_se= _se[15.b_`k'] in 3
				qui replace b_`k'_se= _se[16.b_`k'] in 4
				qui replace b_`k'_se= _se[17.b_`k'] in 5
				qui replace b_`k'_se= _se[18.b_`k'] in 6
				qui replace b_`k'_se= _se[19.b_`k'] in 7
				qui replace b_`k'_se= _se[20.b_`k'] in 8
				qui replace b_`k'_se= _se[21.b_`k'] in 9
				qui replace b_`k'_se= _se[22.b_`k'] in 10
				qui replace b_`k'_se= _se[23.b_`k'] in 11
				qui replace b_`k'_se= _se[24.b_`k'] in 12
				qui replace b_`k'_se= _se[25.b_`k'] in 13
				* T-1 bin: 
				qui replace b_`k'_se= _se[26.b_`k'] in 14
				qui replace b_`k'_se= _se[27.b_`k'] in 15
				qui replace b_`k'_se= _se[28.b_`k'] in 16
				qui replace b_`k'_se= _se[29.b_`k'] in 17
				qui replace b_`k'_se= _se[30.b_`k'] in 18
				qui replace b_`k'_se= _se[31.b_`k'] in 19
				qui replace b_`k'_se= _se[32.b_`k'] in 20
				qui replace b_`k'_se= _se[33.b_`k'] in 21
				qui replace b_`k'_se= _se[34.b_`k'] in 22
				qui replace b_`k'_se= _se[35.b_`k'] in 23
				qui replace b_`k'_se= _se[36.b_`k'] in 24
				qui replace b_`k'_se= _se[37.b_`k'] in 25
				qui replace b_`k'_se= _se[38.b_`k'] in 26
				qui replace b_`k'_se= _se[39.b_`k'] in 27
				qui replace b_`k'_se= _se[40.b_`k'] in 28
			}

			if ("`eq'" == "eq4") {
				* Constructing x-label bins for plotting: 
				qui 	gen b_`k' = _b[13.b_`k'_low] in 1
				qui replace b_`k' = _b[14.b_`k'_low] in 2
				qui replace b_`k' = _b[15.b_`k'_low] in 3
				qui replace b_`k' = _b[16.b_`k'_low] in 4
				qui replace b_`k' = _b[17.b_`k'_low] in 5
				qui replace b_`k' = _b[18.b_`k'_low] in 6
				qui replace b_`k' = _b[19.b_`k'_low] in 7
				qui replace b_`k' = _b[20.b_`k'_low] in 8
				qui replace b_`k' = _b[21.b_`k'_low] in 9
				qui replace b_`k' = _b[22.b_`k'_low] in 10
				qui replace b_`k' = _b[23.b_`k'_low] in 11
				qui replace b_`k' = _b[24.b_`k'_low] in 12
				qui replace b_`k' = _b[25.b_`k'_low] in 13
				* T-1 bin: 
				qui replace b_`k' = _b[26.b_`k'_low] in 14
				qui replace b_`k' = _b[27.b_`k'_low] in 15
				qui replace b_`k' = _b[28.b_`k'_low] in 16
				qui replace b_`k' = _b[29.b_`k'_low] in 17
				qui replace b_`k' = _b[30.b_`k'_low] in 18
				qui replace b_`k' = _b[31.b_`k'_low] in 19
				qui replace b_`k' = _b[32.b_`k'_low] in 20
				qui replace b_`k' = _b[33.b_`k'_low] in 21
				qui replace b_`k' = _b[34.b_`k'_low] in 22
				qui replace b_`k' = _b[35.b_`k'_low] in 23
				qui replace b_`k' = _b[36.b_`k'_low] in 24
				qui replace b_`k' = _b[37.b_`k'_low] in 25
				qui replace b_`k' = _b[38.b_`k'_low] in 26
				qui replace b_`k' = _b[39.b_`k'_low] in 27
				qui replace b_`k' = _b[40.b_`k'_low] in 28

				* Constructing b_`k' standard errors: 
				qui 	gen b_`k'_se= _se[13.b_`k'_low] in 1
				qui replace b_`k'_se= _se[14.b_`k'_low] in 2
				qui replace b_`k'_se= _se[15.b_`k'_low] in 3
				qui replace b_`k'_se= _se[16.b_`k'_low] in 4
				qui replace b_`k'_se= _se[17.b_`k'_low] in 5
				qui replace b_`k'_se= _se[18.b_`k'_low] in 6
				qui replace b_`k'_se= _se[19.b_`k'_low] in 7
				qui replace b_`k'_se= _se[20.b_`k'_low] in 8
				qui replace b_`k'_se= _se[21.b_`k'_low] in 9
				qui replace b_`k'_se= _se[22.b_`k'_low] in 10
				qui replace b_`k'_se= _se[23.b_`k'_low] in 11
				qui replace b_`k'_se= _se[24.b_`k'_low] in 12
				qui replace b_`k'_se= _se[25.b_`k'_low] in 13
				* T-1 bin: 
				qui replace b_`k'_se= _se[26.b_`k'_low] in 14
				qui replace b_`k'_se= _se[27.b_`k'_low] in 15
				qui replace b_`k'_se= _se[28.b_`k'_low] in 16
				qui replace b_`k'_se= _se[29.b_`k'_low] in 17
				qui replace b_`k'_se= _se[30.b_`k'_low] in 18
				qui replace b_`k'_se= _se[31.b_`k'_low] in 19
				qui replace b_`k'_se= _se[32.b_`k'_low] in 20
				qui replace b_`k'_se= _se[33.b_`k'_low] in 21
				qui replace b_`k'_se= _se[34.b_`k'_low] in 22
				qui replace b_`k'_se= _se[35.b_`k'_low] in 23
				qui replace b_`k'_se= _se[36.b_`k'_low] in 24
				qui replace b_`k'_se= _se[37.b_`k'_low] in 25
				qui replace b_`k'_se= _se[38.b_`k'_low] in 26
				qui replace b_`k'_se= _se[39.b_`k'_low] in 27
				qui replace b_`k'_se= _se[40.b_`k'_low] in 28

				* Constructing b_`k' interaction coef estimates: 
				qui 	gen b_`k'_int= _b[13.b_`k'_high] in 1
				qui replace b_`k'_int= _b[14.b_`k'_high] in 2
				qui replace b_`k'_int= _b[15.b_`k'_high] in 3
				qui replace b_`k'_int= _b[16.b_`k'_high] in 4
				qui replace b_`k'_int= _b[17.b_`k'_high] in 5
				qui replace b_`k'_int= _b[18.b_`k'_high] in 6
				qui replace b_`k'_int= _b[19.b_`k'_high] in 7
				qui replace b_`k'_int= _b[20.b_`k'_high] in 8
				qui replace b_`k'_int= _b[21.b_`k'_high] in 9
				qui replace b_`k'_int= _b[22.b_`k'_high] in 10
				qui replace b_`k'_int= _b[23.b_`k'_high] in 11
				qui replace b_`k'_int= _b[24.b_`k'_high] in 12
				qui replace b_`k'_int= _b[25.b_`k'_high] in 13
				* T-1 bin: 
				qui replace b_`k'_int= _b[26.b_`k'_high] in 14
				qui replace b_`k'_int= _b[27.b_`k'_high] in 15
				qui replace b_`k'_int= _b[28.b_`k'_high] in 16
				qui replace b_`k'_int= _b[29.b_`k'_high] in 17
				qui replace b_`k'_int= _b[30.b_`k'_high] in 18
				qui replace b_`k'_int= _b[31.b_`k'_high] in 19
				qui replace b_`k'_int= _b[32.b_`k'_high] in 20
				qui replace b_`k'_int= _b[33.b_`k'_high] in 21
				qui replace b_`k'_int= _b[34.b_`k'_high] in 22
				qui replace b_`k'_int= _b[35.b_`k'_high] in 23
				qui replace b_`k'_int= _b[36.b_`k'_high] in 24
				qui replace b_`k'_int= _b[37.b_`k'_high] in 25
				qui replace b_`k'_int= _b[38.b_`k'_high] in 26
				qui replace b_`k'_int= _b[39.b_`k'_high] in 27
				qui replace b_`k'_int= _b[40.b_`k'_high] in 28

				* Constructing b_`k'_int standard errors: 
				qui 	gen b_`k'_int_se= _se[13.b_`k'_high] in 1
				qui replace b_`k'_int_se= _se[14.b_`k'_high] in 2
				qui replace b_`k'_int_se= _se[15.b_`k'_high] in 3
				qui replace b_`k'_int_se= _se[16.b_`k'_high] in 4
				qui replace b_`k'_int_se= _se[17.b_`k'_high] in 5
				qui replace b_`k'_int_se= _se[18.b_`k'_high] in 6
				qui replace b_`k'_int_se= _se[19.b_`k'_high] in 7
				qui replace b_`k'_int_se= _se[20.b_`k'_high] in 8
				qui replace b_`k'_int_se= _se[21.b_`k'_high] in 9
				qui replace b_`k'_int_se= _se[22.b_`k'_high] in 10
				qui replace b_`k'_int_se= _se[23.b_`k'_high] in 11
				qui replace b_`k'_int_se= _se[24.b_`k'_high] in 12
				qui replace b_`k'_int_se= _se[25.b_`k'_high] in 13
				* T-1 bin: 
				qui replace b_`k'_int_se= _se[26.b_`k'_high] in 14
				qui replace b_`k'_int_se= _se[27.b_`k'_high] in 15
				qui replace b_`k'_int_se= _se[28.b_`k'_high] in 16
				qui replace b_`k'_int_se= _se[29.b_`k'_high] in 17
				qui replace b_`k'_int_se= _se[30.b_`k'_high] in 18
				qui replace b_`k'_int_se= _se[31.b_`k'_high] in 19
				qui replace b_`k'_int_se= _se[32.b_`k'_high] in 20
				qui replace b_`k'_int_se= _se[33.b_`k'_high] in 21
				qui replace b_`k'_int_se= _se[34.b_`k'_high] in 22
				qui replace b_`k'_int_se= _se[35.b_`k'_high] in 23
				qui replace b_`k'_int_se= _se[36.b_`k'_high] in 24
				qui replace b_`k'_int_se= _se[37.b_`k'_high] in 25
				qui replace b_`k'_int_se= _se[38.b_`k'_high] in 26
				qui replace b_`k'_int_se= _se[39.b_`k'_high] in 27
				qui replace b_`k'_int_se= _se[40.b_`k'_high] in 28

				* Adding and subtracting to make error-bands: (1.96 = 95%) CI, (1.645 = 90% CI)
				qui gen b_`k'_int_upper = b_`k'_int + (1.96*b_`k'_int_se) 
				qui gen b_`k'_int_lower = b_`k'_int - (1.96*b_`k'_int_se) 
			}

			* Adding and subtracting to make error-bands: (1.96 = 95%) CI, (1.645 = 90% CI)
			qui gen b_`k'_upper = b_`k' + (1.96*b_`k'_se)
			qui gen b_`k'_lower = b_`k' - (1.96*b_`k'_se)

			* Plotting + exporting b_`k' estimates: 
			twoway (scatter b_`k' x, mcolor(stc1)) || (rspike b_`k'_upper b_`k'_lower x, lcolor(stc1)), ///
				leg(off) name(`name', replace) title("`title'", size(vlarge)) subtitle("") ///
				ytitle("`ytitle'", size(medlarge)) xtitle("`k'-Day Buckets", size(medlarge)) ///
				xline(14.5, lcolor(red) lwidth(0.1pt)) yline(0, lcolor(red) lwidth(0.1pt)) ///
				xlab(1 "-14" 3 "-12" 5 "-10" 7 "-8" 9 "-6" 11 "-4" 13 "-2" 15 "0" 17 "2" 19 "4" 21 "6" 23 "8" 25 "10" 27 "12", labsize(med) nogrid) ylab(., labsize(med)) /// 
				saving("5000_figures/`k'_days/`eq'/`o'/estudy_`variant'`suffix'", replace) 
				
			* exporting Eq2 graph to be plotted separately: 
			if ("`eq'" == "eq2") {
				* SOLO volume outcomes: 
				if ("`o'" == "n_stops") 			local solo_title = "Total Stop Volume"
				if ("`o'" == "n_bstops") 			local solo_title = "Black Stop Volume"
				if ("`o'" == "n_searches") 			local solo_title = "Total Search Volume"
				if ("`o'" == "n_bsearches") 		local solo_title = "Black Search Volume"
				if ("`o'" == "n_hits") 				local solo_title = "Total Hit Volume"
				if ("`o'" == "n_bhits") 			local solo_title = "Black Hit Volume"

				* SOLO rate outcomes: 
				if ("`o'" == "bstop_share") 		local solo_title = "Black Stop-Share"
				if ("`o'" == "bsearch_share") 		local solo_title = "Black Search-Share"
				if ("`o'" == "bsearch_rate") 		local solo_title = "Black Search Rate"
				if ("`o'" == "bhit_share") 			local solo_title = "Black Hit-Share"
				if ("`o'" == "bhit_rate") 			local solo_title = "Black Hit Rate"
				if ("`o'" == "bhit_bstop_ratio") 	local solo_title = "Black Hits-to-Stops Ratio"

				twoway (scatter b_`k' x, mcolor(stc1)) || (rspike b_`k'_upper b_`k'_lower x, lcolor(stc1)), ///
					leg(off) name(`name', replace) title("`solo_title'", size(vlarge)) subtitle("") ///
					ytitle("`ytitle'", size(medlarge)) xtitle("`k'-Day Buckets", size(medlarge)) ///
					xline(14.5, lcolor(red) lwidth(0.1pt)) yline(0, lcolor(red) lwidth(0.1pt)) ///
					xlab(1 "-14" 3 "-12" 5 "-10" 7 "-8" 9 "-6" 11 "-4" 13 "-2" 15 "0" 17 "2" 19 "4" 21 "6" 23 "8" 25 "10" 27 "12", labsize(med) nogrid) /// 
					saving("5000_figures/`k'_days/`eq'/`o'/solo_estudy_`variant'`suffix'", replace) 
					
				graph export "6000_LaTeX/figures/solo_`o'_`variant'`suffix'.eps", replace
				graph export "6000_LaTeX/figures/solo_`o'_`variant'`suffix'.pdf", replace
			}

			graph drop _all

			if ("`eq'" == "eq4") {
				local name "`o'_estudy_int_hi"
				local title "Eq4: High Scrutiny"
				* Plotting + exporting b_`k'_int estimates: 
				twoway (scatter b_`k'_int x, mcolor(stc1)) || (rspike b_`k'_int_upper b_`k'_int_lower x, lcolor(stc1)), ///
					leg(off) name(`name', replace) title("`title'", size(vlarge)) subtitle("") ///
					xtitle("`k'-Day Buckets", size(medlarge)) ///
					xline(14.5, lcolor(red) lwidth(0.1pt)) yline(0, lcolor(red) lwidth(0.1pt)) ///
					xlab(1 "-14" 3 "-12" 5 "-10" 7 "-8" 9 "-6" 11 "-4" 13 "-2" 15 "0" 17 "2" 19 "4" 21 "6" 23 "8" 25 "10" 27 "12", labsize(med) nogrid) ylab(., labsize(med)) /// 
					saving("5000_figures/`k'_days/`eq'/`o'/estudy_int_`variant'`suffix'", replace) nodraw 
				drop b_`k'_int b_`k'_int_se b_`k'_int_upper b_`k'_int_lower
			}

			* Dropping everything so loop can re-run
			drop x b_`k' b_`k'_se b_`k'_upper b_`k'_lower
		}
	}
	* Combining Graphs
	foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
		if (("`variant'" == "A03") & (("`o'" == "bstop_share") | ("`o'" == "bsearch_share") | ("`o'" == "bsearch_rate") | ("`o'" == "bhit_share") | ("`o'" == "bhit_rate") | ("`o'" == "bhit_bstop_ratio"))) {
			continue
		}
		
		* full estudies: 
		graph combine "5000_figures/`k'_days/eq2/`o'/estudy_`variant'`suffix'" "5000_figures/`k'_days/eq4/`o'/estudy_`variant'`suffix'" "5000_figures/`k'_days/eq4/`o'/estudy_int_`variant'`suffix'", col(3) ycommon name("`o'_`variant'", replace) title("") subtitle("") xsize(10)  
*		graph export "5000_figures/`k'_days/estudy_graphs/`o'_`variant'`suffix'.pdf", replace
		graph export "6000_LaTeX/figures/`o'_`variant'`suffix'.eps", replace
		graph export "6000_LaTeX/figures/`o'_`variant'`suffix'.pdf", replace
	}
	graph drop _all
}

* combining SOLO graphs for slideshow: 
graph combine "5000_figures/`k'_days/eq2/n_stops/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/n_bstops/solo_estudy_main`suffix'", col(2) name("solo_stops", replace) title("") subtitle("") xsize(10)
graph export "6000_LaTeX/figures/solo_stops`suffix'.eps", replace
graph export "6000_LaTeX/figures/solo_stops`suffix'.pdf", replace

graph combine "5000_figures/`k'_days/eq2/n_searches/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/n_bsearches/solo_estudy_main`suffix'", col(2) name("solo_searches", replace) title("") subtitle("") xsize(10)
graph export "6000_LaTeX/figures/solo_searches`suffix'.eps", replace
graph export "6000_LaTeX/figures/solo_searches`suffix'.pdf", replace

graph combine "5000_figures/`k'_days/eq2/n_hits/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/n_bhits/solo_estudy_main`suffix'", col(2) name("solo_hits", replace) title("") subtitle("") xsize(10)
graph export "6000_LaTeX/figures/solo_hits`suffix'.eps", replace
graph export "6000_LaTeX/figures/solo_hits`suffix'.pdf", replace

graph combine "5000_figures/`k'_days/eq2/bstop_share/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/bsearch_share/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/bhit_share/solo_estudy_main`suffix'", col(3) name("solo_shares", replace) title("") subtitle("") xsize(10)
graph export "6000_LaTeX/figures/solo_shares`suffix'.eps", replace
graph export "6000_LaTeX/figures/solo_shares`suffix'.pdf", replace

graph combine "5000_figures/`k'_days/eq2/bsearch_rate/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/bhit_rate/solo_estudy_main`suffix'" "5000_figures/`k'_days/eq2/bhit_bstop_ratio/solo_estudy_main`suffix'", col(3) name("solo_rates", replace) title("") subtitle("") xsize(10)
graph export "6000_LaTeX/figures/solo_rates`suffix'.eps", replace
graph export "6000_LaTeX/figures/solo_rates`suffix'.pdf", replace

log close
