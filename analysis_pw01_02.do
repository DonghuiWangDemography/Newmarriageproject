* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: what type of marriage ego involved (spousal age, ed)
* created on 03172019 



clear all 
global date "07182019"   // mmddyy
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 


*use "${datadir}\pw_a.dta", clear   //missing as high hazard of event occurance 
*use "${datadir}\pw_b.dta", clear  // low 


*compensation: family ses, own ses, physical attractiveness 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen    
*merge 1:1 pid using "${datadir}\spouseinfo.dta", nogen   // around 20% of spousal inforamtion is missing for newlyweds  
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
*10
g 		ltasset10=log(total_asset_10hh2+1) if total_asset_10hh2>0
replace ltasset10=0 if total_asset_10hh2==0


egen passet10 =rowtotal(houseasset10 companyasset10 financeasset_gross land_asset_10hh2 valuable_10hh2 otherasset_10hh2)
egen nasset10= rowtotal(house_debts10 nonhousing_debts)
g lasset10_p=log(passet10+1)
g lasset10_n=log(nasset10+1)


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


*alternative measure of wealth: wealth ranks? 



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
local var "alivefm livepa eduy educ occup income fincome lassetp lassetn fincomeper 
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



misschk edu_fm lassetp10 Leduy Llincome dagepa han urbanhukou10  urbanhukou3 Llivepa Lfarmhh Lnonagbushh hasbro Lfamilysize, gen(all)
// missing in any covariates : 2.87

*drop the person as far as he/she has one missing in covariates 
bysort pid: egen missing=max(allnumber)  
keep if missing==0

// misschk Leduy Llincome edu_fm  partypa lasset_p lasset_n Llfincome  ///	
//         han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro

misschk Leduy Llincome edu_fm  partypa lassetp10    ///	
        han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro //M=5309
*===========descriptives ===========
#delimit;
table1, vars( married bin \ marstay bin \marleave  bin \ edu_fm contn \lassetp10 contn \ passet10 contn  \ Loccup cat \ 
              Leduy  contn \ Llincome contn  \ Lincome contn  \ ftree10  bin \ grave10 bin  \
             age contn \ Lfarmhh bin\ Lnonagbushh bin \ dagepa contn \ hasbro bin \ Lfamilysize contn \ region cat )      
         by (gr) format(%2.1f)  test saving("$tables\desc_dv_pw2.xls", replace) ;
delimit cr 

*% married & living arragement 
#delimit;
table1, vars(edu_fm contn \lassetp10 contn \ passet10 contn
              Leduy  contn \ Llincome contn  \ Lincome contn 
             age contn \ Lfarmhh bin\ Lnonagbushh bin \ dagepa contn \ hasbro bin \ Lfamilysize contn \ region cat )      
         by (married) format(%2.1f)  test saving("$tables\desc2_pw2.xls", replace) ;
delimit cr 


*=====first stage: entry into marriage=================		 
log using "${logs}\marriage_$date",replace 
// global dv1 "edu_fm lassetp10                 sp1 sp2 sp3 dagepa han urbanhukou3 Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize i.region i.spell"
// global dv2 "edu_fm lassetp10 Leduy Llincome  sp1 sp2 sp3 dagepa han urbanhukou3 Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize i.region i.spell"

global dv1 "edu_fm lassetp10                  i.spell"
global dv2 "edu_fm lassetp10 Leduy Llincome   i.spell"


global ctr "sp1 sp2 sp3 dagepa han  Llivepa Lfarmhh Lnonagbushh  hasbro Lfamilysize i.region i.spell"




