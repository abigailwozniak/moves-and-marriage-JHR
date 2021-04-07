
*** This do file creates the data for Figures 2 and 4.  Text file output: jhr_figs_2_4.txt

clear all
set more off
set matsize 1000
capture log close
set logtype text
set debug off

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/jhr_figs_2_4.txt, replace text
	global outsheet XXX/jhr_output

	
**************************************
**running for either six months pre and 24 post or visa versa
**************************************
local six_mo_pre = 1

if `six_mo_pre' {
use $datadir/data_for_graph_miles

*** t_pos0 is the same as t_neg1

forvalues x= 0/25 {
local y = `x' + 7
gen subseven`y' = t_pos`x'
}

gen subseven1 = t_neg7
gen subseven2 = t_neg6
gen subseven3 = t_neg5
gen subseven4 = t_neg4
gen subseven5 = t_neg3
gen subseven6 = t_neg2

keep if figure_sample == 1
}

reshape long subseven, i(id) j(mo)

gen age_round = round(age)

qui reg subseven i.age_round mo if conus_conus == 1
predict resid_trend, resid


 

foreach group in conus_conus worse_location worse_epop better_location better_epop conus_abroad worse_amm better_amm more_exp_rent less_exp_rent worse_shcon worse_shman worse_shgov worse_shmil better_shcon better_shman better_shgov better_shmil {

qui reg subseven i.age_round mo if `group' == 1
predict resid_trend_`group', resid

replace resid_trend_`group' = . if `group' ~= 1

qui reg subseven i.age_round if `group' == 1
predict resid_no_trend_`group', resid


replace resid_no_trend_`group' = . if `group' ~= 1

}
*** Data for Figures 2 & 4
** mo = 1 represents month (-6); mo = 7 represents month (0)
dis "`group' trend"
*** All of it:
tabstat resid_trend_*, by(mo)


** Figure 2
tabstat resid_trend_conus_conus, by(mo)

** Figure 4A
tabstat resid_trend_conus_conus resid_trend_worse_location resid_trend_better_location, by(mo)
** Figure 4B
tabstat resid_trend_conus_conus resid_trend_worse_epop resid_trend_better_epop, by(mo)
** Figure 4C
tabstat resid_trend_conus_conus resid_trend_more_exp_rent resid_trend_less_exp_rent, by(mo)
** Figure 4D
tabstat resid_trend_conus_conus resid_trend_worse_amm resid_trend_better_amm, by(mo)
** Figure 4E
tabstat resid_trend_conus_conus resid_trend_conus_abroad, by(mo)





exit

