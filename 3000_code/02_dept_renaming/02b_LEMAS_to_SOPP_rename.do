* 02b_LEMAS_to_SOPP_rename

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

capture log close
log using "3000_code/02_dept_renaming/02_SMCL_logs/02b_LEMAS_to_SOPP_rename", smcl replace

* this is the list of all RENAMED departments that appear in the SOPP datasets: 
	* I want to rename LEMAS to align with SOPP, so I convert this to Excel for viewing: 
*use "~\coding\02_TRAFFIC_BIAS_paper\2000_data\SOPP_renamed_dept_list.dta", replace
*char department_name[_de_col_width_] 100
*export excel using "2000_data/SOPP_renamed_dept_list", replace

use state_abbrev agency_name year agency_id_unique ori_9 agency_type agency_type_old using "2000_data/300_cleaning/40_LEMAS/LEMAS_appended.dta", replace
drop if (year<2007)
drop if (state_abbrev=="DC")
order state_abbrev agency_name 
sort state_abbrev agency_name

* for simplicity: making all lowercase, removing leading/trailing spaces, removing double spaces: 
replace agency_name = lower(agency_name)
replace agency_name = itrim(agency_name) 

* some more simply prelim fixes, and de-duping what remains: 
replace agency_name = subinstr(agency_name, "police dept", "police department", .)
replace agency_name = subinstr(agency_name, " co sheriff", " county sheriff", .)
replace agency_name = subinstr(agency_name, "sheriff dept", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriffs dept", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriff's dept", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriff department", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriffs department", "sheriff's department", .)
replace agency_name = subinstr(agency_name, "sheriff's department", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriff office", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriffs office", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "dept of public safety", "department of public safety", .)
replace agency_name = subinstr(agency_name, "dept public safety", "department of public safety", .)
replace agency_name = subinstr(agency_name, "dept. of public safety", "department of public safety", .)
replace agency_name = subinstr(agency_name, "dept of public sfty", "department of public safety", .)

