*Project : transition into first marriage & co-residency   
*Date created: 01/22/2019
*Task: reconstruct  education history 
* updated : 03/03/2019

clear all 
clear matrix 
set more off 
capture log close 
*set maxvar  120000, perm

global date "01222019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

*load cfps data (cfps.ado stored at c:\ado\personal\)
*sysdir
cfps 


*====2010=====
/*
atschool2010
cfps2010edu_best  个人问卷受访者已完成的最高学历 
cfps2010sch_best  个人问卷受访者离校/上学阶段
cfps2010eduy      个人问卷受访者已完成的受教育年限 
*/


use $w10a, clear  // N=33,600
merge 1:1 pid using $cross,  keepusing(cfps2010edu_best cfps2010sch_best) keep(match master) nogen 
keep pid cfps2010edu_best

merge 1:m pid using $w10hh, keepusing(tb4_a_p) keep(match) nogen
replace cfps2010edu_best=tb4_a_p if cfps2010edu_best==.
rename cfps2010edu_best edu2010     // 4 unkowns 
g in_10a  =1
save "${datadir}\2010_edu_EHC.dta", replace 

*====2012=====
*identify educational history in 2011 and 2012 
*cfps2011_latest_d3: schooling status in 2010
* may also need to merge 2010 ? 


use $w12a, clear  // N=35719

merge 1:1 pid using $cross, keepusing(cfps2012edu indsurvey10) keep(match master) nogen   // trust cfps2012edu
merge 1:1 pid using $w14a,  keepusing (cfps2012_latest_edu) keep(match master)  nogen 
merge 1:m pid using $w12hh, keepusing(tb4_a12_p co_a12_p) keep(match master) nogen 
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a12_p ==0  //drop duplicated ppl 

*****STEP1: correct codings & make up missings in 2012edu=======
* cfps2012edu: edu in cross wave panel 
* edu2012: adult sample in 2012

* check consistencies between self-report in w12a, hh and re-interview in 2014
egen difedu=diff(edu2012 cfps2012edu cfps2012_latest_edu tb4_a12_p )    	// 64% consistent
egen difedu_2=diff(cfps2012edu edu2012)  						//98.95  consistent  

*correct edu codings in 2012
rename  edu2012 edu2012_a    // rename to avoid confusing 

g  		edu2012 = cfps2012edu if difedu==0 | difedu_2==0  // trust cross-wave edu
*tab edu2012 if indsurvey10==1,m  ==> still 216 missing 


*replace missing with 2014-reinterview , if further missing, replace with 2014 hh 
replace edu2012=cfps2012_latest_edu if edu2012==. & cfps2012_latest_edu>0 & cfps2012_latest_edu<.
replace edu2012=tb4_a12_p if edu2012==. & tb4_a12_p>0 & tb4_a12_p<.
*tab edu2012 ,m   // => 28 missing leave as it is 


****STEP2: identify the highest educational level in year 2011
merge 1:1 pid using "${datadir}\2010_edu_EHC.dta", keepusing(edu2010) nogen // only keep those that interviewed in 2010

egen dif1012=diff(edu2010 edu2012)    // 76% the same 
g edu2011= edu2010 if dif1012==0

*whether attending school 10-12
replace wc01=1 if kr1>0 				// 21change; N=2099 still attending school 
tab wc01 if edu2011==. , m				// N=390 currently attending schoool

*for those still attending school ： identify when current schooling level started 
rename kr1 level 
rename (kr201 kr302 kra402 kr502 kra602 kr702 kr802)  ///
	   (t2  t3 t4 t5 t6 t7 t8)
	   
* 2=primary school; 3= middle school ; 4=high school; 5= da zhuan; 6=ben ke; 7= masters; 8=phd  

forval i=2/8{

replace t`i'=. if t`i'<0

* if current schooling started on or prior to 2011, 2011 highest edu level =2012 highest edu level 
replace edu2011=edu2012  if  t`i'<=2011 & t`i'<. & wc01==1 & edu2011==. 

* if current schooling started after 2011 => edu2010=edu2011 
replace edu2011=edu2010 if  t`i'>2011 &  t`i'<.  & wc01==1 & edu2011==. 
}	

* only N=30 changes made 

* if 文盲/半文盲 in 2012, still 文盲/半文盲 in 2011
replace edu2011=1 if edu2012==1 & edu2011==. 

* missing the date of staring the program , but still attending school in 2012 ? 
misschk t2 t3 t4 t5 t6 t7 t8, gen(m)
tab wc01  if mnumber==7,m   // N=7295 attending schoool but missing valid school starting date 

*repalce with edu2012 if valid date is missing 
replace edu2011= edu2012 if mnumber==7  & wc01==1  & edu2011==.   // 44 change made 

drop t* mpattern mnumber

tab edu2011,m   // N=7530 missing 


