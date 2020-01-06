
* not runnable, for the purpose of comparison
* how main variabls are generated

* not reflected in the variable-generating codes, but possibly important
* for household roster files starting 2012,
* discard duplicated entries which are records of people who changed households, keep only those who are in the household
* for example, in 2012 roster
duplicates tag pid, gen(dup)
drop if dup != 0 & co_a12_p == 0

*DW: It looks like the way that duplicates are handled are the same. I remembered copied your codes.
*see clean0203combined_dw line 328-329 for year 12 ; line452-454 for year14 ; line 579-580 for year14

**********************
*** marital status ***
**********************

* self-report 2010
replace qe1_best = . if qe1_best < 0
rename qe1_best marstat_i10

* family-report 2010
replace tb3_a_p = . if tb3_a_p < 0
rename tb3_a_p marstat_h10

* retrospective self-report 2010 (collected in 2012)
replace cfps2010_marriage = . if cfps2010_marriage == 0
rename cfps2010_marriage marstat_10_i12

* self-report 2012
replace qe104 = . if qe104 < 0
rename qe104 marstat_i12

* family report 2012
replace tb3_a12_p = . if tb3_a12_p < 0
rename tb3_a12_p marstat_h12

* retrospective self-report 2012 (collected in 2014)
replace cfps2012_marriage_update = . if cfps2012_marriage_update == 0
rename cfps2012_marriage_update marstat_12_i14

* self-report 2014
replace qea0 = . if qea0 < 0
rename qea0 marstat_i14

* family-report 2014
replace tb3_a14_p = . if tb3_a14_p < 0
rename tb3_a14_p marstat_h14

* retrospective self-report 2014 (collected in 2016)
replace cfps2014_marriage_update = . if cfps2014_marriage_update == 0
rename cfps2014_marriage_update marstat_14_i16

* self-report 2016
replace qea0 = . if qea0 < 0
rename qea0 marstat_i16

* family-report 2016
replace tb3_a16_p = . if tb3_a16_p < 0
rename tb3_a16_p marstat_h16

* status: retrospective > self-report > family-report
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

* if unmarried at t, missing at t-1 or before, code as unmarried at t-1 or before
replace marstat_10 = 1 if marstat_10 == . & marstat_12 == 1
replace marstat_10 = 1 if marstat_10 == . & marstat_14 == 1
replace marstat_10 = 1 if marstat_10 == . & marstat_16 == 1
replace marstat_12 = 1 if marstat_12 == . & marstat_14 == 1
replace marstat_12 = 1 if marstat_12 == . & marstat_16 == 1
replace marstat_14 = 1 if marstat_14 == . & marstat_16 == 1

* interview year and month 2010
gen intyear_i10 = cyear
gen intmonth_i10 = cmonth

* self-report year and month of marriage 2010
replace qe210y = . if qe210y < 0
gen mary10_cur_i10 = qe210y

replace qe405y = . if qe405y < 0
gen mary10_las_i10 = qe405y

replace qe501y = . if qe501y < 0
gen mary10_dec_i10 = qe501y

replace qe605y_best = . if qe605y_best < 0
gen mary10_fir_i10 = qe605y_best

replace qe210m = . if qe210m < 0
gen marm10_cur_i10 = qe210m

replace qe405m = . if qe405m < 0
gen marm10_las_i10 = qe405m

replace qe501m = . if qe501m < 0
gen marm10_dec_i10 = qe501m

replace qe605m = . if qe605m < 0
gen marm10_fir_i10 = qe605m

* interview year and month 2012
gen intyear_i12 = cyear
gen intmonth_i12 = cmonth

* retrospective year and month of marriage 2010 (collected in 2012)
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

* self-report year and month of marriage in 2012

replace qe208y = . if qe208y < 0
replace qe413y = . if qe413y < 0
replace qe514y = . if qe514y < 0
replace qe604y = . if qe604y < 0

egen mary12_i12 = rowmin(qe208y qe413y qe514y qe604y)

replace qe208m = . if qe208m < 0
replace qe413m = . if qe413m < 0
replace qe514m = . if qe514m < 0
replace qe604m = . if qe604m < 0

gen marm12_i12 = qe208m if mary12_i12 == qe208y & qe208y != .
replace marm12_i12 = qe413m if mary12_i12 == qe413y & qe413y != .
replace marm12_i12 = qe514m if mary12_i12 == qe514y & qe514y != .
replace marm12_i12 = qe604m if mary12_i12 == qe604y & qe604y != .

