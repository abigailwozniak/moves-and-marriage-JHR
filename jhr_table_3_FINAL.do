*** creates Table 2 & Table B1 
*** output: table_3.xls / log_table_3.txt

clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/log_table_3.txt, text replace 
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
		
***********************************************************************
**** TABLE 3 **********************************************************
**** Randomization Tests **********************************************
***********************************************************************

foreach var in totmoves_not {
    foreach sample in /*everkids evermarr married */ re_enlist  {

	areg `var' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/table_3.xls, replace label ctitle ("all, `sample'") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' if sample_`sample'_us == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq
	local f = r(p)
	outreg2  using $outsheet/table_3.xls, label ctitle ("demos, `sample'") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')
	
	areg `var' if sample_`sample'_us == 1 & male == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/table_3.xls, label ctitle ("all, `sample', male") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' if sample_`sample'_us == 1 & male == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq 
	local f = r(p)
	outreg2  using $outsheet/table_3.xls, label ctitle ("demos, `sample', male") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')

**** pre 9/11 entrance	

	areg `var' if sample_`sample'_us == 1 & pre2002 == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/table_3.xls, label ctitle ("all, `sample', <= 2001") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' if sample_`sample'_us == 1 & pre2002 == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq 
	local f = r(p)
	outreg2  using $outsheet/table_3.xls, label ctitle ("demos, `sample', <= 2001") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')
	
	**** term 6

	areg `var' if sample_`sample'_us == 1 & term6 == 1, robust absorb(exper_br_year_sex_fe)
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	outreg2  using $outsheet/table_3.xls, label ctitle ("term6") title("`var' `sample'") dec(3) addtex(Mean, `mean') keep(`demos')

	areg `var' `demos_`sample'2' if sample_`sample'_us == 1 & term6 == 1, robust absorb(exper_br_year_sex_fe)
	
	qui summ `var' if e(sample) == 1
	local mean = r(mean)
	dis "test `var' all, sample = `sample'"
	test ged hsd asc_smc college_pl afqsc black hispanic other_race age age_sq 
	local f = r(p)
	outreg2  using $outsheet/table_3.xls, label ctitle ("term6") title("`var'") dec(3) addtex(Mean, `mean', F-Test p-value, `f') keep(`demos')	
}
}

