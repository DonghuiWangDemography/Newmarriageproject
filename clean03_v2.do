*Project : transition into first marriage & co-residency   
*Task: update dv and ivs , make up for missing, update codes based on cc's codes

*updated on 06242019
*add more vars on housing and traditional value 
	*housing: years built, total value, housing type 
	*traditional value: visit graveyard, has geneoulogy book 

*============================================
//ssc install egenmore
//search misschk

clear all 
clear matrix 
set more off 
capture log close 

global date "02252019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

sysdir
cfps // load cfps data (cfps.ado)

use "${datadir}\marriage.dta" , clear

*----------update parental survival information ----------
* note from cc
* 2016, trust as best guess for alive in all years
* if missing and deceased in 2014/2012/2010, treat as deceased
* if missing and not deceased in 2014/2012/2010, leave as missing b/c could deceased in 2016
* use co-residency information to infer whether individual is alive ??
local fm "f m"
foreach x of local fm {

	g       alive`x'16 = alive`x'16_16a
	replace alive`x'16 = alive`x'_16hh if alive`x'16_16a<. & alive`x'16==. 
	replace alive`x'16 = 0 if alive`x'16 == . & alive`x'_14hh == 0
	replace alive`x'16 = 0 if alive`x'16 == . & alive`x'_12hh == 0
	replace alive`x'16 = 0 if alive`x'16 == . & alive`x'_10hh == 0
	replace alive`x'16 = 0 if alive`x'16 == . & alive`x'_10hh == 0
	replace alive`x'16 = 0 if alive`x'16 == . & alive`x'_10a ==0
	replace alive`x'16 = 1 if alive`x'16 == . & live`x'_16hh==1
 }

replace alivef16  = 0 if alivef16 == . & marm_16hh == 5  //widowed
replace alivem16  = 0 if alivem16 == . & marf_16hh == 5

 
*2014
* if reported alive in 2016, replace as alive in 2014 no matter current report
* if missing and deceased in any previous years, treat as deceased
local fm "f m" 
foreach x of local fm{

	g       alive`x'14= alive`x'_14hh
	replace alive`x'14= 1 if alive`x'14==. & alive`x'16==1
	replace alive`x'14= 0 if alive`x'14==. & alive`x'_12hh ==0
	replace alive`x'14= 0 if alive`x'14==. & alive`x'_10hh ==0
	replace alive`x'14= 0 if alive`x'14==. & alive`x'_10a ==0
	replace alive`x'14 =1 if alive`x'14==. & live`x'_14hh==1

}
replace alivef14  = 0 if alivef14 == . & marm_14hh == 5
replace alivem14  = 0 if alivem14 == . & marf_14hh == 5


 *2012
 * if reported alive in 14,16, replace as alive 
 * if reported as died in 2010, replace as died
 local fm "f m" 
foreach x of local fm{
	 g 		 alive`x'12=alive`x'_12hh
	 replace alive`x'12=1 if alive`x'12==. & alive`x'14==1
	 replace alive`x'12=1 if alive`x'12==. & alive`x'16==1
	 replace alive`x'12=0 if alive`x'12==. & alive`x'_10hh==0
	 replace alive`x'12=0 if alive`x'12==. & alive`x'_10a==0
	 replace alive`x'12=1 if alive`x'12== . & live`x'_12hh==1
 }
 
replace alivef12  = 0 if alivef12 == . & marm_12hh == 5
replace alivem12  = 0 if alivem12 == . & marf_12hh == 5


* 2010 
* if reported alive in 2016/2014/2012, replace as alive in 2010 no matter current report
* if coresident in 2016/2014/2012/2010, replace as alive in 2010 no matter current report
local fm "f m" 
foreach x of local fm{

	g 		alive`x'10 = alive`x'_10hh 
	replace alive`x'10 = alive`x'_10a if alive`x'10==. 

	replace alive`x'10 = 1 if alive`x'16==1  
	replace alive`x'10 = 1 if alive`x'14==1  
	replace alive`x'10 = 1 if alive`x'12==1  

	replace alive`x'10 = 1 if live`x'_16hh==1  
	replace alive`x'10 = 1 if live`x'_14hh==1  
	replace alive`x'10 = 1 if live`x'_12hh==1  
	replace alive`x'10 = 1 if live`x'_10hh==1  
}

