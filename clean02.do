*Project : transition into first marriage & co-residency   
*Date : 11182018
*Task: data cleaning : marriage from 2010-2018 adult file 
*Note: After 2nd meeting with CC, decided to focus on adults sample . 

*updated on 11/23/2018: 
*1. HH survey: whether ego lives within the hh (tb6_a_p), parental marriage parental alive 
*2. Adult AR section: residential changes  
*3. Marital history 
*4.other baseline var: gender, age, rural/urban ==> from cross panel 

*updated on 11/30/2018
*Add wave 1 predictors 
*============================================
//ssc install blindschemes, replace all
//set scheme plotplainblind, permanently
//ssc install motivate

clear all 
clear matrix 
set more off 
capture log close 

global date "11232018"   // ddmmyy
global dir "C:\Users\donghuiw\Desktop\Marriage"
*global dir "W:\Marriage"

global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"

******CFPS data **********************************************************************
global datadir "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"
*global datadir "W:\Marriage\CFPSrawdata_Chinese"

global w10hh "${datadir}\2010\cfps2010famconf_report_nat092014.dta"
global w10hh2 "${datadir}\2010\cfps2010family_report_nat092014.dta"
global w10a "${datadir}\2010\cfps2010adult_report_nat092014.dta"
global w10c "${datadir}\2010\cfps2010child_report_nat092014.dta"

global w12hh "${datadir}\2012\cfps2012famros_092015compress.dta"
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

log using "${logs}\[exploratory]$date}", text replace 

*============================================
*1.Merge 10-14 individual & hh sample
* naming convention: a:adult sample ; hh : hh sample c: additional infor intent to correct for key vars 

***********10wave***************
use $w10a, clear
// individual survey : pid fid gender age education occupation income employment status hukou educational status 

// parental alive : if parents are living with any relatives 
g alivef_c= 1 if qb411_s_1 > 0 | qb411_s_2 > 0 | qb411_s_3 > 0 | qb411_s_4 > 0 | qb411_s_5 > 0 | qb411_s_6 > 0 
g alivem_c= 1 if qb511_s_1 > 0 | qb511_s_2 > 0 | qb511_s_3 > 0 | qb511_s_4 > 0 | qb511_s_5 > 0 | qb511_s_6 > 0 | qb511_s_7 > 0 | qb511_s_8 > 0

clonevar alivef= alive_a_f
clonevar alivem= alive_a_m

replace alivef = alivef_c if alive_a_f<0 
replace alivem =alivem_c if  alive_a_m<0

drop alivef_c alivem_c

//byr 
g byr=qa1y_best if qa1y_best>0  // missing one 
clonevar age=qa1age

// school/ work status 
clonevar inschool=qd3 
g inwork= (qg3==1 | qg4==1)  // currently has a job, current engege ag job
g farmwork=(qg4 ==1)

gen empstat = 1 if qg303 == 5
replace empstat = 2 if qg303 == 3
replace empstat = 3 if qg303 == 1
replace empstat = 4 if qg3 == 0 & qg2 == 1
replace empstat = 5 if qg2 == 0

// income 
replace income = 0 if income < 0 & inwork == 0

// hukou
clonevar hukounow=qa2
clonevar hukou3=qa302
clonevar hukou12=qa402

keep pid  provcd qe1 qe1_best gender byr age qa2  educ eduy2010  hukou* alive*  ///
	      qb*  empstat  inschool inwork farmwork income urban
		  
foreach x of varlist _all {
rename `x' `x'_10a
}

