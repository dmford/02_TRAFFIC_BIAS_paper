* 02a_SOPP_to_FE_rename

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/02_dept_renaming/02_SMCL_logs/02a_SOPP_to_FE_rename", smcl replace

* this ugly piece is used to reduce data-crunching: 
local my_sopp_vars = "state locale date subject_race subject_age subject_sex department_name county_name search_conducted officer_race officer_age officer_sex contraband_found search_basis search_vehicle search_person contraband_alcohol contraband_drugs contraband_weapons contraband_other type reason_for_search department_id type"

* 1/88: AR_LITTLE_ROCK 
use "2000_data/200_raw/20_SOPP_DTAs/ar_little_rock.dta", replace
qui replace department_name = "little rock police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ar_little_rock.dta", replace

********************************************************************************

* 2/88: AZ_GILBERT 
use "2000_data/200_raw/20_SOPP_DTAs/az_gilbert.dta", replace
qui replace department_name = "gilbert police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/az_gilbert.dta", replace

* 3/88: AZ_MESA 
use "2000_data/200_raw/20_SOPP_DTAs/az_mesa.dta", replace
qui replace department_name = "mesa police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/az_mesa.dta", replace

* 4/88: AZ_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/az_statewide.dta", replace
qui replace department_name = "arizona department of public safety" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/az_statewide.dta", replace

********************************************************************************

*  5/88: CA_ANAHEIM 
use "2000_data/200_raw/20_SOPP_DTAs/ca_anaheim.dta", replace
qui replace department_name = "anaheim police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_anaheim.dta", replace

*  6/88: CA_BAKERSFIELD 
use "2000_data/200_raw/20_SOPP_DTAs/ca_bakersfield.dta", replace
qui replace department_name = "bakersfield police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_bakersfield.dta", replace

* 7/88: CA_LONG_BEACH 
use "2000_data/200_raw/20_SOPP_DTAs/ca_long_beach.dta", replace
qui replace department_name = "long beach police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_long_beach.dta", replace

* 8/88: CA_LOS_ANGELES 
use "2000_data/200_raw/20_SOPP_DTAs/ca_los_angeles.dta", replace
qui replace department_name = "los angeles police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_los_angeles.dta", replace

* 9/88: CA_OAKLAND 
use "2000_data/200_raw/20_SOPP_DTAs/ca_oakland.dta", replace
qui replace department_name = "oakland police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_oakland.dta", replace

* 10/88: CA_SAN_BERNARDINO 
use "2000_data/200_raw/20_SOPP_DTAs/ca_san_bernardino.dta", replace
qui replace department_name = "san bernardino police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_san_bernardino.dta", replace

* 11/88: CA_SAN_DIEGO 
use "2000_data/200_raw/20_SOPP_DTAs/ca_san_diego.dta", replace
qui replace department_name = "san diego police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_san_diego.dta", replace

* 12/88: CA_SAN_FRANCISCO 
use "2000_data/200_raw/20_SOPP_DTAs/ca_san_francisco.dta", replace
qui replace department_name = "san francisco police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_san_francisco.dta", replace

* 13/88: CA_SAN_JOSE 
use "2000_data/200_raw/20_SOPP_DTAs/ca_san_jose.dta", replace
qui replace department_name = "san jose police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_san_jose.dta", replace

* 14/88: CA_SANTA_ANA 
use "2000_data/200_raw/20_SOPP_DTAs/ca_santa_ana.dta", replace
qui replace department_name = "santa ana police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_santa_ana.dta", replace

* 15/88: CA_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/ca_statewide.dta", replace
qui replace department_name = "california highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_statewide.dta", replace

* 16/88: CA_STOCKTON 
use "2000_data/200_raw/20_SOPP_DTAs/ca_stockton.dta", replace
qui replace department_name = "stockton police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ca_stockton.dta", replace

********************************************************************************

* 17/88: CO_AURORA 
use "2000_data/200_raw/20_SOPP_DTAs/co_aurora.dta", replace
qui replace department_name = "aurora police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/co_aurora.dta", replace

* 18/88: CO_DENVER
use "2000_data/200_raw/20_SOPP_DTAs/co_denver.dta", replace
qui replace department_name = "denver police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/co_denver.dta", replace

* 19/88: CO_STATEWIDE
use "2000_data/200_raw/20_SOPP_DTAs/co_statewide.dta", replace
qui replace department_name = "colorado state patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/co_statewide.dta", replace

********************************************************************************

* 20/88: CT_HARTFORD 
use "2000_data/200_raw/20_SOPP_DTAs/ct_hartford.dta", replace
qui replace department_name = "hartford police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ct_hartford.dta", replace

* 21/88: CT_STATEWIDE
	*** THIS DATASET CONTAINS MULTIPLE (104) DEPARTMENTS ***
