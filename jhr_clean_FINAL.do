*** This do file cleans the data and creates datasets for the figures and tables 

clear all
set more off
set matsize 1000
capture log close
set logtype text
set debug off


local date = "03222020"

local to_5 = 1

foreach num in 5 {
if `to_`num'' {
local gr  to_`num'
}
}

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/cleaning_and_tables_`date'.txt, replace 
	global figdir XXX/figs_miles
	global outsheet XXX/jhr_output


foreach var in 5 {
if `to_`var'' {
	use $datadir/initial_data
	local yos = `var'
	local group to_`var'
}
}


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

****** location variables

*** creating weighted average epops

	** time under an epop if not in training
	gen epoptime = filedt_s[_n+1] - filedt_s if training == 0 & id == id[_n+1] & training[_n+1] == 0
	gen epop_x_time = epop * epoptime if training == 0
	sort id filedt_s
	by id: gen sumtime = sum(epoptime) if epop ~= .
	
	sort id filedt_s
	by id: gen sum_epop_x_time = sum(epop_x_time)
	gen avg_epop = sum_epop_x_time/sumtime
	replace avg_epop = . if filedt_s > td(31dec2010)
	replace avg_epop = . if sum_epop_x_time == 0

*** creating weighted average cell shares using the same method as epop
	
	sort id training filedt_s
	
	gen celltime = filedt_s[_n+1] - filedt_s if training == 0 & id == id[_n+1] & training[_n+1] == 0
	gen cell_x_time = cellsharei * celltime if training == 0
	sort id filedt_s
	by id: gen sumtime2 = sum(celltime) if cellsharei ~= .

	sort id filedt_s
	by id: gen sum_cell_x_time = sum(cell_x_time)
	gen avg_cellshare = sum_cell_x_time/sumtime2
	replace avg_cellshare = . if sum_cell_x_time == 0
	
*** creating weighted average cell poi using the same method as epop
	
	drop celltime cell_x_time sumtime2 sum_cell_x_time
	sort id training filedt_s
	
	gen celltime = filedt_s[_n+1] - filedt_s if training == 0 & id == id[_n+1] & training[_n+1] == 0
	gen cell_x_time = cellpopi * celltime if training == 0 & merge_marriage_market_msa == 3
	sort id filedt_s
	by id: gen sumtime2 = sum(celltime) if cellpopi ~= .

	sort id filedt_s
	by id: gen sum_cell_x_time = sum(cell_x_time)
	gen avg_cellpop = sum_cell_x_time/sumtime2
	replace avg_cellpop = . if sum_cell_x_time == 0
	
	gen not_in_msa = merge_marriage_market_msa ~= 3 & training == 0
	bys id: egen ever_not_in_msa = max(not_in_msa)
	
	replace avg_cellpop = . if ever_not_in_msa == 1
	
*** creating weighted average 2br rent price
	
	drop celltime cell_x_time sumtime2 sum_cell_x_time
	sort id training filedt_s
	
	gen celltime = filedt_s[_n+1] - filedt_s if training == 0 & id == id[_n+1] & training[_n+1] == 0
	gen cell_x_time = md_rrentgrsi * celltime if training == 0 & md_rrentgrsi ~= .
	sort id filedt_s
	by id: gen sumtime2 = sum(celltime) if md_rrentgrsi ~= .

	sort id filedt_s
	by id: gen sum_cell_x_time = sum(cell_x_time)
	gen avg_cell2br = sum_cell_x_time/sumtime2
	replace avg_cell2br = . if sum_cell_x_time == 0
	
	gen not_in_2br = md_rrentgrsi == . & training == 0
	bys id: egen ever_not_in_2br = max(not_in_2br)
	
	replace avg_cell2br = . if ever_not_in_2br == 1	

*** creating weighted average ammenities
	
	drop celltime cell_x_time sumtime2 sum_cell_x_time
	sort id training filedt_s
	
	gen celltime = filedt_s[_n+1] - filedt_s if training == 0 & id == id[_n+1] & training[_n+1] == 0
	gen cell_x_time = amenityscale * celltime if training == 0 & amenityscale ~= .
	sort id filedt_s
	by id: gen sumtime2 = sum(celltime) if amenityscale ~= .

	sort id filedt_s
	by id: gen sum_cell_x_time = sum(cell_x_time)
	gen avg_cell_amm = sum_cell_x_time/sumtime2
	replace avg_cell_amm = . if sum_cell_x_time == 0
	
	gen not_in_amm = amenityscale == . & training == 0
	bys id: egen ever_not_in_amm = max(not_in_amm)
	
	replace avg_cell_amm = . if ever_not_in_amm == 1
	
*** shcon shman shgov shmil shsvc
foreach var in shcon shman shgov shmil shsvc {
	drop celltime cell_x_time sumtime2 sum_cell_x_time
	sort id training filedt_s
	
	gen celltime = filedt_s[_n+1] - filedt_s if training == 0 & id == id[_n+1] & training[_n+1] == 0
	gen cell_x_time = `var' * celltime if training == 0 & `var' ~= .
	sort id filedt_s
	by id: gen sumtime2 = sum(celltime) if `var' ~= .

	sort id filedt_s
	by id: gen sum_cell_x_time = sum(cell_x_time)
	gen avg_`var' = sum_cell_x_time/sumtime2
	replace avg_`var' = . if sum_cell_x_time == 0
	
	gen not_in_`var' = `var' == . & training == 0
	bys id: egen ever_not_in_`var' = max(not_in_`var')
	replace avg_`var' = . if filedt_s > td(31dec2010)

	replace avg_`var' = . if ever_not_in_`var' == 1
}



*** going to create worse move if moving to a location with more than 1 standard deviation from the previous.  

** first need to create standard deviation of all possible locations

foreach var in epop amenityrank md_rrentgrsi cellsharei shcon shman shgov shmil shsvc {
	egen tempz2_`var' = std(`var')
	}
	
*** moving to a worse location in terms of cell size
	sort id training filedt_s
	gen worse_location = tempz2_cellsharei < (tempz2_cellsharei[_n-1]-1)  if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & cellsharei[_n-1] ~= . & cellsharei ~= . & move_not == 1
	gen better_location = (tempz2_cellsharei[_n-1]+1) < tempz2_cellsharei  if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & cellsharei ~= . & cellsharei[_n-1] ~= . & move_not == 1
	
	gen worse_epop = tempz2_epop < (tempz2_epop[_n-1]-1) if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & epop[_n-1] ~= . & epop ~= . & move_not == 1
	gen better_epop = (tempz2_epop[_n-1]+1) < (tempz2_epop)  if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & epop[_n-1] ~= . & epop ~= . & move_not == 1
	
	
	gen worse_amm = tempz2_amenityrank < (tempz2_amenityrank[_n-1]-1)  if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & amenityrank[_n-1] ~= . & amenityrank ~= . & move_not == 1
	gen better_amm = (tempz2_amenityrank[_n-1]+1) < (tempz2_amenityrank) if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & amenityrank[_n-1] ~= . & amenityrank ~= . & move_not == 1

foreach var in shcon shman shgov shmil shsvc {
	gen worse_`var' = tempz2_`var' < (tempz2_`var'[_n-1]-1)  if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & `var'[_n-1] ~= . & `var' ~= . & move_not == 1
	gen better_`var' = (tempz2_`var'[_n-1]+1) < (tempz2_`var') if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & `var'[_n-1] ~= . & `var' ~= . & move_not == 1
	}
	
	gen more_exp_rent = tempz2_md_rrentgrsi > (tempz2_md_rrentgrsi[_n-1]+1) if move_not == 1 & training == 0 & training[_n-1] == 0 & id == id[_n-1]  & abroad ~= 1 & md_rrentgrsi[_n-1] ~= . & md_rrentgrsi ~= . 
	gen less_exp_rent = (tempz2_md_rrentgrsi[_n-1]+1) > (tempz2_md_rrentgrsi) if move_not == 1 & training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & md_rrentgrsi[_n-1] ~= . & md_rrentgrsi ~= . 