replace alivef10  = 0 if alivef10 == . & marm_10hh == 5
replace alivem10  = 0 if alivem10 == . & marf_10hh == 5


forval i=10(2)16 {
g 		 alivefm`i'=1 if alivef`i'==1 | alivem`i'==1 
replace  alivefm`i'=0 if alivef`i'==0 & alivem`i'==0
replace  alivefm`i'=. if alivef`i'==. & alivem`i'==.
}

*======== living arragement  ========
* co-residing with parents only if both Ego and parents are in the household 
* not living with parents if either Ego or parents in the household but not both
* not living with parents if both parents died 
* cannot determine coresidence if both Ego and parents NOT in the household [these where missing came from]

foreach x of numlist 10 12 14 16  {
* ego living with father
g       livefp_`x'=1 if livef_`x'hh==1 & livep_`x'hh==1 
replace livefp_`x'=0 if livef_`x'hh==0 & livep_`x'hh==1 

*replace livefp_`x'=0 if livef_`x'hh==. & livep_`x'hh==1             // treat parental living infor missing as not living in the hh
replace livefp_`x'=0 if livef_`x'hh==1 & livep_`x'hh==0 
*replace livefp_`x'=0 if livef_`x'hh==1 & livep_`x'hh==.         // if ego's living info missing & father in hh, treat as not living with fa 
replace livefp_`x'=0 if alivef`x'==0 

*ego living with mother
g       livemp_`x'=1 if livem_`x'hh==1 & livep_`x'hh==1 
replace livemp_`x'=0 if livem_`x'hh==0 & livep_`x'hh==1 
*replace livemp_`x'=0 if livem_`x'hh==. & livep_`x'hh==1
replace livemp_`x'=0 if livem_`x'hh==1 & livep_`x'hh==0 
*replace livemp_`x'=0 if livem_`x'hh==1 & livep_`x'hh==. 
replace livemp_`x'=0 if alivem`x'==0 & in_`x'a==1

* living with either parents 
g       livepa`x'=1 if livefp_`x'==1 | livemp_`x'==1 
replace livepa`x'=0 if livefp_`x'==0 & livemp_`x'==0 
*replace livepa`x'=0 if livefp_`x'==. & livemp_`x'==0   // if not livef, missing living with m, treat as not live with pa
*replace livepa`x'=0 if livefp_`x'==0 & livemp_`x'==.   // do the same thing for mother's case
*replace livepa`x'=0 if livefp_`x'==. & livemp_`x'==. 
}





*======= other predictors========
*own gender, education, hukou status, income ,children 
*parental education, age 
*household income / wealth 

g male=(gender_cross==1)  // trust cross-wave data

g age=2010-birthy_cross  //  trust cross-wave data after compare with cc's codes
g agesq=age*age

* parent age : 
g       byf=byf_12a 
replace byf=byf_16hh if byf==. & byf_16hh>0
replace byf=byf_14hh if byf==. & byf_14hh>0
replace byf=byf_12hh if byf==. & byf_12hh>0
replace byf=byf_10hh if byf==. & byf_10hh>0

g       agef=2010-byf if byf<.
replace agef=agef_10hh if agef==. & agef_10hh>0  


g       bym=bym_12a 
replace bym=bym_16hh if bym==. & bym_16hh>0
replace bym=bym_14hh if bym==. & bym_14hh>0
replace bym=bym_12hh if bym==. & bym_12hh>0
replace bym=bym_10hh if bym==. & bym_10hh>0

g       agem=2010-bym if bym<.  //86 missing 

g agef75=(agef>= 75 & agef<.)
g agem75=(agem>= 75 & agem<.)
g agefm_75=(agef75==1 |agem75==1)

* own education  
*highest educaiton acheived 
g educ10=edu2010_10a   //1-8
g 		educ12=edu2012
replace educ12=educ_12hh if edu2012==. & educ_12hh>0

g 		educ14=cfps2014edu_14a if  cfps2014edu_14a>0
replace educ14=educp_14hh if educp_14hh>0 & cfps2014edu_14a==.
replace educ14=1 if educ14==9

