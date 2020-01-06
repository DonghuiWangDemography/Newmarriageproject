

* get yearly data for marriage, education, and occupation

*cd "E:\Dropbox\0PPPP_Projects\NewMarriage\rawdata"
clear all 
clear matrix 
set more off 
capture log close 

global date "02072019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps  // load cfps 


***************
**** 2010 *****
***************
*use "cfps2010adult_report_nat092014.dta", clear
use $w10a, clear

* need interview year and month for reference
gen intyear_i10 = cyear
gen intmonth_i10 = cmonth

* year of marriage 2010
replace qe210y = . if qe210y < 0
gen mary10_cur_i10 = qe210y

replace qe405y = . if qe405y < 0
gen mary10_las_i10 = qe405y

replace qe501y = . if qe501y < 0
gen mary10_dec_i10 = qe501y

replace qe605y_best = . if qe605y_best < 0
gen mary10_fir_i10 = qe605y_best

* month of marriage 2010
replace qe210m = . if qe210m < 0
gen marm10_cur_i10 = qe210m

replace qe405m = . if qe405m < 0
gen marm10_las_i10 = qe405m

replace qe501m = . if qe501m < 0
gen marm10_dec_i10 = qe501m

replace qe605m = . if qe605m < 0
gen marm10_fir_i10 = qe605m

keep pid *_i10
sort pid
save "${datadir}\gen_i10_ehc.dta", replace


***************
**** 2012 *****
***************
*use "cfps2012adultcombined_092015compress.dta", clear
use $w12a, clear

* need interview year and month for reference
gen intyear_i12 = cyear
gen intmonth_i12 = cmonth

* correct year and month of marriage for 2010
replace qec105y = . if qec105y < 0
replace qec502y = . if qec502y < 0
replace qec602y = . if qec602y < 0
egen mary10_cur_i12 = rowmin(qec105y qec502y qec602y)

replace qec105m = . if qec105m < 0
replace qec502m = . if qec502m < 0
replace qec602m = . if qec602m < 0
gen marm10_cur_i12 = qec105m if mary10_cur_i12 == qec105y & qec105y != .
replace marm10_cur_i12 = qec502m if mary10_cur_i12 == qec502y & qec502y != .
replace marm10_cur_i12 = qec602m if mary10_cur_i12 == qec602y & qec602y != .

replace qec304y = . if qec304y < 0
replace qec404y = . if qec404y < 0
egen mary10_las_i12 = rowmin(qec304y qec404y)

replace qec304m = . if qec304m < 0
replace qec404m = . if qec404m < 0
gen marm10_las_i12 = qec304m if mary10_las_i12 == qec304y & qec304y != .
replace marm10_las_i12 = qec404m if mary10_las_i12 == qec404y & qec404y != .

replace qec702y = . if qec702y < 0
gen mary10_fir_i12 = qec702y

replace qec702m = . if qec702m < 0
gen marm10_fir_i12 = qec702m

* year and month of marriage in 2012

replace qe208y = . if qe208y < 0
replace qe413y = . if qe413y < 0
replace qe514y = . if qe514y < 0
replace qe604y = . if qe604y < 0
* if answered 208, no response for 413 and 514, some response for 604

egen mary12_i12 = rowmin(qe208y qe413y qe514y qe604y)
* some got married in 2010

replace qe208m = . if qe208m < 0
replace qe413m = . if qe413m < 0
replace qe514m = . if qe514m < 0
replace qe604m = . if qe604m < 0

gen marm12_i12 = qe208m if mary12_i12 == qe208y & qe208y != .
replace marm12_i12 = qe413m if mary12_i12 == qe413y & qe413y != .
replace marm12_i12 = qe514m if mary12_i12 == qe514y & qe514y != .
replace marm12_i12 = qe604m if mary12_i12 == qe604y & qe604y != .

keep pid *_i12
sort pid
*save "gen_i12_ehc.dta", replace
save "${datadir}\gen_i12_ehc.dta", replace

***************
**** 2014 *****
***************
*use "cfps2014adult_170630.dta", clear
use $w14a, clear 

* need interview year and month for reference
gen intyear_i14 = cyear
gen intmonth_i14 = cmonth

* correct year and month of marriage in 2012
replace qea205y = . if qea205y < 0
gen mary12_i14 = qea205y

replace qea205m = . if qea205m < 0
gen marm12_i14 = qea205m

* year of marriage in 2014
replace eeb201y = . if eeb201y < 0
replace eeb401y_a_1 = . if eeb401y_a_1 < 0
* eeb401y_a2 thru 5 are empty

egen mary14_i14 = rowmin(eeb201y eeb401y_a_1)

