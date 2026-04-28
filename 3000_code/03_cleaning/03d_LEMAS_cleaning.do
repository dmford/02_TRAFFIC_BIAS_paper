*  04d_LEMAS_cleaning.do	

clear all

* (1) HPCC cluster, and (2) personal machine: 
cd "/bigdata/mbateslab/dford013/coding/02_TRAFFIC_BIAS_paper"
*cd "~\coding\02_TRAFFIC_BIAS_paper\"

********************************************************************************

log using "3000_code/03_cleaning/03_SMCL_logs/03d_LEMAS_cleaning", smcl replace



log close
