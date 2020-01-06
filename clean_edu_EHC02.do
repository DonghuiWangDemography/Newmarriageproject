*Project : transition into first marriage & co-residency   
*Date created: 03/03/2019
*Task: reconstruct  education history. 
*Adopt a new coding scheme： First identify & correct edu2010,12, 14, 16 , then identify edu11, 13, 15  
*some codes are borrowed from clean_edu_EHC.do 


clear all 
clear matrix 
set more off 
capture log close 
*set maxvar  120000, perm

global date "03032019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

*load cfps data (cfps.ado stored at c:\ado\personal\)
*sysdir
cfps 


use $w10a, clear  // N=33,600
merge 1:1 pid using $cross,  keepusing(cfps2010edu_best cfps2010sch_best) keep(match master) nogen 
keep pid cfps2010edu_best

merge 1:m pid using $w10hh, keepusing(tb4_a_p) keep(match) nogen
replace cfps2010edu_best=tb4_a_p if cfps2010edu_best==. &  tb4_a_p>0 
rename cfps2010edu_best edu2010     // 4 unkowns 

keep pid edu2010 
*save "${datadir}\2010_edu_EHC.dta", replace 
tempfile edu2010
save `edu2010.dta', replace   // N=53753



use $w12a, clear  // N=35719
merge 1:1 pid using $cross, keepusing(cfps2012edu ) keep(match master) nogen   // trust cfps2012edu
merge 1:1 pid using $w14a,  keepusing (cfps2012_latest_edu) keep(match master)  nogen 
merge 1:m pid using $w12hh, keepusing(tb4_a12_p co_a12_p)  nogen 
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a12_p ==0  //drop duplicated ppl 

* check consistencies between self-report in w12a, hh and re-interview in 2014
egen difedu=diff(edu2012 cfps2012edu cfps2012_latest_edu tb4_a12_p )    	// 64% consistent
egen difedu_2=diff(cfps2012edu edu2012)  						//98.95  consistent  

*correct edu codings in 2012
rename  edu2012 edu2012_a    // rename to avoid confusing 

*tab edu2012_a cfps2012edu,m  // some inconsistencies , trust cross wave edu 

g edu2012 = cfps2012edu if difedu==0 | difedu_2==0  


*replace missing with 2014-reinterview , if further missing, replace with 2014 hh 
replace edu2012=cfps2012_latest_edu if edu2012==. & cfps2012_latest_edu>0 & cfps2012_latest_edu<.
replace edu2012=tb4_a12_p           if edu2012==. & tb4_a12_p>0 & tb4_a12_p<.
*tab edu2012 ,m   // N=1908 missing , leave as it is 

g in_12  =1
keep pid edu2012 in_12 

tempfile edu2012
save `edu2012.dta', replace   // N=53753


use $w14a, clear   //N=37147 
*no need to merge cross-wave data, bx cfps2014edu is included in the individual survey
*w2016 did not re-interview. 
merge 1:m pid using $w14hh, keepusing (tb4_a14_p co_a14_p)  nogen      
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a14_p ==0   

*check consistencies 
egen    difed=diff(cfps2014edu tb4_a14_p)   
replace cfps2014edu=tb4_a14_p if cfps2014edu==. & tb4_a14_p>0  // no change made 

clonevar edu2014=cfps2014edu if cfps2014edu>0 
replace edu2014=1 if cfps2014edu==9  // set 不必读书 as 1 
tab edu2014,m                		//  678 missing 

keep pid edu2014 
tempfile edu2014
save `edu2014.dta', replace  


use $w16a, clear
merge 1:m pid using $w16hh, keepusing (tb4_a16_p)  nogen

clonevar edu2016=cfps2016edu // => 80 missing
replace  edu2016=tb4_a16_p  if edu2016==. & tb4_a16_p>0 & tb4_a16_p<.
tab edu2016,m                		//  1,311 missing 

keep pid edu2016 
tempfile edu2016
save `edu2016.dta', replace  
 

use `edu2010.dta', clear
merge 1:1 pid using `edu2012.dta', keep(match master) nogen 
merge 1:1 pid using `edu2014.dta', keep(match master) nogen 
merge 1:1 pid using `edu2016.dta', keep(match master) nogen 