foreach var in tempz2_cellsharei tempz2_epop tempz2_amenityrank tempz2_md_rrentgrsi tempz2_shcon tempz2_shman tempz2_shgov tempz2_shmil tempz2_shsvc {
	gen ch_`var' = `var' - `var'[_n-1] if training == 0 & training[_n-1] == 0 & id == id[_n-1] & abroad ~= 1 & `var'[_n-1] ~= . & `var' ~= . & move_not == 1
}	
	
	
*** creating variable for initial rank
	bys id: egen mind = min(filedt_s)
	gen temprank = real(substr(grade, 3, 1))
	gen initial_rank_temp = temprank if filedt_s == mind
	bys id: egen initial_rank = max(initial_rank_temp)

	
*** variable for large posts
	bys id arloc year: gen num_id_arloc_yr = _n
	replace num_id_arloc_yr = . if num_id_arloc_yr ~= 1
	bys arloc year: egen tot_arloc_year = total(num_id_arloc_yr)
	bys arloc year: gen num_arloc_yr = _n
	summ tot_arloc_year if num_arloc_yr == 1, de

	gen large_post = tot_arloc_year >= r(p90)
	
	sort id training filedt_s
	gen large_to_small = large_post == 0 & move_not == 1 & training == 0 & large_post[_n-1] == 1 & id == id[_n-1]
	
	
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

** timing between marriage and moves
	gen marr_filedt_s = date_marr - filedt_s if move_not == 1
	gen marr2 = abs(marr_filedt_s)
	bys id: egen marr3 = min(abs(marr_filedt_s))
	gen marr4 = marr_filedt_s if marr2 == marr3 
	by id: egen marr5 = min(marr4)
	by id: gen marr_num = _n
