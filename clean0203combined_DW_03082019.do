
clear all 
clear matrix 
set more off 
capture log close 

global date "01022019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

*global logs "${dir}\logs"
*global graphs "${dir}\graphs"
*global tables "${dir}\tables"
*global code "${dir}\code"


*====================CFPS data ====================
global datadir "${dir}\CFPSrawdata_Chinese"    // data stored at CFPSrawdata_Chinese folder

global w10hh "${datadir}\2010\cfps2010famconf_report_nat092014.dta"
global w10hh2 "${datadir}\2010\cfps2010family_report_nat092014.dta"
global w10a "${datadir}\2010\cfps2010adult_report_nat092014.dta"
global w10c "${datadir}\2010\cfps2010child_report_nat092014.dta"

global w11a "${datadir}\2011\cfps2011adult_102014.dta"

global w12hh "${datadir}\2012\cfps2012famros_092015compress.dta"
global w12a "${datadir}\2012\cfps2012adultcombined_092015compress.dta"
global w12c "${datadir}\2012\cfps2012childcombined_032015compress.dta"
global w12cross "${datadir}\2012\crossyearid_032015compress.dta"
global w12hh2 "${datadir}\2012\cfps2012family_092015compress.dta"

global w14hh "${datadir}\2014\cfps2014famconf_170630.dta"
global w14a "${datadir}\2014\cfps2014adult_170630.dta"
global w14c "${datadir}\2014\Cfps2014child_170630.dta"
global w14hh2 "${datadir}\2014\Cfps2014famecon_170630.dta"

global w16hh "${datadir}\2016\cfps2016famconf_201804.dta"
global w16hh2 "${datadir}\2016\cfps2016famecon_201807.dta" 
global w16a "${datadir}\2016\cfps2016adult_201808.dta"
global w16c "${datadir}\2016\cfps2016child_201807.dta"
global cross "${datadir}\2016\Cfps2016crossyearid_201807.dta"

*============================================
*============================================
* codes migrated from clean02_v2.do
* First round of cleaning 

*1.Merge 10-14 individual & hh sample
* naming convention: 
* a:adult sample ; hh : hh sample ; _c temp var for purpose of correction; 
* varyear1_year2 : year1 : status at the year ; year2:survey year

use $w10a, clear
*individual survey : pid fid gender age education occupation income employment status hukou educational status 

*parental alive : if parents are living with any relatives 
g alivef_c= 1 if qb411_s_1 > 0 | qb411_s_2 > 0 | qb411_s_3 > 0 | qb411_s_4 > 0 | qb411_s_5 > 0 | qb411_s_6 > 0 
g alivem_c= 1 if qb511_s_1 > 0 | qb511_s_2 > 0 | qb511_s_3 > 0 | qb511_s_4 > 0 | qb511_s_5 > 0 | qb511_s_6 > 0 | qb511_s_7 > 0 | qb511_s_8 > 0

clonevar alivef= alive_a_f
clonevar alivem= alive_a_m

replace alivef =alivef_c if alive_a_f<0 
replace alivem =alivem_c if alive_a_m<0 

drop alivef_c alivem_c

*byr 
g byr=qa1y_best if qa1y_best>0  // missing one 
g age=qa1age

*school/ work status 
clonevar inschool=qd3 // N=5 NA
g       inwork =1 if qg3==1 | qg4==1  // currently has a job or current engege ag job
replace inwork=0  if qg3==0 
replace inwork=0 if inwork==. & inschool==1  
replace inwork=0 if inwork==. & qj101>0 &qj101<. // has valid reason for not working  still N=158 mmissing 

g farmwork=(qg4 ==1)
g everwork=(qg2==1)

*income 
replace income = 0 if income < 0 & inwork == 0

*hukou
clonevar hukounow=qa2
clonevar hukou3=qa302
clonevar hukou12=qa402

// Residental mobility and length of stay with parents
g immobile_child= (qa3==1 & qa4==1)   // if residential location at age 3 & 12 are the same as birth place 
g parstay_child = (qa303==0 & qa304==0 & qa403==0 & qa404==0) // parents always live together with you from 3-12


keep pid  provcd qe1 qe1_best gender byr age qa2  educ eduy2010  hukou* alive* everwork  ///
	      inschool inwork farmwork income urban feduc meduc feduy meduy seduc seduy edu* ///
		  immobile_child parstay_child  
		  
foreach x of varlist _all {
rename `x' `x'_10a
}

