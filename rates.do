* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: calculate annual rates,following a method by Xie 

global date "07152019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 


cfps 

use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen    
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
keep if age>=15 & age<=45  // N= 2962

*====================missing on Y=====================
*main analysis drop missings
misschk marstat12 marstat14 marstat16  livepa12 livepa14 livepa16, gen(m)
keep if mnumber==0

// marital status is irreversable 
drop if marstat12==1 & marstat14==0  // 2 observation dropped 

forval i=12(2)16{
g 		marstay`i'=1 if marstat`i'==1 & livepa`i'==1
replace marstay`i'=0 if marstat`i'==0 
replace marstay`i'=0 if marstat`i'==1 & livepa`i'==0

g       marleave`i'=1 if marstat`i'==1 & livepa`i'==0
replace marleave`i'=0 if marstat`i'==0 
replace marleave`i'=0 if marstat`i'==1 & livepa`i'==1 
}

gen 	newlyweds12=1 if marstat12==1 
replace newlyweds12=0 if marstat12==0 

gen 	newlyweds14=1 if marstat14==1 & marstat12==0 
replace newlyweds14=0 if marstat12==0 & marstat14==0
replace newlyweds14=0 if marstat12==1 


gen 	newlyweds16=1 if marstat16==1 & marstat14==0 
replace newlyweds16=0 if marstat16==0 & marstat14==0 & marstat12==0
replace newlyweds16=0 if marstat14==1 
replace newlyweds16=0 if marstat12==1 

misschk newlyweds12 newlyweds14 newlyweds16

*biannual rates of entering into marraige 
keep pid marstat* marstay* marleave* newlyweds* age male 


// forval i=10(2)14 {
// 	local j=`i'+2
//	
// 	bysort age male: egen nsingle`j'=sum(marstat`i'==0)
// 	bysort age male: egen nmar`j'=sum(marstat`j'==1)
// 	bysort age male: egen nstay`j'=sum(marstay`j'==1)
// 	bysort age male: egen nleave`j'=sum(marleave`j'==1)
//	
// 	g r_mar`j'  = nmar`j'/ nsingle`j'
// 	g r_stay`j' = nstay`j'/nsingle`j'
// 	g r_leave`j'= nleave`j'/nsingle`j'
//	
// 	sum r_mar`j' r_stay`j' r_leave`j'
// }


*an alternative calculation 
*age as two year range 
// recode age (15/16=15)(17/18=17)(19/20=19)(21/22=21)(23/24=23)(25/26=25)(27/28=27)(29/30=29) ///
// 		   (31/32=31)(33/34=33)(35/36=35)(37/38=37)(39/40=39)(41/42=41)(43/45=43), gen(ageg)



forval i=10(2)14 {
	local j=`i'+2
	bysort age male: egen nsingle`i'=sum(marstat`i'==0)
	bysort age male: egen nmar`j'=sum(newlyweds`j'==1)
	bysort age male: egen nstay`j'=sum(marstay`j'==1)
	bysort age male: egen nleave`j'=sum(marleave`j'==1)
}

*number of singles by age and male 
egen nsingle=rowtotal(nsingle10 nsingle12 nsingle14)
egen nmar=rowtotal(nmar12 nmar14 nmar16)
egen nstay=rowtotal( nstay12 nstay14 nstay16)
egen nleave=rowtotal( nleave12 nleave14 nleave16)

keep age male nsingle nmar nstay nleave 
duplicates drop  

sort male age 
by male: g Lnmar=nmar[_n-1]
by male: g Lnstay=nstay[_n-1]
by male: g Lnleave=nleave[_n-1]
drop if Lnmar==.

g r_mar=Lnmar/nsingle
g r_stay=Lnstay/nsingle
g r_leave=Lnleave/nsingle

sum r_mar r_stay r_leave,  detail 
*rates greater than one, what happend ? 


*ssc inst localp 
lpoly r_mar age if male==1, bw(3) mc(gs10)  scheme(s1color) 
lpoly r_mar age if male==0, bw(3) mc(gs10)  scheme(s1color)   


twoway (lowess  r_mar12 age if male==1) (lowess  r_stay12 age if male==1) (lowess  r_leave12 age if male==1)
twoway (lowess  r_mar12 age if male==0) (lowess  r_stay12 age if male==0) (lowess  r_leave12 age if male==0)





