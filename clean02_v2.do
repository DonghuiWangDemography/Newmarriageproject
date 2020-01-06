*Project : transition into first marriage & co-residency   
*Date : 11182018
*Task: data cleaning : marriage from 2010-2018 adult file 
*Note: After 2nd meeting with CC, decided to focus on adults sample . 

*updated on 11/23/2018: 
*1. HH survey: whether ego lives within the hh (tb6_a_p), parental marriage parental alive 
*2. Adult AR section: residential changes  
*3. Marital history 
*4.other baseline var: gender, age, rural/urban ==> from cross panel 

*updated on 12/05/2018
*Add wave 1 predictors 
*Revise code , impute missings based on cc's code 

*updated on 09232019: add living arragements preference in 2014 as time-invariant predictor 

*============================================
//ssc install blindschemes, replace all
//set scheme plotplainblind, permanently

clear all 
clear matrix 
set more off 
capture log close 

global date "01022020"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 

*============================================
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

		*occupation
		clonevar occ=qg307code if qg307code>0
		// misschk occ if inwork==1   // only 56 missing 

		*party membership
		g party=(qa701>0 & qa701<.)

		clonevar iseip=qg307isei

		*income 
		replace income = 0 if income < 0 & inwork == 0

		*hukou
		clonevar hukounow=qa2
		clonevar hukou3=qa302
		clonevar hukou12=qa402

		*Residental mobility and length of stay with parents
		g immobile_child= (qa3==1 & qa4==1)   // if residential location at age 3 & 12 are the same as birth place 
		g parstay_child = (qa303==0 & qa304==0 & qa403==0 & qa404==0) // parents always live together with you from 3-12

		*physical attractiveness
		clonevar attract=qz204
		*height, weight
		clonevar height=qp1 if qp1>0
		clonevar weight=qp2 if qp2>0

		*subjective measure
		clonevar status_sub=qm402 if qm402>0 
		clonevar income_sub=qm401 if qm401>0 


keep pid  provcd qe1 qe1_best gender byr age qa2  educ eduy2010  hukou* alive* everwork  		///
	      inschool inwork farmwork income urban feduc meduc feduy meduy seduc seduy sedu edu* 	///
		  immobile_child parstay_child attract height weight bmivalue iseip status_sub income_sub  ///
		  inwork occ rswt_nat rswt_res 
		  
foreach x of varlist _all {
rename `x' `x'_10a
}