g in_10a=1
rename pid_10a pid 
tempfile w10a
save `w10a.dta', replace 


use $w10hh, clear
*parental education
g       educf_10hh= feduc
*replace educf_10hh= tb4_a_f if tb4_a_f>0 & educf_10hh==.  // highest ed of father in 2010

g       educm_10hh= meduc
*replace educm_10hh= tb4_a_m if tb4_a_m>0 & educm_10hh==.

*parental byr
clonevar byrf_10hh= fbirthy
replace  byrf_10hh=tb1y_a_f if tb1y_a_f>0 & tb1y_a_f<.

clonevar byrm_10hh= mbirthy
replace  byrm_10hh=tb1y_a_m if tb1y_a_m>0 & tb1y_a_m<.

*parental occupation prestiage 
clonevar iseif_10hh=tb5_isei_a_f
clonevar iseim_10hh=tb5_isei_a_m

*own demo
clonevar educ_10hh= tb4_a_p
clonevar byr_10hh=birthy_best

*spouse demo
clonevar educs_10hh=tb4_a_s
clonevar byrs_10hh=tb1y_a_s

local fm "p s f m"
foreach x of local fm {
*alive 
replace alive_a_`x' =.  if  alive_a_`x'<0
g       alive`x'_10hh=1 if  alive_a_`x'==1 
replace alive`x'_10hh=0 if  alive_a_`x'==0
replace alive`x'_10hh=1 if  alive_a_`x'==. & co_`x'==1             // these codes appear much later in cc's code
replace alive`x'_10hh=1 if  alive_a_`x'==. & tb6_a_`x'==1


*live in the household  
g        live`x'_10hh=1 if tb6_a_`x'==1 
replace  live`x'_10hh=0 if tb6_a_`x'==0 | co_`x'==0  |  co_`x'==-8   // Note: revised in 01072019 : co_`x'=-8 equivalent to code_a_`x'==-8 aka no within family code  
replace  live`x'_10hh=0 if alive`x'_10hh==0
replace  live`x'_10hh=0 if tb601_a_`x' >0 &  tb601_a_`x' <12  // has reasons to moveout
}

keep fid pid   code_a_p tb3_a_p tb2_a_p tb6_a_p tb601_a_p co_p  tb1b_a_p td8_a_p tb1b_a_p  birthy_best    ///
	     pid_f code_a_f tb3_a_f tb2_a_f tb6_a_f tb601_a_f co_f  tb1b_a_f td8_a_f tb1b_a_f  fbirthy   foccupcode ///
		 pid_m code_a_m tb3_a_m tb2_a_m tb6_a_m tb601_a_m co_m  tb1b_a_m td8_a_m tb1b_a_m  mbirthy   moccupcode  ///
		 pid_s code_a_s tb3_a_s tb2_a_s tb6_a_s tb601_a_s co_s  tb1b_a_s td8_a_s tb1b_a_s   ///
		 educf_10hh educm_10hh byrf_10hh byrm_10hh educ_10hh byr_10hh educs_10hh byrs_10hh  ///
		 iseif_10hh iseim_10hh  alive*_10hh live*_10hh
		 
local fm "p s f m"
foreach x of local fm {
	rename (code_a_`x'     tb3_a_`x'    tb601_a_`x'  co_`x'        tb1b_a_`x'  td8_a_`x'     tb2_a_`x')   ///
		   (code`x'_10hh  mar`x'_10hh   rmig`x'_10hh co`x'_10hh    age`x'_10hh hukoumig`x'10 gender`x'10 )
		   }
	rename (pid_s pid_f pid_m) (pids10 pidf10 pidm10)  
	rename marp_10hh mar10_10hh
	
g in_10hh=1
tempfile w10hh
save `w10hh.dta', replace 


*hh economics roster
use $w10hh2, clear	
foreach x of varlist _all {
rename `x' `x'_10hh2
}
rename fid_10hh2 fid 

g in_10hh2=1
merge 1:m fid using `w10hh.dta'  // 604 from 10hh  not matched
drop _merge 

* define househownership
g house_owned10= (fd1_10hh2==1 | fd1_10hh2==2) if in_10hh2==1 // own house or shared ownership with danwei 
g codep = codep_10hh - 100
g codef = codef_10hh - 100
g codem = codem_10hh - 100

rename fd101_s_*_10hh2 ownhouse_*
rename fd110_10hh2     ownhouse_4  // if has shared ownership with danwei, the id of the housing entitilement 

forvalues i =1/4{
replace ownhouse_`i'=. if ownhouse_`i'<0
g       house`i'p=1 if ownhouse_`i'==codep & codep<.
replace house`i'p=0 if ownhouse_`i'!=codep & codep<. 
replace house`i'p=0 if house`i'p==. & house_owned==0  
 