g 		educ16=cfps2016edu_16a 
replace educ16=educp_16hh if cfps2016edu_16a==.


*yrs of education
clonevar eduy10=cfps2010eduy_im_cross        // from 0-22 yrs : 8 missing 
replace  eduy10=eduy2010_10a if cfps2010eduy_im_cross==.

clonevar eduy12=cfps2012eduy_im_cross       // equivalent to cfps2012eduy_cross // 43 missing 
clonevar eduy14=cfps2014eduy_im_14a  // use imputed version 
clonevar eduy16=cfps2016eduy_im_16a

*impute yrs of edu with levels of edu for missing
recode   educ12  (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22), gen (eduy12_aux)   // 66missing 
recode   educ14  (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22), gen (eduy14_aux)  // 1900 missing:  no need to worry bx going to use lag1 var
recode   educ16  (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22), gen (eduy16_aux)  // 1900 missing:  no need to worry bx going to use lag1 var

replace eduy12=eduy12_aux if eduy12==.
replace eduy14=eduy14_aux if eduy14==.
replace eduy16=eduy16_aux if eduy16==.

drop eduy12_aux eduy14_aux eduy16_aux



*parental education 
g       feduc=feduc_10a  if feduc_10a<.
replace feduc=educf_16hh if feduc==. & educf_16hh>0
replace feduc=educf_14hh if feduc==. & educf_14hh>0
replace feduc=educf_12hh if feduc==. & educf_12hh>0
replace feduc=educf_10hh if feduc==. & educf_10hh>0
*for those still missing feduc, impute with f's edu when ego at age 14
replace feduc=educf_12a  if feduc==. & educf_12a>0    
tab feduc if in_10a==1 ,m   // 17.6% missing  why ?


g       meduc=meduc_10a  if meduc_10a<.
replace meduc=educm_16hh if meduc==. & educm_16hh>0
replace meduc=educm_14hh if meduc==. & educm_14hh>0
replace meduc=educm_12hh if meduc==. & educm_12hh>0
replace meduc=educm_10hh if meduc==. & educm_10hh>0
*for those still missing feduc, impute with f's edu when ego at age 14
replace meduc=educm_12a  if meduc==. & educm_12a>0    // 
tab meduc if in_10a==1 ,m 

egen edu_fm=rowmax(feduc meduc) 
recode edu_fm (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22)

*tab edu_fm if in_10a==1,m   // 10.88 % missing 


*group birth year into 10 yr interval except begining & ending interval 
egen byfgr=cut(byf) if !missing(feduc, byf) & in_10a==1, at(1807, 1910, 1920, 1930, 1940,1950,1960, 1985) lab 
egen bymgr=cut(bym) if !missing(meduc, bym) & in_10a==1, at(1860, 1910,1920, 1930, 1940,1950,1960, 1985) lab 


*distribution of father, mother, ego, or all ? 
*follow a stata tutorial :https://www.stata.com/support/faqs/statistics/percentile-ranks-and-plotting-positions/
bysort byfgr : egen nf=count(feduc)     if !missing(feduc, byf) & in_10a==1  
bysort byfgr : egen feduc_r=rank(feduc) if !missing(feduc, byf) & in_10a==1 , track   
  
gen feducpc=1+int(100*(feduc_r-0.5)/nf) if !missing(feduc, byf) & in_10a==1  //scale up to 1-100

//list byfgr feduc_pc feduc_r feduc in 1/200 if !missing(feduc, byf) & in_10a==1 

*mother:
bysort bymgr : egen nm=count(meduc)     if !missing(meduc, bym) & in_10a==1  
bysort bymgr : egen meduc_r=rank(meduc) if !missing(meduc, bym) & in_10a==1 , track  
gen  meducpc=1+int(100*(meduc_r-0.5)/nm) if !missing(meduc, bym) & in_10a==1   //scale up to 1-100


*tab iseif_10hh if farmhh_10hh2==1 & livepa10==1,m
tab farmhh_10hh2 if iseif_10hh<0 & in_10a==1,m
tab farmhh_12hh2 if iseif_10hh<0 & in_10a==1,m