* fix for "abc police" and "abc sheriff": 
replace agency_name = subinstr(agency_name, "police", "police department", .)
replace agency_name = subinstr(agency_name, "police department department", "police department", .)
replace agency_name = subinstr(agency_name, "sheriff", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriff's offices", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "sheriff's office's office", "sheriff's office", .)
replace agency_name = subinstr(agency_name, "police department authority", "police authority", .)
replace agency_name = subinstr(agency_name, "tribal police department", "tribal police", .)

* Alaska: 
replace agency_name = "alaska state troopers" if inlist(agency_name, "alaska state trooopers") & (state_abbrev=="AK")

* Alabama: 
replace agency_name = "alabama department of public safety" if inlist(agency_name, "alabama department of public") & (state_abbrev=="AL")
replace agency_name = "barbour county sheriff's office" if inlist(agency_name, "barbourcounty sheriff's office") & (state_abbrev=="AL")
replace agency_name = "opelika police department" if inlist(agency_name, "opeilka police department") & (state_abbrev=="AL")
replace agency_name = "poarch creek tribal police department" if inlist(agency_name, "poarch creek tribal public safety") & (state_abbrev=="AL")

* Arkansas: 
replace agency_name = "arkansas state police" if inlist(agency_name, "arkansas state police department") & (state_abbrev=="AR")
replace agency_name = "carroll county sheriff's office" if inlist(agency_name, "carroll county") & (state_abbrev=="AR")
replace agency_name = "fayetteville police department" if inlist(agency_name, "faytteville police department") & (state_abbrev=="AR")
replace agency_name = "independence county sheriff's office" if inlist(agency_name, "independence county sheriff's offices offic") & (state_abbrev=="AR")
replace agency_name = "north little rock police department" if inlist(agency_name, "n. little rock police department", "north little rock police department depart") & (state_abbrev=="AR")

* Arizona: 
replace agency_name = "arizona department of public safety" if inlist(agency_name, "arizona department of public", "arizona dept of public safety") & (state_abbrev=="AZ")

* California: 
drop if inlist(agency_name, "manager", "office of the sheriff's office")
replace agency_name = "contra costa county sheriff's office" if inlist(agency_name, "contra costa county sheriff's office/coroner") & (state_abbrev=="CA")
replace agency_name = "cypress police department" if inlist(agency_name, "cypness police department") & (state_abbrev=="CA")
replace agency_name = "kern county sheriff's office" if inlist(agency_name, "kern county sd coroner") & (state_abbrev=="CA")
replace agency_name = "monterey county sheriff's office" if inlist(agency_name, "monterey county") & (state_abbrev=="CA")
replace agency_name = "orange county sheriff's office" if inlist(agency_name, "orange county sheriff's office coroner dept", "orange county sheriff's office-coroner department")  & (state_abbrev=="CA")
replace agency_name = "placer county sheriff's office" if inlist(agency_name, "placer county sheriff's office/coroner") & (state_abbrev=="CA")
replace agency_name = "sacramento county sheriff's office" if inlist(agency_name, "sacramento county sheriff's office s") & (state_abbrev=="CA")
replace agency_name = "salinas police department" if inlist(agency_name, "salinas poilce department") & (state_abbrev=="CA")
replace agency_name = "san luis obispo sheriff's office" if inlist(agency_name, "san luis obispo county sheriff's office/coroner's office")  & (state_abbrev=="CA")
replace agency_name = "solano county sheriff's office" if inlist(agency_name, "solano ocunty sheriff's office") & (state_abbrev=="CA")
replace agency_name = "stanislaus county sheriff's office" if inlist(agency_name, "stanislaus county") & (state_abbrev=="CA")
replace agency_name = "sunnyvale department of public safety" if inlist(agency_name, "sunnyvale dept of public safety") & (state_abbrev=="CA")
replace agency_name = "ventura police department" if inlist(agency_name, "ventura police department buenaventura") & (state_abbrev=="CA")
replace agency_name = "visalia police department" if inlist(agency_name, "visalia department of public safety") & (state_abbrev=="CA")

* Colorado: 
replace agency_name = "fort collins police department" if inlist(agency_name, "fort collins police department services") & (state_abbrev=="CO")

* Connecticut: 
replace agency_name = "connecticut state police" if inlist(agency_name, "connecticut state police department") & (state_abbrev=="CT")
replace agency_name = "darien police department" if inlist(agency_name, "darien connecticut police department") & (state_abbrev=="CT")

* Delaware: 
replace agency_name = "delaware state police" if inlist(agency_name, "delaware state police department") & (state_abbrev=="DE")
replace agency_name = "new castle police department" if inlist(agency_name, "new castle (city) police department") & (state_abbrev=="DE")

* Florida: 
replace agency_name = "bradenton police department" if inlist(agency_name, "bradenton police department ddepartment") & (state_abbrev=="FL")
replace agency_name = "brevard county sheriff's office" if inlist(agency_name, "brevard sheriff's office") & (state_abbrev=="FL")
replace agency_name = "broward county sheriff's office" if inlist(agency_name, "broward sheriff's office") & (state_abbrev=="FL")
replace agency_name = "delray beach police department" if inlist(agency_name, "decray beach police department") & (state_abbrev=="FL")
replace agency_name = "escambia county sheriff's office" if inlist(agency_name, "escambia sheriff's office") & (state_abbrev=="FL")
replace agency_name = "indian river county sheriff's office" if inlist(agency_name, "indian river county sheriff's office ofc") & (state_abbrev=="FL")
replace agency_name = "miami-dade police department" if inlist(agency_name, "miami-dade county police department", "miamidade police department") & (state_abbrev=="FL")
replace agency_name = "ocean ridge police department" if inlist(agency_name, "ocean ridge public safety department") & (state_abbrev=="FL")
replace agency_name = "pasco county sheriff's office" if inlist(agency_name, "pasco sheriff's office") & (state_abbrev=="FL")
replace agency_name = "port st lucie police department" if inlist(agency_name, "port st. lucie police department") & (state_abbrev=="FL")
replace agency_name = "st lucie county sheriff's office" if inlist(agency_name, "saint lucie county sheriff's office", "st. lucie county sheriff's office") & (state_abbrev=="FL")
replace agency_name = "st petersburg police department" if inlist(agency_name, "saint petersburg police department", "st. petersburg police department") & (state_abbrev=="FL")
replace agency_name = "st cloud police department" if inlist(agency_name, "st. cloud police department") & (state_abbrev=="FL")
replace agency_name = "st johns county sheriff's office" if inlist(agency_name, "st. johns county sheriff's office") & (state_abbrev=="FL")
replace agency_name = "st augustine police department" if inlist(agency_name, "st. augustine police department") & (state_abbrev=="FL")
replace agency_name = "volusia county sheriff's office" if inlist(agency_name, "volusia county") & (state_abbrev=="FL")

* Georgia: 
replace agency_name = "athens-clarke county police department" if inlist(agency_name, "athens clarke county police department") & (state_abbrev=="GA")
replace agency_name = "bainbridge department of public safety" if inlist(agency_name, "bainbridge public safety") & (state_abbrev=="GA")
replace agency_name = "clayton county police department" if inlist(agency_name, "clayton police department") & (state_abbrev=="GA")
replace agency_name = "college park police department" if inlist(agency_name, "college park polic dept") & (state_abbrev=="GA")
replace agency_name = "savannah-chatham metro police department" if inlist(agency_name, "savannah chatham metro police department") & (state_abbrev=="GA")
replace agency_name = "springfield police department" if inlist(agency_name, "springfield police department deaprtment") & (state_abbrev=="GA")

* Hawaii: 
replace agency_name = "hawaii police department" if inlist(agency_name, "hawaii county police department") & (state_abbrev=="HI")
replace agency_name = "honolulu police department" if inlist(agency_name, "honolulu county police department") & (state_abbrev=="HI")
replace agency_name = "kauai police department" if inlist(agency_name, "kauai county police department") & (state_abbrev=="HI")
replace agency_name = "maui police department" if inlist(agency_name, "maui county police department") & (state_abbrev=="HI")

* Iowa: 
replace agency_name = "iowa state patrol" if inlist(agency_name, "iowa department of public safety") & (state_abbrev=="IA")
replace agency_name = "le mars police department" if inlist(agency_name, "lemars police department") & (state_abbrev=="IA")
replace agency_name = "manchester police department" if inlist(agency_name, "manchester iowa police department") & (state_abbrev=="IA")
replace agency_name = "pottawattamie county sheriff's office" if inlist(agency_name, "pottawattamie county sheriff's office offi") & (state_abbrev=="IA")
replace agency_name = "sac county sheriff's office" if inlist(agency_name, "sac county iowa") & (state_abbrev=="IA")

* Idaho: 
replace agency_name = "idaho state police" if inlist(agency_name, "idaho state police department")  & (state_abbrev=="ID")

* Illinois: 
replace agency_name = "bloomington police department" if inlist(agency_name, "bloomington il police department") & (state_abbrev=="IL")
replace agency_name = "clark county sheriff's office" if inlist(agency_name, "clark co il sheriff's office") & (state_abbrev=="IL")
replace agency_name = "clay county sheriff's office" if inlist(agency_name, "clay county illinois") & (state_abbrev=="IL")
replace agency_name = "east st louis police department" if inlist(agency_name, "east saint louis police department") & (state_abbrev=="IL")
replace agency_name = "dupage county sheriff's office" if inlist(agency_name, "du page county sheriff's office") & (state_abbrev=="IL")
replace agency_name = "marquette heights police department" if inlist(agency_name, "marquette heights police department departmen") & (state_abbrev=="IL")
replace agency_name = "milan police department" if inlist(agency_name, "milan il police department") & (state_abbrev=="IL")
replace agency_name = "peoria police department" if inlist(agency_name, "peoria il police department") & (state_abbrev=="IL")
replace agency_name = "pulaski county sheriff's office" if inlist(agency_name, "pulaski county sheriff's officepula") & (state_abbrev=="IL")
replace agency_name = "rosemont public safety department" if inlist(agency_name, "rosemont police department") & (state_abbrev=="IL")
replace agency_name = "st clair county sheriff's office" if inlist(agency_name, "saint clair county sheriff's office") & (state_abbrev=="IL")

* Indiana: 
replace agency_name = "adams county sheriff's office" if inlist(agency_name, "adams county indiana sheriff's office") & (state_abbrev=="IN")
replace agency_name = "indiana state police" if inlist(agency_name, "indiana state police department") & (state_abbrev=="IN")
replace agency_name = "indianapolis metropolitan police department" if inlist(agency_name, "indianapolis metro police department") & (state_abbrev=="IN")
replace agency_name = "richmond police department" if inlist(agency_name, "richmond indiana police department") & (state_abbrev=="IN")
replace agency_name = "st joseph county sheriff's office" if inlist(agency_name, "saint joseph county sheriff's office") & (state_abbrev=="IN")
replace agency_name = "st john police department" if inlist(agency_name, "st. john police department") & (state_abbrev=="IN")

* Kansas: 
replace agency_name = "allen county sheriff's office" if inlist(agency_name, "allen county law enforcement") & (state_abbrev=="KS")
replace agency_name = "butler county sheriff's office" if inlist(agency_name, "butler co kansas sheriff's office") & (state_abbrev=="KS")
replace agency_name = "gardner police department" if inlist(agency_name, "gardner department of public safety", "gardner public safety department") & (state_abbrev=="KS")
replace agency_name = "iowa tribal police" if inlist(agency_name, "iowa (of ks and ne) tribal police") & (state_abbrev=="KS")
replace agency_name = "sumner county sheriff's office" if inlist(agency_name, "summer county sheriff's office") & (state_abbrev=="KS")

* Kentucky: 
replace agency_name = "kentucky state police" if inlist(agency_name, "kentucky state police department") & (state_abbrev=="KY")
replace agency_name = "lexington division of police" if inlist(agency_name, "lexington division of police department") & (state_abbrev=="KY")
replace agency_name = "lexington police department" if inlist(agency_name, "lexington division of police", "lexington-fayette county police department") & (state_abbrev=="KY")
replace agency_name = "nicholas county sheriff's office" if inlist(agency_name, "nicholas county") & (state_abbrev=="KY")

* Louisiana: 
replace agency_name = "baton rouge police department" if inlist(agency_name, "baton rouge city police department") & (state_abbrev=="LA")
replace agency_name = "bossier parish sheriff's office" if inlist(agency_name, "bossier sheriff's office") & (state_abbrev=="LA")
replace agency_name = "east baton rouge parish sheriff's office" if inlist(agency_name, "e baton rouge parish sheriff's office") & (state_abbrev=="LA")
replace agency_name = "iberia parish sheriff's office" if inlist(agency_name, "iberia parish sheridd") & (state_abbrev=="LA")
replace agency_name = "st charles parish sheriff's office" if inlist(agency_name, "st charles sheriff's office") & (state_abbrev=="LA")
replace agency_name = "st bernard parish sheriff's office" if inlist(agency_name, "st. bernard parish sheriff's office") & (state_abbrev=="LA")
replace agency_name = "st charles parish sheriff's office" if inlist(agency_name, "st. charles parish sheriff's office") & (state_abbrev=="LA")
replace agency_name = "st john the baptist parish sheriff's office" if inlist(agency_name, "st. john the baptist parish sheriff's office") & (state_abbrev=="LA")
replace agency_name = "st landry parish sheriff's office" if inlist(agency_name, "st. landry parish sheriff's office") & (state_abbrev=="LA")
replace agency_name = "st mary parish sheriff's office" if inlist(agency_name, "st. mary parish sheriff's office") & (state_abbrev=="LA")

* Massachusetts: 
replace agency_name = "massachusetts state police" if inlist(agency_name, "massachusetts state police department", "massachusetts department of state p") & (state_abbrev=="MA")

* Maryland: 
replace agency_name = "frederick city police department" if inlist(agency_name, "frederick police department") & (state_abbrev=="MD")
replace agency_name = "frederick county sheriff's office" if inlist(agency_name, "fredrick county sheriff's office") & (state_abbrev=="MD")
replace agency_name = "prince george's county sheriff's office" if inlist(agency_name, "office of the sheriff's office for prince") & (state_abbrev=="MD")
replace agency_name = "prince george's county police department" if inlist(agency_name, "prince georges county police department") & (state_abbrev=="MD")
replace agency_name = "st mary's county sheriff's office" if inlist(agency_name, "st marys county sheriff's office", "saint marys county sheriff's office") & (state_abbrev=="MD")

* Maine: 
replace agency_name = "maine state police" if inlist(agency_name, "maine state police department") & (state_abbrev=="ME")
 
* Michigan: 
replace agency_name = "clinton township police department" if inlist(agency_name, "clinton charter township police department") & (state_abbrev=="MI")
replace agency_name = "farmington department of public safety" if inlist(agency_name, "farmington public safety") & (state_abbrev=="MI")
replace agency_name = "grosse pointe woods department of public safety" if inlist(agency_name, "grosse pointe woods dps", "grosse pointe woods police department") & (state_abbrev=="MI")
replace agency_name = "madison township police department" if inlist(agency_name, "madison twp police department") & (state_abbrev=="MI")
replace agency_name = "metamora township police department" if inlist(agency_name, "metamora police department") & (state_abbrev=="MI")
replace agency_name = "michigan state police" if inlist(agency_name, "michigan state police department") & (state_abbrev=="MI")
replace agency_name = "oakland county sheriff's office" if inlist(agency_name, "oakland country sheriff's office") & (state_abbrev=="MI")
replace agency_name = "office of genesee county sheriff" if inlist(agency_name, "office of sheriff's office genesee county") & (state_abbrev=="MI")
replace agency_name = "plymouth city police department" if inlist(agency_name, "plymouth (city) police department") & (state_abbrev=="MI")
replace agency_name = "plymouth township police department" if inlist(agency_name, "plymouth twp police department") & (state_abbrev=="MI")
replace agency_name = "st joseph charter township police department" if inlist(agency_name, "st. joseph police department") & (state_abbrev=="MI")
replace agency_name = "st clair shores police department" if inlist(agency_name, "st. clair shores police department") & (state_abbrev=="MI")
replace agency_name = "st ignace police department" if inlist(agency_name, "st. ignace police department") & (state_abbrev=="MI")
replace agency_name = "st johns police department" if inlist(agency_name, "st. johns police department") & (state_abbrev=="MI")
replace agency_name = "tittabawassee township police department" if inlist(agency_name, "tittabawassee twp police department") & (state_abbrev=="MI")
replace agency_name = "troy police department" if inlist(agency_name, "troy michigan police department") & (state_abbrev=="MI")

* Minnesota: 
replace agency_name = "inver grove heights police department" if inlist(agency_name, "inver grove heights public safety dep.") & (state_abbrev=="MN")
replace agency_name = "red lake tribal department of public safety" if inlist(agency_name, "red lake tribal dps") & (state_abbrev=="MN")
replace agency_name = "rochester police department" if inlist(agency_name, "rocehster police department") & (state_abbrev=="MN")
replace agency_name = "st anthony police department" if inlist(agency_name, "saint anthony police department") & (state_abbrev=="MN")
replace agency_name = "st cloud police department" if inlist(agency_name, "saint cloud police department", "st. cloud police department") & (state_abbrev=="MN")
replace agency_name = "st paul police department" if inlist(agency_name, "saint paul police department", "st. paul police department") & (state_abbrev=="MN")

* Missouri: 
replace agency_name = "barry county sheriff's office" if inlist(agency_name, "barry county mo") & (state_abbrev=="MO")
replace agency_name = "carroll county sheriff's office" if inlist(agency_name, "chief deputy") & (state_abbrev=="MO")
replace agency_name = "o'fallon police department" if inlist(agency_name, "city of o'fallon mo police department") & (state_abbrev=="MO")
replace agency_name = "cole camp police department" if inlist(agency_name, "cole camp missouri police department") & (state_abbrev=="MO")
replace agency_name = "gladstone police department" if inlist(agency_name, "gladstone department of public safety") & (state_abbrev=="MO")
replace agency_name = "lee's summit police department" if inlist(agency_name, "lees summit police department") & (state_abbrev=="MO")
replace agency_name = "st ann police department" if inlist(agency_name, "saint ann police department") & (state_abbrev=="MO")
replace agency_name = "st charles police department" if inlist(agency_name, "saint charles police department") & (state_abbrev=="MO")
replace agency_name = "st clair county sheriff's office" if inlist(agency_name, "saint clair county sheriff's office") & (state_abbrev=="MO")
replace agency_name = "st joseph police department" if inlist(agency_name, "saint joseph police department", "st. joseph police department") & (state_abbrev=="MO")
replace agency_name = "st louis metropolitan police department" if inlist(agency_name, "saint louis city police department", "st. louis metropolitan police department") & (state_abbrev=="MO")
replace agency_name = "st louis county police department" if inlist(agency_name, "saint louis county police department", "st. louis county police department") & (state_abbrev=="MO")
replace agency_name = "st mary police department" if inlist(agency_name, "saint mary police department") & (state_abbrev=="MO")
replace agency_name = "sikeston police department" if inlist(agency_name, "sikeston public safety") & (state_abbrev=="MO")

* Mississippi: 
replace agency_name = "mississippi highway patrol" if inlist(agency_name, "mississippi department of public safety") & (state_abbrev=="MS")

* Montana: 
replace agency_name = "cascade county sheriff's office" if inlist(agency_name, "cascade county sheriff's office and") & (state_abbrev=="MT")
replace agency_name = "granite county sheriff's office" if inlist(agency_name, "granite county") & (state_abbrev=="MT")
replace agency_name = "kalispell police department" if inlist(agency_name, "kallspell police department") & (state_abbrev=="MT")

* North Carolina: 
replace agency_name = "charlotte-mecklenburg police department" if inlist(agency_name, "charlottemecklenburg police department") & (state_abbrev=="NC")
replace agency_name = "havelock police department" if inlist(agency_name, "havelook police department") & (state_abbrev=="NC")
replace agency_name = "holly springs police department" if inlist(agency_name, "holly springs public safety") & (state_abbrev=="NC")
replace agency_name = "new hanover county sheriff's office" if inlist(agency_name, "new hanover county sheriff's office's") & (state_abbrev=="NC")
replace agency_name = "north carolina state highway patrol" if inlist(agency_name, "north carolina state hwy patrol") & (state_abbrev=="NC")
replace agency_name = "rowan county sheriff's office" if inlist(agency_name, "rowan sheriff's office") & (state_abbrev=="NC")
replace agency_name = "winston-salem police department" if inlist(agency_name, "winstonsalem police department") & (state_abbrev=="NC")

* North Daokta: 
replace agency_name = "griggs county sheriff's office" if inlist(agency_name, "griggs county nd") & (state_abbrev=="ND")
replace agency_name = "kidder county sheriff's office" if inlist(agency_name, "kidder county") & (state_abbrev=="ND")
replace agency_name = "north dakota highway patrol" if inlist(agency_name, "nd highway patrol", "north dakota state highway patrol") & (state_abbrev=="ND")
replace agency_name = "renville county sheriff's office" if inlist(agency_name, "renville county so") & (state_abbrev=="ND")
replace agency_name = "williams county sheriff's office" if inlist(agency_name, "williams county so") & (state_abbrev=="ND")

* Nebraska: 
replace agency_name = "fillmore county sheriff's office" if inlist(agency_name, "fillmore county") & (state_abbrev=="NE")
replace agency_name = "wheeler county sheriff's office" if inlist(agency_name, "wheeler county sheriff's office nebraska") & (state_abbrev=="NE")

* New Hampshire: 
replace agency_name = "amherst police department" if inlist(agency_name, "amherst nh police department") & (state_abbrev=="NH")
replace agency_name = "hillsborough county sheriff's office" if inlist(agency_name, "hillsborough county sheriff's office offic") & (state_abbrev=="NH")
replace agency_name = "new hampshire state police" if inlist(agency_name, "new hampshire state police department") & (state_abbrev=="NH")

* New Jersey: 
replace agency_name = subinstr(agency_name, "twp police department", "township police department", .) if (state_abbrev=="NJ")
replace agency_name = "asbury park police department" if inlist(agency_name, "asbury park public safety dept") & (state_abbrev=="NJ")
replace agency_name = "barnegat township police department" if inlist(agency_name, "barnegat police department") & (state_abbrev=="NJ")
replace agency_name = "belleville police department" if inlist(agency_name, "belleville township police department") & (state_abbrev=="NJ")
replace agency_name = "bellmawr police department" if inlist(agency_name, "bellmawr borough police department") & (state_abbrev=="NJ")
replace agency_name = "bloomfield police department" if inlist(agency_name, "bloomfield township police department") & (state_abbrev=="NJ")
replace agency_name = "boonton police department" if inlist(agency_name, "boonton township police department") & (state_abbrev=="NJ")
replace agency_name = "brick township police department" if inlist(agency_name, "brick police department", "brick twp department of public safety") & (state_abbrev=="NJ")
replace agency_name = "bridgeton police department" if inlist(agency_name, "bridgewater township police department") & (state_abbrev=="NJ")
replace agency_name = "camden county police department" if inlist(agency_name, "camden police department") & (state_abbrev=="NJ")
replace agency_name = "cape may police department" if inlist(agency_name, "cape may city police department") & (state_abbrev=="NJ")
replace agency_name = "cranford township police department" if inlist(agency_name, "cranford police department") & (state_abbrev=="NJ")
replace agency_name = "edison police department" if inlist(agency_name, "edison township police department") & (state_abbrev=="NJ")
replace agency_name = "far hills police department" if inlist(agency_name, "far hills boro police department") & (state_abbrev=="NJ")
replace agency_name = "lakewood police department" if inlist(agency_name, "lakewood township police department") & (state_abbrev=="NJ")
replace agency_name = "long branch police department" if inlist(agency_name, "long branch (city) pub sfty dept") & (state_abbrev=="NJ")
replace agency_name = "new brunswick police department" if inlist(agency_name, "new brunswick city police department") & (state_abbrev=="NJ")
replace agency_name = "new jersey state police" if inlist(agency_name, "new jersey state police department") & (state_abbrev=="NJ")
replace agency_name = "north bergen police department" if inlist(agency_name, "north bergen township police department") & (state_abbrev=="NJ")
replace agency_name = "orange township police department" if inlist(agency_name, "orange (city of) township police department", "orange police department") & (state_abbrev=="NJ")
replace agency_name = "parsippany-troy hills police department" if inlist(agency_name, "parsippany-troy hills township police department") & (state_abbrev=="NJ")
replace agency_name = "plainfield police department" if inlist(agency_name, "plainfield police department division") & (state_abbrev=="NJ")
replace agency_name = "ringwood police department" if inlist(agency_name, "ringwood boro police department") & (state_abbrev=="NJ")
replace agency_name = "roselle park police department" if inlist(agency_name, "roselle park borough police department") & (state_abbrev=="NJ")
replace agency_name = "sussex county sheriff's office" if inlist(agency_name, "sheriff's office sussex county") & (state_abbrev=="NJ")
replace agency_name = "south brunswick police department" if inlist(agency_name, "south brunswick township police department") & (state_abbrev=="NJ")
replace agency_name = "teaneck police department" if inlist(agency_name, "teaneck township police department") & (state_abbrev=="NJ")
replace agency_name = "tinton falls police department" if inlist(agency_name, "tinto falls police department") & (state_abbrev=="NJ")
replace agency_name = "toms river police department" if inlist(agency_name, "toms river township police department") & (state_abbrev=="NJ")
replace agency_name = "washington township police department" if inlist(agency_name, "washington twp (gloucester co.) police department") & (state_abbrev=="NJ")
replace agency_name = "west orange police department" if inlist(agency_name, "west orange township police department") & (state_abbrev=="NJ")
replace agency_name = "woodbridge police department" if inlist(agency_name, "woodbridge township police department") & (state_abbrev=="NJ")

* New Mexico: 
replace agency_name = "new mexico state police" if inlist(agency_name, "new mexico state police department") & (state_abbrev=="NM")

* Nevada: 
replace agency_name = "las vegas metropolitan police department" if inlist(agency_name, "las vegas metro police department") & (state_abbrev=="NV")

* New York: 
replace agency_name = "albany police department" if inlist(agency_name, "albany (city) police department", "albany city police department") & (state_abbrev=="NY")
replace agency_name = "amherst police department" if inlist(agency_name, "amherst (town) police department", "amherst town police department") & (state_abbrev=="NY")
replace agency_name = "auburn police department" if inlist(agency_name, "auburn city police department") & (state_abbrev=="NY")
replace agency_name = "bedford police department" if inlist(agency_name, "bedford town police department") & (state_abbrev=="NY")
replace agency_name = "binghamton police department" if inlist(agency_name, "binghamton city police department") & (state_abbrev=="NY")
replace agency_name = "buffalo police department" if inlist(agency_name, "buffalo (city) police department", "buffalo city police department") & (state_abbrev=="NY")
replace agency_name = "cheektowaga police department" if inlist(agency_name, "cheektowaga (town) police department", "cheektowaga town police department") & (state_abbrev=="NY")
replace agency_name = "clarkstown police department" if inlist(agency_name, "clarkstown (town) police department", "clarkstown town police department") & (state_abbrev=="NY")
replace agency_name = "colonie police department" if inlist(agency_name, "colonie (town) police department", "colonie town police department") & (state_abbrev=="NY")
replace agency_name = "depew police department" if inlist(agency_name, "depew (vlg) police department") & (state_abbrev=="NY")
replace agency_name = "east fishkill town police department" if inlist(agency_name, "east fishkill (town) police department") & (state_abbrev=="NY")
replace agency_name = "ellenville village police department" if inlist(agency_name, "ellenville (vlg) police department") & (state_abbrev=="NY")
replace agency_name = "geneva police department" if inlist(agency_name, "geneva city police department") & (state_abbrev=="NY")
replace agency_name = "goshen police department" if inlist(agency_name, "goshen (vlg) police department") & (state_abbrev=="NY")
replace agency_name = "gouverneur village police department" if inlist(agency_name, "gouverneur (vlg) police department") & (state_abbrev=="NY")
replace agency_name = "greenburgh town police department" if inlist(agency_name, "greenburgh (town) police department") & (state_abbrev=="NY")
replace agency_name = "harrison police department" if inlist(agency_name, "harrison (vlg) police department") & (state_abbrev=="NY")
replace agency_name = "hempstead police department" if inlist(agency_name, "hempstead (vlg) police department", "hempstead village police department") & (state_abbrev=="NY")
replace agency_name = "huntington bay police department" if inlist(agency_name, "huntington bay village police department") & (state_abbrev=="NY")
replace agency_name = "long beach police department" if inlist(agency_name, "long beach city police department") & (state_abbrev=="NY")
replace agency_name = "middletown police department" if inlist(agency_name, "middletown (city) police department") & (state_abbrev=="NY")
replace agency_name = "mount vernon police department" if inlist(agency_name, "mount vernon (city) police department") & (state_abbrev=="NY")
replace agency_name = "new rochelle police department" if inlist(agency_name, "new rochelle (city) police department", "new rochelle city police department") & (state_abbrev=="NY")
replace agency_name = "newburgh police department" if inlist(agency_name, "newburgh (city) police department", "newburgh city police department") & (state_abbrev=="NY")
replace agency_name = "niagara falls police department" if inlist(agency_name, "niagara falls (city) police department", "niagara falls city police department") & (state_abbrev=="NY")
replace agency_name = "north castle police department" if inlist(agency_name, "north castle town police department") & (state_abbrev=="NY")
replace agency_name = "plattsburgh police department" if inlist(agency_name, "plattsburgh (city) police department") & (state_abbrev=="NY")
replace agency_name = "ramapo police department" if inlist(agency_name, "ramapo town police department") & (state_abbrev=="NY")
replace agency_name = "rensselaer city police department" if inlist(agency_name, "rensselaer (city) police department") & (state_abbrev=="NY")
replace agency_name = "rochester police department" if inlist(agency_name, "rochester (city) police department") & (state_abbrev=="NY")
replace agency_name = "suffolk county sheriff's office" if inlist(agency_name, "sc sheriff's office") & (state_abbrev=="NY")
replace agency_name = "schenectady police department" if inlist(agency_name, "schenectady city police department") & (state_abbrev=="NY")
replace agency_name = "sleepy hollow village police department" if inlist(agency_name, "sleepy hollow (vlg) police department") & (state_abbrev=="NY")
replace agency_name = "southampton town police department" if inlist(agency_name, "southampton (town) police department") & (state_abbrev=="NY")
replace agency_name = "stony point police department" if inlist(agency_name, "stony point town police department") & (state_abbrev=="NY")
replace agency_name = "syracuse police department" if inlist(agency_name, "syracuse city police department", "syracuse (city) police department") & (state_abbrev=="NY")
replace agency_name = "tonawanda town police department" if inlist(agency_name, "tonawanda (town) police department") & (state_abbrev=="NY")
replace agency_name = "troy police department" if inlist(agency_name, "troy (city) police department", "troy city police department") & (state_abbrev=="NY")
replace agency_name = "utica police department" if inlist(agency_name, "utica (city) police department", "utica city police department") & (state_abbrev=="NY")
replace agency_name = "vestal town police department" if inlist(agency_name, "vestal (town) police department") & (state_abbrev=="NY")
replace agency_name = "watertown police department" if inlist(agency_name, "watertown (city) police department") & (state_abbrev=="NY")
replace agency_name = "west seneca police department" if inlist(agency_name, "west seneca (town) police department") & (state_abbrev=="NY")
replace agency_name = "westchester county department of public safety" if inlist(agency_name, "westchester county dept of pub sfty", "westchester county dps") & (state_abbrev=="NY")
replace agency_name = "white plains police department" if inlist(agency_name, "white plains (city) police department", "white plains department of public safety") & (state_abbrev=="NY")
replace agency_name = "windham town police department" if inlist(agency_name, "windham (town) police department") & (state_abbrev=="NY")
replace agency_name = "yonkers police department" if inlist(agency_name, "yonkers (city) police department", "yonkers city police department") & (state_abbrev=="NY")

* Ohio: 
replace agency_name = "bowling green police division" if inlist(agency_name, "bowling green police department division") & (state_abbrev=="OH")
replace agency_name = "cleveland division of police" if inlist(agency_name, "cleveland division of police department", "cleveland police department") & (state_abbrev=="OH")
replace agency_name = "columbus division of police" if inlist(agency_name, "columbus division of police department", "columbus police department") & (state_abbrev=="OH")
replace agency_name = "grove city division of police" if inlist(agency_name, "grove city division of police department", "grove city police department") & (state_abbrev=="OH")
replace agency_name = "hamilton county sheriff's office" if inlist(agency_name, "hamilton county ohio sheriff's office") & (state_abbrev=="OH")
replace agency_name = "miami township police department" if inlist(agency_name, "miami twp (clermont co) police department") & (state_abbrev=="OH")
replace agency_name = "middletown division of police" if inlist(agency_name, "middletown division of police department", "middletown police department") & (state_abbrev=="OH")
replace agency_name = "moraine police division" if inlist(agency_name, "moraine police department division") & (state_abbrev=="OH")
replace agency_name = "newark division of police" if inlist(agency_name, "newark division of police department") & (state_abbrev=="OH")
replace agency_name = "oxford division of police" if inlist(agency_name, "oxford division of police department") & (state_abbrev=="OH")
replace agency_name = "pataskala division of police" if inlist(agency_name, "pataskala division of police department") & (state_abbrev=="OH")
replace agency_name = "wooster police division" if inlist(agency_name, "wooster police department", "wooster police department division") & (state_abbrev=="OH")

* Oklahoma: 
replace agency_name = "altus police department" if inlist(agency_name, "altas police department") & (state_abbrev=="OK")
replace agency_name = "choctaw nation tribal law enforcement" if inlist(agency_name, "choctaw nation tribal le") & (state_abbrev=="OK")
replace agency_name = "el reno police department" if inlist(agency_name, "elreno police department") & (state_abbrev=="OK")
replace agency_name = "mccurtain police department" if inlist(agency_name, "mc curtain police department") & (state_abbrev=="OK")
replace agency_name = "oklahoma highway patrol" if inlist(agency_name, "oklahoma highway patrol dps") & (state_abbrev=="OK")
replace agency_name = "stilwell police department" if inlist(agency_name, "stillwell police department") & (state_abbrev=="OK")

* Oregon: 
replace agency_name = "tribal police confederated trips" if inlist(agency_name, "coos,umpqua,siuslaw tribal police") & (state_abbrev=="OR")
replace agency_name = "jackson county sheriff's office" if inlist(agency_name, "jackson county sheriff's office county") & (state_abbrev=="OR")
replace agency_name = "oregon state police" if inlist(agency_name, "oregon state police department") & (state_abbrev=="OR")
replace agency_name = "portland police bureau" if inlist(agency_name, "portland police department bureau") & (state_abbrev=="OR")

* Pennsylvania: 
replace agency_name = "allentown police department" if inlist(agency_name, "allentown city police department") & (state_abbrev=="PA")
replace agency_name = "bristol township police department" if inlist(agency_name, "bristol twp police department") & (state_abbrev=="PA")
replace agency_name = "bryn athyn police department" if inlist(agency_name, "bryn athyn borough police department") & (state_abbrev=="PA")
replace agency_name = "chester police department" if inlist(agency_name, "chester city police department") & (state_abbrev=="PA")
replace agency_name = "erie bureau of police" if inlist(agency_name, "erie bureau of police department") & (state_abbrev=="PA")
replace agency_name = "falls township police department" if inlist(agency_name, "falls twp police department") & (state_abbrev=="PA")
replace agency_name = "forks township police department" if inlist(agency_name, "forks twp police department") & (state_abbrev=="PA")
replace agency_name = "gettysburg borough police department" if inlist(agency_name, "gettysburg boroug police department") & (state_abbrev=="PA")
replace agency_name = "hampden township police department" if inlist(agency_name, "hampden twp police department") & (state_abbrev=="PA")
replace agency_name = "horsham police department" if inlist(agency_name, "horsham twp police department") & (state_abbrev=="PA")
replace agency_name = "lehighton police department" if inlist(agency_name, "lehighton borough police department") & (state_abbrev=="PA")
replace agency_name = "lower merion township police department" if inlist(agency_name, "lower merion twp police department") & (state_abbrev=="PA")
replace agency_name = "masontown police department" if inlist(agency_name, "masontown borough police department") & (state_abbrev=="PA")
replace agency_name = "middletown township police department" if inlist(agency_name, "middletown twp police department") & (state_abbrev=="PA")
replace agency_name = "montoursville police department" if inlist(agency_name, "montoursville borough police department") & (state_abbrev=="PA")
replace agency_name = "north huntington township police department" if inlist(agency_name, "north huntingdon township police department") & (state_abbrev=="PA")
replace agency_name = "northampton borough police department" if inlist(agency_name, "northamptontownship police department") & (state_abbrev=="PA")
replace agency_name = "pennsylvania state police" if inlist(agency_name, "pennsylvania state police department") & (state_abbrev=="PA")
replace agency_name = "philadelphia police department" if inlist(agency_name, "philadelphia city police department") & (state_abbrev=="PA")
replace agency_name = "pittsburgh bureau of police department" if inlist(agency_name, "pittsburgh city police department") & (state_abbrev=="PA")
replace agency_name = "pottsville bureau of police" if inlist(agency_name, "pottsville bureau of police department", "pottsville police department") & (state_abbrev=="PA")
replace agency_name = "punxsutawney police department" if inlist(agency_name, "punxsutawney borough police department") & (state_abbrev=="PA")
replace agency_name = "reading police department" if inlist(agency_name, "reading city police department") & (state_abbrev=="PA")
replace agency_name = "roseto police department" if inlist(agency_name, "roseto borough police department") & (state_abbrev=="PA")
replace agency_name = "scranton police department" if inlist(agency_name, "scranton city police department") & (state_abbrev=="PA")
replace agency_name = "steelton police department" if inlist(agency_name, "steelton borough police department") & (state_abbrev=="PA")
replace agency_name = "warrington police department" if inlist(agency_name, "warrington township police department") & (state_abbrev=="PA")
replace agency_name = "waynesboro police department" if inlist(agency_name, "waynesboro borough police department") & (state_abbrev=="PA")
replace agency_name = "weatherly police department" if inlist(agency_name, "weatherly borough dept") & (state_abbrev=="PA")
replace agency_name = "yeadon police department" if inlist(agency_name, "yeadon borough police department") & (state_abbrev=="PA")
replace agency_name = "wilkes barre township police department" if inlist(agency_name, "wilkes barre (city) police department") & (state_abbrev=="PA")

* Rhode Island: 
replace agency_name = "rhode island state police" if inlist(agency_name, "rhode island state police department") & (state_abbrev=="RI")

* South Carolina: 
replace agency_name = "greenville county sheriff's office" if inlist(agency_name, "greenville sheriff's office county") & (state_abbrev=="SC")
replace agency_name = "north myrtle beach police department" if inlist(agency_name, "north myrtle beach department", "north myrtle beach dps") & (state_abbrev=="SC")

* South Dakota: 
replace agency_name = "oglala sioux tribal dps" if inlist(agency_name, "ogala sioux tribe dps") & (state_abbrev=="SD")
replace agency_name = "sioux falls police department" if inlist(agency_name, "sioux falls police department depatment") & (state_abbrev=="SD")

* Tennessee: 
replace agency_name = "metro nashville police department" if inlist(agency_name, "nashville metro police department") & (state_abbrev=="TN")
replace agency_name = "tennessee highway patrol" if inlist(agency_name, "tennessee department of safety") & (state_abbrev=="TN")
replace agency_name = "washington county sheriff's office" if inlist(agency_name, "washington county tn sheriff's office ofc") & (state_abbrev=="TN")

* Texas: 
replace agency_name = "arlington police department" if inlist(agency_name, "arlington tx police department") & (state_abbrev=="TX")
replace agency_name = "denton county sheriff's office" if inlist(agency_name, "dentan county sheriff's office") & (state_abbrev=="TX")
replace agency_name = "euless police department" if inlist(agency_name, "euless texas police department") & (state_abbrev=="TX")
replace agency_name = "floyd county sheriff's office" if inlist(agency_name, "floydn county sheriff's office") & (state_abbrev=="TX")
replace agency_name = "highland park department of public safety" if inlist(agency_name, "highland park dept of pub safety", "highland park dps") & (state_abbrev=="TX")
replace agency_name = "killeen police department" if inlist(agency_name, "kileen police department") & (state_abbrev=="TX")
replace agency_name = "la salle county sheriff's office" if inlist(agency_name, "lasalle county sheriff's office") & (state_abbrev=="TX")
replace agency_name = "mount pleasant police department" if inlist(agency_name, "mt pleasant police department") & (state_abbrev=="TX")
replace agency_name = "edwards county sheriff's office" if inlist(agency_name, "office of the sheriff's office edwards cotx") & (state_abbrev=="TX")

* Utah: 
replace agency_name = "duchesne sheriff's office" if inlist(agency_name, "duchesne utah") & (state_abbrev=="UT")
replace agency_name = "logan police department" if inlist(agency_name, "logan city police department") & (state_abbrev=="UT")
replace agency_name = "ogden police department" if inlist(agency_name, "ogden city police department") & (state_abbrev=="UT")
replace agency_name = "orem police department" if inlist(agency_name, "orem department of public safety") & (state_abbrev=="UT")
replace agency_name = "price police department" if inlist(agency_name, "price city police department") & (state_abbrev=="UT")
replace agency_name = "provo police department" if inlist(agency_name, "provo city police department") & (state_abbrev=="UT")
replace agency_name = "st george police department" if inlist(agency_name, "st. george police department") & (state_abbrev=="UT")
replace agency_name = "utah highway patrol" if inlist(agency_name, "utah department of public safety") & (state_abbrev=="UT")
replace agency_name = "west jordan police department" if inlist(agency_name, "west jordan city police department") & (state_abbrev=="UT")

* Virginia: 
replace agency_name = "albemarle county police department" if inlist(agency_name, "albemarle county dept") & (state_abbrev=="VA")
replace agency_name = "arlington county police department" if inlist(agency_name, "arlington police department") & (state_abbrev=="VA")
replace agency_name = "chesterfield county police department" if inlist(agency_name, "chesterfield police department") & (state_abbrev=="VA")
replace agency_name = "fairfax county police department" if inlist(agency_name, "fairfax police department") & (state_abbrev=="VA")
replace agency_name = "hampton police division" if inlist(agency_name, "hampton police department division", "hampton police department") & (state_abbrev=="VA")
replace agency_name = "henrico county division of police" if inlist(agency_name, "henrico county division of police department", "henrico county police department") & (state_abbrev=="VA")
replace agency_name = "manassas police department" if inlist(agency_name, "manassas (city) police department") & (state_abbrev=="VA")
replace agency_name = "petersburg bureau of police" if inlist(agency_name, "petersburg bureau of police department", "petersburg police department") & (state_abbrev=="VA")
replace agency_name = "roanoke police department" if inlist(agency_name, "roanoke (city) police department", "roanoke city police department") & (state_abbrev=="VA")
replace agency_name = "spotsylvania county sheriff's office" if inlist(agency_name, "spotsylvania sheriff's office") & (state_abbrev=="VA")
replace agency_name = "sussex county sheriff's office" if inlist(agency_name, "sussex sheriff's office") & (state_abbrev=="VA")
replace agency_name = "virginia state police" if inlist(agency_name, "virginia dept of state police department", "virginia state police department") & (state_abbrev=="VA")

* Vermont: 
replace agency_name = "vermont state police department" if inlist(agency_name, "vermont department of public safety") & (state_abbrev=="VT")

* Washington: 
replace agency_name = "bingen-white salmon police department" if inlist(agency_name, "bingen-white salmonbingen police department") & (state_abbrev=="WA")

* Wisconsin: 
replace agency_name = "brandon-fairwater police department" if inlist(agency_name, "brandonfairwater police department") & (state_abbrev=="WI")
replace agency_name = "colby-abbotsford police department" if inlist(agency_name, "colbyabbotsford police department") & (state_abbrev=="WI")
replace agency_name = "la crosse county sheriff's office" if inlist(agency_name, "la crosse county sheriff's office departme") & (state_abbrev=="WI")
replace agency_name = "madison police department" if inlist(agency_name, "madison (town) police department") & (state_abbrev=="WI")
replace agency_name = "manitowoc county sheriff's office" if inlist(agency_name, "manitowoc sheriff's office") & (state_abbrev=="WI")
replace agency_name = "manitowok police department" if inlist(agency_name, "manitowok police department de[t") & (state_abbrev=="WI")

* West Virginia: 
replace agency_name = "west virginia state police" if inlist(agency_name, "west virginia state police department") & (state_abbrev=="WV")

* Wyoming: 
replace agency_name = "goshen county sheriff's office" if inlist(agency_name, "goshen county so") & (state_abbrev=="WY")
replace agency_name = "johnson county sheriff's office" if inlist(agency_name, "johnson county so") & (state_abbrev=="WY")
replace agency_name = "laramie county sheriff's office" if inlist(agency_name, "laramie county sherrifs dept") & (state_abbrev=="WY")
replace agency_name = "natrona county sheriff's office" if inlist(agency_name, "natrona county so") & (state_abbrev=="WY")
replace agency_name = "sweetwater county sheriff's office" if inlist(agency_name, "sweetwater county so") & (state_abbrev=="WY")
replace agency_name = "uinta county sheriff's office" if inlist(agency_name, "uinta county so") & (state_abbrev=="WY")

display "string variables:"
ds, has(type string) var(32)
display ""
display "non-string variables:"
ds, not(type string) var(32)

save "2000_data/400_base/LEMAS_base.dta", replace

log close
