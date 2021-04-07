*** This do file creates the results for Table 6 Column 3 (end of first term results)
** output: table_6_col3.xls

clear all
set more off

set matsize 1000
capture log close
set logtype text
set debug off


local date = "03222021"

local first_term = 1

if `first_term' {
local gr first
}

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/jhr_end_first_term.txt, replace 
	global outsheet XXX/jhr_output


if `first_term' {
	use $datadir/jhr_sample_table6, clear
	local yos maxtime
	local group first_term
}


** dropping variables we don't need

	drop latitude longitude geoloc arloc_old region_sp division_sp locna geona tlac lng_nm ugrid point educ_gr curr_time_ 

compress

drop _merge

*** merging in the county data on ammenities
gen county_fips = countyfips
destring county_fips, replace
merge m:1 county_fips using $datadir/county_natamen.dta

ren _merge merge_ammen

drop metaread
ren metaread_old metaread

replace metaread = 8840 if state == "DC"

merge m:1 metaread year using $datadir/median_2br_rent_allyrs
ren _merge merge_2br

drop statefip

	gen statefip = .

	replace statefip = 1 if state == "AL"
	replace statefip = 2 if state == "AK"
	replace statefip = 4 if state == "AZ"
	replace statefip = 5 if state == "AR"
	replace statefip = 6 if state == "CA"
	replace statefip = 8 if state == "CO"
	replace statefip = 9 if state == "CT"
	replace statefip = 10 if state == "DE"
	replace statefip = 12 if state == "FL"
	replace statefip = 13 if state == "GA"
	replace statefip = 15 if state == "HI"
	replace statefip = 16 if state == "ID"
	replace statefip = 17 if state == "IL"
	replace statefip = 18 if state == "IN"
	replace statefip = 19 if state == "IA"
	replace statefip = 20 if state == "KS"
	replace statefip = 21 if state == "KY"
	replace statefip = 22 if state == "LA"
	replace statefip = 23 if state == "ME"
	replace statefip = 24 if state == "MD"
	replace statefip = 25 if state == "MA"
	replace statefip = 26 if state == "MI"
	replace statefip = 27 if state == "MN"
	replace statefip = 28 if state == "MS"
	replace statefip = 29 if state == "MO"
	replace statefip = 30 if state == "MT"
	replace statefip = 31 if state == "NE"
	replace statefip = 32 if state == "NV"
	replace statefip = 33 if state == "NH"
	replace statefip = 34 if state == "NJ"
	replace statefip = 35 if state == "NM"
	replace statefip = 36 if state == "NY"
	replace statefip = 37 if state == "NC"
	replace statefip = 38 if state == "ND"
	replace statefip = 39 if state == "OH"
	replace statefip = 40 if state == "OK"
	replace statefip = 41 if state == "OR"
	replace statefip = 42 if state == "PA"
	replace statefip = 44 if state == "RI"
	replace statefip = 45 if state == "SC"
	replace statefip = 46 if state == "SD"
	replace statefip = 47 if state == "TN"
	replace statefip = 48 if state == "TX"
	replace statefip = 49 if state == "UT"
	replace statefip = 50 if state == "VT"
	replace statefip = 51 if state == "VA"
	replace statefip = 53 if state == "WA"
	replace statefip = 54 if state == "WV"
	replace statefip = 55 if state == "WI"
	replace statefip = 56 if state == "WY"

*ren state_fip statefip
	merge m:1 statefip year using $datadir/median_2br_rent_state_allyrs_2
	ren _merge merge_2br_state

	replace md_rrentgrsi = md_rrentgrsi_state if md_rrentgrsi == . & merge_2br_state == 3

*** merge in share employment data using msa
	drop shcon shman shgov shmil 
	
	merge m:1 msa year using $datadir/BEA_msa, keepusing(shcon shman shgov shmil shsvc)
	foreach var in shcon shman shgov shmil shsvc {
	ren `var' `var'msa
	}
	tab _merge
	drop if _merge == 2
	ren _merge merge_msa2
	sort state_fips year
	merge m:1 state_fips year using $datadir/BEA_state, keepusing(shcon shman shgov shmil shsvc)
	tab _merge

	foreach var in shcon shman shgov shmil shsvc {
	ren `var' `var'state
	}
	drop if _merge == 2
	ren _merge merge_state_year2
	
	foreach var in shcon shman shgov shmil shsvc {
	gen `var' = `var'msa if merge_msa2 == 3
	replace `var' = `var'state if merge_state_year2 == 3 & (merge_msa2 ~= 3 | msa == . | `var'msa == .)
	}

