*** This do file creates the data for Figures 3A and 3B.  Text file output: jhr_figs_3a_3b.txt

 clear all
set more off
set matsize 1000
capture log close
set logtype text
set debug off

local date = "02032021"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/jhr_figs_3a_3b.txt, replace 
	global outsheet XXX/jhr_output

use $datadir/figs_3a_3b

	drop t_neg* t_pos*

	*** marriages surrounding re-enlistment for five-year sample - conditional on re-enlist
	

		bys id first_term: egen maxfirst = max(filedt_s)
		replace maxfirst = . if first_term == 0		
		gen not_first_term = first_term ~= 1
		bys id: egen re_enlist2 = max(not_first_term)
			forvalues x=1/24 {
			gen t_neg`x' = 0 if m_ent == 0 & re_enlist2 == 1
			}
			forvalues x=1/24 {
			local y = `x' -1
			local z = `y' * 30
			replace t_neg`x' = 1 if date_marr - maxfirst  < -`z' & re_enlist2 == 1
			}
			
			forvalues x=0/25 {
			gen t_pos`x' = 0 if re_enlist2 == 1
			}
			
			forvalues x=1/26 {
			local y = `x' - 1
			local z = `y' * 30
			replace t_pos`y' = 1 if  date_marr - maxfirst  < `z' & re_enlist2 == 1
			}
		
		*** one obs per person
		bys id first_term: gen num_temp = _n
		replace num_temp = . if first_term == 0
		
		
		
		summ t_neg* t_pos* if figure_sample == 1 & everabroad == 0 & num_temp == 1 & re_enlist2 == 1 & maxfirst - firstdate > 365
		
		** Figure 3A
		tabstat t_neg13 t_neg12 t_neg11 t_neg10 t_neg9 t_neg8 t_neg7 t_neg6 t_neg5 t_neg4 t_neg3 t_neg2 t_neg1 t_pos1 t_pos2 t_pos3 t_pos4 t_pos5 t_pos6 t_pos7 t_pos8 t_pos9 t_pos10 t_pos11 t_pos12 t_pos13 t_pos14 t_pos15 t_pos16 t_pos17 t_pos18 t_pos19 t_pos20 t_pos21 t_pos22 t_pos23 t_pos24 t_pos25 if figure_sample == 1 & everabroad == 0 & num_temp == 1 & re_enlist2 == 1 & maxfirst - firstdate > 365, stats(mean n) col(s)
	
		drop t_neg* t_pos* num_temp
	
		*** first move surrounding re-enlistment for five-year sample
	
		bys id move_not: egen temp_minmove = min(filedt_s)
		replace temp_minmove = . if move_not == 0
		bys id: egen minmove = min(temp_minmove)
			forvalues x=1/13 {
			gen t_neg`x' = 0 if re_enlist2 == 1
			}
			forvalues x=1/13 {
			local y = `x' -1
			local z = `y' * 30
			replace t_neg`x' = 1 if minmove - maxfirst  < -`z'  & re_enlist2 == 1 & minmove ~= .
			}
			
			forvalues x=0/13 {
			gen t_pos`x' = 0  if re_enlist2 == 1
			}
			
			forvalues x=1/13 {
			local y = `x' - 1
			local z = `y' * 30 
			replace t_pos`y' = 1 if minmove - maxfirst  < `z' & re_enlist2 == 1 & minmove ~= .
			}
		
		*** one obs per person
		bys id first_term: gen num_temp = _n
		replace num_temp = . if first_term == 0
		*** make sure in army for one years before and one years after re-enlistment
		gen re_sample = re_enlist2 == 1 & maxfirst - firstdate > 365 & lastdate - maxfirst > 365
		
		summ t_neg* t_pos* if everabroad == 0 & num_temp == 1 & re_sample == 1 & ever_figure_sample == 1

		*** Figure 3B
		tabstat t_neg13 t_neg12 t_neg11 t_neg10 t_neg9 t_neg8 t_neg7 t_neg6 t_neg5 t_neg4 t_neg3 t_neg2 t_neg1 t_pos1 t_pos2 t_pos3 t_pos4 t_pos5 t_pos6 t_pos7 t_pos8 t_pos9 t_pos10 t_pos11 t_pos12 if everabroad == 0 & num_temp == 1 & re_sample == 1 & ever_figure_sample == 1, stats(mean n) col(s)

	
		
	