g in_10a=1
rename pid_10a pid 
tempfile w10a
save `w10a.dta', replace 


use $w10hh, clear
// parental education
g       educf_10hh= feduc
replace educf_10hh= tb4_a_f if tb4_a_f>0 

g       educm_10hh= meduc
replace educm_10hh= tb4_a_m if tb4_a_m>0 

// parental byr
clonevar byrf_10hh= fbirthy
replace  byrf_10hh=tb1y_a_f if tb1y_a_f>0 & tb1y_a_f<.

clonevar byrm_10hh= mbirthy
replace  byrm_10hh=tb1y_a_m if tb1y_a_m>0 & tb1y_a_m<.

//own demo
clonevar educ_10hh= tb4_a_p
clonevar byr_10hh=birthy_best

// spouse demo
clonevar educs_10hh=tb4_a_s
clonevar byrs_10hh=tb1y_a_s

keep fid pid   code_a_p alive_a_p tb3_a_p tb2_a_p tb6_a_p tb601_a_p co_p  tb1b_a_p td8_a_p tb1b_a_p  birthy_best    ///
	     pid_f code_a_f alive_a_f tb3_a_f tb2_a_f tb6_a_f tb601_a_f co_f  tb1b_a_f td8_a_f tb1b_a_f  fbirthy   foccupcode ///
		 pid_m code_a_m alive_a_m tb3_a_m tb2_a_m tb6_a_m tb601_a_m co_m  tb1b_a_m td8_a_m tb1b_a_m  mbirthy   moccupcode  ///
		 pid_s code_a_s alive_a_s tb3_a_s tb2_a_s tb6_a_s tb601_a_s co_s  tb1b_a_s td8_a_s tb1b_a_s ///
		 educf_10hh educm_10hh byrf_10hh byrm_10hh educ_10hh byr_10hh educs_10hh byrs_10hh 
		 		 
g in_10hh=1
local fm "p s f m"
foreach x of local fm {
	rename (code_a_`x'   alive_a_`x'   tb3_a_`x'    tb6_a_`x'     tb601_a_`x'  co_`x'        tb1b_a_`x'  td8_a_`x'     tb2_a_`x')   ///
		   (code`x'_10hh alive`x'_10hh mar`x'_10hh  live`x'_10hh  rmig`x'_10hh co`x'_10hh    age`x'_10hh hukoumig`x'10 gender`x'10 )
		   }
	rename (pid_s pid_f pid_m) (pids10 pidf10 pidm10)
	rename marp_10hh mar10_10hh

tempfile w10hh
save `w10hh.dta', replace 

use $w10hh2, clear
keep fid fk1 fe3 ff502_a_* fd*  familysize-foperate_net land_asset resivalue_new otherhousevalue house_debts savings funds debit_other   ///
	company otherasset valuable nonhousing_debts total_asset    
	
g in10hh2=1
foreach x of varlist _all {
rename `x' `x'_10hh2
}
rename fid_10hh2 fid 
//tempfile w10hh2
//save `w10hh2.dta', replace 

merge 1:m fid using `w10hh.dta', nogen   // 604 not matched.Why ??
save "${datadir}\w10hhmerged.dta" ,replace 

*********12 wave**************** 
use $w12a, clear 
*parent age
clonevar byrf=qv101a if qv101a>0 & qv101a<.
replace  byrf = 2012 - qv101c if qv101c > 0 & qv101c<.

clonevar byrm=qv201y if qv201y>0 & qv201y<.
replace  byrm = 2012 - qv201b if qv201b > 0 & qv201b < .

* parental educ
clonevar educf=qv102 if qv102>0 & qv102<.
clonevar educm=qv202 if qv202>0 & qv202<.

* gender
clonevar gender= cfps2010_gender
* age
clonevar byr=cfps2010_qa1y_best
*sch, work
g inschool=wc01
replace inschool=wc01ckp2 if wc01ckp2>0 & wc01ckp2<.

g       inwork =qg101 
replace inwork=5 if inschool==1 & qg101<0

 
keep pid fid12 fid10 qe101 qe102 qe103 qe104 cfps2010_marriage longform shortform gender byr* educ*  inschool inwork   ///
	 income_adj sch2012 edu2012 eduy2012 urban12
g in_12a=1
foreach v of varlist _all {
rename `v' `v'_12a
} 
rename pid_12a pid