*	histogram marr5 if marr_num == 1, title("Time Between Marriage and Move") frac xtitle("Marriage Date - Move Date")
*	graph export $figdir/married_move_`gr'.ps, replace
*	histogram marr5 if marr_num == 1 & female == 0, title("Time Since Marriage and Move -- MEN") frac
*	graph export $figdir/married_move_`gr'_m.ps, replace
*	histogram marr5 if marr_num == 1 & female == 1, title("Time Since Marriage and Move -- WOMEN") frac
*	graph export $figdir/married_move_`gr'_f.ps, replace
	drop marr_filedt_s marr2 marr3 marr4 marr_num
	ren marr5 days_to_move
	gen months_to_move = floor((days_to_move/30))


	gen shot_gun = abs(months_to_move) <= 3
	replace shot_gun = . if months_to_move == .
	
	gen m_to_m_l6 = abs(months_to_move) <= 6
	replace m_to_m_l6 = . if m_ent == 1 | evermarr == 0 | months_to_move == .
	
	gen m_to_m_g6 = abs(months_to_move) > 6
	replace m_to_m_g6 = . if  m_ent == 1 | evermarr == 0 | months_to_move == .
	
*** people who were ever abroad
	bys id: egen everabroad = max(abroad)
	
	
	*** first move
	gen date_move = filedt_s if move_not == 1
	bys id: egen min_date_move = min(date_move)
	
*** same as above, but conditioning on those who were not married 6 months before a move and did not move again within 24 months. - just for FIRST moves

*** creating a histogram which shows when people's first moves are.  

gen time_since_start_30 = floor((min_date_move - startdate)/30)
*histogram time_since_start_30 if filedt_s == min_date_move

*graph export $figdir/time_since_start_30.pdf, replace

preserve 
keep time_since_start_30 filedt_s min_date_move term3
save $datadir/app_fig_1, replace
restore

/*
*** Data for figure is in jhr_app_fig_1.do
** Appendix C Figure 1

histogram time_since_start_30 if filedt_s == min_date_move & term3 == 1

graph export $figdir/time_since_start_30_term3.pdf, replace
tab time_since_start_30 if filedt_s == min_date_move & term3 == 1
*/

***** creating yearly variables for new tables eight

gen yr_1 = filedt_s - startdate < 365 if startdate ~= . & filedt_s ~= .
gen yr_2 = filedt_s - startdate < 730 & yr_1 == 0 if startdate ~= . & filedt_s ~= .
gen yr_3 = filedt_s - startdate < 1095 & yr_1 == 0 & yr_2 == 0 if startdate ~= . & filedt_s ~= .
gen yr_4 = filedt_s - startdate < 1460 & yr_1 == 0 & yr_2 == 0 & yr_3 == 0 if startdate ~= . & filedt_s ~= .
gen yr_5 = filedt_s - startdate < 1825 & yr_1 == 0 & yr_2 == 0 & yr_3 == 0 & yr_4 == 0 if startdate ~= . & filedt_s ~= .


bys id: egen lastdate = max(filedt_s)

egen arloc_unique = group(arloc)
gen temp_first = arloc_unique if first == 1
gen temp_last = arloc_unique if filedt_s == lastdate


bys id: egen first_arloc = max(temp_first)
bys id: egen last_arloc = max(temp_last)

drop temp_first temp_last lastdate

forvalues x=1/5 {
bys id yr_`x': egen married_yr_`x' = max(married) if yr_`x' == 1
bys id: egen ev_marr_yr_`x' = max(married_yr_`x')
drop married_yr_`x'
bys id yr_`x': egen move_yr_`x' = max(move_not) if yr_`x' == 1
bys id: egen ev_move_yr_`x' = max(move_yr_`x')
drop move_yr_`x'

foreach var in more_exp_rent less_exp_rent worse_location better_location worse_epop better_epop worse_amm better_amm  {
bys id yr_`x': egen `var'_yr_`x' = max(`var') if yr_`x' == 1
bys id: egen ev_`var'_yr_`x' = max(`var'_yr_`x')
drop `var'_yr_`x' 
}
foreach var in tempz2_cellsharei tempz2_epop tempz2_amenityrank tempz2_md_rrentgrsi tempz2_shcon tempz2_shman tempz2_shgov tempz2_shmil tempz2_shsvc {
bys id yr_`x': egen ch_`var'_yr_`x' = max(ch_`var') if yr_`x' == 1
bys id: egen ev_ch_`var'_yr_`x' = max(ch_`var'_yr_`x')
drop ch_`var'_yr_`x' 
}

bys id yr_`x': gen dist_less300_yr_`x' = distance_move_not < 300 & ev_move_yr_`x' == 1 & yr_`x' == 1
bys id: egen ev_dist_less300_yr_`x' = max(dist_less300_yr_`x')

bys id yr_`x': gen dist_300_1000_yr_`x' = distance_move_not >= 300 & distance_move_not < 1000 & ev_move_yr_`x' == 1 & yr_`x' == 1
bys id: egen ev_dist_300_1000_yr_`x' = max(dist_300_1000_yr_`x')

bys id yr_`x': gen dist_1000_2000_yr_`x' = distance_move_not >= 1000 & distance_move_not < 2000 & ev_move_yr_`x' == 1 & yr_`x' == 1
bys id: egen ev_dist_1000_2000_yr_`x' = max(dist_1000_2000_yr_`x')

bys id yr_`x': gen dist_2000_3000_yr_`x' = distance_move_not >= 2000 & distance_move_not < 3000 & ev_move_yr_`x' == 1 & yr_`x' == 1
bys id: egen ev_dist_2000_3000_yr_`x' = max(dist_2000_3000_yr_`x')

