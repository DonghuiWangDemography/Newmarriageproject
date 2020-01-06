
set more off
*cd "/Users/chengcheng/Dropbox/0PPPP_Projects/NewMarriage/rawdata"
*cd "E:\Dropbox\0PPPP_Projects\NewMarriage\rawdata"

clear all 
clear matrix 
set more off 
capture log close 

global date "01022019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 


******************
*** 2010 adult ***
******************

*use "cfps2010adult_report_nat092014.dta", clear
use $w10a, clear

* tag this file
gen tag_i10 = 1

* parent alive
gen alive_f_i10 = 1 if qb411_s_1 > 0 | qb411_s_2 > 0 | qb411_s_3 > 0 | qb411_s_4 > 0 | qb411_s_5 > 0 | qb411_s_6 > 0
gen alive_m_i10 = 1 if qb511_s_1 > 0 | qb511_s_2 > 0 | qb511_s_3 > 0 | qb511_s_4 > 0 | qb511_s_5 > 0 | qb511_s_6 > 0 | qb511_s_7 > 0 | qb511_s_8 > 0

* marital status
replace qe1_best = . if qe1_best < 0
rename qe1_best marstat_i10

* gender
gen male_i10 = 1 if gender == 1
replace male_i10 = 0 if gender == 0

* age
gen bthy_i10 = qa1y_best
replace bthy_i10 = . if qa1y_best < 0

* education
rename edu2010 edu_i10

* occupation
* 1 farm 2 employed 3 self 4 unemployed 5 never worked
gen empstat = 1 if qg303 == 5
replace empstat = 2 if qg303 == 3
replace empstat = 3 if qg303 == 1
replace empstat = 4 if qg3 == 0 & qg2 == 1
replace empstat = 5 if qg2 == 0

gen occup_main = 1 if qg307code >=10000 & qg307code < 20000
replace occup_main = 2 if qg307code >=20000 & qg307code < 30000
replace occup_main = 3 if qg307code >=30000 & qg307code < 40000
replace occup_main = 4 if qg307code >=40000 & qg307code < 50000
replace occup_main = 5 if qg307code >=50000 & qg307code < 60000
replace occup_main = 6 if qg307code >=60000 & qg307code < 70000
replace occup_main = 7 if qg307code >=70000 & qg307code < 80000
replace occup_main = 7 if qg307code >=90000 & qg307code < 100000
replace occup_main = 8 if qg307code >=80000 & qg307code < 90000
replace occup_main = 5 if qg4 == 1 & occup_main == .

* 1 management (10000-10501) 
* 2 prof (20000-21901)
* 3 administr (30000-30901) 
* 4 busine (40000-40901)
* 5 agri (50000-50902) 
* 6 manuf (60000-62903)
* 7 other (70000, 90000) 
* 8 unemployed (80000)
* 9 never employed 

gen occup_i10 = occup_main if occup_main != . & occup_main != 8
replace occup_i10 = 8 if occup_i10 == . & empstat == 4
replace occup_i10 = 9 if occup_i10 == . & empstat == 5
replace occup_i10 = 5 if occup_i10 == . & empstat == 1

* income
replace income = 0 if income < 0 & occup_i10 == 9
replace income = 0 if income < 0 & occup_i10 == 8
replace income = . if income < 0
rename income income_i10

* current hukou
gen urbanhukou_i10 = 0 if qa2 == 1
replace urbanhukou_i10 = 1 if qa2 == 3
replace urbanhukou_i10 = 9 if qa2 == 5 | qa2 == 79

* hukou at 3 (335 neither)
gen urbanhukou_a3_i10 = 0 if qa302 == 1
replace urbanhukou_a3_i10 = 1 if qa302 == 3
replace urbanhukou_a3_i10 = 9 if qa302 == 5 | qa302 == 79

* hukou at 12 (211 neither)
gen urbanhukou_a12_i10 = 0 if qa402 == 1
replace urbanhukou_a12_i10 = 1 if qa402 == 3
replace urbanhukou_a12_i10 = 9 if qa402 == 5 | qa402 == 79

keep pid *_i10
sort pid

*save "gen_i10.dta", replace
save "${datadir}\gen_i10.dta", replace 
*******************
*** 2010 roster ***
*******************

use $w10hh, clear

* tag this file
gen tag_h10 = 1

* spouse id
gen hassid_h10 = 1 if pid_s > 0
replace hassid_h10 = 0 if pid_s < 0
rename pid_s pid_s_h10
replace pid_s_h10 = . if pid_s_h10 < 0

* parent alive
replace alive_a_f = . if alive_a_f < 0
rename alive_a_f alive_f_h10

replace alive_a_m = . if alive_a_m < 0
rename alive_a_m alive_m_h10

* marital status
replace tb3_a_p = . if tb3_a_p < 0
rename tb3_a_p marstat_h10

* parent cores
gen     cores_f_h10 = 1 if tb6_a_f == 1
replace cores_f_h10 = 0 if co_f == 0 | tb6_a_f == 0
replace cores_f_h10 = 0 if alive_f_h10 == 0

gen cores_m_h10 = 1 if tb6_a_m == 1
replace cores_m_h10 = 0 if co_m == 0 | tb6_a_m == 0
replace cores_m_h10 = 0 if alive_m_h10 == 0

gen inhh_h10 = 1 if tb6_a_p == 1
replace inhh_h10 = 0 if tb6_a_p == 0

gen inhh_s_h10 = 1 if tb6_a_s == 1
replace inhh_s_h10 = 0 if tb6_a_s == 0 | co_s == 0

* gender
gen male_h10 = 1 if tb2_a_p == 1
replace male_h10 = 0 if tb2_a_p == 0

* age
gen bthy_h10 = birthy_best
replace bthy_h10 = . if birthy_best < 0

* parent age
gen bthy_f_h10 = fbirthy if fbirthy != .
replace bthy_f_h10 = tb1y_a_f if bthy_f_h10 == . & tb1y_a_f > 0 & tb1y_a_f != .
replace bthy_f_h10 = 2010 - tb1b_a_f if bthy_f_h10 == . & tb1b_a_f > 0 & tb1b_a_f != .

gen bthy_m_h10 = mbirthy if mbirthy != .
replace bthy_m_h10 = tb1y_a_m if bthy_m_h10 == . & tb1y_a_m > 0 & tb1y_a_m != .
replace bthy_m_h10 = 2010 - tb1b_a_m if bthy_m_h10 == . & tb1b_a_m > 0 & tb1b_a_m != .

* education
replace tb4_a_p = . if tb4_a_p < 0
rename tb4_a_p edu_h10

* parent education
gen edu_f_h10 = feduc
replace edu_f_h10 = tb4_a_f if tb4_a_f > 0 & tb4_a_f != . & edu_f_h10 == .

gen edu_m_h10 = meduc
replace edu_m_h10 = tb4_a_m if tb4_a_m > 0 & tb4_a_m != . & edu_m_h10 == .

* parent occupation
* 1 management (10000-10501)
* 2 prof (20000-21901)
* 3 administr (30000-30901) 
* 4 busine (40000-40901)
* 5 agri (50000-50902) 
* 6 manuf (60000-62903)
* 7 other (70000, 90000) 
* 8 unemployed (80000)

gen occup_f_h10 = 1 if foccupcode >=10000 & foccupcode < 20000
replace occup_f_h10 = 2 if foccupcode >=20000 & foccupcode < 30000
replace occup_f_h10 = 3 if foccupcode >=30000 & foccupcode < 40000
replace occup_f_h10 = 4 if foccupcode >=40000 & foccupcode < 50000
replace occup_f_h10 = 5 if foccupcode >=50000 & foccupcode < 60000
replace occup_f_h10 = 6 if foccupcode >=60000 & foccupcode < 70000
replace occup_f_h10 = 7 if foccupcode ==70000
replace occup_f_h10 = 7 if foccupcode ==90000
replace occup_f_h10 = 8 if foccupcode ==80000

