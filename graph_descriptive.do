clear
set more off 
capture log close 

*========load data/folders
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home 


global datadir "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"  //office
*global datadir "W:\Marriage\CFPSrawdata_Chinese"                         // pri
*global datadir "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese"    // home

global date "03312019"   // ddmmyy
global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"   


*merge time-invariant dataset with time varying dataset
use "${datadir}\panel_1016.dta" , clear  // previous panel 
merge 1:1 pid using "${datadir}\marr_EHC.dta" , nogen 
*merge 1:1 pid using "${datadir}\EHC_edu.dta", keep (master match) nogen
merge 1:1 pid using "${datadir}\edu_EHC_temp.dta", keep(master match)nogen    // temprorary file
merge 1:1 pid using  "${datadir}\work_EHC.dta", keep (master match) nogen 
*merge 1:1 pid using  "${datadir}\homeleaving_EHC.dta" , keep(master match) nogen 

keep if marstat10==0  //N=2976
keep if age>=15 & age<=40





// // * 01/03/2019: a quick check on the survival graph 
// g mar_agemin=mar_ymin- byr_10a if mar_ymin>0 & mar_ymin<.
// *recode eduy10 (0=1 "Less than primary school") (6=2 "Primary school") (9=3 "Middle school") (12=4 "High school") (15=5 "Technique school") (16/22=6 "College and beyond"), gen (edu)
//
// stset mar_agemin, failure ( married2016==1) id(pid)
// sts graph , by(male)  xtitle("Age")  
//
//
// sts graph if male==1 ,   by(edu)  xtitle("Age") 
// sts graph if male==0 ,   by(edu)  xtitle("Age") 
//
// sts graph if male==0 & urban10==0,   by(edu) xlabel (0 "20" 5 "25" 10"30" 15"35" ) xtitle("Age") title ("Married & leave parental home: rural female")





*keep pid income10 income12 income14 income16 lincome10 lincome12 lincome14 lincome16 male urban_10a age

preserve 
reshape long married, i(pid) j(year)
*reshape long marstat, i(pid) j(year)
collapse (mean)  married, by (year male)
bytwoway (line married year), by(male) aes(color lpattern)
restore 





preserve
reshape long lincome , i(pid) j(year)
collapse (median) lincome, by (age male)
bytwoway (line lincome age), by(male) aes(color lpattern)
restore




/* 
preserve 
sample 10
profileplot  houseasset10 houseasset12 houseasset14 houseasset16 , by(male) median
profileplot income10 income12 income14 income16, by(male) median 
profileplot fincomeper10 fincomeper12 fincomeper14 fincomeper16, by (male) median
restore
*/

*Analysis of missing (dependent variables only)
* missing due to lost-to follow up 
misschk in_10a in_12a in_14a in_16a, gen (miss)
*12:N=1485;  14: N=1445  16: N=349
encode misspattern, g(misspattern2)
g missing_inter=(misspattern2 ==2 | misspattern2==3 |misspattern2==4 | misspattern2==6) // N=555
g missing_perm=(misspattern2 ==1 | misspattern2==5| misspattern2==7)
g missing_not=(misspattern2==8)

rename (in_10a in_12a in_14a in_16a) (in_10 in_12 in_14 in_16)

*recode marital status: treat cohabitation as single , treat divorced as get married over the course of past 2yrs
* mar: 1.single 2.married 3.cohabitation 4.divorced 
foreach x of numlist 10 12 14 16 {
replace mar`x'=. if mar`x'<0
replace mar`x'=1 if mar`x'==3
replace mar`x'=2 if mar`x'==4
tab mar`x' if in_`x'==1 ,m 
}

* no missing in marital status if not for attrition 

* define preiod
*for no missing 
g	    fin=2 if mar12==2 & misspattern2==8   //contribute to 2 pw if get married in wave12 
replace fin=3 if mar14==2 & (mar12==1 | mar12==.) & misspattern2==8    //contribute to 3 pw if get married in wave14 
replace fin=4 if mar16==2 & (mar14==1 | mar14==.) & misspattern2==8   //contribute to 4 pw if get married in wave16 
replace fin=4 if mar16==1 & (mar14==1 | mar14==.) & misspattern2==8   //contribute to 4 pw if censored

