*Project : transition into first marriage & co-residency   
*Date created: 01/11/2019
*Task:re-code var without EHC so that var 2011=var2010, var2013=var2012, var2015=var2014

clear all 
clear matrix 
set more off 
capture log close 

global date "01282019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

sysdir
cfps // load cfps data (cfps.ado)


// merge time-invariant dataset with time varying data

use "${datadir}\work_EHC2.dta", clear
merge 1:1 pid using "${datadir}\EHC_edu.dta", nogen
merge 1:1 pid using "${datadir}\panel_1016.dta", keep(master match) nogen
// the reason for so many non-match is bx panel_1016 also include hh survey  

*====================analytical sample==================== 
*sample restriction 
keep if in_10a==1            
*keep if age>=20 & age<=40
*keep if age==18
keep if age>=18 & age<=35
*keep if mar10==1 
keep if married2010==0        
drop if alivep_12hh==0 | alivep_14hh==0 | alivep_16hh==0 
drop if pids10>0 & pids10<.  // single, therefore should not have valid spouse id =>100 observation dropped 


misschk in_12a in_14a in_16a, gen(m)
encode mpattern, g(mpattern2)

misschk married201* // no missing values in intial marriage variable, which is incorrect 
// adjust marriage value for attrition 
forval i=2011/2016{
replace married`i'=. if mpattern2==1  // missing in 12, 14 16 wave : only married2010 known. 
}

forval i=2013/2016{
replace married`i'=. if mpattern2==5 // missing in 14, 16 wave: 2010,2011, 2012 known 
}

forval i=2015/2016{
replace married`i'=. if mpattern2==7   // 2011-2014 known 
}

drop edu2010_10a edu2010_t1_best_10a edu2012_12a
misschk edu2010 edu2011 edu2012 edu2013  edu2014 edu2015 edu2016
// eudcation is fine 

// missing in inwork mainly due to attrition 
misschk inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016 if mpattern2==1  // missing 12 wave :  524 missing
misschk inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016 if mpattern2==5  // missing 14, 16wave : 307 missing
misschk inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016 if mpattern2==7  // missing 16 wave : 449 missing
* there's nothing to do with these missing

forval i=1/7 {
*misschk inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016 if mpattern2==`i'
misschk mcadj2010 mcadj2011 mcadj2012 mcadj2013 mcadj2014 mcadj2015 mcadj2016 if mpattern2==`i'
}


misschk mcadj2010 mcadj2011 mcadj2012 mcadj2013 mcadj2014 mcadj2015 mcadj2016, gen(ocm)
encode ocmpattern, g(ocmp)

// still many missings in occupation. Why ?



// recode occupational category so that to create a new var: occupation of starting a job [until it hits antoher occupation].

forval i=2010/2016 {

gen oc`i'= int(mcadj`i'/10000) if mcadj`i'>0 
replace oc`i'=7 if oc`i'==8 |oc`i'==9 // military and others 
replace oc`i'=8 if oc`i'==. & inwork`i'==1

la def occup 1 "manager,government official" 2 "professional" 3"clerk" 4"business professional" 5"Agricultural personnel" 6"manufacture" 7"others"  ///
		     8 "occuaption missing(but working)", modify
la val oc`i' occup		 
}

// how stable is the urban reisdency status ?
tab urban10 urban12 if in_10a==1 & in_12a==1,m
tab urban12 urban14 if in_12a==1 & in_14a==1,m
tab urban14 urban16 if in_14a==1 & in_16a==1,m

*egen ud=diff(urban10 urban12 urban14 urban16) if mpattern2==8

*tab ud

*=> urban residency does not change at all. can safely treat as a time-invariant variable

tab nonaghukou10 nonaghukou12 if in_10a==1 & in_12a==1,m
tab nonaghukou12 nonaghukou14 if in_12a==1 & in_14a==1,m
tab nonaghukou14 nonaghukou16 if in_14a==1 & in_16a==1,m

*=>some variations in hukou status, nonaghukou is a time-varying variable


rename own_p_*hh2 own_p_*a

