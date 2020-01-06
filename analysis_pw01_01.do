* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: what type of marriage ego involved (spousal age, ed)
* created on 03172019 


* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* updated on 09242019: do not stratify by rural /urban hukou, prepare for paa 
* updated on 


clear all 
global date "01012020"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "C:\Users\wdhec\Desktop\Marriage"  // laptop 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 


*use "${datadir}\pw_a.dta", clear   //missing as high hazard of event occurance 
*use "${datadir}\pw_b.dta", clear  // low 


*compensation: family ses, own ses, physical attractiveness 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen    
*merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen   // around 20% of spousal inforamtion is missing for newlyweds  
merge 1:1 pid using "${datadir}\work_EHC.dta", nogen     // use only occupation of 10, 12,14, 16

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

	misschk marstay12  marstay14 marstay16
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

g female=(male==0)



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

*living preference 
rename sonstay_14a  sonstay
replace sonstay=. if sonsta==-1 

*parental education 
recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8),gen(eduy_fm_aux)
recode eduy_fm_aux (1=1 "less than primary") (2=2 "primary") (3=3 "middle school") (4/8=4 "high school and above"), gen(educ_fm)
drop   eduy_fm_aux

*-------family wealth--------
*10
g 		ltasset10=log(total_asset_10hh2+1) if total_asset_10hh2>0
replace ltasset10=0 if total_asset_10hh2==0

g tasset = total_asset_10hh2 /1000

egen passet10 =rowtotal(houseasset10 companyasset10 financeasset_gross land_asset_10hh2 valuable_10hh2 otherasset_10hh2)
egen nasset10= rowtotal(house_debts10 nonhousing_debts)

g lasset10_p=log(passet10+1)
g lasset10_n=log(nasset10+1)



// bysort pid : egen hasdebt=sum(nasset10>0)
// unique fid if hasdebt ==0 
// unique fid if hasdebt >0 


*family wealth exclude housing value 
egen wnohh=rowtotal(companyasset10 financeasset_gross land_asset_10hh2 valuable_10hh2 otherasset_10hh2) 
g lwnohh=log(wnohh +1) 
replace lwnohh =0 if wnohh ==0


*family wealth per capita
g lwealthp= log((passet10/familysize10)+1)
replace lwealthp=0 if passet10==0


*12 
g ltasset12=log(total_asset_12hh2+1) if total_asset_12hh2>0
replace ltasset12=0 if total_asset_12hh2==0

egen passet12=rowtotal(land_asset_12hh2 houseasset_gross_12hh2 finance_asset_12hh2 fixed_asset_12hh2 durables_asset_12hh2) 
egen nasset12=rowtotal(house_debts_10hh2 houseother_debts_12hh2)

g lasset12_p=log(passet12+1)
g lasset12_n=log(nasset12+1)

*14 
g       ltasset14=log(total_asset_14hh2+1) if total_asset_14hh2>0
replace ltasset14=0 if total_asset_14hh2==0

egen passet14=rowtotal(land_asset_14hh2 houseasset_gross_14hh2 finance_asset_14hh2 fixed_asset_14hh2 durables_asset_14hh2) 
egen nasset14=rowtotal(house_debts_14hh2 nonhousing_debts_14hh2)

g lasset14_p=log(passet14+1)
g lasset14_n=log(nasset14+1)




*detailed measure of wealth and asset : housing, land and other asset 

*2010 asset : land (land_asset_10hh2), housing asset (houseasset_net10, houseasset10), company, valuable , other,  finance 

sum houseasset10  land_asset_10hh2 companyasset10 financeasset_gross valuable_10hh2 otherasset_10hh2

g 		lhouseasset=log(houseasset10+1)
replace lhouseasset=0 if houseasset10==0

g       lcompanyasset=log(companyasset10+1)
replace lcompanyasset=0 if companyasset10==0

g 		lfinanceasset=log(financeasset_gross+1)
replace lfinanceasset=0 if financeasset_gross==0

g       lland_asset =log(land_asset_10hh2+1)
replace lland_asset=0 if land_asset_10hh2==0

g 		lvaluble= log(valuable_10hh2+1)
replace lvaluble= 0 if valuable_10hh2 ==0

g 		lotherasset = log(otherasset_10hh2 +1)
replace lotherasset =0 if otherasset_10hh2 ==0 

g 		lhouse_debts=log(house_debts10+1)
replace lhouse_debts=0 if house_debts10==0

g       lnonhousing_debts=log(nonhousing_debts+1)
replace lnonhousing_debts=0 if nonhousing_debts==0