local dv "dv1 dv2"
foreach x of local dv{
display "==> urban female"
*	logit married $`x'  if male==0 & urbanhukou10==1 , or vce(bootstrap, reps(1000))
	logit married $`x'  if male==0 & urbanhukou10==1 ,  vce(robust)
	margins, dydx(edu_fm lassetp10)
	mat c=r(table)
	mat ci_uf_`x'=c["ll".."ul",1..2]
	mat b_uf_`x'=r(b)
	mat se_uf_`x'=c["se", 1..2]
	mat p_uf_`x'=c["pvalue", 1..2]
	
	margins, dydx(lassetp10)
	
	
eststo  female_mar_`x'_urban

display "==>urban male"
*	logit married $`x'   if male==1 & urbanhukou10==1, or vce(bootstrap, reps(1000))
	logit married $`x'   if male==1 & urbanhukou10==1, vce(robust)
	margins, dydx(edu_fm lassetp10)
    mat c=r(table)
	mat ci_um_`x'=c["ll".."ul",1..2]
	mat b_um_`x'=r(b)
	mat se_um_`x'=c["se", 1..2]
	mat p_um_`x'=c["pvalue", 1..2]
	
eststo  male_mar_`x'_urban


display "==> rural female"
*	logit married $`x'   if male==0 & urbanhukou10==0, or vce(bootstrap, reps(1000))
	logit married $`x'   if male==0 & urbanhukou10==0,  vce(robust)

	margins, dydx(edu_fm lassetp10)
	mat c=r(table)
	mat ci_rf_`x'=c["ll".."ul",1..2]
	mat b_rf_`x'=r(b)
	mat se_rf_`x'=c["se", 1..2]
	mat p_rf_`x'=c["pvalue", 1..2]
	
eststo  female_mar_`x'_rural


display "==> rural male"

*	logit married $`x' i.spell if male==1 & urbanhukou10==0, or vce(bootstrap, reps(1000))
	logit married $`x' i.spell if male==1 & urbanhukou10==0, vce(robust)

	margins, dydx(edu_fm lassetp10)
    mat c=r(table)
	mat ci_rm_`x'=c["ll".."ul",1..2]
	mat b_rm_`x'=r(b)
	mat se_rm_`x'=c["se", 1..2]
	mat p_rm_`x'=c["pvalue", 1..2]
	
eststo  male_mar_`x'_rural
}

*rural 
esttab female_mar_dv1_rural female_mar_dv2_rural  ///
	   male_mar_dv1_rural   male_mar_dv2_rural   ///
       using "$tables\bmarriage_rural_$date.rtf",   ///
       nonumbers mtitles  b(%9.2f)  se(%9.2f) noomitted la replace 
	   
*urban
esttab female_mar_dv1_urban female_mar_dv2_urban  ///
	   male_mar_dv1_urban   male_mar_dv2_urban   ///
       using "$tables\bmarriage_urban_$date.rtf",   ///
       nonumbers mtitles  b(%9.2f)  se(%9.2f) noomitted la replace  	   
	   

*average marginal effects 
local gr "uf um rf rm"
foreach x of local gr{
mat `x'_dv1=b_`x'_dv1[1,1] \se_`x'_dv1[1,1] \ b_`x'_dv1[1,2] \ se_`x'_dv1[1,2]
mat `x'_dv2=b_`x'_dv2[1,1] \ se_`x'_dv2[1,1] \ b_`x'_dv2[1,2] \ se_`x'_dv2[1,2]
}

mat ame_u=uf_dv1,uf_dv2,um_dv1,um_dv2
mat ame_r=rf_dv1,rf_dv2,rm_dv1,rm_dv2

mat rownames ame_u= b_edu se_edu b_asset se_asset
mat colnames ame_u=female_m1 female_m2 male_m1 male_m2 

mat rownames ame_r= b_edu se_edu b_asset se_asset
mat colnames ame_r=female_m1 female_m2 male_m1 male_m2 

mat list ame_u, format(%9.3f)
mat list ame_r, format(%9.3f)



*=====AME of own SES======
qui: logit married $dv2  if male==0 & urbanhukou10==1 ,  vce(robust)
	 margins, dydx(Leduy Llincome)
	 mat own_uf=r(b)

qui: logit married $dv2  if male==1 & urbanhukou10==1 ,  vce(robust)
	 margins, dydx(Leduy Llincome)
	 mat own_um=r(b)
	 
	 	 
qui: logit married $dv2  if male==0 & urbanhukou10==0 ,  vce(robust)
	 margins, dydx(Leduy Llincome)
	 mat own_rf=r(b)
	 
qui: logit married $dv2  if male==1 & urbanhukou10==0 ,  vce(robust)
	 margins, dydx(Leduy Llincome)
	 mat own_rm=r(b)	 

