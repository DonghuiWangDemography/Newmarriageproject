* dataformat:person-wave instead of person-year
* task : different measurment of competing risks : marry & stay; single & leave; single & stay. starting stage:(single & live) 



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
misschk marstat12 marstat14 marstat16  livepa12 livepa14 livepa16, gen(m)
keep if mnumber==0

forval i=10(2)16 {
gen 	status`i'=1 if livepa`i'==1 & marstat`i'==0  // stay , single
replace status`i'=2 if livepa`i'==1 & marstat`i'==1  // stay, married
replace status`i'=3 if livepa`i'==0 & marstat`i'==0  // leave, single 
replace status`i'=4 if livepa`i'==0 & marstat`i'==1 // leave, married

}
la def st 1 "stay, single" 2"stay,married" 3"leave,single" 4"leave, married", modify
la val status10  st
la val status12  st
la val status14  st
la val status16  st

forval i=10(2)16 {
tab status`i',la m
}

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

*father's occupational prestiage
*first convert cfps occupational code into ISCO-88(4digit): adfile: iscoocc.ado
iscoocc fisco88, iocc(foccupcode)  
*second covert into isei : adofie: iscoisei.ado
// 70000 军人                     .a
// 80000 无职业者分类及其代码     .b
// 90000 不便分类的其他从业人员   .c
iscoisei fisei, isco(fisco88)	
tab fisei,m  //16%missing
 

iscoocc misco88, iocc(moccupcode)  
*second covert into isei : adofie: iscoisei.ado
// 70000 军人                     .a
// 80000 无职业者分类及其代码     .b
// 90000 不便分类的其他从业人员   .c
iscoisei misei, isco(misco88)	
tab misei,m  // 20% missing

egen iseifm=rowmax(fisei misei)


*parental education 
recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8),gen(eduy_fm_aux)
recode eduy_fm_aux (1=1 "less than primary") (2=2 "primary") (3=3 "middle school") (4/8=4 "high school and above"), gen(educ_fm)
drop  eduy_fm_aux

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

corr lasset10_p iseifm edu_fm fincome10
 
sum lasset10_p lasset12_p lasset14_p
sum lasset10_n lasset12_n lasset14_n

*detailed measure of wealth and asset 

*资产：房产，土地，金融，公司
g 		lhouseasset=log(houseasset10+1)
replace lhouseasset=0 if houseasset10==0

g lcompanyasset=log(companyasset10+1)
replace lcompanyasset=0 if companyasset10==0

g 		lfinanceasset=log(financeasset_gross+1)
replace lfinanceasset=0 if financeasset_gross==0


g 		lhouse_debts=log(house_debts10+1)
replace lhouse_debts=0 if house_debts10==0

g lnonhousing_debts=log(nonhousing_debts+1)
replace lnonhousing_debts=0 if nonhousing_debts==0

g lland_asset =log(land_asset_10hh2+1)
replace lland_asset=0 if land_asset_10hh2==0


*age spline 
egen gr=group(urbanhukou10 male)
la def gr 1"non-urban hukou, female" 2"non-urban hukou, male" 3"urban hukou, female" 4"urban hukou male", modify 
la val gr gr 

tab gr
			

* percentile calculated from sample (robust to age cutoff)
* break down by four groups
// g 	    p25=20 if gr==1
// replace p25=21 if gr==2
// replace p25=22 if gr==3
// replace p25=23 if gr==4
//
// g 	    p50=21 if gr==1
// replace p50=23 if gr==2
// replace p50=24 if gr==3
// replace p50=25 if gr==4
//
// g 		p75=23 if gr==1
// replace p75=25 if gr==2
// replace p75=26 if gr==3
// replace p75=27 if gr==4


// *break down by gender only
g 	    p25=20 if  male==1
replace p25=21 if  male==0

g 	   p50=22 if male==1
replace p50=23 if male==0


g 		p75=24 if male==1
replace p75=25 if male==0



*cut off: 25p, 75p 
// *1.code spline by hand 
// g 	    agesp1=age if age<=p25
// replace agesp1=p25 if age>p25
//
// g       agesp2=0       if age<=p25
// replace agesp2=age-p25 if age>p25 & age<=p75
// replace agesp2=p75-p25 if age>p75
//
// g 		agesp3=0    	  if age<=p75
// replace agesp3=age-p75    if age>p75

*2. use stata command
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

// corr agesp1 sp1 
// corr agesp2 sp2
// corr agesp3 sp3
*the results are the same 

*define censoring status
g       censor=1 if marstat16==0 
replace censor=0 if marstat16==1 



*============
*define duration 
*no attrition: m=7 or 3 interval missing cases (but imputed)
g 		dur=1 if status12 !=1 				              
replace dur=2 if status12==1 & status14 !=1               
replace dur=3 if status12==1 & status14 ==1 	  

*define outcome 
g       status=status12 if dur==1
replace status=status14 if dur==2
replace status=status16 if dur==3

la val status st
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

misschk Leduy Llincome edu_fm  partypa  lassetp10 lassetn10  iseifm	Loccup  ///	
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
gen     marstay=1 if married==1 & livepa16==1
replace marstay=0 if married==0
replace marstay=0 if married==1 & livepa16==0

gen     marleave=1 if married==1 & livepa16==0
replace marleave=0 if married==0
replace marleave=0 if married==1 & livepa16==1


*twoway (lowess married lassetp10) (histogram lassetp10) , by(male)

*===========descriptives ===========

#delimit;
table1, vars( married bin \ marstay bin \marleave  bin \ edu_fm conts \lassetp10 conts\ lassetn10 conts \  partypa bin \ ocf cat\ iseifm conts \
              Leduy  conts \ Llincome conts \  Loccup cat \ 
             age conts \ Lfarmhh bin\ Lnonagbushh bin \ dagepa conts \ hasbro bin \ Lfamilysize conts )      
         by (gr) format(%2.1f)  test saving("$tables\desc_dv_pw.xls", replace) ;
delimit cr 

//
// #delimit;
// table1, vars(gr cat\ edu_fm conts \ Leduy conts \  ltasset conts \
//              age conts\   Lnonaghukou bin\ Lmigrant bin \ 
// 			 \ hasbro bin \ Lfamilysize conts \ region cat)      
//          by (married) format(%2.1f)  test saving("$tables\desc_dv_pwmar.xls", replace) ;
// delimit cr 
//
//
// *breakdown by male and female  
// #delimit;
// table1, vars( married cat \ Leduy conts \ edu_fm conts  \ Llincome conts \  ltasset conts \
//              age conts \   Lnonaghukou bin\ Lmigrant bin \ 
// 		   \ hasbro bin \ Lfamilysize conts \  region cat)      
//          by (male) format(%2.1f)  test saving("$tables\desc_pwmar_male.xls", replace) ;
// delimit cr 

*=====first stage: entry into marriage=================

global ctr1 "agesp1 agesp2 agesp3 han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro i.region i.spell"

*First, entry into marriage: family ses,own ses has additive effect 
global dv1 "edu_fm "  
global dv2 "lassetp10 lassetn10"  // parental education 
*global dv3 "partypa"  // family wealth 
*global dv4 "iseifm"
global own "Leduy Llincome "

local dv "dv1 dv2 dv3 dv4 "
foreach x of local dv{

display "Female"
logit married $`x' $ctr1 if male==0 
eststo  female_mar_`x'

display "Male"
logit married $`x' $ctr1 if male==1 
eststo  male_mar_`x'
}

*female 
esttab female_mar_dv1 female_mar_dv2 female_mar_dv3 female_mar_dv4 using "$tables\marriage_female.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

*male 
esttab male_mar_dv1 male_mar_dv2 male_mar_dv3 male_mar_dv4 using "$tables\marriage_male.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

//twoway (lowess married lassetp10, logit) (histogram  lassetp10), by(male)

	  
// *own resources' mediation effect
// global dv1 "edu_fm Leduy Llincome"  
// global dv2 "ltasset Leduy Llincome "  // parental education 
// global dv3 "partypa Leduy Llincome "  // family wealth 


// global dv1 "edu_fm lassetp10 lassetn10 partypa ocf1 ocf2 ocf4 ocf5 "
// global dv2 "edu_fm lassetp10 lassetn10 partypa ocf1 ocf2 ocf4 ocf5 Leduy Llincome i.Loccup"  

global dv1 "edu_fm lassetp10 lassetn10  "
global dv2 "edu_fm lassetp10 lassetn10 Leduy Llincome i.Loccup"  

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
	  
	  
// *KHB
// khb logit married edu_fm lassetp10 lassetn10 partypa || Leduy Llincome if male==0,  ///
// concomitant($ctr) summary
//
// khb logit married edu_fm lassetp10 lassetn10 partypa || Leduy Llincome if male==1,  ///
// concomitant($ctr) summary

// esttab female_mar_dv1 female_mar_dv2 female_mar_dv3 female_mar_dv4  using "$tables\marriage_female.rtf",   ///
//       nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 
//	  
// esttab male_mar_dv1 male_mar_dv2 male_mar_dv3 male_mar_dv4  using "$tables\marriage_male.rtf",   ///
//       nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

	  
*=====rural urban========= 
*First, entry into marriage: family ses,own ses has additive effect 
global ctr5 " sp1 sp2 sp3 han Lfarmhh Lnonagbushh dagepa Lfamilysize hasbro i.region"

global dv1 "edu_fm"  
global dv2 "lassetp10 lassetn10"  // parental education 
global dv3 "partypa"  // family wealth 
*global dv4 "ib3.ocf"
*global dv4 "iseifm"
global own "Leduy Llincome "

local dv "dv1 dv2 dv3 dv4 "
foreach x of local dv{

logit married $`x' i.spell if male==0 & urbanhukou10==1
eststo  female_mar_`x'_urban

logit married $`x'  i.spell if male==0 & urbanhukou10==0
eststo  female_mar_`x'_rural


logit married $`x'  i.spell if male==1 & urbanhukou10==1
eststo  male_mar_`x'_urban

logit married $`x'  i.spell if male==1 & urbanhukou10==0
eststo  male_mar_`x'_rural

}

*urban female  
esttab female_mar_dv1_urban female_mar_dv2_urban female_mar_dv3_urban female_mar_dv4_urban using "$tables\marriage_female_urban.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

*urban male  
esttab male_mar_dv1_urban male_mar_dv2_urban male_mar_dv3_urban male_mar_dv4_urban using "$tables\marriage_male_urban.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 	  
	  
	  
*rural female  
esttab female_mar_dv1_rural female_mar_dv2_rural female_mar_dv3_rural female_mar_dv4_rural using "$tables\marriage_female_rural.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

*rural male  
esttab male_mar_dv1_rural male_mar_dv2_rural male_mar_dv3_rural male_mar_dv4_rural using "$tables\marriage_male_rural.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 	  





local dv "dv1 dv2"
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
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

*rural 
esttab female_mar_dv1_rural female_mar_dv2_rural male_mar_dv1_rural male_mar_dv2_rural  using "$tables\marriage_rural.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

	  
	  
	  
	  
*interactions with agespline 
// global dv4 "c.edu_fm##c.agesp1 c.edu_fm##c.agesp2  lasset_p lasset_n partypa Leduy Llincome "
// global dv5 "edu_fm  c.lasset_p##c.agesp1  c.lasset_p##c.agesp2   partypa Leduy Llincome "
// global dv6 "edu_fm  c.lasset_n##c.agesp1   c.lasset_n##c.agesp2    partypa Leduy Llincome "
// global dv7 "partypa##c.agesp1  partypa##c.agesp2    lasset_p lasset_n edu_fm Leduy Llincome "

// *interaction with age or age dummy
// global dv4 "c.edu_fm##c.agesp2 c.edu_fm##c.agesp3 lasset_p lasset_n  Leduy    i.ocf partypa Llincome i.Loccup "
// global dv5 "c.lasset_p##c.agesp1   c.lasset_p##c.agesp2 c.lasset_p##c.agesp3 edu_fm lasset_n       i.ocf  partypa Leduy Llincome i.Loccup"
// global dv6 "edu_fm  c.lasset_n##c.agesp2 c.lasset_n##c.agesp3 i.ocf  partypa Leduy Llincome i.Loccup"
// global dv7 "partypa##c.agesp2  partypa##c.agesp3 lasset_p lasset_n i.ocf edu_fm Leduy Llincome i.Loccup"



	  
	   
*========breakdown by rural urban

local dv "dv4 dv5 dv6 dv7"
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

esttab female_mar_dv4_urban female_mar_dv4_rural  male_mar_dv4_urban male_mar_dv4_rural  using "$tables\mar_dv4.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 

esttab female_mar_dv5_urban female_mar_dv5_rural  male_mar_dv5_urban male_mar_dv5_rural  using "$tables\mar_dv5.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 

	  
	  
esttab female_mar_dv4_rural female_mar_dv5_rural female_mar_dv6_rural female_mar_dv7_rural using "$tables\logit_female_pa_rural.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 
	  
esttab female_mar_dv4_urban female_mar_dv5_urban female_mar_dv6_urban female_mar_dv7_urban using "$tables\logit_female_pa_urban.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 

esttab male_mar_dv4_rural male_mar_dv5_rural male_mar_dv6_rural male_mar_dv7_rural using "$tables\logit_male_pa_rural.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 
	  
esttab male_mar_dv4_urban male_mar_dv5_urban male_mar_dv6_urban male_mar_dv7_urban using "$tables\logit_male_pa_urban.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 	

	  
	  
// *====own resource interact with parental resource : not significant==========
// global dv6 "c.edu_fm##c.Leduy ltasset Llincome"	    
// global dv7 "edu_fm Leduy c.ltasset##c.Llincome"	
//
// local dv "dv6 dv7"
//   foreach x of local dv{
// qui: logit married $`x' $ctr1 if male==0 
// eststo  female_mar_`x'
//
// qui: logit married $`x' $ctr1 if male==1 
// eststo  male_mar_`x'
// }
//
// esttab female_mar_dv6 female_mar_dv7 male_mar_dv6 male_mar_dv7 using "$tables\egoparnt.rtf",   ///
//       nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 
	  
	  
// esttab female_mar_dv4_rural female_mar_dv5_rural male_mar_dv4_rural male_mar_dv5_rural using "$tables\logit_female_asset_rural_interact.rtf",   ///
//       nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 
//
// esttab female_mar_dv4_urban female_mar_dv5_urban male_mar_dv4_urban male_mar_dv5_urban using "$tables\logit_female_asset_urban_interact.rtf",   ///
//       nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 	  
	  
	  
*add meaasurment of wealth one each at time 
global dv11 "Leduy Llincome edu_fm partypa i.Loccup lhouseasset "
global dv12 "Leduy Llincome edu_fm partypa i.Loccup lcompanyasset" 
global dv13 "Leduy Llincome edu_fm partypa i.Loccup lfinanceasset" 
global dv14 "Leduy Llincome edu_fm partypa i.Loccup lland_asset" 
global dv15 "Leduy Llincome edu_fm partypa i.Loccup lhouse_debts"
global dv16 "Leduy Llincome edu_fm partypa i.Loccup lnonhousing_debts"


*=====rural urban========= 
local dv "dv11 dv12 dv13 dv14 dv15 dv16"
*global ctr5 "age agesq han urbanhukou3 dagepa Lfamilysize hasbro i.region i.spell"
*global ctr5 "i.agegp han Lfarmhh Lnonagbushh dagepa Lfamilysize hasbro i.region i.spell"

foreach x of local dv{
qui: logit married $`x' $ctr5 if male==0 & urbanhukou10==1
eststo  female_mar_`x'_urban

qui: logit married $`x' $ctr5 if male==0 & urbanhukou10==0
eststo  female_mar_`x'_rural


qui: logit married $`x' $ctr5 if male==1 & urbanhukou10==1
eststo  male_mar_`x'_urban

qui: logit married $`x' $ctr5 if male==1 & urbanhukou10==0
eststo  male_mar_`x'_rural
}


esttab female_mar_dv11_rural female_mar_dv12_rural female_mar_dv13_rural female_mar_dv14_rural female_mar_dv15_rural female_mar_dv16_rural using "$tables\logit_female_asset_rural.rtf",   ///
      nonumbers mtitles label b(%9.3f)  se(%9.3f) noomitted  replace 

esttab female_mar_dv11_urban female_mar_dv12_urban female_mar_dv13_urban female_mar_dv14_urban female_mar_dv15_urban female_mar_dv16_urban using "$tables\logit_female_asset_urban.rtf",   ///
      nonumbers mtitles label b(%9.3f)  se(%9.3f) noomitted  replace 	  


esttab male_mar_dv11_rural male_mar_dv12_rural male_mar_dv13_rural male_mar_dv14_rural male_mar_dv15_rural male_mar_dv16_rural using "$tables\logit_male_asset_rural.rtf",   ///
      nonumbers mtitles label b(%9.3f)  se(%9.3f) noomitted  replace 

esttab male_mar_dv11_urban male_mar_dv12_urban male_mar_dv13_urban male_mar_dv14_urban male_mar_dv15_urban male_mar_dv16_urban using "$tables\logit_male_asset_urban.rtf",   ///
      nonumbers mtitles label b(%9.3f)  se(%9.3f) noomitted  replace 	 
	  	  
	  
	  
logit married $dv4 $ctr1 if male==0 
eststo  female_mar_dv4

logit married $dv4 $ctr1 if male==1 
eststo  male_mar_dv4
	  
esttab male_mar_dv4 female_mar_dv4 using "$tables\logit_male_mar4.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 

	  
logit married $dv5 $ctr4 if male==0 
eststo  female_mar_dv5

logit married $dv5 $ctr4 if male==1 
eststo  male_mar_dv5
	  
esttab male_mar_dv5 female_mar_dv5 using "$tables\logit_male_mar5.rtf",   ///
      nonumbers mtitles label eform  ci(%9.2f) noomitted  replace 	  
	  

*logit married $dv $ctr if male==0 & urban==1 &  nonaghukou10==1 
	   
*===========competing risk=========================	  

local dv "dv1 dv2 dv3 dv4 "
foreach x of local dv{

display "Female"
logit marstay $`x'$ctr1 if male==0 
eststo  female_stay_`x'

display "Male"
logit marstay $`x'  $ctr1 if male==1 
eststo  male_stay_`x'
}

*female 
esttab female_stay_dv1 female_stay_dv2 female_stay_dv3 female_stay_dv4 using "$tables\stay_female.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

*male 
esttab male_stay_dv1 male_stay_dv2 male_stay_dv3 male_stay_dv4 using "$tables\stay_male.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 



local dv "dv1 dv2 dv3 dv4 "
foreach x of local dv{

display "Female"
logit marleave $`x' $own $ctr1 if male==0 
eststo  female_leave_`x'

display "Male"
logit marleave $`x'  $own  $ctr1 if male==1 
eststo  male_leave_`x'
}

*female 
esttab female_leave_dv1 female_leave_dv2 female_leave_dv3 female_leave_dv4 using "$tables\leave_female.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 

*male 
esttab male_leave_dv1 male_leave_dv2 male_leave_dv3 male_leave_dv4 using "$tables\leave_male.rtf",   ///
      nonumbers mtitles label b(%9.3f) se(%9.3f) noomitted  replace 


logit marstay $dv2 $ctr1 if male==0 
eststo  female_stay

logit marstay $dv2  $ctr1 if male==1 
eststo male_stay


logit marleave $dv2  $ctr1 if male==0 
eststo  female_leave

logit marleave $dv2  $ctr1  if male==1 
eststo male_leave

	  	  
esttab female_stay female_leave male_stay  male_leave  using "$tables\competing.rtf",   ///
      nonumbers mtitles  b(%9.3f) se(%9.3f)  label   replace 	 
 	  

// *multinomial 
//
// mlogit compr $dv $ctr if male==0 , base(2)
// eststo  female_comp
// mlogit compr $dv $ctr if male==1 , base(2)
// eststo male_comp
//
// esttab female_comp male_comp  using "$tables\mlogit_base1.rtf",   ///
//       nonumbers mtitles label eform  ci(%9.2f) noomitted  replace  
//
//
//
// esttab female_comp male_comp  using "$tables\mlogit_base2.rtf",   ///
//       nonumbers mtitles label eform  ci(%9.2f) noomitted  replace  


  
*=========rural urban differences=========================
global dv2 "i.educ_fm lassetp10 lassetn10 partypa Leduy Llincome i.Loccup"  

*stay , urban
 logit marstay $dv2 $ctr5 if male==0 & urbanhukou10==1, or
eststo  female_stay_urban
 logit marstay $dv2 $ctr5 if male==1 & urbanhukou10==1, or
eststo male_stay_urban

*stay , rural 
 logit marstay $dv2 $ctr5  if male==0 & urbanhukou10==0, or
eststo  female_stay_rural

 logit marstay $dv2 $ctr5 if male==1 & urbanhukou10==0, or
eststo  male_stay_rural

*Llivepa predict failure perfectly for rural female.
*tab  Llivepa marstay if marstay !=. & Llivepa !=. & male==0 & urban==0

*leave , urban  
logit marleave $dv2 $ctr5 if male==0 & urbanhukou10==1, or
eststo  female_leave_urban
logit marleave $dv2 $ctr5  if male==1 & urbanhukou10==1, or
eststo male_leave_urban

*leave , rural   
 logit marleave $dv2 $ctr5  if male==0 & urbanhukou10==0, or
eststo  female_leave_rural
 logit marleave $dv2 $ctr5   if male==1 & urbanhukou10==0, or
eststo  male_leave_rural


/* stay, rural urban comparison 
esttab  male_stay_urban male_stay_rural  female_stay_urban  female_stay_rural    using "$tables\logit_stay.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 

* leave, rural urban comparison 
esttab male_leave_urban  male_leave_rural female_leave_urban female_leave_rural using "$tables\logit_leave.rtf",   ///
      nonumbers mtitles  eform  ci(%9.2f) noomitted  replace 	  
*/	  
	  
* male 
esttab  male_stay_urban male_leave_urban  male_stay_rural   male_leave_rural  using "$tables\logit_male.rtf",   ///
      nonumbers mtitles  b(%9.3f)  se(%9.3f) noomitted la replace 
	  
*female 
esttab  female_stay_urban female_leave_urban female_stay_rural  female_leave_rural  using "$tables\logit_female.rtf",   ///
      nonumbers mtitles  b(%9.3f)  se(%9.3f) noomitted  la replace 
	  
*urban 
esttab female_stay_urban female_leave_urban male_stay_urban male_leave_urban using "$tables\competing_urban.rtf",   ///
      nonumbers mtitles  b(%9.3f)  se(%9.3f) noomitted la replace 

*rural 
esttab female_stay_rural female_leave_rural male_stay_rural male_leave_rural using "$tables\competing_rural.rtf",   ///
      nonumbers mtitles  b(%9.3f)  se(%9.3f) noomitted la replace 	  

	  
*stay, leave as competing risk 
esttab female_stay_urban male_stay_urban female_stay_rural male_stay_rural using "$tables\compting_stay.rtf",   ///
      nonumbers mtitles  b(%9.3f)  se(%9.3f) noomitted la replace 

	  
*leave, stay as competing risk 
esttab female_leave_urban male_leave_urban female_leave_rural male_leave_rural using "$tables\compting_leave.rtf",   ///
      nonumbers mtitles  b(%9.3f)  se(%9.3f) noomitted la replace 	  