*calculate pct to total asset 



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


*save "${datadir}\cross.dta", replace 


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


*---------lag time-varying predictors by one-wave : education, work, income housing condition migrant familyincome

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
local var "alivefm livepa eduy educ occup income fincome lassetp lassetn fincomeper 
           house_owned house_sqr own_p otherhh houseasset house_debts  
		   nonaghukou migrant  familysize farmhh nonagbushh chhp " ;
#delimit cr

foreach x of local var {
g        L`x'= `x'10  if spell==1  		      // 10 -12 wave , use wave10 as predictor 
replace  L`x'= `x'12  if spell==2             // 12-14 wave, wave12 predictor
replace  L`x'= `x'10  if spell==2 & `x'12==.  // if missing, use wave 10 predictor
 
replace  L`x'= `x'14  if spell==3      //14-16 wave, wave14 as predictor  
replace  L`x'= `x'12  if spell==3 & `x'14==.
replace  L`x'= `x'10  if spell==3 & `x'14==. & `x'12==.
}

* log county housing price 
g Llchhp=log(Lchhp+1)


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

*debt to value ratio
g dtv=Lhouse_debts/Lhouseasset     //housing debt to asset ratio 
la var dtv "housing debt to value ratio"



misschk edu_fm lassetp10 Leduy Llincome dagepa han urbanhukou10  Llivepa Lfarmhh Lnonagbushh hasbro Lfamilysize lhouseasset lwnohh ///
        Llchhp lhouseasset lcompanyasset  lland_asset lfinanceasset lvaluble lotherasset , gen(all)
// missing in any covariates : 2.87
// missing in sonstay = 1718 (32 %) 

*drop the person as far as he/she has one missing in covariates 
bysort pid: egen missing=max(allnumber)  
keep if missing==0



misschk Leduy Llincome edu_fm  partypa lassetp10    ///	
        han urbanhukou10 Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro Llchhp //M=5309
*===========descriptives ===========
// #delimit;
// table1, vars( married bin \ marstay bin \marleave  bin \ edu_fm contn \lassetp10 contn \ passet10 contn  \
//               Leduy  contn \ Llincome contn  \ Lincome contn  \
//              age contn \ Lfarmhh bin\  urbanhukou10 bin \ Lnonagbushh bin \ dagepa contn \ hasbro bin \ Lfamilysize contn \ region cat )      
//          by (female) format(%2.1f)  test saving("$tables\desc_all.xls", replace) ;
// delimit cr 


g sqwealth=lassetp10*lassetp10

g brolive=(nbro_alive_cor>0)

egen bro=group(hasbro brolive)
la def bro 1"no bros"  2"has bro not together" 3 "bro living together" , modify 
la val bro bro 


*----------Regression ---------- 

*M1 gender differences of total wealth 
*local ctrl "sp1 sp2 sp3 dagepa han  partypa Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize  urbanhukou10 i.region i.spell "

global iv1 " Lotherhh            sp1 sp2 sp3 dagepa han  partypa Llivepa Lfarmhh Lnonagbushh  bro Lfamilysize  urbanhukou10 i.region i.spell "
*global iv1 "c.tasset##i.female  sp1 sp2 sp3 dagepa han  partypa Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize  urbanhukou10 i.region i.spell "

*global iv1 "c.Llassetp##i.female    c.Llassetn##i.female sp1 sp2 sp3 dagepa han  partypa Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize  urbanhukou10 i.region i.spell"
*global iv2 "c.Llassetp##i.female    c.Llassetn##i.female edu_fm Leduy Llincome  sp1 sp2 sp3 dagepa han partypa  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize  urbanhukou10 i.region i.spell"

*global iv2 "c.ltasset10##i.female edu_fm Leduy Llincome  sp1 sp2 sp3 dagepa han partypa  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize  urbanhukou10 i.region i.spell"
*global iv2 "c.lasset10_p##i.female c.lasset10_n##i.female"


local dv "married marstay marleave"
local iv "iv1 iv2"

foreach y of local dv {
foreach x of local iv { 
	logit `y' $`x'  if hasbro ==0 , or vce(robust)
    est store   m1_`y'_`x'
} 
}

esttab m1_married_iv1   m1_married_iv2  ///
       using "$tables\m1_married.rtf",   ///
       nonumbers mtitles  b(%9.2f)  wide se(%9.2f) noomitted la replace 

esttab m1_marstay_iv1   m1_marstay_iv2  ///
       using "$tables\m1_marstay.rtf",   ///
       nonumbers mtitles  b(%9.2f) wide se(%9.2f) noomitted la replace 

