
* dataformat:person-wave instead of person-year
* use expand command instead of reshape 

* Task: pooled cross sectional 

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


*conditional on marriage, examine living arragement 
keep if marstat12==1 | marstat14==1 | marstat16==1   // N=999

*=====Y========
gen 	livepa=livepa12 if marstat12==1 
replace livepa=livepa14 if marstat14==1  & marstat12==0
replace livepa=livepa16 if marstat16==1  & marstat14==0

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



* percentile calculated from sample (robust to age cutoff)
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




*homeownership 
rename own_p_*hh2 own_p*
rename own_f_*hh2 own_f*
rename own_m_*hh2 own_m*

rename  lasset*_p  lassetp*
rename  lasset*_n  lassetn*


local var "alivefm livepa eduy educ occup  house_owned house_sqr otherhh houseasset nonaghukou migrant familysize farmhh nonagbushh"
foreach x of local var {
g       L`x'= `x'10  if marstat12==1    // marry in 12, use variable in 10 
replace L`x'=`x'12   if marstat12==1  & L`x'==.   //replace with the var measured at the time of the survey 
 
replace L`x'= `x'12  if marstat14==1 & marstat12==0  
replace L`x'= `x'14  if marstat14==1 & marstat12==0  & L`x'==.

replace L`x'= `x'14  if marstat16==1 & marstat14==0 
}

*income : average over prior years 
egen Llincome_aux14=rowmean(income10 income12)          if marstat14==1 & marstat12==0
egen Llincome_aux16=rowmean(income10 income12 income14) if marstat16==1 & marstat14==0


g 		Llincome=log(income10+1) if marstat12==1
replace Llincome=log(Llincome_aux14+1) if marstat14==1 & marstat12==0
replace Llincome=log(Llincome_aux16+1) if marstat16==1 & marstat14==0

drop Llincome_aux14 Llincome_aux16



*education
recode Leduc (1/3=1 "middle school or less") (4=2 "high school") (5/7=3 "college and above"),  ///
       gen(Ledulevel)

la def oc 0 "not working" 1"managerial or professional" 2 "business professional" 3 "Ag personnel" 4 "manufacture" 5 "others"
la val Loccup oc

replace Loccup=5 if Loccup==.  // treat missing as others 

misschk Leduy Llincome edu_fm  partypa     ///	
        han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 dagepa Lfamilysize hasbro , gen(mi)
keep if minumber==0


		 
*additing together 
global dv01 "edu_fm"
global dv02 "lassetp10"
global dv1 "edu_fm lassetp10  "
global dv2 "edu_fm lassetp10 Leduy Llincome "
global dv3 "edu_fm lassetp10 Leduy Llincome  partypa  sp1 sp2 sp3 han urbanhukou10 Lfarmhh Lnonagbushh urbanhukou3 partypa dagepa Lfamilysize hasbro i.region "

*prental party membership and occupation does not matter		
		
*local dv "dv1 dv2 dv3"
local dv "dv01 dv02 dv1 dv2 dv3"
foreach x of local dv{
display " female"
logit livepa $`x' if male==0 
eststo  female_mar_`x'

display " male"
logit livepa $`x'   if male==1 
eststo  male_mar_`x'
} 

* female
esttab female_mar_dv01 female_mar_dv02 female_mar_dv1 female_mar_dv2  female_mar_dv3 using "$tables\livepa_female.rtf",   ///
	   nonumbers mtitles label eform  ci(%9.2f) noomitted  replace

* male
esttab male_mar_dv01 male_mar_dv02 male_mar_dv1 male_mar_dv2  male_mar_dv3 using "$tables\livepa_male.rtf",   ///
	   nonumbers mtitles label eform  ci(%9.2f) noomitted  replace
	
