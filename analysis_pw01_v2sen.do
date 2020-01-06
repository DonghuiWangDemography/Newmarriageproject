* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: what type of marriage ego involved (spousal age, ed)
* created on 03172019 
*only look at two waves 

global date "05012019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 


*use "${datadir}\pw_a.dta", clear   //missing as high hazard of event occurance 
*use "${datadir}\pw_b.dta", clear  // low 


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


*====================missing on Y=====================
*main analysis drop missings
misschk marstat12 marstat14   livepa12 livepa14 , gen(m)
keep if mnumber==0

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

*sensitivity analysis: assume high/low hazard of event occurance
*use  "${datadir}\pw_a.dta" ,clear  // high hazard of event occurance : parenatl ses does not matter
*use  "${datadir}\pw_b.dta" ,clear   //low hazard of event occurance 

*=======descriptive statistics before coverting to person-wave======= 

*1.own attributes 
g       han=1 if ethnicity_cross==1
replace han=0 if ethnicity_cross>1 

g 		urbanhukou10=1 if hukou10_10a==3 
replace urbanhukou10=0 if hukou10_10a==1 

clonevar urban=urban10


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

*father's occupation
g       occpf=int(foccupcode/10000) if foccupcode>10000
replace occpf=9 if foccupcode==997 | foccupcode==998 | foccupcode==999   // 997, 998 , 999 as others 
recode  occpf (1/3=1 "Managerial or Professional")  (4=2 "Service personnel")  ///
             (5=3 "Ag personnel") (6=4 "Manufacture personnel") (7/9=5 "others"), gen(ocf)
la var ocf "father's occupation"   // 7.33 missing 
*maybe not a good idea 


*family wealth
*10
g 		ltasset10=log(total_asset_10hh2+1) if total_asset_10hh2>0
replace ltasset10=0 if total_asset_10hh2==0

egen passet10 =rowtotal(houseasset10 companyasset10 financeasset_gross land_asset_10hh2 valuable_10hh2 otherasset_10hh2)
egen nasset10= rowtotal(house_debts10 nonhousing_debts)
g lasset10_p=log(passet10+1)
g lasset10_n=log(nasset10+1)

*12 
g ltasset12=log(total_asset_12hh2+1) if total_asset_12hh2>0
replace ltasset12=0 if total_asset_12hh2==0

egen passet12=rowtotal(land_asset_12hh2 houseasset_gross_12hh2 finance_asset_12hh2 fixed_asset_12hh2 durables_asset_12hh2) 
egen nasset12=rowtotal(house_debts_10hh2 houseother_debts_12hh2)

g lasset12_p=log(passet12+1)
g lasset12_n=log(nasset12+1)

*14 
g ltasset14=log(total_asset_14hh2+1) if total_asset_14hh2>0
replace ltasset14=0 if total_asset_14hh2==0

egen passet14=rowtotal(land_asset_14hh2 houseasset_gross_14hh2 finance_asset_14hh2 fixed_asset_14hh2 durables_asset_14hh2) 
egen nasset14=rowtotal(house_debts_14hh2 nonhousing_debts_14hh2)

g lasset14_p=log(passet14+1)
g lasset14_n=log(nasset14+1)


sum lasset10_p lasset12_p lasset14_p
sum lasset10_n lasset12_n lasset14_n


*age spline 
egen gr=group(urbanhukou10 male)
la def gr 1"non-urban hukou, female" 2"non-urban hukou, male" 3"urban hukou, female" 4"urban hukou male", modify 
la val gr gr 

tab gr
			

// *break down by gender only
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



*define censoring status
g       censor=1 if marstat14==0 
replace censor=0 if marstat14==1 



*============
*define duration :only follow two waves 

*no attrition: m=7 or 3 interval missing cases (but imputed)
g 		dur=1 if marstat12==1 				                //10 single, 12 married :1pw
replace dur=2 if marstat12==0 & marstat14==1               //12 single, 14 married :2pw 
replace dur=2 if marstat14==0   // 14single : 2pw