use "2000_data/200_raw/20_SOPP_DTAs/ct_statewide.dta", replace
qui replace department_name = "ansonia police department" if department_name == "Ansonia"
qui replace department_name = "bethel police department" if department_name == "Bethel"
qui replace department_name = "branford police department" if department_name == "Branford"
qui replace department_name = "bridgeport police department" if department_name == "Bridgeport"
qui replace department_name = "danbury police department" if department_name == "Danbury"
qui replace department_name = "east hartford police department" if department_name == "East Hartford"
qui replace department_name = "fairview police department" if department_name == "Fairfield"
qui replace department_name = "groton police department" if department_name == "Groton City"
qui replace department_name = "groton town police department" if department_name == "Groton Town"
qui replace department_name = "hamden police department" if department_name == "Hamden"
qui replace department_name = "hartford police department" if department_name == "Hartford"
qui replace department_name = "madison police department" if department_name == "Madison"
qui replace department_name = "manchester police department" if department_name == "Manchester"
qui replace department_name = "meriden police department" if department_name == "Meriden"
qui replace department_name = "middletown police department" if department_name == "Middletown"
qui replace department_name = "milford police department" if department_name == "Milford"
qui replace department_name = "monroe police department" if department_name == "Monroe"
qui replace department_name = "new britain police department" if department_name == "New Britain"
qui replace department_name = "new haven police department" if department_name == "New Haven"
qui replace department_name = "new london police department" if department_name == "New London"
qui replace department_name = "new milford police department" if department_name == "New Milford"
qui replace department_name = "newington police department" if department_name == "Newington"
qui replace department_name = "norwalk police department" if department_name == "Norwalk"
qui replace department_name = "norwich police department" if department_name == "Norwich"
qui replace department_name = "old saybrook department of police services" if department_name == "Old Saybrook"
qui replace department_name = "orange police department" if department_name == "Orange"
qui replace department_name = "plainfield police department" if department_name == "Plainfield"
qui replace department_name = "plainville police department" if department_name == "Plainville"
qui replace department_name = "putnam police department" if department_name == "Putnam"
qui replace department_name = "ridgefield police department" if department_name == "Ridgefield"
qui replace department_name = "seymour police department" if department_name == "Seymour"
qui replace department_name = "south windsor police department" if department_name == "South Windsor"
qui replace department_name = "stamford police department" if department_name == "Stamford"
qui replace department_name = "connecticut state police" if department_name == "State Police"
qui replace department_name = "stratford police department" if department_name == "Stratford"
qui replace department_name = "suffield police department" if department_name == "Suffield"
qui replace department_name = "vernon police department" if department_name == "Vernon"
qui replace department_name = "wallingford police department" if department_name == "Wallingford"
qui replace department_name = "waterbury police department" if department_name == "Waterbury"
qui replace department_name = "waterford police department" if department_name == "Waterford"
qui replace department_name = "west haven police department" if department_name == "West Haven"
qui replace department_name = "westport police department" if department_name == "Westport"
qui replace department_name = "wethersfield police department" if department_name == "Wethersfield"
qui replace department_name = "willimantic police department" if department_name == "Willimantic"
qui replace department_name = "windsor locks police department" if department_name == "Windsor Locks"
qui replace department_name = lower(department_name)
drop if department_name == "na"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ct_statewide.dta", replace

********************************************************************************

* 22/88: FL_SAINT_PETERSBURG
use "2000_data/200_raw/20_SOPP_DTAs/fl_saint_petersburg.dta", replace
qui replace department_name = "st. petersburg police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/fl_saint_petersburg.dta", replace

* 23/88: FL_STATEWIDE
	*** THIS DATASET CONTAINS MULTIPLE (5) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/fl_statewide.dta", replace
qui replace department_name = "florida highway patrol" if inlist(department_name, "FLORIDA HIGHWAY PATROL", "FLORIDA HIGHWAY PATROL - TROOP K", "FLORIDA HIGHWAY PATROL  MOTORS SQ")
*replace department_name = "" if department_name == "FLORIDA DEPARTMENT OF AGRICULTURE"
drop if department_name == "NA"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/fl_statewide.dta", replace

* 24/88: FL_TAMPA 
	*** THIS DATASET CONTAINS MULTIPLE (436) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/fl_tampa.dta", replace

* FL_TAMPA is a mess; department_name == "A|B|B|C" type problems
	* 1: make all lowercase, split along dividers
	* 2: change repeats into blanks
	* 3: shoving left, re-forming variable
qui replace department_name = lower(department_name) 
drop if department_name == ""
split department_name, parse("|")
forvalues i = 1(1)24 {
	local p1 = `i'+1
	forvalues ip1 = `p1'(1)24 {
		replace department_name`ip1' = "" if department_name`ip1' == department_name`i'
	}
}
forvalues loop = 1(1)2 {
	forvalues i = 1(1)23 {
		display `i'
		replace department_name`i' = "" if inlist(department_name`i', "unknown", "other")
		replace department_name`i' = "state attorney's office" if (department_name`i' == "state attorney")
		local mi = 24-(`i'-1)
		display `mi'
		local mi2 = `mi'-1
		display `mi2'
		replace department_name`mi2' = department_name`mi' if (department_name`mi2'=="" & department_name`mi'!="")
		replace department_name`mi' = "" if (department_name`mi' == department_name`mi2') & (department_name`mi'!="")
	}
}
forvalues i=1(1)24 {
	levelsof department_name`i', local(d`i')
	if missing(`"`d`i''"') {
		drop department_name`i'
	}
}
replace department_name = department_name1 if (department_name2 == "") & (department_name3 == "")
replace department_name = department_name1 + "|" + department_name2 if (department_name2 != "") & (department_name3 == "")
replace department_name = department_name1 + "|" + department_name2 + "|" + department_name3 if (department_name2 != "") & (department_name3 != "")

drop department_name1 department_name2 department_name3 

save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/fl_tampa.dta", replace

********************************************************************************

* 25/88: GA_STATEWIDE
	*** THIS DATASET CONTAINS MULTIPLE (3) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/ga_statewide.dta", replace
qui replace department_name = "georgia state patrol" if department_name == "GEORGIA DEPARTMENT OF PUBLIC SAFETY"
qui replace department_name = "georgia department of natural resources" if department_name == "GEORGIA DEPARTMENT OF NATURAL RESOURCES"
qui replace department_name = "georgia state patrol" if department_name == "GEORGIA STATE PATROL"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ga_statewide.dta", replace

********************************************************************************

* 26/88: IA_STATEWIDE
	*** THIS DATASET CONTAINS MULTIPLE (341) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/ia_statewide.dta", replace
	* evidently IA_STATEWIDE breaks-down stops by state patrol districts - which I dont' use 
qui replace department_name = "iowa state patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ia_statewide.dta", replace

********************************************************************************

* 27/88: ID_IDAHO_FALLS
use "2000_data/200_raw/20_SOPP_DTAs/id_idaho_falls.dta", replace
qui replace department_name = "idaho falls police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/id_idaho_falls.dta", replace

********************************************************************************

* 28/88: IL_CHICAGO 
use "2000_data/200_raw/20_SOPP_DTAs/il_chicago.dta", replace
qui replace department_name = "chicago police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/il_chicago.dta", replace

