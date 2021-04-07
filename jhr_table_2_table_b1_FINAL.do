*** creates Table 2 & Table B1 (summary statistics)
*** output: table_2_table_b1.txt

clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/table_2_table_b1.txt, text replace 
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
		
***********************************************************************
**** TABLE 2 **********************************************************
**** Summary Statistics ***********************************************
***********************************************************************
	

		
	
*** replacing re-enlist to 10 equal to missing if could not have been in for 10 years.
	replace re_enlist_10 = . if initial_year > 2003
	gen everkids_nokids = everkids if kids_ent == 0
	gen evermarr_nm_ent = evermarr if nm_ent == 1
	gen age_marr_table = age_marr if evermarr == 1 & nm_ent == 1
	
	
	/* order of summary stats: female age black hispanic other_race afqsc ged hsd hsg asc_smc college_pl everdepl sum_combat first_term re_enlist_10 dualspouse everdual totmoves_not evermarr everkids_nokids everdissolve */
	
		foreach var in female black hispanic other_race ged hsd hsg asc_smc college_pl everdepl first_term re_enlist_10 dualspouse everdual evermarr_nm_ent marr_nm_ent married everkids_nokids everdissolve {
	foreach group in all male pre2002 term6 female {	    
		qui summ `var' if sample_re_enlist_us == 1 & `group' == 1, de
		
		scalar mean`var'`group' = round(r(mean), .01)
		scalar sd`var'`group' = round(r(sd), .01)
		
		}
	mat mat`var' = [mean`var'all, mean`var'male, mean`var'pre2002, mean`var'term6]
	mat mat2`var' = [mean`var'all, mean`var'male, mean`var'female]
		}
	
		foreach var in age afqsc sum_combat totmoves_not maxyos age_marr_table {
	foreach group in all male pre2002 term6 female {	    
		qui summ `var' if sample_re_enlist_us == 1 & `group' == 1, de
		
		scalar mean`var'`group' = round(r(mean), .01)
		scalar sd`var'`group' = round(r(sd), .01)
		
		}
	mat mat`var' = [mean`var'all, mean`var'male, mean`var'pre2002, mean`var'term6\sd`var'all, sd`var'male, sd`var'pre2002, sd`var'term6]
	mat mat2`var' = [mean`var'all, mean`var'male, mean`var'female\sd`var'all, sd`var'male, sd`var'female]

		}

		foreach group in all male pre2002 term6 female {
	qui summ female if sample_re_enlist_us == 1 & `group' == 1
	scalar n`group' = r(N)
		}
		
	mat table_2 = [matfemale\matage\matblack\mathispanic\matother_race\matafqsc\matged\mathsd\mathsg\matasc_smc\matcollege_pl\mateverdepl\matsum_combat\matfirst_term\matre_enlist_10\matmaxyos\matdualspouse\mateverdual\mattotmoves_not\matevermarr_nm_ent\matmarr_nm_ent\matmarried\matage_marr_table\mateverkids_nokids\mateverdissolve\nall, nmale, npre2002, nterm6]
	
	
	***********************************************************************
**** TABLE B1 *********************************************************
**** Summary Stats for All, Men, and Women ****************************
***********************************************************************
 
 	mat table_b1 = [mat2female\mat2age\mat2black\mat2hispanic\mat2other_race\mat2afqsc\mat2ged\mat2hsd\mat2hsg\mat2asc_smc\mat2college_pl\mat2everdepl\mat2sum_combat\mat2first_term\mat2re_enlist_10\mat2maxyos\mat2dualspouse\mat2everdual\mat2totmoves_not\mat2evermarr_nm_ent\mat2marr_nm_ent\mat2married\mat2age_marr_table\mat2everkids_nokids\mat2everdissolve\nall, nmale, nfemale]

	matrix list table_2
	
	matrix list table_b1