*define outcome 
g        married=1 if censor==0
replace  married=0 if censor==1 

*what if drop those permanet attrtion ? 
*drop if inlist(m,1,4,6 )


expand dur 
bysort pid: g spell=_n
by pid :gen pycount=_N     //   N=7644 pw  #person-wave 
tab pycount 
tab pycount if spell==1  ,m


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

local var "alivefm livepa eduy educ occup income fincome lassetp lassetn fincomeper house_owned house_sqr otherhh houseasset nonaghukou migrant  familysize farmhh nonagbushh"
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

la def oc 0 "not working" 1"managerial or professional" 2 "business professional" 3 "Ag personnel" 4 "manufacture" 5 "others"
la val Loccup oc

	   
*family income 
g Llfincomeper=log(Lfincomeper+1)
g Llfincome=log(Lfincome+1)

*own income 
g Llincome=log(Lincome+1)
replace Llincome=0 if Lincome==0

misschk Leduy Llincome edu_fm  partypa  lassetp10 lassetn10  ocf	Loccup  ///	
        han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro , gen(all)
*drop the person as far as he/she has one missing in covariates 
* ! this coding is incorrect 
bysort pid: egen missing=max(allnumber)  
keep if missing==0

// misschk Leduy Llincome edu_fm  partypa lasset_p lasset_n Llfincome  ///	
//         han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro

misschk Leduy Llincome edu_fm  partypa Llassetp  Llassetn ///	
        han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro 

		
*competing risk 
local var "marstay marleave"
foreach x of local var {
g 		`x'=`x'12  if spell==1
replace `x'=`x'14  if spell==2
replace `x'=`x'16  if spell==3 
}

// global dv1 "edu_fm lassetp10 lassetn10 partypa ocf1 ocf2 ocf4 ocf5 "
// global dv2 "edu_fm lassetp10 lassetn10 partypa ocf1 ocf2 ocf4 ocf5 Leduy Llincome i.Loccup"  

global dv1 "edu_fm lassetp10 lassetn10 partypa "
global dv2 "edu_fm lassetp10 lassetn10 partypa Leduy Llincome i.Loccup"  

local dv "dv1 dv2"
foreach x of local dv{
display "Female"
logit married $`x' $ctr1 if male==0 
test edu_fm lassetp10 lassetn10 partypa
eststo  female_mar_`x'

display "Male"
logit married $`x' $ctr1 if male==1 
test edu_fm lassetp10 lassetn10 partypa
eststo  male_mar_`x'
}

*joint significant test: family ses does not matter ?
esttab female_mar_dv1 female_mar_dv2 male_mar_dv1 male_mar_dv2 using "$tables\marriage.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 


*=====rural urban========= 
local dv "dv1 dv2"
global ctr5 "sp1 sp2 sp3  han Lfarmhh Lnonagbushh dagepa Lfamilysize hasbro i.region i.spell"
*global ctr1 "i.agegp han Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro i.region i.spell"


foreach x of local dv{
 logit married $`x' $ctr5 if male==0 & urbanhukou10==1
eststo  female_mar_`x'_urban

logit married $`x' $ctr5 if male==0 & urbanhukou10==0
eststo  female_mar_`x'_rural


logit married $`x' $ctr5 if male==1 & urbanhukou10==1
eststo  male_mar_`x'_urban

logit married $`x' $ctr5 if male==1 & urbanhukou10==0
eststo  male_mar_`x'_rural
}

*urban 
esttab female_mar_dv1_urban female_mar_dv2_urban male_mar_dv1_urban male_mar_dv2_urban  using "$tables\marriage_urban.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f)noomitted  replace 

*rural 
esttab female_mar_dv1_rural female_mar_dv2_rural male_mar_dv1_rural male_mar_dv2_rural  using "$tables\marriage_rural.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 