mat ame_uo=own_uf',own_um'
mat ame_ro=own_rf',own_rm'

mat list ame_uo, format(%9.3f)
mat list ame_ro, format(%9.3f)

*===========graphing============

// coefplot  (matrix(b_uf_dv1) ,ci(ci_uf_dv1) label(female_m1) )  ///
// 		     (matrix(b_um_dv1), ci(ci_um_dv1) label(male_m1))  ,   ///
// 		   yline(0) msymbol(S)    vertical title("Average Marginal Effects (Urban)")
// graph save Graph "${graphs}\ame_urbanmarriagem1_$date.gph",replace



coefplot  (matrix(b_uf_dv1) ,ci(ci_uf_dv1) label(female_m1) )  ///
		  (matrix(b_uf_dv2),ci(ci_uf_dv2) label(female_m2))  ///
		  (matrix(b_um_dv1),ci(ci_um_dv1) label(male_m1))  ///
		  (matrix(b_um_dv2),ci(ci_um_dv2) label(male_m2)) , ///
		   yline(0) msymbol(S)    vertical title("Average Marginal Effects (Urban)")
graph save Graph "${graphs}\ame_urbanmarriage_$date.gph",replace


coefplot  (matrix(b_rf_dv1),ci(ci_rf_dv1) label(female_m1) )  ///
		  (matrix(b_rf_dv2),ci(ci_rf_dv2) label(female_m2) )  ///
		  (matrix(b_rm_dv1),ci(ci_rm_dv1) label(male_m1) )  ///
		  (matrix(b_rm_dv2),ci(ci_rm_dv2) label(male_m2)) , ///
		  yline(0) msymbol(S)   vertical   title("Average Marginal Effects (Rural)")
graph save Graph "${graphs}\ame_ruralmarriage_$date.gph",replace

log close

graph use  "${graphs}\ame_urbanmarriage_$date.gph"
graph use  "${graphs}\ame_ruralmarriage_$date.gph"


*=========KHB===================
log using "${logs}\KHBmarriage_$date.log", replace

* rural female 	  
khb logit married edu_fm lassetp10  || Leduy Llincome if  male==0 & urbanhukou10==0 ,  ///
c($ctr) ape summary

eststo female_rural 

* rural male 	  
khb logit married edu_fm lassetp10  || Leduy Llincome if  male==1 & urbanhukou10==0 ,  ///
c($ctr) summary
eststo male_rural 

*urban female 
khb logit married edu_fm lassetp10  || Leduy Llincome if  male==0 & urbanhukou10==1 ,  ///
c($ctr)  summary
eststo female_urban


*urban male
khb logit married edu_fm lassetp10  || Leduy Llincome if  male==1 & urbanhukou10==1 ,  ///
c($ctr)  summary
eststo male_urban

esttab female_rural male_rural female_urban male_urban  using "$tables\khbmarriage_$date.rtf",  ///
       b(%9.3f)  se(%9.3f) mtitles 

log close 

	   
*===========competing risk=========================	 
log using "${logs}\stay_$date.log" ,replace

*stay, leave as competing risk 		
local dv "dv1 dv2"
foreach x of local dv{
display "==> urban female"
	logit marstay $`x'  if male==0 & urbanhukou10==1 , or vce(bootstrap, reps(1000))
*	logit marstay $`x'  if male==0 & urbanhukou10==1 , or vce(robust)
	margins, dydx(edu_fm lassetp10)
	mat c=r(table)
	mat ci_uf_`x'=c["ll".."ul",1..2]
	mat b_uf_`x'=r(b)
	
	
eststo  female_stay_`x'_urban

display "==>urban male"
	logit marstay $`x'   if male==1 & urbanhukou10==1, or vce(bootstrap, reps(1000))
*	logit marstay $`x'  if male==1 & urbanhukou10==1 , or vce(robust)

	margins, dydx(edu_fm lassetp10)
    mat c=r(table)
	mat ci_um_`x'=c["ll".."ul",1..2]
	mat b_um_`x'=r(b)
	
eststo  male_stay_`x'_urban


display "==> rural female"
	logit marstay $`x'   if male==0 & urbanhukou10==0, or vce(bootstrap, reps(1000))
	*logit marstay $`x'   if male==0 & urbanhukou10==0, or vce(robust)

	margins, dydx(edu_fm lassetp10)
	mat c=r(table)
	mat ci_rf_`x'=c["ll".."ul",1..2]
	mat b_rf_`x'=r(b)
	
eststo  female_stay_`x'_rural


display "==> rural male"

	logit marstay $`x' i.spell if male==1 & urbanhukou10==0, or vce(bootstrap, reps(1000))
*	logit marstay $`x' i.spell if male==1 & urbanhukou10==0, or vce(robust)

	margins, dydx(edu_fm lassetp10)
    mat c=r(table)
	mat ci_rm_`x'=c["ll".."ul",1..2]
	mat b_rm_`x'=r(b)

eststo  male_stay_`x'_rural
}

