
*=========cc: family report of coresidence: 2010 househld========== 

* parent alive
replace alive_a_f = . if alive_a_f < 0
rename alive_a_f alive_f_h10

replace alive_a_m = . if alive_a_m < 0
rename alive_a_m alive_m_h10

* parent cores
gen cores_f_h10 = 1 if tb6_a_f == 1
replace cores_f_h10 = 0 if co_f == 0 | tb6_a_f == 0
replace cores_f_h10 = 0 if alive_f_h10 == 0

gen cores_m_h10 = 1 if tb6_a_m == 1
replace cores_m_h10 = 0 if co_m == 0 | tb6_a_m == 0
replace cores_m_h10 = 0 if alive_m_h10 == 0

gen inhh_h10 = 1 if tb6_a_p == 1
replace inhh_h10 = 0 if tb6_a_p == 0

gen inhh_s_h10 = 1 if tb6_a_s == 1
replace inhh_s_h10 = 0 if tb6_a_s == 0 | co_s == 0

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
* CC comment: the last two lines are unncessary; they do no thing

*live in the household  
g        live`x'_10hh=1 if tb6_a_`x'==1 
replace  live`x'_10hh=0 if tb6_a_`x'==0 | co_`x'==0  |  co_`x'==-8   // Note: revised in 01072019 : co_`x'=-8 equivalent to code_a_`x'==-8 aka no within family code  
* CC comment: why treat - 8 as non-cores
replace  live`x'_10hh=0 if alive`x'_10hh==0
replace  live`x'_10hh=0 if tb601_a_`x' >0 &  tb601_a_`x' <12  // has reasons to moveout
}
* CC comment: the last line is unncessary; it does nothing

*=======================================================