*** creating the first arloc for someone - for clustering
	sort id training filedt_s
	bys id training: gen first = _n
	replace first = 0 if first ~= 1

	egen arlocnum = group(arloc)
	gen tempx = arlocnum if first == 1 & training == 0
	bys id: egen first_arlocnum = max(tempx) 
	drop tempx

**** first_term variable
	sort id filedt_s
	by id: gen numterm = _n
	gen tempterm6 = real(terms) if numterm == 1
	
	bys id: egen term_first = max(tempterm6)
	
	drop tempterm6

	gen tempterm6 = terms == "6" & numterm == 1
	
	bys id: egen term6 = max(tempterm6)

forvalues x=3/4 {
	gen tempterm`x' = terms == "`x'" & numterm == 1
	
	bys id: egen term`x' = max(tempterm`x')
	}
forvalues x=5/5 {
	gen tempterm`x' = terms == "`x'" & numterm == 1
	
	bys id: egen terms`x' = max(tempterm`x')
	}

	
*** creating variable for initial rank
	bys id: egen mind = min(filedt_s)
	gen temprank = real(substr(grade, 3, 1))
	gen initial_rank_temp = temprank if filedt_s == mind
	bys id: egen initial_rank = max(initial_rank_temp)

	
*** creating variable for initial year
	gen initial_year = year(mind)
	
*** are people in divisions and bcts?
	gen bct = div == 1 | bdereg == 1

*** married when enter	
	gen temp3 = married == 1 & firstobs == 1
	bys id: egen m_ent = max(temp3)
	drop temp3
	
*** kids when enter
	gen temp3 = kids == 1 & firstobs == 1
	bys id: egen kids_ent = max(temp3)
	drop temp3
	
*** married with less than a year in the Army

	gen less_yr = (filedt_s - startdate <= 365) & filedt_s > startdate
	gen temp5 = less_yr == 1 & marst == "M" & m_ent == 0
	bys id: egen mar_lyr = max(temp5)
	drop temp5

*** age when enter
	gen temp3 = age if firstobs == 1
	bys id: egen age_when_enter = max(temp3)
	drop temp3

	ren _merge merge_old1

** figuring out age when first get married - merging in data from age_marr.do.  also creates variable for first time not married and first time with kids.

	/*age_marr is a filedt_s*/
	gen tempage = age_marr - birthmo
	gen date_marr = age_marr
	gen tempage2 = tempage/365.25
	replace tempage2 = . if tempage2 < 17 | tempage2 > 55
	drop age_marr tempage
	ren tempage2 age_marr
	
*** people who were ever abroad
	bys id: egen everabroad = max(abroad)
		
	*** first move
	gen date_move = filedt_s if move_not == 1
	bys id: egen min_date_move = min(date_move)
		
*** dual spouse
	gen dualspouse = spouse_id ~= .
	replace married = 1 if dualspouse == 1
	dis "summarizing dualspouse"
	summ dualspouse
	
*** deployment variables
	gen temp = sum_combat >0 & sum_combat ~= .  
	bys id: egen everdepl = max(temp)

*** date of first non-training move

	bys id move_not: egen temp_move = min(filedt_s)
	replace temp_move = . if move_not == 0
	bys id: egen first_move_dt_s = min(temp_move)

*** creating year, job, rank interaction variables
	bys initial_rank pmos initial_year: gen exper_br_year_flag=1 if _n==1
	replace exper_br_year_flag=0 if exper_br_year_flag==.
	gen exper_br_year_fe=sum(exper_br_year_flag)
	drop exper_br_year_flag
	
*** creating year, job, rank, gender interaction variables
	bys initial_rank pmos initial_year sex: gen exper_br_year_flag_s=1 if _n==1
	replace exper_br_year_flag_s=0 if exper_br_year_flag_s==.
	gen exper_br_year_sex_fe=sum(exper_br_year_flag_s)
	drop exper_br_year_flag_s