* 29/88: IL_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (1013) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/il_statewide.dta", replace
qui replace department_name = lower(department_name)
qui replace department_name = "illinois department of natural resources" if department_name == "illinois department of natural resources police"
qui replace department_name = subinstr(department_name, "police", "police department", .)
qui replace department_name = subinstr(department_name, "sheriff", "sheriff's office", .)
qui replace department_name = "illinois state police" if department_name == "illinois state police department"
qui replace department_name = "la grange police department" if department_name == "lagrange police department"
qui replace department_name = "mt. zion police department" if department_name == "mount zion police department"
qui replace department_name = "naplate village police department" if department_name == "naplate police department"
qui replace department_name = "university of illinois at chicago police department" if department_name == "university of illinois chicago police department"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/il_statewide.dta", replace

********************************************************************************

* 30/88: IN_FORT_WAYNE 
use "2000_data/200_raw/20_SOPP_DTAs/in_fort_wayne.dta", replace
qui replace department_name = "fort wayne police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/in_fort_wayne.dta", replace

********************************************************************************

* 31/88: KS_WICHITA 
use "2000_data/200_raw/20_SOPP_DTAs/ks_wichita.dta", replace
qui replace department_name = "wichita police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ks_wichita.dta", replace

********************************************************************************

* 32/88: KY_LOUISVILLE 
use "2000_data/200_raw/20_SOPP_DTAs/ky_louisville.dta", replace
qui replace department_name = "louisville metro police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ky_louisville.dta", replace

* 33/88: KY_OWENSBORO 
use "2000_data/200_raw/20_SOPP_DTAs/ky_owensboro.dta", replace
qui replace department_name = "owensboro police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ky_owensboro.dta", replace

********************************************************************************

* 34/88: LA_NEW_ORLEANS 
use "2000_data/200_raw/20_SOPP_DTAs/la_new_orleans.dta", replace
qui replace department_name = "new orleans police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/la_new_orleans.dta", replace

********************************************************************************

* 35/88: MA_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/ma_statewide.dta", replace
qui replace department_name = "massachusetts state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ma_statewide.dta", replace

********************************************************************************

* 36/88: MD_BALTIMORE 
use "2000_data/200_raw/20_SOPP_DTAs/md_baltimore.dta", replace
qui replace department_name = "baltimore police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/md_baltimore.dta", replace

* 37/88: MD_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (425) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/md_statewide.dta", replace
	* few shorthands used in this data, mostly changing "X" to "X police department": 