* year and month of interview 2014
gen intyear_i14 = cyear
gen intmonth_i14 = cmonth

* retrospective year and month of marriage in 2012 (collected in 2014)
replace qea205y = . if qea205y < 0
gen mary12_i14 = qea205y

replace qea205m = . if qea205m < 0
gen marm12_i14 = qea205m

* self-report year and month of marriage in 2014
replace eeb201y = . if eeb201y < 0
replace eeb401y_a_1 = . if eeb401y_a_1 < 0

egen mary14_i14 = rowmin(eeb201y eeb401y_a_1)

replace eeb201m = . if eeb201m < 0
replace eeb401m_a_1 = . if eeb401m_a_1 < 0

gen marm14_i14 = eeb201m if mary14_i14 == eeb201y & eeb201y != .
replace marm14_i14 = eeb401m_a_1 if mary14_i14 == eeb401y_a_1 & eeb401y_a_1 != .

* year and month of interview 2016
gen intyear_i16 = cyear
gen intmonth_i16 = cmonth

* retrospective year and month of marriage in 2014 (collected in 2016)
replace qea205y = . if qea205y < 0
gen mary14_i16 = qea205y

replace qea205m = . if qea205m < 0
gen marm14_i16 = qea205m

* self-report year and month of marriage in 2016

replace eeb201y = . if eeb201y < 0
replace eeb401y_a_1 = . if eeb401y_a_1 < 0
egen mary16_i16 = rowmin(eeb201y eeb401y_a_1)

replace eeb201m = . if eeb201m < 0
replace eeb401m_a_1 = . if eeb401m_a_1 < 0

gen marm16_i16 = eeb201m if mary16_i16 == eeb201y & eeb201y != .
replace marm16_i16 = eeb401m_a_1 if mary16_i16 == eeb401y_a_1 & eeb401y_a_1 != .

* correct year and month of marriage in 2010
gen mary10_cur = mary10_cur_i12 if mary10_cur_i12 != .
replace mary10_cur = mary10_cur_i10 if mary10_cur == . & mary10_cur_i10 != .

gen marm10_cur = marm10_cur_i12 if mary10_cur == mary10_cur_i12 & mary10_cur_i12 != .
replace marm10_cur = marm10_cur_i10 if mary10_cur == mary10_cur_i10 & mary10_cur_i10 != .

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

* compile all years of marriage, choose earliest
egen maryear = rowmin(mary10 mary12 mary14 mary16_i16)

* if missing year of marriage and never married until 16, replace with 9999
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

* generate marital status (married_a) based on year and month of marriage
gen married_a_10 = 0 if maryear >= 2012 & maryear != .
replace married_a_10 = 1 if maryear <= 2009 & maryear != .
replace married_a_10 = 0 if maryear == 2011 & intyear_i10 == 2010
replace married_a_10 = 1 if maryear == 2010 & intyear_i10 == 2011
replace married_a_10 = 0 if maryear == 2010 & intyear_i10 == 2010 & intmonth_i10 < marmonth & marmonth != .
replace married_a_10 = 0 if maryear == 2011 & intyear_i10 == 2011 & intmonth_i10 < marmonth & marmonth != .
replace married_a_10 = 1 if maryear == 2010 & intyear_i10 == 2010 & intmonth_i10 >= marmonth & marmonth != .
replace married_a_10 = 1 if maryear == 2011 & intyear_i10 == 2011 & intmonth_i10 >= marmonth & marmonth != .

* if marital status based on year is missing, use marital status based on self-report and family-report
gen married_10 = married_a_10
replace married_10 = 0 if marstat_10 == 1 & married_10 == .
replace married_10 = 0 if marstat_10 == 3 & married_10 == .
replace married_10 = 1 if marstat_10 != 1 & marstat_10 != 3 & marstat_10 != . & married_10 == .

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

*******************
*** coresidence ***
*******************

* family-report coresidence 2010
gen 	cores_f_h10 = 1 if tb6_a_f == 1
replace cores_f_h10 = 0 if co_f == 0 | tb6_a_f == 0
replace cores_f_h10 = 0 if alive_f_h10 == 0

gen cores_m_h10 = 1 if tb6_a_m == 1
replace cores_m_h10 = 0 if co_m == 0 | tb6_a_m == 0
replace cores_m_h10 = 0 if alive_m_h10 == 0

gen inhh_h10 = 1 if tb6_a_p == 1
replace inhh_h10 = 0 if tb6_a_p == 0

gen inhh_s_h10 = 1 if tb6_a_s == 1
replace inhh_s_h10 = 0 if tb6_a_s == 0 | co_s == 0