g       house`i'f= 1 if ownhouse_`i'==codef & codef<.
replace house`i'f=0 if ownhouse_`i'!=codef  & codef<. 
replace house`i'f=0 if house`i'f==. & house_owned==0  

g       house`i'm= 1 if ownhouse_`i'==codem & codem<.
replace house`i'm=0 if  ownhouse_`i'!=codem  & codem<. 
replace house`i'm=0 if  house`i'm==. & house_owned==0  
}
egen own_p = rowtotal(house*p), missing
egen own_f = rowtotal(house*f), missing
egen own_m = rowtotal(house*m), missing

drop codep codef codem house*p house*f house*m

rename (own_p own_f own_m)( own_p_10hh2 own_f_10hh2 own_m_10hh2)

save "${datadir}\w10hhmerged.dta" ,replace 


***************12 wave**************** 
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
g 		inschool=wc01
replace inschool=wc01ckp2 if wc01ckp2>0 & wc01ckp2<.


g        inwork =1 if qg101==1 
replace  inwork =1 if qg102==1 & inwork==.
replace  inwork =1 if qg103==1 & qg105==1 & inwork==.   // on vacation or sick leave, treated as in work 
replace  inwork =1 if qg108==1 & inwork==.     // business off season 
replace  inwork =1 if qg109==1 &  inwork==. 
replace  inwork =0 if qg101==5 
replace  inwork =0 if  qg110>0 & qg110<77  // has valid reason not working 
replace  inwork =0 if inwork==. & inschool==1  // only 8 missing 

keep pid fid12 fid10 qe101 qe102 qe103 qe104 cfps2010_marriage longform shortform gender byr* edu*  inschool inwork   ///
	 income_adj sch2012 edu2012 eduy2012 urban12 
	 
foreach v of varlist _all {
rename `v' `v'_12a
} 
rename pid_12a pid

g in_12a=1
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
clonevar byr_12hh= tb1y_a_p if tb1y_a_p >=0

// spouse demo
clonevar educs_12hh=tb4_a12_s
clonevar byrs_12hh= tb1y_a_s

// update parental alive and living arragement
// use infomation on living arragement, alive and tongzao chifan
// it looks this chunck has done little to impute parental co-resideeing information  
local fm "p s f m"
foreach x of local fm {
*alive 
replace alive_a_`x' =.  if  alive_a_`x'<0
g       alive`x'_12hh=1 if  alive_a_`x'==1 
replace alive`x'_12hh=0 if  alive_a_`x'==0
replace alive`x'_12hh=0 if  alive_a_`x'==. & deathreason_`x' != "-1" & deathreason_`x' != "-8" & deathreason_`x' != ""
replace alive`x'_12hh=1 if  alive_a_`x'==. & co_a12_`x' ==1

*living in the household 
g        live`x'_12hh=1 if tb6_a12_`x'==1 
replace  live`x'_12hh=0 if tb6_a12_`x'==0 | co_a12_`x'==0 | co_a12_`x'==-8
replace  live`x'_12hh=0 if alive`x'_12hh==0
replace  live`x'_12hh=0 if tb601_a12_`x' >0 &  tb601_a12_`x' <12  // has reasons to moveout
}

keep fid12 pid code_a_p  tb3_a12_p tb6_a12_p tb601_a12_p co_a12_p   qa301_a12_p  tb2_a_p  ///
	     pid_s code_a_s  tb3_a12_s tb6_a12_s tb601_a12_s co_a12_s   qa301_a12_f  tb2_a_f  ///
		 pid_f code_a_f  tb3_a12_f tb6_a12_f tb601_a12_f co_a12_f   qa301_a12_m  tb2_a_m  ///
		 pid_m code_a_m  tb3_a12_m tb6_a12_m tb601_a12_m co_a12_m   qa301_a12_s  tb2_a_s  ///
		 alive*_12hh live*_12hh                                                           ///
		 educf_12hh educm_12hh byrf_12hh byrm_12hh educ_12hh byr_12hh educs_12hh	byrs_12hh  
		 
local fm "p s f m"
foreach x of local fm {
	rename (code_a_`x'     tb3_a12_`x'   tb601_a12_`x'  co_a12_`x'     tb2_a_`x'        qa301_a12_`x'     )   ///
		   (code`x'_hh12   mar`x'_12hh   rmig`x'12_12hh co`x'12_12hh   gender`x'12_12hh hukou`x'_12hh )
		   }
		   

	rename (pid_s pid_f pid_m) (pids12 pidf12 pidm12)
	rename marp_12hh mar12_12hh
	
g in_12hh=1

duplicates tag pid, gen(dup) 
drop if dup !=0 & cop12_12hh ==0  //drop duplicated ppl 

