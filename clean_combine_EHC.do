*Project : transition into first marriage & co-residency   
*Date created: 01/11/2019
*Task: put together across 6 years. 

// net install bytwoway, ///
//     from(https://github.com/matthieugomez/stata-bytwoway/raw/master)

clear all 
clear matrix 
set more off 
capture log close 

global date "01282019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

*sysdir
cfps // load cfps data (cfps.ado)


// *merge time-invariant dataset with time varying dataset
// use "${datadir}\panel_1016.dta" , clear  // previous panel 
// merge 1:1 pid using "${datadir}\marr_EHC.dta" , nogen 
// *merge 1:1 pid using "${datadir}\EHC_edu.dta", keep (master match) nogen
// merge 1:1 pid using "${datadir}\edu_EHC_temp.dta", keep(master match)nogen    // temprorary file
// merge 1:1 pid using  "${datadir}\work_EHC.dta", keep (master match) nogen 
// *merge 1:1 pid using  "${datadir}\homeleaving_EHC.dta" , keep(master match) nogen 
//
//

*04172019
*compensation: family ses, own ses, physical attractiveness 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen 
merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen 
merge 1:1 pid using "${datadir}\work_EHC.dta", nogen  // use only occupation of 10, 12,14, 16


/*before retricting sample, check a few stats 
*low ses men are more likely to live at home: for total sample.
g edufm_high=(edu_fm>=12)
replace edufm_high=. if edu_fm==.

forval i=10(2)16 {
*tab edu`i' livepa`i'  if  male==1 & newlyweds`i'==1, cell nofreq
*tab edu_fm livepa`i'  if  male==1 & newlyweds`i'==1, cell nofreq  
tab edufm_high livepa`i'  if  male==1 , cell nofreq  
 
*tab edu`i' livepa`i'  if  male==1, cell nofreq m 
*tab edu`i'  hmp`i'  if  male==1, cell nofreq m 
}

*/

*restrictions 
*alive in 10-16
g 		alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387


*live with at least one parent 
keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 
keep if livepa10==1 //==>5721
keep if married2010==0  // 2908



*misschk in_2011b in_2012b in_2013b in_2014b in_2015b in_2016b, gen(m)

// *=====missing patterns==========
// * adult survey
// misschk in_12a in_14a in_16a, gen(ma)
// encode mapattern, g(ma2)
//
// *hh survey
// misschk in_12hh in_14hh in_16hh, gen(mh)
// encode mhpattern, g(mh2)
//
// * missing patterns from household survey 
// g mpt=1 if inlist(mh2, 1,5,7)
// replace mpt=0 if inlist(mh2,8)
// replace mpt=2 if inlist(mh2,2,3,4,6)
//
// *from adult survey 
// g mad=1 if inlist(ma2, 1,5,7)
// replace mad=0 if inlist(ma2,8)
// replace mad=2 if inlist(ma2,2,3,4,6)
//
// la def mp 0 "no missing" 1 "permanent attrition" 2 "interval missing"
// la val mpt mp
// la val mad mp


*count new marriage : t single, t+1 married 
forval i=2011/2016 {
*tab married`i',m
local j=`i'-1
g newlyweds`i'=(married`j'==0 & married`i'==1 )
}


* create dependent variable 
*live pa: assume living arragements not changed in between waves 
forval i=10(2)16{
rename livepa`i' livepa20`i'
}
clonevar livepa2011=livepa2012
clonevar livepa2013=livepa2014
clonevar livepa2015=livepa2016

*dv for competing risks 
forval i=2011/2016 {
g 		marstay`i'=1 if married`i'==1 & livepa`i'==1
replace marstay`i'=0 if married`i'==1 & livepa`i'==0
replace marstay`i'=0 if married`i'==0

g 		marleave`i'=1 if married`i'==1 & livepa`i'==0
replace marleave`i'=0 if married`i'==1 & livepa`i'==1
replace marleave`i'=0 if married`i'==0
}