rename co_f co_f_h10
rename co_m co_m_h10


*=========dw: family report of coresidence: 2010 househld========== 

* 2010 househld
* livep: ego live in the household, livef: father live in the hh, livem: mother live in the household 
local fm "p s f m"
foreach x of local fm {
*alive 
replace alive_a_`x' =.  if  alive_a_`x'<0
g       alive`x'_10hh=1 if  alive_a_`x'==1 
replace alive`x'_10hh=0 if  alive_a_`x'==0
replace alive`x'_10hh=1 if  alive_a_`x'==. & co_`x'==1          // these codes appear much later in cc's code
replace alive`x'_10hh=1 if  alive_a_`x'==. & tb6_a_`x'==1


*live in the household  
g        live`x'_10hh=1 if tb6_a_`x'==1 
replace  live`x'_10hh=0 if tb6_a_`x'==0 | co_`x'==0  |  co_`x'==-8   // Note: revised in 01072019 : co_`x'=-8 equivalent to code_a_`x'==-8 aka no within family code  
replace  live`x'_10hh=0 if alive`x'_10hh==0
replace  live`x'_10hh=0 if tb601_a_`x' >0 &  tb601_a_`x' <12  // has reasons to moveout
}

*=======================================================

* family-report coresidence 2012
gen     cores_f_h12 = 1 if tb6_a12_f == 1
replace cores_f_h12 = 0 if co_a12_f == 0 | tb6_a12_f == 0
replace cores_f_h12 = 0 if alive_f_h12 == 0

gen cores_m_h12 = 1 if tb6_a12_m == 1
replace cores_m_h12 = 0 if co_a12_m == 0 | tb6_a12_m == 0
replace cores_m_h12 = 0 if alive_m_h12 == 0

gen inhh_h12 = 1 if tb6_a12_p == 1
replace inhh_h12 = 0 if tb6_a12_p == 0 | co_a12_p == 0

gen inhh_s_h12 = 1 if tb6_a12_s == 1
replace inhh_s_h12 = 0 if tb6_a12_s == 0 | co_a12_s == 0

rename co_a12_f co_f_h12
rename co_a12_m co_m_h12


*=========dw: family report of coresidence: 2010 househld========== 

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

*==================================================================

* family-report coresidence 2014
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

rename co_a14_f co_f_h14
rename co_a14_m co_m_h14

* family-report coresidence 2016
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

rename co_a16_f co_f_h16
rename co_a16_m co_m_h16

* coresident with parents only if both Ego and parents are in the household
* noncoresident with parents if either Ego or parents in the household but not both
* cannot determine coresidence if both Ego and parents NOT in the household
gen cores_f_10 = 1 if cores_f_h10 == 1 & inhh_h10 == 1
replace cores_f_10 = 0 if cores_f_h10 == 0 & inhh_h10 == 1
replace cores_f_10 = 0 if cores_f_h10 == 1 & inhh_h10 == 0
replace cores_f_10 = 0 if alive_f_10 == 0
gen cores_m_10 = 1 if cores_m_h10 == 1 & inhh_h10 == 1
replace cores_m_10 = 0 if cores_m_h10 == 0 & inhh_h10 == 1
replace cores_m_10 = 0 if cores_m_h10 == 1 & inhh_h10 == 0
replace cores_m_10 = 0 if alive_m_10 == 0
gen cores_fm_10 = 1 if cores_f_10 == 1 | cores_m_10 == 1
replace cores_fm_10 = 0 if cores_f_10 == 0 & cores_m_10 == 0

gen cores_f_12 = 1 if cores_f_h12 == 1 & inhh_h12 == 1
replace cores_f_12 = 0 if cores_f_h12 == 0 & inhh_h12 == 1
replace cores_f_12 = 0 if cores_f_h12 == 1 & inhh_h12 == 0
replace cores_f_12 = 0 if alive_f_12 == 0
gen cores_m_12 = 1 if cores_m_h12 == 1 & inhh_h12 == 1
replace cores_m_12 = 0 if cores_m_h12 == 0 & inhh_h12 == 1
replace cores_m_12 = 0 if cores_m_h12 == 1 & inhh_h12 == 0
replace cores_m_12 = 0 if alive_m_12 == 0
gen cores_fm_12 = 1 if cores_f_12 == 1 | cores_m_12 == 1
replace cores_fm_12 = 0 if cores_f_12 == 0 & cores_m_12 == 0