*=========income===========================
* individual income
g income10=income_10a if income_10a>=0  
g       lincome10=log(income_10a+1) if income_10a>0   
replace lincome10=0 if inschool_10a==1  & lincome10==.  // N=1646 missing (4.9)
g hasincome10=(income_10a>0)

g income12=income_adj_12a  if income_adj_12a>=0 
replace  income12=0 if inschool_12a==1 & income12==.

*misschk income_adj_12a income_adj_12_cross if in_10a==1 
*egen icdif12=diff(income_adj_12_cross income_adj_12a)
*misschk income12 if in_12a==1

g lincome12=log(income_adj_12a+1) if income_adj_12a>0 & income_adj_12a<.
g hasincome12=(income_adj_12a>0 & income_adj_12a<. )

*!!note: income 14/16 is not adjusted. 
//misschk income_14a income_14_cross if in_14hh==1    
g 		income14=income_14a if income_14a>=0  
replace income14=0 if inschool_14a==1 & income14==.

g 		lincome14=log(income14+1) 
replace lincome14=0 if income14==0
g	 hasincome14=(income14>0 & income14<.)

* income in 16: not found at the cross wave data
g 		income16=income_16a if income_16a >=0  //222 missing 
*replace income16=0 if income16==. & atwork16==0  & in_16a==1

g       lincome16=log(income16+1) if income16>0 
replace lincome16=0 if income_16a==0
g hasincome16 =(income16>0 & income16<.)

misschk income10 income12 income14  if in_10a==1  

*=========occupation===========================
rename occ_*a occ*
rename inwork_*a inwork*
misschk occ10 occ12 occ14 

* occupational category 
forval i=10(2)16 {
gen oc`i'= int(occ`i'/10000) if occ`i'>0 
replace oc`i'=7 if oc`i'>=8 & oc`i' !=.
*replace oc`i'=8 if oc`i'==. & inwork`i'==1 
replace oc`i'=0 if  inwork`i'==0 & oc`i'==.

// further recode occupation 
recode oc`i' (1/3=1 "Managerial or Professional")  (4=2 "Service personnel") (5=3 "Ag personnel") (6=4 "Manufacture personnel") (7/8=5 "others") (0=0 "not working"), gen(occup`i')
}

misschk occup10 if in_10a==1 
misschk occup12 if in_12a==1 
misschk occup14 if in_14a==1 


*hh income 
* impute total hh income as sum of individual income in adult survey if hh income missing
* replace total hh income as sum of individual income in adult survey if hh income smaller than sum of total adult income

*2010 
*misschk faminc_old_10hh2 faminc_10hh2 faminc_net_10hh2 faminc_net_old_10hh2 if in_10hh2==1   // all four has around 4% missing (around N=3k)
forval i=1/27{
replace ff502_a_`i'_10hh2=. if ff502_a_`i'_10hh2<0
}

egen faminc_chh1 = rowtotal(ff502_a_*_10hh2), missing
bysort fid: egen faminc_chh= max(faminc_chh1)
replace faminc_10hh2=faminc_chh if faminc_10hh2==.  //329 change made

drop    faminc_chh1 ff502_a_*_10hh2

*for those still zero or missing, impute with total income from adult survey
replace income_10a=. if income_10a<0

bysort fid: egen fincome_c=total(income_10a), missing
bysort fid: egen fincome_cor=max(fincome_c)
replace faminc_10hh2=fincome_cor if  faminc_10hh2==. 
replace faminc_10hh2=fincome_cor if  faminc_10hh2==0 & income_10a<.  
replace faminc_10hh2=fincome_cor if  faminc_10hh2<income_10a  &  income_10a<.
 
*check : family income cannot smaller than individual's income 
assert faminc_10hh2 >= income_10a if income_10a<.
drop fincome_cor ff50*  fincome_c 

g       lfincome=log(faminc_10hh2) if faminc_10hh2<.  // 
replace lfincome=0                 if faminc_10hh2==0   //  

clonevar fincome10=faminc_10hh2  
*misschk fincome10 if in_10hh2==1 //166 missing 

*2012
*misschk fincome1_12hh2 fincome2_12hh2 fincome2_adj_12hh2 fincome2_adj_12hh2 if in_12hh==1  
g        fincome12=fincome1_adj_12hh2  if fincome2_adj_12hh2>0 & fincome2_adj_12hh2<.   // use non-adjusted value 