g in_10a=1
rename pid_10a pid 
tempfile w10a
save `w10a.dta', replace 



use $w10hh, clear   // unique fid is  14960
		*parental prestiage 
		replace pid_f=. if pid_f<0
		*how many father's pid missing given iseif missing  
		misschk pid_f if tb5_isei_a_f<0     // 16.9 father pid not missing even if iseif missing 
		list pid_f tb5_isei_a_f in 1/200 if tb5_isei_a_f<0 

		*parental char
		*education 
		clonevar educf_10hh= feduc
		clonevar educm_10hh= meduc

		*byr
		clonevar byf_10hh=fbirthy
		replace  byf_10hh=tb1y_a_f if tb1y_a_f>0 & tb1y_a_f<.

		clonevar bym_10hh= mbirthy
		replace  bym_10hh=tb1y_a_m if tb1y_a_m>0 & tb1y_a_m<.

		*party membership 
		clonevar fparty_10hh=fparty
		clonevar mparty_10hh=mparty

		*occupation prestiage 
		clonevar iseif_10hh=tb5_isei_a_f
		clonevar iseim_10hh=tb5_isei_a_m

		// *Parents Must Live in the household if 修正后家庭成员不同住直系亲属个数(t3count_modify)=0
		// replace co_f=1 if t3count_modify==0 & co_f==-8
		// replace co_m=1 if t3count_modify==0 & co_m==-8

		*own demo
		clonevar educ_10hh= tb4_a_p
		clonevar byr_10hh=birthy_best

		*spouse demo
		clonevar educs_10hh=tb4_a_s
		clonevar bys_10hh=tb1y_a_s
		clonevar bms_10hh=tb1m_a_s

		local fm "p s f m"
		foreach x of local fm {
		*alive 
		replace alive_a_`x' =.  if  alive_a_`x'<0
		g       alive`x'_10hh=1 if  alive_a_`x'==1 
		replace alive`x'_10hh=0 if  alive_a_`x'==0

		*live in the household  
		g        live`x'_10hh=1 if tb6_a_`x'==1 
		replace  live`x'_10hh=0 if tb6_a_`x'==0 | co_`x'==0 | co_`x'==-8
		}
		
*--------------children's inforamtion-----------------

		*if has children 
		forval i=1/10{
		g children`i'=(code_a_c`i' > 100 & code_a_c`i'< . )
		}
		
		egen nchildren_10hh=rowtotal(children*) 
		
		*byr of the eldest child
		*trust birth year, if byr missing, replace with age 
		forval i=1/10{
		clonevar byr_children`i'=  tb1y_a_c`i'       if inrange(tb1y_a_c`i', 1900, 2010)
		replace  byr_children`i' = 2010- tb1b_a_c`i' if byr_children`i'==. & inrange(tb1b_a_c`i', 0,80)	
		}
		egen byr_children_10hh=rowmin(byr_children*)
		
		*gender of the eldest children 
		forval i= 1/10 {
		g male_children_`i'= tb2_a_c`i'  if byr_children`i'==  byr_children_10hh & inrange(tb2_a_c`i', 0, 1)
		}
		egen male_children_10hh=rowmax(male_children_*)
		
		
rename cid cid_hh10

keep fid pid   code_a_p tb3_a_p tb2_a_p tb5_code_a_p tb501_a_p tb6_a_p tb601_a_p co_p  tb1b_a_p td8_a_p tb1b_a_p  birthy_best    ///
	     pid_f code_a_f tb3_a_f tb2_a_f tb5_code_a_f tb501_a_f tb6_a_f tb601_a_f co_f  tb1b_a_f td8_a_f tb1b_a_f  fbirthy   foccupcode ///
		 pid_m code_a_m tb3_a_m tb2_a_m tb5_code_a_m tb501_a_m tb6_a_m tb601_a_m co_m  tb1b_a_m td8_a_m tb1b_a_m  mbirthy   moccupcode  ///
		 pid_s code_a_s tb3_a_s tb2_a_s tb5_code_a_s tb501_a_s tb6_a_s tb601_a_s co_s  tb1b_a_s td8_a_s tb1b_a_s   ///
		 educf_10hh educm_10hh byf_10hh bym_10hh educ_10hh byr_10hh educs_10hh bys_10hh bms_10hh  /// 
		 iseif_10hh iseim_10hh  alive*_10hh live*_10hh *party_10hh cid_hh10 nchildren_10hh byr_children_10hh male_children_10hh

		 
	local fm "p s f m"
	foreach x of local fm {
		rename (code_a_`x'    tb3_a_`x'    tb501_a_`x'  tb601_a_`x'  co_`x'       tb1b_a_`x'  td8_a_`x'     tb2_a_`x' )   ///
			   (code`x'_10hh  mar`x'_10hh  mng`x'_10hh  rmig`x'_10hh co`x'_10hh   age`x'_10hh hukoumig`x'10 gender`x'10)
			   }
			   
	rename (pid_s pid_f pid_m) (pids10 pidf10 pidm10)  
	rename marp_10hh mar10_10hh
	
g in_10hh=1
tempfile w10hh
save `w10hh.dta', replace 



*hh economics roster
use $w10hh2, clear	// N=14798

		foreach x of varlist _all {
		rename `x' `x'_10hh2
		}
		rename fid_10hh2 fid 
		g in_10hh2=1

		merge m:m fid using `w10hh.dta'    // 604 cases from 10hh not matched ? what hapeend ?
		drop _merge 

		*farming household 
		g 		farmhh_10hh2=1 if fk1==1
		replace farmhh_10hh2=0 if fk1==0

		*have nonag family business 
		g 		nonagbushh_10hh2=1 if fe3==1 
		replace nonagbushh_10hh2=0 if fe3==0

		*=======housing============
		* define househownership
		g house_owned10= (fd1_10hh2==1 | fd1_10hh2==2) if in_10hh2==1  // own house or shared ownership with danwei 
		g house_pa10=(fd1_10hh2==6) if in_10hh2==1                    // parents or children provide housing

		g codep = codep_10hh - 100
		g codef = codef_10hh - 100
		g codem = codem_10hh - 100

		rename fd101_s_*_10hh2 ownhouse_*
		rename fd110_10hh2     ownhouse_4  // if has shared ownership with danwei, the id of the housing entitilement 

		forvalues i =1/4{
		replace ownhouse_`i'=. if ownhouse_`i'<0
		g       house`i'p=1 if ownhouse_`i'==codep & codep<.
		replace house`i'p=0 if ownhouse_`i'!=codep & codep<. 
		replace house`i'p=0 if house`i'p==. & house_owned10==0  
		 
		g       house`i'f=1 if ownhouse_`i'==codef & codef<.
		replace house`i'f=0 if ownhouse_`i'!=codef  & codef<. 
		replace house`i'f=0 if  house`i'f==. & house_owned10==0  

		g       house`i'm=1 if ownhouse_`i'==codem & codem<.
		replace house`i'm=0 if  ownhouse_`i'!=codem  & codem<. 
		replace house`i'm=0 if  house`i'm==. & house_owned10==0  
		}
		egen own_p = rowtotal(house*p), missing
		egen own_f = rowtotal(house*f), missing
		egen own_m = rowtotal(house*m), missing

		drop codep codef codem house*p house*f house*m
		 
		rename (own_p own_f own_m)( own_p_10hh2 own_f_10hh2 own_m_10hh2)


		*------------tradition------------
		g       ftree10=1 if fc4_10hh2==1
		replace ftree10=0 if fc4_10hh2==0  
		la var ftree10 "having a genealogy"

		g 		grave10=1  if  fc5_10hh2==1
		replace grave10=0  if  fc5_10hh2==0
		la var grave10 "visiting gravesite"
		

		