local var "livepa alivef alivem otherhh house_sqr nonaghukou fincomeper houseasset migrant house_owned own_p_"
foreach x of local var {

forval i=10(2)16{
rename `x'`i' `x'20`i'
}
clonevar `x'2011=`x'2012
clonevar `x'2013=`x'2014
clonevar `x'2015=`x'2016
}

forval i=10(2)16 {
rename in_`i'a in_20`i'
}
clonevar in_2011=in_2012
clonevar in_2013=in_2014
clonevar in_2015=in_2016

forval i=2010/2016 {
tab livepa`i' if in_`i'==1 ,m  // no missing in living arragement 
*tab house_sqr`i' if in_`i'==1,m
}


// how many get married 
egen married=anymatch(married201*), value(1)

log using "${logs}\[desc]$date}", text replace 
local var "married inwork  edu livepa alivef alivem otherhh house_sqr nonaghukou houseasset fincomeper migrant house_owned own_p_"
foreach x of local var {
forval i=2010/2016 {
tab `x'`i' if in_`i'==1 ,m 
}
}
log close


// descriptives by rural urban
* marry within family vs outside family 
forval i=2010/2016{
g marstay`i'=.
g marleave`i'=.
}

log using "${logs}\[dv_dis]$date}", text replace 
forval i=2010/2016 {
replace marstay`i'=(married`i'==1 & livepa`i'==1) 
replace marleave`i'=(married`i'==1 & livepa`i'==0) 
tab married`i' urban10, m
tab marstay`i' urban10,m
tab marleave`i' urban10, m
}
log close

*list  married2012 marstay2012 marleave2012 if marstay2012 !=1 &  marleave2012 !=1

keep pid married201* livepa201* otherhh201* house_sqr201*  nonaghukou201* migrant201* fincomeper201*   ///
 	 inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016   ///
	 own_p_* house_owned*  oc201* edu201* alivef201* alivem201*                     ///    
	 age agesq male edu_fm nsib_alive hasbro nbro_alive agefm_75 birthy_best urban10 region mpattern2

local var "livepa alivef alivem otherhh house_sqr nonaghukou fincomeper migrant house_owned own_p_"
reshape long married inwork oc edu `var', i(pid) j(year)

// identify duration 
drop if married==.  // drop attrition 
bysort pid year: g first=sum(married==1)==1 & sum(married[_n-1]==0)==0  // identify ealiest wave when marriage occur
bysort pid (year): g sf=sum(first)
drop if sf >1 

by pid: egen status=max(married)

*drop marstay marleave
*tab mpattern2 livepa,m
g marstay=.
g marleave=.

replace marstay=1 if livepa==1 & married==1
replace marstay=0 if livepa==0 & married==1
replace marstay=0 if married==0

replace marleave=1 if livepa==0 & married==1
replace marleave=0 if livepa==1 & married==1
replace marleave=0 if married==0



// life table graph 
/*
g agest=year-(2010-age)
stset agest, id(pid) failure(married==1)
sts graph 

*sts graph  if urban10==0, ha  by(male) xlabel (0 "18" 10"28" 20"38"  30"48" 40"48") xtitle("Age") 
egen gr=group(male urban10)
la def gr 1"rural female" 2"urban female" 3"rural male" 4"urban male"
la val gr gr 

sts graph , ha  by(gr) xtitle("Age") 

*/
g alivefm=(alivef==1 | alivem==1)
replace alivefm=. if alivef==. & alivem==.

// time-varying covariates, lag t-1 yr

recode edu (1/2=1 "primary or less") (3=2 "middle school") (4=3 "high school") (5/8=4 "college and above"),  ///
       gen(edulevel)
g pfinc=log(fincomeper) if fincomeper>0
replace pfinc=0 if fincomeper==0

	  
//drop L*
local var "inwork edulevel otherhh oc alivefm house_sqr nonaghukou livepa pfinc migrant house_owned own_p_"
foreach x of local var{
bysort pid (year): g L`x'=`x'[_n-1]
}

drop if year==2010  // drop 2010 

bysort pid: g spell=_n
by pid :gen pycount=_N 
tab pycount 
tab pycount if spell==1  


*list year inwork Linwork  Ledu Lotherhh Loc Lnonaghukou in 1/700, sepby(pid)

* cross tab event and year 
tab year married , row


// re-code educatioal and occupation category 
*recode edu_fm (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22)
*drop edufm
recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8)
recode edu_fm (1/2=1 "primary or less") (3=2 "middle school") (4/8=3 "high school and above"), gen(edufm)

rename Lown_p_ Lown_p
*g lhouseasset=log(houseasset) if houseasset>0
*replace lhouseasset=0 if houseasset==0


* descriptives : marstay marleave by urbanicity and gender 
foreach x of varlist married marleave marstay {
display "==>urban"
tab `x' male if urban==1
display "==>rural"
tab `x' male if urban==0
}

egen gr=group(male urban10)
la def gr 1"rural female" 2"urban female" 3"rural male" 4"urban male"
la val gr gr 

table1, vars(married bin\ marleave bin\ marstay bin \   ///
            age conts\ edulevel cat \ inwork bin \ otherhh bin\ nonaghukou bin\ edufm cat\ livepa bin )  ///
        by (gr) format(%2.1f) 
		
		
