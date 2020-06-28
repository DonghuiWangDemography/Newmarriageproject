* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: what type of marriage ego involved (spousal age, ed)
* created on 03172019 

.
* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: what type of marriage ego involved (spousal age, ed)
* created on 03172019 

* updated on 09242019: childbearing predict living arragement 
* updated on 06202020: finalize results & cpi adjusted wealth (income was cpi djusted in clean03_2.do 
*===============================================================
clear all 
global date "20200623"   // yymmdd
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "D:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  
global dir "/Users/donghui/Dropbox/Marriage"  //mac 

*global dir "C:\Users\wdhec\Dropbox\Marriage"  //laptop 

cfps_mac 
*cfps 


*use "${datadir}\pw_a.dta", clear   //missing as high hazard of event occurance 
*use "${datadir}\pw_b.dta", clear  // low 


*compensation: family ses, own ses, physical attractiveness 
use "${datadir}/panel_1016.dta", clear
merge 1:1 pid using "${datadir}/marr_EHC.dta", nogen    


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

*====================missing on Y=====================
*main analysis: drop missings
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

misschk marstay12 marstay14 marstay16
misschk marleave12 marleave14 marleave16



*sensitivity analysis  
*use  "${datadir}\pw_a.dta" ,clear  // high hazard of event occurance : parenatl ses does not matter
*use  "${datadir}\pw_b.dta" ,clear   //low hazard of event occurance 

*=======descriptive statistics before coverting to person-wave======= 

*1.own attributes 
g       han=1 if ethnicity_cross==1
replace han=0 if ethnicity_cross>1 

g 		urbanhukou10=1 if hukou10_10a==3 
replace urbanhukou10=0 if hukou10_10a==1 

clonevar urban=urban10

g female = (gender_10a==0)

*2. parental attributes:
 *hukou at age3 (proxty for parental hukou)
g 		urbanhukou3=1 if hukou3_10a==3
replace urbanhukou3=0 if hukou3_10a==1 |hukou3_10a==5  


*party-membership
g 		fparty=1 if fparty_10hh==1   // communist party 
replace fparty=0 if fparty_10hh==2 |  fparty_10hh==3 | fparty_10hh==4 

g 		mparty=1 if mparty_10hh==1  // communist party 
replace mparty=0 if mparty_10hh==2 | mparty_10hh==3 | mparty_10hh==4 
g partypa=(fparty==1 |mparty==1)

*parental age
egen agepa=rowmax(agef agem)
g dagepa=agepa-age


*parental education 
recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8),gen(eduy_fm_aux)
recode eduy_fm_aux (1=1 "less than primary") (2=2 "primary") (3=3 "middle school") (4/8=4 "high school and above"), gen(educ_fm)
drop  eduy_fm_aux

*family wealth

misschk total_asset_10hh2 total_asset_12hh2 total_asset_14hh2
*10
g 		ltasset10=log(total_asset_10hh2+1) if total_asset_10hh2>0
replace ltasset10=0 if total_asset_10hh2<=0

egen passet10 =rowtotal(houseasset10 companyasset10 financeasset_gross land_asset_10hh2 valuable_10hh2 otherasset_10hh2)
egen nasset10= rowtotal(house_debts10 nonhousing_debts)
g lasset10_p=log(passet10+1)
g lasset10_n=log(nasset10+1)


*family wealth per capita
g lwealthp= log((passet10/familysize10)+1)
replace lwealthp=0 if passet10<=0


*12 
replace total_asset_12hh2= total_asset_12hh2*1.026 // inflation ajusted 

g       ltasset12=log(total_asset_12hh2+1) if total_asset_12hh2>0
replace ltasset12=0 if total_asset_12hh2<=0

egen passet12=rowtotal(land_asset_12hh2 houseasset_gross_12hh2 finance_asset_12hh2 fixed_asset_12hh2 durables_asset_12hh2) 
egen nasset12=rowtotal(house_debts_10hh2 houseother_debts_12hh2)

g lasset12_p=log(passet12*1.026+1)
g lasset12_n=log(nasset12*1.026+1)

*14
replace total_asset_14hh2=total_asset_14hh2*1.02
 
g       ltasset14=log(total_asset_14hh2+1) if total_asset_14hh2>0
replace ltasset14=0 if total_asset_14hh2<=0