tempfile w12a
save `w12a.dta'


use $w12hh, clear

// parental education
clonevar educf_12hh= feduc12
replace  educf_12hh= tb4_a12_f if feduc12<0 | feduc12==.

clonevar educm_12hh= meduc12
replace  educm_12hh= tb4_a12_m if meduc12<0 | meduc12==.

// parental byr
clonevar byrf_12hh= fbirth12
replace  byrf_12hh=tb1y_a_f if tb1y_a_f>0 & tb1y_a_f<.

clonevar byrm_12hh= mbirth12
replace  byrm_12hh=tb1y_a_m if tb1y_a_m>0 & tb1y_a_m<.

//own demo
clonevar educ_12hh= tb4_a12_p

// spouse demo
clonevar educs_12hh=tb4_a12_s
clonevar byrs_12hh= tb1y_a_s

// update parental alive and living arragement
// use infomation on living arragement, alive and tongzao chifan

// it looks this chunck has done nothing 
local fm "p s f m"
foreach x of local fm {
*alive 
replace alive_a_`x' =.  if  alive_a_`x'<0
g       alive`x'_12hh=1 if  alive_a_`x'==1 
replace alive`x'_12hh=0 if  alive_a_`x'==0
replace alive`x'_12hh=0 if  alive_a_`x'==. & deathreason_`x' != "-1" & deathreason_`x' != "-8" & deathreason_`x' != ""

*co-residency 
g        live`x'_12hh=1 if tb6_a12_`x'==1 
replace  live`x'_12hh=0 if tb6_a12_`x'==0 | co_a12_`x'==0 
replace  live`x'_12hh=0 if alive`x'_12hh==0
}


keep fid12 pid code_a_p alive_a_p tb3_a12_p tb6_a12_p tb601_a12_p co_a12_p tb1y_a_p tb4_a12_p qa301_a12_p  tb2_a_p  ///
	     pid_s code_a_s alive_a_s tb3_a12_s tb6_a12_s tb601_a12_s co_a12_s tb1y_a_f tb4_a12_f qa301_a12_f  tb2_a_f  ///
		 pid_f code_a_f alive_a_f tb3_a12_f tb6_a12_f tb601_a12_f co_a12_f tb1y_a_m tb4_a12_m qa301_a12_m  tb2_a_m  ///
		 pid_m code_a_m alive_a_m tb3_a12_m tb6_a12_m tb601_a12_m co_a12_m tb1y_a_s tb4_a12_s qa301_a12_s  tb2_a_s  ///
		 educf_12hh educm_12hh byrf_12hh byrm_12hh 	
		 