*Second, assume roughly equal number of male & female marry & live independently  
*the rest of female marry & move with inlaws, marstay for male would be roughtly equal to marleave for female, esp in rural area
*log using "${logs}\mar_livingarragement_rural$date", text replace 
forval i=2011/2016 {
tab male marstay`i'   if urban_10a==1 ,m
tab male marleave`i'  if urban_10a==1 ,m 
}
*log close 

*analysis of missing : whether  individuals who left home for marriage are more likely dropping out ?

*drop  in_201*
forval i=10(2)16 {
clonevar in_20`i'=in_`i'a 
}
clonevar in_2011=in_2012
clonevar in_2013=in_2014
clonevar in_2015=in_2016

forval i=2011/2016 {
replace in_`i'=0 if in_`i'==.
}


*==========recode Dvs======
*1. Time-varying predictors with EHC: education and occupation /work status 

*Education
// * version 1: highest educational level derived from EHC (clean_edu_EHC.do)
// drop edu2010_10a edu2010_t1_best_10a edu2012_12a
// misschk edu2010 edu2011 edu2012 edu2013  edu2014 edu2015 edu2016, gen(em)
// encode empattern, g(edm)
//
// forval i=2010/2016{
// tab edu`i',m 
// }
//
// * check : educational levels are irreversable 
// forval i=2011/2016 {
// local j=`i'-1
// *assert edu`j'<=edu`i' if edm==4  // 52 contradictions. what happend ?
// *list edu`j' edu`i'  if edu`j'>edu`i' & edm==4
// }

*version 2 : ehc from cross-wave data 
*cfps2010edu_best_cross, cfps2012edu_cross,cfps2014edu_cross,cfps2016edu_cross
drop  edu2010_10a edu2010_t1_best_10a edu2012_12a edu2010 edu2011 edu2012 edu2013  edu2014 edu2015 edu2016

rename cfps2010edu_best_cross edu2010
rename cfps2012edu_cross 	  edu2012
rename cfps2014edu_cross      edu2014

clonevar edu2016=cfps2016edu_cross if  cfps2016edu_cross<8
replace  edu2016=7 if cfps2016edu_cross==8 


clonevar edu2011=edu2012
clonevar edu2013=edu2014
clonevar edu2015=edu2016

misschk edu2010 edu2011 edu2012 edu2013  edu2014 edu2015 edu2016, gen(em)
encode empattern, g(edm)

*last value carry foward
*2:_2345 __  ; 3: _23__ 67; 4:  _23__ __ 

forval i=2011/2015{
replace edu`i'=edu2010 if edu`i'==. & inlist(edm,2,3,4)
}

*6:___45 __
forval i=2013/2014{
replace edu`i'=edu2012 if edu`i'==. & inlist(edm,6)
}

misschk edu2010 edu2011 edu2012 edu2013  edu2014 edu2015 edu2016


forval i=2011/2016{
local j=`i'-1
*assert edu`j'<=edu`i' &  edu`j'<.   //9 contradictions 
*list pid edu`j' edu`i'  if edu`j'>edu`i' & edu`j'<. , sepby(pid)
}



* occupational category 
forval i=2010/2016 {
gen oc`i'= int(mcadj`i'/10000) if mcadj`i'>0 
replace oc`i'=7 if oc`i'==8 |oc`i'==9 // military and others 
replace oc`i'=8 if mcadj`i'==. & inwork`i'==1 
replace oc`i'=0 if  inwork`i'==0 

// further recode occupation 
recode oc`i' (1/3=1 "managerial or professional")  (4=2 "business professional") (5=3 "Ag personnel") (6=4 "manufacture") (7/8=5 "others") (0=0 "not working"), gen(occ`i')
}

misschk occ* // still quite some missing, leave for now 

*2. Time-varying predictors w/c ehc: assume status unchanged in between waves. 
rename own_p_*hh2 own_p_*
*rename own_p_*a own_p_*

