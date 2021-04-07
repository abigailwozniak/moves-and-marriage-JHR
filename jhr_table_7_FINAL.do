*** creates Table 7 
*** output: table_7.xls
*** log: log_table_7.txt


clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/log_table_7.txt, text replace 
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
	
********
*** Table 7
********

gen tot_dist_sq = tot_dist_not^2			


foreach var in evermarr {
	foreach var2 in totmoves_not {
			foreach cond in all  {

			
*** + all controls for posting history and location characteristics
			areg `var' `var2' z2avg_cell_amm z2avg_cell2br avg_cellshare avg_epop z2avg_shcon z2avg_shman z2avg_shgov z2avg_shmil z2avg_shsvc longestmove ever_hom_d tot_dist_not tot_dist_sq `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			gen sample_hist_loc = e(sample)			
						
***** all condition on sample_hist_loc

*** Col. 1

			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1 & sample_hist_loc == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_7.xls, replace label ctitle ("`cond', hist_loc_sample") title("`var'") dec(3) addtex(Mean, `mean') keep(`var2' z2avg_cell_amm z2avg_cell2br avg_epop longestmove ever_hom_d tot_dist_not tot_dist_sq avg_cellshare)

*** Col. 2 + all controls for location characteristics
			areg `var' `var2' z2avg_cell_amm z2avg_cell2br avg_cellshare avg_epop z2avg_shcon z2avg_shman z2avg_shgov z2avg_shmil z2avg_shsvc `demos_`var'' if `cond' == 1  & sample_`var'_us == 1 & sample_hist_loc == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/table_7.xls,  label ctitle ("`cond', hist_loc_sample") title("`var'") dec(3) addtex(Mean, `mean') keep(`var2' z2avg_cell_amm z2avg_cell2br avg_epop z2avg_shcon z2avg_shman z2avg_shgov z2avg_shmil z2avg_shsvc longestmove ever_hom_d tot_dist_not tot_dist_sq avg_cellshare)
			
			
*** Col. 3 + all controls for posting history
			areg `var' `var2' longestmove ever_hom_d tot_dist_not tot_dist_sq `demos_`var'' if `cond' == 1  & sample_`var'_us == 1 & sample_hist_loc == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/table_7.xls,  label ctitle ("`cond', hist_loc_sample") title("`var'") dec(3) addtex(Mean, `mean') keep(`var2' z2avg_cell_amm z2avg_cell2br avg_epop longestmove ever_hom_d tot_dist_not tot_dist_sq avg_cellshare)

					
*** Col. 4 + all controls for posting history and location characteristics
			areg `var' `var2' z2avg_cell_amm z2avg_cell2br avg_cellshare avg_epop z2avg_shcon z2avg_shman z2avg_shgov z2avg_shmil z2avg_shsvc longestmove ever_hom_d tot_dist_not tot_dist_sq `demos_`var'' if `cond' == 1  & sample_`var'_us == 1 & sample_hist_loc == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			outreg2  using $outsheet/table_7.xls,  label ctitle ("`cond', hist_loc_sample") title("`var'") dec(3) addtex(Mean, `mean') keep(`var2' z2avg_cell_amm z2avg_cell2br avg_cellshare avg_epop z2avg_shcon z2avg_shman z2avg_shgov z2avg_shmil z2avg_shsvc longestmove ever_hom_d tot_dist_not tot_dist_sq avg_cellshare)
drop sample_hist_loc

}
}
}