bys id yr_`x': gen dist_gr_3000_yr_`x' = distance_move_not > 3000 & ev_move_yr_`x' == 1 & yr_`x' == 1 & distance_move_not ~= .
bys id: egen ev_dist_gr_3000_yr_`x' = max(dist_gr_3000_yr_`x')

}

*** creating arloc fixed effects for each year
	forvalues x=1/5 {
	sort id yr_`x' filedt_s training
	by id yr_`x': gen yrnum = _n
	gen arloc_yr_`x'_1 = arloc_unique if yr_`x' == 1 & training == 0 & yrnum == 1
	gen arloc_yr_`x'_2 = arloc_unique if yr_`x' == 1 & training == 0 & yrnum == 2
	gen arloc_yr_`x'_3 = arloc_unique if yr_`x' == 1 & training == 0 & yrnum == 3
	bys id: egen ev_arloc_yr_`x'_1 = max(arloc_yr_`x'_1)
	bys id: egen ev_arloc_yr_`x'_2 = max(arloc_yr_`x'_2)
	bys id: egen ev_arloc_yr_`x'_3 = max(arloc_yr_`x'_3)
	drop yrnum arloc_yr_`x'_*
	}

*** only including if have data on the characteristics of the move
forvalues x=1/5 {
foreach var in more_exp_rent less_exp_rent worse_location better_location worse_epop better_epop worse_amm better_amm ch_tempz2_cellsharei ch_tempz2_epop ch_tempz2_amenityrank ch_tempz2_md_rrentgrsi ch_tempz2_shcon ch_tempz2_shman ch_tempz2_shgov ch_tempz2_shmil ch_tempz2_shsvc {
replace ev_`var'_yr_`x' = 0 if ev_move_yr_`x' == 0
}
}

*** time since start for first move.
	gen temp4 = min_date_move - startdate if filedt_s == min_date_move
	bys id: egen time_since_start = max(temp4)

*** creating a sample for the figures
	
	* 1) just first moves
	gen figure_sample = 1 if move_not == 1 & filedt_s == min_date_move
	
	* 2) in military for at least 6 months before first move
	bys id: egen firstdate = min(filedt_s)
	replace figure_sample = 0 if min_date_move < firstdate + 180
	
	*3) in military for at least 2 years after first move
	bys id: egen lastdate = max(filedt_s)
	replace figure_sample = 0 if lastdate - min_date_move < 730
	
	*4) do not move for at least 2 years after first move
	sort id move_not filedt_s
	replace figure_sample = 0 if filedt_s[_n+1] - filedt_s < 730 & move_not == 1 & move_not[_n+1] == 1 & id == id[_n+1]
	
	*5) not married 6 months before first move
	replace figure_sample = 0 if date_marr - filedt_s < -180
	replace figure_sample = 0 if m_ent == 1
	
	*6) not moving from or to an abroad location
	sort id training filedt_s
	gen conus_conus = abroad == 0 & abroad[_n-1] == 0 & training[_n-1] == 0
	
	gen abroad_conus = abroad == 0 & abroad[_n-1] == 1 & training[_n-1] == 0
	
	gen conus_abroad = abroad == 1 & abroad[_n-1] == 0 & training[_n-1] == 0 & (substr(arloc, 1, 2) == "GE" | substr(arloc, 1, 2) == "GM" | substr(arloc, 1, 2) == "IT")
	
	gen abroad_abroad = abroad == 1 & abroad[_n-1] == 1 & training[_n-1] == 0
	
	summ time_since_move_not if abroad_abroad == 1, de
	summ time_since_move_not if abroad_conus == 1, de
	
	*** saving a file to then re-randomize the moves in another do file
	preserve
	gen floor_tenure = floor((filedt_s - startdate)/30)
	bys id: egen temp_age = min(age)
	gen entry_age = floor(temp_age)
	drop temp_age
	keep if figure_sample == 1 
	keep id move_not filedt_s min_date_move firstdate lastdate date_marr entry_age age floor_tenure filedt_s startdate
	save  $datadir/figre_sample_fake_1, replace
	restore
	
*** creating another sample of movers where there is a longer pre-lag and a shorter post lag
	
	* 1) just first moves
	gen figure_sample2 = 1 if move_not == 1 & filedt_s == min_date_move
	
	* 2) in military for at least 2 years before first move
	replace figure_sample2 = 0 if min_date_move < firstdate + 730
	
	*3) in military for at least 6 months after first move
	replace figure_sample2 = 0 if lastdate - min_date_move < 180
	
	*4) do not move for at least 6 months after first move
	sort id move_not filedt_s
	replace figure_sample2 = 0 if filedt_s[_n+1] - filedt_s < 180 & move_not == 1 & move_not[_n+1] == 1 & id == id[_n+1]
	
	*5) not married 2 years before first move
	replace figure_sample2 = 0 if date_marr - filedt_s < -730
	replace figure_sample2 = 0 if m_ent == 1
	
	*** creating an alternate sample for figure 1 that fits the restrictions below
	gen figure_sample_alt = figure_sample

	bys id: egen ever_figure_sample = max(figure_sample)
	bys id: egen ever_figure_sample2 = max(figure_sample2)
	
	*** saving another file to then re-randomize the moves in another do file
	preserve
	gen floor_tenure = floor((filedt_s - startdate)/30)
	bys id: egen temp_age = min(age)
	gen entry_age = floor(temp_age)
	drop temp_age

	keep if figure_sample2 == 1 
	keep id move_not filedt_s min_date_move firstdate lastdate date_marr entry_age age floor_tenure filedt_s startdate
	save  $datadir/figre_sample_fake_2, replace
	restore	
	
*** Create a sample of people that can be used as a comparison.
	* 1) create sample -- had been in the army for at least six months -- a date for each person that occurs at the average time and age for people

	gen figure_sample_nomove = filedt_s == firstdate
	
	* 2) look similar to figure_sample (balance on age and time since enter // and other characteristics)
	gen tenure = filedt_s - startdate
	summ age tenure female ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat if figure_sample == 1
	summ tenure if figure_sample == 1, de
		gen figure_nomove_date = firstdate + r(mean)
		replace figure_sample_alt = 0 if tenure < r(mean) - 365 | tenure > r(mean) + 365

	gen temp_age = 	(figure_nomove_date - birthmo)/365
	summ age if figure_sample == 1, de
		replace figure_sample_nomove = 0 if temp_age < r(mean) - 1 | temp_age > r(mean) + 1
		replace figure_sample_alt = 0 if age < r(mean) - 1 | age > r(mean) + 1
	summ age tenure female ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat if figure_sample_nomove == 1

	replace figure_sample_nomove = 0 if figure_nomove_date < firstdate + 180	


*3) do not move for at least 2 years after filedt_s
	sort id  filedt_s
	replace figure_sample_nomove = 0 if min_date_move - figure_nomove_date < 730 & min_date_move ~= .
	
*4) not married 6 months before first move
	replace figure_sample_nomove = 0 if date_marr - figure_nomove_date < -180
	replace figure_sample_nomove = 0 if m_ent == 1

*5) in military for at least 2 years after filedt_s
	replace figure_sample_nomove = 0 if lastdate - figure_nomove_date < 730

	forvalues x=1/24 {
	gen t_neg`x' = 0 if figure_sample == 1 | figure_sample_nomove == 1 | figure_sample_alt == 1
	gen t2_neg`x' = 0 if figure_sample2 == 1
	
	gen t_kids_neg`x' = 0 if figure_sample == 1 | figure_sample_nomove == 1 | figure_sample_alt == 1
	gen t_div_neg`x' = 0 if m_ent == 1 | figure_sample2 == 1
	}
	forvalues x=0/25 {
	gen t_pos`x' = 0 if figure_sample == 1 | figure_sample_nomove == 1 | figure_sample_alt == 1 
	gen t2_pos`x' = 0 if figure_sample2 == 1 
	
	gen t_kids_pos`x' = 0 if figure_sample == 1 | figure_sample_nomove == 1 | figure_sample_alt == 1 
	gen t_div_pos`x' = 0 if m_ent == 1 
	}
	
	*** 1 if married at each of these month intervals, 0 if not married at each of these month intervals
	
	forvalues x=1/24 {
	local y = `x' -1
	local z = `y' * 30
	replace t_neg`x' = 1 if (figure_sample == 1 | figure_sample_alt == 1) & date_marr - filedt_s < -`z' & date_marr ~= .
	replace t2_neg`x' = 1 if (figure_sample2 == 1 | figure_sample_alt == 1) & date_marr - filedt_s < -`z' & date_marr ~= .
	
	replace t_neg`x' = 1 if (figure_sample_nomove == 1) & date_marr - figure_nomove_date < -`z' & date_marr ~= .

	
	}
	
	forvalues x=1/26 {
	local y = `x' - 1
	local z = `y' * 30
	replace t_pos`y' = 1 if (figure_sample == 1 | figure_sample_alt == 1 | figure_sample2 == 1) & date_marr - filedt_s < `z' & date_marr ~= .
	replace t2_pos`y' = 1 if (figure_sample2 == 1) & date_marr - filedt_s < `z' & date_marr ~= .

	replace t_pos`y' = 1 if (figure_sample_nomove == 1) & date_marr - figure_nomove_date < `z' & date_marr ~= .


	}
	
	*** 1 if have kids at each of these month intervals, 0 if no kids at each of these month intervals
	
	forvalues x=1/7 {
	local y = `x' -1
	local z = `y' * 30
	replace t_kids_neg`x' = 1 if (figure_sample == 1 | figure_sample2 == 1) & date_first_kids - filedt_s < -`z' & date_first_kids ~= .
	}
	
	forvalues x=1/26 {
	local y = `x' - 1
	local z = `y' * 30
	replace t_kids_pos`y' = 1 if (figure_sample == 1 | figure_sample2 == 1) & date_first_kids - filedt_s < `z' & date_first_kids ~= .
	}
	
	save $datadir/data_for_graph_miles, replace
	