local var "alivef alivem otherhh house_sqr nonaghukou fincomeper lincome familysize houseasset migrant house_owned own_p_"
foreach x of local var {

forval i=10(2)16{
rename `x'`i' `x'20`i'
}
clonevar `x'2011=`x'2012
clonevar `x'2013=`x'2014
clonevar `x'2015=`x'2016
}

*log using "${logs}\[desc]$date}", text replace 
local var " inwork occ edu livepa alivef alivem otherhh house_sqr nonaghukou houseasset fincomeper lincome migrant house_owned own_p_ "
foreach x of local var {
forval i=2010/2016 {
misschk `x'`i' if in_`i'==1 
}
}
*log close 
*quite some missing in fincomeper. leave as it is 




*3. Time-invariant predictors
*gender, ethnicity, rural/urban residency / parental education/ occupation / family wealth in 2010
rename age age2010

g han=(ethnicity_cross==1)
replace han=. if ethnicity_cross<0


*parent ses 
g elite_f=(foccupcode<40000 )
g elite_m=(moccupcode<40000 )


*an alternative measure of parental elite status 
egen iseipa=rowmax(iseim_10hh iseif_10hh)     //  18.47 missing
replace iseipa=. if iseipa<0

*family wealth, housing 
rename nodifficulty10 nodifficulty

clonevar tasset2010= total_asset_10hh2  // total asset 
g ltasset2010=log(tasset2010+1) if tasset2010>0 & tasset2010<.
replace ltasset2010=0 if tasset2010==0

g nasset= (tasset2010<0)    // negative asset N=63

rename provcd_10a province



keep pid married201* livepa201* marstay* marleave*  otherhh201* house_sqr201*  nonaghukou201* migrant201* fincomeper201*   ///
 	 inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016                                   ///
	 own_p_* house_owned*  occ201* edu201* alivef201* alivem201*  nodifficulty  familysize201* nasset               ///    
	 age2010  male edu_fm iseif agefm_75 nsib_alive hasbro nbro_alive nbro_alive_cor birthy_best han          ///
	 urban10 region  ltasset2010 in_201* province elite_f height_10a bmivalue_10a weight_10a iseipa  iseif_10hh iseim_10hh

save "${datadir}\combine_wide.dta" , replace
*save "${datadir}\combine_wide_all.dta" , replace

use  "${datadir}\combine_wide.dta" , clear	 
local var "marstay marleave livepa alivef alivem otherhh house_sqr nonaghukou fincomeper migrant house_owned own_p_ familysize"
reshape long married inwork occ edu `var', i(pid) j(year)

// adjust risk set 
drop if married==.  // marriage: no interval missing, drop attrition 
bysort pid year: g first=sum(married==1)==1 & sum(married[_n-1]==0)==0  // identify ealiest wave when marriage occur
bysort pid (year): g sf=sum(first)
drop if sf >1   // drop py from risk set after getting married

by pid: egen status=max(married)



*Some additonal modification of predictors 
*age
g agesq2010= age2010* age2010

*education
recode edu (1/2=1 "primary or less") (3=2 "middle school") (4=3 "high school") (5/8=4 "college and above"),  ///
       gen(edulevel)
	   
la var height_10a "Height(cm)"
	   
*breakdown to four groups
egen gr=group(urban10 male)
la def gr 1"rural female" 2"rural male" 3"urban female" 4"urban male", modify 
la val gr gr 	   
	   
	   
*family income : (note family income has quite some missing) 
g pfinc=log(fincomeper) if fincomeper>1
replace pfinc=0 if fincomeper<=1 &  fincomeper>0
*reverse calculating total family income 
misschk fincomeper familysize
g fincome=fincomeper*familysize
g lfinc=log(fincome)
replace lfinc=0 if fincomeper==. & familysize<.


*time-varying covariates, lag t-1 yr	  
local var "inwork edulevel otherhh occ house_sqr nonaghukou livepa pfinc migrant house_owned own_p_ lfinc"
foreach x of local var{
bysort pid (year): g L`x'=`x'[_n-1]
}

la def oc 1 "managerial or professional" 2 "business professional" 3 "Ag personnel" /// 
		  4 "manufacture" 5 "others"  0 "not working", modify
la val Locc oc

la def edu 1 "primary or less" 2"middle school" 3"high school" 4"college and above"
la val Ledulevel edu

drop if year==2010  // drop baseline year 

bysort pid: g spell=_n
by pid :gen pycount=_N 
tab pycount 
tab pycount if spell==1  