egen passet14=rowtotal(land_asset_14hh2 houseasset_gross_14hh2 finance_asset_14hh2 fixed_asset_14hh2 durables_asset_14hh2) 
egen nasset14=rowtotal(house_debts_14hh2 nonhousing_debts_14hh2)

g lasset14_p=log(passet14*1.02+1)
g lasset14_n=log(nasset14*1.02+1)

misschk ltasset10 ltasset12 ltasset14


*age spline 
egen gr=group(urbanhukou10 male)
la def gr 1"non-urban hukou, female" 2"non-urban hukou, male" 3"urban hukou, female" 4"urban hukou male", modify 
la val gr gr 

tab gr
			

*percentile calculated from sample (robust to age cutoff)
*break down by gender only
g 	    p25=20 if  male==1
replace p25=21 if  male==0

g 	   p50=22 if male==1
replace p50=23 if male==0


g 		p75=24 if male==1
replace p75=25 if male==0


*cut off: 25p, 75p 
*1.code spline by hand 
g 	    agesp1=age if age<=p25
replace agesp1=p25 if age>p25

g       agesp2=0       if age<=p25
replace agesp2=age-p25 if age>p25 & age<=p75
replace agesp2=p75-p25 if age>p75

g 		agesp3=0    	  if age<=p75
replace agesp3=age-p75    if age>p75

*2. use stata command, break down by group 
mkspline sp1_1 20  sp2_1 23  sp3_1  = age if gr==1
mkspline sp1_2 21  sp2_2 25  sp3_2  = age if gr==2
mkspline sp1_3 22  sp2_3 26  sp3_3  = age if gr==3 
mkspline sp1_4 23  sp2_4 27  sp3_4  = age if gr==4

g sp1=.
g sp2=.
g sp3=.
forval i=1/4{
replace sp1=sp1_`i' if  gr==`i'
replace sp2=sp2_`i' if  gr==`i'
replace sp3=sp3_`i' if  gr==`i'
}
drop sp1_* sp2_* sp3_*


*=====================
*define censoring status
g       censor=1 if marstat16==0 
replace censor=0 if marstat16==1 

*define duration 
g 		dur=1 if marstat12==1 				                //10 single, 12 married :1pw
replace dur=2 if marstat12==0 & marstat14==1               //12 single, 14 married :2pw 
replace dur=3 if marstat14==0 & marstat16==1 & dur==.	  //14 single, 16 married :3pw 

*single, contribute 3 pw 
replace dur=3 if marstat16==0 	& dur==.


*define outcome 
g        married=1 if censor==0
replace  married=0 if censor==1 


expand dur 
bysort pid: g spell=_n
by pid :gen pycount=_N     //   N=7644 pw  #person-wave 
tab pycount 
tab pycount if spell==1  ,m

*competing risk 
local v "marstay marleave"
foreach x of local v {
g 		`x'=`x'12 if dur==1
replace `x'=`x'14 if dur==2
replace `x'=`x'16 if dur==3
}
*!Note: For sensitivity analysis, marstay12-16/marleave12-16 are already calcuated in clean_04_senA		

*zero prior to censor 
sort pid spell 
by pid, : g last=(_n==_N)

