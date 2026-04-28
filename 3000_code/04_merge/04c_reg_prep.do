* 04c_reg_prep.do

clear all

*ssc install winsor2

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/04_merge/04_SMCL_logs/04c_reg_prep", smcl replace

*ssc install jwdid
*ssc install csdid
*ssc install hdfe
*ssc install drdid 

set varabbrev off

* Dates for consideration: 
	* 01Jan2011=18628, 31Dec2020=22280

* bin-size: 
local k=14

* event-window, +/- b: 
local b=14

use fe_id num_dept state county_name date subject_race black n_stops search_conducted contraband_found rep_annually rep_monthly type search_basis edate FEgtrend_SOPP_merge reg_etime* reg_edate* scr_* sample0 sample1 sample2 sample3 sample4 dl_postm nl_postm pre_gt_dept_lower pre_gt_name_lower if ((date>=18628-134) & (date<=22280+135)) using "2000_data/400_base/10_merged/merged_gtrends", replace

display ""
display "Regression Prep Loop, `k'-Day Buckets:"

* note: should I drop if search=NA and contraband=NA earlier? 
tab search_conducted contraband_found

* keep if (st_dept*date: SOPP-only) OR ((st_dept*date: FE+SOPP) & (edate==nearest any))
keep if (FEgtrend_SOPP_merge==1) | ((FEgtrend_SOPP_merge==3) & (edate==reg_edate0))

* dropping annual, monthly reporters: 
drop if (rep_annually==1) 
drop if (rep_monthly==1) 

* dropping pedestrian stops: 
drop if (type=="pedestrian")

* dropping plain-view, consent searches: 
drop if (search_basis==0) 
drop if (search_basis==1)

* dropping non-(white, black, hispanic, API, indigenous peoples, middle eastern, other) race stops: 
	* i.e. dropping stops that have no race data available 
drop if (!inlist(subject_race, 1, 2, 3, 4, 5, 6, 7))

drop (rep_annually rep_monthly type search_basis subject_race)

**************************************************
*** CONSTRUCTING OUTCOME VARIABLE ***
**************************************************

gen stop=1
gen bstop=black 

gen search=(search_conducted==1)
gen bsearch=(black*search)

gen bsr=.
replace bsr=0 if (bstop==1)
replace bsr=1 if (search==1) & (black==1)

gen bss=.
replace bss=0 if (search==1)
replace bss=1 if (search==1) & (black==1)

gen hit=(contraband_found==1)
gen bhit=(black*hit)

gen bhr=.
replace bhr=0 if (search==1) & (black==1) 
replace bhr=1 if (hit==1) & (black==1)

gen bhs=.
replace bhs=0 if (hit==1)
replace bhs=1 if (hit==1) & (black==1)

gen bhsr=.
replace bhsr=0 if (bstop==1) 
replace bhsr=1 if (bhit==1)

gen treat0=(reg_edate0!=.)
gen post0=0 
replace post0=1 if (date >= reg_edate0) & (treat0==1)

sum (stop bstop search bsearch hit bhit bsr bss bhr bhs bhsr fe_id reg_edate0 scr_* sample0 treat0 post0 num_dept date dl_postm nl_postm)

**************************************************
*** COLLAPSING OBS TO DEPT-DAY ***
**************************************************
collapse (sum) n_stops=stop n_bstops=bstop n_searches=search n_bsearches=bsearch n_hits=hit n_bhits=bhit (mean) bstop_share=bstop bsearch_rate=bsr bsearch_share=bss bhit_rate=bhr bhit_share=bhs bhit_bstop_ratio=bhsr fe_id reg_edate0 scr_* sample0 treat0 post0 dl_postm nl_postm pre_gt_dept_lower pre_gt_name_lower, by(num_dept date)

sum (n_stops n_bstops n_searches n_bsearches n_hits n_bhits bstop_share bsearch_rate bsearch_share bhit_rate bhit_share bhit_bstop_ratio reg_edate0 scr_* sample0 treat0 post0 num_dept date dl_postm nl_postm pre_gt_dept_lower pre_gt_name_lower)

la var n_stops "01. how many drivers did the department stop?"
la var n_bstops "02. how many black drivers did the department stop?"
la var bstop_share "03. what is the black-share of stops?"
la var n_searches "04. how many vehicle searches did the department conduct?"
la var n_bsearches "05. how many black-vehicle searches did the department conduct?"
la var bsearch_rate "06. how many black-stops are searched?"
la var bsearch_share "07. what is the black-share of searches?"
la var n_hits "08. how many vehicle searches found contraband?"
la var n_bhits "09. how many black-vehicle searches found contraband?"
la var bhit_rate "10. what is the success rate of black searches?"
la var bhit_share "11. what is the black-share of hits?"
la var bhit_bstop_ratio "12. out of all black stops, what is the hit rate?"

* Seasonality: (1) quarter, (2) month, (3) week, (4) day-of-week
gen quarter=quarter(date)
gen month=month(date)
gen week=week(date)
gen dow=dow(date)

* Time Trend: (0) date, (1) year, (2) year+quarter, (3) year+month, (4) year+week 
gen year=year(date)
gen yq=yq(year, quarter)
gen ym=ym(year, month)
gen yw=yw(year, week)

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

* scr={0,1,2}, finding and using max for each event (constant), 0 for control group
	* should it be 0? Are non-scrutinized events also 0? 
		* (this should not be something I am unsure about)
