*Project : transition into first marriage & co-residency   
*Date : 05042019
*Task: sensitivty code of missing in dependent vars


global date "05012019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 


*compensation: family ses, own ses, physical attractiveness 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen    
*merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen 
merge 1:1 pid using "${datadir}\work_EHC.dta", nogen  // use only occupation of 10, 12,14, 16

*======impose sample restrictions====== 
*1. alive in 10-16
g 	    alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387

*2.at least one parent alive
keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 

*3. live at parental home in 2010 (to ensure family wealth includes parental wealth)
keep if livepa10==1    //==>5721

*4.single in 2010 
keep if marstat10==0  
*keep if age>=20 & age<=45  // N=1565
keep if age>=15 & age<=45  // N= 2962

*====================
*missing on dependent vars: sensitivity analysis

misschk marstat12 marstat14 marstat16, gen(m)
encode (mpattern), gen(m)

*A:assume high hazard of event occurance 
tab m 
*1.MMM: drop 
drop if inlist(m,1)

*2.MMA: 
drop if inlist(m,2)

*3.MAA:
drop if inlist(m,3)

*4:AMM
replace marstat12=1 if inlist(m,4)
replace marstat14=1 if inlist(m,4)
replace marstat16=1 if inlist(m,4)

*5:AMA
replace marstat14=1 if inlist(m,5) 
replace marstat12=1 if inlist(m,5) 
replace marstat16=1 if inlist(m,5)

*6:AAM
replace marstat12=0 if inlist(m,6) 
replace marstat16=1 if inlist(m,6) 
replace marstat14=1 if inlist(m,6) 

misschk marstat12 marstat14 marstat16

*For competing risk, do the same thing 
forval i=12(2)16{
g 		marstay`i'=1 if marstat`i'==1 & livepa`i'==1
replace marstay`i'=0 if marstat`i'==0 
replace marstay`i'=0 if marstat`i'==1 & livepa`i'==0

g       marleave`i'=1 if marstat`i'==1 & livepa`i'==0
replace marleave`i'=0 if marstat`i'==0 
replace marleave`i'=0 if marstat`i'==1 & livepa`i'==1 
}

misschk marstay12 marstay14 marstay16, gen(ms)
encode (mspattern), gen(ms)

misschk marleave12 marleave14 marleave16, gen(ml)
encode (mlpattern), gen(ml)

*A: assume high hazard of event occurance 
tab ms

*1.MMA:
drop if inlist(ms,1)

*2.MAM
drop if inlist(ms,2)

*3.MAA
drop if inlist(ms,3)

*4.AMM
replace marstay12=1 if inlist(ms,4)
replace marstay14=1 if inlist(ms,4)
replace marstay16=1 if inlist(ms,4)

*5.AMA
replace marstay12=1 if inlist(ms,5)
replace marstay14=1 if inlist(ms,5)
replace marstay16=1 if inlist(ms,5)

*6.AAM
replace marstay12=0 if inlist(ms,6) 
replace marstay14=1 if inlist(ms,6) 
replace marstay16=1 if inlist(ms,6) 

misschk marstay12 marstay14 marstay16

*marleave
tab ml
*4.AMM
replace marleave12=1 if inlist(ml,4)
replace marleave14=1 if inlist(ml,4)
replace marleave16=1 if inlist(ml,4)

*5.AMA
replace marleave12=1 if inlist(ml,5)
replace marleave14=1 if inlist(ml,5)
replace marleave16=1 if inlist(ml,5)

*6.AAM
replace marleave12=0 if inlist(ml,6)
replace marleave14=1 if inlist(ml,6)
replace marleave16=1 if inlist(ml,6)

misschk marleave12 marleave14 marleave16
save "${datadir}\pw_a.dta", replace 




*==============
*==============
*B:assume low hazard of event occurance, save another file 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen    
*merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen 
merge 1:1 pid using "${datadir}\work_EHC.dta", nogen  // use only occupation of 10, 12,14, 16

*======impose sample restrictions====== 
*1. alive in 10-16
g 	    alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387

*2.at least one parent alive
keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 

*3. live at parental home in 2010 (to ensure family wealth includes parental wealth)
keep if livepa10==1    //==>5721

