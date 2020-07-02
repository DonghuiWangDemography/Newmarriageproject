*2014 : if wealthier parents prefer to have children stay at parental home 
*updated on 06192020


clear all 
clear matrix 
set more off 
capture log close 



global date "09082019"   // mmddyy
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
global dir "D:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

global dir "/Users/donghui/Dropbox/Marriage"
cfps_mac       // load cfps data 


use $w14hh, clear 

	*identify if ego has married children 
	forval i=1/10 {
	gen chm`i'=(inlist(tb3_a14_c`i', 2))
    *gen chm`i'=(inlist(tb3_a14_c`i', 2, 4, 5)) 
	}

egen marchil=anymatch(chm*), values(1)

keep pid marchil familysize14 co_a14_p
duplicates tag pid, gen(dup) 
drop if dup !=0 &  co_a14_p==0  //drop duplicated ppl 

duplicates drop 
tempfile ch
save `ch.dta', replace 


use $w14a, clear
merge 1:1 pid using `ch.dta' 
keep if _merge ==3 	
drop _merge 	
tempfile w14a
save `w14a.dta',replace 		


use $w14hh2, clear	
		*farming household 
		g 		farmhh=1 if fk1l==1
		replace farmhh=0 if fk1l==0

		*have nonag family business
		g 		nonagbushh=1 if fm1==1 
		replace nonagbushh=0 if fm1==0

		keep fid14 cid  pid*   fincom* house*  familysize farmhh nonagbushh *asset* *debts* resivalue
		foreach x of varlist _all {
		rename `x' `x'_14hh2
		}

		rename fid14_14hh2 fid14 
		g in_14hh2=1

merge 1:m fid using `w14a.dta'
keep if _merge==3
drop _merge 
tempfile w14hhc
save `w14hhc.dta', replace 

 *ethnicity 
use $cross, clear 
 keep pid ethnicity
 merge 1:1 pid using `w14hhc.dta' 
 keep if _merge==3
 drop _merge 
 
 *=========================

*demographic information : age gender ethnicity, current hukou, farming & family business. region 
clonevar age =cfps2014_age
g        female = (cfps_gender==0) 

clonevar educ=cfps2014eduy_im // use imputed educational level 
replace educ=. if cfps2014eduy_im<0 
	
g       nonaghukou=(qa301==3)
replace nonaghukou=. if qa301==-1

gen      han=(ethnicity==1)
replace  han=. if ethnicity==-8
replace  han =1 if qa701code==1 & han==.
	
*wealth, income 
g lpincome=log(p_income+1) if p_income>=0



gen tasset=total_asset_14hh2/1000 //total asset has missing

egen passet14 =rowtotal(houseasset_gross_14hh2  finance_asset_14hh2 land_asset_14hh2 fixed_asset_14hh2 durables_asset_14hh2)
g lpasset14=log(passet14+1)

clonevar fsize=familysize14 

*region 
recode provcd14 (11/15=1 "north") (21/23=2 "northeast") (31/37=3 "east") ///
			     (41/46=4 "southcentral") (50/53=5 "southwest") (61/65=6 "northwest"), gen (region) 
tab region, gen(region) la

*attitude 
g  coreside_agree=(qm1003==4 | qm1003==5)  //agree or strongly argee son should reside with parents 
la var coreside_agree "agree or strongly argee son should reside with parents"
replace coreside_agree =. if qm1003<0
 

keep if marchil==1


misschk qm1003 coreside_agree age female nonaghukou han educ tasset passet   fsize farmhh nonagbushh region, gen(m)
keep if mnumber==0
keep  qm1003 coreside_agree age female nonaghukou han educ tasset passet   fsize farmhh nonagbushh region



#delimit;
table1, vars(tasset conts \lpasset14 contn  \ educ  contn \ 
             age contn \ female bin\ nonaghukou bin \ han bin \ fsize contn \ nonagbushh bin\  region cat )      
         by (coreside_agree) format(%2.1f)  test saving("$tables/aux14_$date.xls", replace) ;
delimit cr 


logit   coreside_agree lpasset14 educ age female han nonaghukou fsize i.region 
eststo aux14_bin

oprobit qm1003         lpasset14 educ age female han nonaghukou fsize i.region 
eststo aux14_or

esttab aux14_bin aux14_or ///
       using "$tables/aux14_$date.rtf",   ///
        mtitles  b(%9.2f)  se(%9.2f) noomitted  replace  	   
	   