***** Figure 1 is now created in jhr_fig_1.do

save $datadir/figs_3a_3b, replace
*** Figures 3A and 3B in jhr_figs_3a_3b.do

*** dual spouse
	gen dualspouse = spouse_id ~= .
	replace married = 1 if dualspouse == 1
	dis "summarizing dualspouse"
	summ dualspouse
	


*** deployment variables
	gen temp = sum_combat >0 & sum_combat ~= .  
	bys id: egen everdepl = max(temp)
	
	
*** moves pre and post deployment

	gen pre_move_not = move_not if filedt_s < min_combat_filedt_s
	gen post_move_not = move_not if filedt_s > min_combat_filedt_s
	
*** married 3 months before first deployment

	gen diff_marr_combat = min_combat_filedt_s - date_marr
	gen marr_3mo_1deploy = (diff_marr_combat > 0 & diff_marr_combat <= 92 & diff_marr_combat ~= .)
	replace marr_3mo_1deploy = . if evermarr == 0

*** date of first non-training move

	bys id move_not: egen temp_move = min(filedt_s)
	replace temp_move = . if move_not == 0
	bys id: egen first_move_dt_s = min(temp_move)
		

	dis "count number of people in sample, check 0"
	count if num_id_check == 1


	
*** people who were ever in a dual relationship
	bys id: egen everdual = max(dualspouse)
	replace evermarr = 1 if everdual == 1
	gen ndual = 1 if everdual == 0
	replace ndual = 0 if everdual == 1

