*Project : transition into first marriage & co-residency   
*Date : 12022018
*Task: covert wide into long format, perpare for discrete-time event history analysis 
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


	 
*============longformat for discrete-time event history analysis================
use "${datadir}\panel_1016.dta" , clear 
*====================analytical sample==================== 

keep if in_10a==1           // restrict to 10 adult sample & alive to subseqent waves
keep if age>=20 & age<=40
keep if mar10==1           // universe : single in  adult 10survey  : N=4279
drop if alivep_12hh==0 | alivep_14hh==0 | alivep_16hh==0 // ==> N=4250



*Analysis of missing (dependent variables only)
* missing due to lost-to follow up 
misschk in_10a in_12a in_14a in_16a, gen (miss)
*12:N=1485;  14: N=1445  16: N=349

/*
Missing for |
      which |
 variables? |      Freq.     Percent        Cum.
------------+-----------------------------------
       _234 |        329       14.79       14.79
       _23_ |        111        4.99       19.78
       _2_4 |        114        5.13       24.91
       _2__ |        185        8.32       33.23
       __34 |        194        8.72       41.95
       __3_ |        145        6.52       48.47
       ___4 |        238       10.70       59.17
       ____ |        908       40.83      100.00
------------+-----------------------------------
      Total |      2,224      100.00
*/

*define intermittant missing (missing_inter)as missing in early waves, but picked up later. 
*define permnant missing as missing and not picked up in later waves 
encode misspattern, g(misspattern2)
g missing_inter=(misspattern2 ==2 | misspattern2==3 |misspattern2==4 | misspattern2==6) // N=555
g missing_perm=(misspattern2 ==1  | misspattern2==5| misspattern2==7)
g missing_not=(misspattern2==8)

*recode marital status: treat cohabitation as single , treat divorced as get married over the course of past 2yrs
* mar: 1.single 2.married 3.cohabitation 4.divorced 
foreach x of numlist 10 12 14 16 {
replace mar`x'=. if mar`x'<0
replace mar`x'=1 if mar`x'==3
replace mar`x'=2 if mar`x'==4
*tab mar`x' if in_`x'a==1 ,m 
}

replace mar14=2 if mar12==2
replace mar16=2 if  mar14==2 | mar12==2

assert mar14 !=1 & mar16 !=1 if mar12==2 
assert mar16 !=1 if mar14==2


rename (in_10a in_12a in_14a in_16a) (in_10 in_12 in_14 in_16)


foreach x of numlist 10 12 14 16 {
replace migrant`x'_cross=. if migrant`x'_cross<0
g migrant`x'=(migrant`x'_cross==1)
}


keep pid  mar10 mar12 mar14 mar16 livepa10 livepa12 livepa14 livepa16 atschool10 atschool12 atschool14 atschool16 atwork*   ///
	 age agesq male edu_fm nsib_alive hasbro agefm_75 eduy10 eduy12 eduy14 eduy16 	 ///
	 alivef10 alivef12 alivef14 alivef16 alivem10 alivem12 alivem14 alivem16   		///
	 income10 income12 income14 income16 fincomeper* migrant10  migrant12  migrant14  migrant16     						///
	 fincome10 fincome12 fincome14 fincome16 fincomeper*  							 /// 
     house_owned* house_sqr* otherhh* nonaghukou* urban10 urban12 urban14 urban16  ///
	 familysize10 familysize12 familysize14 familysize16  houseasset10	houseasset12 houseasset14 houseasset16			///
	 region misspattern misspattern2 missing_inter missing_perm missing_not  	 ///
     in_10 in_12 in_14 in_16

* missing not due to attrition

*log using "${logs}\missing_longform$date", text replace 
local var1 "mar alivef alivem livepa eduy atschool atwork income fincome house_owned house_sqr otherhh  houseasset urban nonaghukou fincomeper familysize migrant"
*local var2  "age male edufm nsib_alive hasbro agefm_75 region"
foreach y of local var1 {
foreach x of numlist 10 12 14 16 {
misschk `y'`x' if in_`x'==1
}
}
*log close 
* note 12/14/2018 : better not to use fincomeper as still many missings . 