*** for first timers, the CRA assumptions include term length
	if `first_term' {
	drop exper_br_year_fe
	bys initial_rank pmos initial_year term_first: gen exper_br_year_flag=1 if _n==1
	replace exper_br_year_flag=0 if exper_br_year_flag==.
	gen exper_br_year_fe=sum(exper_br_year_flag)
	drop exper_br_year_flag
	}
	
*****************************************************
** Creating a number of right hand side variables
*****************************************************

** move_yr - did you move in a particular year? 
	bys id: egen totmoves  = total(move)
*** non-training moves
	bys id: egen totmoves_not = total(move_not)
	replace move_not = 0 if last_not == 1 & distance_move_not == 0
	replace distance_move_not = 0 if move_not ~= 1
	bys id: egen tot_dist_not = total(distance_move_not)
	replace tot_dist_not = . if everabroad == 1


*** changing the totmoves to only include non-abroad moves --- just for Germany and Italy where it is most likely to be accomanied.  

	gen abroad_move = 0 if move_not == 1 & conus == 1
	sort id move_not
	replace abroad_move = 1 if move_not == 1 & conus == 0 & (substr(arloc, 1, 2) == "GE" | substr(arloc, 1, 2) == "GM" | substr(arloc, 1, 2) == "IT") & conus[_n-1] == 1 & id == id[_n-1]
	replace abroad_move = 1 if move_not == 1 & conus == 1 & (substr(arloc[_n-1], 1, 2) == "GE" | substr(arloc[_n-1], 1, 2) == "GM" | substr(arloc[_n-1], 1, 2) == "IT") & id == id[_n-1]
	
	gen abroad_move_c_o = 0 if move_not == 1
	replace abroad_move_c_o = 1 if move_not == 1 & conus == 0 & (substr(arloc, 1, 2) == "GE" | substr(arloc, 1, 2) == "GM" | substr(arloc, 1, 2) == "IT") & conus[_n-1] == 1 & id == id[_n-1]
	
	gen abroad_move_o_c = 0 if move_not == 1
	replace abroad_move_o_c = 1 if move_not == 1 & conus == 1 & (substr(arloc[_n-1], 1, 2) == "GE" | substr(arloc[_n-1], 1, 2) == "GM" | substr(arloc[_n-1], 1, 2) == "IT") & id == id[_n-1]
	
	gen abroad_to_abroad_move = 0 if move_not == 1
	replace abroad_to_abroad_move = 1 if move_not == 1 & (substr(arloc, 1, 2) == "GE" | substr(arloc, 1, 2) == "GM" | substr(arloc, 1, 2) == "IT")  & (substr(arloc[_n-1], 1, 2) == "GE" | substr(arloc[_n-1], 1, 2) == "GM" | substr(arloc[_n-1], 1, 2) == "IT") & id == id[_n-1]
	
	gen move_not_us = move_not
	replace move_not_us = 0 if abroad_move == 1 | (conus == 0 & move_not == 1)	
	bys id: egen totmoves_not_us = total(move_not_us)	
	ren totmoves_not totmoves_not_w_abroad
	bys id: egen abroad_moves_not = total(abroad_move)
	gen totmoves_not = totmoves_not_us
	
	** could be domestic moves within us or within italy/germany
	label var totmoves_not "Domestic Moves"

** total time spent in training
	sort id filedt_s
	gen time_in_training = filedt_s - filedt_s[_n-1] if training == 1 & id == id[_n-1] & filedt_s > filedt_s[_n-1]
	bys id: egen min_train = min(filedt_s)
	gen mintrain = (filedt_s == min_train & training == 1)
	replace time_in_training = filedt_s - startdate if mintrain == 1
	bys id: egen tot_time_t = total(time_in_training)
	drop min_train mintrain

bys id: egen lastdate = max(filedt_s)

	/* creating a file to check some of the data */
	egen newid = group(id)
	sort newid filedt_s

*** number of kids
	gen nbr_kids = nrdep - 1 if married == 1 & dualspouse ~= 1
	replace nbr_kids = nrdep if married == 0 | dualspouse == 1	
	replace nbr_kids = nrdep if married == 0 & dualspouse == .
	
	bys id: egen temp_kids = max(nbr_kids)
	drop nbr_kids
	ren temp_kids nbr_kids

******
** keeping one observation
******
	bys id: egen max = max(filedt_s)
	keep if filedt_s == max


** some people are missing their marriage indicator for the last observation.  replacing with deers data in that case
	replace married = 1 if married == . & spouse_deers == 1
	replace married = 0 if married == . & spouse_deers == 0
	
*** moves per year variables
	gen tot_mov_nt_yr = totmoves_not / `yos'
	gen tot_moves_yr = totmoves / `yos'

	set emptycells drop, permanently

	gen male = sex == "M" if sex ~= ""

*** creating some sub populations
	gen all = 1
	gen nm_ent = 1 if m_ent == 0
	replace nm_ent = 0 if m_ent == 1

	gen term5 = terms == "5"
	
	gen max_three = totmoves_not_w_abroad <= 3
	
	gen neverdepl = everdepl == 0
	gen infantry = branch == "IN"

***********************************************************************
***** creating different samples to run for each set of outcomes
***********************************************************************
	*** just for us moves
		qui areg everdissolve totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if evermarr == 1 & everabroad == 0, absorb(exper_br_year_fe)
		gen sample_everdissolve_us = e(sample)
		dis "summ everdissolve by nbr moves, us only"
		tabstat everdissolve if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_everdissolve female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		qui areg everkids totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if everabroad == 0 & kids_ent == 0, absorb(exper_br_year_fe)
		gen sample_everkids_us = e(sample)
		dis "summ everkids by nbr moves, us only"
		tabstat everkids if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_everkids female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq

		qui areg nbr_kids totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age if everabroad == 0 & kids_ent == 0, absorb(exper_br_year_fe)
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
		

		
**** taking out combat
		local demos_everdissolve2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_everkids2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_nbr_kids2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_age_marr2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_evermarr2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_married2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		local demos_marr_nm_ent2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq		
		local demos_re_enlist2 female ged hsd asc_smc college_pl afqsc black hispanic other_race  age age_sq
		
eststo clear
***********************************************************************
**** TABLE 2 **********************************************************
**** Summary Statistics ***********************************************
***********************************************************************
	
	gen pre2002 = mind < td(01oct2001) if initial_year ~= .
	gen post2001 = mind >= td(01oct2001) if initial_year ~= .
	
	count if married == .

*** How many moves do people have?
foreach var in everdissolve everkids age_marr evermarr married re_enlist{
	dis "`var'"
	tab totmoves_not if sample_`var'_us == 1

*	tab totmoves_not_w_abroad if sample_`var'_all == 1
}

