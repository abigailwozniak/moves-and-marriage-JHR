*** creates Appendix Tables C1 & C2
*** output: app_c4.xls

*** log: app_table_c4.txt


clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/app_table_c4, text replace 
	global outsheet XXX/jhr_output


use $datadir/jhr_samples_created



**** taking out combat
		local demos_everdissolve female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		local demos_everkids female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		local demos_nbr_kids female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		local demos_age_marr female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat
		local demos_evermarr female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		local demos_marr_nm_ent female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		local demos_married female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		local demos_re_enlist female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq

		
**** taking out combat
		local demos_everdissolve2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_everkids2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_nbr_kids2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_age_marr2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_evermarr2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_married2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_marr_nm_ent2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq		
		local demos_re_enlist2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq

	gen pre2002 = mind < td(01oct2001) if initial_year ~= .
	gen post2001 = mind >= td(01oct2001) if initial_year ~= .		
		
*********
** Appendix Table C4
*********

*** Col. 1 Main result

foreach var in evermarr {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			   
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c4.xls, replace label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 

*** Col. 2 any move
			areg `var' any_move `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/app_c4.xls,  label ctitle ("`cond', us") title("`var'") dec(3) addtex(Mean, `mean') keep(any_move)	
			
			
*** Col. 3 conditioning on 0 or 1 move
			areg `var' one_move  `demos_`var'' if `cond' == 1  & sample_`var'_us == 1 & zero_one_move == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/app_c4.xls, label ctitle ("max 1 move") title("`var'") dec(3) addtex(Mean, `mean', Sample) keep(one_move)			
			
*** Col. 4 conditioning on 3 or fewer moves			 
			areg `var' one_move two_move three_move `demos_`var'' if `cond' == 1  & sample_`var'_us == 1 & max_three == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/app_c4.xls,  label ctitle ("`cond'") title("max 3 moves") dec(3) addtex(Mean, `mean') keep(one_move two_move three_move)			
			

*** Col. 5 including abroad moves
			areg `var' totmoves_not_w_abroad `demos_`var'' if `cond' == 1  & sample_`var'_all == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ totmoves_not_w_abroad if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c4.xls,  label ctitle ("`cond'") title("`var'") dec(4) addtex(Mean, `mean') keep(totmoves_not_w_abroad)

			
*** Col 6. any move - international included
			areg `var' any_move_intl `demos_`var'' if `cond' == 1  & sample_`var'_all == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/app_c4.xls,  label ctitle ("`cond', abroad included") title("`var'") dec(3) addtex(Mean, `mean') keep(any_move_intl)				

*** Col. 7 - including abroad moves with max of 1 move
			areg `var' totmoves_not_w_abroad `demos_`var'' if `cond' == 1  & sample_`var'_all == 1 & zero_one_move == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ totmoves_not_w_abroad if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c4.xls,  label ctitle ("`cond' max 1 move") title("`var'") dec(4) addtex(Mean, `mean') keep(totmoves_not_w_abroad)			
					
			}
	}
}