//Analysis: male female 
* var tried : Lpfinc  
*global dv "age agesq  i.Ledu Linwork  Lotherhh Lnonaghukou  Llivepa Lmigrant i.edufm  hasbro i.region i.year"
*global dv "age agesq  i.Ledu Linwork   Lown_p Lnonaghukou  Llivepa Lmigrant edu_fm  hasbro i.region i.year"
*global dv "age agesq  i.Ledulevel Linwork  Lotherhh Lnonaghukou  Llivepa  i.edufm  nsib_alive Lalivefm i.region i.year"
*note oc and inwork cannot put together
global dv "age agesq  i.Ledulevel Linwork  Lotherhh Lnonaghukou  Llivepa  i.edufm  nsib_alive Lalivefm i.region i.year"

*global dv "age agesq  i.Ledulevel i.year"


qui: logit married $dv if male==0 
eststo  female_mar
qui: logit married $dv  if male==1 
eststo male_mar

*esttab female_mar male_mar using "$tables\ehc_mar.rtf",   ///
*      nonumbers mtitles("Female_mar" "Male_mar")  eform  ci(%9.2f)  replace 
esttab female_mar male_mar using "$tables\ehc_mar2.rtf",   ///
      nonumbers mtitles("Female_mar" "Male_mar") eform   ci(%9.2f)  replace 

	  
// breakdown by urban rural 
qui: logit married $dv if male==0 & urban==1, or
eststo  female_mar_urban
qui: logit married $dv if male==1 & urban==1, or
eststo male_mar_urban

qui: logit married $dv if male==0 & urban==0, or
eststo  female_mar_rural
qui: logit married $dv if male==1 & urban==0, or
eststo  male_mar_rural

esttab   male_mar_urban  male_mar_rural female_mar_urban female_mar_rural  using "$tables\logit_mar_rural.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 


*esttab female_mar_urban  male_mar_urban f0emale_mar_rural  male_mar_rural using "$tables\logit_mar_rural.rtf",   ///
*      nonumbers mtitles("female_mar_urban" "male_mar_urban"  "female_mar_rural" "male_mar_rural")  eform  ci(%9.2f) noomitted  replace 

*===========competing risk=========================

qui: logit marstay $dv if male==0 
eststo  female_stay
qui: logit marstay $dv  if male==1 
eststo male_stay
esttab female_stay male_stay using "$tables\ehc_mar2.rtf",   ///
      nonumbers mtitles eform   ci(%9.2f)  replace 

qui: logit marleave $dv if male==0 
eststo  female_leave
qui: logit marleave $dv  if male==1 
eststo male_leave


*esttab female_leave male_leave using "$tables\ehc_mar2.rtf",   ///
*      nonumbers mtitles eform   ci(%9.2f)  replace 	  
	  
esttab female_stay male_stay female_leave male_leave female_mar male_mar using "$tables\ehc_competing.rtf",   ///
      nonumbers mtitles eform   ci(%9.2f)  replace 	  
	  
*=========rural urban differences=========================
*stay , urban
qui: logit marstay $dv if male==0 & urban==1, or
eststo  female_stay_urban
qui: logit marstay $dv if male==1 & urban==1, or
eststo male_stay_urban

*stay , rural
 logit marstay $dv if male==0 & urban==0, or
eststo  female_stay_rural
qui: logit marstay $dv if male==1 & urban==0, or
eststo  male_stay_rural

*Llivepa predict failure perfectly for rural female.
tab  Llivepa marstay if marstay !=. & Llivepa !=. & male==0 & urban==0

*leave , urban  
qui: logit marleave $dv if male==0 & urban==1, or
eststo  female_leave_urban
qui: logit marleave $dv if male==1 & urban==1, or
eststo male_leave_urban

*leave , rural   
qui: logit marleave $dv if male==0 & urban==0, or
eststo  female_leave_rural
qui: logit marstay $dv if male==1 & urban==0, or
eststo  male_leave_rural


* stay, rural urban comparison 
esttab  male_stay_urban male_stay_rural  female_stay_urban  female_stay_rural     using "$tables\logit_stay.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 

* leave, rural urban comparison 
esttab male_leave_urban  male_leave_rural female_leave_urban female_leave_rural using "$tables\logit_leave.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 	  

* male 
esttab  male_stay_urban male_stay_rural  male_leave_urban  male_leave_rural  using "$tables\logit_male.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 
	  
*female 
esttab  female_stay_urban female_stay_rural  female_leave_urban  female_leave_rural  using "$tables\logit_female.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 
	  
