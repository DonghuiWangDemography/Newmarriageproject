*Project : transition into first marriage & co-residency   
*Date created: 03122019
*Task: 1. replace parental living arragements with cc's 
*2. examine living arragements of newly weds only 

clear all 
clear matrix 
set more off 
capture log close 

global date "03122019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

*sysdir
cfps // load cfps data (cfps.ado)


*merge time-invariant dataset with time varying dataset
use "${datadir}\panel_1016.dta" , clear 
drop livepa10 livepa12 livepa14 livepa16  
merge 1:1 pid using "${datadir}\marr_EHC.dta" , nogen 
merge 1:1 pid using "${datadir}\edu_EHC_temp.dta", keep(master match)nogen    // temprorary file
merge 1:1 pid using  "${datadir}\work_EHC.dta", keep (master match) nogen 
*merge cc's results 
merge 1:1 pid using "${datadir}\gen_all_recode_marstat.dta",   ///
			  keepusing(cores_fm_* alive_*_*) nogen             


*alive in 10-16
g 		alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387


*live with at least one parent 
keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 


rename cores_fm_* livepa*   // rename cc's parents coresiding var
 
keep if livepa10==1 //==>5708
keep if married2010==0  // 2909



*=====missing patterns==========
* adult survey
misschk in_12a in_14a in_16a, gen(ma)
encode mapattern, g(ma2)

*hh survey
misschk in_12hh in_14hh in_16hh, gen(mh)
encode mhpattern, g(mh2)

* missing patterns from household survey 
g mpt=1 if inlist(mh2, 1,5,7)
replace mpt=0 if inlist(mh2,8)
replace mpt=2 if inlist(mh2,2,3,4,6)

*from adult survey 
g mad=1 if inlist(ma2, 1,5,7)
replace mad=0 if inlist(ma2,8)
replace mad=2 if inlist(ma2,2,3,4,6)

la def mp 0 "no missing" 1 "permanent attrition" 2 "interval missing"
la val mpt mp
la val mad mp



* for livepa, there's nothing we can do 

misschk livepa*  

*count new marriage : t single, t+1 married 
forval i=2011/2016 {
*tab married`i',m
local j=`i'-1
g newlyweds`i'=(married`j'==0 & married`i'==1 )
}


* create dependent variable 
*live pa: assume living arragements not changed in between waves ]
forval i=10(2)16{
tab livepa`i',m
}

forval i=10(2)16{
rename livepa`i' livepa20`i'
}
clonevar livepa2011=livepa2012
clonevar livepa2013=livepa2014
clonevar livepa2015=livepa2016


forval i=2011/2016 {
g marstay`i'=(married`i'==1 & livepa`i'==1)
g marleave`i'=(married`i'==1 & livepa`i'==0)

replace marstay`i'=. if  married`i'==. |livepa`i'==.
replace marleave`i'=. if married`i'==. |livepa`i'==.
}



*log using "${logs}\newlyweds_gender$date", text replace 
*first, there should be roughly equal number of male and female get married each year 
forval i=2011/2016 {
tab  newlyweds`i'  , m
*tab male marstay`i'   if  newlyweds`i'==1,m
*tab male marleave`i'  if  newlyweds`i'==1,m 
}
*log close


log using "${logs}\mar_livingarragement_rural$date", text replace 

*Second, assume roughly equal number of male & female marry & live independently  
*the rest of female marry & move with inlaws, marstay for male would be roughtly equal to marleave for female, esp in rural area
forval i=2011/2016 {
tab male marstay`i'   if urban_10a==1 ,m
tab male marleave`i'  if urban_10a==1 ,m 
}
log close 

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

*log using "${logs}\newlyweds_missing$date", text replace 
forval i=2011/2015 {
local j=`i'-1
display "year=`i'"
tab  in_`j' if newlyweds`i'==1 ,  m 
*if people are likely lost to follow up prior to marriage,conditional on being sampled in hh survey 
*if ppl are likely to lost to follow up after marriage

tab male in_`j' if newlyweds`i'==1,m
*tab urban_10a in_`j' if newlyweds`i'==1,m
*anova male in_`j' if newlyweds`i'==1
*anova urban_10a in_`j' if newlyweds`i'==1
}
*log close 