*** for people who were ever abroad, don't include them in the epop / cell share data
	replace avg_epop = . if everabroad == 1
	
	replace avg_cellshare = . if everabroad == 1


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
	
*** total moves pre-deployment and post deployment
	bys id: egen pre_totmoves_not = total(pre_move_not)
	bys id: egen post_totmoves_not = total(post_move_not)
	
	
*** total worse moves
	bys id: egen tot_worse_not = max(worse_location)
	bys id: egen tot_better_not = max(better_location)	
	bys id: egen tot_worse_epop = max(worse_epop)
	bys id: egen tot_better_epop = max(better_epop)	
	bys id: egen tot_figure_sample = max(figure_sample)
	bys id: egen tot_conus_abroad = max(conus_abroad)
	bys id: egen tot_abroad_conus = max(abroad_conus)
	bys id: egen tot_abroad_abroad = max(abroad_abroad)
	bys id: egen tot_worse_amm = max(worse_amm)
	bys id: egen tot_better_amm = max(better_amm)	
	bys id: egen tot_more_exp_rent = max(more_exp_rent)
	bys id: egen tot_less_exp_rent = max(less_exp_rent)
	


*** changing the totmoves to only include non-abroad moves --- just for Germandy and Italy where it is most likely to be accomanied.  

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
	
	bys id: egen abroad_moves_not_c_o = total(abroad_move_c_o)
	bys id: egen abroad_moves_not_o_c = total(abroad_move_o_c)
	bys id: egen abroad_to_abroad_moves = total(abroad_to_abroad_move)

	** could be domestic moves within us or within italy/germany
	label var totmoves_not "Domestic Moves"

*	histogram time_since_move if move == 1, percent
*	graph export $figdir/time_since_move.ps, replace

** total time spent in training
	sort id filedt_s
	gen time_in_training = filedt_s - filedt_s[_n-1] if training == 1 & id == id[_n-1] & filedt_s > filedt_s[_n-1]
	bys id: egen min_train = min(filedt_s)
	gen mintrain = (filedt_s == min_train & training == 1)
	replace time_in_training = filedt_s - startdate if mintrain == 1
	bys id: egen tot_time_t = total(time_in_training)
	drop min_train mintrain

** time overseas - NEED TO CORRECT FOR OTHER PLACES WHERE FAMILY DOES NOT MOVE (BESIDES KOREA)
	sort id training conus filedt_s
	gen temp_overseas = filedt_s - filedt_s[_n-1] if conus[_n-1] == 0 & id == id[_n-1] & cnty[_n-1] ~= "KS" & training == 0 & filedt_s > filedt_s[_n-1]
	bys id: egen time_overseas = total(temp_overseas)
	drop temp_overseas


*** urban versus rural
	gen rural = msa == .
	replace rural = . if zipcd == "" 
	replace rural = . if conus == 0
	sort id training rural filedt_s
	gen temp_rural = filedt_s - filedt_s[_n-1] if rural[_n-1] == 1 & id == id[_n-1] & conus[_n-1] == 1 & training == 0 & filedt_s > filedt_s[_n-1]
	bys id: egen time_rural = total(temp_rural)
	drop temp_rural

*** time not in region 
	gen inhomeregion = region == regionhor
	sort id training inhomeregion filedt_s
	gen temp_region = filedt_s - filedt_s[_n-1] if inhomeregion[_n-1] == 0 & id == id[_n-1] & training == 0 & filedt_s > filedt_s[_n-1]
	replace temp_region = 0 if inhomeregion[_n-1] == 1 & id == id[_n-1] & training == 0
	bys id: egen time_notreg = total(temp_region)
	bys id: egen ever_home = min(temp_region)
	replace ever_home = 1 if ever_home > 0
	replace time_notreg = . if regionhor == ""
	drop temp_region
	
	drop ever_home
	gen temp_ever_home = inhomeregion == 1 & training == 0
	bys id: egen ever_home = max(temp_ever_home)
	