qui replace department_name = subinstr(department_name, "PD", "police department", .)
qui replace department_name = subinstr(department_name, "SO", "sheriff's office", .)
qui replace department_name = lower(department_name)
qui replace department_name = "aberdeen police department" if inlist(department_name, "aberdeen city police department")
qui replace department_name = "allegany county sheriff's office" if inlist(department_name, "allegany county bureau of police", "allegany county sheriffs office", "alleghany", "alleghany county sheriff's office")
qui replace department_name = "annapolice police department" if inlist(department_name, "annapolis city police department")
qui replace department_name = "anne arundel county police department" if inlist(department_name, "aa county", "anne arundel county police departme")
qui replace department_name = "anne arundel county sheriff's office" if inlist(department_name, "aa co sheriff", "anne arundel county sheriff's offic")
qui replace department_name = "baltimore city school police" if inlist(department_name, "baltimore city public schools polic", "baltimore city schools police")
qui replace department_name = "baltimore county police department" if inlist(department_name, "baltimore county")
qui replace department_name = "baltimore police department" if inlist(department_name, "baltimore city police department", "balt city")
qui replace department_name = "bowei police department" if inlist(department_name, "bowie", "bower police department", "city of bowie")
qui replace department_name = "bowie state university police department" if inlist(department_name, "bowie state univ", "bowie state university police")
qui replace department_name = "brunswick police department" if inlist(department_name, "brunswick")
qui replace department_name = "calvert county sheriff's office" if inlist(department_name, "calvert co", "calvert")
qui replace department_name = "cambridge police department" if inlist(department_name, "cambridge")
qui replace department_name = "capitol heights police department" if inlist(department_name, "capitolheights")
qui replace department_name = "caroline county sheriff's office" if inlist(department_name, "caroline", "caroline county sheriff")
qui replace department_name = "carroll county sheriff's office" if inlist(department_name, "carroll", "carroll county police department")
qui replace department_name = "cecil county sheriff's office" if inlist(department_name, "cecil county")
qui replace department_name = "centreville police department" if inlist(department_name, "centreville", "centreville  police department")
qui replace department_name = "charles county sheriff's office" if inlist(department_name, "charles", "charles county")
qui replace department_name = "chestertown police department" if inlist(department_name, "chestertown")
qui replace department_name = "cheverly police department" if inlist(department_name, "cheverly")
qui replace department_name = "chevy chase village police department" if inlist(department_name, "chevy chase police department", "chevy chase village police departme", "chevychase")
qui replace department_name = "colmar manor police department" if inlist(department_name, "colmar", "colmar police department")
qui replace department_name = "comptroller of maryland" if inlist(department_name, "comptroller")
qui replace department_name = "coppin state university police department" if inlist(department_name, "coppin", "coppin state university  police dep", "coppin state university police")
qui replace department_name = "cottage city police department" if inlist(department_name, "cottagecity")
qui replace department_name = "crofton police department" if inlist(department_name, "crofton")
qui replace department_name = "cumberland police department" if inlist(department_name, "cumberland", "cumberland city police department")
qui replace department_name = "delmar police department" if inlist(department_name, "delmar")
qui replace department_name = "denton police department" if inlist(department_name, "denton")
qui replace department_name = "department of general services" if inlist(department_name, "dgs", "general services police department")
qui replace department_name = "district heights police department" if inlist(department_name, "distheights", "districts heights police department")
qui replace department_name = "dorchester county sheriff's office" if inlist(department_name, "dorchester", "dorchester co sheriff")
qui replace department_name = "easton police department" if inlist(department_name, "easton")
qui replace department_name = "edmonston police department" if inlist(department_name, "edmonston")
qui replace department_name = "elkton police department" if inlist(department_name, "elkton")
qui replace department_name = "federalsburg police department" if inlist(department_name, "federalsburg")
qui replace department_name = "frederick county sheriff's office" if inlist(department_name, "frederick co sheriff")
qui replace department_name = "frederick police department" if inlist(department_name, "frederickpolice department", "frederick")
qui replace department_name = "frostburg police department" if inlist(department_name, "frostburg", "frostburg city police department")
qui replace department_name = "frostburg state university police department" if inlist(department_name, "frostburg state university", "frostburg state university police d")
qui replace department_name = "fruitland police department" if inlist(department_name, "fruitland")
qui replace department_name = "gaithersburg police department" if inlist(department_name, "gaithersburg")
qui replace department_name = "garrett county police department" if inlist(department_name, "garrett")
qui replace department_name = "garrett county sheriff's office" if inlist(department_name, "garrett county sheriff")
qui replace department_name = "glenarden police department" if inlist(department_name, "glenarden", "city of glenarden")
qui replace department_name = "greenbelt police department" if inlist(department_name, "greenbelt")
qui replace department_name = "greensboro police department" if inlist(department_name, "greensboro")
qui replace department_name = "hagerstown police department" if inlist(department_name, "hagerstown")
qui replace department_name = "hampstead police department" if inlist(department_name, "hampstead")
qui replace department_name = "harford county sheriff's office" if inlist(department_name, "harford", "harford county")
qui replace department_name = "havre de grace police department" if inlist(department_name, "havredegrace")
qui replace department_name = "howard county police department" if inlist(department_name, "hocpolice department")
qui replace department_name = "howard county sheriff's office" if inlist(department_name, "howard co sheriff's office")
qui replace department_name = "hurlock police department" if inlist(department_name, "hurlock")
qui replace department_name = "hyattsville police department" if inlist(department_name, "hyattsville")
qui replace department_name = "kent county sheriff's office" if inlist(department_name, "kent", "kent co sheriff")
qui replace department_name = "la plata police department" if inlist(department_name, "laplata")
qui replace department_name = "landover hills police department" if inlist(department_name, "landover hills police  department", "landover", "landover police department")
qui replace department_name = "laurel police department" if inlist(department_name, "laurel")
qui replace department_name = "manchester police department" if inlist(department_name, "manchester", "manchester police  department")
qui replace department_name = "maryland national capital park police" if inlist(department_name, "maryland - national capital pa", "maryland national capital park poli", "maryland national capital park police montgomery county", "maryland national capital park police prince george's county", "maryland national capital park prin", "maryland-national capital park police montgomery county")
qui replace department_name = "maryland national capital park police" if inlist(department_name, "maryland-national capital park police prince george's county", "mcpark", "mdncpp montgomery", "mdncpp prince george's", "pgpark")
qui replace department_name = "maryland state police" if inlist(department_name, "msp")
qui replace department_name = "maryland transit administration police department" if inlist(department_name, "maryland transportation administration police", "maryland transit administration police", "mta")
qui replace department_name = "maryland transportation authority police department" if inlist(department_name, "mdta", "mdta police")
qui replace department_name = "montgomery county police department" if inlist(department_name, "montgomery", "montgomery co")
qui replace department_name = "montgomery county sheriff's office" if inlist(department_name, "montgomery co sheriff", "montgomery county sheriffs office", "montsheriff")
qui replace department_name = "morgan state university police department" if inlist(department_name, "morgan state university police")
qui replace department_name = "mount rainier police department" if inlist(department_name, "mount ranier police department", "mtrainier")
qui replace department_name = "morningside police department" if inlist(department_name, "morningside")
qui replace department_name = "new carrollton police department" if inlist(department_name, "ncpolice department")
qui replace department_name = "north east police department" if inlist(department_name, "northeast police department")
qui replace department_name = "natural resources police" if inlist(department_name, "nrp")
qui replace department_name = "oakland police department" if inlist(department_name, "oakland")
qui replace department_name = "ocean city police department" if inlist(department_name, "oceancity")
qui replace department_name = "ocean pines police department" if inlist(department_name, "oceanpines")
qui replace department_name = "oxford police department" if inlist(department_name, "oxford")
qui replace department_name = "pocomoke city police department" if inlist(department_name, "pocomoke", "pokomoke county")
qui replace department_name = "prince george's county police department" if inlist(department_name, "prince george's police department", "pgcopolice department")
qui replace department_name = "prince george's county sheriff's office" if inlist(department_name, "prince george's county sheriff's of", "pg sheriff")
qui replace department_name = "princess anne police department" if inlist(department_name, "princessanne")
qui replace department_name = "queen anne's county sheriff's office" if inlist(department_name, "qacsheriff's office", "queen anne's county", "queen anne's county sheriff's offic")
qui replace department_name = "ridgely police department" if inlist(department_name, "ridgely", "ridgley police department")
qui replace department_name = "riverdale park police department" if inlist(department_name, "riverdale", "riverdale police department")
qui replace department_name = "rock hall police department" if inlist(department_name, "rockhall")
qui replace department_name = "rockville city police department" if inlist(department_name, "rockville", "rockville police department")
qui replace department_name = "salisbury police department" if inlist(department_name, "salisbury")
qui replace department_name = "seat pleasant police department" if inlist(department_name, "seatpleasant")
qui replace department_name = "salisbury university police department" if inlist(department_name, "salisbury university police departm")
qui replace department_name = "smithsburg police department" if inlist(department_name, "smithsburg")
qui replace department_name = "snow hill police department" if inlist(department_name, "snowhill", "snowhill police department")
qui replace department_name = "somerset county sheriff's office" if inlist(department_name, "sheriff's officemerset")
qui replace department_name = "sykesville police department" if inlist(department_name, "sykesville")
qui replace department_name = "st. michael's police department" if inlist(department_name, "st michaels police department", "st. michaels police department", "stmichaels")
qui replace department_name = "st. mary's county sheriff's office" if inlist(department_name, "st mary's sheriff", "stmarys")
qui replace department_name = "talbot county sheriff's office" if inlist(department_name, "talbot", "talbot county")
qui replace department_name = "taneytown police department" if inlist(department_name, "taneytown")
qui replace department_name = "takoma park police department" if inlist(department_name, "takoma")
qui replace department_name = "thurmont police department" if inlist(department_name, "thurmont")
qui replace department_name = "towson university police department" if inlist(department_name, "towson univ", "towson university police")
qui replace department_name = "trappe police department" if inlist(department_name, "trappe")
qui replace department_name = "university of baltimore police department" if inlist(department_name, "ub police department", "ubaltpolice department", "univ of balt police department", "university of baltimore police depa", "university of maryland baltimore police")
qui replace department_name = "university of maryland baltimore police department" if inlist(department_name, "umab police department", "umb", "university of maryland at baltimore police department")
qui replace department_name = "university of maryland baltimore county police department" if inlist(department_name, "umbc", "umbc police", "university of maryland baltimore county police")
qui replace department_name = "university of maryland college park police department" if inlist(department_name, "umcp", "univ of md police department", "university of maryland college park police", "university of maryland police colle", "university of maryland police college park", "university of maryland police department", "umpolice department")
qui replace department_name = "university of maryland eastern shore police department" if inlist(department_name, "umes", "university of maryland eastern shor", "university of maryland eastern shore police")
qui replace department_name = "university park police department" if inlist(department_name, "university park police", "universitypark")
qui replace department_name = "washington county sheriff's office" if inlist(department_name, "washington co. sheriffs office", "washington county sheriffs office")
qui replace department_name = "westminster police department" if inlist(department_name, "westminster")
qui replace department_name = "wicomico county sheriff's office" if inlist(department_name, "wicomico", "wicomico county sheriffs office")
qui replace department_name = "worcester county sheriff's office" if inlist(department_name, "worcester", "worchester co sheriff")
qui replace department_name = "washington county sheriff's office" if inlist(department_name, "washington", "washington co")
qui replace department_name = "washington suburban sanitary commission police department" if inlist(department_name, "wssc police department")
qui replace department_name = "westernport police department" if inlist(department_name, "westernport")
qui replace department_name = "worcester county sheriff's office" if inlist(department_name, "worcester", "worchester co sheriff")