*==========recode Dvs======
*1. Time-varying predictors with EHC: education and occupation /work status 

*Education
drop edu2010_10a edu2010_t1_best_10a edu2012_12a
misschk edu2010 edu2011 edu2012 edu2013  edu2014 edu2015 edu2016, gen(em)
encode empattern, g(edm)

/*

*for interval missing in education, last value carry forward 
/*
------------+-----------------------------------
   _2345 67 |        275        6.58        6.58
   _2345 __ |         16        0.38        6.96
   _23__ 67 |          6        0.14        7.11
   _23__ __ |         42        1.01        8.11
   ___45 67 |        186        4.45       12.56
   ___45 __ |         33        0.79       13.35
   _____ 67 |        353        8.45       21.80
   _____ __ |      3,268       78.20      100.00
------------+-----------------------------------
*/

*2: _2345 __ ; 3 : _23__ 67 ; 4:_23__ __
forval i=2011/2014 {
replace edu`i'=edu2010 if  edu`i'==. & inlist(edm,2,3,4)
}

*6:   ___45 __
forval i=2013/2014 {
replace edu`i'=edu2012 if  edu`i'==. & inlist(edm,6)
}

*/

* work 
g elite_f=(foccupcode<40000)

* recode occupational category 
forval i=2010/2016 {
gen oc`i'= int(mcadj`i'/10000) if mcadj`i'>0 
replace oc`i'=7 if oc`i'==8 |oc`i'==9 // military and others 
replace oc`i'=8 if mcadj`i'==. & inwork`i'==1 
replace oc`i'=0 if  inwork`i'==0 

*la def occup 1 "manager,government official" 2 "professional" 3"clerk" 4"business professional" 5"Agricultural personnel" 6"manufacture" 7"others"  ///
*		     8 "occuaption missing(but working)" 0 "not working", modify 
*la val oc`i' occup	

// further recode occupation 
recode oc`i' (1/3=1 "managerial or professional")  (4=2 "business professional") (5=3 "Ag personnel") (6=4 "manufacture") (7/8=5 "others") (0=0 "not working"), gen(occ`i')
}

misschk occ* // still quite some missing, leave for now 

*2. Time-varying predictors w/c ehc: assume status unchanged in between waves. 
rename own_p_*hh2 own_p_*
*rename own_p_*a own_p_*

