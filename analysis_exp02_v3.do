no*Project : transition into first marriage & co-residency   
*Date : 12022018
*Task: covert wide into long format (use expand command instead of reshape), perpare for discrete-time event history analysis 
*============================================
//ssc install table1
//ssc install estout

clear
set more off 
capture log close 

*========load data/folders
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
global dir "C:\Users\wdhec\Desktop\Marriage"     // home 

*global datadir "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"  //office
*global datadir "W:\Marriage\CFPSrawdata_Chinese"                         // pri
global datadir "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese"    // home

global date "12242018"   // ddmmyy
global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"   

use "${datadir}\panel_1016.dta" , clear 


*====================analytical sample==================== 
*sample restriction : single age 20-40 alive until 2016
keep if in_10a==1            
keep if age>=20 & age<=40
keep if mar10==1           
drop if alivep_12hh==0 | alivep_14hh==0 | alivep_16hh==0 
drop if pids10>0 & pids10<.  //==> 2224 


*recode marital status: treat cohabitation as single , treat divorced as get married over the course of past 2yrs
* mar: 1.single 2.married 3.cohabitation 4.divorced 
foreach x of numlist 10 12 14 16 {
replace mar`x'=. if mar`x'<0
replace mar`x'=1 if mar`x'==3
replace mar`x'=2 if mar`x'==4 | mar`x'==5
tab mar`x' if in_`x'hh==1 ,m   
tab livepa`x' if in_`x'hh==1 , m
}
replace mar14=2 if mar12==2
replace mar16=2 if  mar14==2 | mar12==2 
tab mar16 if in_16hh==1,m  //152 still missing in wave 16 even if interviewed in 2016 hh 

*check: cannot be single after t if get married in t
* cannot be married at t if single at after t
assert mar14 !=1 & mar16 !=1 if mar12==2 
assert mar16 !=1 if mar14==2 | mar12==2
assert mar14 !=1 if mar12==2

assert mar12 !=2 if mar14==1 | mar16==1
assert mar14 !=2 if mar16==1



*Analysis of missing : define missing as missing from household survey 
misschk in_10hh in_12hh in_14hh  in_16hh, gen(miss)
encode misspattern, g(misspattern2)
g missing_inter=(misspattern2 ==2 | misspattern2==3 |misspattern2==4 | misspattern2==6) // N=555
g missing_perm=(misspattern2 ==1 | misspattern2==5| misspattern2==7)
g missing_not=(misspattern2==8)

misschk mar10 mar12 mar14 mar16


/*
Missing for |
      which |
 variables? |      Freq.     Percent        Cum.
------------+-----------------------------------
       _234 |        341        6.66        6.66
       _23_ |         72        1.41        8.06
       _2_4 |         75        1.46        9.53
       _2__ |        167        3.26       12.79
       __34 |        203        3.96       16.75
       __3_ |        200        3.90       20.65
       ___4 |        323        6.30       26.96
       ____ |      3,742       73.04      100.00
------------+-----------------------------------
      Total |      5,123      100.00

*/

*rename (in_10a in_12a in_14a in_16a) (in_10 in_12 in_14 in_16)
rename (in_10hh in_12hh in_14hh in_16hh) (in_10 in_12 in_14 in_16)   // use being interviewed in adult sample as the criteira for missing or in household sample?



*Define outcome: each wave, individuals are in these four mutually exclusive status
la def status 1 "single, live with pa" 2 "single, not live with pa"  3"married, not live with pa"  4"married, live with pa"

foreach x of numlist 10 12 14 16{
g       status`x'=1 if mar`x'==1 & livepa`x'==1       // single, live with pa
replace status`x'=2 if mar`x'==1 & livepa`x'==0       //single, not live with pa
replace status`x'=3 if mar`x'==2 & livepa`x'==0       //married, not live with pa
replace status`x'=4 if mar`x'==2 & livepa`x'==1       //married,  live with pa
la val  status`x' status
tab mar`x' if in_`x'==1 ,m
tab livepa`x' if in_`x'==1 ,m
tab status`x' if in_`x'==1 ,m
}