local v "married marstay marleave"
foreach x of local v{
replace `x'=0   if last==0
}
*==========work on IVs==========
*lag time-varying predictors by one-wave : education, work, income housing condition migrant familyincome

*homeownership 
rename own_p_*hh2 own_p*
rename own_f_*hh2 own_f*
rename own_m_*hh2 own_m*

rename  lasset*_p  lassetp*
rename  lasset*_n  lassetn*

// *occupation
// rename mc20* mc*
// misschk mc10 mc12 mc14  // quite some missing in onccupation: may not appropirate measure occupation 
#delimit;
local var "alivefm livepa eduy educ occup income fincome lassetp ltasset lassetn fincomeper 
           house_owned house_sqr own_p otherhh houseasset house_debts  
		   nonaghukou migrant  familysize farmhh nonagbushh" ;
#delimit cr

foreach x of local var {
g        L`x'= `x'10  if spell==1  		      // 10 -12 wave , use wave10 as predictor 
replace  L`x'= `x'12  if spell==2             // 12-14 wave, wave12 predictor
replace  L`x'= `x'10  if spell==2 & `x'12==.  // if missing, use wave 10 predictor
 
replace  L`x'= `x'14  if spell==3      //14-16 wave, wave14 as predictor  
replace  L`x'= `x'12  if spell==3 & `x'14==.
replace  L`x'= `x'10  if spell==3 & `x'14==. & `x'12==.
}

*education
recode Leduc (1/3=1 "middle school or less") (4=2 "high school") (5/7=3 "college and above"),  ///
       gen(Ledulevel)

	   

*own income 
g Llincome=log(Lincome+1)
replace Llincome=0 if Lincome==0



*misschk edu_fm lassetp10 Lltasset Llassetp Leduy Llincome dagepa han urbanhukou10  urbanhukou3 Llivepa Lfarmhh Lnonagbushh hasbro Lfamilysize, gen(all)


misschk lassetp10 Lltasset Llassetp edu_fm Leduy  Llincome  sp1 sp2 sp3 dagepa han  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize   Lotherhh urbanhukou3 urbanhukou10, gen(all)
// missing in any covariates : 2.87

*drop the person as far as he/she has one missing in covariates 
bysort pid: egen missing=max(allnumber)  
keep if missing==0



misschk Leduy Llincome edu_fm  partypa lassetp10 female   ///	
        han urbanhukou10 Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro //M=5309
		

		
*end of variable generation 

save "${datadir}\mar_cleaned", replace  



use "${datadir}\mar_cleaned" , clear 
*time - invariant predictors 
keep pid female age edu_fm agepa hasbro region    // N = 2105 

duplicates drop 
#delimit;
table1, vars(age contn \ edu_fm conts \ agepa conts \ hasbro bin \ region cat )
	   by(female) format(%2.1f)  saving("$tables\desc_constant$date.xls", replace) ;
delimit cr

*===========descriptives ===========

use "${datadir}\mar_cleaned" , clear 

#delimit;
table1, vars( married bin \ marstay bin \marleave  bin \ edu_fm contn \lassetp10 contn \ passet10 contn  \ Llassetp conts \
              Leduy  contn \ Llincome contn  \ Lincome contn  \
             age contn \ Lfarmhh bin\  urbanhukou10 bin \ Lnonagbushh bin \ dagepa contn \ hasbro bin \ Lfamilysize contn \ region cat )      
         by (female) format(%2.1f)  test saving("$tables\desc_tv$date.xls", replace) ;
delimit cr 




*----------Regression ---------- 
log using "$logs\main_$date" , replace 


use "${datadir}\mar_cleaned" , clear 


global iv1 "c.Llassetp##i.female edu_fm                    sp1 sp2 sp3 dagepa han  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize   Lotherhh urbanhukou10 urbanhukou3 i.region i.spell"
global iv2 "c.Llassetp##i.female edu_fm  Leduy   Llincome  sp1 sp2 sp3 dagepa han  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize   Lotherhh urbanhukou10 urbanhukou3 i.region i.spell" 


// global iv1 "c.Lltasset##i.female edu_fm                    sp1 sp2 sp3 dagepa han  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize   Lotherhh urbanhukou10 i.region"
// global iv2 "c.Llassetp##i.female edu_fm  Leduy   Llincome  sp1 sp2 sp3 dagepa han  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize   Lotherhh urbanhukou10 i.region " 

local dv "married marstay marleave"
local iv "iv1 iv2 "

foreach y of local dv {
foreach x of local iv { 
	logit `y' $`x'  , or vce(robust) 
    est store   all_`y'_`x'
} 
}

#delimit; 
esttab all_married_iv1   all_married_iv2  
       using "$tables\all_married_$date.rtf",   
       nocons nonumbers mtitles  b(%9.2f)  wide se(%9.2f) noomitted la replace 
;

esttab all_marstay_iv1   all_marstay_iv2 
       using "$tables\all_marstay_$date.rtf",  
       nonumbers mtitles  b(%9.2f) wide se(%9.2f) noomitted la replace 
;

esttab all_marleave_iv1   all_marleave_iv2  
       using "$tables\all_marleave_$date.rtf",   
       nonumbers mtitles  b(%9.2f) wide  se(%9.2f) noomitted la replace 
;	   
delimit cr 

log close    

erase "${datadir}\mar_cleaned.dta"
