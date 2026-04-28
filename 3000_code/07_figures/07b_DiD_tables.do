* 07b_DiD_tables.do

clear all

* (1) HPCC cluster, and (2) personal machine: 
*cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/07b_DiD_tables", smcl replace

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

	* generating variant titles: 
	if ("`variant'" ==  "A00") local variant_title =  "A00, Full Sample, Unbalanced"
	if ("`variant'" == "main") local variant_title = "Main, Balanced"
	if ("`variant'" ==  "A01") local variant_title =  "A01, Balanced"
	if ("`variant'" ==  "A02") local variant_title =  "A02, Balanced"
	if ("`variant'" ==  "A03") local variant_title =  "A03, Log Outcomes, Balanced"
	if ("`variant'" ==  "A04") local variant_title =  "A04, Strongly Balanced"
	if ("`variant'" ==  "A05") local variant_title =  "A05, Single-Event Departments, Balanced"
	if ("`variant'" ==  "A06") local variant_title =  "A06, Multi-Event Deaprtments, Balanced"
	if ("`variant'" ==  "A07") local variant_title =  "A07, Only Statewide Departments, Balanced"
	if ("`variant'" ==  "A08") local variant_title =  "A08, Without Statewide Departments, Balanced"
	if ("`variant'" ==  "TWM") local variant_title =  "TWM, Heterogeneity Check, Balanced"
	
	*** Estimates for Panel A: DiD 
	local r = 1
	local v = 1
	
	* Constructing RATES matrix: 
	if ("`variant'" != "A03") {
		foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio {
			display ""
			display "Eq1 DiD: k=`k', variant=`variant', suffix=`suffix', outcome=`o'"
			
			* Coefficient Estimates: 
			estimates use "4000_outputs/`k'_days/eq1/`o'/DiD_`variant'`suffix'.ster"
			estimates describe using "4000_outputs/`k'_days/eq1/`o'/DiD_`variant'`suffix'.ster"
			estimate
			eststo r`r'
			
			* Pre-Event Averages: 
			use "2000_data/500_working/`k'_days/eq3/e_DiDiD`suffix'.dta" if (e_`o'_`variant'==1 & treat==1), replace
			sum `o' 
			estadd scalar treated_pre_mean = r(mean)

			* FE Indicators: 
			if (("`variant'" != "A01") & ("`variant'" != "A02")) {
				estadd local dept_event_year_fe "Yes"
				estadd local dept_event_fe "No"
				estadd local dow_fe "No"
			}
			
			if ("`variant'" == "A01") {
				estadd local dept_event_year_fe "No"
				estadd local dept_event_fe "Yes"
				estadd local dow_fe "No"
			}
			
			if ("`variant'" == "A02") {
				estadd local dept_event_year_fe "Yes"
				estadd local dept_event_fe "No"
				estadd local dow_fe "Yes"
			}
			
			estadd local year_mo_fe "Yes"
			estadd local holiday_fe "Yes"

			local ++r
		}
	}

	* Constructing VOLUMES matrix: 
	foreach o in n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
		display ""
		display "Eq1 DiD: k=`k', variant=`variant', suffix=`suffix', outcome=`o'"

		* Coefficient Estimates: 
		estimates use "4000_outputs/`k'_days/eq1/`o'/DiD_`variant'`suffix'.ster"
		estimates describe using "4000_outputs/`k'_days/eq1/`o'/DiD_`variant'`suffix'.ster"
		estimate
		eststo v`v'

		* Pre-Event Averages: 
		use "2000_data/500_working/`k'_days/eq3/e_DiDiD`suffix'.dta" if (e_`o'_`variant'==1 & treat==1), replace
		sum `o' 
		estadd scalar treated_pre_mean = r(mean)

		* FE Indicators: 
		if (("`variant'" != "A01") & ("`variant'" != "A02")) {
			estadd local dept_event_fe "Yes"
			estadd local dept_event_year_fe "No"
			estadd local dow_fe "No"
		}
		
		if ("`variant'" == "A01") {
			estadd local dept_event_fe "No"
			estadd local dept_event_year_fe "Yes"
			estadd local dow_fe "No"
		}
		
		if ("`variant'" == "A02") {
			estadd local dept_event_year_fe "Yes"
			estadd local dept_event_fe "No"
			estadd local dow_fe "Yes"
		}
		
		estadd local year_mo_fe "Yes"
		estadd local holiday_fe "Yes"

		local ++v
	}

	* Constructing SOLO DiD Table: (added extra \resizebox command to fix slideshow width)
	*local posthead_solo "\hline \multicolumn{@span}{l}{\textbf{Panel A: Diff-in-Diff}} \\"
	*\captionof{table}{Rate Outcomes, `variant_title'} 
	*\captionof{table}{Volume Outcomes, `variant_title'} 
	local prehead_r_solo "\resizebox{\textwidth}{!}{\begin{tabular}{l*{@M}{c}} \hline \\"
	local prehead_v_solo "\resizebox{\textwidth}{!}{\begin{tabular}{l*{@M}{c}} \hline \\"
	local postfoot_r_solo "\hline \end{tabular}}"
	local postfoot_v_solo "\hline \end{tabular}}"
	
	* SOLO non-A01 and non-A02 loop, with dept-event-year FEs
	if (("`variant'" != "A01") & ("`variant'" != "A02")) {
		if ("`variant'" != "A03") {
			* SOLO rates table, with captions
			esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'_solo.tex", replace ///
				keep(post0) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
				coef(post0 "Treatment") noobs ///
				stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
				mtitles("\shortstack{Stop\\Share}" "\shortstack{Search\\Share}" "\shortstack{Hit\\Share}" "\shortstack{Search\\Rate}" "\shortstack{Hit\\Rate}" "\shortstack{Hits\\Per Stop}") ///
				fragment booktabs nonotes prehead(`prehead_r_solo') postfoot(`postfoot_r_solo') 
		}
		
		* SOLO volumes table, with captions
		esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'_solo.tex", replace ///
			keep(post0) star(* 0.10 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
			coef(post0 "Treatment") noobs ///
			stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
			mtitles("\shortstack{All\\Stops}" "\shortstack{Black\\Stops}" "\shortstack{All\\Searches}" "\shortstack{Black\\Searches}" "\shortstack{All\\Hits}" "\shortstack{Black\\Hits}") ///
			fragment booktabs nonotes prehead(`prehead_v_solo') postfoot(`postfoot_v_solo')
	}

	* SOLO A01 loop, with dept-event FEs
	if ("`variant'" == "A01") {
		* SOLO rates table, with captions
		esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'_solo.tex", replace ///
			keep(post0) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
			coef(post0 "Treatment") noobs ///
			stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
			mtitles("\shortstack{Stop\\Share}" "\shortstack{Search\\Share}" "\shortstack{Hit\\Share}" "\shortstack{Search\\Rate}" "\shortstack{Hit\\Rate}" "\shortstack{Hits\\Per Stop}") ///
			fragment booktabs nonotes prehead(`prehead_r_solo') postfoot(`postfoot_r_solo') 
		
		* SOLO volumes table, with captions
		esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'_solo.tex", replace ///
			keep(post0) star(* 0.10 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
			coef(post0 "Treatment") noobs ///
			stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
			mtitles("\shortstack{All\\Stops}" "\shortstack{Black\\Stops}" "\shortstack{All\\Searches}" "\shortstack{Black\\Searches}" "\shortstack{All\\Hits}" "\shortstack{Black\\Hits}") ///
			fragment booktabs nonotes prehead(`prehead_v_solo') postfoot(`postfoot_v_solo')
	}

	* SOLO A02 loop, with dow FEs
	if ("`variant'" == "A02") {
		* SOLO rates table, with captions
		esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'_solo.tex", replace ///
			keep(post0) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
			coef(post0 "Treatment") noobs ///
			stats(treated_pre_mean dow_fe N, label("Treated Pre-Mean" "Day-of-Week" "Dept-Days:") fmt(%9.3g)) ///
			mtitles("\shortstack{Stop\\Share}" "\shortstack{Search\\Share}" "\shortstack{Hit\\Share}" "\shortstack{Search\\Rate}" "\shortstack{Hit\\Rate}" "\shortstack{Hits\\Per Stop}") ///
			fragment booktabs nonotes prehead(`prehead_r_solo') postfoot(`postfoot_r_solo') 
		
	* SOLO volumes table, with captions
	esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'_solo.tex", replace ///
		keep(post0) star(* 0.10 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
		coef(post0 "Treatment") noobs ///
		stats(treated_pre_mean dow_fe N, label("Treated Pre-Mean" "Day-of-Week" "Dept-Days:") fmt(%9.3g)) ///
		mtitles("\shortstack{All\\Stops}" "\shortstack{Black\\Stops}" "\shortstack{All\\Searches}" "\shortstack{Black\\Searches}" "\shortstack{All\\Hits}" "\shortstack{Black\\Hits}") ///
		fragment booktabs nonotes prehead(`prehead_v_solo') postfoot(`postfoot_v_solo')
	}

	
	
	*\captionof{table}{Rate Outcomes, `variant_title'} 
	*\captionof{table}{Volume Outcomes, `variant_title'} 
	* Constructing Panel A: DiD (added extra \resizebox command to fix slideshow width)
	local postheadA "\hline \multicolumn{@span}{l}{\textbf{Panel A: Diff-in-Diff}} \\"
	local preheadAr "\resizebox{\textwidth}{!}{\begin{tabular}{l*{@M}{c}} \hline \\"
	local preheadAv "\resizebox{\textwidth}{!}{\begin{tabular}{l*{@M}{c}} \hline \\"
	
	if ("`variant'" != "A03") {
		* rates table Panel A, with captions
		esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'.tex", replace ///
			keep(post0) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
			coef(post0 "Treatment") noobs ///
			mtitles("\shortstack{Stop\\Share}" "\shortstack{Search\\Share}" "\shortstack{Hit\\Share}" "\shortstack{Search\\Rate}" "\shortstack{Hit\\Rate}" "\shortstack{Hits\\Per Stop}") ///
			fragment booktabs nonotes prehead(`preheadAr') posthead(`postheadA')
	}
		
	* volumes table Panel A, with captions
	esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'.tex", replace ///
		keep(post0) star(* 0.10 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
		coef(post0 "Treatment") noobs ///
		mtitles("\shortstack{All\\Stops}" "\shortstack{Black\\Stops}" "\shortstack{All\\Searches}" "\shortstack{Black\\Searches}" "\shortstack{All\\Hits}" "\shortstack{Black\\Hits}") ///
		fragment booktabs nonotes prehead(`preheadAv') posthead(`postheadA')
	

	
	*** Estimates for Panel B: DiDiD 
	local r = 1
	local v = 1

	* Constructing RATES matrix: 
	if ("`variant'" != "A03") {
		foreach o in bstop_share bsearch_share bhit_share bsearch_rate bhit_rate bhit_bstop_ratio {
			display ""
			display "Eq3 DiDiD: k=`k', variant=`variant', suffix=`suffix', outcome=`o'"

			* Coefficient Estimates: 
			estimates use "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
			estimates describe using "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
			estimate
			eststo r`r'

			* Pre-Event Averages: 
			use "2000_data/500_working/`k'_days/eq3/e_DiDiD`suffix'.dta" if (e_`o'_`variant'==1 & treat==1), replace
			sum `o' 
			estadd scalar treated_pre_mean = r(mean)

			* FE Indicators: 
			if (("`variant'" != "A01") & ("`variant'" != "A02")) {
				estadd local dept_event_year_fe "Yes"
				estadd local dept_event_fe "No"
				estadd local dow_fe "No"
			}
			
			if ("`variant'" == "A01") {
				estadd local dept_event_year_fe "No"
				estadd local dept_event_fe "Yes"
				estadd local dow_fe "No"
			}
			
			if ("`variant'" == "A02") {
				estadd local dept_event_year_fe "Yes"
				estadd local dept_event_fe "No"
				estadd local dow_fe "Yes"
			}
			
			estadd local year_mo_fe "Yes"
			estadd local holiday_fe "Yes"

			local ++r
		}
	}

	* Constructing VOLUMES matrix: 
	foreach o in n_stops n_bstops n_searches n_bsearches n_hits n_bhits {
		display ""
		display "DiD: k=`k', variant=`variant', suffix=`suffix', outcome=`o'"

		* Coefficient Estimates: 
		estimates use "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
		estimates describe using "4000_outputs/`k'_days/eq3/`o'/DiDiD_`variant'`suffix'.ster"
		estimate
		eststo v`v'

		* Pre-Event Averages: 
		use "2000_data/500_working/`k'_days/eq3/e_DiDiD`suffix'.dta" if (e_`o'_`variant'==1 & treat==1), replace
		sum `o' 
		estadd scalar treated_pre_mean = r(mean)

		* FE Indicators: 
		if (("`variant'" != "A01") & ("`variant'" != "A02")) {
			estadd local dept_event_fe "Yes"
			estadd local dept_event_year_fe "No"
			estadd local dow_fe "No"
		}
		
		if ("`variant'" == "A01") {
			estadd local dept_event_fe "No"
			estadd local dept_event_year_fe "Yes"
			estadd local dow_fe "No"
		}
		
		if ("`variant'" == "A02") {
			estadd local dept_event_year_fe "Yes"
			estadd local dept_event_fe "No"
			estadd local dow_fe "Yes"
		}
		
		estadd local year_mo_fe "Yes"
		estadd local holiday_fe "Yes"

		local ++v
	}

	* Constructing Panel B: DiDiD
	local postheadB "\hline \multicolumn{@span}{l}{\textbf{Panel B: Heterogeneity by Scrutiny}} \\"
	local postfootBv "\hline \end{tabular}}"
	local postfootBr "\hline \end{tabular}}"
	
	* non-A01 and non-A02 loop, with dept-event-year FEs
	if (("`variant'" != "A01") & ("`variant'" != "A02")) {
		* rates table Panel B, with captions
		if ("`variant'" != "A03") {
			esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'.tex", append ///
				keep(post1 post2) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
				coef(post1 "Low Scrutiny" post2 "High Scrutiny") ///
				stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
				addnote("note test") ///
				fragment booktabs nonumbers nomtitles posthead(`postheadB') postfoot(`postfootBr')
		}
	
		* volumes table Panel B, with captions
		esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'.tex", append ///
			keep(post1 post2) star(* 0.1 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
			coef(post1 "Low Scrutiny" post2 "High Scrutiny") ///
			stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
			addnote("note test") ///
			fragment booktabs nonumbers nomtitles posthead(`postheadB') postfoot(`postfootBv')
	}

	* A01 loop, with dept-event FEs
	if ("`variant'" == "A01") {
		* rates table, Panel B, with captions
		esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'.tex", append ///
			keep(post1 post2) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
			coef(post1 "Low Scrutiny" post2 "High Scrutiny") ///
			stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
			addnote("note test") ///
			fragment booktabs nonumbers nomtitles posthead(`postheadB') postfoot(`postfootBr')
			
		* volumes table, Panel B, with captions
		esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'.tex", append ///
			keep(post1 post2) star(* 0.1 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
			coef(post1 "Low Scrutiny" post2 "High Scrutiny") ///
			stats(treated_pre_mean N, label("Treated Pre-Mean" "Dept-Days:") fmt(%9.3g)) ///
			addnote("note test") ///
			fragment booktabs nonumbers nomtitles posthead(`postheadB') postfoot(`postfootBv')
	}
	
	* A02 loop, with dow FEs
	if ("`variant'" == "A02") {
		* rates table, Panel B, with captions
		esttab r1 r2 r3 r4 r5 r6 using "6000_LaTeX/tables/DiD_rates_`variant'`suffix'.tex", append ///
			keep(post1 post2) star(* 0.1 ** 0.05 *** 0.01) b(%4.3f) se(%4.3f) /// 
			coef(post1 "Low Scrutiny" post2 "High Scrutiny") ///
			stats(treated_pre_mean dow_fe N, label("Treated Pre-Mean" "Day-of-Week" "Dept-Days:") fmt(%9.3g)) ///
			addnote("note test") ///
			fragment booktabs nonumbers nomtitles posthead(`postheadB') postfoot(`postfootBr')
			
		* volumes table, Panel B, with captions
		esttab v1 v2 v3 v4 v5 v6 using "6000_LaTeX/tables/DiD_volumes_`variant'`suffix'.tex", append ///
			keep(post1 post2) star(* 0.1 ** 0.05 *** 0.01) b(%7.3g) se(%4.3g) ///
			coef(post1 "Low Scrutiny" post2 "High Scrutiny") ///
			stats(treated_pre_mean dow_fe N, label("Treated Pre-Mean" "Day-of-Week" "Dept-Days:") fmt(%9.3g)) ///
			addnote("note test") ///
			fragment booktabs nonumbers nomtitles posthead(`postheadB') postfoot(`postfootBv')
	}
}

log close
