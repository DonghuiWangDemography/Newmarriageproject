*Project : transition into first marriage & co-residency   
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

global date "12142018"   // ddmmyy
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


*Analysis of missing : define missing as missing from household survey 
* missing due to lost-to follow up 
*misschk in_10a in_12a in_14a in_16a, gen (miss)
misschk in_10hh in_12hh in_14hh  in_16hh, gen(miss)
* alternatively use missing info in marriage 
//misschk mar10 mar12 mar14 mar16, gen (miss)
encode misspattern, g(misspattern2)
g missing_inter=(misspattern2 ==2 | misspattern2==3 |misspattern2==4 | misspattern2==6) // N=555
g missing_perm=(misspattern2 ==1 | misspattern2==5| misspattern2==7)
g missing_not=(misspattern2==8)


rename (in_10a in_12a in_14a in_16a) (in_10 in_12 in_14 in_16)

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

tab mar16 if in_16hh==1,m  //152 missing in wave 16 even if interviewed in 2016 hh 


/* chcek: cannot be single after t if get married in t
* cannot be married at t if single at after t
assert mar14 !=1 & mar16 !=1 if mar12==2 
assert mar16 !=1 if mar14==2 | mar12==2
assert mar14 !=1 if mar12==2

assert mar12 !=2 if mar14==1 | mar16==1
assert mar14 !=2 if mar16==1
*/

*define duration  
*for no attrition  
g	    fin=2 if mar12==2 & misspattern2==8   //contribute to 2 pw if get married in wave12 
replace fin=3 if mar14==2 & (mar12==1 | mar12==.) & misspattern2==8  //contribute to 3 pw if get married in wave14 
replace fin=4 if mar16==2 & (mar14==1 | mar14==.) & misspattern2==8  //contribute to 4 pw if get married in wave16 
replace fin=4 if mar16==1 & (mar14==1 | mar14==.) & misspattern2==8  //contribute to 4 pw if censored

*missing due to attrition 
replace fin=1 if misspattern2==1     // if  completely missing in 12 14, 16, contribute one pw only 
replace fin=2 if misspattern2==5    // if last seen in wave12  contribute 2 pw   __34

replace fin=3 if inlist(misspattern2, 3, 7)    // if last seen in w14  : _2_4 or ___4  contribute 3 person-wave
replace fin=2 if inlist(misspattern2, 3, 7) & mar12==2   // if last seen in w14 , but get married in wave 12, contribute 2 pw

replace fin=4 if inlist(misspattern2, 2, 4, 6)  // last seen in w16 , contribute 4 waves 
replace fin=2 if inlist(misspattern2, 2, 4, 6) & mar12==2        // last seen in w16 but married in 12， contribute 2 pw
replace fin=3 if inlist(misspattern2, 2, 4, 6) & (mar14==2 & mar12 !=2) // last seen in w16 but married in 14， contribute 2 pw

tab fin,m  

*recode event indicator 
g       mar=1 if  mar12==2 | mar14==2 | mar16==2             // if get married at any wave 
replace mar=0 if (mar12==1 | mar12==.) & fin==2             // single or missing if last seen as single or missing 
replace mar=0 if (mar14==1 | mar14==.) & fin==3
replace mar=0 if (mar16==1 | mar16==.) & fin==4 
replace mar=0 if misspattern2==1  // single if only in wave10 

* not censored : if get married & time known . censored : single or exisit time unkonwn (aka attrition)
g 		censor=0 if mar==1
replace censor=1 if mar==0

*competing risk 

g       marleave=1 if mar12 ==2 & livepa12==1 & fin==2
replace marleave=1 if mar14 ==2 & livepa14==1 & fin==3 
replace marleave=1 if mar16 ==2 & livepa16==1 & fin==4
replace marleave=0 if marleave==.

g       marstay=1 if mar12 ==2 & livepa12==0 & fin==2
replace marstay=1 if mar14 ==2 & livepa14==0 & fin==3 
replace marstay=1 if mar16 ==2 & livepa16==0 & fin==4
replace marstay=0 if marstay==. 



/*stablility of living arragements 
egen live_chg=diff(livepa10 livepa12 livepa14 livepa16)  //461 never changed 
egen hukou_chg=diff(nonaghukou10 nonaghukou12 nonaghukou14 nonaghukou16)  //1050 never changed 
egen urban_chg= diff(urban10 urban12 urban14 urban16)
*/

*===========work on dvs: lag predictors by one-wave 
*recode some dvs
foreach x of numlist 10 12 14 16 {
replace migrant`x'_cross=. if migrant`x'_cross<0
g migrant`x'=(migrant`x'_cross==1)
}

rename (immobile_child_10a parstay_child_10a everwork_10a) (immobile_child parstay_child everwork)