gen cores_f_14 = 1 if cores_f_h14 == 1 & inhh_h14 == 1
replace cores_f_14 = 0 if cores_f_h14 == 0 & inhh_h14 == 1
replace cores_f_14 = 0 if cores_f_h14 == 1 & inhh_h14 == 0
replace cores_f_14 = 0 if alive_f_14 == 0
gen cores_m_14 = 1 if cores_m_h14 == 1 & inhh_h14 == 1
replace cores_m_14 = 0 if cores_m_h14 == 0 & inhh_h14 == 1
replace cores_m_14 = 0 if cores_m_h14 == 1 & inhh_h14 == 0
replace cores_m_14 = 0 if alive_m_14 == 0
gen cores_fm_14 = 1 if cores_f_14 == 1 | cores_m_14 == 1
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

*********************
*** parents alive ***
*********************

* self-report living with siblings 2010
gen alive_f_i10 = 1 if qb411_s_1 > 0 | qb411_s_2 > 0 | qb411_s_3 > 0 | qb411_s_4 > 0 | qb411_s_5 > 0 | qb411_s_6 > 0
gen alive_m_i10 = 1 if qb511_s_1 > 0 | qb511_s_2 > 0 | qb511_s_3 > 0 | qb511_s_4 > 0 | qb511_s_5 > 0 | qb511_s_6 > 0 | qb511_s_7 > 0 | qb511_s_8 > 0

* family report alive 2010
replace alive_a_f = . if alive_a_f < 0
rename alive_a_f alive_f_h10

replace alive_a_m = . if alive_a_m < 0
rename alive_a_m alive_m_h10

* family-report marital status 2010
gen marstat_f_h10 = tb3_a_f
gen marstat_m_h10 = tb3_a_m

* family-report alive 2012
replace alive_a_f = . if alive_a_f < 0
replace alive_a_f = 0 if alive_a_f == . & deathreason_f != "-1" & deathreason_f != "-8" & deathreason_f != ""
rename alive_a_f alive_f_h12

replace alive_a_m = . if alive_a_m < 0
replace alive_a_m = 0 if alive_a_m == . & deathreason_m != "-1" & deathreason_m != "-8" & deathreason_m != ""
rename alive_a_m alive_m_h12

* family-report marital status 2012
gen marstat_f_h12 = tb3_a12_f
gen marstat_m_h12 = tb3_a12_m

* family-report alive 2014
replace alive_a14_f = . if alive_a14_f < 0
rename alive_a14_f alive_f_h14

replace alive_a14_m = . if alive_a14_m < 0
rename alive_a14_m alive_m_h14

* family-report marital status 2014
gen marstat_f_h14 = tb3_a14_f
gen marstat_m_h14 = tb3_a14_m

* self-report alive 2016
gen alive_f_i16 = 1 if qf5_a_1 >=1 & qf5_a_1 <= 5
replace alive_f_i16 = 0 if qf5_a_1 == 7
replace alive_f_i16 = 1 if alive_f_i16 == . & cfps_father_alive == 1

gen alive_m_i16 = 1 if qf5_a_2 >=1 & qf5_a_2 <= 5
replace alive_m_i16 = 0 if qf5_a_2 == 7
replace alive_m_i16 = 1 if alive_m_i16 == . & cfps_mother_alive == 1

* family-report parent alive 2016
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

* family-report marital status
gen marstat_f_h16 = tb3_a16_f
gen marstat_m_h16 = tb3_a16_m

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

gen alive_fm_10 = 1 if alive_f_10 == 1 | alive_m_10 == 1
replace alive_fm_10 = 0 if alive_f_10 == 0 & alive_m_10 == 0
gen alive_fm_12 = 1 if alive_f_12 == 1 | alive_m_12 == 1
replace alive_fm_12 = 0 if alive_f_12 == 0 & alive_m_12 == 0
gen alive_fm_14 = 1 if alive_f_14 == 1 | alive_m_14 == 1
replace alive_fm_14 = 0 if alive_f_14 == 0 & alive_m_14 == 0
gen alive_fm_16 = 1 if alive_f_16 == 1 | alive_m_16 == 1
replace alive_fm_16 = 0 if alive_f_16 == 0 & alive_m_16 == 0

gen alive_fm_all = 1 if alive_fm_10 == 1 & alive_fm_12 == 1 & alive_fm_14 == 1 & alive_fm_16 == 1
replace alive_fm_all = 0 if alive_fm_10 == 0 | alive_fm_12 == 0 | alive_fm_14 == 0 | alive_fm_16 == 0
keep if alive_fm_all == 1