// re-code educatioal and occupation category 
*recode edu_fm (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22)
*drop edufm
recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8)
recode edu_fm (1/2=1 "primary or less") (3=2 "middle school") (4/8=3 "high school and above"), gen(edufm)

rename Lown_p_ Lown_p
*g lhouseasset=log(houseasset) if houseasset>0
*replace lhouseasset=0 if houseasset==0

*own ses
g elite_p=(Locc==1 |Locc==2)


g 		compr=0 if married==0
replace compr=1 if marstay==1
replace compr=2 if marleave==1
tab compr,m

la def compr 0 "single" 1"married, stay at parental home" 2 "married leave parental home "
la val compr compr


*breakdown to four groups
egen elite=group(elite_p elite_f)
la def el 1"both non-elite" 2"father elite, ego non-elite" 3"ego elite,father non-elite" 4"both elite", modify 
la val elite el 	   
	   


*descriptive statistics by four group
#delimit ;
table1, vars(compr cat \iseipa conts \ edu_fm conts  \ ltasset2010 conts\       
            age2010 conts\ edulevel cat   \ nonaghukou bin\ migrant bin 
			\ house_owned bin \ otherhh bin \ hasbro bin \ familysize conts )     		
         by (gr) format(%2.1f) test saving("$tables\desc_gr.xls", replace);
delimit cr 

* some evidence of parental and children resource differences 
*descriptive statistics by dependent variable 
#delimit;
table1, vars(gr cat\ edu_fm cat \ elite_p bin \ iseipa conts \ ltasset2010 conts\ elite_f bin\ oc cat\ edulevel cat \ Lown_p bin \  
             age2010 conts\   nonaghukou bin\ migrant bin
			\ house_owned bin \ otherhh bin \ hasbro bin \ familysize conts )      
         by (compr) format(%2.1f)  test saving("$tables\desc_bydv.xls", replace) ;
delimit cr 

		


		
*=========Analysis==========
*global ctr "age2010 agesq2010 Lotherhh Lnonaghukou Lmigrant hasbro familysize i.region i.year " // controls 
global ctr "age2010 agesq2010 i.Lhouse_owned  Lnonaghukou Lmigrant hasbro familysize agefm_75 i.region i.year"
*global dv "i.Ledulevel" 
*global dv "i.Locc"

*global dv "i.edufm i.Ledulevel "  // prestiage 
*global dv "i.elite"

*global dv "elite_p elite_f"
*global dv "Lown_p"


*global dv "edu_fm"  // parental education 
*global dv "i.edufm"  // parental education 
*global dv "i.elite_f"

*global dv "ltasset2010"  // family asset in 2010
*global dv " Lotherhh"    
*global dv "i.Ledulevel"  // own education 
*global dv "height_10a"


*global dv "age agesq  i.Ledu Linwork  Lotherhh Lnonaghukou  Llivepa Lmigrant i.edufm  hasbro i.region i.year"
*global dv "age agesq  i.Ledu Linwork   Lown_p Lnonaghukou  Llivepa Lmigrant edu_fm  hasbro i.region i.year"
*global dv "age agesq  i.Ledulevel Linwork  Lotherhh Lnonaghukou  Llivepa  i.edufm  nsib_alive Lalivefm i.region i.year"
*global dv "age agesq  i.Ledulevel Linwork Lhouse_owned Lotherhh Lnonaghukou  Llivepa  i.edufm  nsib_alive  i.region i.year"
*global dv "age agesq  i.Ledulevel i.Loc  Lotherhh Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel i.Locc  i.Lhouse_owned i.Lotherhh Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel i.Locc  Lhouse_sqr  i.Lhouse_owned i.Lotherhh Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel  i.Locc  Llfinc  Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel  i.Locc Lhouse_owned  Lotherhh  Lnonaghukou    i.edufm   familysize  Llivepa i.region i.year"

// preserve 
// keep if age2010>15 & age2010<=35

logit married $dv $ctr if male==0 
eststo  female_mar
logit married $dv  $ctr if male==1 
eststo male_mar


esttab female_mar male_mar using "$tables\ehc_mar.rtf",   ///
      nonumbers mtitles("Female_mar" "Male_mar") eform  la ci(%9.2f)  replace 