local var "alivef alivem otherhh house_sqr nonaghukou fincomeper familysize houseasset migrant house_owned own_p_"
foreach x of local var {

forval i=10(2)16{
rename `x'`i' `x'20`i'
}
clonevar `x'2011=`x'2012
clonevar `x'2013=`x'2014
clonevar `x'2015=`x'2016
}

log using "${logs}\[desc]$date}", text replace 
local var "married inwork occ edu livepa alivef alivem otherhh house_sqr nonaghukou houseasset fincomeper migrant house_owned own_p_ "
foreach x of local var {
forval i=2010/2016 {
tab `x'`i' if in_`i'==1 ,m 
}
}
log close 
* very small missing as far as being interviewed in the adult survey except for parental alive information . What happend to parental alive? 

forval i=2010/2016 {
tab alivef`i' if in_`i'==1 ,m 
tab alivem`i' if in_`i'==1 ,m 
}


*3. Time-invariant predictors
*gender, ethnicity, rural/urban residency / parental education/ occupation / family wealth 
rename age age2010

g han=(ethnicity_cross==1)
replace han=. if ethnicity_cross<0

*fathers' occupation prestiage 
clonevar iseif=iseif_10hh if iseif_10hh>0

*family wealth, housing 
rename nodifficulty10 nodifficulty

clonevar tasset2010= total_asset_10hh2  // total asset 
g ltasset2010=log(tasset2010) 
replace ltasset2010=0 if tasset2010==0

misschk total_asset_10hh2 ltasset2010 if in_10a==1
// ==> quite some missing in father's occupational prestige and total asset


*how stable is the urban reisdency status ?
*egen ud=diff(urban10 urban12 urban14 urban16) if mpattern2==8

*=> urban residency does not change at all. can safely treat as a time-invariant variable
tab nonaghukou2010 nonaghukou2012 if in_10a==1 & in_12a==1,m
tab nonaghukou2012 nonaghukou2014 if in_12a==1 & in_14a==1,m
tab nonaghukou2014 nonaghukou2016 if in_14a==1 & in_16a==1,m

*=>some variations in hukou status, nonaghukou is a time-varying variable

rename provcd_10a province


*examine missings 
*father's occupation prestiage, 28 % missing 
egen newlyweds1016=anymatch(newlyweds*), values(1)
egen marstay1016=anymatch(marstay*), values(1)


*living arragement at the time of marriage 
keep if newlyweds1016==1
g agesq2010=age2010*age2010 


global ctr "age2010 agesq2010 nonaghukou2010 migrant2010  hasbro familysize2010  i.region" // controls 
global dv ""

logit marstay1016 edu_fm $ctr if male==0
eststo female_stay

logit marstay1016 edu_fm $ctr if male==1
eststo male_stay

esttab female_stay male_stay using "$tables\logit_newlywedscross.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 




keep pid married201* livepa201* marstay* marleave*  otherhh201* house_sqr201*  nonaghukou201* migrant201* fincomeper201*   ///
 	 inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016   ///
	 own_p_* house_owned*  occ201* edu201* alivef201* alivem201*  nodifficulty  familysize201*                 ///    
	 age2010  male edu_fm iseif agefm_75 nsib_alive hasbro nbro_alive nbro_alive_cor birthy_best  ///
	 urban10 region  ltasset2010 in_201* province elite_f

save "${datadir}\combine_wide.dta" , replace
	 
local var "marstay marleave livepa alivef alivem otherhh house_sqr nonaghukou fincomeper migrant house_owned own_p_ familysize"
reshape long married inwork occ edu `var', i(pid) j(year)

// adjust risk set 
drop if married==.  // marriage: no interval missing, drop attrition 
bysort pid year: g first=sum(married==1)==1 & sum(married[_n-1]==0)==0  // identify ealiest wave when marriage occur
bysort pid (year): g sf=sum(first)
drop if sf >1   // drop py from risk set after getting married

by pid: egen status=max(married)

*egen gr=group(male urban10)
egen gr=group(urban10 male)
*tab urban10 male

la def gr 1"rural female" 2"rural male" 3"urban female" 4"urban male", modify 
la val gr gr 


*Some additonal modification of predictors 
*age
g agesq2010= age2010* age2010

*education
recode edu (1/2=1 "primary or less") (3=2 "middle school") (4=3 "high school") (5/8=4 "college and above"),  ///
       gen(edulevel)

*family income
g pfinc=log(fincomeper) if fincomeper>1
replace pfinc=0 if fincomeper<=1 &  fincomeper>0
*reverse calculating total family income 
misschk fincomeper familysize
g fincome=fincomeper*familysize
g lfinc=log(fincome)
replace lfinc=0 if fincomeper==. & familysize<.

*parents alive 
g 		alivefm=(alivef==1 | alivem==1)
replace alivefm=. if alivef==. & alivem==. 

*time-varying covariates, lag t-1 yr	  
//drop L*
local var "inwork edulevel otherhh occ alivefm house_sqr nonaghukou livepa pfinc migrant house_owned own_p_ lfinc"
foreach x of local var{
bysort pid (year): g L`x'=`x'[_n-1]
}

la def oc 1 "managerial or professional" 2 "business professional" 3 "Ag personnel" /// 
		 4 "manufacture" 5 "others"  0 "not working", modify
la val Locc oc


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


