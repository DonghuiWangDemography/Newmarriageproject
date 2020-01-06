*Project : transition into first marriage & co-residency   
*Date : 11182018
*Task: update marriage & living arragements  for 2010 adult sample 
*============================================
clear
set more off 
capture log close 
global dir "W:\Marriage"
global datadir "W:\Marriage\CFPSrawdata_Chinese"

*global dir "C:\Users\donghuiw\Desktop\Marriage"
global date "11222018"   // ddmmyy
global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"   

log using "${logs}\[dvcode]$date}", text replace 

*==========upadate marriage status & living arragements==========
*Marital Status update rules: 
*Retrospective  updated  individual  survey  response  at  T+1  >  individual  survey  response  at  T  >  household  roster  response  at  T
* 1.single 2.married 3.cohabitation 4.divorced 5.widowed; 
* 0. no data, -8. NA -1. donot know

use "${datadir}\marriage.dta" , clear
// marriage status
g       mar10= cfps2010_marriage_12a if  cfps2010_marriage_12a>0
replace mar10=qe1_best_10a           if  mar10==. 

g       mar12=cfps2012_marriage_update_14a  if  cfps2012_marriage_update_14a>0
replace mar12= qe104_12a                    if  mar12==.
replace mar12=mar12_12hh                    if  mar12==.

g       mar14=cfps2014_marriage_update_16a if cfps2014_marriage_update_16a>0
replace mar14=qea0_14a                     if mar14==.
replace mar14=mar14_14hh                   if mar14==.

g mar16=qea0_16a         if qea0_16a>0 
replace mar16=mar16_16hh if mar16==. 


// analytical sample 
keep if in_10a==1           // restrict to 10 adult sample & alive to subseqent waves 
drop if alivep12==0 | alivep14==0 | alivep16==0 
keep if mar10==1   // universe : single in  adult 10survey 
drop if pids10 >0  // should not have spouse id N= 32, ==> N=4217


*===============check missings ==========
// Two issues : 1. nearly half spouse IDs are missing among newly weds
//				2. marital status missing 

*1. missing marital status 
tab mar12 if in_12a==1, m  
tab mar14 if mar12==1 & in_14a==1, m 
tab mar16 if mar14==1 & in_16a==1, m  

// never married in t+1 is never married in t
replace mar10= 1 if mar10==. & mar12==1
replace mar10= 1 if mar10==. & mar14==1
replace mar10= 1 if mar10==. & mar16==1



replace mar12= 1 if mar12==. & mar14==1




*2. missing sopuse id
foreach x of numlist 12 14 16 {
g has_pids`x'=(pids`x'>0 & pids`x'<.)
}

/* how many newlyweds have  missing spouse id ?
tab has_pids12 if mar12==2   				// N=225	(59.24%)
tab has_pids14 if mar14==2  &   mar12==1  	// N=232	(54.51%)	
tab has_pids16 if mar16==2	&	mar14==1  	// N=231	(44.60%)	
*/

* why spouse IDs are missing ?   ego moved out after marriage, lost track of ego (thus spouse as well). 
// Make up for missings marstatus (spouse ID)   use EHC
// make up 2012 marital status if marital status from 12-14 (14-16) remain unchanged. 0 missing imputed 

// make up 2012 spouse ID if marital status from 12-14 remain unchanged 
replace pids12=pids14   if eeb202c_14a==1 & mar12==2 & has_pids12==0  & has_pids14==1  // N=118
replace has_pids12=1 if pids12>0 & pids12<.   // update has pids12
tab has_pids12 if mar12==2  // now 343 has 2012 spouse id 

// make up 2014 spouse ID if marital status in 14-16 unchanged. 
tab     has_pids16      if mar14==2 & eeb202_1_16a==1 & has_pids14==0   // N=160
replace pids14=pids16 if mar14==2 & eeb202_1_16a==1 & has_pids14==0 & has_pids16==1
replace has_pids14=1 if pids14>0 & pids14<.

drop eeb*

// living arragement  (co-residing with parents)
* coresident with parents only if both Ego and parents are in the household
* noncoresident with parents if either Ego or parents in the household but not both
* cannot determine coresidence if both Ego and parents NOT in the household

foreach x of numlist 10 12 14 16 {
g pa_in`x'=(livef`x'==1 | livem`x'==1) 

g       livepa`x'=1 if (pa_in`x'==1 & livep`x'==1)
replace livepa`x'=0 if livep`x'==0
replace livepa`x'=0 if livef`x'==0 | livem`x'==0
replace livepa`x'=-8 if (livef`x'==0 & livem`x'==0 & livep`x'==0)
}
drop pa_in*


*========== predictors==============
* parental alive 
* if alive in t+1, alive in t
* if died in t, died in t+1

 

*age
gen age10

save "${datadir}\panel_1016.dta" , replace 