// *multinomial
// drop status
// g 		status=0 if married==0
// replace status=1 if marstay==1 & status==.
// replace status=2 if marleave==1 & status==. 
// la def status 0"single" 1"stay" 2"leave"
// la val status status
//
//
// mlogit status $dv $ctr if male==0 
// eststo  female_mar
// mlogit status $dv  $ctr if male==1 
// eststo male_mar


  
// breakdown by urban rural 
logit married $dv  $ctr if male==0 & urban==1, or
eststo  female_mar_urban
logit married $dv $ctr if male==1 & urban==1, or
eststo male_mar_urban

logit married $dv $ctr if male==0 & urban==0, or
eststo  female_mar_rural
logit married $dv $ctr if male==1 & urban==0, or
eststo  male_mar_rural

esttab female_mar male_mar  male_mar_urban  male_mar_rural female_mar_urban female_mar_rural using "$tables\logit_mar_rural.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace  





*esttab female_mar_urban  male_mar_urban f0emale_mar_rural  male_mar_rural using "$tables\logit_mar_rural.rtf",   ///
*      nonumbers mtitles("female_mar_urban" "male_mar_urban"  "female_mar_rural" "male_mar_rural")  eform  ci(%9.2f) noomitted  replace 

*===========competing risk=========================

logit marstay $dv $ctr if male==0 
eststo  female_stay
logit marstay $dv $ctr if male==1 
eststo male_stay
esttab female_stay male_stay using "$tables\ehc_mar2.rtf",   ///
      nonumbers mtitles eform   ci(%9.2f)  replace 

logit marleave $dv $ctr if male==0 
eststo  female_leave
qui: logit marleave $dv $ctr  if male==1 
eststo male_leave


*esttab female_leave male_leave using "$tables\ehc_competing_leave.rtf",   ///
*      nonumbers mtitles eform   ci(%9.2f)  replace 	  
	  
esttab female_stay male_stay female_leave male_leave  using "$tables\ehc_competing.rtf",   ///
      nonumbers mtitles eform   ci(%9.2f) la replace 	  
	  
*=========rural urban differences=========================
*stay , urban
 logit marstay $dv $ctr if male==0 & urban==1, or
eststo  female_stay_urban
 logit marstay $dv $ctr if male==1 & urban==1, or
eststo male_stay_urban

*stay , rural 
 logit marstay $dv $ctr     if male==0 & urban==0, or
eststo  female_stay_rural

 logit marstay $dv $ctr if male==1 & urban==0, or
eststo  male_stay_rural

*Llivepa predict failure perfectly for rural female.
*tab  Llivepa marstay if marstay !=. & Llivepa !=. & male==0 & urban==0

*leave , urban  
logit marleave $dv $ctr if male==0 & urban==1, or
eststo  female_leave_urban
logit marleave $dv $ctr  if male==1 & urban==1, or
eststo male_leave_urban

*leave , rural   
 logit marleave $dv $ctr  if male==0 & urban==0, or
eststo  female_leave_rural
 logit marleave $dv $ctr   if male==1 & urban==0, or
eststo  male_leave_rural


/* stay, rural urban comparison 
esttab  male_stay_urban male_stay_rural  female_stay_urban  female_stay_rural    using "$tables\logit_stay.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 

* leave, rural urban comparison 
esttab male_leave_urban  male_leave_rural female_leave_urban female_leave_rural using "$tables\logit_leave.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 	  
*/	  
	  
* male 
esttab  male_stay_urban male_leave_urban  male_stay_rural   male_leave_rural  using "$tables\logit_male.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted la replace 
	  
*female 
esttab  female_stay_urban female_leave_urban female_stay_rural  female_leave_rural  using "$tables\logit_female.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  la replace 
	  

esttab male_stay_urban  female_stay_urban  male_stay_rural  female_stay_rural   ///
       male_leave_urban female_leave_urban male_leave_rural female_leave_rural  using "$tables\logit_comptrisk.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 	  

*===============================
*===============================
*examine by region and differentiate by father/ children's resources 