*4.single in 2010 
keep if marstat10==0  
*keep if age>=20 & age<=45  // N=1565
keep if age>=15 & age<=45  // N= 2962
*=======================
*missing on dependent vars: sensitivity analysis
misschk marstat12 marstat14 marstat16, gen(m)
encode (mpattern), gen(m)

*low hazard of event occurance 
tab m
*1 MMM
replace marstat12=0 if inlist(m,1)
replace marstat14=0 if inlist(m,1)
replace marstat16=0 if inlist(m,1)

*2.MMA
replace marstat12=0 if inlist(m,2)
replace marstat14=0 if inlist(m,2)
replace marstat16=1 if inlist(m,2)

*3.MAA
replace marstat12=0 if inlist(m,3)
replace marstat14=1 if inlist(m,3)
replace marstat16=1 if inlist(m,3)

*4.AMM
replace marstat12=0 if inlist(m,4)
replace marstat14=0 if inlist(m,4)
replace marstat16=0 if inlist(m,4)

*5:AMA
replace marstat12=0 if inlist(m,5)
replace marstat14=0 if inlist(m,5)
replace marstat16=1 if inlist(m,5)

*6.AAM
replace marstat12=0 if inlist(m,6)
replace marstat14=0 if inlist(m,6)
replace marstat16=0 if inlist(m,6)

misschk marstat12 marstat14 marstat16


*For competing risk, do the same thing 
forval i=12(2)16{
g 		marstay`i'=1 if marstat`i'==1 & livepa`i'==1
replace marstay`i'=0 if marstat`i'==0 
replace marstay`i'=0 if marstat`i'==1 & livepa`i'==0

g       marleave`i'=1 if marstat`i'==1 & livepa`i'==0
replace marleave`i'=0 if marstat`i'==0 
replace marleave`i'=0 if marstat`i'==1 & livepa`i'==1 
}

misschk marstay12 marstay14 marstay16, gen(ms)
encode (mspattern), gen(ms)

misschk marleave12 marleave14 marleave16, gen(ml)
encode (mlpattern), gen(ml)

*B: assume low hazard of event occurance 
tab ms

*1.MMA
replace marstay12=0 if inlist(ms,1)
replace marstay14=0 if inlist(ms,1)
replace marstay16=1 if inlist(ms,1)

*2.MAM
replace marstay12=0 if inlist(ms,2)
replace marstay14=1 if inlist(ms,2)
replace marstay16=1 if inlist(ms,2)


*3.MAA
replace marstay12=0 if inlist(ms,3)
replace marstay14=1 if inlist(ms,3)
replace marstay16=1 if inlist(ms,3)

*4.AMM
replace marstay12=0 if inlist(ms,4)
replace marstay14=0 if inlist(ms,4)
replace marstay16=0 if inlist(ms,4)

*5.AMA
replace marstay12=0 if inlist(ms,5)
replace marstay14=0 if inlist(ms,5)
replace marstay16=1 if inlist(ms,5)


*6.AAM
replace marstay12=0 if inlist(ms,6)
replace marstay14=0 if inlist(ms,6)
replace marstay16=0 if inlist(ms,6)

misschk marstay12 marstay14 marstay16


*marry& leave 
tab ml

*1.MMA
replace marleave12=0 if inlist(ml,1)
replace marleave14=0 if inlist(ml,1)
replace marleave16=1 if inlist(ml,1)

*2.MAM
replace marleave12=0 if inlist(ml,2)
replace marleave14=1 if inlist(ml,2)
replace marleave16=1 if inlist(ml,2)

*3.MAA
replace marleave12=0 if inlist(ml,3)
replace marleave14=1 if inlist(ml,3)
replace marleave16=1 if inlist(ml,3)

*4.AMM
replace marleave12=0 if inlist(ml,4)
replace marleave14=0 if inlist(ml,4)
replace marleave16=0 if inlist(ml,4)

*5.AMA
replace marleave12=0 if inlist(ml,5)
replace marleave14=0 if inlist(ml,5)
replace marleave16=1 if inlist(ml,5)


*6.AAM
replace marleave12=0 if inlist(ml,6)
replace marleave14=0 if inlist(ml,6)
replace marleave16=0 if inlist(ml,6)

misschk marleave12  marleave14 marleave16

save "${datadir}\pw_b.dta", replace 
