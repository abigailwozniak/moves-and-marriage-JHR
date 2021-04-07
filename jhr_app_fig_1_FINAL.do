*** This do file creates the data for Figure 1.  Text file output: jhr_app_fig_1.txt

 clear all
set more off
set matsize 1000
capture log close
set logtype text
set debug off

local date = "02032021"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/jhr_app_fig_1.txt, replace text
	global outsheet XXX/jhr_output


use $datadir/app_fig_1

** Appendix C Figure 1

histogram time_since_start_30 if filedt_s == min_date_move & term3 == 1

graph export $outsheet/time_since_start_30_term3.pdf, replace
tab time_since_start_30 if filedt_s == min_date_move & term3 == 1
