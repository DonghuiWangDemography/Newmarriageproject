* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* marriage attributes for the newlyweds (age, education)

* created on 03172019 
global date "03172019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 

*compensation: family ses, own ses, physical attractiveness 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen 
merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen 


*======impose sample restrictions====== 
*1. alive in 10-16
g 		alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387

*2.at least one parent alive
*keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 

*3. only for newlyweds 
keep if newlyweds12==1 |newlyweds14==1 |newlyweds16==1   //N=1524


forval i=12(2)16 {
tab educs_`i' if newlyweds`i'==1,m
tab ages_`i' if newlyweds`i'==1,m
}


*pooled cross sectional:12 newlyweds, 14 newlyweds, 16 newlyweds
*dv:edus ages at the time of marriage 
*iv:parental education, income one wave prior to marriage 

*adjust iv 
rename cfps2010edu_best_cross educ10
rename cfps2012edu_cross 	  educ12
rename cfps2014edu_cross      educ14

clonevar educ16=cfps2016edu_cross if  cfps2016edu_cross<8
replace  educ16=7 if cfps2016edu_cross==8 

*homeownership 
rename own_p_*hh2 own_p*
rename own_f_*hh2 own_f*
rename own_m_*hh2 own_m*


local var "alivef alivem eduy educ  income fincome fincomeper own_p own_f own_m house_owned house_sqr otherhh houseasset nonaghukou migrant familysize"

foreach x of local var {
g       `x'=`x'10 if newlyweds12==1

replace `x'=`x'12 if newlyweds14==1
replace `x'=`x'10 if newlyweds14==1 & `x'12==.  // 12 missing, replace with 10 

replace `x'=`x'14 if newlyweds16==1
replace `x'=`x'12 if newlyweds16==1 & `x'14==.
replace `x'=`x'10 if newlyweds16==1 & `x'12==. & `x'14==.
} 

	   
*time-invariant (wave1): age agesq male urban edu_fm 
clonevar urban=urban10
g ltasset=log(total_asset_10hh2+1) if total_asset_10hh2>0
replace ltasset=0 if total_asset_10hh2==0
g ngtasset=(total_asset_10hh2<0)
rename  immobile_child_10a immobile

g wealth=total_asset_10hh2/1000

recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8),gen(eduy_fm_aux)
recode eduy_fm_aux (1/2=1 "primary or less") (3=2 "middle school") (4/8=3 "high school and above"), gen(educ_fm)
drop   eduy_fm_aux

g iseif=iseif_10hh if iseif_10hh>0 
	   
*family income 
drop lfincome
g lfincomeper=log(fincomeper+1)
g lfincome=log(fincome+1)


*total expenses 
g lexp=log(expense_10hh2)
replace lexp=0 if expense_10hh2==0

g lincome=log(income+1)
replace lincome=0 if income==0


*DV
replace  educs_14=0 if educs_14==9  //9 as 不必念书
recode educs_12 (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19), gen (eduys_12) 
recode educs_14 (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19), gen (eduys_14)
recode educs_16 (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19), gen (eduys_16)


local var "educs ages eduys"
foreach x of local var {
g 		`x'=`x'_12 if newlyweds12==1
replace `x'=`x'_14 if newlyweds14==1
replace `x'=`x'_16 if newlyweds14==1
} 

keep if newlyweds12==1
*keep if newlyweds14==1

tab educs,m  //half missing, cannot identify 
tab ages,m

*soupse ses 
global ctr "male age agesq familysize nonaghukou migrant urban nsib_alive immobile i.region"

*first set of analysis : family ses only 
*global dv "edu_fm" 			// edu_fm sig
*global dv "ltasset" 			// asset: insig 
*global dv "lexp"  				// expense: mariginally sig 
*global dv "wealth"  			// wealth: nosig
*global dv "iseif"  		   // marginally sig 
*global dv "otherhh"           // insig 
*global dv "house_owned"       // insig 
*global dv "lfincome"          // insig 

*second set of analysis: conditional on one's own ses  
*global dv "eduy edu_fm"   // eduy sig, edu fm not 
global dv "eduy edu_fm ltasset"   // family ses does not matter 
*global dv "eduy iseif"   // eduy sig, edu fm not 


*conclusion : own ses completlye explain family ses 

reg eduys $dv $ctr 
*change functional form 
ologit educs $dv $ctr 


