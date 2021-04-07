*** creates Appendix Tables C1 & C2
*** output: app_c1_evermarr.xls / app_c1_marr_nm_ent.xls / app_c1_married.xls
*** output: app_c2_evermarr.xls / app_c2_marr_nm_ent.xls / app_c2_married.xls

*** log: app_tables_c1_c2.txt


clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/app_tables_c1_c2.txt, text replace 
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

****** Clustering for the Appendix Tables 

*** creating arloc x start year indicators
	bys first_arlocnum initial_year: gen arloc_x_startyear_flag=1 if _n==1
	replace arloc_x_startyear_flag=0 if arloc_x_startyear_flag==.
	gen arloc_x_startyear =sum(arloc_x_startyear_flag)
	drop arloc_x_startyear_flag

	
***** clustering of the main results
foreach var in evermarr marr_nm_ent married {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			
*** cluster group 1: first post

*** App Table 1 Row 3
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe) cluster(first_arlocnum)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c1_`var'.xls, replace label ctitle ("`cond', cluster first arloc") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')
}	
*** cluster group 2: first post x year started

			foreach cond in all  {
*** App Table 1 Row 4
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe) cluster(arloc_x_startyear)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c1_`var'.xls, label ctitle ("`cond', cluster first arloc x year") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')
}
			
*** cluster group 3: job x rank x year

		foreach cond in all  {

*** App Table C1 Row 5; App Table C2 Col 1
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe) cluster(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c1_`var'.xls, label ctitle ("`cond', cluster jry") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')
			outreg2  using $outsheet/app_c2_`var'.xls, replace label ctitle ("`cond', cluster jry") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')
		}
		
		foreach cond2 in  male pre2002 term6 {

*** Appendix Table C2 Col. 2, 3, 4	
			areg `var' `var2' `demos_`var'' if `cond2' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe) cluster(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/app_c2_`var'.xls, label ctitle ("`cond2'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')

			}	
		
		}
		}