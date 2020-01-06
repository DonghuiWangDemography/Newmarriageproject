

* get yearly data for marriage, education, and occupation

cd "E:\Dropbox\0PPPP_Projects\NewMarriage\rawdata"

***************
**** 2010 *****
***************
use "cfps2010adult_report_nat092014.dta", clear

* need interview year and month for reference
gen intyear_i10 = cyear
gen intmonth_i10 = cmonth

* must be never married in 2010, unncessary to know EHC of education and occupation prior to 2010.

keep pid *_i10
sort pid
save "gen_i10_ehc.dta", replace

***************
**** 2012 *****
***************
use "cfps2012adultcombined_092015compress.dta", clear

* need interview year and month for reference
gen intyear_i12 = cyear
gen intmonth_i12 = cmonth

*** marriage ***

* may get married btw 2010 and 2012, but divorced/widowed in 2012 survey
* goal is to get the year of first marriage, whether or not it lasted until 2012 survey

* 208 current spouse
* 413 last spouse
* 514 deceased spouse
* 604 first spouse

replace qe208y = . if qe208y < 0
replace qe413y = . if qe413y < 0
replace qe514y = . if qe514y < 0
replace qe604y = . if qe604y < 0
* if answered 208, no response for 413 and 514, some response for 604

egen maryear_i12 = rowmin(qe208y qe413y qe514y qe604y)
* some got married in 2010

replace qe208m = . if qe208m < 0
replace qe413m = . if qe413m < 0
replace qe514m = . if qe514m < 0
replace qe604m = . if qe604m < 0

gen marmonth_i12 = qe208m if maryear_i12 == qe208y & qe208y != .
replace marmonth_i12 = qe413m if maryear_i12 == qe413y & qe413y != .
replace marmonth_i12 = qe514m if maryear_i12 == qe514y & qe514y != .
replace marmonth_i12 = qe604m if maryear_i12 == qe604y & qe604y != .

*** education ***

gen edu_i12 = edu2012

replace kr1 = . if kr1 < 0
gen inschoollevel_i12 = kr1
gen inschoolstart_i12 = kr201 if kr201 > 0 & kr201 != .
replace inschoolstart_i12 = kr302 if kr302 > 0 & kr302 != .
replace inschoolstart_i12 = kra402 if kra402 > 0 & kra402 != .
replace inschoolstart_i12 = kr502 if kr502 > 0 & kr502 != .
replace inschoolstart_i12 = kra602 if kra602 > 0 & kra602 != .
replace inschoolstart_i12 = kr702 if kr702 > 0 & kr702 != .
replace inschoolstart_i12 = kr802 if kr802 > 0 & kr802 != . 

replace kw1 = . if kw1 < 0
gen leftschoollevel_i12 = kw1

gen leftdegree_i12 = 1 if kw303 == 1 | kw404 == 1 | kw504 == 1 | kw604 == 1 | kw704 == 1 | kw804 == 1 | kw904 == 1

replace kw2y = . if kw2y < 0
gen leftschoolend_i12 = kw2y

gen leftschoolstart_i12 = kw302 if kw302 > 0 & kw302 != .
replace leftschoolstart_i12 = kw403 if kw403 > 0 & kw403 != .
replace leftschoolstart_i12 = kw503 if kw503 > 0 & kw503 != .
replace leftschoolstart_i12 = kw603 if kw603 > 0 & kw603 != .
replace leftschoolstart_i12 = kw703 if kw703 > 0 & kw703 != .
replace leftschoolstart_i12 = kw803 if kw803 > 0 & kw803 != .
replace leftschoolstart_i12 = kw903 if kw903 > 0 & kw903 != .

*** occupation ***

* status is not as important as occupation
* we have to assure occupation

* in full-time school are assumed to be unemployed
gen ftstudent_i12 = 1 if wc01 == 1 & kra1 == 1
replace ftstudent_i12 = 0 if wc01 == 0 | kra1 == 5

gen working_i12 = 1 if qg101 == 1
replace working_i12 = 0 if qg101 == 5