*rural 
// esttab female_stay_dv1_rural female_stay_dv2_rural  ///
// 	   male_stay_dv1_rural   male_stay_dv2_rural   ///
//        using "$tables\stay_rural_$date.rtf",   ///
//        nonumbers mtitles  eform  ci(%9.2f) noomitted la replace 
//	   
// *urban
// esttab female_stay_dv1_urban female_stay_dv2_urban  ///
// 	   male_stay_dv1_urban   male_stay_dv2_urban   ///
//        using "$tables\stay_urban_$date.rtf",   ///
//        nonumbers mtitles  eform  ci(%9.2f) noomitted la replace  


*rural 
esttab female_stay_dv1_rural female_stay_dv2_rural  ///
	   male_stay_dv1_rural   male_stay_dv2_rural   ///
       using "$tables\stay_rural_$date.rtf",   ///
       nonumbers mtitles  b(%9.2f)  se(%9.2f)  noomitted la replace 
	   
*urban
esttab female_stay_dv1_urban female_stay_dv2_urban  ///
	   male_stay_dv1_urban   male_stay_dv2_urban   ///
       using "$tables\stay_urban_$date.rtf",   ///
       nonumbers mtitles   b(%9.2f)  se(%9.2f)  noomitted la replace  
	   

*average marginal effects 
mat ame_u=b_uf_dv1',b_uf_dv2',b_um_dv1',b_um_dv2'
mat ame_r=b_rf_dv1',b_rf_dv2',b_rm_dv1',b_rm_dv2'

mat colnames ame_u=female_m1 female_m2 male_m1 male_m2 
mat colnames ame_r=female_m1 female_m2 male_m1 male_m2 

mat list ame_u, format(%9.3f)
mat list ame_r, format(%9.3f)

*===========graphing============

coefplot  (matrix(b_uf_dv1) ,ci(ci_uf_dv1) label(female_m1) )  ///
		  (matrix(b_uf_dv2),ci(ci_uf_dv2) label(female_m2))  ///
		  (matrix(b_um_dv1),ci(ci_um_dv1) label(male_m1))  ///
		  (matrix(b_um_dv2),ci(ci_um_dv2) label(male_m2)) , ///
		   yline(0) msymbol(S)   byopts(xrescale)  vertical title("Average Marginal Effects (Urban)")
graph save Graph "${graphs}\ame_urbanstay_$date.gph",replace


graph use "${graphs}\ame_urbanstay_$date.gph"

coefplot  (matrix(b_rf_dv1),ci(ci_rf_dv1) label(female_m1) )  ///
		  (matrix(b_rf_dv2),ci(ci_rf_dv2) label(female_m2) )  ///
		  (matrix(b_rm_dv1),ci(ci_rm_dv1) label(male_m1) )  ///
		  (matrix(b_rm_dv2),ci(ci_rm_dv2) label(male_m2)) , ///
		  yline(0) msymbol(S)   byopts(xrescale) vertical   title(" Average Marginal Effects (Rural)")
graph save Graph "${graphs}\ame_ruralstay_$date.gph",replace

graph use "${graphs}\ame_ruralstay_$date.gph"


log close 



	   
*leave, stay  as competing risk 
log using "${logs}\leave_$date.log" ,replace