*STEP2.2 
* not currently not attending school
* if left school prior to 2011: edu2011=edu2012=edu2010  
* if left school after 2011 :  edu2011=edu2012 (aka timing of leaving school doesn't matter)
replace edu2011=edu2012 if  wc01==0 & edu2011==. 

assert edu2011 <= edu2012 if edu2011<. 

*if still missing , impute  with 2012 education 
replace edu2011=edu2012 if missing(edu2011) & !missing(edu2012)  
g in_12a=1 

tab edu2011 , m  
tab edu2012 , m
* N=7,212  missing 
tab edu2011 edu2012              // basically no change at all for the highest educational level from 2011-2012 
tab edu2010 edu2011, nolab     

*there are a few inconsistencies 
*list level kw1 if edu2010==2 & edu2011==1
*replace edu2010=1 if  edu2010==2 & edu2011==1  // 3 changes 
*assert edu2010<= edu2011 if edu2010<.   // 22 contradictions : what to do with these? 
*assert edu2011<= edu2012 if edu2011<.   // no contradiction 

keep pid  edu2011 edu2012 
save "${datadir}\2012_edu_EHC.dta", replace 


*====2014=====
use $w14a, clear

*w2016 did not re-interview. 
merge 1:m pid using $w14hh, keepusing (tb4_a14_p co_a14_p) keep(matched) nogen      
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a14_p ==0 //drop duplicated ppl 


*check consistencies 
egen    difed=diff(cfps2014edu tb4_a14_p)   // only 49 dif
replace cfps2014edu=tb4_a14_p if cfps2014edu==. & tb4_a14_p>0  // no change made 

clonevar edu2014=cfps2014edu if cfps2014edu>0 
replace edu2014=1 if cfps2014edu==9  // set 不必读书 as 1 
tab edu2014,m                		// 49 missing 


g edu2013=.
* if age 45 and above, schooling expereince as NA
replace edu2013=edu2014 if cfps2014_age>44 

*not attending school 2012-2014 (regardless of whether currently attending or not), edu2013==edu2014
replace edu2013=edu2014 if wc02==0 & edu2013==. 

* attending school 2012-2014, not attending school 2014: edu2013==edu2014
replace edu2013=edu2014 if wc02==1 & wc01==0 & edu2013==. 

* attending school 2012-2014, attending school 2014 : identify the date of staring 2014 educational level  
rename (kr201 kr302 kra402 kr502 kra602 kr702 kr802) ///
	   (t2 t3 t4 t5 t6 t7 t8) 

forval i=2/8 {
replace t`i'=. if t`i'<0

*if current schooling started prior to 2013, edu2013=edu2014 
replace edu2013=edu2014  if  wc02==1 & wc01==1 & t`i'<=2013  & kr1==`i' & edu2013==. 

*if current schooling started after 2013, edu2013=edu2012 
replace edu2013=edu2014-1 if wc02==1 & wc01==1  & t`i'>2013 & t`i'<. & kr1==`i' & edu2013==. 
}

* for those in less than primary school in 2014, still in less than primary school in 2013
replace edu2013=1 if edu2014==1 & edu2013==. 
replace edu2014=. if edu2014<0

// for those still missing in 2013 
replace edu2013=edu2014 if missing(edu2013) & !missing(edu2014) & edu2014 >0 
replace edu2013=. if edu2013<0

keep pid  edu2013 edu2014  

*assert  edu2013 <=edu2014 if edu2013<.

g in_14a=1

tab edu2013 if in_14a==1 ,m   // 49 missing 
tab edu2014 if in_14a==1 ,m   //49 missing

save  "${datadir}\2014_edu_EHC.dta", replace 

use $w16a, clear
* 5205 missing in sch2016: all of who are neither not in school or NA in2016 (aka pc1==0 / -8)
* ==>  impute missing form household survey 

merge 1:m pid using $w16hh, keepusing (tb4_a16_p) keep(matched) nogen
replace cfps2016edu=tb4_a16_p if cfps2016edu==. & tb4_a16_p>0 & tb4_a16_p<.

clonevar edu2016=cfps2016edu // => 80 missing

* identify 2015 education 
g edu2015=.
* Note: education related questions are only asked for those age below 45. 
replace edu2015=edu2016 if cfps_age>=45

*not attending school 2014-2016(regardless of whehter attending school in 2016 ), edu2015=edu2016 
replace  edu2015=edu2016 if pc7==0 & edu2015==.

*attending school 2014-2016, not attending school 2016 : edu2015==edu2014==edu2016
replace edu2015=edu2016 if pc7==1 & pc1==0 & edu2015==.

* attending school 2014-2016, attending school 2016 : identify the date of starting 2016 educational level
* tab pc7 pc1,m  // no one attending school 2014-2016a and attending school in 2016 
* something wentwrong for pc7,pc1, may not need to consider these two

* starting current education prior to 2015, eud2015=edu2016 
replace edu2015=edu2016   if  pr0<=2015 & pr0>0 & edu2015==.

* Note: kw1 is also asked for some individuals who are still attending school (aka pc1==1) 
// other educational experiences : generate 2015 schooling level first (sch2015)
g sch2015=.
forval i=1/3 {
replace kw2y_b_`i'=. if kw2y_b_`i'<0
rename  kw2y_b_`i' fin_`i'
rename (kw302_b_`i' kw403_b_`i' kw503_b_`i' kw603_b_`i' kw703_b_`i'  kw803_b_`i' kw903_b_`i')   ///
	   (st3_`i'     st4_`i'    st5_`i' st6_`i'  st7_`i' st8_`i' st9_`i')
	   
g sch2015_`i'=.	   
forval j=3/9 {
replace st`j'_`i'=. if st`j'_`i'<0 
misschk st`j'_`i' fin_`i', gen(m`j'_`i')

replace sch2015_`i'=`j'  if st`j'_`i'<=2015 & fin_`i'>=2015  & sch2015==. & !missing(st`j'_`i', fin_`i')

* assume in a lower level if starting date is after 2015
replace sch2015_`i'=`j'-1 if st`j'_`i'>2015 & sch2015==. 

// if no valid starting & ending date 
replace sch2015_`i'=kw1 if sch2015==. & missing(st`j'_`i', fin_`i') & kw1 !=10  // 10 = never been to school
replace sch2015_`i'=1 if sch2015==. & missing(st`j'_`i', fin_`i') & kw1==10 

}
}
egen sch2015_max=rowmax(sch2015_1 sch2015_2 sch2015_3)
replace sch2015=sch2015_max if sch2015==. & sch2015_max>0

// higest educational level is one level lower than the schooling level currently attending 
replace edu2015=sch2015-1 if edu2015==. & kw0==1

tab edu2016 if edu2015==.

tab edu2015 edu2016,m  

replace edu2015=edu2016 if edu2015==. & edu2016 !=.
gen in_16a=1

tab edu2015 if in_16a==1, m  // N=80 missing 
tab edu2016 if in_16a==1, m  // N=80 missing 

save "${datadir}\2016_edu_EHC.dta" , replace 

use  "${datadir}\2010_edu_EHC.dta" ,clear
merge 1:1 pid using "${datadir}\2012_edu_EHC.dta" , nogen 
merge 1:1 pid using "${datadir}\2014_edu_EHC.dta" , nogen 
merge 1:1 pid using "${datadir}\2016_edu_EHC.dta", nogen   // N=3323 
merge 1:1 pid using $cross, nogen 
keep if  in_10a==1

forval i=2010/2015{
local j=`i'+1
*assert edu`i'<=edu`j' & edu`i'<.  // 28 contradictions :set to missing
*list edu`i' edu`j' if  edu`i'>edu`j' & edu`i'<. , nolab 
replace edu`i'=. if edu`i'>edu`j' & edu`i'<. 
replace edu`j'=. if edu`i'>edu`j' & edu`i'<. 
*assert edu`i'<=edu`j' & !missing(edu`i', edu`j')     // still  contradictions ? what happend ? 

list edu`i' edu`j' if  edu`i'>edu`j' & !missing(edu`i', edu`j') 

}

forval i=2010/2015{
local j=`i'+1

tab edu`i' edu`j' ,m  nolab   // looks fine 
}


*interval missing: last value carry forward 
misschk edu2010 edu2011 edu2012 edu2013 edu2014 edu2015 edu2016, gen(medu)
encode (medupattern), g(me)

/*
Missing for |
      which |
 variables? |      Freq.     Percent        Cum.
------------+-----------------------------------
   _2345 67 |      3,681       10.96       10.96
   _2345 __ |        985        2.93       13.89
   _23__ 67 |        871        2.59       16.48
   _23__ __ |      2,139        6.37       22.85
   ___45 67 |      2,163        6.44       29.28
   ___45 __ |      1,867        5.56       34.84
   _____ 67 |      2,853        8.49       43.33
   _____ __ |     19,041       56.67      100.00
------------+-----------------------------------
      Total |     33,600      100.00
*/




*_2345 __
tab edu2010 edu2015 if me==2,m nolab

forval i=2011/2014 {
replace edu`i'=edu2010 if edu`i'==. & me==2
}

*_23__ 67
forval i=2011/2012 {
replace edu`i'=edu2010 if edu`i'==. & inlist(me, 2,3)
}

*___45 __

forval i=2013/2014 {
replace edu`i'=edu2012 if edu`i'==. & inlist(me, 5)
}

forval i=2010/2015{
local j=`i'+1
display `i'
tab edu`i' edu`j' 
*assert edu`i'<=edu`j' & edu`i'<.    // 25 contradictions 
*list edu`i' edu`j' if edu`i' > edu`j'  & edu`i'<.
}

 


keep pid edu2010 edu2011 edu2012 edu2013 edu2014 edu2015 edu2016 
keep if in_10a==1
save "${datadir}\EHC_edu.dta" ,replace 





// check plot 
/* search spagplot 
use "${datadir}\EHC_edu.dta", clear
merge 1:1 pid using $cross , keep (matched) keepusing (birthy gender)
reshape long sch, i(pid) j(year) 

sample 5
spagplot sch year if birthy >1989, id(pid)

*/

erase "${datadir}\2010_edu_EHC.dta"
erase "${datadir}\2012_edu_EHC.dta"
erase "${datadir}\2014_edu_EHC.dta"
erase "${datadir}\2016_edu_EHC.dta"