gen occup_main = 1 if job2012mn_occu >=10000 & job2012mn_occu < 20000
replace occup_main = 2 if job2012mn_occu >=20000 & job2012mn_occu < 30000
replace occup_main = 3 if job2012mn_occu >=30000 & job2012mn_occu < 40000
replace occup_main = 4 if job2012mn_occu >=40000 & job2012mn_occu < 50000
replace occup_main = 5 if job2012mn_occu >=50000 & job2012mn_occu < 60000
replace occup_main = 6 if job2012mn_occu >=60000 & job2012mn_occu < 70000
replace occup_main = 7 if job2012mn_occu >=70000 & job2012mn_occu < 80000
replace occup_main = 7 if job2012mn_occu >=90000 & job2012mn_occu < 100000
replace occup_main = 8 if job2012mn_occu >=80000 & job2012mn_occu < 90000

* main non-farm job

keep pid *_i12
sort pid
save "gen_i12_ehc.dta", replace

***************
**** 2014 *****
***************
use "cfps2014adult_170630.dta", clear

* need interview year and month for reference
gen intyear_i14 = cyear
gen intmonth_i14 = cmonth

*** marriage ***

* 205 spouse of 2012
* 201 cores spouse
* 401_* spouse since 2012

replace qea205y = . if qea205y < 0
replace eeb201y = . if eeb201y < 0
replace eeb401y_a_1 = . if eeb401y_a_1 < 0
replace eeb401y_a_2 = . if eeb401y_a_2 < 0
replace eeb401y_a_3 = . if eeb401y_a_3 < 0
replace eeb401y_a_4 = . if eeb401y_a_4 < 0
replace eeb401y_a_5 = . if eeb401y_a_5 < 0

* eeb401y_a2 thru 5 are empty

egen maryear_i14 = rowmin(qea205y eeb201y eeb401y_a_1)

replace qea205m = . if qea205m < 0
replace eeb201m = . if eeb201m < 0
replace eeb401m_a_1 = . if eeb401m_a_1 < 0
replace eeb401m_a_2 = . if eeb401m_a_2 < 0
replace eeb401m_a_3 = . if eeb401m_a_3 < 0
replace eeb401m_a_4 = . if eeb401m_a_4 < 0
replace eeb401m_a_5 = . if eeb401m_a_5 < 0

* eeb401m_a2 thru 5 are empty

gen marmonth_i14 = qea205m if maryear_i14 == qea205y & qea205y != .
replace marmonth_i14 = eeb201m if maryear_i14 == eeb201y & eeb201y != .
replace marmonth_i14 = eeb401m_a_1 if maryear_i14 == eeb401y_a_1 & eeb401y_a_1 != .


*** education ***

replace cfps2014edu = . if cfps2014edu < 0
gen edu_i14 = cfps2014edu

replace kr1 = . if kr1 < 0
gen inschoollevel_i14 = kr1
gen inschoolstart_i14 = kr201 if kr201 > 0 & kr201 != .
replace inschoolstart_i14 = kr302 if kr302 > 0 & kr302 != .
replace inschoolstart_i14 = kra402 if kra402 > 0 & kra402 != .
replace inschoolstart_i14 = kr502 if kr502 > 0 & kr502 != .
replace inschoolstart_i14 = kra602 if kra602 > 0 & kra602 != .
replace inschoolstart_i14 = kr702 if kr702 > 0 & kr702 != .
replace inschoolstart_i14 = kr802 if kr802 > 0 & kr802 != . 

replace kw1 = . if kw1 < 0
gen leftschoollevel_i14 = kw1

gen leftdegree_i14 = 1 if kw303 == 1 | kw404 == 1 | kw504 == 1 | kw604 == 1 | kw704 == 1 | kw804 == 1

replace kw2y = . if kw2y < 0
gen leftschoolend_i14 = kw2y