tempfile w12hh
save `w12hh.dta', replace 

use $w12hh2, clear	
keep fid12 fid10 code* fk1l ff602est fincom* fq* fr* house* fs6* familysize fincperadj_p
foreach x of varlist _all {
rename `x' `x'_12hh2
}
rename fid12_12hh2 fid12 
g in_12hh2=1

merge 1:m fid12 using `w12hh.dta'  
drop _merge 

*define house ownership
g house_owned12=(fq1_12hh2==1 | fq1_12hh2==2 ) if in_12hh2==1 

g codep = codep_hh12 - 100
g codef = codef_hh12 - 100
g codem = codem_hh12 - 100

rename fq3_s_*_12hh2 ownhouse_*
forvalues i =1/4{
replace ownhouse_`i'=. if ownhouse_`i'<0
g       house`i'p=1 if ownhouse_`i'==codep & codep<.
replace house`i'p=0 if ownhouse_`i'!=codep & codep<. 
replace house`i'p=0 if house`i'p==. & house_owned==0  
 
g       house`i'f= 1 if ownhouse_`i'==codef & codef<.
replace house`i'f=0 if ownhouse_`i'!=codef  & codef<. 
replace house`i'f=0 if house`i'f==. & house_owned==0  

g       house`i'm= 1 if ownhouse_`i'==codem & codem<.
replace house`i'm=0 if  ownhouse_`i'!=codem  & codem<. 
replace house`i'm=0 if  house`i'm==. & house_owned==0  
}
egen own_p = rowtotal(house*p), missing
egen own_f = rowtotal(house*f), missing
egen own_m = rowtotal(house*m), missing

drop codep codef codem house*p house*f house*m

rename (own_p own_f own_m ) (own_p_12hh2 own_f_12hh2 own_m_12hh2 )

save "${datadir}\w12hhmerged.dta" ,replace 



*******14wave*********
use $w14a , clear
* age / birth year
clonevar  byr= cfps_birthy
clonevar  gender=cfps_gender
clonevar  hukou=qa301 if qa301>0 & qa301<.

*education
clonevar educ=cfps2014eduy_im // use imputed educational level 

*school work
g       inschool=1 if wc01==1  
replace inschool=0 if wc01==0
replace inschool=0 if employ2014==1 |employ2014==3 //N=1547 missing 
replace inschool=0 if cfps2014_age>= 45 & cfps2014_age<. // replace NA with 0

g		inwork=1 if employ2014==1
replace inwork=0 if employ2014==0 | employ2014==3

replace inwork=1 if inwork==. & pg02==1  // has job in past 12 month
replace inwork=0 if inwork==. & pg02==5  // N=3503 missing 
replace inwork=qga1 if inwork==. & qga1>0 & qga1<.   // work history from 2012- present: 0 change 

keep pid  qea0 qea1 qea2  cfps2012_marriage cfps2012_marriage_update eeb*  ///
	 byr gender	hukou  inschool inwork cfps2014edu* income 					
	foreach v of varlist _all {
			rename `v' `v'_14a
			}
rename pid_14a pid

g in_14a=1
tempfile w14a
save `w14a.dta' 


use $w14hh, clear
local fm "p s f m"
foreach x of local fm {
* code 
clonevar code`x'_14hh=code_a_`x' 
* education
clonevar educ`x'_14hh=tb4_a14_`x'  if tb4_a14_`x'>0 & tb4_a14_`x'<.

* birthyr 
clonevar byr`x'_14hh= tb1y_a_`x' if tb1y_a_`x'>0 & tb1y_a_`x'<. 

*alive 
replace alive_a14_`x' =. if  alive_a14_`x'<0
g       alive`x'_14hh=1  if  alive_a14_`x'==1 
replace alive`x'_14hh=0  if  alive_a14_`x'==0
replace alive`x'_14hh=0  if  alive_a14_`x'==. & ta401_a14_`x' != "-1" & ta401_a14_`x' != "-2" & ta401_a14_`x' != "-8" // if have valid death reason 
replace alive`x'_14hh=1  if  alive_a14_`x'==. & co_a14_`x' ==1

*co-residency 
g        live`x'_14hh=1 if tb6_a14_`x'==1 
replace  live`x'_14hh=0 if tb6_a14_`x'==0 | co_a14_`x'==0 | co_a14_`x'==-8
replace  live`x'_14hh=0 if alive`x'_14hh==0
replace  live`x'_14hh=0 if tb601_a14_`x' >0 & tb601_a14_`x' <.  // have reasons to moveout
 
* hukou
clonevar hukou`x'_14hh=qa301_a14_`x' if qa301_a14_`x' >0
* gender 
clonevar gender`x'_14hh = tb2_a_`x' if tb2_a_`x'>0