misschk edu2010 edu2012 edu2014 edu2016, gen(m)
encode mpattern, gen(mp)

/*			
1234	2	0.01	0.01
12_4	1	0.00	0.01
1__4	1	0.00	0.01
_234	1,848	5.50	5.51
_23_	492	1.46	6.98
_2_4	423	1.26	8.24
_2__	1,148	3.42	11.65
__34	1,609	4.79	16.44
__3_	1,110	3.30	19.74
___4	2,243	6.68	26.42
____	24,723	73.58	100.00
*/			

*1234: all missing, drop 
drop if mp==1

*12_4 & 1__4 : impute with non missing 2014 edu 
list edu201* if inlist(mp,2,3)  ,nolab
forval i=2010(2)2016 {
replace edu`i'=edu2014 if inlist(mp,2,3)  &  edu`i'==.
}

*5: _23_
*list edu201* if inlist(mp,5)  ,nolab
egen dif1016=diff(edu2010 edu2016)
*tab dif1016 if inlist(mp,5)

forval i=2012(2)2014 {
replace  edu`i'=edu2010 if inlist(mp,5) & dif1016==0 &  edu`i'==.
}

* 6: _2_4; 7: _2__ 
list edu201* if inlist(mp,6,7 )  ,nolab
egen dif1014=diff(edu2010 edu2014)
tab dif1014 if inlist(mp,6,7)  // only 67 differ

replace edu2012=edu2010 if inlist(mp,6,7) & dif1014==0 & edu2012==.

*9 :__3_
list edu201* if inlist(mp,9)  ,nolab
egen dif1216=diff(edu2012 edu2016)
tab dif1216 if inlist(mp,9)

replace edu2014=edu2012 if inlist(mp,9) & dif1216==0 & edu2014==.

misschk edu2010 edu2012 edu2014 edu2016  // much smaller missing 

keep pid edu2010 edu2012 edu2014 edu2016


**these codes need to change after going through edu EHC*************

*expand into 2 yrs :assume no change in highest education in between interview waves 
clonevar edu2011=edu2012
clonevar edu2013=edu2014
clonevar edu2015=edu2016



save "${datadir}\edu_EHC_temp.dta" ,replace 


/*=============STPEEED here on 03042018  ============
*====work on 2011, 2013, 2015 edu=============
use  "${datadir}\edu_EHC_temp.dta", clear 
forval i=2010(2)2016{
tab edu`i',m
}

merge 1:1 pid using $w12a, nogen 


egen dif1012=diff(edu2010 edu2012)    // 76% the same 
g edu2011= edu2010 if dif1012==0


*For those still attending school in 10-12： identify when current schooling level started 
rename kr1 level 
rename (kr201 kr302 kra402 kr502 kra602 kr702 kr802)  ///
	   (t2  t3 t4 t5 t6 t7 t8)
	   
* 2=primary school; 3= middle school ; 4=high school; 5= da zhuan; 6=ben ke; 7= masters; 8=phd  

forval i=2/8{

replace t`i'=. if t`i'<0

* if current schooling started on or prior to 2011, 2011 highest edu level =2012 highest edu level 
replace edu2011=edu2012  if  t`i'<=2011 & t`i'<. & wc01==1 & edu2011==. & edu2012 !=.

* if current schooling started after 2011 => edu2010=edu2011 
replace edu2011=edu2010 if  t`i'>2011 &  t`i'<.  & wc01==1 & edu2011==.  & edu2010 !=.
}	

* if 文盲/半文盲 in 2012, still 文盲/半文盲 in 2011
replace edu2011=1 if edu2012==1 & edu2011==. 

* missing the date of staring the program , but still attending school in 2012 ? 
misschk t2 t3 t4 t5 t6 t7 t8, gen(m)
tab wc01  if mnumber==7,m   // N=7295 attending schoool but missing valid school starting date 

*repalce with edu2012 if valid date is missing 
replace edu2011= edu2012 if mnumber==7  & wc01==1  & edu2011==.   

drop t* mpattern mnumber

tab edu2011 if edu2010 !=. ,m     // N=3131


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

tab edu2010 edu2011 if edu2010 !=., nolab    // it is very strange    

tab edu2011 edu2012 if edu2010 !=., nolab    // basically no change at all for the highest educational level from 2011-2012 


