*** who has kids but is never married

	summ everkids if evermarr == 0
	
	count if everkids == 1 & evermarr == 0
	count

***********************************************************************
***** RUNNING ALL OF THE REGRESSIONS BASED ON THE SAMPLES CREATED ABOVE
***********************************************************************


******
*** Table 6 - Column 3
******
**** Table 6, Panel A

foreach var in evermarr {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_col3.xls, replace label ctitle("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}

			}	
	}
	

*** Table 6, Panel B 
foreach var in age_marr {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_col3.xls,  label ctitle("`var'")  dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}


			}	
	}
	

*** Table 6, Panel C 
foreach var in married {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_col3.xls, label ctitle("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}


			}	
	}
	

*** Table 6, Panel D
foreach var in everkids {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_col3.xls, label ctitle("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}

	}
	
}
*** Table 6, Panel E 
foreach var in everdissolve {
	foreach var2 in totmoves_not {
			foreach cond in all  {
			areg `var' `var2' `demos_`var'' if `cond' == 1  & sample_`var'_us == 1, robust absorb(exper_br_year_sex_fe)
			qui summ `var' if e(sample) == 1, de
			local mean = r(mean)
			qui summ `var2' if e(sample) == 1, de
			local mean2 = r(mean)
			outreg2  using $outsheet/table_6_col3.xls, label ctitle("`var'") dec(3) addtex(Mean, `mean', Indep Mean, `mean2') keep(`var2') 
				
			}
	
	}
	
}

exit