* marital status
clonevar mar`x'_14hh=tb3_a14_`x'
}

g in_14hh=1

rename (pid_s pid_f pid_m) (pids14 pidf_14hh pidm_14hh)
rename marp_14hh mar14_14hh

*drop duplicates 
duplicates tag pid, gen(dup) 
drop if dup !=0 &  co_a14_p==0  //drop duplicated ppl 

keep pid pid* fid14 *_14hh
tempfile w14hh
save `w14hh.dta', replace 

use $w14hh2, clear	
keep fid14   pid*  fk1l fo7_est fincom* fq* fr* house* fs6* familysize 
foreach x of varlist _all {
rename `x' `x'_14hh2
}
rename fid14_14hh2 fid14 
g in_14hh2=1

merge 1:m fid14 using `w14hh.dta' , nogen   //887 not merged from using : what happend? 

*define house ownership
g house_owned14=(fq2_14hh2==1 | fq2_14hh2==2 ) if  in_14hh2==1

rename fq3pid_a_*_14hh2 ownhouse_*  // pid of the houseowner

forvalues i =1/8{
replace ownhouse_`i'=. if ownhouse_`i'<0
g       house`i'p=1 if ownhouse_`i'==pid & pid<.   
replace house`i'p=0 if ownhouse_`i'!=pid & pid<. 
replace house`i'p=0 if house`i'p==. & house_owned==0  
 
g       house`i'f= 1 if ownhouse_`i'==pidf_14hh & pidf_14hh<.
replace house`i'f=0 if ownhouse_`i'!=pidf_14hh  & pidf_14hh<. 
replace house`i'f=0 if house`i'f==. & house_owned==0  

g       house`i'm=1 if ownhouse_`i'==pidm_14hh & pidm_14hh<.
replace house`i'm=0 if  ownhouse_`i'!=pidm_14hh  & pidm_14hh<. 
replace house`i'm=0 if  house`i'm==. & house_owned==0  
}
egen own_p = rowtotal(house*p), missing
egen own_f = rowtotal(house*f), missing
egen own_m = rowtotal(house*m), missing

drop codep codef codem house*p house*f house*m

rename (own_p own_f own_m ) (own_p_14hh2 own_f_14hh2 own_m_14hh2 )

save "${datadir}\w14hhmerged.dta" ,replace 


************16 wave***********
use $w16a, clear

* parents alive 
g 		alivef16=cfps_father_alive if cfps_father_alive>0 
replace alivef16=0 if qf5_a_1==7
replace alivef16=1 if qf5_a_1 >=1 & qf5_a_1 <= 5

g 		alivem16=cfps_mother_alive if cfps_mother_alive>0
replace alivem16=0 if qf5_a_2==7
replace alivem16=1 if qf5_a_2 >=1 & qf5_a_2 <= 5


* gender
clonevar gender= cfps_gender
* age
clonevar byr=cfps_birthy

*hukou
clonevar hukou=cfps_hk

*sch, work
g inschool=(pc1==1) // treating NA as 0
g       inwork=1 if employ==1
replace inwork=0 if employ==0 | employ==3 |employ==-8 // treating NA as 0??
replace inwork=0 if inwork==. & inschool==1  //N=3456 missing


keep pid  qea0 qea1 qea2  cfps2014_marriage cfps2014_marriage_update  eeb* urban16 alivef16 alivem16 gender byr hukou cfps2016edu* income  

	 
	foreach v of varlist _all{
			rename `v' `v'_16a
			}
g in_16a=1
rename pid_16a pid 
tempfile w16a
save `w16a.dta' 

use $w16hh,  clear
local fm "p s f m"
foreach x of local fm {
* code
clonevar code`x'_16hh=code_a_`x' 

* education
clonevar educ`x'_16hh=tb4_a16_`x'  if tb4_a16_`x'>0 & tb4_a16_`x'<.

* birthyr 
clonevar byr`x'_16hh= tb1y_a_`x' if tb1y_a_`x'>0 & tb1y_a_`x'<. 

