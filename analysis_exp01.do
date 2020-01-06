*Project : transition into first marriage & co-residency   
*Date : 12022018
*Task: code iv, explorative analysis 
*============================================
//ssc install table1
//ssc install estout
//ssc install stcompet

clear
set more off 
capture log close 
set matsize 800   // 800 for IC

*========load data/folders
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*lobal dir "C:\Users\wdhec\Desktop\Marriage"     // home 

global datadir "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"  //office
*global datadir "W:\Marriage\CFPSrawdata_Chinese"                         // pri
*global datadir "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese"    // home

global date "12122018"   // ddmmyy
global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"   
*log using "${logs}\[ivcode]$date}", text replace 

use "${datadir}\panel_1016.dta" , clear 


*====================analytical sample==================== 

keep if in_10a==1           // restrict to 10 adult sample & alive to subseqent waves
keep if age>=20 & age<=40
keep if mar10==1           // universe : single in  adult 10survey  : N=4279
drop if alivep_12hh==0 | alivep_14hh==0 | alivep_16hh==0 // ==> N=4250
drop if pids10>0 & pids10<.  //==> 4217 remove those single in 10 but has spouse id 

* if restrict to age 30,N=1435


rename (in_10a in_12a in_14a in_16a) (in_10 in_12 in_14 in_16)

*recode marital status so that : if cohabit at wave t, treat as single; if divorced as  married. 
* mar: 1.single 2.married 3.cohabitation 4.divorced 
foreach x of numlist 10 12 14 16 {
replace mar`x'=. if mar`x'<0
replace mar`x'=1 if mar`x'==3
replace mar`x'=2 if mar`x'==4
tab mar`x' if in_`x'==1 ,m 
tab livepa`x' if in_`x'==1 ,m 
}

* missing patterns of mar and livepa : no missing if not due to attrition 
* missing was imputed for mar
* what about missing living arragement due to attrition ? 

misschk in_10 in_12 in_14 in_16, gen (miss)
encode misspattern, g(misspattern2)
misschk mar12 mar14        if misspattern2==2
misschk livepa12 livepa14  if misspattern2==2



*1. married in subsequent waves Vs Single
g       mar=1 if mar12==2 | mar14==2 | mar16==2
replace mar=0 if mar==. & mar12==1  &  mar14==1 & mar16==1
tab mar,m  // 514 missing 



*2. married & not living with parents 
g        marleave=1 if mar12==2  & livepa12==0
replace  marleave=1 if mar14==2  & livepa14==0
replace  marleave=1 if mar16==2  & livepa16==0

replace  marleave=0 if mar12==2  & livepa12==1
replace  marleave=0 if mar14==2  & livepa14==1
replace  marleave=0 if mar16==2  & livepa16==1

tab marleave,m
tab marleave if mar==1, m

*3. married & stay with parents 

// create combinations of marital status and living arragement 
la def c 1"single, live with pa"  2 "single, not live with pa" 3 "married, live with pa" 4 "married, not live with pa"
foreach x of numlist 10 12 14 16 {
g       combine`x'=1 if mar`x'== 1 & livepa`x'==1 & in_`x'==1 
replace combine`x'=2 if mar`x'== 1 & livepa`x'==0 & in_`x'==1 
replace combine`x'=3 if mar`x'== 2 & livepa`x'==1 & in_`x'==1 
replace combine`x'=4 if mar`x'== 2 & livepa`x'==0 & in_`x'==1 
la val  combine`x' c
tab combine`x' if in_`x'==1, m
}



* hypothesis : rural /urban difference in entry into marriage  & living arragements after marriage 
* overall argument: rural men faces greater economic pressure 
* accounting for migration 
* rural men delay marriage bx of financial unprepareness
* rural men more likely to get married at home ??

tab  mar urban10 if male==1 , cell
tab  marleave urban10 if male==1


*save "$datadir\prepare.dta" , replace 