save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/md_statewide.dta", replace

********************************************************************************

* 38/88: MI_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (95) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/mi_statewide.dta", replace

* confident corrections:  
qui drop if inlist(department_name, "675.00", "683.10", "69", "70", "70 1469", "70 @744")
qui drop if inlist(department_name, "1015.00", "1085.00", "1645.00", "257.00", "296.00", "492.00", "560.00")
qui replace department_name = "michigan state police adrian post" if inlist(department_name, "MSPAdrian")
qui replace department_name = "michigan state police alpena post" if inlist(department_name, "MSPAlpena")
qui replace department_name = "michigan state police brighton post" if inlist(department_name, "MSPBrighto")
qui replace department_name = "michigan state police brighton post" if department_id == "MSPBrighto"
qui replace department_name = "michigan state police cadillac post" if inlist(department_name, "MSPCadilla")
qui replace department_name = "michigan state police calumet post" if inlist(department_name, "MSPCalumet")
qui replace department_name = "michigan state police coldwater post" if inlist(department_name, "MSPColdwat")
qui replace department_name = "michigan state police corunna post" if inlist(department_name, "MSPCorunna")
qui replace department_name = "michigan state police east tawas post" if inlist(department_name, "MSPEastTaw")
qui replace department_name = "michigan state police gaylord post" if inlist(department_name, "MSPGaylord")
qui replace department_name = "michigan state police grand haven post" if inlist(department_name, "MSPGrandHa")
qui replace department_name = "michigan state police gladstone post" if inlist(department_name, "MSPGladsto")
qui replace department_name = "michigan state police hart post" if inlist(department_name, "MSPHart")
qui replace department_name = "michigan state police hastings post" if inlist(department_name, "MSPHasting")
qui replace department_name = "michigan state police houghton lake post" if inlist(department_name, "MSPHoughto")
qui replace department_name = "michigan state police iron mountain post" if inlist(department_name, "MSPIronMou")
qui replace department_name = "michigan state police ithaca post" if inlist(department_name, "MSPIthaca")
qui replace department_name = "michigan state police jackson post" if inlist(department_name, "MSPJackson")
qui replace department_name = "michigan state police lakeview post" if inlist(department_name, "MSPLakevie")
qui replace department_name = "michigan state police lansing post" if inlist(department_name, "MSPLansing")
qui replace department_name = "michigan state police lapeer post" if inlist(department_name, "MSPLapeer", "MSPLapeerH")
qui replace department_name = "michigan state police manistique post" if inlist(department_name, "MSPManisti")
qui replace department_name = "michigan state police marshall post" if inlist(department_name, "MSPMarshal")
qui replace department_name = "michigan state police metro north post" if inlist(department_name, "MSPMetroNo")
qui replace department_name = "michigan state police metro south post" if inlist(department_name, "MSPMetroSo")
qui replace department_name = "michigan state police mount pleasant post" if inlist(department_name, "MSPMtPleas")
qui replace department_name = "michigan state police negaunee post" if inlist(department_name, "MSPNegaune")
qui replace department_name = "michigan state police petoskey post" if inlist(department_name, "MSPPetoske")
qui replace department_name = "michigan state police rockford" if inlist(department_name, "MSPRockfor")
qui replace department_name = "michigan state police st. ignace post" if inlist(department_name, "MSPStIgnac")
qui replace department_name = "michigan state police traverse city post" if inlist(department_name, "MSPTrav")
qui replace department_name = "michigan state police wakefield post" if inlist(department_name, "MSPWakefie")
qui replace department_name = "michigan state police wayland post" if inlist(department_name, "WaylandMSP")
qui replace department_name = "michigan state police west branch post" if inlist(department_name, "MSPWestBra")
qui replace department_name = "michigan state police white pigeon post" if inlist(department_name, "MSPWP")
qui replace department_name = "michigan state police ypsilanti post" if inlist(department_name, "MSPY")