foreach scr in scr_nl scr_nu scr_dl scr_du {
	bysort fe_id: egen temp_max=max(`scr')
	replace `scr'=temp_max 
	replace `scr'=0 if `scr'==.
	drop temp_*
}

* need fe_id==0 for control groups: 
replace fe_id=0 if (fe_id==.)

sum _all

* Assn: if max=min, no variation in days (months)--> monthly (annual) reporter
gen stop_day=day(date)
gen stop_month=month(date)
gen stop_year=year(date)

bysort num_dept stop_month: egen max_stop_day=max(stop_day)
bysort num_dept stop_month: egen min_stop_day=min(stop_day)
gen temp_stop_day_diff=max_stop_day - min_stop_day
gen rep_monthly=(temp_stop_day_diff==0)
drop temp_* max_stop_day min_stop_day

bysort num_dept stop_year: egen max_stop_month=max(stop_month)
bysort num_dept stop_year: egen min_stop_month=min(stop_month)
gen temp_stop_month_diff=max_stop_month - min_stop_month
gen rep_annually=(temp_stop_month_diff==0)
drop temp_* max_stop_month min_stop_month 

drop stop_day stop_month stop_year

drop if ((rep_annually==1) | (rep_monthly==1))
drop if rep_monthly==1

* Nevada Highway Patrol 2/2012 slipped through
drop if ((num_dept==2948) & (month==2) & (year==2012))

**************************************************
*** GENERATING CATEGORICAL HOLIDAY VARIABLE ***
**************************************************
* MEMORIAL DAYS: weekend + holiday monday
gen memorial=0
replace memorial=1 if inlist(date, td(30May2011), (td(30May2011)-1), (td(30May2011)-2), (td(30May2011)-3)) 
replace memorial=1 if inlist(date, td(28May2012), (td(28May2012)-1), (td(28May2012)-2), (td(28May2012)-3)) 
replace memorial=1 if inlist(date, td(27May2013), (td(27May2013)-1), (td(27May2013)-2), (td(27May2013)-3)) 
replace memorial=1 if inlist(date, td(26May2014), (td(26May2014)-1), (td(26May2014)-2), (td(26May2014)-3)) 
replace memorial=1 if inlist(date, td(25May2015), (td(25May2015)-1), (td(25May2015)-2), (td(25May2015)-3)) 
replace memorial=1 if inlist(date, td(30May2016), (td(30May2016)-1), (td(30May2016)-2), (td(30May2016)-3)) 
replace memorial=1 if inlist(date, td(29May2017), (td(29May2017)-1), (td(29May2017)-2), (td(29May2017)-3)) 
replace memorial=1 if inlist(date, td(28May2018), (td(28May2018)-1), (td(28May2018)-2), (td(28May2018)-3)) 
replace memorial=1 if inlist(date, td(27May2019), (td(27May2019)-1), (td(27May2019)-2), (td(27May2019)-3)) 
replace memorial=1 if inlist(date, td(25May2020), (td(25May2020)-1), (td(25May2020)-2), (td(25May2020)-3)) 

* LABOR DAYS: weekend + holiday monday
gen labor=0
replace labor=1 if inlist(date, td(05Sep2011), (td(05Sep2011)-1), (td(05Sep2011)-2), (td(05Sep2011)-3)) 
replace labor=1 if inlist(date, td(03Sep2012), (td(03Sep2012)-1), (td(03Sep2012)-2), (td(03Sep2012)-3)) 
replace labor=1 if inlist(date, td(02Sep2013), (td(02Sep2013)-1), (td(02Sep2013)-2), (td(02Sep2013)-3)) 
replace labor=1 if inlist(date, td(01Sep2014), (td(01Sep2014)-1), (td(01Sep2014)-2), (td(01Sep2014)-3)) 
replace labor=1 if inlist(date, td(07Sep2015), (td(07Sep2015)-1), (td(07Sep2015)-2), (td(07Sep2015)-3)) 
replace labor=1 if inlist(date, td(05Sep2016), (td(05Sep2016)-1), (td(05Sep2016)-2), (td(05Sep2016)-3)) 
replace labor=1 if inlist(date, td(04Sep2017), (td(04Sep2017)-1), (td(04Sep2017)-2), (td(04Sep2017)-3)) 
replace labor=1 if inlist(date, td(03Sep2018), (td(03Sep2018)-1), (td(03Sep2018)-2), (td(03Sep2018)-3)) 
replace labor=1 if inlist(date, td(02Sep2019), (td(02Sep2019)-1), (td(02Sep2019)-2), (td(02Sep2019)-3)) 
replace labor=1 if inlist(date, td(07Sep2020), (td(07Sep2020)-1), (td(07Sep2020)-2), (td(07Sep2020)-3)) 

* FOURTHS OF JULY WEEKS: 4th + surrounding days (and weekend if applicable)
gen fourth=0
replace fourth=1 if inlist(date, td(01Jul2011), td(02Jul2011), td(03Jul2011), td(04Jul2011))
replace fourth=1 if inlist(date, td(03Jul2012), td(04Jul2012))
replace fourth=1 if inlist(date, td(03Jul2013), td(04Jul2013))
replace fourth=1 if inlist(date, td(03Jul2014), td(04Jul2014), td(05Jul2014), td(06Jul2014))
replace fourth=1 if inlist(date, td(02Jul2015), td(03Jul2015), td(04Jul2015), td(05Jul2015))
replace fourth=1 if inlist(date, td(01Jul2016), td(02Jul2016), td(03Jul2016), td(04Jul2016))
replace fourth=1 if inlist(date, td(03Jul2017), td(04Jul2017))
replace fourth=1 if inlist(date, td(03Jul2018), td(04Jul2018))
replace fourth=1 if inlist(date, td(03Jul2019), td(04Jul2019))
replace fourth=1 if inlist(date, td(02Jul2020), td(03Jul2020), td(04Jul2020), td(05Jul2020))

* THANKSGIVING WEEKEND: We, Th, Fr, Sa & Su
gen tg=0 
replace tg=1 if inlist(date, td(24Nov2011), (td(24Nov2011)-1), (td(24Nov2011)+1), (td(24Nov2011)+2), (td(24Nov2011)+3)) 
replace tg=1 if inlist(date, td(22Nov2012), (td(22Nov2012)-1), (td(22Nov2012)+1), (td(22Nov2012)+2), (td(22Nov2012)+3)) 
replace tg=1 if inlist(date, td(28Nov2013), (td(28Nov2013)-1), (td(28Nov2013)+1), (td(28Nov2013)+2), (td(28Nov2013)+3)) 
replace tg=1 if inlist(date, td(27Nov2014), (td(27Nov2014)-1), (td(27Nov2014)+1), (td(27Nov2014)+2), (td(27Nov2014)+3)) 
replace tg=1 if inlist(date, td(26Nov2015), (td(26Nov2015)-1), (td(26Nov2015)+1), (td(26Nov2015)+2), (td(26Nov2015)+3)) 
replace tg=1 if inlist(date, td(24Nov2016), (td(24Nov2016)-1), (td(24Nov2016)+1), (td(24Nov2016)+2), (td(24Nov2016)+3)) 
replace tg=1 if inlist(date, td(23Nov2017), (td(23Nov2017)-1), (td(23Nov2017)+1), (td(23Nov2017)+2), (td(23Nov2017)+3)) 
replace tg=1 if inlist(date, td(22Nov2018), (td(22Nov2018)-1), (td(22Nov2018)+1), (td(22Nov2018)+2), (td(22Nov2018)+3)) 
replace tg=1 if inlist(date, td(28Nov2019), (td(28Nov2019)-1), (td(28Nov2019)+1), (td(28Nov2019)+2), (td(28Nov2019)+3)) 
replace tg=1 if inlist(date, td(26Nov2020), (td(26Nov2020)-1), (td(26Nov2020)+1), (td(26Nov2020)+2), (td(26Nov2020)+3)) 

* CHRISTMAS: Christmas Day + Eve 
gen xmas=0
replace xmas=1 if inlist(date, td(24Dec2011), td(25Dec2011))
replace xmas=1 if inlist(date, td(24Dec2012), td(25Dec2012))
replace xmas=1 if inlist(date, td(24Dec2013), td(25Dec2013))
replace xmas=1 if inlist(date, td(24Dec2014), td(25Dec2014))
replace xmas=1 if inlist(date, td(24Dec2015), td(25Dec2015))
replace xmas=1 if inlist(date, td(24Dec2016), td(25Dec2016))
replace xmas=1 if inlist(date, td(24Dec2017), td(25Dec2017))
replace xmas=1 if inlist(date, td(24Dec2018), td(25Dec2018))
replace xmas=1 if inlist(date, td(24Dec2019), td(25Dec2019))
replace xmas=1 if inlist(date, td(24Dec2020), td(25Dec2020))

* NEW YEARS: New Years Day + Eve
gen nye=0
replace nye=1 if (date==td(01Jan2011)) 
replace nye=1 if inlist(date, td(31Dec2011), td(01Jan2012))
replace nye=1 if inlist(date, td(31Dec2012), td(01Jan2013))
replace nye=1 if inlist(date, td(31Dec2013), td(01Jan2014))
replace nye=1 if inlist(date, td(31Dec2014), td(01Jan2015))
replace nye=1 if inlist(date, td(31Dec2015), td(01Jan2016))
replace nye=1 if inlist(date, td(31Dec2016), td(01Jan2017))
replace nye=1 if inlist(date, td(31Dec2017), td(01Jan2018))
replace nye=1 if inlist(date, td(31Dec2018), td(01Jan2019))
replace nye=1 if inlist(date, td(31Dec2019), td(01Jan2020))

* COMBINING: 
gen holidays=0
replace holidays=1 if (memorial==1)
replace holidays=2 if (labor==1)
replace holidays=3 if (fourth==1)
replace holidays=4 if (tg==1)
replace holidays=5 if (xmas==1)
replace holidays=6 if (nye==1)
*drop memorial labor fourth tg xmas nye 

**************************************************
*** PROBLEMATIC DEPARTMENTS ***
**************************************************
* SOME DEPARTMENTS BOTH TREATED AND UNTREATED: 
bysort num_dept: egen avg_treat=mean(treat0)
gen treat=0
replace treat=1 if (avg_treat>0)
drop if (treat==1) & (treat0==0)
drop avg_treat

* I WANT TO SEE STATEWIDE vs NOT: 
bysort num_dept: egen avg_nstops=mean(n_stops)
gen statewide=0
replace statewide=1 if inlist(num_dept, 7, 2971, 2970, 2953, 2950, 124, 2959, 2976, 2685, 2, 1149, 2962, 18, 1017, 83, 1390, 128, 2948, 2978, 2449, 129, 2979, 2944, 2413, 1406, 2731, 2973, 2958, 1391, 2946)

* GENERATING UNION/INTERSECTION SCRUTINY ***
*gen n_scr=scr_nl
*gen d_scr=scr_dl
*gen or_scr=0
*replace or_scr=1 if (scr_nl==1) | (scr_dl==1)
*replace or_scr=2 if (scr_nl==2) | (scr_dl==2)
*gen and_scr=0
*replace and_scr=1 if (scr_nl==1) & (scr_dl==1)
*replace and_scr=2 if (scr_nl==2) & (scr_dl==2)

* GENERATING EVENT_ID: 
egen event_id=group(reg_edate0 num_dept) 
replace event_id=0 if (event_id==.)

**************************************************
*** DROPPING PROBLEMATIC DEPARTMENTS ***
**************************************************
* no post-event data for ALREADY TREATED dept: DROP
drop if (num_dept==9 & reg_edate0==td(29oct2018))
drop if (num_dept==124 & reg_edate0==td(12mar2019))
drop if (num_dept==960 & reg_edate0==td(06jun2018))
drop if (num_dept==2969 & reg_edate0==td(17oct2018))

* no pre-event data for WILL BE TREATED dept: DROP
drop if (num_dept==960 & reg_edate0==td(24nov2011))
drop if (num_dept==1387)

* only pre-event data for WILL BE TREATED dept: MAKE CONTROL
qui replace treat=0 if (num_dept==1099 | num_dept==1391)
qui replace post0=0 if (num_dept==1099 | num_dept==1391)
qui replace reg_edate0=. if (num_dept==1099 | num_dept==1391)

* only post-data for NOT YET TREATED dept: DROP
drop if (num_dept==1390 & reg_edate0==td(20dec2012))

* only post-data for ALREADY TREATED dept: DROP
drop if (num_dept==2963)

*** multi-event-depts ***
egen temp_tag=tag(num_dept reg_edate0) if (date==reg_edate0)
bysort num_dept: egen num_events=sum(temp_tag) 
gen multi_dept=(num_events>1)
drop temp_tag

* dept only has post-obs, no preperiod stop data: DROP
qui drop if (num_dept==82)

* dept*event only has post-obs: DROP
qui drop if (num_dept==1365 & reg_edate0==td(13jun2012))

* dept*event only has pre-obs: DROP
	*** NOTE: if I am dropping dept*event, is that correct? 
		*** or should I instead be shifting to different event within dept? 
qui drop if (num_dept==1365 & reg_edate0==td(22jul2014))

*** dept-events within one bin (15 days) of one another ***
qui gen scr=0 
qui replace scr=1 if (treat==1)
qui replace scr=2 if inlist(event_id, 79, 21, 77, 18, 87, 16, 64, 75, 31, 35, 53, 63, 13, 70, 58, 1, 65, 7, 72, 23, 80, 76, 34, 27, 54, 32, 62, 61, 3, 81, 36)

* department-based scrutiny: scr2
qui gen scr2=0
qui replace scr2=1 if (treat==1)
qui replace scr2=2 if inlist(event_id, 79, 21, 77, 18, 87, 16, 64, 75, 31, 35, 53, 63, 13, 70, 58, 1, 65, 7, 72, 23, 80, 76, 34, 27, 54, 32, 62, 61, 3, 81, 36)

* CA_los angeles police department: 9, (14jan2011 and 24jan2011)
qui replace reg_edate0=td(14jan2011) if (num_dept==9 & reg_edate0==td(24jan2011))
qui replace event_id=1 if (event_id==2)

* IL_chicago police department: 960, (01sep2013 and 07sep2013)
qui replace reg_edate0=td(01sep2013) if (num_dept==960 & reg_edate0==td(07sep2013))
qui replace event_id=30 if (event_id==31)

* MD_maryland state police: 1390, (18mar2014 and 21mar2014)
qui replace reg_edate0=td(18mar2014) if (num_dept==1390 & reg_edate0==td(21mar2014))
qui replace event_id=38 if (event_id==39)

* scrutiny correction because of paired-event-combining: 
	* (unless I define scr after changing event_id above)
qui replace scr=2 if (num_dept==9 & reg_edate0==td(14jan2011))
qui replace scr=2 if (num_dept==960 & reg_edate0==td(01sep2013))

**************************************************
*** GENERATING BINS ***
**************************************************
qui gen reg_etime0=date - reg_edate0 
drop if ((reg_etime0<-26*`k') | (reg_etime0>26*`k')) & (reg_etime0!=.)
gen b_`k' = 0
replace b_`k'=1 if ((reg_etime0>=-26*`k') & (reg_etime0<-25*`k'))
replace b_`k'=2 if ((reg_etime0>=-25*`k') & (reg_etime0<-24*`k'))
replace b_`k'=3 if ((reg_etime0>=-24*`k') & (reg_etime0<-23*`k'))
replace b_`k'=4 if ((reg_etime0>=-23*`k') & (reg_etime0<-22*`k'))
replace b_`k'=5 if ((reg_etime0>=-22*`k') & (reg_etime0<-21*`k'))
replace b_`k'=6 if ((reg_etime0>=-21*`k') & (reg_etime0<-20*`k'))
replace b_`k'=7 if ((reg_etime0>=-20*`k') & (reg_etime0<-19*`k'))
replace b_`k'=8 if ((reg_etime0>=-19*`k') & (reg_etime0<-18*`k'))
replace b_`k'=9 if ((reg_etime0>=-18*`k') & (reg_etime0<-17*`k'))
replace b_`k'=10 if ((reg_etime0>=-17*`k') & (reg_etime0<-16*`k'))
replace b_`k'=11 if ((reg_etime0>=-16*`k') & (reg_etime0<-15*`k'))
replace b_`k'=12 if ((reg_etime0>=-15*`k') & (reg_etime0<-14*`k'))

replace b_`k'=13 if ((reg_etime0>=-14*`k') & (reg_etime0<-13*`k'))
replace b_`k'=14 if ((reg_etime0>=-13*`k') & (reg_etime0<-12*`k'))
replace b_`k'=15 if ((reg_etime0>=-12*`k') & (reg_etime0<-11*`k'))
replace b_`k'=16 if ((reg_etime0>=-11*`k') & (reg_etime0<-10*`k'))
replace b_`k'=17 if ((reg_etime0>=-10*`k') & (reg_etime0<-9*`k'))
replace b_`k'=18 if ((reg_etime0>=-9*`k') & (reg_etime0<-8*`k'))
replace b_`k'=19 if ((reg_etime0>=-8*`k') & (reg_etime0<-7*`k'))
replace b_`k'=20 if ((reg_etime0>=-7*`k') & (reg_etime0<-6*`k'))
replace b_`k'=21 if ((reg_etime0>=-6*`k') & (reg_etime0<-5*`k'))
replace b_`k'=22 if ((reg_etime0>=-5*`k') & (reg_etime0<-4*`k'))
replace b_`k'=23 if ((reg_etime0>=-4*`k') & (reg_etime0<-3*`k'))
replace b_`k'=24 if ((reg_etime0>=-3*`k') & (reg_etime0<-2*`k'))
replace b_`k'=25 if ((reg_etime0>=-2*`k') & (reg_etime0<-1*`k'))
replace b_`k'=26 if ((reg_etime0>=-1*`k') & (reg_etime0<0*`k'))
*** TREATMENT OCCURS AT b_`k' = 26.999 ***
replace b_`k'=27 if ((reg_etime0>=0*`k') & (reg_etime0<1*`k'))
replace b_`k'=28 if ((reg_etime0>=1*`k') & (reg_etime0<2*`k'))
replace b_`k'=29 if ((reg_etime0>=2*`k') & (reg_etime0<3*`k'))
replace b_`k'=30 if ((reg_etime0>=3*`k') & (reg_etime0<4*`k'))
replace b_`k'=31 if ((reg_etime0>=4*`k') & (reg_etime0<5*`k'))
replace b_`k'=32 if ((reg_etime0>=5*`k') & (reg_etime0<6*`k'))
replace b_`k'=33 if ((reg_etime0>=6*`k') & (reg_etime0<7*`k'))
replace b_`k'=34 if ((reg_etime0>=7*`k') & (reg_etime0<8*`k'))
replace b_`k'=35 if ((reg_etime0>=8*`k') & (reg_etime0<9*`k'))
replace b_`k'=36 if ((reg_etime0>=9*`k') & (reg_etime0<10*`k'))
replace b_`k'=37 if ((reg_etime0>=10*`k') & (reg_etime0<11*`k'))
replace b_`k'=38 if ((reg_etime0>=11*`k') & (reg_etime0<12*`k'))
replace b_`k'=39 if ((reg_etime0>=12*`k') & (reg_etime0<13*`k'))
replace b_`k'=40 if ((reg_etime0>=13*`k') & (reg_etime0<14*`k'))