local fm "p s f m"
foreach x of local fm {
	rename (code_a_`x' alive_a_`x' tb3_a12_`x' tb6_a12_`x' tb601_a12_`x' co_a12_`x' tb2_a_`x'  tb1y_a_`x' )   ///
		   (code`x'12  alive`x'12  mar`x'12    live`x'12   rmig`x'12     co`x'12   gender`x'12 byr`x'12 )
		   }
		   

	rename (pid_s pid_f pid_m) (pids12 pidf12 pidm12)
	rename marp12 mar12_12hh

duplicates drop pid, force 
tempfile w12hh
save `w12hh.dta', replace 


*******14wave*********
use $w14a , clear
keep pid  qea0 qea1 qea2  cfps2012_marriage cfps2012_marriage_update qa301  eeb* cfps_birthy 
	foreach v of varlist _all {
			rename `v' `v'_14a
			}
rename pid_14a pid
g in_14a=1
tempfile w14a
save `w14a.dta' 

use $w14hh, clear
keep fid14 pid  code_a_p alive_a14_p tb3_a14_p tb6_a14_p tb601_a14_p co_a14_p  tb1y_a_p   tb4_a14_p  qa301_a14_p  tb2_a_p  ///
	      pid_f code_a_f alive_a14_f tb3_a14_f tb6_a14_f tb601_a14_f co_a14_f  tb1y_a_f   tb4_a14_f  qa301_a14_f  tb2_a_f  ///
		  pid_m code_a_m alive_a14_m tb3_a14_m tb6_a14_m tb601_a14_m co_a14_m  tb1y_a_m   tb4_a14_m  qa301_a14_m  tb2_a_m   ///
		  pid_s code_a_s alive_a14_s tb3_a14_s tb6_a14_s tb601_a14_s co_a14_s  tb1y_a_s   tb4_a14_s  qa301_a14_s  tb2_a_s
 				 
g in_14hh=1
local fm "p s f m"
foreach x of local fm {
	rename (code_a_`x' alive_a14_`x' tb3_a14_`x' tb6_a14_`x' tb601_a14_`x' co_a14_`x' tb1y_a_`x' qa301_a14_`x' tb2_a_`x' )   ///
		   (code`x'14  alive`x'14    mar`x'14    live`x'14   rmig`x'14     co`x'14    byr`x'14   hukou`x'14    gender`x'14 )
		   }
	rename (pid_s pid_f pid_m) (pids14 pidf14 pidm14)
	rename marp14 mar14_14hh

duplicates drop pid, force 
tempfile w14hh
save `w14hh.dta', replace 

************16 wave***********
use $w16a, clear
keep pid  qea0 qea1 qea2  cfps2014_marriage cfps2014_marriage_update  eeb*
	foreach v of varlist qea0 qea1 qea2  cfps2014_marriage cfps2014_marriage_update eeb*{
			rename `v' `v'_16a
			}
g in_16a=1
tempfile w16a
save `w16a.dta' 

use $w16hh,  clear
keep fid16 pid code_a_p alive_a16_p tb3_a16_p tb6_a16_p tb601_a16_p co_a16_p tb2_a_p tb1y_a_p hukou_a16_p ///
	     pid_s code_a_s alive_a16_s tb3_a16_s tb6_a16_s tb601_a16_s co_a16_s tb2_a_s tb1y_a_s hukou_a16_s ///
		 pid_f code_a_f alive_a16_f tb3_a16_f tb6_a16_f tb601_a16_f co_a16_f tb2_a_f tb1y_a_f hukou_a16_f ///
		 pid_m code_a_m alive_a16_m tb3_a16_m tb6_a16_m tb601_a16_m co_a16_m tb2_a_m tb1y_a_m hukou_a16_m	
		  			 
g in_16hh=1
local fm "p s f m"
foreach x of local fm {
	rename (code_a_`x' alive_a16_`x' tb3_a16_`x' tb6_a16_`x' tb601_a16_`x' co_a16_`x' tb2_a_`x'   tb1y_a_`x'  hukou_a16_`x')   ///
		   (code`x'16  alive`x'16    mar`x'16    live`x'16   rmig`x'16     co`x'16    gender`x'16  byr`x'16 hukou`x'16 )
		   }
	rename (pid_s pid_f pid_m) (pids16 pidf16 pidm16)
	
	rename marp16 mar16_16hh

duplicates drop pid, force    
tempfile w16hh
save `w16hh.dta', replace 

use $cross, clear
foreach x of varlist _all {
rename `x' `x'_cross
}
rename pid_cross pid
tempfile cross
save `cross.dta', replace
 
*============merge panel================
 
use `w10a.dta', clear
merge 1:1 pid using `w12a.dta' , nogen
merge 1:1 pid using `w14a.dta' , nogen
merge 1:1 pid using `w16a.dta' , nogen

merge 1:1 pid using "${datadir}\w10hhmerged.dta" , nogen
merge 1:1 pid using `w12hh.dta' , nogen
merge 1:1 pid using `w14hh.dta' , nogen
merge 1:1 pid using `w16hh.dta' , nogen
merge 1:1 pid using `cross.dta' , nogen

save "${datadir}\marriage.dta" ,replace 

erase "${datadir}\w10hhmerged.dta"
