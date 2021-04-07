*** This do file creates Table 8 with the output of table_8.xls


clear all
set more off
set matsize 1000
capture log close
set logtype text
set debug off


local date = "03222021"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/jhr_table_8.txt, replace 
	global outsheet XXX\jhr_output

use $datadir/evermarr_us_sample

gen same_arloc = first_arloc == last_arloc

reshape long ev_marr_yr_ ev_move_yr_ ev_more_exp_rent_yr_ ev_less_exp_rent_yr_ ev_worse_location_yr_ ev_better_location_yr_ ev_worse_epop_yr_ ev_better_epop_yr_ ev_worse_amm_yr_ ev_better_amm_yr_ ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_ ev_dist_gr_3000_yr_  ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_, j(year_of_service) i(id)

bys id: egen totmove = sum(ev_move)
keep if totmove == 1 | totmove == 0

replace ev_dist_2000_3000_yr_ = 1 if ev_dist_gr_3000_yr_ == 1

areg ev_marr ev_move ev_more_exp_rent_ ev_less_exp_rent_ ev_worse_location_ ev_better_location_ ev_worse_epop_ ev_better_epop_ ev_worse_amm_ ev_better_amm_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ i.year_of_service ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq, robust absorb(exper_br_year_fe)
gen sample_table7 = e(sample) == 1
bys id sample_table7: gen nbrtable7 = _N
replace sample_table7 =0 if nbrtable7 ~= 5

areg ev_marr ev_move i.year_of_service ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq  if sample_table7 == 1, robust absorb(exper_br_year_fe)
	outreg2 using $outsheet/table_8.xls, replace label ctitle(controls) title(table_8) dec(3) keep(ev_move)

areg ev_marr ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ i.year_of_service ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq   if sample_table7 == 1, robust absorb(exper_br_year_fe)
	outreg2  using $outsheet/table_8.xls,  label ctitle(controls) title(table_8) dec(3) keep(ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_)


areg ev_marr ev_move ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_  i.year_of_service ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq   if sample_table7 == 1, robust absorb(exper_br_year_fe)
	outreg2  using $outsheet/table_8.xls,  label ctitle(controls) title(table_8) dec(3) keep(ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_ )

	
	
areg ev_marr ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_  i.year_of_service ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq   if sample_table7 == 1, robust absorb(exper_br_year_fe)
	outreg2  using $outsheet/table_8.xls,  label ctitle(controls) title(table_8) dec(3) keep(ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_ )

areg ev_marr ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_  i.year_of_service ged hsd hsg asc_smc college_pl female afqsc black hispanic other_race sum_combat age age_sq same_arloc i.first_arloc i.last_arloc if sample_table7 == 1, robust absorb(exper_br_year_fe)
	outreg2  using $outsheet/table_8.xls,  label ctitle(controls) title(table_8) dec(3) keep(ev_move ev_ch_tempz2_cellsharei_yr_ ev_ch_tempz2_epop_yr_ ev_ch_tempz2_amenityrank_yr_ ev_ch_tempz2_md_rrentgrsi_yr_ ev_ch_tempz2_shcon_yr_ ev_ch_tempz2_shman_yr_ ev_ch_tempz2_shgov_yr_ ev_ch_tempz2_shmil_yr_ ev_ch_tempz2_shsvc_yr_ ev_dist_less300_yr_ ev_dist_300_1000_yr_ ev_dist_1000_2000_yr_ ev_dist_2000_3000_yr_)