replace eeb201m = . if eeb201m < 0
replace eeb401m_a_1 = . if eeb401m_a_1 < 0

gen marm14_i14 = eeb201m if mary14_i14 == eeb201y & eeb201y != .
replace marm14_i14 = eeb401m_a_1 if mary14_i14 == eeb401y_a_1 & eeb401y_a_1 != .

keep pid *_i14
sort pid
save "${datadir}\gen_i14_ehc.dta", replace


***************
**** 2016 *****
***************
*use "cfps2016adult_201808.dta", clear
use $w16a, clear

* need interview year and month for reference
gen intyear_i16 = cyear
gen intmonth_i16 = cmonth

* correct year and month of marriage in 2014
replace qea205y = . if qea205y < 0
gen mary14_i16 = qea205y

replace qea205m = . if qea205m < 0
gen marm14_i16 = qea205m

* year and month of marriage in 2016

replace eeb201y = . if eeb201y < 0
replace eeb401y_a_1 = . if eeb401y_a_1 < 0
egen mary16_i16 = rowmin(eeb201y eeb401y_a_1)

replace eeb201m = . if eeb201m < 0
replace eeb401m_a_1 = . if eeb401m_a_1 < 0

gen marm16_i16 = eeb201m if mary16_i16 == eeb201y & eeb201y != .
replace marm16_i16 = eeb401m_a_1 if mary16_i16 == eeb401y_a_1 & eeb401y_a_1 != .

keep pid *_i16
sort pid
save "${datadir}\gen_i16_ehc.dta", replace

*******************
***** combine *****
*******************

*use "gen_all_recode.dta", clear
use "${datadir}\gen_all_recode.dta",clear

* respondents in 2010, N = 33,600
keep if tag_i10 == 1 

sort pid
merge pid using "${datadir}\gen_i10_ehc.dta"
drop _merge

sort pid
merge pid using "${datadir}\gen_i12_ehc.dta"
drop if _merge == 2
drop _merge

sort pid
merge pid using "${datadir}\gen_i14_ehc.dta"
drop if _merge == 2
drop _merge

sort pid
merge pid using "${datadir}\gen_i16_ehc.dta"
drop if _merge == 2
drop _merge

save "${datadir}\gen_all_recode_maryear.dta", replace

use "${datadir}\gen_all_recode_maryear.dta", clear

* N = 33,600

*******************
***** outcome *****
*******************

* correct year and month of marriage in 2010
gen mary10_cur = mary10_cur_i12 if mary10_cur_i12 != .
replace mary10_cur = mary10_cur_i10 if mary10_cur == . & mary10_cur_i10 != .

gen marm10_cur = marm10_cur_i12 if mary10_cur == mary10_cur_i12 & mary10_cur_i12 != .
replace marm10_cur = marm10_cur_i10 if mary10_cur == mary10_cur_i10 & mary10_cur_i10 != .
* 4 cases where 10 and 12 records same year and month

gen mary10_fir = mary10_fir_i12 if mary10_fir_i12 != .
replace mary10_fir = mary10_fir_i10 if mary10_fir == . & mary10_fir_i10 != .

gen marm10_fir = marm10_fir_i12 if mary10_fir == mary10_fir_i12 & mary10_fir_i12 != .
replace marm10_fir = marm10_fir_i10 if mary10_fir == mary10_fir_i10 & mary10_fir_i10 != .

gen mary10_las = mary10_las_i12 if mary10_las_i12 != .
replace mary10_las = mary10_las_i10 if mary10_las == . & mary10_las_i10 != .

gen marm10_las = marm10_las_i12 if mary10_las == mary10_las_i12 & mary10_las_i12 != .
replace marm10_las = marm10_las_i10 if mary10_las == mary10_las_i10 & mary10_las_i10 != .

egen mary10 = rowmin(mary10_cur mary10_fir mary10_las mary10_dec_i10) 

gen marm10 = marm10_cur if mary10 == mary10_cur & mary10_cur != .
replace marm10 = marm10_las if mary10 == mary10_las & mary10_las != .
replace marm10 = marm10_dec_i10 if mary10 == mary10_dec_i10 & mary10_dec_i10 != .
replace marm10 = marm10_fir if mary10 == mary10_fir & mary10_fir != .

* correct year and month of marriage in 2012
gen mary12 = mary12_i14 if mary12_i14 != .
replace mary12 = mary12_i12 if mary12 == . & mary12_i12 != .

gen marm12 = marm12_i12 if mary12 == mary12_i12 & mary12_i12 != .
replace marm12 = marm12_i14 if mary12 == mary12_i14 & mary12_i14 !=. 