gen occup_m_h10 = 1 if moccupcode >=10000 & moccupcode < 20000
replace occup_m_h10 = 2 if moccupcode >=20000 & moccupcode < 30000
replace occup_m_h10 = 3 if moccupcode >=30000 & moccupcode < 40000
replace occup_m_h10 = 4 if moccupcode >=40000 & moccupcode < 50000
replace occup_m_h10 = 5 if moccupcode >=50000 & moccupcode < 60000
replace occup_m_h10 = 6 if moccupcode >=60000 & moccupcode < 70000
replace occup_m_h10 = 7 if moccupcode ==70000
replace occup_m_h10 = 7 if moccupcode ==90000
replace occup_m_h10 = 8 if moccupcode ==80000

* parent hukou
gen urbanhukou_f_h10 = 0 if td8_a_f == 1
replace urbanhukou_f_h10 = 1 if td8_a_f == 3

gen urbanhukou_m_h10 = 0 if td8_a_m == 1
replace urbanhukou_m_h10 = 1 if td8_a_m == 3

* parent marital status (for alive imputation)
gen marstat_f_h10 = tb3_a_f
gen marstat_m_h10 = tb3_a_m
rename co_f co_f_h10
rename co_m co_m_h10

* household size
bysort fid: egen hhsize_h10 = sum(inhh_h10)

keep pid fid provcd code_a_p code_a_f code_a_m *_h10
sort pid

*save "gen_h10.dta", replace
save "${datadir}\gen_h10.dta", replace 

*******************
*** 2010 family ***
*******************

*use "cfps2010family_report_nat092014.dta", clear
use $w10hh2, clear

* tag this file
gen tag_f10 = 1

* farm or family business
replace fk1 = . if fk1 < 0
rename fk1 farm_f10
replace fe3 = . if fe3 < 0
rename fe3 fambus_f10

* household income
rename faminc_net faminc_f10

* head of household
replace tb7 = . if tb7 < 0
rename tb7 head_f10

* homeownership
rename fd1 own_f10
rename fd101_s_1 owner1_f10
rename fd101_s_2 owner2_f10
rename fd101_s_3 owner3_f10
rename fd110 owner4_f10

* urban residence
rename urban urban_f10

* square meters
replace fd2 = . if fd2 < 0
rename fd2 hhsqm_f10

* other owned housing assets
gen otherhh_f10 = 0 if fd7 == 0
replace otherhh_f10 = fd701 if fd7 == 1 & fd701 >= 0

* other housing assets square meters
gen otherhhsqm_f10 = 0 if fd7 == 0
replace otherhhsqm_f10 = fd702 if fd7 == 1 & fd702 >= 0

* housing difficulty
gen hhdiff_f10 = 1 if fd8_s_1 >= 1 & fd8_s_1 <=77
replace hhdiff_f10 = 1 if hhdiff_f10 == . & fd8_s_2 >= 1 & fd8_s_2 <=77
replace hhdiff_f10 = 1 if hhdiff_f10 == . & fd8_s_3 >= 1 & fd8_s_3 <=77
replace hhdiff_f10 = 0 if hhdiff_f10 == . & fd8_s_1 == 78

keep fid *_f10
sort fid

*save "gen_f10.dta", replace
save "${datadir}\gen_f10.dta", replace 
******************
*** 2012 adult ***
******************

*use "cfps2012adultcombined_092015compress.dta", clear
use $w12a, clear

* tag this file
gen tag_i12 = 1

* marital status 2010
replace cfps2010_marriage = . if cfps2010_marriage == 0
rename cfps2010_marriage marstat_10_i12

* marital status 2012
replace qe104 = . if qe104 < 0
rename qe104 marstat_i12

* gender
gen male_i12 = 1 if cfps2012_gender == 1
replace male_i12 = 0 if cfps2012_gender == 0

* age
gen bthy_i12 = cfps2012_birthy
replace bthy_i12 = . if cfps2012_birthy < 0

* parent age
gen bthy_f_i12 = qv101a if qv101a > 0 & qv101a != .
replace bthy_f_i12 = 2012 - qv101c if qv101c > 0 & qv101c != .

gen bthy_m_i12 = qv201y if qv201y > 0 & qv201y != .
replace bthy_m_i12 = 2012 - qv201b if qv201b > 0 & qv201b != .

* parent educ
gen edu_f_i12 = qv102 if qv102 > 0 & qv102 != .
gen edu_m_i12 = qv202 if qv202 > 0 & qv202 != .

* parent occupation
gen occup_f_i12 = 1 if qv103code_best >=10000 & qv103code_best < 20000
replace occup_f_i12 = 2 if qv103code_best >=20000 & qv103code_best < 30000
replace occup_f_i12 = 3 if qv103code_best >=30000 & qv103code_best < 40000
replace occup_f_i12 = 4 if qv103code_best >=40000 & qv103code_best < 50000
replace occup_f_i12 = 5 if qv103code_best >=50000 & qv103code_best < 60000
replace occup_f_i12 = 6 if qv103code_best >=60000 & qv103code_best < 70000
replace occup_f_i12 = 7 if qv103code_best ==70000
replace occup_f_i12 = 7 if qv103code_best ==90000
replace occup_f_i12 = 8 if qv103code_best ==80000

gen occup_m_i12 = 1 if qv203code_best >=10000 & qv203code_best < 20000
replace occup_m_i12 = 2 if qv203code_best >=20000 & qv203code_best < 30000
replace occup_m_i12 = 3 if qv203code_best >=30000 & qv203code_best < 40000
replace occup_m_i12 = 4 if qv203code_best >=40000 & qv203code_best < 50000
replace occup_m_i12 = 5 if qv203code_best >=50000 & qv203code_best < 60000
replace occup_m_i12 = 6 if qv203code_best >=60000 & qv203code_best < 70000
replace occup_m_i12 = 7 if qv203code_best ==70000
replace occup_m_i12 = 7 if qv203code_best ==90000
replace occup_m_i12 = 8 if qv203code_best ==80000

keep pid *_i12
sort pid


*save "gen_i12.dta", replace
save "${datadir}\gen_i12.dta" , replace 
*******************
*** 2012 roster ***
*******************

*use "cfps2012famros_092015compress.dta", clear
use $w12hh, clear


* discard duplicated entries which are records of people who changed households, keep only those who are in the household
duplicates tag pid, gen(dup)
drop if dup != 0 & co_a12_p == 0

rename alive_a_p alive_p_h12

* tag this file
gen tag_h12 = 1

* spouse id
gen hassid_h12 = 1 if pid_s > 0
replace hassid_h12 = 0 if pid_s < 0
rename pid_s pid_s_h12
replace pid_s_h12 = . if pid_s_h12 < 0

* parent alive
replace alive_a_f = . if alive_a_f < 0
replace alive_a_f = 0 if alive_a_f == . & deathreason_f != "-1" & deathreason_f != "-8" & deathreason_f != ""
rename alive_a_f alive_f_h12

replace alive_a_m = . if alive_a_m < 0
replace alive_a_m = 0 if alive_a_m == . & deathreason_m != "-1" & deathreason_m != "-8" & deathreason_m != ""
rename alive_a_m alive_m_h12

* marital status
replace tb3_a12_p = . if tb3_a12_p < 0
rename tb3_a12_p marstat_h12

