
*** creates Extra CRA Tables
*** output: extra_table_cra.xls / cra_with_marst_enter

*** log: extra_cra.txt


clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/extra_cra.txt, text replace 
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
*** Tables if requested
*********

foreach var in time_since_start  {
    
foreach sample in re_enlist  {
    
		areg `var' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/extra_table_cra.xls, replace label ctitle ("all, `var'")  dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq
	local f = r(p)
	outreg2  using $outsheet/extra_table_cra.xls, label ctitle ("all, `var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')

}
}


foreach var in two_move_if_one time_since_move_2 tot_worse_not tot_worse_epop tot_worse_amm tot_more_exp_rent tot_better_not tot_better_epop tot_better_amm tot_less_exp_rent {
    
foreach sample in re_enlist  {
    
		areg `var' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/extra_table_cra.xls, label ctitle ("all, `sample'") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq
	local f = r(p)
	outreg2  using $outsheet/extra_table_cra.xls, label ctitle ("all, `var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')

}
}

******* main CRA table with Marital Status when Enter

foreach var in totmoves_not { 
    foreach sample in re_enlist  {
    
		areg `var' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/cra_with_marst_enter.xls, replace label ctitle ("all") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' m_ent if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq
	local f = r(p)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("demos, all") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')

****  MEN
	
	areg `var' if sample_`sample'_us == 1 & male == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("male") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' m_ent if sample_`sample'_us == 1 & male == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq 
	local f = r(p)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("demos, male") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')

**** pre 9/11 entrance	

	areg `var' if sample_`sample'_us == 1 & pre2002 == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("<= 2001") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' m_ent if sample_`sample'_us == 1 & pre2002 == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq 
	local f = r(p)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("demos, <= 2001") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')



**** term 6

	areg `var' if sample_`sample'_us == 1 & term6 == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("term6") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' m_ent if sample_`sample'_us == 1 & term6 == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq 
	local f = r(p)
	outreg2  using $outsheet/cra_with_marst_enter.xls, label ctitle ("demos, term6") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')	
}
}

