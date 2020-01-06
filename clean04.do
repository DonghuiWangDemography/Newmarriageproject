
clear all 
clear matrix 
set more off 
capture log close 

global date "12052018"   // ddmmyy
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"

******CFPS data **********************************************************************
*global datadir "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"  //office
global datadir "W:\Marriage\CFPSrawdata_Chinese"                       // pri
*global datadir "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese"    // home

global w10hh "${datadir}\2010\cfps2010famconf_report_nat092014.dta"
global w10hh2 "${datadir}\2010\cfps2010family_report_nat092014.dta"
global w10a "${datadir}\2010\cfps2010adult_report_nat092014.dta"
global w10c "${datadir}\2010\cfps2010child_report_nat092014.dta"

global w12hh "${datadir}\2012\cfps2012famros_092015compress.dta"
global w12a "${datadir}\2012\cfps2012adultcombined_092015compress.dta"
global w12c "${datadir}\2012\cfps2012childcombined_032015compress.dta"
global w12cross "${datadir}\2012\crossyearid_032015compress.dta"

global w14hh "${datadir}\2014\cfps2014famconf_170630.dta"
global w14a "${datadir}\2014\cfps2014adult_170630.dta"
global w14c "${datadir}\2014\Cfps2014child_170630.dta"

global w16hh "${datadir}\2016\cfps2016famconf_201804.dta"
global w16a "${datadir}\2016\cfps2016adult_201808.dta"
global w16c "${datadir}\2016\cfps2016child_201807.dta"
global cross "${datadir}\2016\Cfps2016crossyearid_201807.dta"

*========merege all the data first 

use $w10a, clear
foreach x of varlist _all {
rename `x' `x'_10a
}
g in_10a=1
rename pid_10a pid 
drop qb3* qa7* qd1* qf1* kt1* qn* qm7* tb* qd10* kr* ks*
tempfile w10a
save `w10a.dta', replace 

use $w12a, clear
foreach x of varlist _all {
rename `x' `x'_12a
}
g in_12a=1
drop  qb3* qa7* qd1* qf1* kt1* qn* qm7* tb* qd10* kr* ks*
rename pid_12a pid 
tempfile w12a
save `w12a.dta', replace 

use $w14a, clear
foreach x of varlist _all {
rename `x' `x'_14a
}
g in_14a=1
rename pid_14a pid 
tempfile w14a
save `w14a.dta', replace 

use $w16a, clear
foreach x of varlist _all {
rename `x' `x'_16a
}
g in_16a=1
rename pid_16a pid 
tempfile w16a
save `w16a.dta', replace 

*hh survey 
use $w10hh, clear
foreach x of varlist _all {
rename `x' `x'_10hh
}
g in_10hh=1
rename pid_10hh pid 
tempfile w10hh
save `w10hh.dta', replace 

use $w12hh, clear
foreach x of varlist _all {
rename `x' `x'_12hh
}
g in_12hh=1
rename pid_12hh pid 
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a12_p ==0  //drop duplicated ppl 
tempfile w12hh
save `w12hh.dta', replace 

use $w14hh, clear
foreach x of varlist _all {
rename `x' `x'_14hh
}
g in_14hh=1

rename pid_14hh pid 
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a14_p==0  //drop duplicated ppl 
tempfile w14hh
save `w14hh.dta', replace 


use $w16hh, clear
foreach x of varlist _all {
rename `x' `x'_16hh
}
g in_16hh=1

rename pid_16hh pid 
duplicates tag pid, gen(dup) 
drop if dup !=0 & co_a16_p==0  //drop duplicated ppl 
tempfile w16hh
save `w16hh.dta', replace 


use $cross, clear
foreach x of varlist _all {
rename `x' `x'_cross
}
rename pid_cross pid
tempfile cross
save `cross.dta', replace

*merge 
use `w10a.dta', clear
merge 1:1 pid using `w12a.dta' , nogen
merge 1:1 pid using `w14a.dta' , nogen
merge 1:1 pid using `w16a.dta' , nogen

merge 1:1 pid using `w10hh.dta', nogen
merge m:1 pid using `w10hh.dta', nogen
merge 1:1 pid using `w12hh.dta' , nogen
merge 1:1 pid using `w14hh.dta' , nogen
merge 1:1 pid using `w16hh.dta' , nogen
merge 1:1 pid using `cross.dta' , nogen

save "${datadir}\merged_temp.dta"

* household family survey
use $w10hh2, clear	
foreach x of varlist _all {
rename `x' `x'_10hh2
}
rename fid_10hh2 fid 
g in_10hh2=1
merge m:1 fid using "${datadir}\merged_temp.dta"  // 604 from 10hh  not matched
drop _merge 

save "${datadir}\fullpanel_10_16.dta" ,replace 
beep