* impute missing with adultincome 
bysort fid12: egen fincome_c=total(income12), missing
bysort fid12: egen fincome_cor=max(fincome_c)

replace fincome12=fincome_cor if  fincome12==. & in_12hh2==1 & fincome_cor>0 & fincome_cor<.
replace fincome12=fincome_cor if  fincome12==0 & income12>0 & income12<.  
replace fincome12=fincome_cor if  fincome12<income12  &  income12<.
 
assert fincome12 >= income12 if income12<.

drop fincome_c fincome_cor
*misschk fincome12 if in_12hh2==1 // 96 missing
*!!next step: adjust 2012 so that to comparable to 2014 income?? 

*2014 
*misschk fincome1_14hh2 if in_14hh2==1  // N=4298  missing ; not copmarable to 2010 fincome, not adjusted
*use version taht not comparable to 2010 (fincome1 instead of fincome2 bx the missings are imputed from individual income that not adjusted
replace income14=. if income14<0
g       fincome14=fincome1_14hh2 if fincome1_14hh2>0 

bysort fid14: egen fincome_c=total(income14), missing
bysort fid14: egen fincome_cor=max(fincome_c)

replace fincome14=fincome_cor if  fincome14==. & in_14hh2==1 & fincome_cor>0 & fincome_cor<.
replace fincome14=fincome_cor if  fincome14==0 & in_14hh2==1 & income14>0 & income14<.  
replace fincome14=fincome_cor if  fincome14<income14  &  income14<. & in_14hh2==1

drop fincome_c fincome_cor
*misschk fincome14 if in_14hh2==1  //107missing

*2016
*misschk fincome1_16hh2 if in_16hh2==1  // N=129 missing
replace income16=. if income16<0
g       fincome16=fincome1_16hh2 if fincome1_16hh2>0 

bysort fid16: egen fincome_c=total(income16), missing
bysort fid16: egen fincome_cor=max(fincome_c)

replace fincome16=fincome_cor if  fincome16==. & in_16hh2==1 & fincome_cor>0 & fincome_cor<.
replace fincome16=fincome_cor if  fincome16==0 & in_16hh2==1 & income16>0 & income16<.  
replace fincome16=fincome_cor if  fincome16<income16  &  income16<. & in_16hh2==1

rename farmhh_*hh2 farmhh*
rename nonagbushh_*hh2 nonagbushh*


*----------Housing----------
*2010
g house_sqr10=fd2_10hh2  if fd2_10hh2>0  // square footage of the current house 
 

*housing difficulty 
egen nodifficulty10= rcount(fd8_s_1_10hh2 fd8_s_2_10hh2 fd8_s_3_10hh2 ), cond(@ == 78)  // no housing difficulty  
g    housinghard10=1-nodifficulty

* other owned housing assets
gen     otherhh10=1 if fd7_10hh2 == 1
replace otherhh10=0 if fd7_10hh2==0
*replace otherhh10 = fd701_10hh2 if fd7_10hh2 == 1 & fd701_10hh2 >= 0

* other housing assets square meters
gen     otherhhsqm10 = 0 if fd7_10hh2 == 0
replace otherhhsqm10 = fd702_10hh2 if fd7_10hh2 == 1 & fd702_10hh2 >= 0


*yr built/purchased year 
gen  	yrbhh10=fd103_10hh2 if fd102_10hh2==1
replace yrbhh10=fd105_10hh2 if fd102_10hh2==5
replace yrbhh10=fd111_10hh2 if fd1_10hh2==2

*yr moved
g yrmvhh10=fd3_10hh2


*2012
g house_sqr12=fq701_best_12hh2  if fq701_best_12hh2>0  & in_12hh2==1   // square footage of the house  2516 don't knows

g       otherhh12=1 if fr1_12hh2==1
replace otherhh12=0 if fr1_12hh2==0


*did not find other square meters in 2012 hh & housing difficulty measure in 2012 survey 
*2014
g house_sqr14=fq801_14hh2 if fq801_14hh2>0 & in_14hh2==1
replace house_sqr14=0 if house_sqr14==. & fq801_14hh2==-8  // replace NAs as 0

g    	otherhh14=1 if fr1_14hh2==1
replace otherhh14=0 if fr1_14hh2==0

*2016

g house_sqr16=fq801_16hh2 if fq801_16hh2>0 & in_16hh2==1
replace house_sqr16=0 if house_sqr16==. & fq801_16hh2==-8  // replace NAs as 0

g 		otherhh16=1 if fr1_16hh2==1
replace otherhh16=0 if fr1_16hh2==0

*===========wealth,debt,asset==========

*housing value/debt 
g 		 houseasset10= resivalue_new_10hh2+otherhousevalue_10hh2    // primary housing + other housing 
clonevar houseasset12= houseasset_gross_12hh2  //235 missing 
clonevar houseasset14= houseasset_gross_14hh2
clonevar houseasset16= houseasset_gross_16hh2

clonevar house_debts10=house_debts_10hh2
clonevar house_debts12=house_debts_12hh2
clonevar house_debts14=house_debts_14hh2
clonevar house_debts16=house_debts_16hh2


*other wealth/debt measured at wave 1
g        houseasset_net10=houseasset10-house_debts10
clonevar companyasset10=company_10hh2
egen financeasset_gross=rowtotal(savings_10hh2 stock_10hh2 funds_10hh2 debit_other_10hh2)

local iv "fh203_a_2_10hh2 fh203_a_3_10hh2 fh203_a_4_10hh2 fh203_a_5_10hh2 fh203_a_6_10hh2"
foreach x of local iv {
replace `x'=. if `x'<0
}
egen nonhousing_debts=rowtotal(fh203_a_2_10hh2 fh203_a_3_10hh2 fh203_a_4_10hh2 fh203_a_5_10hh2 fh203_a_6_10hh2)


*birth yr of the eldest child 
egen byr_children=rowmin(byr_children_*)

la var byr_children "birth yr of the eldest child"

*----------county-level housing price-----------
bysort cid_hh10:    egen chhp10=mean(resivalue_new_10hh2) if resivalue_new_10hh2>=0
bysort cid_12hh2:   egen chhp12=mean(resivalue_new_12hh2) if resivalue_new_12hh2>=0
bysort cid14_14hh2: egen chhp14=mean(resivalue_14hh2*10000) if resivalue_14hh2>=0

sum chhp10 chhp12 chhp14

*-----------------durable goods, living standards  ---------------
g car10 = (fj1_10hh2 ==1 ) if in_10hh==1
g motor10 = (fj2_10hh2 == 1)  if in_10hh==1
g tractor10 = (fj301_10hh2 ==1) if in_10hh==1
g tv10 = (fj4_10hh2 ==1) if in_10hh==1




*==============other  characheristics=================== 
* family size
clonevar familysize10=familysize_10hh2
clonevar familysize12=familysize_12hh2
clonevar familysize14=familysize_14hh2
clonevar familysize16=familysize16_16hh2

*hukou, migrant and urban: first use info at adult survey and hh survey , then impute with cross-wave info
g 		nonaghukou10=1 if hukounow_10a==3 
replace nonaghukou10=0 if hukounow_10a==1
replace nonaghukou10=1 if hk10_cross==3 & nonaghukou10==.
replace nonaghukou10=0 if hk10_cross==1 & nonaghukou10==.  //72 missing

g 		nonaghukou12=1 if hukoup_12hh==3
replace nonaghukou12=0 if hukoup_12hh==1
replace nonaghukou12=1 if hk12_cross==3 & nonaghukou12==.
replace nonaghukou12=0 if hk12_cross==1 & nonaghukou12==.  


g 		nonaghukou14=1 if hukoup_14hh==3
replace nonaghukou14=0 if hukoup_14hh==1
replace nonaghukou14=1 if hk14_cross==3 & nonaghukou14==.
replace nonaghukou14=0 if hk14_cross==1 & nonaghukou14==.  

//misschk nonaghukou10 nonaghukou12 nonaghukou14 if in_10a==1  // less than 10%missing 


foreach x of numlist 10 12 14 16{
clonevar urban`x'= urban10_cross if in_`x'a==1 
g 		migrant`x'=1 if migrant`x'_cross==1
replace migrant`x'=0 if migrant`x'_cross==0
}

//misschk migrant10 migrant12 migrant14 if in_10a==1 // less than 10%missing 


*update family income per capita
clonevar fincomeper10=fincome1_per_adj10_cross
clonevar fincomeper12=fincome2_per12_cross
clonevar fincomeper14=fincome2_per14_cross  
clonevar fincomeper16=fincome2_per16_cross 



* region
recode provcd_10a (11/14=1 "north") (21/23=2 "northeast") (31/37=3 "east") ///
			      (41/45=4 "southcentral") (50/53=5 "southwest") (61/62=6 "northwest"), gen (region) 
tab region, gen(region) la

rename qa2_10a hukou10_10a

drop alive_a_c*_10a 
save "${datadir}\panel_temp.dta" ,replace 

*siblings
use $w10a,clear
	clonevar nsib=qb1 
	replace  nsib=. if qb1<0   // 415 missing 

	*avlive total sibs co-residing
	clonevar nsib_alive_cor=qb2 if qb2>=0  // 3812 missing  // what's NA here ?
	replace  nsib_alive_cor=0 if nsib==0

	*alive total sibs not co-residing
	egen nsib_alive_nocore= rcount(qb304_a_*), cond(@ == 1)  // live siblings if has one 

	*number of alive bros not co-residing 
	forval i=1/15{
	g oldbro`i'_alive=(qb301_a_`i'==1   & qb304_a_`i'==1)
	g oldsis`i'_alive=(qb301_a_`i'==2   & qb304_a_`i'==1)
	g youngbro`i'_alive=(qb301_a_`i'==3 & qb304_a_`i'==1)
	g youngsis`i'_alive=(qb301_a_`i'==4 & qb304_a_`i'==1)
	}
	egen noldbro_alive_nocor=rowtotal(oldbro*_alive),missing
	egen noldsis_alive_nocor=rowtotal(oldsis*_alive),missing
	egen nyoungbro_alive_nocor=rowtotal(youngbro*_alive ),missing
	egen nyoungsis_alive_nocor=rowtotal(youngsis*_alive),missing

	g nsib_alive=nsib_alive_cor +nsib_alive_nocore  //418 missing
	g nbro_alive_nocor=noldbro_alive_nocor + nyoungbro_alive_nocor
	g nsis_alive_nocor=noldsis_alive_nocor+nyoungsis_alive_nocor