*** ever in home division
	gen inhomedivision = division == divisionhor & training == 0
	bys id: egen ever_hom_division = max(inhomedivision)

	sort id training inhomedivision filedt_s
	gen temp_div = filedt_s - filedt_s[_n-1] if inhomedivision[_n-1] == 0 & id == id[_n-1] & training == 0 & filedt_s > filedt_s[_n-1]
	replace temp_div = 0 if inhomedivision[_n-1] == 1 & id == id[_n-1] & training == 0
	bys id: egen time_notdiv = total(temp_div)
	replace time_notdiv = . if divisionhor == ""
	
*** ever in home state
	gen inhomestate = state == statehor & training == 0
	bys id: egen ever_hom_state = max(inhomestate)

** number of years with a move
	bys id year: egen move_in_year = max(move_not)
	bys id year: gen num_temp = sum(move_in_year)
	gen temp3 = (move_in_year == 1 & num_temp == 1)
	bys id: egen tot_year_move = total(temp3)
	drop move_in_year num_temp temp3


** moves in the last five years
	bys id: egen lastobs2 = max(filedt_s)
	gen temp5 = lastobs2 - 1826
	gen last5 = (filedt_s >= temp5)
	gen tempmove = (move_not == 1 & last5 == 1)
	bys id: egen moves_5years = total(tempmove)
	bys id: egen max_yos = max(yos)
	replace moves_5years = . if max_yos < 4
	drop max_yos
	drop  temp5 last5 tempmove

*** move in the last year

	gen temp1 = lastobs2 - 365
	gen last1 = (filedt_s >= temp1)
	gen tempmove = (move_not == 1 & last1 == 1)
	bys id: egen moves_1year = total(tempmove)
	drop lastobs2 temp1 last1 tempmove

	foreach var in msa region division {
	bys id `var': gen num_`var' = _n
	gen temp`var' = num_`var' == 1
	bys id: egen tot`var' = total(temp`var')
	drop temp`var' num_`var'
	}

dis "count number of people in sample, check 2"
count if num_id_check == 1
drop lastdate
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
	gen tot_msa_yr = totmsa / `yos'
	gen tot_region_yr = totregion/ `yos'
	gen tot_division_yr = totdivision / `yos'
	gen tot_lm_yr = totlongmove / `yos'
	gen tot_sm_yr = totshortmove / `yos'
	set emptycells drop, permanently


** regressing their time in service before first move 
	eststo clear

	ren tot_division_yr tot_div_yr

	dis "count number of people in sample, check 3"
	count if num_id_check == 1

	gen w_m = female == 0 & white == 1
	foreach var in longestmove time_overseas time_1_2 mean_last2 time_notreg time_rural {
	gen temp2 = `var' /365.25
	drop `var'
	ren temp2 `var'
	}

	foreach var in  totpop {
	gen temp2 = `var' / 100000
	drop `var'
	ren temp2 `var'
	}
	foreach var in 5 {
	if `to_`var'' {
	gen re_enlist_10 = maxyos >= 10
	}
	}



	gen male = sex == "M" if sex ~= ""



*** creating indicators for 1, 2, 3 moves, etc.  will use in the regressions
	gen one_move = totmoves_not == 1
	gen zero_one_move = totmoves_not_w_abroad <= 1
	gen two_move = totmoves_not == 2
	gen zero_two_move = totmoves_not_w_abroad <= 2
	gen three_move = totmoves_not == 3
	gen zero_three_move = totmoves_not_w_abroad <= 3
	gen any_move = totmoves_not > 0 if totmoves_not ~= .
	gen any_move_intl = totmoves_not_w_abroad > 0 if totmoves_not_w_abroad ~= .

	gen one_abroad_move = abroad_moves_not == 1
	gen two_abroad_move = abroad_moves_not == 2
	gen three_abroad_move = abroad_moves_not == 3
	
	gen one_abroad_moves_not_c_o = abroad_moves_not_c_o == 1
	gen two_abroad_moves_not_c_o = abroad_moves_not_c_o == 2
	gen three_abroad_moves_not_c_o = abroad_moves_not_c_o == 3

	gen one_abroad_moves_not_o_c = abroad_moves_not_o_c == 1
	gen two_abroad_moves_not_o_c = abroad_moves_not_o_c == 2
	gen three_abroad_moves_not_o_c = abroad_moves_not_o_c == 3	
	
	gen one_abroad_abroad_move = abroad_to_abroad_moves == 1
	gen two_abroad_abroad_move = abroad_to_abroad_moves == 2
	gen three_abroad_abroad_move = abroad_to_abroad_moves == 3
	
foreach var in tot_less_exp_rent tot_better_amm tot_better_epop tot_better_not tot_worse_not tot_worse_epop tot_worse_amm tot_more_exp_rent {
replace `var' = . if one_move ~= 1
}
	
	gen drop0_totmov = totmoves_not
	replace drop0_totmov = . if totmoves_not == 0

/* creating a normalized version of epop for each of these outcomes below*/

*** creating some sub populations
	gen all = 1
	gen nm_ent = 1 if m_ent == 0
	replace nm_ent = 0 if m_ent == 1

	gen term5 = terms == "5"
	
	gen max_three = totmoves_not_w_abroad <= 3
	
	gen neverdepl = everdepl == 0
	gen infantry = branch == "IN"