*alive 
replace alive_a16_`x' =. if  alive_a16_`x'<0
g       alive`x'_16hh=1  if  alive_a16_`x'==1 
replace alive`x'_16hh=0  if  alive_a16_`x'==0
replace alive`x'_16hh=0  if  alive_a16_`x'==. & ta401_a16_`x' != "-1" & ta401_a16_`x' != "-2" & ta401_a16_`x' != "-8" // if have valid death reason 
replace alive`x'_16hh=1  if  alive_a16_`x'==. & outpers_where16_`x' >= 1 & outpers_where16_`x' <= 6
replace alive`x'_16hh=1  if  alive_a16_`x'==. & co_a16_`x'==1

*co-residency 
g        live`x'_16hh=1 if tb6_a16_`x'==1 
replace  live`x'_16hh=0 if tb6_a16_`x'==0 | co_a16_`x'==0 |  co_a16_`x'==-8
replace  live`x'_16hh=0 if alive`x'_16hh==0
replace  live`x'_16hh=0 if tb601_a16_`x' >0 &  tb601_a16_`x'<.    // have reasons to moveout
 
* hukou
clonevar hukou`x'_16hh=hukou_a16_`x' if hukou_a16_`x' >0
* gender 
clonevar gender`x'_16hh = tb2_a_`x' if tb2_a_`x'>0

* marital status
clonevar mar`x'_16hh=tb3_a16_`x'
}

g in_16hh=1

rename (pid_s pid_f pid_m) (pids16 pidf_16hh pidm_16hh)
rename marp_16hh mar16_16hh

duplicates tag pid, gen(dup)
drop if dup !=0 & co_a16_p ==0

keep pid fid16 pids16 pidf_16hh pidm_16hh *_16hh

tempfile w16hh
save `w16hh.dta', replace 


use $w16hh2, clear	
keep fid16 pid*  fk1l fo7_est fincom* fq* fr* house* fs6* familysize 
foreach x of varlist _all {
rename `x' `x'_16hh2
}
rename fid16_16hh2 fid16 
g in_16hh2=1


merge 1:m fid16 using `w16hh.dta', nogen


*define house ownership
g house_owned16=(fq2_16hh2==1 | fq2_16hh2==2 ) if  in_16hh2==1


rename fq3pid_a_*_16hh2 ownhouse_*

forvalues i =1/10{
replace ownhouse_`i'=. if ownhouse_`i'<0
g       house`i'p=1 if ownhouse_`i'==pid & pid<.
replace house`i'p=0 if ownhouse_`i'!=pid & pid<. 
replace house`i'p=0 if house`i'p==. & house_owned==0  
 
g       house`i'f=1 if ownhouse_`i'==pidf_16hh & pidf_16hh<.
replace house`i'f=0 if ownhouse_`i'!=pidf_16hh  & pidf_16hh<. 
replace house`i'f=0 if house`i'f==. & house_owned==0  

g       house`i'm= 1 if ownhouse_`i'==pidm_16hh & pidm_16hh<.
replace house`i'm=0 if  ownhouse_`i'!=pidm_16hh  & pidm_16hh<. 
replace house`i'm=0 if  house`i'm==. & house_owned==0  
}
egen own_p = rowtotal(house*p), missing
egen own_f = rowtotal(house*f), missing
egen own_m = rowtotal(house*m), missing

drop codep codef codem house*p house*f house*m

rename (own_p own_f own_m ) (own_p_16hh2 own_f_16hh2 own_m_16hh2 )

save "${datadir}\w16hhmerged.dta" ,replace 


*cross-wave panel 
use $cross, clear
foreach x of varlist _all {
rename `x' `x'_cross
}
rename pid_cross pid
tempfile cross
save `cross.dta', replace
 
 
*============merge adult/hh roster================
 
use `w10a.dta', clear
merge 1:1 pid using `w12a.dta' , nogen
merge 1:1 pid using `w14a.dta' , nogen
merge 1:1 pid using `w16a.dta' , nogen

merge 1:1 pid using "${datadir}\w10hhmerged.dta" , nogen
merge 1:1 pid using "${datadir}\w12hhmerged.dta" , nogen
merge 1:1 pid using "${datadir}\w14hhmerged.dta" , nogen
merge 1:1 pid using "${datadir}\w16hhmerged.dta" , nogen
merge 1:1 pid using `cross.dta' , nogen

//drop some vars 
drop fk2* fc* eeb6*
save "${datadir}\marriage.dta" ,replace 

erase "${datadir}\w10hhmerged.dta"
erase "${datadir}\w12hhmerged.dta"
erase "${datadir}\w14hhmerged.dta"
erase "${datadir}\w16hhmerged.dta"

beep

*===================================================
*===================================================

use "${datadir}\marriage.dta" , clear
*codes from clean03_v2.do
*task : 

*update parental survival information 
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
replace alive`x'14 =1 if alive`x'14== . & live`x'_14hh==1

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


*log using "${logs}\dw_rep_alivefm$date", text replace 
forval i=10(2)16 {
tab alivef`i' if in_10a==1 ,m
tab alivem`i' if in_10a==1, m
}
*log close 
 