* parent cores
gen     cores_f_h12 = 1 if tb6_a12_f == 1
replace cores_f_h12 = 0 if co_a12_f == 0 | tb6_a12_f == 0
replace cores_f_h12 = 0 if alive_f_h12 == 0
*dw modify:
replace cores_f_h12 = 0 if tb601_a12_f >0 &  tb601_a12_f <12  // has valid reasons to moveout

gen cores_m_h12 = 1 if tb6_a12_m == 1
replace cores_m_h12 = 0 if co_a12_m == 0 | tb6_a12_m == 0
replace cores_m_h12 = 0 if alive_m_h12 == 0
*dw modify
replace cores_m_h12 = 0 if tb601_a12_m >0 &  tb601_a12_m <12  // has valid reasons to moveout


gen inhh_h12 = 1 if tb6_a12_p == 1
replace inhh_h12 = 0 if tb6_a12_p == 0 | co_a12_p == 0

gen inhh_s_h12 = 1 if tb6_a12_s == 1
replace inhh_s_h12 = 0 if tb6_a12_s == 0 | co_a12_s == 0

* gender
gen male_h12 = 1 if tb2_a_p == 1
replace male_h12 = 0 if tb2_a_p == 0

* age
gen bthy_h12 = tb1y_a_p
replace bthy_h12 = . if tb1y_a_p < 0

* parent age
gen bthy_f_h12 = fbirth12 if fbirth12 > 0 & fbirth12 != .
replace bthy_f_h12 = tb1y_a_f if bthy_f_h12 == . & tb1y_a_f > 0 & tb1y_a_f != .
replace bthy_f_h12 = 2012 - tb1b_a_f if bthy_f_h12 == . & tb1b_a_f > 0 & tb1b_a_f != .

gen bthy_m_h12 = mbirth12 if mbirth12 > 0 & mbirth12 != .
replace bthy_m_h12 = tb1y_a_m if bthy_m_h12 == . & tb1y_a_m > 0 & tb1y_a_m != .
replace bthy_m_h12 = 2012 - tb1b_a_m if bthy_m_h12 == . & tb1b_a_m > 0 & tb1b_a_m != .

* parent education
gen edu_f_h12 = feduc12 if feduc12 > 0 & feduc12 != .
replace edu_f_h12 = tb4_a12_f if tb4_a12_f > 0 & tb4_a12_f != . & edu_f_h12 == .

gen edu_m_h12 = meduc12 if meduc12 > 0 & meduc12 != .
replace edu_m_h12 = tb4_a12_m if tb4_a12_m > 0 & tb4_a12_m != . & edu_m_h12 == .

* parent marital status (for alive imputation)
gen marstat_f_h12 = tb3_a12_f
gen marstat_m_h12 = tb3_a12_m
rename co_a12_f co_f_h12
rename co_a12_m co_m_h12

keep pid *_h12
sort pid

*save "gen_h12.dta", replace
save "${datadir}\gen_h12.dta" , replace 

******************
*** 2014 adult ***
******************

use $w14a, clear

* tag this file
gen tag_i14 = 1

* marital status 2012
replace cfps2012_marriage_update = . if cfps2012_marriage_update == 0
rename cfps2012_marriage_update marstat_12_i14

* marital status 2014
replace qea0 = . if qea0 < 0
rename qea0 marstat_i14

* gender
gen male_i14 = 1 if cfps_gender == 1
replace male_i14 = 0 if cfps_gender == 0

* age
gen bthy_i14 = cfps_birthy

keep pid *_i14
sort pid

*save "gen_i14.dta", replace
save "${datadir}\gen_i14.dta" , replace 

*******************
*** 2014 roster ***
*******************

*use "cfps2014famconf_170630.dta", clear
use $w14hh, clear
* discard duplicated entries which are records of people who changed households, keep only those who are in the household
duplicates tag pid, gen(dup)
drop if dup != 0 & co_a14_p == 0

rename alive_a14_p alive_p_h14

* tag this file
gen tag_h14 = 1

* spouse id
gen hassid_h14 = 1 if pid_s > 0
replace hassid_h14 = 0 if pid_s < 0
rename pid_s pid_s_h14
replace pid_s_h14 = . if pid_s_h14 < 0

* parent alive
replace alive_a14_f = . if alive_a14_f < 0
rename  alive_a14_f alive_f_h14

/* additional condition 
replace alive`x'_14hh=0  if  alive_a14_`x'==. & ta401_a14_`x' != "-1" & ta401_a14_`x' != "-2" & ta401_a14_`x' != "-8" // if have valid death reason 
replace alive`x'_14hh=1  if  alive_a14_`x'==. & co_a14_`x' ==1
*/

replace alive_a14_m = . if alive_a14_m < 0
rename alive_a14_m alive_m_h14

* marital status
replace tb3_a14_p = . if tb3_a14_p < 0
rename tb3_a14_p marstat_h14

* parent cores
gen cores_f_h14 = 1 if tb6_a14_f == 1
replace cores_f_h14 = 0 if co_a14_f == 0 | tb6_a14_f == 0
replace cores_f_h14 = 0 if alive_f_h14 == 0

gen cores_m_h14 = 1 if tb6_a14_m == 1
replace cores_m_h14 = 0 if co_a14_m == 0 | tb6_a14_m == 0
replace cores_m_h14 = 0 if alive_m_h14 == 0

gen inhh_h14 = 1 if tb6_a14_p == 1
replace inhh_h14 = 0 if tb6_a14_p == 0 | co_a14_p == 0

gen inhh_s_h14 = 1 if tb6_a14_s == 1
replace inhh_s_h14 = 0 if tb6_a14_s == 0 | co_a14_s == 0

* gender
gen male_h14 = 1 if tb2_a_p == 1
replace male_h14 = 0 if tb2_a_p == 0

* age
gen bthy_h14 = tb1y_a_p
replace bthy_h14 = . if tb1y_a_p < 0

* parent age
gen bthy_f_h14 = tb1y_a_f if tb1y_a_f > 0 & tb1y_a_f != .
gen bthy_m_h14 = tb1y_a_m if tb1y_a_m > 0 & tb1y_a_m != .

* parent education
gen edu_f_h14 = tb4_a14_f if tb4_a14_f > 0 & tb4_a14_f != .
gen edu_m_h14 = tb4_a14_m if tb4_a14_m > 0 & tb4_a14_m != .

* parent marital status (for alive imputation)
gen marstat_f_h14 = tb3_a14_f
gen marstat_m_h14 = tb3_a14_m
rename co_a14_f co_f_h14
rename co_a14_m co_m_h14

keep pid *_h14
sort pid

*save "gen_h14.dta", replace
save "${datadir}\gen_h14.dta" , replace


******************
*** 2016 adult ***
******************

*use "cfps2016adult_201808.dta", clear
use $w16a, clear

* tag this file
gen tag_i16 = 1

* parent alive
gen     alive_f_i16 = 1 if qf5_a_1 >=1 & qf5_a_1 <= 5
replace alive_f_i16 = 0 if qf5_a_1 == 7
replace alive_f_i16 = 1 if alive_f_i16 == . & cfps_father_alive == 1

gen alive_m_i16 = 1 if qf5_a_2 >=1 & qf5_a_2 <= 5
replace alive_m_i16 = 0 if qf5_a_2 == 7
replace alive_m_i16 = 1 if alive_m_i16 == . & cfps_mother_alive == 1

* marital status 2014
replace cfps2014_marriage_update = . if cfps2014_marriage_update == 0
rename cfps2014_marriage_update marstat_14_i16

* marital status 2016
replace qea0 = . if qea0 < 0
rename qea0 marstat_i16

* gender
gen male_i16 = 1 if cfps_gender == 1
replace male_i16 = 0 if cfps_gender == 0