replace b_`k'=41 if ((reg_etime0>=14*`k') & (reg_etime0<15*`k'))
replace b_`k'=42 if ((reg_etime0>=15*`k') & (reg_etime0<16*`k'))
replace b_`k'=43 if ((reg_etime0>=16*`k') & (reg_etime0<17*`k'))
replace b_`k'=44 if ((reg_etime0>=17*`k') & (reg_etime0<18*`k'))
replace b_`k'=45 if ((reg_etime0>=18*`k') & (reg_etime0<19*`k'))
replace b_`k'=46 if ((reg_etime0>=19*`k') & (reg_etime0<20*`k'))
replace b_`k'=47 if ((reg_etime0>=20*`k') & (reg_etime0<21*`k'))
replace b_`k'=48 if ((reg_etime0>=21*`k') & (reg_etime0<22*`k'))
replace b_`k'=49 if ((reg_etime0>=22*`k') & (reg_etime0<23*`k'))
replace b_`k'=50 if ((reg_etime0>=23*`k') & (reg_etime0<24*`k'))
replace b_`k'=51 if ((reg_etime0>=24*`k') & (reg_etime0<25*`k'))
replace b_`k'=52 if ((reg_etime0>=25*`k') & (reg_etime0<=26*`k'))

* Philadelphia Police Department: DNC 2016, abnormal stop days
gen Philly_DNC=((num_dept==2957) & inlist(date, td(24Jul2016), td(25Jul2016), td(26Jul2016), td(27Jul2016), td(28Jul2016), td(29Jul2016), td(30Jul2016), td(31Jul2016)))

