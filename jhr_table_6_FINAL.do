*** creates Table 6, Columns 1, 2, 4, 5 
*** output: table_6_panel_a.xls / table_6_panel_b.xls / table_6_panel_c.xls / table_6_panel_d.xls / table_6_panel_e.xls
*** log: table_6.txt


clear all 
set more off
set matsize 1000
capture log close
set debug off

local date = "03172020"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/table_6.txt, text replace 
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
		
******
*** Table 6
******
**** Table 6, Panel A
foreach var in evermarr {
	foreach var2 in totmoves_not {
			foreach cond in female  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_a.xls, replace label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}
			foreach cond in post2001  {

			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_a.xls, label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')

			}	
	}
	
}
*** Table 6, Panel B 
foreach var in age_marr {
	foreach var2 in totmoves_not {
			foreach cond in female  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_b.xls, replace label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}
			foreach cond in  post2001 m_to_m_l6 m_to_m_g6 {

			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_b.xls, label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')

			}	
	}
	
}
*** Table 6, Panel C 
foreach var in married {
	foreach var2 in totmoves_not {
			foreach cond in female  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_c.xls, replace label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}
			foreach cond in  post2001 m_to_m_l6 m_to_m_g6 {

			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_c.xls, label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')

			}	
	}
	
}
*** Table 6, Panel D
foreach var in everkids {
	foreach var2 in totmoves_not {
			foreach cond in female  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_d.xls, replace label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}
			foreach cond in  post2001 m_to_m_l6 m_to_m_g6 {

			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_d.xls, label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')

			}	
	}
	
}
*** Table 6, Panel E 
foreach var in everdissolve {
	foreach var2 in totmoves_not {
			foreach cond in female  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_e.xls, replace label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}
			foreach cond in  post2001 m_to_m_l6 m_to_m_g6 {

			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_panel_e.xls, label ctitle ("`cond'") title("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2')

			}	
	}
	
}