* age
gen bthy_i16 = cfps_birthy
replace bthy_i16 = . if cfps_birthy < 0

keep pid *_i16
sort pid

*save "gen_i16.dta", replace
save "${datadir}\gen_i16.dta" , replace 
*******************
*** 2016 roster ***
*******************

*use "cfps2016famconf_201804.dta", clear
use $w16hh, clear
* tag this file
gen tag_h16 = 1

rename alive_a16_p alive_p_h16

* spouse id
gen hassid_h16 = 1 if pid_s > 100
replace hassid_h16 = 0 if pid_s < 100
rename pid_s pid_s_h16
replace pid_s_h16 = . if pid_s_h16 < 100

* parent alive
gen alive_f_h16 = 1 if alive_a16_f == 1
replace alive_f_h16 = 0 if alive_a16_f == 0
replace alive_f_h16 = 0 if alive_f_h16 == . & ta4y_a16_f > 0 & ta4y_a16_f != .
replace alive_f_h16 = 0 if alive_f_h16 == . & ta401_a16_f != "-1" & ta401_a16_f != "-8" & ta401_a16_f != ""
replace alive_f_h16 = 1 if alive_f_h16 == . & tb6_a16_f == 1
replace alive_f_h16 = 1 if alive_f_h16 == . & outpers_where16_f >= 1 & outpers_where16_f <= 6

gen alive_m_h16 = 1 if alive_a16_m == 1
replace alive_m_h16 = 0 if alive_a16_m == 0
replace alive_m_h16 = 0 if alive_m_h16 == . & ta4y_a16_m > 0 & ta4y_a16_m != .
replace alive_m_h16 = 0 if alive_m_h16 == . & ta401_a16_m != "-1" & ta401_a16_m != "-8" & ta401_a16_m != ""
replace alive_m_h16 = 1 if alive_m_h16 == . & tb6_a16_m == 1
replace alive_m_h16 = 1 if alive_m_h16 == . & outpers_where16_m >= 1 & outpers_where16_m <= 6

* marital status
replace tb3_a16_p = . if tb3_a16_p < 0
rename tb3_a16_p marstat_h16

* parent cores
gen cores_f_h16 = 1 if tb6_a16_f == 1
replace cores_f_h16 = 0 if co_a16_f == 0 | tb6_a16_f == 0
replace cores_f_h16 = 0 if alive_f_h16 == 0

gen cores_m_h16 = 1 if tb6_a16_m == 1
replace cores_m_h16 = 0 if co_a16_m == 0 | tb6_a16_m == 0
replace cores_m_h16 = 0 if alive_m_h16 == 0

gen inhh_h16 = 1 if tb6_a16_p == 1
replace inhh_h16 = 0 if tb6_a16_p == 0 | co_a16_p == 0

gen inhh_s_h16 = 1 if tb6_a16_s == 1
replace inhh_s_h16 = 0 if tb6_a16_s == 0 | co_a16_s == 0

* gender
gen male_h16 = 1 if tb2_a_p == 1
replace male_h16 = 0 if tb2_a_p == 0

* age
gen bthy_h16 = tb1y_a_p
replace bthy_h16 = . if tb1y_a_p < 0

* parent age
replace tb1y_a_f = . if tb1y_a_f < 0
rename tb1y_a_f bthy_f_h16

replace tb1y_a_m = . if tb1y_a_m < 0
rename tb1y_a_m bthy_m_h16

* parent education
replace tb4_a16_f = . if tb4_a16_f < 0
rename tb4_a16_f edu_f_h16

replace tb4_a16_m = . if tb4_a16_m < 0
rename tb4_a16_m edu_m_h16

* parent marital status (for alive imputation)
gen marstat_f_h16 = tb3_a16_f
gen marstat_m_h16 = tb3_a16_m
rename co_a16_f co_f_h16
rename co_a16_m co_m_h16

keep pid *_h16
sort pid

*save "gen_h16.dta", replace
save "${datadir}\gen_h16.dta" , replace

*****************
*** siblings ****
*****************

*use "cfps2010adult_report_nat092014.dta", clear
use $w10a, clear

*** total number of brothers, non-cores
forvalues i = 1/15{
gen hasbro_`i' = 1 if qb301_a_`i' == 1
replace hasbro_`i' = 1 if hasbro_`i' == . & qb301_a_`i' == 3
replace hasbro_`i' = 0 if hasbro_`i' == . & qb301_a_`i' != 1 & qb301_a_`i' != 3 & qb301_a_`i' > 0
replace hasbro_`i' = 0 if hasbro_`i' == . & qb3count == 0
replace hasbro_`i' = 0 if hasbro_`i' == . & qb1 == 0
}

egen nbro_noncores = rowtotal(hasbro_1 hasbro_2 hasbro_3 hasbro_4 hasbro_5 hasbro_6 hasbro_7 hasbro_8 hasbro_9 hasbro_10 hasbro_11 hasbro_12 hasbro_13 hasbro_14 hasbro_15), missing
replace nbro_noncores = . if qb1 < 0

*** total number of living brothers, non-cores
forvalues i = 1/15{
gen hasbro_a`i' = 1 if hasbro_`i' == 1 & qb304_a_`i' == 1
replace hasbro_a`i' = 0 if hasbro_`i' == 0 | qb304_a_`i' == 0
}

egen nbro_anoncores = rowtotal(hasbro_a1 hasbro_a2 hasbro_a3 hasbro_a4 hasbro_a5 hasbro_a6 hasbro_a7 hasbro_a8 hasbro_a9 hasbro_a10 hasbro_a11 hasbro_a12 hasbro_a13 hasbro_a14 hasbro_a15), missing
replace nbro_anoncores = . if qb1 < 0

*** total number of living siblings, non-cores

forvalues i = 1/15{
gen hassib_`i' = 1 if qb304_a_`i' == 1
replace hassib_`i' = 0 if qb304_a_`i' == 0
replace hassib_`i' = 0 if hassib_`i' == . & qb3count == 0
replace hassib_`i' = 0 if hassib_`i' == . & qb1 == 0
}

egen nsib_noncores = rowtotal(hassib_1 hassib_2 hassib_3 hassib_4 hassib_5 hassib_6 hassib_7 hassib_8 hassib_9 hassib_10 hassib_11 hassib_12 hassib_13 hassib_14 hassib_15), missing
replace nsib_noncores = . if qb1 < 0

*** total number of living siblings, cores/non-cores

rename qb1 nsib_all
rename qb2 nsib_cores

replace nsib_all = . if nsib_all < 0
replace nsib_cores = . if nsib_cores < 0
replace nsib_cores = 0 if nsib_all == 0

gen nsib_alive = nsib_noncores + nsib_cores

keep pid nsib_all nsib_cores nsib_noncores nsib_alive nbro_noncores nbro_anoncores

sort pid
tempfile sibnocore
save  `sibnocore.dta', replace
*save "gen_i10_sib_noncores.dta", replace

*use "cfps2010famconf_report_nat092014.dta", clear
use $w10hh, clear

gen male_p = 1 if tb2_a_p == 1
replace male_p = 0 if tb2_a_p == 0

replace code_a_f = . if code_a_f < 0
replace code_a_m = . if code_a_m < 0

keep pid fid male_p code_a_f code_a_m

rename code_a_f father_p
rename code_a_m mother_p

bysort fid: gen id = _n

forvalues i = 1/26{

gen male_`i'_o = male_p if id == `i'
bysort fid: egen male_`i' = max(male_`i'_o)

gen father_`i'_o = father_p if id == `i'
bysort fid: egen father_`i' = max(father_`i'_o)

gen mother_`i'_o = mother_p if id == `i'
bysort fid: egen mother_`i' = max(mother_`i'_o)