* less confident corrections: 
qui replace department_name = "michigan state police flint post" if inlist(department_name, "MSPF")
qui replace department_name = "michigan state police niles post" if inlist(department_name, "MSPN")
qui replace department_name = "michigan state police paw paw post" if inlist(department_name, "MSPPP")

save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/mi_statewide.dta", replace

********************************************************************************

* 39/88: MN_SAINT_PAUL 
use "2000_data/200_raw/20_SOPP_DTAs/mn_saint_paul.dta", replace
qui replace department_name = "saint paul police department"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/mn_saint_paul.dta", replace

********************************************************************************

* 40/88: MO_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (679) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/mo_statewide.dta", replace

* these capture all of the old manual-renaming that I had done (yuck)
qui replace department_name = lower(department_name)
qui replace department_name = subinstr(department_name, "dept. of public safety", "department of public safety", .)
qui replace department_name = subinstr(department_name, "co. sheriff's dept.", "county sheriff's office", .)
qui replace department_name = subinstr(department_name, "sheriff's dept.", "sheriff's office", .)
qui replace department_name = subinstr(department_name, "police dept.", "police department", .)
qui replace department_name = "de soto police department" if inlist(department_name, "desoto police department")
qui replace department_name = "gladstone police department" if inlist(department_name, "gladstone department of public safety")
qui replace department_name = "moberly police department" if inlist(department_name, "moberly")
qui replace department_name = "sikeston department of public safety" if inlist(department_name, "sikeston police department") 
qui replace department_name = "st. louis metropolitan police department" if inlist(department_name, "st. louis city police department")
qui replace department_name = "st. louis county park rangers" if inlist(department_name, "st. louis park rangers")
qui replace department_name = "riverside police department" if inlist(department_name, "riverside department of public safety")
qui replace department_name = "adair county sheriff's office" if inlist(department_name, "adair")
qui replace department_name = "bourbon department of public safety" if inlist(department_name, "bourbon - department of public safety")
qui replace department_name = "florissant valley community college police department" if inlist(department_name, "florissant valley community college")
qui replace department_name = "richmond police department" if inlist(department_name, "richmond")
qui drop if department_name == "vi"
qui replace department_name = "union pacific railroad police-kansas city/st. louis" if inlist(department_name, "union pacific railroad police - kansas city", "union pacific railroad police - st. louis")
qui replace department_name = "clark county sheriff's office" if inlist(department_name, "clark police department")
qui replace department_name = "gasconade county sheriff's office" if inlist(department_name, "gasconade police department")
qui replace department_name = "holt county sheriff's office" if inlist(department_name, "holt police department")
qui replace department_name = "miller county sheriff's office" if inlist(department_name, "miller police department")

save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/mo_statewide.dta", replace

********************************************************************************

* 41/88: MS_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (366) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/ms_statewide.dta", replace

replace department_name = lower(department_name)
replace department_name = subinstr(department_name, "police dept", "police department", .)
replace department_name = subinstr(department_name, "sheriff office", "sheriff's office", .)
drop if department_name == "na"

save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ms_statewide.dta", replace

********************************************************************************

* 42/88: MT_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/mt_statewide.dta", replace
qui replace department_name = "montana highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/mt_statewide.dta", replace

********************************************************************************

* 43/88: NC_CHARLOTTE 
	*** THIS DATASET CONTAINS MULTIPLE (2) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/nc_charlotte.dta", replace
qui replace department_name = "charlotte-mecklenburg police department" if inlist(department_name, "Charlotte-Mecklenburg Police Department")
qui replace department_name = "unc charlotte university police department" if inlist(department_name, "UNC Charlotte University Police Department")
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_charlotte.dta", replace

* 44/88: NC_DURHAM 
	*** THIS DATASET CONTAINS MULTIPLE (2) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/nc_durham.dta", replace
qui replace department_name = "durham county sheriff's office" if department_name == "Durham County Sheriff's Office"
qui replace department_name = "durham police department" if department_name == "Durham Police Department"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_durham.dta", replace

* 45/88: NC_FAYETTEVILLE 
	*** THIS DATASET CONTAINS MULTIPLE (2) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/nc_fayetteville.dta", replace
qui replace department_name = "fayetteville police department" if inlist(department_name, "Fayetteville Police Department")
qui replace department_name = "fayetteville state university police department" if inlist(department_name, "Fayetteville State University Police Department")
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_fayetteville.dta", replace

* 46/88: NC_GREENSBORO 
	*** THIS DATASET CONTAINS MULTIPLE (2) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/nc_greensboro.dta", replace
qui replace department_name = "greensboro police department" if inlist(department_name, "Greensboro Police Department")
qui replace department_name = "unc greensboro university police department" if inlist(department_name, "UNC Greensboro University Police Department")
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_greensboro.dta", replace

* 47/88: NC_RALEIGH 
use "2000_data/200_raw/20_SOPP_DTAs/nc_raleigh.dta", replace
qui replace department_name = "raleigh police department" if department_name == "Raleigh Police Department"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_raleigh.dta", replace

* 48/88: NC_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (312) DEPARTMENTS! ***
		* (NOTABLY: it contains ALL of the other NC-departments from this section)
use "2000_data/200_raw/20_SOPP_DTAs/nc_statewide.dta", replace
qui replace department_name = subinstr(department_name, "UNC ", "unc ", .)
qui replace department_name = subinstr(department_name, "NC ", "north carolina ", .)
replace department_name = lower(department_name)
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_statewide.dta", replace

*49/88: NC_WINSTON-SALEM 
	*** THIS DATASET CONTAINS MULTIPLE (2) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/nc_winston-salem.dta", replace
qui replace department_name = "winston-salem police department" if inlist(department_name, "Winston-Salem Police Department")
qui replace department_name = "winston-salem state university police department" if inlist(department_name, "Winston-Salem State University Police Department")
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nc_winston-salem.dta", replace

********************************************************************************

* 50/88: ND_GRAND_FORKS 
use "2000_data/200_raw/20_SOPP_DTAs/nd_grand_forks.dta", replace
qui replace department_name = "grand forks police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nd_grand_forks.dta", replace

* 51/88: ND_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/nd_statewide.dta", replace
qui replace department_name = "north dakota highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nd_statewide.dta", replace

