*grahping


global date "05092019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 


*use "${datadir}\pw_a.dta", clear   //missing as high hazard of event occurance 
*use "${datadir}\pw_b.dta", clear  // low 


*compensation: family ses, own ses, physical attractiveness 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen    
*merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen   // around 20% of spousal inforamtion is missing for newlyweds  
merge 1:1 pid using "${datadir}\work_EHC.dta", nogen  // use only occupation of 10, 12,14, 16

*======impose sample restrictions====== 
*1. alive in 10-16
g 	    alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387

*2.at least one parent alive
keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 

*3. live at parental home in 2010 (to ensure family wealth includes parental wealth)
keep if livepa10==1    //==>5721

*4.single in 2010 
keep if marstat10==0  
*keep if age>=20 & age<=45  // N=1565
keep if age>=15 & age<=45  // N= 2962


*====================missing on Y=====================
*main analysis drop missings
misschk marstat12 marstat14 marstat16  livepa12 livepa14 livepa16, gen(m)
keep if mnumber==0

// marital status is irreversable 
drop if marstat12==1 & marstat14==0  // 2 observation dropped 

// forval i=12(2)16{
// g 		marstay`i'=1 if marstat`i'==1 & livepa`i'==1
// replace marstay`i'=0 if marstat`i'==0 
// replace marstay`i'=0 if marstat`i'==1 & livepa`i'==0
//
// g       marleave`i'=1 if marstat`i'==1 & livepa`i'==0
// replace marleave`i'=0 if marstat`i'==0 
// replace marleave`i'=0 if marstat`i'==1 & livepa`i'==1 
// }



gen 	newlyweds12=1 if marstat12==1 
replace newlyweds12=0 if marstat12==0 

gen 	newlyweds14=1 if marstat14==1 & marstat12==0 
replace newlyweds14=0 if marstat12==0 & marstat14==0
replace newlyweds14=0 if marstat12==1 


gen 	newlyweds16=1 if marstat16==1 & marstat14==0 
replace newlyweds16=0 if marstat16==0 & marstat14==0 & marstat12==0
replace newlyweds16=0 if marstat14==1 
replace newlyweds16=0 if marstat12==1 

misschk newlyweds12 newlyweds14 newlyweds16


forval i=12(2)16{
g 		marstay`i'=1 if newlyweds`i'==1 & livepa`i'==1
replace marstay`i'=0 if newlyweds`i'==0 
replace marstay`i'=0 if newlyweds`i'==1 & livepa`i'==0

g       marleave`i'=1 if newlyweds`i'==1 & livepa`i'==0
replace marleave`i'=0 if newlyweds`i'==0 
replace marleave`i'=0 if newlyweds`i'==1 & livepa`i'==1 
}


reshape long newlyweds marstat marstay marleave, i(pid) j(year)
*calculate proportion of married 
*calcuate age 
replace age=35 if age>35
replace age=20 if age<=20

*calculate hazard instead of proportions 
*convert to life table 
ltable age marstat , graph  // proportion of surviving 
ltable age marstay, graph

*infile age D Di lx a using https://data.princeton.edu/eco572/datasets/prestonBox41.dat, clear

keep age male marstat marstay marleave 

*count person-year 
bysort age: egen nmar=total(marstat)
bysort age: g n=_N
g nsingle=n- nmar

*number of married & stay at parental home
bysort age: egen nstay=total(marstay)
bysort age: egen nleave=total(marleave)

keep age nmar nsingle n nstay nleave  
duplicates drop 
rename n ppl

*count cumulative cases of survival  
bysort age: gen cummar=sum(nmar)
gen cumn=sum(ppl)
g sur=cumn[22-_n]

bysort age: gen cumstay=sum(nstay)
bysort age: gen cumleave=sum(nleave)

*calculate rates : incidence by exposure 
g q_mar=cummar/cumn
g q_stay=cumstay/cumn
g q_leave=cumleave/cumn

*prob of surviving 
g p_mar=(cumn-nmar)/cumn
g p_stay=(cumn-nstay)/cumn
g p_leave=(cumn-nleave)/cumn



tsset age 
twoway line q_mar age || line q_stay age || line q_leave age
twoway line p_mar age || line p_stay age || line p_leave age


*proportion of the status over age
foreach x of varlist newlyweds marstat marstay marleave {
qui: prop `x', over (age)
mat `x'=r(table)
mat list r(table)
mat p`x'= `x'[1,22..42]
mat list p`x'
}

drop _all 
mat C=pnewlyweds',pmarstay',pmarleave'
mat colnames C=Newlyweds Marry_stay Marry_leave
mat list C

*numlist "15/43 45"
numlist "15/35"
mat rownames C`i'=`r(numlist)'
mat list C 
svmat C, names(col)

foreach x in Newlyweds Marry_stay Marry_leave{
replace `x'= 100*`x'
}

gen Age=14+_n


grstyle init
grstyle set plain,
twoway (connected Newlyweds Age, lp(dash) m(oh))                 ///
       (connected Marry_stay Age, lp(dash_dot))                     ///
       (connected Marry_leave Age, lp(dash_dot_dot) m(d)) ,  ///
  legend(rows(1) forcesize pos(6)) xlab(15(2)35) ylab(0(10)50) ytit("% Respondents") xtitle(Age)

 graph save Graph "E:\Marriage\graphs\descriptive.gph"
 
 graph use  "E:\Marriage\graphs\descriptive.gph"
 graph save "${graphs}\descriptive.gph",  replace 
