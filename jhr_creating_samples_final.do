** This do file creates the samples used for tables 2-7, and appendix tables 1-4
** output: jhr_samples_created.dta

clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03222020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/samples_for_t2_7.txt, text replace 
	global figdir XXX/figs_miles
	global outsheet XXX/jhr_output
		
use $datadir/jhr_clean_for_tables	

		
***********************************************************************
***** creating different samples to run for each set of outcomes
***********************************************************************
	*** just for us moves
		qui areg everdissolve totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if evermarr == 1 & everabroad == 0, absorb(exper_br_year_fe)
		gen sample_everdissolve_us = e(sample)
		dis "summ everdissolve by nbr moves, us only"
		tabstat everdissolve if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_everdissolve female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		qui areg everkids totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat everdual age if everabroad == 0 & kids_ent == 0, absorb(exper_br_year_fe)
		gen sample_everkids_us = e(sample)
		dis "summ everkids by nbr moves, us only"
		tabstat everkids if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_everkids female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq

		qui areg nbr_kids totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat everdual age if everabroad == 0 & kids_ent == 0, absorb(exper_br_year_fe)
		gen sample_nbr_kids_us = e(sample)
		dis "summ everkids by nbr moves, us only"
		tabstat nbr_kids if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_nbr_kids female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		
		qui areg age_marr totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if evermarr == 1 & nm_ent == 1 & everabroad == 0, absorb(exper_br_year_fe)
		gen sample_age_marr_us = e(sample)
		dis "summ age_marr by nbr moves, us only"
		tabstat age_marr if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_age_marr female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat

		qui areg evermarr totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq if nm_ent == 1 & everabroad == 0, absorb(exper_br_year_fe)
		gen sample_evermarr_us = e(sample)
		gen sample_marr_nm_ent_us = e(sample)
		dis "summ evermarr by nbr moves, us only"
		tabstat evermarr if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_evermarr female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		gen marr_nm_ent = married if nm_ent == 1 
		local demos_marr_nm_ent female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		**** saving this sample to use for the T7 regressions with five obs per person
		preserve
		keep if sample_evermarr_us == 1 
		save $datadir/evermarr_us_sample, replace
		restore
		
		
		qui areg married totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq if everabroad == 0, absorb(exper_br_year_fe)
		gen sample_married_us = e(sample)
		dis "summ married by nbr moves, us only"
		tabstat married if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_married female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		qui areg re_enlist totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq if everabroad == 0, absorb(exper_br_year_fe)		
		gen sample_re_enlist_us = e(sample)
		dis "summ re_enlist by nbr moves, us only"
		tabstat re_enlist if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)		
		local demos_re_enlist female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
	*** including abroad moves
	
		qui areg everdissolve totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if evermarr == 1 & ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_everdissolve_all = e(sample)
		dis "summ everdissolve by nbr moves, abroad included"
		tabstat everdissolve if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		
		qui areg everkids totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat  age if kids_ent == 0 & ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_everkids_all = e(sample)
		dis "summ everkids by nbr moves, abroad included"
		tabstat everkids if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)

		qui areg nbr_kids totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat  age if kids_ent == 0 & ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_nbr_kids_all = e(sample)
		dis "summ nbr_kids by nbr moves, abroad included"
		tabstat nbr_kids if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		
		qui areg age_marr totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if evermarr == 1 & nm_ent == 1 & ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_age_marr_all = e(sample)
		dis "summ age_marr by nbr moves, abroad included"
		tabstat age_marr if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)

		qui areg evermarr totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if nm_ent == 1 & ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_evermarr_all = e(sample)
		dis "summ evermarr by nbr moves, abroad included"
		tabstat evermarr if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)

		qui areg marr_nm_ent totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq if nm_ent == 1 & ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_marr_nm_ent_all = e(sample)
		dis "summ married if not married when enter by nbr moves, abroad included"
		tabstat marr_nm_ent if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
					
		qui areg married totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)
		gen sample_married_all = e(sample)
		dis "summ married by nbr moves, abroad included"
		tabstat married if e(sample) == 1, by(totmoves_not)		c(stats) stats(mean n)
		
		qui areg re_enlist totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if ever_abroad_notGM_GE_IT == 0, absorb(exper_br_year_fe)		
		gen sample_re_enlist_all = e(sample)
		dis "summ re_enlist by nbr moves, abroad included"
		tabstat re_enlist if e(sample) == 1, by(totmoves_not)	c(stats) stats(mean n)	
		

	gen two_move_if_one = 1 if two_move == 1
	replace two_move_if_one = 0 if one_move == 1

	gen time_since_move_2 = time_since_move if two_move == 1
	


*** How many moves do people have?
foreach var in everdissolve everkids age_marr evermarr married re_enlist{
	dis "`var'"
	*tab totmoves_not if sample_`var'_us == 1

	*tab totmoves_not_w_abroad if sample_`var'_all == 1
}

*** who has kids but is never married

	summ everkids if evermarr == 0
	
	count if everkids == 1 & evermarr == 0
	count

*** stationed in home division interacted with total divisions
gen hom_div_tot = ever_hom_div * totmoves_not

save $datadir/jhr_samples_created, replace


***********************************************************************
***** RUNNING ALL OF THE REGRESSIONS BASED ON THE SAMPLES CREATED ABOVE
***********************************************************************



		