* New Orleans Police Department: Bourbon Street shooting, abnormal stop days
gen NOLA_Bourbon=((num_dept==1148) & inlist(date, td(29Jun2014), td(30Jun2014), td(01Jul2014), td(02Jul2014), td(03Jul2014)))

* VA State Patrol has some VERY unusual days, and is also evidently a weekly reporter: 
*drop if (num_dept==2971) & (n_searches>250)
drop if (num_dept==2971)

* Highly abnormal single month for this dept: 
gen WA_mar_2017=0
replace WA_mar_2017=1 if (num_dept==2976 & month==3 & year==2017)

* FL very strange from 1/1/2016 until 11/1/2016: 
gen FL_strange=0
replace FL_strange=1 if (num_dept==124 & (date>=td(01jan2016) & date<td(01nov2016)))

*** Trim AZ (num_dept==2)
gen day=day(date)
drop if ((day==15) & (num_dept==2))

* TX Garland - very unlikely stop volumes outside of this range: 
drop if (num_dept==2965 & (date<19292 | date>21366))

* bellwood IL average stops go up sharply after 10/2016
gen bellwood_strange=0
replace bellwood_strange=1 if ((num_dept==177) & (date>=20728))

**************************************************
*** UNRELIABLE_SEARCHES & UNRELIABLE_HITS 
**************************************************
* halves
bysort num_dept: egen med_date = median(date)
gen half = 1 if (date <= med_date)
replace half = 2 if half==.