*======== living arragement 
* co-residing with parents only if both Ego and parents are in the household 
* not living with parents if either Ego or parents in the household but not both
* not living with parents if both parents died 
* cannot determine coresidence if both Ego and parents NOT in the household [these where missing came from]

foreach x of numlist 10 12 14 16  {
* ego living with father
g       livefp_`x'=1 if livef_`x'hh==1 & livep_`x'hh==1 
replace livefp_`x'=0 if livef_`x'hh==0 & livep_`x'hh==1 

*replace livefp_`x'=0 if livef_`x'hh==. & livep_`x'hh==1          // treat parental living infor missing as not living in the hh
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
*own gender, education, hukou status, income 
*parental education, age 
*household income / wealth 

g male=(gender_cross==1)  // trust cross-wave data

g age=2010-birthy_cross  //  trust cross-wave data after compare with cc's codes
g agesq=age*age

* parent age : 
*what's the rational of imputing parental age? is parental age something that seriously went wrong? 
g       byrf=byrf_12a 
replace byrf=byrf_16hh if byrf==. & byrf_16hh>0
replace byrf=byrf_14hh if byrf==. & byrf_14hh>0
replace byrf=byrf_12hh if byrf==. & byrf_12hh>0
replace byrf=byrf_10hh if byrf==. & byrf_10hh>0

g       agef=2010-byrf if byrf<.
replace agef=agef_10hh if agef==. & agef_10hh>0  


g       byrm=byrm_12a 
replace byrm=byrm_16hh if byrm==. & byrm_16hh>0
replace byrm=byrm_14hh if byrm==. & byrm_14hh>0
replace byrm=byrm_12hh if byrm==. & byrm_12hh>0
replace byrm=byrm_10hh if byrm==. & byrm_10hh>0

g       agem=2010-byrm if byrm<.  //86 missing 

g agef75=(agef>= 75 & agef<.)
g agem75=(agem>= 75 & agem<.)
g agefm_75=(agef75==1 |agem75==1)

* education  
clonevar eduy10=eduy2010_10a  // from 0-22 yrs : 8 missing 
clonevar eduy12=eduy2012_12a  // equivalent to cfps2012eduy_cross // 43 missing 
recode   cfps2014edu_cross  (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22), gen (eduy14)   // 66missing 
recode   cfps2016edu_cross  (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22), gen (eduy16)  // 1900 missing:  no need to worry bx going to use lag1 var
*tab eduy16 if in_16a==1, m



*parental education 
g       feduc=feduc_10a  if feduc_10a<.
replace feduc=educf_16hh if feduc==. & educf_16hh>0
replace feduc=educf_14hh if feduc==. & educf_14hh>0
replace feduc=educf_12hh if feduc==. & educf_12hh>0
replace feduc=educf_10hh if feduc==. & educf_10hh>0
*for those still missing feduc, impute with f's edu when ego at age 14
replace feduc=educf_12a  if feduc==. & educf_12a>0    
*tab feduc if in_10a==1 ,m 

g       meduc=meduc_10a  if meduc_10a<.
replace meduc=educm_16hh if meduc==. & educm_16hh>0
replace meduc=educm_14hh if meduc==. & educm_14hh>0
replace meduc=educm_12hh if meduc==. & educm_12hh>0
replace meduc=educm_10hh if meduc==. & educm_10hh>0
*for those still missing feduc, impute with f's edu when ego at age 14
replace meduc=educm_12a  if meduc==. & educm_12a>0    // 
*tab meduc if in_10a==1 ,m 
* why so many missing in parental edu??

egen edu_fm=rowmax(feduc meduc) 
recode edu_fm (1=0) (2=6) (3=9) (4=12) (5=15) (6=16) (7=19) (8=22)


*=========income
* individual income
g income10=income_10a if income_10a>=0  //only N=1 NA 
g       lincome10=log(income_10a) if income_10a>0   
replace lincome10=0 if inwork_10a==0   // N=1646 missing (4.9)
g hasincome10=(income_10a>0)

g income12=income_adj_12a  //N= only 66missing
g lincome12=log(income_adj_12a) if income_adj_12a>0 & income_adj_12a<.
g hasincome12=(income_adj_12a>0 & income_adj_12a<. )

*!!note: income 14/16 is not adjusted. 
*misschk income_14_cross if in_14hh==1  // no missing in income_14_cross (but many missing in income_14a)  
g 		income14=income_14_cross if income_14_cross>=0  
replace income14=0 if income14==. & in_14hh==1  // no missing
g 		lincome14=log(income14) 
replace lincome14=0 if income14==0
g	 hasincome14=(income14>0 & income14<.)

* income in 16: not found at the cross wave data
g 		income16=income_16a if income_16a >=0  //222 missing 
*replace income16=0 if income16==. & atwork16==0  & in_16a==1

g       lincome16=log(income16) if income16>0 
replace lincome16=0 if income_16a==0
g hasincome16 =(income16>0 & income16<.)

*hh income 
* impute total hh income as sum of individual income in adult survey if hh income missing
* replace total hh income as sum of individual income in adult survey if hh income smaller than sum of total adult income

*2010 
//misschk faminc_old_10hh2 faminc_10hh2 faminc_net_10hh2 faminc_net_old_10hh2 if in_10hh2==1   // all four has around 4% missing (around N=3k)
forval i=1/27{
replace ff502_a_`i'_10hh2=. if ff502_a_`i'_10hh2<0
}

egen faminc_chh1 = rowtotal(ff502_a_*_10hh2), missing
bysort fid: egen faminc_chh= max(faminc_chh1)
replace faminc_10hh2=faminc_chh if faminc_10hh2==.  //329 change made

drop    faminc_chh1 ff502_a_*_10hh2

// for those still zero or missing, impute with total income from adult survey
replace income_10a=. if income_10a<0

bysort fid: egen fincome_c=total(income_10a), missing
bysort fid: egen fincome_cor=max(fincome_c)
replace faminc_10hh2=fincome_cor if  faminc_10hh2==. 
replace faminc_10hh2=fincome_cor if  faminc_10hh2==0 & income_10a<.  
replace faminc_10hh2=fincome_cor if  faminc_10hh2<income_10a  &  income_10a<.
 
//check : family income cannot smaller than individual's income 
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



*===============Housing
*2010
g house_sqr10=fd2_10hh2  if fd2_10hh2>0  // square footage of the house 

*housing difficulty 
egen nodifficulty10= rcount(fd8_s_1_10hh2 fd8_s_2_10hh2 fd8_s_3_10hh2 ), cond(@ == 78)  // no housing difficulty  
g housinghard10=1-nodifficulty

* other owned housing assets
gen otherhh10=(fd7_10hh2 == 1)
*replace otherhh10 = fd701_10hh2 if fd7_10hh2 == 1 & fd701_10hh2 >= 0

* other housing assets square meters
gen     otherhhsqm10 = 0 if fd7_10hh2 == 0
replace otherhhsqm10 = fd702_10hh2 if fd7_10hh2 == 1 & fd702_10hh2 >= 0

*2012
g house_sqr12=fq701_best_12hh2  if fq701_best_12hh2>0  & in_12hh2==1   // square footage of the house  2516 don't knows

g otherhh12=(fr1_12hh2==1) if   in_12hh2==1 

* did not find other square meters in 2012 hh & housing difficulty measure in 2012 survey 
*2014
g house_sqr14=fq801_14hh2 if fq801_14hh2>0 & in_14hh2==1
replace house_sqr14=0 if house_sqr14==. & fq801_14hh2==-8  // replace NAs as 0
g otherhh14=  (fr1_14hh2==1)   if  in_14hh2==1

*2016

g house_sqr16=fq801_16hh2 if fq801_16hh2>0 & in_16hh2==1
replace house_sqr16=0 if house_sqr16==. & fq801_16hh2==-8  // replace NAs as 0

g otherhh16=  (fr1_16hh2==1) if in_16hh2==1

* gross housing asset 
g 		 houseasset10= resivalue_new_10hh2+otherhousevalue_10hh2    // primary housing + other housing 
clonevar houseasset12= houseasset_gross_12hh2  //235 missing 
clonevar houseasset14= houseasset_gross_14hh2
clonevar houseasset16= houseasset_gross_16hh2

* indicators of family weath ? 

*==============other  characheristics
* family size
clonevar familysize10=familysize_10hh2
clonevar familysize12=familysize_12hh2
clonevar familysize14=familysize_14hh2
clonevar familysize16=familysize16_16hh2

*hukou, migrant and urban: use information from cross wave 

foreach x of numlist 10 12 14 16{
clonevar urban`x'= urban10_cross if in_`x'a==1 
g nonaghukou`x'=(hk`x'_cross==3) if in_`x'a==1 
g migrant`x'=(migrant`x'_cross==1) if in_`x'a==1  
}

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
//create a file of all males 
preserve 
keep if tb2_a_p==1
drop  tb2_a_p
rename code_a_* code_a_*bro
tempfile males 
save `males'
restore 

// match each person with all males in the same household
joinby fid using `males', unmatched (master)
// remove self-matches and matches with father
replace code_a_pbro =. if inlist(code_a_pbro, code_a_f, code_a_p)
// remove if no common parent
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
