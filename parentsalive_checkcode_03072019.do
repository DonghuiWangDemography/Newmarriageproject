*parents alive 


use $w10a, clear
* parent alive
gen alive_f_i10 = 1 if qb411_s_1 > 0 | qb411_s_2 > 0 | qb411_s_3 > 0 | qb411_s_4 > 0 | qb411_s_5 > 0 | qb411_s_6 > 0
gen alive_m_i10 = 1 if qb511_s_1 > 0 | qb511_s_2 > 0 | qb511_s_3 > 0 | qb511_s_4 > 0 | qb511_s_5 > 0 | qb511_s_6 > 0 | qb511_s_7 > 0 | qb511_s_8 > 0

keep pid alive_f_i10 alive_m_i10 
tempfile pa10a
save `pa10a.dta', replace 


*10hh
use $10hh,clear
* parent alive
replace alive_a_f = . if alive_a_f < 0
rename alive_a_f alive_f_h10

replace alive_a_m = . if alive_a_m < 0
rename alive_a_m alive_m_h10


keep pid alive_f_h10 alive_m_h10

tempfile pa10hh
save `pa10hh.dta', replace 

*====line 127 

*12a


*12 hh
use $w12hh, clear

* parent alive
replace alive_a_f = . if alive_a_f < 0
replace alive_a_f = 0 if alive_a_f == . & deathreason_f != "-1" & deathreason_f != "-8" & deathreason_f != ""
rename alive_a_f alive_f_h12

replace alive_a_m = . if alive_a_m < 0
replace alive_a_m = 0 if alive_a_m == . & deathreason_m != "-1" & deathreason_m != "-8" & deathreason_m != ""
rename alive_a_m alive_m_h12


duplicates tag pid, gen(dup)
drop if dup != 0 & co_a12_p == 0

tempfile pa12hh
save `pa12hh.dta', replace 



*14hh
use $w14hh, clear

* parent alive
replace alive_a14_f = . if alive_a14_f < 0
rename  alive_a14_f alive_f_h14

replace alive_a14_m = . if alive_a14_m < 0
rename alive_a14_m alive_m_h14
* original line 496-498 cc
* oringal line 415-416

duplicates tag pid, gen(dup)
drop if dup != 0 & co_a14_p == 0

keep pid alive_a14_f alive_a14_m 
tempfile pa14hh
save `pa14hh.dta', replace 

*16a
use $16a, clear 

* parent alive
gen     alive_f_i16 = 1 if qf5_a_1 >=1 & qf5_a_1 <= 5
replace alive_f_i16 = 0 if qf5_a_1 == 7
replace alive_f_i16 = 1 if alive_f_i16 == . & cfps_father_alive == 1

gen alive_m_i16 = 1 if qf5_a_2 >=1 & qf5_a_2 <= 5
replace alive_m_i16 = 0 if qf5_a_2 == 7
replace alive_m_i16 = 1 if alive_m_i16 == . & cfps_mother_alive == 1

*16hh
use $16hh, clear 

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
