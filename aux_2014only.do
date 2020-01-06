*2014 : if wealthier rural family have more traditional norms 
clear all 
clear matrix 
set more off 
capture log close 



global date "09082019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps       // load cfps data 

*create parental index
use $w14a, clear
		keep pid fid14  urban14  pid_f  pid_m cfps2014_age cfps_gender qm1003 *edu*		
// 			sort pid 
// 			g obsno=_n
// 			keep pid obsno
// 			rename pid id 
// 			tempfile mapping
// 			save `mapping.dta', replace 
//
// 		use $w14a, clear
// 		keep pid fid14  urban14  pid_f  pid_m cfps2014_age cfps_gender qm1003
// 		replace pid_f=. if pid_f<0
// 		replace pid_m=. if pid_m<0
//		
// 		gen id =  pid_f
// 		sort id 
// 		merge m:1 id using `mapping.dta'
// 		keep if _merge ==1 | _merge==3
// 		sort pid 
// 		g f_at=qm1003[obsno]
// 		drop _merge id
//		
// 		gen id= pid_m
// 		merge m:1 id using `mapping.dta'
// 		sort id
// 		keep if _merge ==1 | _merge==3
//		
// 		sort pid 
// 		g m_at=qm1003[obsno]
//
// 		drop _merge id obsno 
		
tempfile w14a
save `w14a.dta', replace 


use $w14hh2, clear	
		*farming household 
		g 		farmhh=1 if fk1l==1
		replace farmhh=0 if fk1l==0

		*have nonag family business(个体经营或者私营企业） 
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

*wealthy older parents tend to prefer to have son live in the house
drop if qm1003<0
replace cfps2014eduy=. if cfps2014eduy<0

*egen  wealth=cut(total_asset_14hh2),group(5) 

egen passet14 =rowtotal(houseasset_gross_14hh2  finance_asset_14hh2 land_asset_14hh2 fixed_asset_14hh2 durables_asset_14hh2)
g lpasset14=log(passet14+1)


g  coreside_agree=(qm1003==4 | qm1003==5)  //agree or strongly argee son should reside with parents 
la var coreside_agree "agree or strongly argee son should reside with parents"

ttest lpasset14    if urban14==0 & cfps2014_age> 50, by(coreside_agree) 
ttest cfps2014eduy if urban14==0 & cfps2014_age> 50, by(coreside_agree) 

graph box lpasset14 if urban14==0 & cfps2014_age> 50, over (coreside_agree)
graph box cfps2014eduy if urban14==0 & cfps2014_age> 50, over (coreside_agree)

*among rural elders age 60 above, those who argree/ storngly agree son should reside with parents have more household wealth 

*preference of parents go to different direction in rural China 
*1. rural wealthy parents wants to stay with son
*2. educated parents do not want 

logit coreside_agree lpasset14 cfps2014eduy if urban14==0 & cfps2014_age> 50
