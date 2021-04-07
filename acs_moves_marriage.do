capture log close
capture clear
estimates clear

log using acs_moves_marriage.log, replace

/*** Look at prevalence of new marriage among movers in ACS ***/

qui do usa_00027.do

keep if gq==1 | gq==2
drop if qmarinyr==4
drop if qmigrat1==4
drop if qmarst==4

replace perwt=round(perwt/100)

* Sample already limited to ages 18-28

tab1 marrinyr
recode marrinyr (0=.) (1=0) (2=1)
recode divinyr (0 8=.) (1=0) (2=1)

gen married=.
tab1 marst
replace married=1 if marst==1 | marst==2
replace married=0 if inlist(marst,3,4,5,6)==1

* Moved is moved house or higher, movedst is moved states or higher. No county-level, within state move category in migrate1.

gen moved=.
replace moved=0 if migrate1==1
replace moved=1 if migrate1==2 | migrate1==3 | migrate1==4
gen movedst=.
replace movedst=0 if migrate1==1 | migrate1==2
replace movedst=1 if migrate1==3 | migrate1==4

summ marrinyr divinyr married moved movedst

reg marrinyr moved [pw=perwt], robust
  estimates store A
reg marrinyr moved if sex==1 [pw=perwt], robust
  estimates store Amen
reg marrinyr moved if sex==1 & inlist(educd,63,65,71,81)==1 [pw=perwt], robust
  estimates store Aed
reg marrinyr moved if sex==1 & inlist(educd,63,65,71,81)==1 & race==1 [pw=perwt], robust
  estimates store Awhite
reg marrinyr moved if sex==1 & inlist(educd,63,65,71,81)==1 & race==2 [pw=perwt], robust
  estimates store Ablack
reg marrinyr moved if sex==1 & inlist(educd,63,65,71,81)==1 & inlist(hispan,1,2,3,4)==1 [pw=perwt], robust
  estimates store Ahisp
  
reg marrinyr movedst [pw=perwt], robust
  estimates store B
reg marrinyr movedst if sex==1 [pw=perwt], robust
  estimates store Bmen
reg marrinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 [pw=perwt], robust
  estimates store Bed
reg marrinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 & race==1 [pw=perwt], robust
  est sto Bwhite
reg marrinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 & race==2 [pw=perwt], robust
  est sto Bblack
reg marrinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 & inlist(hispan,1,2,3,4)==1 [pw=perwt], robust
  est sto Bhisp
  
reg divinyr movedst [pw=perwt], robust
  est sto C
reg divinyr movedst if sex==1 [pw=perwt], robust
  est sto Cmen
reg divinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 [pw=perwt], robust
  est sto Ced
reg divinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 & race==1 [pw=perwt], robust
  est sto Cwhite
reg divinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 & race==2 [pw=perwt], robust
  est sto Cblack
reg divinyr movedst if sex==1 & inlist(educd,63,65,71,81)==1 & inlist(hispan,1,2,3,4)==1 [pw=perwt], robust
  est sto Chisp
  
reg married movedst [pw=perwt], robust
  est sto D
reg married movedst if sex==1 [pw=perwt], robust
  est sto Dmen
reg married movedst if sex==1 & inlist(educd,63,65,71,81)==1 [pw=perwt], robust
  est sto Ded
reg married movedst if sex==1 & inlist(educd,63,65,71,81)==1 & race==1 [pw=perwt], robust
  est sto Dwhite
reg married movedst if sex==1 & inlist(educd,63,65,71,81)==1 & race==2 [pw=perwt], robust
  est sto Dblack
reg married movedst if sex==1 & inlist(educd,63,65,71,81)==1 & inlist(hispan,1,2,3,4)==1 [pw=perwt], robust
  est sto Dhisp

gen scplus=.
replace scplus=1 if educd >=65 & educd < 999
replace scplus=0 if educd < 65 & educd > 1
tab1 scplus

reg marrinyr movedst scplus i.age [pw=perwt], robust
  estimates store E
reg marrinyr movedst scplus i.age if sex==1 [pw=perwt], robust
  estimates store Emen
reg marrinyr movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 [pw=perwt], robust
  estimates store Eed
reg marrinyr movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 & race==1 [pw=perwt], robust
  est sto Ewhite
reg marrinyr movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 & race==2 [pw=perwt], robust
  est sto Eblack
reg marrinyr movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 & inlist(hispan,1,2,3,4)==1 [pw=perwt], robust
  est sto Ehisp

reg married movedst scplus i.age [pw=perwt], robust
  estimates store F
reg married movedst scplus i.age if sex==1 [pw=perwt], robust
  estimates store Fmen
reg married movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 [pw=perwt], robust
  estimates store Fed
reg married movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 & race==1 [pw=perwt], robust
  est sto Fwhite
reg married movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 & race==2 [pw=perwt], robust
  est sto Fblack
reg married movedst scplus i.age if sex==1 & inlist(educd,63,65,71,81)==1 & inlist(hispan,1,2,3,4)==1 [pw=perwt], robust
  est sto Fhisp  

estout A Amen Aed, keep(moved) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Awhite Ablack Ahisp, keep(moved) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout B Bmen Bed, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Bwhite Bblack Bhisp, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout C Cmen Ced, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Cwhite Cblack Chisp, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout D Dmen Ded, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Dwhite Dblack Dhisp, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout E Emen Eed, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Ewhite Eblack Ehisp, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout F Fmen Fed, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Fwhite Fblack Fhisp, keep(movedst) cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)

estout A Amen Aed, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Awhite Ablack Ahisp, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout B Bmen Bed, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Bwhite Bblack Bhisp, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout C Cmen Ced, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Cwhite Cblack Chisp, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout D Dmen Ded, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Dwhite Dblack Dhisp, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout E Emen Eed, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Ewhite Eblack Ehisp, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout F Fmen Fed, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout Fwhite Fblack Fhisp, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)


/*
estout B*, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout C*, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout D*, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
estout E*, cells(b(star fmt(3)) se(par fmt(3))) stats(N r2)
*/