gen leftschoolstart_i14 = kw302 if kw302 > 0 & kw302 != .
replace leftschoolstart_i14 = kw403 if kw403 > 0 & kw403 != .
replace leftschoolstart_i14 = kw503 if kw503 > 0 & kw503 != .
replace leftschoolstart_i14 = kw603 if kw603 > 0 & kw603 != .
replace leftschoolstart_i14 = kw703 if kw703 > 0 & kw703 != .
replace leftschoolstart_i14 = kw803 if kw803 > 0 & kw803 != .

*** occupation ***

keep pid *_i14
sort pid
save "gen_i14_ehc.dta", replace


***************
**** 2016 *****
***************
use "cfps2016adult_201808.dta", clear

* need interview year and month for reference
gen intyear_i16 = cyear
gen intmonth_i16 = cmonth

*** marriage ***

* 205 spouse of 2012
* 201 cores spouse
* 401_* spouse since 2012

replace qea205y = . if qea205y < 0
replace eeb201y = . if eeb201y < 0
replace eeb401y_a_1 = . if eeb401y_a_1 < 0

egen maryear_i16 = rowmin(qea205y eeb201y eeb401y_a_1)

replace qea205m = . if qea205m < 0
replace eeb201m = . if eeb201m < 0
replace eeb401m_a_1 = . if eeb401m_a_1 < 0

* eeb401m_a2 thru 5 are empty

gen marmonth_i16 = qea205m if maryear_i16 == qea205y & qea205y != .
replace marmonth_i16 = eeb201m if maryear_i16 == eeb201y & eeb201y != .
replace marmonth_i16 = eeb401m_a_1 if maryear_i16 == eeb401y_a_1 & eeb401y_a_1 != .

*** education ***

gen edu_i16 = cfps2016edu

replace pc3 = . if pc3 < 0
gen inschoollevel_i16 = pc3

* kw1 is asked among all, including those still in school, in 2016, but not in 2012 and 2014.
* hence kw1's start year is the year before the start of the current in-school status.

replace kw1 = . if kw1 < 0
gen leftschoollevel_i16 = kw1

gen leftdegree_i16 = 1 if kw303_b_1 == 1 | kw404_b_1 == 1 | kw504_b_1 == 1 | kw604_b_1 == 1 | kw704_b_1 == 1 | kw804_b_1 == 1 | kw904_b_1 == 1

replace kw2y_b_1 = . if kw2y_b_1 < 0
gen leftschoolend_i16 = kw2y_b_1

gen leftschoolstart_i16 = kw302_b_1 if kw302_b_1 > 0 & kw302_b_1 != .
replace leftschoolstart_i16 = kw403_b_1 if kw403_b_1 > 0 & kw403_b_1 != .
replace leftschoolstart_i16 = kw503_b_1 if kw503_b_1 > 0 & kw503_b_1 != .
replace leftschoolstart_i16 = kw603_b_1 if kw603_b_1 > 0 & kw603_b_1 != .
replace leftschoolstart_i16 = kw703_b_1 if kw703_b_1 > 0 & kw703_b_1 != .
replace leftschoolstart_i16 = kw803_b_1 if kw803_b_1 > 0 & kw803_b_1 != .
replace leftschoolstart_i16 = kw903_b_1 if kw903_b_1 > 0 & kw903_b_1 != .

*** occupation ***

keep pid *_i16
sort pid
save "gen_i16_ehc.dta", replace

***************************
***** restrict sample *****
***************************

use "gen_all_recode.dta", clear

* restrict sample, 2010 adult survey respondents who survived til 2016
keep if tag_i10 == 1 
drop if alive_p_h12 == 0 | alive_p_h14 == 0 | alive_p_h16 == 0

* ignore 3 missing marital status in 2010, N=4,218
keep if marstat_10 == 1 & hassid_h10 == 0

* aged 18 and above in 2010, must be eligible to marry at least in 2012, N = 3,243
keep if age >= 18

gen alive_fm_all = 1 if alive_fm_10 == 1 & alive_fm_12 == 1 & alive_fm_14 == 1 & alive_fm_16 == 1
replace alive_fm_all = 0 if alive_fm_10 == 0 | alive_fm_12 == 0 | alive_fm_14 == 0 | alive_fm_16 == 0