gen fsib_`i' = 1 if father_p == father_`i' & father_p != . & father_`i' != .
replace fsib_`i' = 0 if father_p != father_`i' & father_p != . & father_`i' != .

gen msib_`i' = 1 if mother_p == mother_`i' & mother_p != . & mother_`i' != .
replace msib_`i' = 0 if mother_p != mother_`i' & mother_p != . & mother_`i' != .

gen fson_`i' = 1 if male_`i' == 1 & fsib_`i' == 1
replace fson_`i' = 0 if male_`i' == 0 & fsib_`i' == 1
replace fson_`i' = 0 if fsib_`i' == 0

gen mson_`i' = 1 if male_`i' == 1 & msib_`i' == 1
replace mson_`i' = 0 if male_`i' == 0 & msib_`i' == 1
replace mson_`i' = 0 if msib_`i' == 0

}

drop *_o

egen fsib_s = rowtotal(fsib_1 fsib_2 fsib_3 fsib_4 fsib_5 fsib_6 fsib_7 fsib_8 fsib_9 fsib_10 fsib_11 fsib_12 fsib_13 fsib_14 fsib_15 fsib_16 fsib_17 fsib_18 fsib_19 fsib_20 fsib_21 fsib_22 fsib_23 fsib_24 fsib_25 fsib_26), missing
egen msib_s = rowtotal(msib_1 msib_2 msib_3 msib_4 msib_5 msib_6 msib_7 msib_8 msib_9 msib_10 msib_11 msib_12 msib_13 msib_14 msib_15 msib_16 msib_17 msib_18 msib_19 msib_20 msib_21 msib_22 msib_23 msib_24 msib_25 msib_26), missing
egen fson_s = rowtotal(fson_1 fson_2 fson_3 fson_4 fson_5 fson_6 fson_7 fson_8 fson_9 fson_10 fson_11 fson_12 fson_13 fson_14 fson_15 fson_16 fson_17 fson_18 fson_19 fson_20 fson_21 fson_22 fson_23 fson_24 fson_25 fson_26), missing
egen mson_s = rowtotal(mson_1 mson_2 mson_3 mson_4 mson_5 mson_6 mson_7 mson_8 mson_9 mson_10 mson_11 mson_12 mson_13 mson_14 mson_15 mson_16 mson_17 mson_18 mson_19 mson_20 mson_21 mson_22 mson_23 mson_24 mson_25 mson_26), missing

egen sib_s = rowmax(fsib_s msib_s)
egen son_s = rowmax(fson_s mson_s)

gen nsib_cores_count = sib_s - 1

gen nbro_cores = son_s if male_p == 0 & son_s != .
replace nbro_cores = son_s - 1 if male_p == 1 & son_s > 0 & son_s != .
replace nbro_cores = 0 if nbro_cores == . & nsib_cores_count == 0

keep pid nsib_cores_count nbro_cores