********************************************************************************

* 52/88: NE_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (246) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/ne_statewide.dta", replace
qui replace department_name = itrim(department_name)
qui replace department_name = subinstr(department_name, "P.D.", "police department", .)
qui replace department_name = subinstr(department_name, "CO.", "COUNTY", .)
qui replace department_name = lower(department_name)
qui replace department_name = "bayard police department" if inlist(department_name, "bayard pd")
qui replace department_name = "dakota county sheriff's office" if inlist(department_name, "dakota city police department")
qui replace department_name = "dodge-snyder police department" if inlist(department_name, "dodge police department / snyder police department")
qui replace department_name = "exeter police department" if inlist(department_name, "exeter p.d")
qui replace department_name = "fairmont police department" if inlist(department_name, "fairmont pd")
qui replace department_name = "mcpherson county sheriff's office" if inlist(department_name, "mc pherson county sheriff's office")
qui replace department_name = "pawnee county sheriff's office" if inlist(department_name, "pawnee city police department")
qui replace department_name = "stanton county sheriff's office" if inlist(department_name, "stanton police department")
qui drop if department_name == "nbhowelpd"

* workaround to remove sheriff names from sheriff departments 
split department_name, parse("s.o.")
qui replace department_name2 = "sheriff's office" if (department_name2 != "")
qui replace department_name = department_name1 + department_name2 if (department_name2 == "sheriff's office")
drop department_name1 department_name2
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ne_statewide.dta", replace

********************************************************************************

* 53/88: NH_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/nh_statewide.dta", replace
qui replace department_name = "new hampshire state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nh_statewide.dta", replace

********************************************************************************

* 54/88: NJ_CAMDEN 
use "2000_data/200_raw/20_SOPP_DTAs/nj_camden.dta", replace
qui replace department_name = "camden police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nj_camden.dta", replace

* 55/88: NJ_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/nj_statewide.dta", replace
qui replace department_name = "new jersey state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nj_statewide.dta", replace

********************************************************************************

* 56/88: NV_HENDERSON 
use "2000_data/200_raw/20_SOPP_DTAs/nv_henderson.dta", replace
qui replace department_name = "henderson police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nv_henderson.dta", replace

* 57/88: NV_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/nv_statewide.dta", replace
qui replace department_name = "nevada highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/nv_statewide.dta", replace

********************************************************************************

* 58/88: NY_ALBANY 
use "2000_data/200_raw/20_SOPP_DTAs/ny_albany.dta", replace
qui replace department_name = "albany police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ny_albany.dta", replace

* 59/88: NY_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/ny_statewide.dta", replace
qui replace department_name = "new york state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ny_statewide.dta", replace

********************************************************************************

* 60/88: OH_CINCINNATI 
use "2000_data/200_raw/20_SOPP_DTAs/oh_cincinnati.dta", replace
qui replace department_name = "cincinnati police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/oh_cincinnati.dta", replace

* 61/88: OH_COLUMBUS 
use "2000_data/200_raw/20_SOPP_DTAs/oh_columbus.dta", replace
qui replace department_name = "columbus division of police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/oh_columbus.dta", replace

* 62/88: OH_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/oh_statewide.dta", replace
qui replace department_name = "ohio state highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/oh_statewide.dta", replace

********************************************************************************

* 63/88: OK_OKLAHOMA_CITY 
use "2000_data/200_raw/20_SOPP_DTAs/ok_oklahoma_city.dta", replace
qui replace department_name = "oklahoma city police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ok_oklahoma_city.dta", replace

* 64/88: OK_TULSA 
use "2000_data/200_raw/20_SOPP_DTAs/ok_tulsa.dta", replace
qui replace department_name = "tulsa police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ok_tulsa.dta", replace

********************************************************************************

* 65/88: OR_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/or_statewide.dta", replace
qui replace department_name = "oregon state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/or_statewide.dta", replace

********************************************************************************

* 66/88: PA_PHILADELPHIA 
use "2000_data/200_raw/20_SOPP_DTAs/pa_philadelphia.dta", replace
qui replace department_name = "philadelphia police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/pa_philadelphia.dta", replace

********************************************************************************

* 67/68: RI_STATEWIDE
use "2000_data/200_raw/20_SOPP_DTAs/ri_statewide.dta", replace
qui replace department_name = "rhode island state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/ri_statewide.dta", replace

********************************************************************************

* 68/88: SC_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/sc_statewide.dta", replace
qui replace department_name = "south carolina highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/sc_statewide.dta", replace

********************************************************************************

* 69/88: SD_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/sd_statewide.dta", replace
qui replace department_name = "south dakota highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/sd_statewide.dta", replace

********************************************************************************