keep pid nsib nsib_alive nbro_alive_nocor nsib_alive_cor nsib_alive_nocore nsis_alive_nocor
tempfile sibnoncore
save `sibnoncore.dta',replace 


* number of sib/bro living together 
use $w10hh,clear
	keep pid fid tb2_a_p code_a_f code_a_m code_a_p
	replace code_a_f=. if code_a_f<0
	replace code_a_m=. if code_a_m<0

	* number of bros living together 
	*create a file of all males 
	preserve 
	keep if tb2_a_p==1
	drop  tb2_a_p
	rename code_a_* code_a_*bro
tempfile males 
save `males'
restore 

*match each person with all males in the same household
joinby fid using `males', unmatched (master)
*remove self-matches and matches with father
replace code_a_pbro =. if inlist(code_a_pbro, code_a_f, code_a_p)
*remove if no common parent
replace code_a_pbro=. if (code_a_f !=code_a_fbro) & (code_a_m !=code_a_mbro) 
collapse (count) nbro_alive_cor=code_a_pbro (firstnm)  tb2_a_p code_a_f code_a_m pid, by (fid code_a_p)

keep pid fid code_a_f code_a_m code_a_p  nbro_alive_cor
merge 1:1 pid using `sibnoncore.dta' , keep(match) nogen

g nbro_alive=nbro_alive_nocor + nbro_alive_cor
keep fid pid nsib_alive nbro_alive nbro_alive_cor

merge 1:1 pid using "${datadir}\panel_temp.dta" , keep(match) nogen

g hasbro=(nbro_alive>0 &nbro_alive<.)

save "${datadir}\panel_1016.dta" ,replace

erase "${datadir}\panel_temp.dta"

beep