* correct year and month of marriage in 2014
gen mary14 = mary14_i16 if mary14_i16 != .
replace mary14 = mary14_i14 if mary14 == . & mary14_i14 != .

gen marm14 = marm14_i14 if mary14 == mary14_i14 & mary14_i14 != .
replace marm14 = marm14_i16 if mary14 == mary14_i16 & mary14_i16 !=. 

egen maryear = rowmin(mary10 mary12 mary14 mary16_i16)

* if never married until 16 and maryear missing, replace with 9999
replace maryear = 9999 if marstat_10 == 1 & marstat_12 == 1 & marstat_14 == 1 & marstat_16 == 1 & maryear == .

* when month inconsistent, use earliest of the two
gen marmonth = 9999 if marstat_10 == 1 & marstat_12 == 1 & marstat_14 == 1 & marstat_16 == 1
replace marmonth = marm10 if maryear == mary10 & mary10 != .
replace marmonth = marm12 if maryear == mary12 & mary12 != .
replace marmonth = marm14 if maryear == mary14 & mary14 != .
replace marmonth = marm16 if maryear == mary16 & mary16 != .
replace marmonth = marm10 if maryear == mary10 & mary10 == mary12 & mary10 != . & marm10 < marm12 & marm10 != . & marm12 != .
replace marmonth = marm12 if maryear == mary10 & mary10 == mary12 & mary10 != . & marm10 > marm12 & marm10 != . & marm12 != .
replace marmonth = marm10 if maryear == mary10 & mary10 == mary14 & mary10 != . & marm10 < marm14 & marm10 != . & marm14 != .
replace marmonth = marm14 if maryear == mary10 & mary10 == mary14 & mary10 != . & marm10 > marm14 & marm10 != . & marm14 != .
replace marmonth = marm12 if maryear == mary12 & mary12 == mary14 & mary12 != . & marm12 < marm14 & marm12 != . & marm14 != .
replace marmonth = marm14 if maryear == mary12 & mary12 == mary14 & mary12 != . & marm12 > marm14 & marm12 != . & marm14 != .

*******************
****** 2010 *******
*******************

* do not care if married in 2009 or before, 


* marital status based on year and month of marriage
* some got married in the same month as the interview, count as married
gen married_a_10 = 0 if maryear >= 2012 & maryear != .
replace married_a_10 = 1 if maryear <= 2009 & maryear != .
replace married_a_10 = 0 if maryear == 2011 & intyear_i10 == 2010
replace married_a_10 = 1 if maryear == 2010 & intyear_i10 == 2011
replace married_a_10 = 0 if maryear == 2010 & intyear_i10 == 2010 & intmonth_i10 < marmonth & marmonth != .
replace married_a_10 = 0 if maryear == 2011 & intyear_i10 == 2011 & intmonth_i10 < marmonth & marmonth != .
replace married_a_10 = 1 if maryear == 2010 & intyear_i10 == 2010 & intmonth_i10 >= marmonth & marmonth != .
replace married_a_10 = 1 if maryear == 2011 & intyear_i10 == 2011 & intmonth_i10 >= marmonth & marmonth != .

* 3 cases married in 2010 unclear due to missing month of marriage, interviewed in april and may, married in later years, follow self-report status
gen married_10 = married_a_10
replace married_10 = 0 if marstat_10 == 1 & married_10 == .
replace married_10 = 0 if marstat_10 == 3 & married_10 == .
replace married_10 = 1 if marstat_10 != 1 & marstat_10 != 3 & marstat_10 != . & married_10 == .

*******************
****** 2012 *******
*******************

gen married_a_12 = 0 if maryear >= 2014 & maryear != .
replace married_a_12 = 1 if maryear <= 2011 & maryear != .
replace married_a_12 = 0 if maryear == 2013 & intyear_i12 == 2012
replace married_a_12 = 1 if maryear == 2012 & intyear_i12 == 2013
replace married_a_12 = 0 if maryear == 2012 & intyear_i12 == 2012 & intmonth_i12 < marmonth & marmonth != .
replace married_a_12 = 0 if maryear == 2013 & intyear_i12 == 2013 & intmonth_i12 < marmonth & marmonth != .
replace married_a_12 = 1 if maryear == 2012 & intyear_i12 == 2012 & intmonth_i12 >= marmonth & marmonth != .
replace married_a_12 = 1 if maryear == 2013 & intyear_i12 == 2013 & intmonth_i12 >= marmonth & marmonth != .

gen married_12 = married_a_12
replace married_12 = 0 if marstat_12 == 1 & married_12 == .
replace married_12 = 0 if marstat_12 == 3 & married_12 == .
replace married_12 = 1 if marstat_12 != 1 & marstat_12 != 3 & marstat_12 != . & married_12 == .