/*==============Descriptives===================
table1, by(male)  vars(mar12 cat \mar14 cat \ mar16 cat)                                   ///
					saving( "$tables\dv_descriptive.xlsx", sheet(dv) replace)  format(%2.1f)
					
table1, by (male) vars (eduy10 cat \ age contn \  house_owned cat\  house_sqr  conts \ oldbro cat \     ///
						  lfincome_per conts \ lincome conts)  ///
					saving( "$tables\iv_descriptive.xlsx", sheet(iv) replace)  format(%2.1f)
*/
*============Analysis===================
local dv1 "age agesq eduy10 edu_fm hasincome10 lincome10 nonaghukou10 lfincome  nsib_alive hasbro familysize10" 
local dv2 "house_owned10  house_sqr10 otherhh10 otherhhsqm10 housinghard10 urban10" //housing, geographical

*other specification tried
*local dv1 "age agesq eduy10 edu_fm hasincome10 lincome10 urbanhukou10 asset_pct nsib_alive hasbro farm10"  // asset
*local dv1 "age agesq eduy10 edu_fm urbanhukou10 hasincome10 income_share nsib_alive hasbro farm10 i.region " // income_share 
*local dv1 "age agesq eduy10 edu_fm urbanhukou10 lincome10 lfincome nsib_alive hasbro agefm_75  farm10 i.region " //parental age 
*local dv1 "age agesq eduy10 edu_fm  hasincome10 lincome10 inschool_10a  inwork_10a urbanhukou10  nsib_alive hasbro farm10 alivef10 alivem10"  // inwork, inschool


logit mar  `dv1' `dv2' if male==0 , or
eststo Female_marr
logit mar `dv1' `dv2'  if male==1 , or
eststo Male_marr

logit marleave  `dv1' `dv2' if male==0 & mar==1, or
eststo Female_leave
logit marleave `dv1' `dv2'  if male==1 & mar==1 , or
eststo Male_leave

*esttab Female_marr Male_marr Female_leave  Male_leave using "$tables\logit_replicate.rtf",   ///
*      nonumbers mtitles("Female_marr" "Male_marr" "Female_leave" "Male_leave" )   eform ci(%9.2f) replace 

esttab Female_marr Male_marr Female_leave  Male_leave using "$tables\logit_alter.rtf",   ///
      nonumbers mtitles("Female_marr" "Male_marr" "Female_leave" "Male_leave" )   eform ci(%9.2f) replace 

	  
*breakdown by rural urban
*urban
local dv1 " age agesq eduy10 edu_fm hasincome10 lincome10 urbanhukou10 lfincome nsib_alive hasbro farm10"  // individual/family
*local dv2 "house_owned  house_sqr otherhh otherhhsqm housinghard urban" //housing, geographical
local dv2 "par_own house_sqr otherhh otherhhsqm housinghard " //housing, geographical

logit mar  `dv1' `dv2' if male==0 & urban==1, or
eststo Female_marr
logit mar `dv1' `dv2'  if male==1 & urban==1 , or
eststo Male_marr

logit marleave  `dv1' `dv2' if male==0  & mar==1 & urban==1 , or
eststo Female_leave
logit marleave `dv1' `dv2'  if male==1 & mar==1 & urban==1 , or
eststo Male_leave

esttab Female_marr Male_marr Female_leave  Male_leave using "$tables\logit_urban.rtf",   ///
      nonumbers mtitles("Female_marr" "Male_marr" "Female_leave" "Male_leave" )   eform ci(%9.2f) replace 

*rural	  
local dv1 " age agesq eduy10 edu_fm hasincome10 lincome10 urbanhukou10 lfincome nsib_alive hasbro farm10"  // individual/family
*local dv2 "house_owned  house_sqr otherhh otherhhsqm housinghard urban" //housing, geographical
local dv2 "par_own house_sqr otherhh otherhhsqm housinghard " //housing, geographical

logit mar  `dv1' `dv2' if male==0  & urban==0, or
eststo Female_marr
logit mar `dv1' `dv2'  if male==1 & urban==0 , or
eststo Male_marr

logit marleave  `dv1' `dv2' if male==0  & mar==1 & urban==0 , or
eststo Female_leave
logit marleave `dv1' `dv2'  if male==1 & mar==1  & urban==0 , or
eststo Male_leave

esttab Female_marr Male_marr Female_leave  Male_leave using "$tables\logit_rural.rtf",   ///
      nonumbers mtitles("Female_marr" "Male_marr" "Female_leave" "Male_leave" )   eform ci(%9.2f) replace 

	
*erase "$datadir\prepare.dta" 
