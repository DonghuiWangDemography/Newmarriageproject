*Project : transition into first marriage & co-residency   
*date : 11122018

// task: data cleaning : 2010 -2016 new marriages  
*============================================
//ssc install blindschemes, replace all
// ssc inst unique
//set scheme plotplainblind, permanently

clear all 
clear matrix 
set more off 
capture log close 

global date "11122018"   // ddmmyy
*global dir "C:\Users\wdhec\Desktop\Marriage"
global dir "\\redmond.pop.psu.edu\Redirected\duw168\Desktop\Marriage"
global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"
//global data "${dir}\CFPSrawdata_Chinese"

******CFPS data **********************************************************************
*global datadir "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese"
global datadir "\\redmond.pop.psu.edu\Redirected\duw168\Desktop\Marriage\CFPSrawdata_Chinese"
global w10hh "${datadir}\2010\cfps2010famconf_report_nat092014.dta"
global w10hh2 "${datadir}\2010\cfps2010family_report_nat092014.dta"
global w10a "${datadir}\2010\cfps2010adult_report_nat092014.dta"
global w10c "${datadir}\2010\cfps2010child_report_nat092014.dta"

global w12hh "${datadir}\2012\cfps2012famros_092015compress.dta"
global w12hh2 "${datadir}\2012\cfps2012family_092015compress"
global w12a "${datadir}\2012\cfps2012adultcombined_092015compress.dta"
global w12c "${datadir}\2012\cfps2012childcombined_032015compress.dta"
global w12cross "${datadir}\2012\crossyearid_032015compress.dta"

global w14hh "${datadir}\2014\cfps2014famconf_170630.dta"
global w14a "${datadir}\2014\cfps2014adult_170630.dta"
global w14c "${datadir}\2014\Cfps2014child_170630.dta"

global w16hh "${datadir}\2016\cfps2016famconf_201804.dta"
global w16a "${datadir}\2016\cfps2016adult_201808.dta"
global w16c "${datadir}\2016\cfps2016child_201807.dta"
global cross "${datadir}\2016\Cfps2016crossyearid_201807.dta"

*======================================================
*======================================================

log using "${logs}\[exploratory]$date}", text replace 

*======================================================
*********10-12wave******************************************
use $w10hh, clear
keep if tb3_a_p==1  // single N=19,241 
//drop if tb1b_a_p < 16  // drop N=10,345
// keep basic information : education, age, parental ed; parental age; income ; if have siblings ; hukou status ; housing 
keep pid fid cid provcd countyid tb1b_a_p  tb2_a_p birthy_best tb3_a_p  tb5_isei_a_p tb5_siops_a_p  tb6_a_p edu2010_t1_best  ///
		tb1b_a_f fbirthy alive_a_f tb3_a_f feduc tb501_a_f  tb5_isei_a_f tb5_siops_a_f  fparty  ///
		tb1b_a_m mbirthy alive_a_m tb3_a_m meduc tb501_a_m tb5_isei_a_m tb5_siops_a_m mparty
	
	rename (fid   tb1b_a_p tb2_a_p  tb3_a_p tb5_isei_a_p tb5_siops_a_p tb6_a_p edu2010_t1_best birthy_best)     ///
	       (fid10 age10    gender10 mar10   isei10        siops10     live10 edu10 birthy10)
	rename (tb1b_a_f fbirthy alive_a_f tb3_a_f feduc tb501_a_f  tb5_isei_a_f tb5_siops_a_f  fparty)  ///
			(agef10  fbirthy10 alivef10 marf10 feduc10  mngf10  iseif10 siopsf10 fparty10)
	rename (tb1b_a_m mbirthy alive_a_m tb3_a_m meduc tb501_a_m tb5_isei_a_m tb5_siops_a_m mparty)   ///
			(agem10 mbirthy10 alivem10 marm10  meduc10  mngm10 iseim10 siopsm10 mparty10)	
tempfile unmar10
save  `unmar10.dta', replace


// 2. living with in-laws ?
// extract info from inlaws
use $w12hh, clear 
keep pid fid12  tb6_a12_f tb6_a12_m 
	rename (pid tb6_a12_f tb6_a12_m) (pid_s inlawlive_f inlawlive_m)
tempfile inlaw
save `inlaw.dta', replace 

use $w10hh2, clear

use $w10a, clear

use $w12hh, clear
merge m:1 pid using `unmar10.dta'  // merge 2010 hh to 2012 hh roster by pid  

**********1. exclusion criteria*************
keep if _merge==3 // N=1,347 in 2010 not merged to 2012.
	//tab _merge
drop if alive_a_p==0  // drop those who died in 2012
drop if cfps_interv_p==0  // never had valid individual questionaires : N=2202 (aka keep have either valid info in 2010 / 2012)
drop if tb6_a12_s==0  //spouse do not live in the household N=2
	// restrict age ??
drop if tb1b_a_p<14 
drop _merge
// N=6150 
***********2. Marriage and Co-residency******************************
//duplicates list pid // only 5 duplicates 

	g mar12=tb3_a12_p==2  // married, divorced or widowed

// 1. living with parents 
// co_a12_p :  个人是否与该家庭同灶吃饭
// tb6_a12_p :  个人是否在家住

	g co_par=(tb6_a12_f==1 & tb6_a12_m==1 )
	g co_par1=(tb6_a12_f==1 | tb6_a12_m==1)

// living with inlaws 
merge m:m pid_s using `inlaw.dta' 
	g co_inlaw=(inlawlive_f==1 | inlawlive_m==1)
	replace co_inlaw=. if mar12==0