*******************
****** 2014 *******
*******************

gen married_a_14 = 0 if maryear >= 2016 & maryear != .
replace married_a_14 = 1 if maryear <= 2013 & maryear != .
replace married_a_14 = 0 if maryear == 2015 & intyear_i14 == 2014
replace married_a_14 = 1 if maryear == 2014 & intyear_i14 == 2015
replace married_a_14 = 0 if maryear == 2014 & intyear_i14 == 2014 & intmonth_i14 < marmonth & marmonth != .
replace married_a_14 = 0 if maryear == 2015 & intyear_i14 == 2015 & intmonth_i14 < marmonth & marmonth != .
replace married_a_14 = 1 if maryear == 2014 & intyear_i14 == 2014 & intmonth_i14 >= marmonth & marmonth != .
replace married_a_14 = 1 if maryear == 2015 & intyear_i14 == 2015 & intmonth_i14 >= marmonth & marmonth != .

gen married_14 = married_a_14
replace married_14 = 0 if marstat_14 == 1 & married_14 == .
replace married_14 = 0 if marstat_14 == 3 & married_14 == .
replace married_14 = 1 if marstat_14 != 1 & marstat_14 != 3 & marstat_14 != . & married_14 == .
* 4 cases, married in 2012 but not in 2014 & 2010, missing year of marriage, 2 interviewed in 2012 and 2014

** check 2016 status **


*******************
****** 2016 *******
*******************

gen married_a_16 = 0 if maryear >= 2018 & maryear != .
replace married_a_16 = 1 if maryear <= 2015 & maryear != .
replace married_a_16 = 0 if maryear == 2017 & intyear_i16 == 2016
replace married_a_16 = 1 if maryear == 2016 & intyear_i16 == 2017
replace married_a_16 = 0 if maryear == 2016 & intyear_i16 == 2016 & intmonth_i16 < marmonth & marmonth != .
replace married_a_16 = 0 if maryear == 2017 & intyear_i16 == 2017 & intmonth_i16 < marmonth & marmonth != .
replace married_a_16 = 1 if maryear == 2016 & intyear_i16 == 2016 & intmonth_i16 >= marmonth & marmonth != .
replace married_a_16 = 1 if maryear == 2017 & intyear_i16 == 2017 & intmonth_i16 >= marmonth & marmonth != .

gen married_16 = married_a_16
replace married_16 = 0 if marstat_16 == 1 & married_16 == .
replace married_16 = 0 if marstat_16 == 3 & married_16 == .
replace married_16 = 1 if marstat_16 != 1 & marstat_16 != 3 & marstat_16 != . & married_16 == .
* 4 cases married in 2014 but not in 2016 & 2010, missing year of marriage
* in which 2 married in 2012, 2 unmarried in 2012

*******************
****** weird ******
*******************

* if married at t, code as married at t and onward
replace married_12 = 1 if married_10 == 1
replace married_14 = 1 if married_12 == 1
replace married_16 = 1 if married_14 == 1

* if unmarried at t, missing at t-1 or before, code as unmarried at t-1 or before
replace married_10 = 0 if married_10 == . & married_12 == 0
replace married_10 = 0 if married_10 == . & married_14 == 0
replace married_10 = 0 if married_10 == . & married_16 == 0
replace married_12 = 0 if married_12 == . & married_14 == 0
replace married_12 = 0 if married_12 == . & married_16 == 0
replace married_14 = 0 if married_14 == . & married_16 == 0

save "${datadir}\gen_all_recode_marstat.dta", replace

use "${datadir}\gen_all_recode_marstat.dta", clear
forval i=10(2)16 {
tab married_`i',m
}
******************
***** Sample *****
******************

* alive from 2010 to 2016, N = 32,387
drop if alive_p_h12 == 0 | alive_p_h14 == 0 | alive_p_h16 == 0

* at least one parent alive from 2010 to 2016, N = 14,429
* missing 5,235
gen alive_fm_all = 1 if alive_fm_10 == 1 & alive_fm_12 == 1 & alive_fm_14 == 1 & alive_fm_16 == 1
replace alive_fm_all = 0 if alive_fm_10 == 0 | alive_fm_12 == 0 | alive_fm_14 == 0 | alive_fm_16 == 0
keep if alive_fm_all == 1

* coreside with at least one parent in 2010, N = 5,864
* missing 981
keep if cores_fm_10 == 1

* unmarried when interviewed in 2010, N = 3,056
keep if married_10 == 0

save "gen_all_recode_sample.dta", replace