local dv "dv1 dv2"
foreach x of local dv{
display "==> urban female"
*	logit marleave $`x'  if male==0 & urbanhukou10==1 , or vce(bootstrap, reps(1000))
	logit marleave $`x'  if male==0 & urbanhukou10==1 , or vce(robust)

	margins, dydx(edu_fm lassetp10)
	mat c=r(table)
	mat ci_uf_`x'=c["ll".."ul",1..2]
	mat b_uf_`x'=r(b)
	
	
eststo  female_leave_`x'_urban

display "==>urban male"
*	logit marleave $`x'   if male==1 & urbanhukou10==1, or vce(bootstrap, reps(1000))
	logit marleave $`x'   if male==1 & urbanhukou10==1, or vce(robust)

	margins, dydx(edu_fm lassetp10)
    mat c=r(table)
	mat ci_um_`x'=c["ll".."ul",1..2]
	mat b_um_`x'=r(b)
	
eststo  male_leave_`x'_urban


display "==> rural female"
*logit marleave $`x'   if male==0 & urbanhukou10==0, or vce(bootstrap, reps(1000))
logit marleave $`x'   if male==0 & urbanhukou10==0, or vce(robust)

	margins, dydx(edu_fm lassetp10)
	mat c=r(table)
	mat ci_rf_`x'=c["ll".."ul",1..2]
	mat b_rf_`x'=r(b)
	
eststo  female_leave_`x'_rural


display "==> rural male"

*logit marleave $`x' i.spell if male==1 & urbanhukou10==0, or vce(bootstrap, reps(1000))
logit marleave $`x' i.spell if male==1 & urbanhukou10==0, or vce(robust)

	margins, dydx(edu_fm lassetp10)
    mat c=r(table)
	mat ci_rm_`x'=c["ll".."ul",1..2]
	mat b_rm_`x'=r(b)

eststo  male_leave_`x'_rural
}

// *rural 
// esttab female_leave_dv1_rural female_leave_dv2_rural  ///
// 	   male_leave_dv1_rural   male_leave_dv2_rural   ///
//        using "$tables\leave_rural.rtf",   ///
//        nonumbers mtitles  eform  ci(%9.2f) noomitted la replace 
//	   
// *urban
// esttab female_leave_dv1_urban female_leave_dv2_urban  ///
// 	      male_leave_dv1_urban   male_leave_dv2_urban   ///
//        using "$tables\leave_urban.rtf",   ///
//        nonumbers mtitles  eform  ci(%9.2f) noomitted la replace  
	   

*average marginal effects 
mat ame_u=b_uf_dv1',b_uf_dv2',b_um_dv1',b_um_dv2'
mat ame_r=b_rf_dv1',b_rf_dv2',b_rm_dv1',b_rm_dv2'

mat colnames ame_u=female_m1 female_m2 male_m1 male_m2 
mat colnames ame_r=female_m1 female_m2 male_m1 male_m2 

mat list ame_u, format(%9.3f)
mat list ame_r, format(%9.3f)

*===========graphing============

coefplot  (matrix(b_uf_dv1) ,ci(ci_uf_dv1) label(female_m1) )  ///
		  (matrix(b_uf_dv2),ci(ci_uf_dv2) label(female_m2))  ///
		  (matrix(b_um_dv1),ci(ci_um_dv1) label(male_m1))  ///
		  (matrix(b_um_dv2),ci(ci_um_dv2) label(male_m2)) , ///
		   yline(0) msymbol(S)   byopts(xrescale)  vertical title("Average Marginal Effects (Urban)")
graph save Graph "${graphs}\ame_urbanleave_$date.gph",replace


coefplot  (matrix(b_rf_dv1),ci(ci_rf_dv1) label(female_m1) )  ///
		  (matrix(b_rf_dv2),ci(ci_rf_dv2) label(female_m2) )  ///
		  (matrix(b_rm_dv1),ci(ci_rm_dv1) label(male_m1) )  ///
		  (matrix(b_rm_dv2),ci(ci_rm_dv2) label(male_m2)) , ///
		  yline(0) msymbol(S)   byopts(xrescale) vertical   title(" Average Marginal Effects (Rural)")
graph save Graph "${graphs}\ame_ruralleave_$date.gph",replace
	   
log close 
	   
graph use "${graphs}\ame_urbanleave_$date.gph"
graph use "${graphs}\ame_ruralleave_$date.gph"