// check other dvs
* hukou status: ag=1 ; nonag=3  ; no hukou=5 ; not chinese =79 ; NA=-8
foreach x of numlist 10 12 14 16 {
*tab urban`x', m 

}

egen urban_chg= diff(urban10 urban12 urban14 urban16)  // no one changed their rural/ urban residency status
egen hukou_chg= diff (nonaghukou10 nonaghukou12 nonaghukou14 nonaghukou16)  // but hukou status has changed 
* how does one have not changed their rural /urban residency, but hukou status? 


/*
// for intermittant missing, impute status with prior wave

egen status_chg1014=diff(status10 status14)  
replace status12=status10 if  status_chg==1 & inlist(misspattern2,3,4)  // _2_4 , _2__ impute wave2 if wave10 wave14's status remain the same 
replace status12=status10 if inlist(misspattern2,3,4)
replace status14=status12 if inlist(misspattern2,6)  // __3_ impute wave2 if wave10 wave14's status remain the same 

replace status12=status10 if misspattern2==2   //_23_ impute 12 with 10 wave, 14 with 16wave
replace status14=status16 if misspattern2==2

//misschk status10 status12 status14 status16  // should not have intermittant missing in status 
//N5123
*/

* recode dvs
foreach x of numlist 10 12 14 16 {
replace migrant`x'_cross=. if migrant`x'_cross<0
g migrant`x'=(migrant`x'_cross==1)
}

keep pid status* mar10 mar12 mar14 mar16 livepa10 livepa12 livepa14 livepa16 atschool10 atschool12 atschool14 atschool16 atwork*    ///
	 age agesq male edu_fm nsib_alive hasbro nbro_alive_cor agefm_75 eduy10 eduy12 eduy14 eduy16 	 ///
	 alivef10 alivef12 alivef14 alivef16 alivem10 alivem12 alivem14 alivem16   		///
	 income10 income12 income14 income16 fincomeper* migrant10  migrant12  migrant14  migrant16     						///
	 fincome10 fincome12 fincome14 fincome16 fincomeper*  							 /// 
     house_owned* house_sqr* otherhh* nonaghukou* urban10 urban12 urban14 urban16  ///
	 familysize10 familysize12 familysize14 familysize16  houseasset10	houseasset12 houseasset14 houseasset16			///
	 region miss*  	 ///
     in_10 in_12 in_14 in_16


save "${datadir}\ehc_temp2.dta" ,replace 

*define exit wave 

use "${datadir}\ehc_temp2.dta" ,clear
*============case 1  starting state: single, live pa ; event: married & not live with pa ; other status : censored
*define left truncation as not being  single & live with pa at  the first wave 
g lft_tr=(status10 !=1)

local var "status mar alivef alivem livepa eduy atschool atwork income fincome house_owned house_sqr otherhh  houseasset urban nonaghukou fincomeper familysize migrant in_"
reshape long `var', i(pid) j(wave)


// adjust risk set for intermittant missing
by pid: drop if inlist(wave,12,14) & misspattern2==2   // drop gap
by pid: drop if inlist(wave, 12) & inlist(misspattern2, 3, 4)
by pid: drop if wave==14 & misspattern2==6


bysort pid wave: g fin1=sum(status !=1)==1 & sum(status[_n-1]==1)==0   // the first time observe status change : either change to other status , or lost-to-follow up 
egen event= min(cond(fin1==1, status,.)), by(pid)  // define event as the first observed non-single & livepa status 
by pid: replace event=1 if fin1[_N]==0  // remain single&live with pa if no change 
bysort pid: g fin2=sum(fin1==1)

// adjust risk set further

keep if fin2==0 | fin2==1   // keep waves that event has not occur & 1st wave when event is recored to be changed 
drop if event==. & fin1==1  // for those transitioned into missing, contribute only t-1 wave   // N=5373



sort pid wave
by pid: g py=_n

by pid :gen pycount=_N // #person-wave 
tab pycount 
tab pycount if py==1  



*working on predictors 
g lincome=log(income) if income>0
replace lincome=0 if income==0

g lfincome=log(fincome) if fincome>0
replace lfincome=0 if fincome==0

g lhouseasset=log(houseasset) if houseasset>0
replace lhouseasset=0 if houseasset==0


*for individuals who were completely followed up,lag one wave
sort pid wave
local dv "alivef alivem eduy atschool atwork lincome lfincome  house_owned house_sqr otherhh lhouseasset urban nonaghukou  familysize"
foreach x of local dv {
by pid : g `x'_lag = `x'[_n-1] 
replace `x'_lag=`x' if py==1  // first wave use first wave observation 
}