sort pid
merge pid using `sibnocore.dta'
keep if _merge == 3
drop _merge

replace nsib_cores_count = 0 if nsib_cores_count == . & nsib_cores == 0
replace nsib_cores_count = 0 if nsib_cores_count == . & nsib_all == 0
replace nsib_cores_count = 0 if nsib_cores_count == . & nsib_alive == 0

replace nbro_cores = 0 if nbro_cores == . & nsib_cores_count == 0

gen nsib_alive_count = nsib_cores_count + nsib_noncores
gen nbro_alive = nbro_anoncores + nbro_cores

keep pid nsib_alive_count nbro_alive

rename nsib_alive_count nsib_alive_10

gen hasbro_alive_10 = 1 if nbro_alive > 0 & nbro_alive != .
replace hasbro_alive_10 = 0 if nbro_alive == 0

rename nbro_alive nbro_alive_10

sort pid

*save "gen_i10_sib.dta", replace
save "${datadir}\gen_i10_sib.dta"  , replace

*************
*** merge ***
*************

use "${datadir}\gen_i10.dta", replace
sort pid
merge pid using "${datadir}\gen_i10_sib.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_h10.dta"
drop _merge
sort fid
merge fid using "${datadir}\gen_f10.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_i12.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_h12.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_i14.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_h14.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_i16.dta"
drop _merge
sort pid
merge pid using "${datadir}\gen_h16.dta"
drop _merge
sort pid

replace tag_i10 = 0 if tag_i10 == .
replace tag_h10 = 0 if tag_h10 == .
replace tag_f10 = 0 if tag_f10 == .
replace tag_i12 = 0 if tag_i12 == .
replace tag_h12 = 0 if tag_h12 == .
replace tag_i14 = 0 if tag_i14 == .
replace tag_h14 = 0 if tag_h14 == .
replace tag_i16 = 0 if tag_i16 == .
replace tag_h16 = 0 if tag_h16 == .

save "${datadir}\gen_all.dta", replace

erase "${datadir}\gen_i10.dta"
erase "${datadir}\gen_i10_sib.dta"
erase "${datadir}\gen_h10.dta"
erase "${datadir}\gen_f10.dta"
erase "${datadir}\gen_i12.dta"
erase "${datadir}\gen_h12.dta"
erase "${datadir}\gen_i14.dta"
erase "${datadir}\gen_h14.dta"
erase "${datadir}\gen_i16.dta"
erase "${datadir}\gen_h16.dta"

**************
*** recode ***
**************

use "${datadir}\gen_all.dta", clear

**************************
***** marital status *****
**************************

* 1=nevermarried, 2=married, 3=cohabit, 4=divorced, 5=widowed
gen marstat_10 = marstat_10_i12
replace marstat_10 = marstat_i10 if marstat_10 == .
replace marstat_10 = marstat_h10 if marstat_10 == .

gen marstat_12 = marstat_12_i14
replace marstat_12 = marstat_i12 if marstat_12 == .
replace marstat_12 = marstat_h12 if marstat_12 == .

gen marstat_14 = marstat_14_i16
replace marstat_14 = marstat_i14 if marstat_14 == .
replace marstat_14 = marstat_h14 if marstat_14 == .

gen marstat_16 = marstat_i16
replace marstat_16 = marstat_h16 if marstat_16 == .

* assume nevermarried at t+1 nevermarried at t
replace marstat_10 = 1 if marstat_10 == . & marstat_12 == 1
replace marstat_10 = 1 if marstat_10 == . & marstat_14 == 1
replace marstat_10 = 1 if marstat_10 == . & marstat_16 == 1
replace marstat_12 = 1 if marstat_12 == . & marstat_14 == 1
replace marstat_12 = 1 if marstat_12 == . & marstat_16 == 1
replace marstat_14 = 1 if marstat_14 == . & marstat_16 == 1

************************
***** parent alive *****
************************

* 2016, trust as best guess for alive in all years
* if missing and deceased in 2014/2012/2010, treat as deceased
* if missing and not deceased in 2014/2012/2010, leave as missing b/c could deceased in 2016
gen alive_f_16 = alive_f_i16
replace alive_f_16 = alive_f_h16 if alive_f_16 == .
replace alive_f_16 = 0 if alive_f_16 == . & alive_f_h14 == 0
replace alive_f_16 = 0 if alive_f_16 == . & alive_f_h12 == 0
replace alive_f_16 = 0 if alive_f_16 == . & alive_f_i10 == 0
replace alive_f_16 = 0 if alive_f_16 == . & alive_f_h10 == 0
replace alive_f_16 = 1 if cores_f_h16 == 1
replace alive_f_16 = 1 if co_f_h16 == 1
replace alive_f_16 = 0 if alive_f_16 == . & marstat_m_h16 == 5
gen alive_m_16 = alive_m_i16
replace alive_m_16 = alive_m_h16 if alive_m_16 == .
replace alive_m_16 = 0 if alive_m_16 == . & alive_m_h14 == 0
replace alive_m_16 = 0 if alive_m_16 == . & alive_m_h12 == 0
replace alive_m_16 = 0 if alive_m_16 == . & alive_m_i10 == 0
replace alive_m_16 = 0 if alive_m_16 == . & alive_m_h10 == 0
replace alive_m_16 = 1 if cores_m_h16 == 1
replace alive_m_16 = 1 if co_m_h16 == 1
replace alive_m_16 = 0 if alive_m_16 == . & marstat_f_h16 == 5

tab alive_f_16 if  tag_i10==1,m  
tab alive_m_16 if  tag_i10==1,m  

* 2014
* if coresident in 2014, replace as alive in 2014 no matter current report
* if reported alive in 2016, replace as alive in 2014 no matter current report
* if missing and deceased in any previous years, treat as deceased
gen alive_f_14 = alive_f_h14
replace alive_f_14 = 1 if cores_f_h14 == 1
replace alive_f_14 = 1 if alive_f_16 == 1
replace alive_f_14 = 0 if alive_f_14 == . & alive_f_h12 == 0
replace alive_f_14 = 0 if alive_f_14 == . & alive_f_i10 == 0
replace alive_f_14 = 0 if alive_f_14 == . & alive_f_h10 == 0
replace alive_f_14 = 1 if co_f_h14 == 1
replace alive_f_14 = 0 if alive_f_14 == . & marstat_m_h14 == 5
gen alive_m_14 = alive_m_h14
replace alive_m_14 = 1 if cores_m_h14 == 1
replace alive_m_14 = 1 if alive_m_16 == 1
replace alive_m_14 = 0 if alive_m_14 == . & alive_m_h12 == 0
replace alive_m_14 = 0 if alive_m_14 == . & alive_m_i10 == 0
replace alive_m_14 = 0 if alive_m_14 == . & alive_m_h10 == 0
replace alive_m_14 = 1 if co_m_h14 == 1
replace alive_m_14 = 0 if alive_m_14 == . & marstat_f_h14 == 5



tab alive_f_14 if  tag_i10==1,m  
tab alive_m_14 if  tag_i10==1,m  

* 2012
* if coresident in 2012, replace as alive in 2012 no matter current report
* if reported alive in 2016, replace as alive in 2012 no matter current report
* if missing and deceased in any previous years, treat as deceased
gen alive_f_12 = alive_f_h12
replace alive_f_12 = 1 if cores_f_h12 == 1
replace alive_f_12 = 1 if alive_f_16 == 1
replace alive_f_12 = 0 if alive_f_12 == . & alive_f_i10 == 0
replace alive_f_12 = 0 if alive_f_12 == . & alive_f_h10 == 0
replace alive_f_12 = 1 if co_f_h12 == 1
replace alive_f_12 = 0 if alive_f_12 == . & marstat_m_h12 == 5
gen alive_m_12 = alive_m_h12
replace alive_m_12 = 1 if cores_m_h12 == 1
replace alive_m_12 = 1 if alive_m_16 == 1
replace alive_m_12 = 0 if alive_m_12 == . & alive_m_i10 == 0
replace alive_m_12 = 0 if alive_m_12 == . & alive_m_h10 == 0
replace alive_m_12 = 1 if co_m_h12 == 1
replace alive_m_12 = 0 if alive_m_12 == . & marstat_f_h12 == 5

* 2010
* if reported alive in 2016/2014/2012, replace as alive in 2010 no matter current report
* if coresident in 2016/2014/2012/2010, replace as alive in 2010 no matter current report
gen alive_f_10 = 0 if alive_f_h10 == 0 | alive_f_i10 == 0
replace alive_f_10 = alive_f_h10 if alive_f_10 == . & alive_f_h10 != .
replace alive_f_10 = alive_f_i10 if alive_f_10 == . & alive_f_i10 != .
replace alive_f_10 = 1 if alive_f_16 == 1
replace alive_f_10 = 1 if alive_f_14 == 1
replace alive_f_10 = 1 if alive_f_12 == 1
replace alive_f_10 = 1 if cores_f_h16 == 1
replace alive_f_10 = 1 if cores_f_h14 == 1
replace alive_f_10 = 1 if cores_f_h12 == 1
replace alive_f_10 = 1 if cores_f_h10 == 1
replace alive_f_10 = 1 if co_f_h10 == 1
replace alive_f_10 = 0 if alive_f_10 == . & marstat_m_h10 == 5


gen alive_m_10 = 0 if alive_m_h10 == 0 | alive_m_i10 == 0
replace alive_m_10 = alive_m_h10 if alive_m_10 == . & alive_m_h10 != .
replace alive_m_10 = alive_m_i10 if alive_m_10 == . & alive_m_i10 != .
replace alive_m_10 = 1 if alive_m_16 == 1
replace alive_m_10 = 1 if alive_m_14 == 1
replace alive_m_10 = 1 if alive_m_12 == 1
replace alive_m_10 = 1 if cores_m_h16 == 1
replace alive_m_10 = 1 if cores_m_h14 == 1
replace alive_m_10 = 1 if cores_m_h12 == 1
replace alive_m_10 = 1 if cores_m_h10 == 1
replace alive_m_10 = 1 if co_m_h10 == 1
replace alive_m_10 = 0 if alive_m_10 == . & marstat_f_h10 == 5



gen     alive_fm_10 = 1 if alive_f_10 == 1 | alive_m_10 == 1
replace alive_fm_10 = 0 if alive_f_10 == 0 & alive_m_10 == 0
gen     alive_fm_12 = 1 if alive_f_12 == 1 | alive_m_12 == 1
replace alive_fm_12 = 0 if alive_f_12 == 0 & alive_m_12 == 0
gen     alive_fm_14 = 1 if alive_f_14 == 1 | alive_m_14 == 1
replace alive_fm_14 = 0 if alive_f_14 == 0 & alive_m_14 == 0
gen     alive_fm_16 = 1 if alive_f_16 == 1 | alive_m_16 == 1
replace alive_fm_16 = 0 if alive_f_16 == 0 & alive_m_16 == 0



*log using "${logs}\cc_rep_alivefm$date", text replace 
*code line 1-1030 at cc's prelim_2stage_cc_12032018.do

forval i=10(2)16 {
tab alive_f_`i'  if tag_i10==1,m  
tab alive_m_`i'  if tag_i10==1,m 
tab alive_fm_`i' if tag_i10==1,m 
}

g alive_fm=(alive_fm_10==1 & alive_fm_12==1 & alive_fm_14==1 & alive_fm_16==1)

tab alive_fm if tag_i10==1,m  

*log close 
 
 
************************
***** parent cores *****
************************

* coresident with parents only if both Ego and parents are in the household
* noncoresident with parents if either Ego or parents in the household but not both
* cannot determine coresidence if both Ego and parents NOT in the household
gen     cores_f_10 = 1 if cores_f_h10 == 1 & inhh_h10 == 1
replace cores_f_10 = 0 if cores_f_h10 == 0 & inhh_h10 == 1
replace cores_f_10 = 0 if cores_f_h10 == 1 & inhh_h10 == 0
replace cores_f_10 = 0 if alive_f_10 == 0

gen     cores_m_10 = 1 if cores_m_h10 == 1 & inhh_h10 == 1
replace cores_m_10 = 0 if cores_m_h10 == 0 & inhh_h10 == 1
replace cores_m_10 = 0 if cores_m_h10 == 1 & inhh_h10 == 0
replace cores_m_10 = 0 if alive_m_10 == 0

