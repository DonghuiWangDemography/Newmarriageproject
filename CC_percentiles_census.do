
cd "C:\Users\cc16.opr-2jwv8v1\Dropbox\0Dissertation\2familypower\data\datafiles"

use "imputed_50.dta", clear
keep pid
sort pid
gen i = 1
sort i
save "pid.dta", replace

* reshape the census data to construct education percentile

import delimited using "census_female_5yr.csv", clear

expand 7
bysort age: gen i = _n
sort age
reshape wide noedu ele mid high ass col grad, i(i) j(age)

rename noedu* female_*_1
rename ele* female_*_2
rename mid* female_*_3
rename high* female_*_4
rename ass* female_*_5
rename col* female_*_6
rename grad* female_*_7

keep if i == 1
sort i
merge i using "pid.dta"
drop _merge
drop i
sort pid
save "census_female.dta", replace

import delimited using "census_male_5yr.csv", clear

expand 7
bysort age: gen i = _n
sort age
reshape wide noedu ele mid high ass col grad, i(i) j(age)

rename noedu* male_*_1
rename ele* male_*_2
rename mid* male_*_3
rename high* male_*_4
rename ass* male_*_5
rename col* male_*_6
rename grad* male_*_7

keep if i == 1
sort i
merge i using "pid.dta"
drop _merge
drop i
sort pid
save "census_male.dta", replace

use "imputed_50.dta", clear

sort pid
merge pid using "census_female.dta"
drop _merge

sort pid
merge pid using "census_male.dta"
drop _merge

gen eduy_s = eduy_r - eduy_rs
gen age_r = 2010 - bthy_r
gen age_s = 2010 - bthy_r + bthy_rs

drop if age_s < 20

mi passive: gen age_f_r = 2010 - bthy_r + bthy_rf_r
mi passive: replace age_f_r = 85 if age_f_r > 85
mi passive: gen age_f_s = 2010 - bthy_r + bthy_rf_s
mi passive: replace age_f_s = 85 if age_f_s > 85
mi passive: gen age_m_r = 2010 - bthy_r + bthy_rm_r
mi passive: replace age_m_r = 85 if age_m_r > 85
mi passive: gen age_m_s = 2010 - bthy_r + bthy_rm_s
mi passive: replace age_m_s = 85 if age_m_s > 85

gen eq_r = .
gen eq_s = .

forvalues i =1/12{
replace eq_r = female_`i'_1 if eduy_r == 0 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_2 if eduy_r == 6 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_3 if eduy_r == 9 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_4 if eduy_r == 12 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_5 if eduy_r == 15 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_6 if eduy_r == 16 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_7 if eduy_r == 19 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4
replace eq_r = female_`i'_7 if eduy_r == 22 & age_r >= 20+(`i'-1)*5 & age_r <= 20+(`i'-1)*5+4

replace eq_s = male_`i'_1 if eduy_s == 0 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_2 if eduy_s == 6 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_3 if eduy_s == 9 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_4 if eduy_s == 12 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_5 if eduy_s == 15 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_6 if eduy_s == 16 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_7 if eduy_s == 19 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
replace eq_s = male_`i'_7 if eduy_s == 22 & age_s >= 20+(`i'-1)*5 & age_s <= 20+(`i'-1)*5+4
}

mi passive: gen eq_f_r = .
mi passive: gen eq_m_r = .
mi passive: gen eq_f_s = .
mi passive: gen eq_m_s = .

forvalues i =1/14{
mi passive: replace eq_f_r = male_`i'_1 if eduy_f_r == 0 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_2 if eduy_f_r == 6 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_3 if eduy_f_r == 9 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_4 if eduy_f_r == 12 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_5 if eduy_f_r == 15 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_6 if eduy_f_r == 16 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_7 if eduy_f_r == 19 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4
mi passive: replace eq_f_r = male_`i'_7 if eduy_f_r == 22 & age_f_r >= 20+(`i'-1)*5 & age_f_r <= 20+(`i'-1)*5+4

mi passive: replace eq_f_s = male_`i'_1 if eduy_f_s == 0 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_2 if eduy_f_s == 6 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_3 if eduy_f_s == 9 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_4 if eduy_f_s == 12 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_5 if eduy_f_s == 15 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_6 if eduy_f_s == 16 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_7 if eduy_f_s == 19 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4
mi passive: replace eq_f_s = male_`i'_7 if eduy_f_s == 22 & age_f_s >= 20+(`i'-1)*5 & age_f_s <= 20+(`i'-1)*5+4

mi passive: replace eq_m_r = female_`i'_1 if eduy_m_r == 0 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_2 if eduy_m_r == 6 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_3 if eduy_m_r == 9 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_4 if eduy_m_r == 12 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_5 if eduy_m_r == 15 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_6 if eduy_m_r == 16 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_7 if eduy_m_r == 19 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4
mi passive: replace eq_m_r = female_`i'_7 if eduy_m_r == 22 & age_m_r >= 20+(`i'-1)*5 & age_m_r <= 20+(`i'-1)*5+4

mi passive: replace eq_m_s = female_`i'_1 if eduy_m_s == 0 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_2 if eduy_m_s == 6 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_3 if eduy_m_s == 9 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_4 if eduy_m_s == 12 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_5 if eduy_m_s == 15 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_6 if eduy_m_s == 16 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_7 if eduy_m_s == 19 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4
mi passive: replace eq_m_s = female_`i'_7 if eduy_m_s == 22 & age_m_s >= 20+(`i'-1)*5 & age_m_s <= 20+(`i'-1)*5+4

}

drop female* male*

save "imputed_50_census.dta", replace

nmissing eq_f_r eq_m_r eq_f_s eq_m_s

nmissing *_eq_f_r *_eq_m_r *_eq_f_s *_eq_m_s