g marleave=(status==3)
g marstay=(status==4)

*========model==============
macro drop dv dvlag

global dv    "age agesq eduy     lincome     lfincome     lhouseasset        house_owned    house_sqr     otherhh      urban     nonaghukou     edu_fm familysize   agefm_75 nsib_alive hasbro     atwork i.region"
global dvlag "age agesq eduy_lag lincome_lag  lfincome_lag lhouseasset_lag   house_owned_lag house_sqr_lag otherhh_lag  urban_lag nonaghukou_lag edu_fm familysize_lag  agefm_75 nsib_alive hasbro atwork_lag atschool_lag i.region"

*marriage equation 
recode mar (1=0) (2=1)
logit mar $dvlag if male==0 , or
eststo  female_mar 
logit mar $dvlag  if male==1 , or
eststo male_mar

esttab female_mar male_mar using "$tables\logit_analysisexp02_v3_mar.rtf",   ///
      nonumbers mtitles("female_mar" "male_mar" )  eform  ci(%9.2f)  replace 

*rural urban difference
logit mar $dvlag if male==0 & urban==1 , or
eststo  female_mar_urban 
logit mar $dvlag  if male==1&  urban==1  , or
eststo male_mar_urban

logit mar $dvlag if male==0 & urban==0 , or
eststo  female_mar_rural 
logit mar $dvlag  if male==1 & urban==0  , or
eststo male_mar_rural
esttab female_mar_urban  male_mar_urban female_mar_rural male_mar_rural  using "$tables\logit_analysisexp02_v3_mar_ruralurban.rtf",   ///
      nonumbers mtitles("female_mar_urban " "male_mar_urban"  "female_mar_rural" "male_mar_rural")  eform  ci(%9.2f)  replace 




* move out family home, stay with family as competing risk 
drop if lft_tr==1  // discard all left truncated cases.

logit marleave $dvlag if male==0 , or
eststo  female_leave 
logit marleave $dvlag  if male==1 , or
eststo male_leave

esttab female_leave male_leave using "$tables\logit_analysisexp02_v3_leave.rtf",   ///
      nonumbers mtitles("Female_leave" "Male_leave" )  eform  ci(%9.2f)  replace 


* move out family home, stay with family as competing risk : rural / urban difference 
logit marleave $dvlag if male==0 & urban==1 , or
eststo  female_leave_urban
logit marleave $dvlag  if male==1 & urban==1, or
eststo male_leave_urban

logit marleave $dvlag if male==0 & urban==0 , or
eststo  female_leave_rural 
logit marleave $dvlag  if male==1 & urban==0, or
eststo male_leave_rural 

esttab female_leave_urban  male_leave_urban female_leave_rural male_leave_rural  using "$tables\logit_analysisexp02_v3_leaverural.rtf",   ///
      nonumbers mtitles("female_leave_urban" "male_leave_urban" "female_leave_rural" "male_leave_rural")  eform  ci(%9.2f)  replace 
	  
	  
* move out family home, stay with family as competing risk 
logit marstay $dvlag if male==0 , or
eststo  female_stay 
logit marstay $dvlag  if male==1 , or
eststo male_stay 

esttab female_stay  male_stay using "$tables\logit_analysisexp02_v3_stay.rtf",   ///
      nonumbers mtitles("female_stay" "male_stay" )  eform  ci(%9.2f)  replace 




erase "${datadir}\ehc_temp2.dta"