gen     cores_fm_10 = 1 if cores_f_10 == 1 | cores_m_10 == 1
replace cores_fm_10 = 0 if cores_f_10 == 0 & cores_m_10 == 0

gen     cores_f_12 = 1 if cores_f_h12 == 1 & inhh_h12 == 1
replace cores_f_12 = 0 if cores_f_h12 == 0 & inhh_h12 == 1
replace cores_f_12 = 0 if cores_f_h12 == 1 & inhh_h12 == 0
replace cores_f_12 = 0 if alive_f_12 == 0
gen     cores_m_12 = 1 if cores_m_h12 == 1 & inhh_h12 == 1
replace cores_m_12 = 0 if cores_m_h12 == 0 & inhh_h12 == 1
replace cores_m_12 = 0 if cores_m_h12 == 1 & inhh_h12 == 0
replace cores_m_12 = 0 if alive_m_12 == 0
gen     cores_fm_12 = 1 if cores_f_12 == 1 | cores_m_12 == 1
replace cores_fm_12 = 0 if cores_f_12 == 0 & cores_m_12 == 0

gen     cores_f_14 = 1 if cores_f_h14 == 1 & inhh_h14 == 1
replace cores_f_14 = 0 if cores_f_h14 == 0 & inhh_h14 == 1
replace cores_f_14 = 0 if cores_f_h14 == 1 & inhh_h14 == 0
replace cores_f_14 = 0 if alive_f_14 == 0
gen     cores_m_14 = 1 if cores_m_h14 == 1 & inhh_h14 == 1
replace cores_m_14 = 0 if cores_m_h14 == 0 & inhh_h14 == 1
replace cores_m_14 = 0 if cores_m_h14 == 1 & inhh_h14 == 0
replace cores_m_14 = 0 if alive_m_14 == 0
gen     cores_fm_14 = 1 if cores_f_14 == 1 | cores_m_14 == 1
replace cores_fm_14 = 0 if cores_f_14 == 0 & cores_m_14 == 0

gen cores_f_16 = 1 if cores_f_h16 == 1 & inhh_h16 == 1
replace cores_f_16 = 0 if cores_f_h16 == 0 & inhh_h16 == 1
replace cores_f_16 = 0 if cores_f_h16 == 1 & inhh_h16 == 0
replace cores_f_16 = 0 if alive_f_16 == 0
gen cores_m_16 = 1 if cores_m_h16 == 1 & inhh_h16 == 1
replace cores_m_16 = 0 if cores_m_h16 == 0 & inhh_h16 == 1
replace cores_m_16 = 0 if cores_m_h16 == 1 & inhh_h16 == 0
replace cores_m_16 = 0 if alive_m_16 == 0
gen cores_fm_16 = 1 if cores_f_16 == 1 | cores_m_16 == 1
replace cores_fm_16 = 0 if cores_f_16 == 0 & cores_m_16 == 0

log using "${logs}\cc_rep_livepa$date", text replace 
forval i=10(2)16 {
tab cores_fm_`i' if  tag_i10==1,m  
}
log close 

*======restrict sample====
*keep if tag_i10 == 1 
*drop if alive_p_h12 == 0 | alive_p_h14 == 0 | alive_p_h16 == 0
* ignore 3 missing marital status in 2010, N=4,218


******************
***** gender *****
******************
* trust cfps_gender in most recent follow-up adult survey files
gen male = male_i16
replace male = male_i14 if male == .
replace male = male_i12 if male == .
replace male = male_i10 if male == .

***************
***** age *****
***************

* trust cfps_birthy in most recent follow-up adult survey files
gen age = 2010 - bthy_i16
replace age = 2010 - bthy_i14 if age == .
replace age = 2010 - bthy_i12 if age == .
replace age = 2010 - bthy_i10 if age == .
replace age = 2010 - bthy_h16 if age == .
replace age = 2010 - bthy_h14 if age == .
replace age = 2010 - bthy_h12 if age == .
replace age = 2010 - bthy_h10 if age == .

**********************
***** parent age *****
**********************

* trust 2012 individual survey, then most recent household roster
gen bthy_f = bthy_f_i12 if bthy_f_i12 != .
replace bthy_f = bthy_f_h16 if bthy_f == . & bthy_f_h16 != .
replace bthy_f = bthy_f_h14 if bthy_f == . & bthy_f_h14 != .
replace bthy_f = bthy_f_h12 if bthy_f == . & bthy_f_h12 != .
replace bthy_f = bthy_f_h10 if bthy_f == . & bthy_f_h10 != .

gen bthy_m = bthy_m_i12 if bthy_m_i12 != .
replace bthy_m = bthy_m_h16 if bthy_m == . & bthy_m_h16 != .
replace bthy_m = bthy_m_h14 if bthy_m == . & bthy_m_h14 != .
replace bthy_m = bthy_m_h12 if bthy_m == . & bthy_m_h12 != .
replace bthy_m = bthy_m_h10 if bthy_m == . & bthy_m_h10 != .

gen age_f = 2010 - bthy_f
gen age_m = 2010 - bthy_m

gen     age75_f = 1 if age_f >= 75 & age_f != .
replace age75_f = 0 if age_f >=0 & age_f <=75

gen    age75_m = 1 if age_m >= 75 & age_m != .
replace age75_m = 0 if age_m >=0 & age_m <=75

gen     age75_fm = 1 if age75_f == 1 | age75_m == 1
replace age75_fm = 0 if age75_f == 0 & age75_m == 0

*********************
***** education *****
*********************

gen edu = edu_i10
replace edu = edu_h10 if edu == .

gen eduy = 0 if edu == 1
replace eduy = 6 if edu == 2
replace eduy = 9 if edu == 3
replace eduy = 12 if edu == 4
replace eduy = 15 if edu == 5
replace eduy = 16 if edu == 6
replace eduy = 19 if edu == 7 
replace eduy = 22 if edu == 8

****************************
***** parent education *****
****************************

gen     edu_f = edu_f_i12 if edu_f_i12 != . 
replace edu_f = edu_f_h16 if edu_f == . & edu_f_h16 != .
replace edu_f = edu_f_h12 if edu_f == . & edu_f_h12 != . 
replace edu_f = edu_f_h10 if edu_f == . & edu_f_h10 != . 
replace edu_f = edu_f_h14 if edu_f == . & edu_f_h14 != . & edu_f_h14 != 9

gen     edu_m = edu_m_i12 if edu_m_i12 != . 
replace edu_m = edu_m_h16 if edu_m == . & edu_m_h16 != .
replace edu_m = edu_m_h12 if edu_m == . & edu_m_h12 != . 
replace edu_m = edu_m_h10 if edu_m == . & edu_m_h10 != . 
replace edu_m = edu_m_h14 if edu_m == . & edu_m_h14 != . & edu_m_h14 != 9

* NOTE!!!!!! If one missing, max takes the other value!!!!!!!
egen edu_fm_max = rowmax(edu_f edu_m)

gen eduy_fm_max = 0 if edu_fm_max == 1
replace eduy_fm_max = 6 if edu_fm_max == 2
replace eduy_fm_max = 9 if edu_fm_max == 3
replace eduy_fm_max = 12 if edu_fm_max == 4
replace eduy_fm_max = 15 if edu_fm_max == 5
replace eduy_fm_max = 16 if edu_fm_max == 6
replace eduy_fm_max = 19 if edu_fm_max == 7
replace eduy_fm_max = 22 if edu_fm_max == 8

*************************
***** homeownership *****
*************************

replace code_a_p = code_a_p - 100
replace code_a_f = code_a_f - 100
replace code_a_m = code_a_m - 100

forvalues i = 1/4{
replace owner`i'_f10 = . if owner`i'_f10 < 0
gen own_`i'_p = 1 if code_a_p == owner`i'_f10 & code_a_p != .
replace own_`i'_p = 0 if code_a_p != owner`i'_f10 & owner`i'_f10 != . & code_a_p != .
replace own_`i'_p = 0 if own_`i'_p == . & own_f10 >=3 & own_f10 <= 77
gen own_`i'_f = 1 if code_a_f == owner`i'_f10 & code_a_f != .
replace own_`i'_f = 0 if code_a_f != owner`i'_f10 & owner`i'_f10 != . & code_a_f != .
replace own_`i'_f = 0 if own_`i'_f == . & own_f10 >=3 & own_f10 <= 77
gen own_`i'_m = 1 if code_a_m == owner`i'_f10 & code_a_m != .
replace own_`i'_m = 0 if code_a_m != owner`i'_f10 & owner`i'_f10 != . & code_a_m != .
replace own_`i'_m = 0 if own_`i'_m == . & own_f10 >=3 & own_f10 <= 77
}