esttab m1_marleave_iv1   m1_marleave_iv2  ///
       using "$tables\m1_marleave.rtf",   ///
       nonumbers mtitles  b(%9.2f) wide  se(%9.2f) noomitted la replace 
	   

*M2 gender differences of wealth category 
local ctrl "sp1 sp2 sp3 dagepa han  partypa Llivepa Lfarmhh Lnonagbushh  bro Llfincomeper  Lfamilysize  urbanhukou10 i.region i.spell Lchhp"
global iv1 "c.lhouseasset##i.female c.lwnohh##i.female c.lhouse_debts##i.female c.lnonhousing_debts##i.female"
global iv2 "c.lhouseasset##i.female c.lcompanyasset##i.female  c.lland_asset##i.female c.lfinanceasset##i.female c.lvaluble##i.female c.lotherasset##i.female c.lhouse_debts##i.female c.lnonhousing_debts##i.female" 
*global iv1 "c.lhouseasset##i.female c.lwnohh##i.female c.lhouse_debts##i.female c.lnonhousing_debts##i.female"


local dv "married marstay marleave"
local iv "iv1 iv2"

foreach y of local dv {
foreach x of local iv { 
	logit `y' $`x' `ctrl' , or vce(robust)
    est store   m2_`y'_`x' 
} 
}

esttab m2_married_iv1  m2_marstay_iv1  m2_marleave_iv1   ///
       using "$tables\m2_iv1.rtf",   ///
       nonumbers mtitles  b(%9.2f)  wide se(%9.2f) noomitted la replace 
	   
esttab m2_married_iv2  m2_marstay_iv2  m2_marleave_iv2   ///
       using "$tables\m2.rtf",   ///
       nonumbers mtitles  b(%9.2f)  wide se(%9.2f) noomitted la replace 

*M3: the role of housing 
* Lhouse_owned Lotherhh, Lhouse_sqr Lhouseasset Lhouse_debts

local ctrl "lassetp10 sp1 sp2 sp3 dagepa han  partypa Llivepa Lmigrant Lfarmhh Lnonagbushh  i.bro Lfamilysize Llfincomeper  urbanhukou10 i.region i.spell  Lchhp"
*global iv1 "Lhouse_owned##i.female Lotherhh##i.female nodifficulty10##i.female c.Lhouse_sqr##i.female c.lhouseasset##i.female  c.lhouse_debts##i.female "
*global iv1 "c.Lhouse_owned otherhh10##i.female nodifficulty10 c.Lhouse_sqr  c.lhouseasset  c.lhouse_debts "
global iv1 "otherhh10"


local dv "married marstay marleave"
local iv "iv1"

foreach y of local dv {
foreach x of local iv { 
	logit `y' $`x' `ctrl' , or vce(robust)
    est store   m3_`y'_`x' 
} 
}


esttab m3_married_iv1  m3_marstay_iv1  m3_marleave_iv1   ///
       using "$tables\m3.rtf",   ///
       nonumbers mtitles  b(%9.2f)  wide se(%9.2f) noomitted la replace 

	   
*-----the role of childbearing--------
*do those who live at parental home more likely to have children immedient after marriage ?

use  "${datadir}\cross.dta", clear 

// misschk nchildren*
// assert nchildren_10hh <= nchildren_12hh
// assert nchildren_12hh <= nchildren_14hh
// assert nchildren_14hh <= nchildren_16hh


*consider first born only 
// g       newborn12=1 if nchildren_10hh==0 & nchildren_12hh>0
// replace newborn12=0 if nchildren_10hh==0 & nchildren_12hh==0
//
// g       newborn14=1 if nchildren_12hh==0 & nchildren_14hh>1
// replace newborn14=0 if nchildren_12hh==0 & nchildren_14hh==0
//
// g       newborn16=1 if nchildren_14hh==0 & nchildren_16hh>1
// replace newborn16=0 if nchildren_14hh==0 & nchildren_16hh==0

* marriage as absorbing state, recode outcome ??
* 1. marry & children & stay
* 2. marry & children & move 
* 3. marry & nochildren & stay 
* 4. marry & nochildren & move 



// replace mar_ymin=.  if mar_ymin>2017
// g bdur=byr_children-mar_ymin if inrange(mar_ymin, 2010, 2017) & inrange(byr_children, 2010, 2017)


* H: wealthy family have higher ability to influnce newly couples childbearing decisions 
* conditional on marriage, if 
