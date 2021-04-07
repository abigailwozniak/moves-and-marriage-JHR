*** This do file creates the data for Figure 1.  Data for figure is created in fig_1_data.dta


clear all
set more off
set matsize 1000
capture log close
set logtype text
set debug off


local date = "02032021"

	global datadir XXX/dta
	global logdir XXX/jhr_output
	log using $logdir/fig_1.txt, replace 
	global outsheet XXX/jhr_output


foreach var in 1 {
use $datadir/figre_sample_fake_`var', clear

*** what tenure month people moved
tab floor_tenure

*** married month tenure

gen floor_married_tenure = floor((date_marr - startdate)/30)

	forvalues x=1/24 {
	gen t_neg`x' = 0 

	}
	forvalues x=0/25 {
	gen t_pos`x' = 0 

	}
	
	*** 1 if married at each of these month intervals, 0 if not married at each of these month intervals
	
	forvalues x=1/24 {
	local y = `x'*30
	replace t_neg`x' = 1 if date_marr - filedt_s < - `y' 
	
	}
	
	forvalues x=0/25 {
	local y = `x'*30

	replace t_pos`x' = 1 if date_marr - filedt_s < `y' 

	}

	*** average marriage rate
	
	forvalues x = 1/24 {
	local y = 25 - `x'
	egen avg_t_neg`y' = mean(t_neg`y')
	
	}
	forvalues x = 0/25 {
	egen avg_t_pos`x' = mean(t_pos`x')

	}

	preserve
	gen obs = "real"
	keep if _n == 1
	keep avg_t* obs
	save $outsheet/fig_1_data, replace
	restore

	drop t_* avg_*

*** plan: bys entry_age - assign a new id number.  Save the new id, entry_age, and tenure into a dataset.  Randomly sort the data within entry age - assign a new id number and merge on the placebo tenure month

	gen floor_entry_age = floor(entry_age)
	gen tenure = filedt_s - startdate 
	
	preserve
	bys floor_entry_age: gen new_id = _n
	gen placebo_move_tenure = tenure

	keep floor_entry_age new_id placebo_move_tenure
	save $datadir/new_id_entry_age, replace
	restore


	set seed 365476247 
	global bootreps = 100 

* iterate over the bootstrap replications;
forvalues boot = 1/$bootreps { 
	preserve
	gen random = uniform()
	sort floor_entry_age random
	by floor_entry_age: gen new_id = _n
	merge 1:1 new_id floor_entry_age using $datadir/new_id_entry_age
	assert _merge == 3
	
*tab placebo_move_tenure

	forvalues x=1/24 {
	gen t_neg`x' = 0 
	}
	forvalues x=0/25 {
	gen t_pos`x' = 0 
	}
	
	*** 1 if married at each of these month intervals, 0 if not married at each of these month intervals
	
	forvalues x=1/24 {
	local y = `x'*30
	replace t_neg`x' = 1 if date_marr - startdate - placebo_move_tenure < - `y' 
		}
	
	forvalues x=0/25 {
	local y = `x'*30

	replace t_pos`x' = 1 if date_marr - startdate - placebo_move_tenure < `y' 
	}
	
	
	forvalues x = 1/24 {
	local y = 25 - `x'
	egen avg_t_neg`y' = mean(t_neg`y')
	}
	forvalues x = 0/25 {
	egen avg_t_pos`x' = mean(t_pos`x')
	}	
	
gen obs = "`boot'"
gen num = _n
keep if num == 1
keep avg_t* obs
append using $outsheet/fig_1_data
save $outsheet/fig_1_data, replace

restore	
dis "iteration `boot'"
}
}