egen own_p = rowtotal(own_1_p own_2_p own_3_p own_4_p), missing
egen own_f = rowtotal(own_1_f own_2_f own_3_f own_4_f), missing
egen own_m = rowtotal(own_1_m own_2_m own_3_m own_4_m), missing

gen own_fm = 1 if own_f == 1 | own_m == 1
replace own_fm = 0 if own_f == 0 & own_m == 0

gen ownhh = 1 if own_f10 == 1 | own_f10 == 2
replace ownhh = 0 if own_f10 >= 3 & own_f10 <= 77

gen agesq = age*age
gen hasincome = 1 if income_i10 != 0 & income_i10 != .
replace hasincome = 0 if income_i10 == 0

rename *_f10 *
rename tag tag_f10

sort pid

save "${datadir}\gen_all_recode.dta", replace

********************
***** analysis *****
********************

*use "gen_all_recode.dta", clear
use "${datadir}\gen_all_recode.dta", clear
***************************
***** restrict sample *****
***************************



* restrict sample, 2010 adult survey respondents who survived til 2016
keep if tag_i10 == 1 
drop if alive_p_h12 == 0 | alive_p_h14 == 0 | alive_p_h16 == 0

* ignore 3 missing marital status in 2010, N=4,218
keep if marstat_10 == 1 & hassid_h10 == 0

* 99% percentile of age of nevermarried in 2010 who got married in or before 2016 is 39
keep if age >= 20 & age <= 40  // N=2,223 (N=1995 deleted)

gen alive_fm_all = 1 if alive_fm_10 == 1 & alive_fm_12 == 1 & alive_fm_14 == 1 & alive_fm_16 == 1
replace alive_fm_all = 0 if alive_fm_10 == 0 | alive_fm_12 == 0 | alive_fm_14 == 0 | alive_fm_16 == 0

*******************
***** outcome *****
*******************
* transit to marriage, 24% missing on the outcome
gen     married = 1 if marstat_12 == 2 | marstat_14 == 2 | marstat_16 == 2
replace married = 0 if married == . & marstat_12 == 1 & marstat_14 == 1 & marstat_16 == 1

tab cores_fm_10
 
* transit to homeleaving | marriage, 3% missing on the outcome  
gen     homeleave = 1 if marstat_12 == 2 & cores_fm_12 == 0
replace homeleave = 1 if marstat_14 == 2 & cores_fm_14 == 0
replace homeleave = 1 if marstat_16 == 2 & cores_fm_16 == 0

replace homeleave = 0 if marstat_12 == 2 & cores_fm_12 == 1
replace homeleave = 0 if marstat_14 == 2 & cores_fm_14 == 1
replace homeleave = 0 if marstat_16 == 2 & cores_fm_16 == 1

tab homeleave if married==1,m

* instability in living arrangements, 21% missing on the outcome
gen     change = 1 if marstat_12 == 2 & cores_fm_12 == 1 & cores_fm_14 == 0
replace change = 1 if marstat_12 == 2 & cores_fm_12 == 1 & cores_fm_16 == 0
replace change = 1 if marstat_14 == 2 & cores_fm_14 == 1 & cores_fm_16 == 0
replace change = 2 if marstat_12 == 2 & cores_fm_12 == 0 & cores_fm_14 == 1
replace change = 2 if marstat_12 == 2 & cores_fm_12 == 0 & cores_fm_16 == 1
replace change = 2 if marstat_14 == 2 & cores_fm_14 == 0 & cores_fm_16 == 1
replace change = 3 if marstat_12 == 2 & cores_fm_12 == 1 & cores_fm_14 == 1 & cores_fm_16 == 1
replace change = 3 if marstat_14 == 2 & cores_fm_14 == 1 & cores_fm_16 == 1
replace change = 4 if marstat_12 == 2 & cores_fm_12 == 0 & cores_fm_14 == 0 & cores_fm_16 == 0
replace change = 4 if marstat_14 == 2 & cores_fm_14 == 0 & cores_fm_16 == 0



replace urbanhukou_i10 = . if urbanhukou_i10 == 9

save "${datadir}\gen_all_analysis.dta", replace

use "${datadir}\gen_all_analysis.dta", clear
foreach x of numlist 10 12 14 16 {
replace tag_i`x'=. if tag_i`x'==0
}
misschk tag_i10 tag_i12 tag_i14 tag_i16, gen(miss)  // the same


misschk marstat_10  marstat_12 marstat_14 marstat_16, gen(marmiss)

misschk cores_fm_10  cores_fm_12 cores_fm_14 cores_fm_16, gen(livepamiss)

/*
Variables examined for missing values

   #  Variable        # Missing   % Missing
--------------------------------------------
   1  cores_fm_10          20         0.9
   2  cores_fm_12         398        17.9
   3  cores_fm_14         463        20.8
   4  cores_fm_16         529        23.8

Missing for |
      which |
 variables? |      Freq.     Percent        Cum.
------------+-----------------------------------
       1234 |          9        0.40        0.40
       123_ |          6        0.27        0.67
       12_4 |          1        0.04        0.72
       12__ |          3        0.13        0.85
       1___ |          1        0.04        0.90
       _234 |        173        7.78        8.68
       _23_ |         55        2.47       11.16
       _2_4 |         51        2.29       13.45
       _2__ |        100        4.50       17.95
       __34 |        104        4.68       22.63
       __3_ |        116        5.22       27.85
       ___4 |        191        8.59       36.44
       ____ |      1,413       63.56      100.00
------------+-----------------------------------
      Total |      2,223      100.00

Missing for |
   how many |
 variables? |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,413       63.56       63.56
          1 |        408       18.35       81.92
          2 |        213        9.58       91.50
          3 |        180        8.10       99.60
          4 |          9        0.40      100.00
------------+-----------------------------------
      Total |      2,223      100.00

*/




log using "${logs}\result_prelim_2stage.smcl"
**********************
***** regression *****
**********************

**** married ****

logit married ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
urban farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 0

logit married ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
urban farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 1

logit married ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 0 & urban == 1

logit married ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 1 & urban == 1

logit married ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 0 & urban == 0

logit married ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 1 & urban == 0

**** homeleaving ****
logit homeleave ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
urban farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 0 & married == 1

logit homeleave ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
urban farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 1 & married == 1

logit homeleave ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 0 & married == 1 & urban == 1

logit homeleave ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 1 & married == 1 & urban == 1

logit homeleave ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 0 & married == 1 & urban == 0

logit homeleave ///
age agesq eduy eduy_fm_max hasincome income_i10 urbanhukou_i10 ///
hasbro_alive nsib_alive ///
farm faminc ///
hhsize ownhh hhsqm otherhh otherhhsqm hhdiff ///
if male == 1 & married == 1 & urban == 0

log close