*=======mechanism==========
*family ideal or conspicuous consumption ?
*Explore housing condition 
*hypothesis : better housing quality (square footage, housing type (only avaiable on 10)), more likely to live together 
*conspicuous consumption: car,funeral, other event expense 
*newlyweds only

*testing mechanism 
*family ideal hypothesis 	 
*local iv "edu_fm lassetp10 Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"
*local iv "edu_fm Llassetp   Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"
*local iv "edu_fm Lown_p    Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"
*local iv "edu_fm Lhouse_owned    Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"  // strong predictor of marriage transition 
*own employment does not have effect 

*global dv2 "edu_fm lassetp10  Leduy Llincome Lhouse_owned Lhouse_sqr Lotherhh  i.Loccup sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"  // strong predictor of marriage transition 

g tradition= (ftree10==1 & grave10==1)
*global dv2 "edu_fm c.lassetp10##i.ftree10  Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"
global dv2 "edu_fm c.lassetp10##i.tradition  Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro tradition i.region i.spell"

*local iv "edu_fm c.lassetp10##i.grave10  Leduy Llincome i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region i.spell"

*global dv2 "edu_fm lassetp10 Leduy Llincome i.Loccup i.spell"
*global dv3 "edu_fm lassetp10 Leduy Llincome i.Loccup  Lhouse_owned Lotherhh sp1 sp2 sp3 han  Lfarmhh Lnonagbushh urbanhukou3 partypa dagepa Lfamilysize hasbro i.region i.spell"

egen wealth=cut(lassetp10), group(3)
egen income=cut(Llincome), group(3)

global dv2 "edu_fm i.wealth##c.Llincome Leduy  i.Loccup Lhouse_sqr Lotherhh Lhouse_owned sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro  i.region i.spell"
*global dv2 "edu_fm c.lassetp10##i.income Leduy  i.Loccup  sp1 sp2 sp3 han Llivepa Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro  i.region i.spell"

*stay , rural 
 logit marstay $dv2    if male==0 & urbanhukou10==0, or
* margins, dydx(edu_fm) at(Leduy==0) at(Leduy==6) at(Leduy==9) at(Leduy==12) at(Leduy==16)
eststo  female_stay_rural

logit marstay $dv2  if male==1 & urbanhukou10==0, or
eststo  male_stay_rural


*stay , urban
logit marstay $dv2  if male==0 & urbanhukou10==1, or
eststo  female_stay_urban

logit marstay $dv2   if male==1 & urbanhukou10==1, or
eststo male_stay_urban

esttab female_stay_rural male_stay_rural female_stay_urban male_stay_urban using  "$tables\marry.rtf" ,    ///
       nonumbers mtitles  eform  ci(%9.2f) noomitted la replace 





*living arragement : married couple only 
*conditional on marriage, examine living arragement 
keep if marstat12==1 | marstat14==1 | marstat16==1  // N=1648

*=====live pa as Y========
gen 	livepa=livepa12 if marstat12==1 
replace livepa=livepa14 if marstat14==1  & marstat12==0
replace livepa=livepa16 if marstat16==1  & marstat14==0

*global iv "edu_fm Lhouse_sqr  Leduy Llincome i.Loccup  sp1 sp2 sp3 han  Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10 i.region "  // strong predictor of marriage transition 
global iv "edu_fm  lassetp10 Leduy Llincome i.Loccup  sp1 sp2 sp3 han  Lfarmhh Lnonagbushh  dagepa Lfamilysize hasbro ftree10 grave10  i.region "  // strong predictor of marriage transition 
 
logit livepa $iv if male==1 &  urbanhukou10==0
eststo  male_rural_livepa

logit livepa $iv if male==0 &  urbanhukou10==0
eststo  female_rural_livepa


logit livepa $iv if male==1 &  urbanhukou10==1
eststo  male_urban_livepa

logit livepa $iv if male==0 &  urbanhukou10==1
eststo  female_urban_livepa

esttab male_rural_livepa female_rural_livepa male_urban_livepa female_urban_livepa using  "$tables\marry.rtf" ,    ///
       nonumbers mtitles  eform  ci(%9.2f) noomitted la replace 