*missing due to attrition 
replace fin=1 if misspattern2==1    // if  completely missing in 12 14, 16, contribute one pw only 
replace fin=2 if misspattern2==5    // if last seen in wave12 __34
replace fin=3 if inlist(misspattern2, 3, 7)     // if last seen in w14 : _2_4 or ___4  contribute 3 person-wave
replace fin=4 if inlist(misspattern2, 2, 4, 6)  // last seen in w16 , contribute 4 spells 

tab fin,m  // no missing 



*recode event indicator 
* for future person-wave, for each time period 1=event occur, 0=no event 
g       mar=1 if mar12==2 | mar14==2 | mar16==2             // if get married at any wave 
replace mar=0 if (mar12==1 | mar12==.) & fin==2             // single or missing if last seen as single 
replace mar=0 if (mar14==1 | mar14==.) & fin==3
replace mar=0 if (mar16==1 | mar16==.) & fin==4 
replace mar=0 if misspattern2==1  // single if only in wave10 
* 263 missing marital status :  _234 


*competing risk 
g       marleave=1 if mar12 ==2 & livepa12==1 & fin==2
replace marleave=1 if mar14 ==2 & livepa14==1 & fin==3 
replace marleave=1 if mar16 ==2 & livepa16==1 & fin==4
replace marleave=0 if marleave==.

g       marstay=1 if mar12 ==2 & livepa12==0 & fin==2
replace marstay=1 if mar14 ==2 & livepa14==0 & fin==3 
replace marstay=1 if mar16 ==2 & livepa16==0 & fin==4
replace marstay=0 if marstay==. 

*! noted marleave +marstay does not equal to total married. bx missing in living arragement (both ego and parents do not reside in the household, or information missing)

* status: 
g 		status=1 if mar==0
replace status=2 if marleave==1
replace status=3 if marstay==1

la def st 1 "single" 2 "married & not live with parents"  3"married & live with with parents" 
tab status,m

* convert time matrices into age 
* for non missing :
g        ftime=age+6   if fin==4 & misspattern2==8
replace  ftime=age+5   if fin==3 & misspattern2==8
replace  ftime=age+2   if fin==2 & misspattern2==8

* for missing due to attrition : assume missing in the middle 
replace  ftime=age+1  if fin==1    
replace  ftime=age+3  if misspattern2==5     // last seen in wave 12 
replace  ftime=age+5  if inlist(misspattern2, 3, 7)   // last seen in wave 14
replace  ftime=age+6  if inlist(misspattern2, 2, 4, 6)  // last seen in w16 , contribute 6 yrs


g 		censor=0 if mar==1
replace censor=1 if mar==0

la def urban 0"rural" 1"urban" , modify
la val urban10 urban
la var urban10 "rural urban status"

recode eduy10 (0=1 "Less than primary school") (6=2 "Primary school") (9=3 "Middle school") (12=4 "High school") (15=5 "Technique school") (16/18=6 "College and beyond"), gen (edu)

stset ftime , failure (mar==1) scale(2)   id(pid) origin(time 20) 
sts graph if male==1 , hazard by(urban10) xtitle("years since age 20") title ("K-M curve for male")
sts graph if male==0 ,  by(urban10) xtitle("years since age 20") title ("K-M curve for female")

*rural urban differences 
sts graph if male==1 & urban10==0 , by(edu)  xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age") title ("K-M curve for rural male")
sts graph if male==0  & urban10==0,  by(edu) xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age") title ("K-M curve for rural female")




stset ftime, failure (status==2) origin(time 20)  id(pid)
sts graph if male==1 & urban10==0,   by(edu) xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age") title ("Married & leave parental home: rural male")
sts graph if male==0 & urban10==0,   by(edu) xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age") title ("Married & leave parental home: rural female")

sts graph if male==1 &  urban10==1, hazard  by(edu) xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age") title ("Hazard Rate of Married & leave parental home")



stset age, failure (status==3)  origin(time 20)  id(pid) exit(censor==1)
*sts graph, by(male) xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age")
sts graph, hazard by(male) xlabel (0 "20" 5 "25" 10"30" 15"35" 20"40") xtitle("Age")
* the hazard of staying home is higher for female ??