local var1 "mar alivef alivem livepa eduy atschool atwork income fincome house_owned house_sqr otherhh otherhhsqm houseasset urban nonaghukou fincomeper familysize migrant"
reshape long `var1' in_, i(pid) j(wave)
		
save "${datadir}\ehc_temp.dta" ,replace 

use  "${datadir}\ehc_temp.dta" , replace 
keep pid wave in_ mar   misspattern2 


*define exit wave/ adjust risk set 
bysort pid wave: g fin=sum(mar==2)==1 & sum(mar[_n-1]==2)==0  // identify ealiest wave when marriage occur
gsort pid -wave
*by pid: replace fin= sum(mar<.)==1  & sum(mar[_n-1]<.)==0  // or last valid marital status 
bysort pid (wave): g spell=sum(fin)
by pid:g exclude=spell-fin
drop if exclude>=1     // drop person-waves after event occur/ missing
*drop fin spell exclude 


sort pid wave
by pid: g py=_n

by pid :gen pycount=_N // #person-wave 
tab pycount // N=6191 person-wave
tab pycount if py==1  


		
*========competing risk======== 
*A: marry & stay as event, marry & leave as competing risk (censored) 
*recode dependent variable

g        marleave=1 if  mar==2  & livepa==0  
replace  marleave=0 if  mar==2  & livepa==1
replace  marleave=0 if  mar==1    // single is also censored 

*B: marry & leave as event, marry & stay as competing risk 
g        marstay=1 if mar==2 & livepa==1
replace  marstay=0 if mar==2 & livepa==0
replace  marstay=0 if mar==1    // single is also censored 

tab marleave male
tab marstay  male


*==========predictors=================================
/* check number of changes in urban nonaghukou 
bysort pid wave : gen urban_chg=sum(urban != urban[_n-1] & _n!=1)  // # changes in urban : nochange
bysort pid wave : gen nonaghukou_chg=sum(nonaghukou != nonaghukou[_n-1] & _n!=1)  // # changes in hukou: no change ??
drop urban_chg nonaghukou_chg
*/

*working on predictors 
g lincome=log(income) if income>0
replace lincome=0 if income==0

g lfincome=log(fincome) if fincome>0
replace lfincome=0 if fincome==0

g lhouseasset=log(houseasset) if houseasset>0
replace lhouseasset=0 if houseasset==0

g incomeshare=100*income/fincome if fincome>0 & fincome<.

*for individuals who were completely followed up,lag one wave
sort pid wave
local dv "alivef alivem eduy atschool atwork lincome lfincome incomeshare house_owned house_sqr otherhh lhouseasset urban nonaghukou  familysize"
foreach x of local dv {
by pid : g `x'_lag = `x'[_n-1] 
replace `x'_lag=`x' if py==1
}

*========model==============
macro drop dv dvlag
drop if misspattern2==1 // drop those who only interviewed once 

*global dv "age agesq eduy atschool atwork lincome edu_fm lfincome house_owned house_sqr otherhh lhouseasset urban nonaghukou familysize alivef alivem agefm_75 nsib_alive hasbro"
*global dvlag "age agesq eduy_lag atschool_lag atwork_lag incomeshare_lag lincome_lag edu_fm lfincome_lag house_owned_lag house_sqr_lag otherhh_lag lhouseasset_lag urban_lag nonaghukou_lag familysize_lag alivef_lag alivem_lag agefm_75 nsib_alive hasbro i.region"

global dv    "age agesq eduy     lincome     atschool     atwork     lfincome     lhouseasset        house_owned    house_sqr     otherhh      urban     nonaghukou     edu_fm familysize     alivef    alivem     agefm_75 nsib_alive hasbro i.region"
global dvlag "age agesq eduy_lag lincome_lag  lfincome_lag lhouseasset_lag   house_owned_lag house_sqr_lag otherhh_lag  urban_lag nonaghukou_lag edu_fm familysize_lag alivef_lag alivem_lag agefm_75 nsib_alive hasbro i.region"


* move out family home, stay with family as competing risk 
logit marleave $dv if male==0 , or
eststo  female_leave 
logit marleave $dv  if male==1 , or
eststo male_leave

*stay , move out as competing risk 
logit marstay $dv if male==0 , or
eststo  female_stay

logit marstay $dv if male==1, or
eststo male_stay

esttab female_leave male_leave female_stay male_stay  using "$tables\logit_nolag.rtf",   ///
      nonumbers mtitles("Female_leave" "Male_leave" "female_stay" "male_stay")  eform  ci(%9.2f)  replace 

	  
*lag var
* move out family home, stay with family as competing risk 
logit marleave $dvlag if male==0 , or
eststo  female_leave 
logit marleave $dvlag if male==1 , or
eststo male_leave

*stay , move out as competing risk 
logit marstay $dvlag if male==0 , or
eststo  female_stay

logit marstay $dvlag if male==1, or
eststo male_stay

esttab female_leave male_leave female_stay male_stay  using "$tables\elogit_lag_$date.rtf",   ///
      nonumbers mtitles("Female_leave" "Male_leave" "female_stay" "male_stay")  eform  ci(%9.2f)  replace 

	  
	  
	  

erase "$datadir\prepare.dta"  //erase prepare.dta saved in analysis_exp01.do 
erase  "${datadir}\ehc_temp.dta" 
