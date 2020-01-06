// double check the coding : use expand instead of reshape
// results are the same

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
// the reason for so many mismatch is bx panel_1016 also include hh survey  

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
replace married`i'=. if mpattern2==5 // missing in 14, 16 wave : 2010,2011, 2012 known 
}

forval i=2015/2016{
replace married`i'=. if mpattern2==7  // missing 16 wave: 2011-2014 known 
}




local var "livepa alivef alivem otherhh house_sqr nonaghukou fincomeper migrant"
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


keep pid married201* mpattern2

* define duration
*for non-missing
g dur=.
replace dur=6 if married2016==0
replace dur=6 if married2016==1 & married2015==0 
replace dur=5 if married2015==1 & married2014==0 
replace dur=4 if married2014==1 & married2013==0 
replace dur=3 if married2013==1 & married2012==0 
replace dur=2 if married2012==1 & married2011==0 
replace dur=1 if married2011==1 & married2010==0 

replace dur=2 if mpattern2==5 & dur==.   // missing 14, 16wave
replace dur=4 if mpattern2==7 & dur==.  //missing 16 wave
drop if mpattern2==1

tab dur,m
expand dur