* stop totals: 
bysort num_dept: egen stop_tot = sum(n_stops) 
bysort num_dept half: egen stop_tot_half = sum(n_stops) 
bysort num_dept year: egen stop_tot_year = sum(n_stops) 
bysort num_dept yq: egen stop_tot_yq = sum(n_stops) 
bysort num_dept ym: egen stop_tot_ym = sum(n_stops) 
bysort num_dept yw: egen stop_tot_yw = sum(n_stops) 

* bstop totals: 
bysort num_dept: egen bstop_tot = sum(n_bstops) 
bysort num_dept half: egen bstop_tot_half = sum(n_bstops) 
bysort num_dept year: egen bstop_tot_year = sum(n_bstops) 
bysort num_dept yq: egen bstop_tot_yq = sum(n_bstops) 
bysort num_dept ym: egen bstop_tot_ym = sum(n_bstops) 
bysort num_dept yw: egen bstop_tot_yw = sum(n_bstops) 

* search totals: 
bysort num_dept: egen search_tot = sum(n_searches) 
bysort num_dept half: egen search_tot_half = sum(n_searches)
bysort num_dept year: egen search_tot_year = sum(n_searches) 
bysort num_dept yq: egen search_tot_yq = sum(n_searches) 
bysort num_dept ym: egen search_tot_ym = sum(n_searches) 
bysort num_dept yw: egen search_tot_yw = sum(n_searches) 

* bsearch totals: 
bysort num_dept: egen bsearch_tot = sum(n_bsearches) 
bysort num_dept half: egen bsearch_tot_half = sum(n_bsearches)
bysort num_dept year: egen bsearch_tot_year = sum(n_bsearches) 
bysort num_dept yq: egen bsearch_tot_yq = sum(n_bsearches) 
bysort num_dept ym: egen bsearch_tot_ym = sum(n_bsearches) 
bysort num_dept yw: egen bsearch_tot_yw = sum(n_bsearches) 

* hit totals: 
bysort num_dept: egen hit_tot = sum(n_hits) 
bysort num_dept half: egen hit_tot_half = sum(n_hits)
bysort num_dept year: egen hit_tot_year = sum(n_hits) 
bysort num_dept yq: egen hit_tot_yq = sum(n_hits) 
bysort num_dept ym: egen hit_tot_ym = sum(n_hits) 
bysort num_dept yw: egen hit_tot_yw = sum(n_hits) 

* bhit totals: 
bysort num_dept: egen bhit_tot = sum(n_bhits) 
bysort num_dept half: egen bhit_tot_half = sum(n_bhits)
bysort num_dept year: egen bhit_tot_year = sum(n_bhits) 
bysort num_dept yq: egen bhit_tot_yq = sum(n_bhits) 
bysort num_dept ym: egen bhit_tot_ym = sum(n_bhits) 
bysort num_dept yw: egen bhit_tot_yw = sum(n_bhits) 