sort pid
merge pid using "gen_i10_ehc.dta"
drop if _merge == 2
drop _merge

sort pid
merge pid using "gen_i12_ehc.dta"
drop if _merge == 2
drop _merge

sort pid
merge pid using "gen_i14_ehc.dta"
drop if _merge == 2
drop _merge

sort pid
merge pid using "gen_i16_ehc.dta"
drop if _merge == 2
drop _merge

*******************
***** outcome *****
*******************

* drop if married before 2011, N = 3,099
egen maryear = rowmin(maryear_i12 maryear_i14 maryear_i16)
drop if maryear <= 2010

gen married_10 = 0

gen married_11 = 1 if maryear == 2011
replace married_11 = 0 if maryear > 2011 & maryear != .
replace married_11 = 0 if married_11 == . & marstat_12 == 1

gen married_12 = 1 if married_11 == 1
replace married_12 = 1 if married_12 == . & maryear == 2012
replace married_12 = 0 if maryear > 2012 & maryear != .
replace married_12 = 1 if married_12 == . & marstat_12 == 2
replace married_12 = 1 if married_12 == . & marstat_12 == 4
replace married_12 = 0 if married_12 == . & marstat_12 == 1

gen married_13 = 1 if married_11 == 1 | married_12 == 1
replace married_13 = 1 if maryear == 2013
replace married_13 = 0 if maryear > 2013 & maryear != .
replace married_13 = 0 if married_13 == . & marstat_14 == 1

gen married_14 = 1 if married_11 == 1 | married_12 == 1 | married_13 == 1
replace married_14 = 1 if married_14 == . & maryear == 2014
replace married_14 = 0 if maryear > 2014 & maryear != .
replace married_14 = 1 if married_14 == . & marstat_14 == 2
replace married_14 = 1 if married_14 == . & marstat_14 == 4
replace married_14 = 0 if married_14 == . & marstat_14 == 1

gen married_15 = 1 if married_11 == 1 | married_12 == 1 | married_13 == 1 | married_14 == 1
replace married_15 = 1 if maryear == 2015
replace married_15 = 0 if maryear > 2015 & maryear != .
replace married_15 = 0 if married_15 == . & marstat_16 == 1

gen married_16 = 1 if married_11 == 1 | married_12 == 1 | married_13 == 1 | married_14 == 1 | married_15 == 1
replace married_16 = 1 if married_16 == . & maryear == 2016
replace married_16 = 0 if maryear > 2016 & maryear != .
replace married_16 = 1 if married_16 == . & marstat_16 == 2
replace married_16 = 1 if married_16 == . & marstat_16 == 4
replace married_16 = 0 if married_16 == . & marstat_16 == 1

*********************
***** Education *****
*********************

gen edu_10 = edu_i10

gen edu_11 = edu_10 if leftschoollevel_i12 == edu_i10 & leftschoollevel_i12 != .
replace edu_11 = leftschoollevel_i12 if leftschoolend_i12 <= 2011 & leftschoolend_i12 != . & leftdegree_i12 == 1
replace edu_11 = leftschoollevel_i12 - 1 if leftschoolend_i12 <= 2011 & leftschoolend_i12 != . & leftdegree_i12 != 1 & leftschoollevel_i12 != 6
replace edu_11 = leftschoollevel_i12 - 2 if leftschoolend_i12 <= 2011 & leftschoolend_i12 != . & leftdegree_i12 != 1 & leftschoollevel_i12 == 6
replace edu_11 = inschoollevel_i12 - 1 if inschoollevel_i12 != . & inschoolstart_i12 <= 2011 & inschoolstart_i12 != . & inschoollevel_i12 != 6
replace edu_11 = inschoollevel_i12 - 2 if inschoollevel_i12 != . & inschoolstart_i12 <= 2011 & inschoolstart_i12 != . & inschoollevel_i12 == 6