*** interating home with moves
	replace ever_home = . if time_notreg == .
	summ ever_home

	gen home_x_tot = ever_home*totmoves_not

*** creating distances in terms of 1,000s	
	gen tot_dist_not_old = tot_dist_not
	replace tot_dist_not = tot_dist_not_old / 1000

*** normalizing avg_epop, time, and distance

		qui areg re_enlist totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq if everabroad == 0, absorb(exper_br_year_fe)		


		summ longestmove, de
		ren longestmove longestmove2
		gen longestmove = (longestmove - r(mean))/r(sd)
		gen long_avg = longestmove > 0

		gen long_x_tot = longestmove*totmoves_not

		summ avg_epop if e(sample) == 1, de
		ren avg_epop avg_epop2
		gen avg_epop = (avg_epop2 - r(mean))/r(sd)
		gen long_emp = avg_epop > 0
		replace long_emp = . if avg_epop == .
		gen emp_x_tot = avg_epop*totmoves_not
		
		summ avg_cellshare if e(sample) == 1, de
		ren avg_cellshare avg_cellshare2
		gen avg_cellshare = (avg_cellshare - r(mean))/r(sd)
		
		gen cell_x_tot = avg_cellshare*totmoves_not

		summ avg_cellpop if e(sample) == 1, de
		ren avg_cellpop avg_cellpop2
		gen avg_cellpop = (avg_cellpop - r(mean))/r(sd)
		
		foreach var in avg_cell2br avg_cell_amm avg_shcon avg_shman avg_shgov avg_shmil avg_shsvc {
		egen z2`var' = std(`var')
		}
		
		
		gen cellpop_x_tot = avg_cellpop*totmoves_not
		
		sum tot_dist_not if e(sample) == 1, de
		ren tot_dist_not tot_dist_not2
		gen tot_dist_not = (tot_dist_not2 - r(mean))/r(sd)
		
		summ tot_dist_not, de
		gen tot_dist_not_temp = (tot_dist_not - r(mean))/r(sd)
		
		gen tot_dist_gr_less300 = tot_dist_not_old <= 300 & tot_dist_not_old ~= 0 if tot_dist_not_old ~= . 
		gen tot_dist_gr_300_1000 = tot_dist_not_old > 300 & tot_dist_not_old <= 1000 if tot_dist_not_old ~= .
		gen tot_dist_gr_1000_2000 = tot_dist_not_old > 1000 & tot_dist_not_old <= 2000 if tot_dist_not_old ~= .
		gen tot_dist_gr_2000_3000 = tot_dist_not_old > 2000 & tot_dist_not_old <= 3000 if tot_dist_not_old ~= .
		gen tot_dist_gr_great3000 = tot_dist_not_old > 3000 if tot_dist_not_old ~= .

		
		gen dist_x_tot = totmoves_not*tot_dist_not

*** labeling variables 
		label var everdissolve "Dissolve Marriage"
		label var everkids "Have Children"
		label var ged "GED"
		label var hsd "High School Dropout"
		label var hsg "High School Graduate"
		label var term5 "Term Legnth = 5 Years"
		label var male "Male"
		label var female "Female"
		label var nm_ent "Not Married when Enter"
		label var m_ent "Married when Enter"
		label var mar_lyr "Married in 1st Year"
		label var ever_home "Ever in Home Region"
		label var home_x_tot "Ever Home x Moves"
		label var long_avg "Longer than Average Stay"
		label var long_x_tot "Longer x Moves"
		label var long_emp "Avg. Employment > Mean"
		label var emp_x_tot "Emp x Moves"
		label var avg_epop "Average Employment to Pop"
		label var longestmove "Longest Spell"
		label var time_notreg "Time not in Home Region"
		label var tot_dist_not "Total Distance of Moves"
		
		gen abroad_notGM_GE_IT = (conus == 0 & (substr(arloc, 1, 2) ~= "GM" & substr(arloc, 1, 2) ~= "GE" & substr(arloc, 1, 2) ~= "IT"))
		bys id: egen ever_abroad_notGM_GE_IT = max(abroad_notGM_GE_IT)

		
********
*** dataset for creating all of the tables 
********

save $datadir/jhr_clean_for_tables, replace	

/* creating sample to use for Table 8 */

		qui areg evermarr totmoves_not ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq if nm_ent == 1 & everabroad == 0, absorb(exper_br_year_fe)
		gen sample_evermarr_us = e(sample)
		gen sample_marr_nm_ent_us = e(sample)
		dis "summ evermarr by nbr moves, us only"
		tabstat evermarr if e(sample) == 1, by(totmoves_not) c(stats) stats(mean n)
		local demos_evermarr female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		gen marr_nm_ent = married if nm_ent == 1 
		local demos_marr_nm_ent female ged hsd asc_smc college_pl afqsc black hispanic other_race sum_combat age age_sq
		
		**** saving this sample to use for the Table 8 regressions with five obs per person
		preserve
		keep if sample_evermarr_us == 1 
		save $datadir/evermarr_us_sample, replace
		restore
	