* black stop rates: 
gen avg_br = bstop_tot / stop_tot 
gen avg_br_half = bstop_tot_half / stop_tot_half
gen avg_br_year = bstop_tot_year / stop_tot_year 
gen avg_br_yq = bstop_tot_yq / stop_tot_yq 
gen avg_br_ym = bstop_tot_ym / stop_tot_ym 
gen avg_br_yw = bstop_tot_yw / stop_tot_yw 
gen avg_br_day = n_bstops / n_stops 

* search rates: 
gen avg_sr = search_tot / stop_tot 
gen avg_sr_half = search_tot_half / stop_tot_half
gen avg_sr_year = search_tot_year / stop_tot_year 
gen avg_sr_yq = search_tot_yq / stop_tot_yq 
gen avg_sr_ym = search_tot_ym / stop_tot_ym 
gen avg_sr_yw = search_tot_yw / stop_tot_yw 
gen avg_sr_day = n_searches / n_stops 

* bsearch rates: 
gen avg_bsr = bsearch_tot / bstop_tot 
gen avg_bsr_half = bsearch_tot_half / bstop_tot_half
gen avg_bsr_year = bsearch_tot_year / bstop_tot_year 
gen avg_bsr_yq = bsearch_tot_yq / bstop_tot_yq 
gen avg_bsr_ym = bsearch_tot_ym / bstop_tot_ym 
gen avg_bsr_yw = bsearch_tot_yw / bstop_tot_yw 
gen avg_bsr_day = n_bsearches / n_bstops 

* hit rates: 
gen avg_hr = hit_tot / search_tot 
gen avg_hr_half = hit_tot_half / search_tot_half 
gen avg_hr_year = hit_tot_year / search_tot_year 
gen avg_hr_yq = hit_tot_yq / search_tot_yq 
gen avg_hr_ym = hit_tot_ym / search_tot_ym 
gen avg_hr_yw = hit_tot_yw / search_tot_yw 
gen avg_hr_day = n_hits / n_searches 

* bhit rates: 
gen avg_bhr = bhit_tot / bsearch_tot 
gen avg_bhr_half = bhit_tot_half / bsearch_tot_half 
gen avg_bhr_year = bhit_tot_year / bsearch_tot_year 
gen avg_bhr_yq = bhit_tot_yq / bsearch_tot_yq 
gen avg_bhr_ym = bhit_tot_ym / bsearch_tot_ym 
gen avg_bhr_yw = bhit_tot_yw / bsearch_tot_yw 
gen avg_bhr_day = n_bhits / n_bsearches 

*** UNRELIABLE BLACK STOPS: 
* overall average: 4.43383%
	* saying less than 1/10th --> non-reporting searches