* 70/88: TN_NASHVILLE 
	*** THIS DATASET CONTAINS MULTIPLE (2) DEPARTMENTS! ***
		* (no it didn't?)
use "2000_data/200_raw/20_SOPP_DTAs/tn_nashville.dta", replace
qui replace department_name = "metro nashville police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tn_nashville.dta", replace

* 71/88: TN_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/tn_statewide.dta", replace
qui replace department_name = "tennessee highway patrol" 
qui drop if department_name == "NA"
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tn_statewide.dta", replace

********************************************************************************

* 72/88: TX_ARLINGTON 
use "2000_data/200_raw/20_SOPP_DTAs/tx_arlington.dta", replace
qui replace department_name = "arlington police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_arlington.dta", replace

* 73/88: TX_AUSTIN 
use "2000_data/200_raw/20_SOPP_DTAs/tx_austin.dta", replace
qui replace department_name = "austin police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_austin.dta", replace

* 74/88: TX_GARLAND 
use "2000_data/200_raw/20_SOPP_DTAs/tx_garland.dta", replace
qui replace department_name = "garland police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_garland.dta", replace

* 75/88: TX_HOUSTON 
use "2000_data/200_raw/20_SOPP_DTAs/tx_houston.dta", replace
qui replace department_name = "houston police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_houston.dta", replace

* 76/88: TX_LUBBOCK 
use "2000_data/200_raw/20_SOPP_DTAs/tx_lubbock.dta", replace
qui replace department_name = "lubbock police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_lubbock.dta", replace

* 77/88: TX_PLANO 
use "2000_data/200_raw/20_SOPP_DTAs/tx_plano.dta", replace
qui replace department_name = "plano police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_plano.dta", replace

* 78/88: TX_SAN_ANTONIO 
use "2000_data/200_raw/20_SOPP_DTAs/tx_san_antonio.dta", replace
qui replace department_name = "san antonio police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_san_antonio.dta", replace

* 79/88: TX_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/tx_statewide.dta", replace
qui replace department_name = "texas department of public safety" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/tx_statewide.dta", replace

********************************************************************************

* 80/88: VA_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/va_statewide.dta", replace
qui replace department_name = "virginia state police" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/va_statewide.dta", replace

********************************************************************************

* 81/88: VT_BURLINGTON 
use "2000_data/200_raw/20_SOPP_DTAs/vt_burlington.dta", replace
qui replace department_name = "burlington police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/vt_burlington.dta", replace

* 82/88: VT_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (14) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/vt_statewide.dta", replace
* VSP has headquarter info, may be useful? preserving under new variable name 
qui replace department_name = "vermont state police bradford" if inlist(department_name, "BRADFORD VSP")
qui replace department_name = "vermont state police battleboro" if inlist(department_name, "BRATTLEBORO VSP")
qui replace department_name = "vermont state police derby" if inlist(department_name, "DERBY VSP")
qui replace department_name = "vermont state police middlesex" if inlist(department_name, "MIDDLESEX VSP")
qui replace department_name = "vermont state police new haven" if inlist(department_name, "NEW HAVEN VSP")
qui replace department_name = "vermont state police rockingham" if inlist(department_name, "ROCKINGHAM VSP")
qui replace department_name = "vermont state police royalton" if inlist(department_name, "ROYALTON VSP")
qui replace department_name = "vermont state police rutland" if inlist(department_name, "RUTLAND VSP")
qui replace department_name = "vermont state police shaftsbury" if inlist(department_name, "SHAFTSBURY VSP")
qui replace department_name = "vermont state police st. albans" if inlist(department_name, "ST ALBANS VSP")
qui replace department_name = "vermont state police st. johnsbury" if inlist(department_name, "ST JOHNSBURY VSP")
qui replace department_name = "vermont state police hq - field force" if inlist(department_name, "VSP HEADQUARTERS - FIELD FORCE")
qui replace department_name = "vermont state police hq - bci/siu/niu" if inlist(department_name, "VSP HQ- BCI/SIU/NIU")
qui replace department_name = "vermont state police williston" if inlist(department_name, "WILLISTON VSP")
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/vt_statewide.dta", replace

********************************************************************************

* 83/88: WA_SEATTLE 
use "2000_data/200_raw/20_SOPP_DTAs/wa_seattle.dta", replace
qui replace department_name = "seattle police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/wa_seattle.dta", replace

* 84/88: WA_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/wa_statewide.dta", replace
qui replace department_name = "washington state patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/wa_statewide.dta", replace

* 85/88: WA_TACOMA 
use "2000_data/200_raw/20_SOPP_DTAs/wa_tacoma.dta", replace
qui replace department_name = "tacoma police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/wa_tacoma.dta", replace

********************************************************************************

* 86/88: WI_MADISON 
use "2000_data/200_raw/20_SOPP_DTAs/wi_madison.dta", replace
qui replace department_name = "madison police department" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/wi_madison.dta", replace

* 87/88: WI_STATEWIDE 
	*** THIS DATASET CONTAINS MULTIPLE (9) DEPARTMENTS! ***
use "2000_data/200_raw/20_SOPP_DTAs/wi_statewide.dta", replace
qui replace department_name = "wisconsin state patrol NCR/WSA" if inlist(department_name, "WI STATE PATROL NCR/WSA") 
qui replace department_name = "wisconsin state patrol NER/FON" if inlist(department_name, "WI STATE PATROL NER/FON") 
qui replace department_name = "wisconsin state patrol NWR/EAU" if inlist(department_name, "WI STATE PATROL NWR/EAU") 
qui replace department_name = "wisconsin state patrol NWE/SPO" if inlist(department_name, "WI STATE PATROL NWR/SPO") 
qui replace department_name = "wisconsin state patrol SER/WKE" if inlist(department_name, "WI STATE PATROL SER/WKE") 
qui replace department_name = "wisconsin state patrol SWR/DEF" if inlist(department_name, "WI STATE PATROL SWR/DEF") 
qui replace department_name = "wisconsin state patrol SWR/TOM" if inlist(department_name, "WI STATE PATROL SWR/TOM") 
qui replace department_name = "wisconsin state patrol" if inlist(department_name, "WISCONSIN STATE PATROL") 
qui replace department_name = "wisconsin state patrol ZWI" if inlist(department_name, "ZWI STATE PATROL") 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/wi_statewide.dta", replace

********************************************************************************

* 88/88: WY_STATEWIDE 
use "2000_data/200_raw/20_SOPP_DTAs/wy_statewide.dta", replace
qui replace department_name = "wyoming highway patrol" 
save "2000_data/200_raw/20_SOPP_DTAs/2_renamed/wy_statewide.dta", replace



********************************************************************************
**********   APPENDING SOPP DTAs   *********************************************
********************************************************************************



set varabbrev off

filelist, dir("2000_data/200_raw/20_SOPP_DTAs/2_renamed") pat("*.dta") maxdeep(1)
gen dta_path = dirname + "/" + filename 
qui levelsof dta_path, local(full_appending)

drop dirname filename fsize

local j = 1
local k = _N

foreach file of local full_appending {
	display ""
	display "#`j'/`k', $S_TIME: `file'"
	append using "`file'", force keep(`my_sopp_vars')
	local ++j
}

drop dta_path
drop if date == "NA" 
drop if date == "" 

gen state_locale = state + "_" + locale
order state locale department_name date
sort state locale department_name date

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/300_cleaning/20_SOPP/SOPP_appended.dta", replace

set varabbrev on

log close