local var "alivef alivem eduy atschool atwork income fincome house_owned house_sqr otherhh houseasset urban nonaghukou migrant fincomeper familysize"
foreach x of local var {
g        `x'_1= `x'10   // 10 -12 wave , uses wave10 predictor 

g 		 `x'_2=`x'12   //12-14 spell, use wave12 predcitor 
replace  `x'_2=`x'10 if `x'_2==. & `x'10 ~=.  // if missing, use wave10 

g 		`x'_3=`x'14  //14-16 spell, use wave14
replace `x'_3=`x'12 if `x'_3==. & `x'12 ~=.   // if missing use wave12 predictor
replace `x'_3=`x'10 if `x'_3==. & `x'10 ~=.  // if still missing , use wave10 predictor
}

*Note: the coding of marial status / living arragement differs from that predictors aka nolag 
local var "mar livepa"
foreach x of local var {
clonevar `x'_1=`x'12
clonevar `x'_2=`x'14
clonevar `x'_3=`x'16
}

*livepa lag
g livepa_lag_1=livepa10
g livepa_lag_2=livepa12
g livepa_lag_3=livepa14



keep pid fid fin mar marleave marstay status censor male age agesq male edu_fm nsib_alive hasbro agefm_75 region      ///
	alivef_1 alivef_2 alivef_3  alivem_1 alivem_2 alivem_3 eduy_1 eduy_2 eduy_3 atschool_1 atschool_2 atschool_3  atwork_1 atwork_2 atwork_3   ///
	income_1 income_2 income_3  fincome_1 fincome_2 fincome_3  house_owned_1 house_owned_2 house_owned_3  house_sqr_1 house_sqr_2 house_sqr_3  otherhh_1 otherhh_2 otherhh_3 ///
	houseasset_1 houseasset_2 houseasset_3  urban_1 urban_2 urban_3  nonaghukou_1 nonaghukou_2 nonaghukou_3 familysize_1 familysize_2 familysize_3  in_10 in_12 in_14 in_16 misspattern2  ///
	livepa10 livepa12 livepa14 livepa16 mar12 mar14 mar16 migrant_1 migrant_2 migrant_3  livepa_lag_1 livepa_lag_2  livepa_lag_3 ///
	immobile_child parstay_child everwork  agef75 agem75

*===============person-episode data*=============== 

*stset fin , failure (status==1)  id(pid)  exit(censor==1)  // 6504 pw the same as the effect of expand
expand fin     

bysort pid: g spell=_n
by pid :gen pycount=_N //   N=6132 pw  #person-wave 
tab pycount 
tab pycount if spell==1  


local var "alivef alivem eduy atschool atwork income fincome house_owned house_sqr otherhh  houseasset urban nonaghukou migrant familysize livepa_lag"
foreach x of local var {
bysort fid: g       `x'= `x'_1 if spell==1 & spell==2  // if contribute only one pw, use wave 1 info ; if contribute to two pw, use w10 info
bysort fid: replace `x'= `x'_2 if spell==3
bysort fid: replace `x'= `x'_3 if spell==4
}

keep pid fin male mar marleave marstay status censor age agesq alivef alivem eduy atschool atwork income fincome house_owned house_sqr otherhh  houseasset urban nonaghukou familysize edu_fm agefm_75 nsib_alive hasbro region misspattern2  ///
	livepa10 livepa12 livepa14 livepa16 mar12 mar14 mar16 immobile_child parstay_child everwork migrant livepa_lag spell

g lincome=log(income) if income>0
replace lincome=0 if income==0

g lhouseasset=log(houseasset) if houseasset>0
replace lhouseasset=0 if houseasset==0

g lfincome=log(fincome) if fincome>0
replace lfincome=0 if fincome==0

* copied from D. Schneider (2011 AJS):To take the natural log of net worth, first take the absolute value of the measure, then add a small positive constant
*(to retain the zero values), take the natural log, and then multiply the cases that orig- inally had negative values by -1.




* use age spline 
egen agegroup=cut(age), at(19,25, 30, 35, 41)
*========model==============
macro drop dv dv2 dv3
*model tested
*global dv "age agesq eduy lincome lfincome atschool atwork lhouseasset  house_owned  house_sqr otherhh  urban nonaghukou  edu_fm familysize  agefm_75 nsib_alive hasbro i.region"
*global dv "age agesq eduy livepa_lag lincome  lfincome atschool  house_owned  house_sqr otherhh  urban nonaghukou migrant immobile_child parstay_child  edu_fm familysize  agefm_75 nsib_alive hasbro i.region "
*global dv "age agesq  eduy livepa_lag lincome  lfincome houseasset  house_owned  house_sqr otherhh  urban nonaghukou migrant immobile_child parstay_child  edu_fm familysize  agefm_75 nsib_alive hasbro i.region "
*global dv "age agesq i.eduy c.age#i.eduy c.agesq#i.eduy lincome lfincome lhouseasset house_owned  house_sqr otherhh urban nonaghukou edu_fm familysize agefm_75 nsib_alive hasbro"