sum avg_br if bstop_tot!=0
local nbstop_threshold = 1/(r(mean)/20)
display `nbstop_threshold'

gen unreliable_bstops = 0 
replace unreliable_bstops = 1 if (bstop_tot==0)
replace unreliable_bstops = 1 if (stop_tot >= `nbstop_threshold') & (avg_br==0) 
replace unreliable_bstops = 1 if (stop_tot_half >= `nbstop_threshold') & (avg_br_half==0) 
replace unreliable_bstops = 1 if (stop_tot_year >= `nbstop_threshold') & (avg_br_year==0) 
replace unreliable_bstops = 1 if (stop_tot_yq >= `nbstop_threshold') & (avg_br_yq==0) 
replace unreliable_bstops = 1 if (stop_tot_ym >= `nbstop_threshold') & (avg_br_ym==0) 
*replace unreliable_bstops = 1 if (stop_tot_yw >= `nbstop_threshold') & (avg_br_yw==0) 
*replace unreliable_bstops = 1 if (n_stops >= `nbstop_threshold') & (avg_br_day==0) 

* same, but for 1 single search and double the threshold: (some sneaky ones make it through):
replace unreliable_bstops = 1 if (stop_tot >= 5*`nbstop_threshold') & (bstop_tot==1) 
replace unreliable_bstops = 1 if (stop_tot_half >= 5*`nbstop_threshold') & (bstop_tot_half==1) 
replace unreliable_bstops = 1 if (stop_tot_year >= 5*`nbstop_threshold') & (bstop_tot_year==1) 
replace unreliable_bstops = 1 if (stop_tot_yq >= 5*`nbstop_threshold') & (bstop_tot_yq==1) 
replace unreliable_bstops = 1 if (stop_tot_ym >= 5*`nbstop_threshold') & (bstop_tot_ym==1) 
*replace unreliable_bstops = 1 if (stop_tot_yw >= 5*`nbstop_threshold') & (bstop_tot_yw==1) 
*replace unreliable_bstops = 1 if (n_stops >= 5*`nbstop_threshold') & (n_bstops==1) 

* overall average: 4.43383%
	* saying less than 1/10th --> non-reporting searches
sum avg_sr if search_tot!=0
local ns_threshold = 1/(r(mean)/20)
display `ns_threshold'

*** UNRELIABLE SEARCHES: 
gen unreliable_searches = 0 
replace unreliable_searches = 1 if (search_tot==0)
replace unreliable_searches = 1 if (stop_tot >= `ns_threshold') & (avg_sr==0) 
replace unreliable_searches = 1 if (stop_tot_half >= `ns_threshold') & (avg_sr_half==0) 
replace unreliable_searches = 1 if (stop_tot_year >= `ns_threshold') & (avg_sr_year==0) 
replace unreliable_searches = 1 if (stop_tot_yq >= `ns_threshold') & (avg_sr_yq==0) 
replace unreliable_searches = 1 if (stop_tot_ym >= `ns_threshold') & (avg_sr_ym==0) 
*replace unreliable_searches = 1 if (stop_tot_yw >= `ns_threshold') & (avg_sr_yw==0) 
*replace unreliable_searches = 1 if (n_stops >= `ns_threshold') & (avg_sr_day==0) 

* same, but for 1 single search and double the threshold: (some sneaky ones make it through):
replace unreliable_searches = 1 if (stop_tot >= 5*`ns_threshold') & (search_tot==1) 
replace unreliable_searches = 1 if (stop_tot_half >= 5*`ns_threshold') & (search_tot_half==1) 
replace unreliable_searches = 1 if (stop_tot_year >= 5*`ns_threshold') & (search_tot_year==1) 
replace unreliable_searches = 1 if (stop_tot_yq >= 5*`ns_threshold') & (search_tot_yq==1) 
replace unreliable_searches = 1 if (stop_tot_ym >= 5*`ns_threshold') & (search_tot_ym==1) 
*replace unreliable_searches = 1 if (stop_tot_yw >= 5*`ns_threshold') & (search_tot_yw==1) 
*replace unreliable_searches = 1 if (n_stops >= 5*`ns_threshold') & (n_searches==1) 

*** UNRELIABLE BLACK SEARCHES: 
* overall average: 6.81167%
	* saying less than 1/10th --> non-reporting searches
sum avg_bsr if bsearch_tot!=0
local nbs_threshold = 1/(r(mean)/20)
display `nbs_threshold'

*	gen unreliable_bsearches = 0 
*	replace unreliable_bsearches = 1 if (bsearch_tot==0)
*	replace unreliable_bsearches = 1 if (bstop_tot >= `nbs_threshold') & (avg_bsr==0) 
*	replace unreliable_bsearches = 1 if (bstop_tot_half >= `nbs_threshold') & (avg_bsr_half==0) 
*	replace unreliable_bsearches = 1 if (bstop_tot_year >= `nbs_threshold') & (avg_bsr_year==0) 
*	replace unreliable_bsearches = 1 if (bstop_tot_yq >= `nbs_threshold') & (avg_bsr_yq==0) 
*	replace unreliable_bsearches = 1 if (bstop_tot_ym >= `nbs_threshold') & (avg_bsr_ym==0) 
*	*replace unreliable_bsearches = 1 if (bstop_tot_yw >= `nbs_threshold') & (avg_bsr_yw==0) 
*	*replace unreliable_bsearches = 1 if (n_bstops >= `nbs_threshold') & (avg_bsr_day==0) 

*	* same, but for 1 single search and double the threshold: (some sneaky ones make it through):
*	replace unreliable_bsearches = 1 if (bstop_tot >= 5*`nbs_threshold') & (bsearch_tot==1) 
*	replace unreliable_bsearches = 1 if (bstop_tot_half >= 5*`nbs_threshold') & (bsearch_tot_half==1) 
*	replace unreliable_bsearches = 1 if (bstop_tot_year >= 5*`nbs_threshold') & (bsearch_tot_year==1) 
*	replace unreliable_bsearches = 1 if (bstop_tot_yq >= 5*`nbs_threshold') & (bsearch_tot_yq==1) 
*	replace unreliable_bsearches = 1 if (bstop_tot_ym >= 5*`nbs_threshold') & (bsearch_tot_ym==1) 
*	*replace unreliable_bsearches = 1 if (bstop_tot_yw >= 5*`nbs_threshold') & (bsearch_tot_yw==1) 
*	*replace unreliable_bsearches = 1 if (n_bstops >= 5*`nbs_threshold') & (n_bsearches==1) 

*** UNRELIABLE HITS: 
* overall average: 32.88078%
	* saying less than 1/10th --> non-reporting contraband
sum avg_hr if hit_tot!=0
local nh_threshold = 1/(r(mean)/20)
display `nh_threshold'

gen unreliable_hits = 0 
replace unreliable_hits = 1 if (hit_tot==0)
replace unreliable_hits = 1 if (search_tot >= `nh_threshold') & (avg_hr==0) 
replace unreliable_hits = 1 if (search_tot_half >= `nh_threshold') & (avg_hr_half==0) 
replace unreliable_hits = 1 if (search_tot_year >= `nh_threshold') & (avg_hr_year==0) 
replace unreliable_hits = 1 if (search_tot_yq >= `nh_threshold') & (avg_hr_yq==0) 
replace unreliable_hits = 1 if (search_tot_ym >= `nh_threshold') & (avg_hr_ym==0) 
*replace unreliable_hits = 1 if (search_tot_yw >= `nh_threshold') & (avg_hr_yw==0) 
*replace unreliable_hits = 1 if (n_searches >= `nh_threshold') & (avg_hr_day==0) 

* same, but for 1 single search and double the threshold: (some sneaky ones make it through):
replace unreliable_hits = 1 if (search_tot >= 5*`nh_threshold') & (hit_tot==1) 
replace unreliable_hits = 1 if (search_tot_half >= 5*`nh_threshold') & (hit_tot_half==1) 
replace unreliable_hits = 1 if (search_tot_year >= 5*`nh_threshold') & (hit_tot_year==1) 
replace unreliable_hits = 1 if (search_tot_yq >= 5*`nh_threshold') & (hit_tot_yq==1) 
replace unreliable_hits = 1 if (search_tot_ym >= 5*`nh_threshold') & (hit_tot_ym==1) 
*replace unreliable_hits = 1 if (search_tot_yw >= 5*`nh_threshold') & (hit_tot_yw==1) 
*replace unreliable_hits = 1 if (n_searches >= 5*`nh_threshold') & (n_hits==1) 

*** UNRELIABLE BLACK HITS: 
* overall average: 34.33532%
	* saying less than 1/10th --> non-reporting contraband
sum avg_bhr if bhit_tot!=0
local nbh_threshold = 1/(r(mean)/20)
display `nbh_threshold'

*	gen unreliable_bhits = 0 
*	replace unreliable_bhits = 1 if (bhit_tot==0)
*	replace unreliable_bhits = 1 if (bsearch_tot >= `nbh_threshold') & (avg_bhr==0) 
*	replace unreliable_bhits = 1 if (bsearch_tot_half >= `nbh_threshold') & (avg_bhr_half==0) 
*	replace unreliable_bhits = 1 if (bsearch_tot_year >= `nbh_threshold') & (avg_bhr_year==0) 
*	replace unreliable_bhits = 1 if (bsearch_tot_yq >= `nbh_threshold') & (avg_bhr_yq==0) 
*	replace unreliable_bhits = 1 if (bsearch_tot_ym >= `nbh_threshold') & (avg_bhr_ym==0) 
*	*replace unreliable_bhits = 1 if (bsearch_tot_yw >= `nbh_threshold') & (avg_bhr_yw==0) 
*	*replace unreliable_bhits = 1 if (n_bsearches >= `nbh_threshold') & (avg_bhr_day==0) 

*	* same, but for 1 single search and double the threshold: (some sneaky ones make it through):
*	replace unreliable_bhits = 1 if (bsearch_tot >= 5*`nbh_threshold') & (bhit_tot==1) 
*	replace unreliable_bhits = 1 if (bsearch_tot_half >= 5*`nbh_threshold') & (bhit_tot_half==1) 
*	replace unreliable_bhits = 1 if (bsearch_tot_year >= 5*`nbh_threshold') & (bhit_tot_year==1) 
*	replace unreliable_bhits = 1 if (bsearch_tot_yq >= 5*`nbh_threshold') & (bhit_tot_yq==1) 
*	replace unreliable_bhits = 1 if (bsearch_tot_ym >= 5*`nbh_threshold') & (bhit_tot_ym==1) 
*	*replace unreliable_bhits = 1 if (bsearch_tot_yw >= 5*`nbh_threshold') & (bhit_tot_yw==1) 
*	*replace unreliable_bhits = 1 if (n_bsearches >= 5*`nbh_threshold') & (n_bhits==1) 

drop hit_tot* search_tot* stop_tot* avg_sr* avg_hr* half med_date 

drop pre_gt_dept_lower pre_gt_name_lower dl_postm 

* want to keep this for new k-density scrutiny bin justification: 
*drop nl_postm 

drop sample0 scr_nl scr_nu scr_dl scr_du

drop bhit_tot* bsearch_tot* bstop_tot* avg_bsr* avg_bhr* 

**************************************************
*** BALANCING *** --- note: treatment occurs at (b_`k'==26.999)
**************************************************
gen weak_bal = 0
replace weak_bal = 26 if (treat==0)
gen str_bal = 0
replace str_bal = 26 if (treat==0)

forvalues bal=1(1)26 {
	* WEAK BALANCE = bal if #bal bins NONEMPTY: 
	egen temp_tag=tag(num_dept reg_edate0 b_`k') if ((b_`k'<=26+`bal') & (b_`k'>=27-`bal'))
	bysort num_dept reg_edate0: egen nonempty_bins=sum(temp_tag)
	replace weak_bal=`bal' if (nonempty_bins==2*`bal')
	drop temp_tag nonempty_bins 

	* WEAK BALANCE = bal if #bal bins FULL: 
	egen temp_tag = tag(num_dept reg_edate0 b_`k' date) if ((b_`k'<=26+`bal') & (b_`k'>=27-`bal'))
	bysort num_dept reg_edate0: egen full_bins=sum(temp_tag)
	replace str_bal=`bal' if (full_bins==14*2*`bal')
	drop temp_tag full_bins 
}
tab weak_bal 
tab str_bal

* generating pseudo-departments (unique combinations of edate+dept)
replace reg_edate0 = 999999999 if treat==0
egen pseudo_dept = group(num_dept reg_edate0)

egen pseudo_year = group(pseudo_dept year)
egen dept_year = group(num_dept year)

rename ym year_mo

* generating log(Y) for volume-based outcomes: 
gen log_n_stops = ln(n_stops)
gen log_n_bstops = ln(n_bstops)
gen log_n_searches = ln(n_searches)
gen log_n_bsearches = ln(n_bsearches)
gen log_n_hits = ln(n_hits)
gen log_n_bhits = ln(n_bhits)

* CT Hartford has very abnormal stop patterns, and even moreso for searches: 
drop if (num_dept==90) & (date<19663)
drop if (num_dept==90) & (year>2015)

* generating time-invariant weights for each num_dept (need to be constant within dept): 
bysort num_dept: egen n_stops_weight = mean(n_stops)
bysort num_dept: egen n_searches_weight = mean(n_searches)
bysort num_dept: egen n_hits_weight = mean(n_hits)
bysort num_dept: egen n_bstops_weight = mean(n_bstops)
bysort num_dept: egen n_bsearches_weight = mean(n_bsearches)
bysort num_dept: egen n_bhits_weight = mean(n_bhits)

* defining lower and upper event-window bookends: 
replace b_`k' = 1 if ((b_`k' < 27-`b') & (b_`k' >= 1))
replace b_`k' = 52 if ((b_`k' > 26+`b') & (b_`k' <= 52))

* generating post1 and post2 for low vs high scrutiny 
gen low = (scr==1)
gen high = (scr==2)
gen post1 = post0 * low
gen post2 = post0 * high
gen b_`k'_low = b_`k'*low
gen b_`k'_high = b_`k'*high
drop (low high)

sum _all

* Labeling Variables for Table: 
la var treat "Treatment Status:"
la var scr "Scrutiny Level:"
la var bstop_share "Black Stop-Share"
la var bsearch_share "Black Search-Share"
la var bhit_share "Black Hit-Share"
la var bsearch_rate "Black Search Rate"
la var bhit_rate "Black Hit Rate"
la var bhit_bstop_ratio "Black Hits-to-Stops"
la var n_stops "Stops"
la var n_bstops "Black Stops"
la var n_searches "Searches"
la var n_bsearches "Black Searches"
la var n_hits "Hits"
la var n_bhits "Black Hits"

* Labeling Values for Table: 
label define treatment_status 0 "Never-Treated" 1 "Treated" 
label define scrutiny_levels 1 "Low Scrutiny" 2 "High Scrutiny" 
label values treat treatment_status
label values scr scrutiny_levels

save "2000_data/500_working/`k'_days/reg_prep.dta", replace

log close

** department-based scrutiny: scr2
*qui gen scr2=0
*qui replace scr2=1 if (treat==1)
*qui replace scr2=2 if inlist(event_id, 79, 21, 77, 18, 87, 16, 64, 75, 31, 35, 53, 63, 13, 70, 58, 1, 65, 7, 72, 23, 80, 76, 34, 27, 54, 32, 62, 61, 3, 81, 36)