// how man new marriages ?  pid are duplicated 
duplicates drop pid, force  // only 5 deleted 


	tab co_par1 if mar12==1 // 71% living with parents ? 

	// check consistency 	
	tab age10 if mar12==1  // 
	// why so many NAs when it comes to spouse's gender??
	tab code_a_s if mar12==1   // N=451 NA for spouse's code   
	tab tb2_a_s if tb3_a12_p==2
	tab cfps_interv_s  if tb3_a12_p==2
	tab gender10 tb2_a_p  // 1. 2010 gender in consistent with 2012 gender ; 2. why so many NAs in spouse gender ?
	//tab mar12 if gender10==1 &  tb2_a_p==0
	//tab mar12 if gender10==0 &  tb2_a_p==1




*======================================================
**********12-14wave**********************
use $w12hh, clear
	//tab tb1b_a_p if tb3_a12_p==2
keep if tb3_a12_p==1  // single N=17800
keep if alive_a_p==1
drop if  tb1b_a_p<16  // N=8101  may also need to exclude extreme old age ? 
keep pid fid12  cfps_interv_p tb1b_a_p tb1y_a_p  tb2_a_p tb3_a12_p tb4_a12_p qa301_a12_p tb6_a12_p   /// 
		 pid_f cfps_interv_f tb1b_a_f  alive_a_f  tb3_a12_f qa301_a12_f tb6_a12_f  fbirth12 feduc12  ///
		 pid_m cfps_interv_m tb1b_a_m  alive_a_m  tb3_a12_m qa301_a12_m tb6_a12_m  mbirth12 meduc12 generation
	rename (cfps_interv_p tb1b_a_p tb1y_a_p tb2_a_p tb3_a12_p tb4_a12_p qa301_a12_p tb6_a12_p generation)  ///
			(interv12     age12     byr12   gender12 mar12    educ12     hukou12    live12   generation12 )
	rename ( pid_f cfps_interv_f tb1b_a_f  alive_a_f  tb3_a12_f qa301_a12_f tb6_a12_f )  ///
			(pidf12 intervf12    agef12      alivef12   marf12    hukouf12    live12f )
	rename (pid_m cfps_interv_m tb1b_a_m  alive_a_m  tb3_a12_m qa301_a12_m tb6_a12_m )  ///
		   (pidm12 intervm12    agem12      alivem12   marm12    hukoum12    live12m )
tempfile unmar12
save `unmar12.dta' , replace 
		   
		   
use $w14hh, clear
merge m:m pid using `unmar12.dta'  // 799 from 2012 not merged 
keep if _merge==3   
// unique pid // N=7179
	g mar14=(tb3_a14_p==2 | tb3_a14_p==4 | tb3_a14_p==5)   // N=1718 
	g co_par=(tb6_a14_f==1 & tb6_a14_m==1 )
	g co_par1=(tb6_a14_f==1 | tb6_a14_m==1)
	
duplicates  drop pid, force  //797 dropped 
	tab mar14   //N=1,386
	tab co_par1 if mar14==1  // 78.72??

	
	
*======================================================
**********14-16ave**********************
use $w14hh, clear
keep if tb3_a14_p==1  // single N= 18,861
keep if alive_a14_p==1
drop if  tb1y_a_p>1998  //  drop N=10,488
keep pid fid14 provcd14 countyid14 urban14  tb2_a_p tb1y_a_p tb3_a14_p tb4_a14_p qa301_a14_p  
//	 code_a_f pid_f tb1y_a_f tb3_a14_f tb4_a14_f alive_a14_f qa301_a14_f tb6_a14_f  cfps2014_interv_f  
//	 code_a_m pid_m tb1y_a_m tb3_a14_m tb4_a14_m alive_a14_m qa301_a14_m tb6_a14_m cfps2014_interv_m 
	rename ( tb2_a_p tb1y_a_p tb3_a14_p tb4_a14_p qa301_a14_p )  ///
			(gender14 byr14   mar14     educ14  hukou14 )
tempfile unmar14
save `unmar14.dta' , replace 
	
use $w16hh, clear
merge m:m pid using `unmar14.dta' 
keep if _merge==3
//unique pid // N=7465
		g mar16=(tb3_a16_p==2 | tb3_a16_p==4 | tb3_a16_p==5)   // N=1718 
		g co_par=(tb6_a16_f==1 & tb6_a16_m==1 )
		g co_par1=(tb6_a16_f==1 | tb6_a16_m==1)
duplicates  drop pid, force  //332 dropped 
	tab mar16   //N=1,200
	tab co_par1 if mar16==1  

	