save "${datadir}\w10hhmerged.dta" ,replace 


***************12 wave**************** 
use $w12a, clear 

		*parent age
		clonevar byf=qv101a if qv101a>0 & qv101a<.
		replace  byf = 2012 - qv101c if qv101c > 0 & qv101c<.

		clonevar bym=qv201y if qv201y>0 & qv201y<.
		replace  bym = 2012 - qv201b if qv201b > 0 & qv201b < .

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


			*---------------occupation---------------
			*updated on 04302019, Bing Tian's code 

				// Main Occupation Defined by CFPS
				gen 	occ = job2012mn_occu if job2012mn_occu>0 
				replace occ = sg411code_best if sg411code_best>0 & occ==.
				
				// Non-farming Last/Current Occupation 
				*
				gen joblastdate = 0
				gen type = ""
				gen num = .
				*gen nomiss = 0
				local type b c1 c2
				forvalues m = 1/3 {
					local i: word `m' of `type'
					forvalues j = 1/10 {
						replace type = "`i'" if job`i'lastdate_a_`j' > joblastdate & job`i'lastdate_a_`j' != .
						replace num = `j' if job`i'lastdate_a_`j' > joblastdate & job`i'lastdate_a_`j' != .
						*replace nomiss = 1 if nomiss == 0 & (job`i'lastdate_a_`j' !=. & job`i'lastdate_a_`j' > 0)
					}
				}	
				*
				gen cocc = .
				local type b c1 c2
				local qnum 411 510 609
				local N = _N
				forvalues n = 1/`N' {
					forvalues i = 1/3 {
						local t: word `i' of `type'
						local q: word `i' of `qnum'
						forvalues j = 1/10 {
							if type[`n'] == "`t'" & num[`n'] == `j' & qg`q'code_a_`j'[`n']>0 {
								qui replace cocc = qg`q'code_a_`j' in `n'
							}
						}
					}
				}
				replace occ = cocc if occ==.
				// Farming
				replace occ =  50000  if (qg201==1 | qg301==1) & occ==. 



			*attractiveness 
			clonevar attract=qz204

keep pid fid12 fid10 qe101 qe102 qe103 qe104 cfps2010_marriage longform shortform gender by* edu*  inschool inwork   ///
	 income_adj sch2012 edu2012 eduy2012 urban12 occ  attract   // over half of the individua's own income is zero
	 
foreach v of varlist _all {
rename `v' `v'_12a
} 
rename pid_12a pid

g in_12a=1
tempfile w12a
save `w12a.dta'


use $w12hh, clear

	*parental education
	clonevar educf_12hh= feduc12
	replace  educf_12hh= tb4_a12_f if feduc12<0 | feduc12==.

	clonevar educm_12hh= meduc12
	replace  educm_12hh= tb4_a12_m if meduc12<0 | meduc12==.

	*parental byr
	clonevar byf_12hh= fbirth12
	replace  byf_12hh=tb1y_a_f if tb1y_a_f>0 & tb1y_a_f<.

	clonevar bym_12hh= mbirth12
	replace  bym_12hh=tb1y_a_m if tb1y_a_m>0 & tb1y_a_m<.

	*own demo
	clonevar educ_12hh= tb4_a12_p
	clonevar byr_12hh= tb1y_a_p if tb1y_a_p >=0

	*spouse demo
	clonevar educs_12hh=tb4_a12_s
	clonevar bys_12hh= tb1y_a_s
	clonevar bms_12hh= tb1m_a_s

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
	replace  live`x'_12hh=0 if tb6_a12_`x'==0 | co_a12_`x'==0 |co_a12_`x'==-8
	replace  live`x'_12hh=0 if tb601_a12_`x' >0 &  tb601_a12_`x' <12  // has reasons to moveout
	}


*--------------children's inforamtion-----------------
		*if has children 
		forval i=1/10{
		g children`i'=(code_a_c`i' > 100 & code_a_c`i'< . )
		}
		
		egen nchildren_12hh=rowtotal(children*) 
		
		
		*byr/age of the eldest child
		*trust birth year, if byr missing, replace with age 
		forval i=1/10{
		clonevar byr_children`i'=  tb1y_a_c`i'       if inrange(tb1y_a_c`i', 1900, 2012)
		replace  byr_children`i' = 2012- tb1b_a_c`i' if byr_children`i'==. & inrange(tb1b_a_c`i', 0,80)	
		}
		egen byr_children_12hh=rowmin(byr_children*) 
		
		
		*gender of the eldest children 
		forval i= 1/10 {
		g male_children_`i'= tb2_a_c`i'  if byr_children`i'==  byr_children_12hh & inrange(tb2_a_c`i', 0, 1)
		}
		egen male_children_12hh=rowmax(male_children_*)
		
		
			
keep fid12 pid code_a_p  tb3_a12_p tb6_a12_p tb601_a12_p co_a12_p   qa301_a12_p  tb2_a_p  ///
	     pid_s code_a_s  tb3_a12_s tb6_a12_s tb601_a12_s co_a12_s   qa301_a12_f  tb2_a_f  ///
		 pid_f code_a_f  tb3_a12_f tb6_a12_f tb601_a12_f co_a12_f   qa301_a12_m  tb2_a_m  ///
		 pid_m code_a_m  tb3_a12_m tb6_a12_m tb601_a12_m co_a12_m   qa301_a12_s  tb2_a_s  ///
		 alive*_12hh live*_12hh                                                           ///
		 educf_12hh educm_12hh byf_12hh bym_12hh educ_12hh byr_12hh educs_12hh	bys_12hh  bms_12hh nchildren_12hh byr_children_12hh
		 
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

	*farming household 
	g 		farmhh=1 if fk1l==1
	replace farmhh=0 if fk1l==0

	*have nonag family business(个体经营或者私营企业） 
	g 		nonagbushh=1 if fm1==1 
	replace nonagbushh=0 if fm1==0

	keep fid12 fid10 cid code* fk1l ff602est fincom* fq* fr* house* fs6* *asset* *debt* familysize fincperadj_p farmhh nonagbushh resivalue_new
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

	rename (own_p own_f own_m ) (own_p_12hh2 own_f_12hh2 own_m_12hh2)
	
	

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


	clonevar occ=qg303code if qg303code>0
	misschk  occ if inwork==1

	clonevar attract=qz204
	
	*attitude on living arragement 
	clonevar sonstay= qm1003 


keep pid  qea0 qea1 qea2  cfps2012_marriage cfps2012_marriage_update  ///
	 byr gender	hukou  inschool inwork cfps2014edu* income 	occ attract	sonstay			
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

		* birth
		clonevar by`x'_14hh= tb1y_a_`x' if tb1y_a_`x'>0 & tb1y_a_`x'<. 
		clonevar bm`x'_14hh= tb1m_a_`x' if tb1m_a_`x'>0 & tb1m_a_`x'<. 

		* hukou
		clonevar hukou`x'_14hh=qa301_a14_`x' if qa301_a14_`x' >0
		* gender 
		clonevar gender`x'_14hh = tb2_a_`x' if tb2_a_`x'>0

		* marital status
		clonevar mar`x'_14hh=tb3_a14_`x'

		*alive 
		replace alive_a14_`x' =. if  alive_a14_`x'<0
		g       alive`x'_14hh=1  if  alive_a14_`x'==1 
		replace alive`x'_14hh=0  if  alive_a14_`x'==0
		replace alive`x'_14hh=0  if  alive_a14_`x'==. & ta401_a14_`x' != "-1" & ta401_a14_`x' != "-2" & ta401_a14_`x' != "-8" // if have valid death reason 
		replace alive`x'_14hh=1  if  alive_a14_`x'==. & co_a14_`x' ==1

		*co-residency 
		g        live`x'_14hh=1 if tb6_a14_`x'==1 
		replace  live`x'_14hh=0 if tb6_a14_`x'==0 | co_a14_`x'==0 |co_a14_`x'==-8
		replace  live`x'_14hh=0 if alive`x'_14hh==0
		replace  live`x'_14hh=0 if tb601_a14_`x' >0 & tb601_a14_`x' <.  // have reasons to moveout
		
		}
		
		g in_14hh=1
		rename (pid_s pid_f pid_m) (pids14 pidf_14hh pidm_14hh)
		rename marp_14hh mar14_14hh
		
		*--------------children's inforamtion-----------------	
		*if has children 
		forval i=1/10{
		g children`i'=(code_a_c`i' > 100 & code_a_c`i'< . )
		}
		
		egen nchildren_14hh=rowtotal(children*) 
		
		*byr/age of the eldest child
		*trust birth year, if byr missing, replace with age 
		forval i=1/10{
		clonevar byr_children`i'=  tb1y_a_c`i'       if inrange(tb1y_a_c`i', 1900, 2014)
*		replace  byr_children`i' = 2014- tb1b_a_c`i' if byr_children`i'==. & inrange(tb1b_a_c`i', 0,80)	   // no age were found 
		}
		egen byr_children_14hh=rowmin(byr_children*)
				
				
		*gender of the eldest child 
		forval i= 1/10 {
		g male_children_`i'= tb2_a_c`i'  if byr_children`i'==  byr_children_14hh & inrange(tb2_a_c`i', 0, 1)
		}
		egen male_children_14hh=rowmax(male_children_*)

		
*drop duplicates 
duplicates tag pid, gen(dup) 
drop if dup !=0 &  co_a14_p==0  //drop duplicated ppl 

keep pid pid* fid14 *_14hh
tempfile w14hh
save `w14hh.dta', replace 




use $w14hh2, clear	

		*farming household 
		g 		farmhh=1 if fk1l==1
		replace farmhh=0 if fk1l==0

		*have nonag family business(个体经营或者私营企业） 
		g 		nonagbushh=1 if fm1==1 
		replace nonagbushh=0 if fm1==0

		keep fid14 cid  pid*  fk1l fo7_est fincom* house* fr* fs6* fq* familysize farmhh nonagbushh *asset* *debts* resivalue
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

		clonevar occ=qg303code if qg303code>0
		misschk occ if inwork==1

		*attract
		clonevar attract=qz204

keep pid  qea0 qea1 qea2  cfps2014_marriage cfps2014_marriage_update urban16 alivef16 alivem16 gender byr hukou cfps2016edu* income  attract inwork occ
	 
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
		clonevar by`x'_16hh= tb1y_a_`x' if tb1y_a_`x'>0 & tb1y_a_`x'<. 
		clonevar bm`x'_16hh= tb1m_a_`x' if tb1m_a_`x'>0 & tb1m_a_`x'<. 

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


*--------------children's inforamtion-----------------	
		*if has children 
		forval i=1/10{
		g children`i'=(code_a_c`i' > 100 & code_a_c`i'< . )
		}
		
		egen nchildren_16hh=rowtotal(children*) 
		
		*byr/age of the eldest child
		*trust birth year, if byr missing, replace with age 
		forval i=1/10{
		clonevar byr_children`i'=  tb1y_a_c`i'       if inrange(tb1y_a_c`i', 1900, 2016)
*		replace  byr_children`i' = 2016- tb1b_a_c`i' if byr_children`i'==. & inrange(tb1b_a_c`i', 0,80)	
		}
		egen byr_children_16hh=rowmin(byr_children*)
						
		
		*gender of the eldest child 
		forval i= 1/10 {
		g male_children_`i'= tb2_a_c`i'  if byr_children`i'==  byr_children_16hh & inrange(tb2_a_c`i', 0, 1)
		}
		egen male_children_16hh=rowmax(male_children_*)
		
		
		
duplicates tag pid, gen(dup)
drop if dup !=0 & co_a16_p ==0

keep pid fid16 pids16 pidf_16hh pidm_16hh *_16hh

tempfile w16hh
save `w16hh.dta', replace 


use $w16hh2, clear	

		*farming household 
		g 		farmhh=1 if fk1l==1
		replace farmhh=0 if fk1l==5

		*have nonag family business(个体经营或者私营企业） 
		g 		nonagbushh=1 if fm1==1 
		replace nonagbushh=0 if fm1==5


		keep fid16 pid*  fk1l fo7_est fincom* fq* fr* house* fs6* familysize farmhh nonagbushh
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
drop fk2* fc* 
save "${datadir}\marriage.dta" ,replace 

erase "${datadir}\w10hhmerged.dta"
erase "${datadir}\w12hhmerged.dta"
erase "${datadir}\w14hhmerged.dta"
erase "${datadir}\w16hhmerged.dta"

beep