global dv "age agesq eduy lincome lfincome lhouseasset house_owned house_sqr otherhh urban nonaghukou edu_fm familysize nsib_alive hasbro migrant i.spell i.region"
qui: logit mar $dv if male==0 , or
eststo  female_mar
qui: logit mar $dv  if male==1 , or
eststo male_mar

esttab female_mar male_mar using "$tables\ehc_mar.rtf",   ///
      nonumbers mtitles("Female_mar" "Male_mar")  eform  ci(%9.2f)  replace 


*global dv2 "age agesq  lincome lfincome atschool atwork  house_owned  house_sqr otherhh urban i.nonaghukou##c.eduy immobile_child parstay_child  edu_fm familysize  agefm_75 nsib_alive hasbro i.region"
*global dv2 "age agesq  lincome i.nonaghukou##c.lfincome atschool atwork  house_owned  house_sqr otherhh urban immobile_child parstay_child  edu_fm familysize nsib_alive hasbro i.region"


qui: logit mar $dv if male==0 & urban==1, or
eststo  female_mar_urban
qui: logit mar $dv if male==1 & urban==1, or
eststo male_mar_urban
qui: logit mar $dv if male==0 & urban==0, or
eststo  female_mar_rural
qui: logit mar $dv if male==1 & urban==0, or
eststo  male_mar_rural

esttab female_mar_urban  male_mar_urban female_mar_rural  male_mar_rural using "$tables\logit_mar_rural.rtf",   ///
      nonumbers mtitles("female_mar_urban" "male_mar_urban"  "female_mar_rural" "male_mar_rural")  eform  ci(%9.2f) noomitted  replace 

* marriage &  move out  
global dv2 "age agesq eduy livepa_lag lincome lfincome lhouseasset house_owned house_sqr otherhh urban nonaghukou edu_fm familysize nsib_alive hasbro i.region"
	  
qui: logit marleave $dv2 if male==0 & urban==1, or
eststo  female_marleave_urban
qui: logit marleave $dv2 if male==1 & urban==1, or
eststo male_marleave_urban
qui: logit marleave $dv2 if male==0 & urban==0, or
eststo  female_marleave_rural
qui: logit marleave $dv2 if male==1 & urban==0, or
eststo  male_marleave_rural

esttab female_marleave_urban  male_marleave_urban female_marleave_rural  male_marleave_rural using "$tables\logit_marleave_rural.rtf",   ///
      nonumbers mtitles("female_marleave_urban" "male_marleave_urban"  "female_marleave_rural" "male_marleave_rural")  eform  ci(%9.2f) noomitted  replace 
	  
	
*look at those who live in the parental home prior to marriage 

global dv3 "age agesq eduy lincome lfincome lhouseasset house_owned house_sqr otherhh  nonaghukou edu_fm familysize nsib_alive hasbro migrant i.region"	  
qui: logit marleave $dv3 if male==0  & urban==1 & livepa_lag==1 , or
eststo  female_leave_urban 
qui: logit marleave $dv3  if male==1 & urban==1 & livepa_lag==1 , or
eststo male_leave_urban 
qui: logit marleave $dv3  if male==0 & urban==0 & livepa_lag==1 , or
eststo female_leave_rural 
qui: logit marleave $dv3  if male==1 & urban==0 & livepa_lag==1 , or
eststo male_leave_rural


esttab female_leave_urban  male_leave_urban  female_leave_rural male_leave_rural using "$tables\logit_leave_ruralurban.rtf",   ///
      nonumbers mtitles("female_leave_urban" "male_leave_urban"  "female_leave_rural" "male_leave_rural")  eform  ci(%9.2f)  replace 

	  
qui: logit marleave $dv if male==0  & livepa_lag==1 , or
eststo  female_leave 
qui: logit marleave $dv  if male==1 & livepa_lag==1 , or
eststo male_leave

esttab female_leave male_leave using "$tables\logit_leave.rtf",   ///
      nonumbers mtitles("Female_leave" "Male_leave")  eform  ci(%9.2f)  replace 
	  
	  
logit marstay $dv if male==0  & livepa_lag==1 , or
eststo  female_stay
logit marstay $dv  if male==1 & livepa_lag==1 , or
eststo male_stay

esttab female_stay male_stay using "$tables\logit_stay_alter.rtf",   ///
      nonumbers mtitles("female_stay" "male_stay")  eform  ci(%9.2f)  replace 


*rural/urban differences 

logit marstay $dv if male==0 & urban==1 , or
eststo  female_stay_urban
logit marstay $dv  if male==1 & urban==1  , or
eststo male_stay_urban 

logit marstay $dv if male==0 & urban==0 , or
eststo  female_stay_rural
logit marstay $dv  if male==1 & urban==0  , or
eststo male_stay_rural


esttab female_stay_urban male_stay_urban  female_stay_rural male_stay_rural using "$tables\logit_stay_ruralurban.rtf",   ///
      nonumbers mtitles("female_stay" "male_stay")  eform  ci(%9.2f)  replace 



	  // still less educated women are more likely to stay , also less educated men are also likely to stay 