* descriptives : marstay marleave by urbanicity and gender 
foreach x of varlist married marleave marstay {
display "==>urban"
tab `x' male if urban==1,cell nofreq
display "==>rural"
tab `x' male if urban==0,cell nofreq
}

foreach x of varlist livepa {
display "==>urban"
tab `x' male if urban==1, cell nofreq
display "==>rural"
tab `x' male if urban==0, cell nofreq
}

foreach x of varlist male gr{
table1, vars(married bin \ marleave bin\ marstay bin \ edu_fm conts \  alivefm bin \ ltasset2010 conts\       ///
            age2010 conts\ edulevel cat  \  \ nonaghukou bin\ migrant bin ///
			\ house_owned bin \ otherhh bin \ hasbro bin \ familysize conts )      ///		
         by (`x') format(%2.1f) saving("$tables\desc_`x'.xls", replace)
}


*		
*Age should be the the measurement of time : 李强,张震(2009)生存分析中时间变量的选择,中国人口科学,2009年第6期。

		
*=========Analysis==========
*exclude right censored case . aka only examine individuals who are married in 2010-2016
keep if status==1


*global ctr "age2010 agesq2010 Lnonaghukou Lmigrant  hasbro familysize i.region i.year " // controls 

*conditional on housing condition 
global ctr "age2010 agesq2010 Lnonaghukou Lmigrant  hasbro familysize Lotherhh i.region i.year " // controls 
*global dv "edu_fm"  // parental education 
*global dv "i.edufm"  // parental education 

*global dv "ltasset2010"  // family asset in 2010
*global dv " Lotherhh"    
global dv "i.Ledulevel"  // own education 
*global dv "i.Locc"


*global dv "age agesq  i.Ledu Linwork  Lotherhh Lnonaghukou  Llivepa Lmigrant i.edufm  hasbro i.region i.year"
*global dv "age agesq  i.Ledu Linwork   Lown_p Lnonaghukou  Llivepa Lmigrant edu_fm  hasbro i.region i.year"
*global dv "age agesq  i.Ledulevel Linwork  Lotherhh Lnonaghukou  Llivepa  i.edufm  nsib_alive Lalivefm i.region i.year"
*global dv "age agesq  i.Ledulevel Linwork Lhouse_owned Lotherhh Lnonaghukou  Llivepa  i.edufm  nsib_alive  i.region i.year"
*global dv "age agesq  i.Ledulevel i.Loc  Lotherhh Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel i.Locc  i.Lhouse_owned i.Lotherhh Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel i.Locc  Lhouse_sqr  i.Lhouse_owned i.Lotherhh Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel  i.Locc  Llfinc  Lnonaghukou  Llivepa  i.edufm  nbro_alive_cor  i.region i.year"
*global dv "age agesq  i.Ledulevel  i.Locc Lhouse_owned  Lotherhh  Lnonaghukou    i.edufm   familysize  Llivepa i.region i.year"

*===========
*living arragements of newlyweds 
* mar_stay=1 : married, stay  with parents 
* mar_stay =0: not married / not stay with parents 

logit marstay $dv $ctr if male==0 
eststo  female_stay
logit marstay $dv $ctr if male==1 
eststo male_stay

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


* stay, rural urban comparison 
esttab female_stay male_stay female_stay_urban  male_stay_urban female_stay_rural male_stay_rural using "$tables\logit_newlyweds.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 

	  
	  
	  
*===============================
*===============================
*examine by region and differentiate by father/ children's resources 
*shanghai :31 guangdong:44
*gansu : 62

preserve 
keep if province==31
global ctr "age2010 agesq2010 Lnonaghukou Lmigrant  hasbro familysize  i.year " // controls 

*global dv "edu_fm"  // parental education 
*global dv "i.edufm"  // parental education 
*global dv " Lotherhh"    


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
	  
	  
esttab female_stay male_stay female_leave male_leave  using "$tables\ehc_competing_guangdong.rtf",   ///
      nonumbers mtitles eform   ci(%9.2f)  replace 	 
	  
restroe 

*=====================
*=====================
* 2 by 2 typology 
