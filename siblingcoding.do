// sibling coding 
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
tempfile sibnocores
save `sibnocores.dta', replace
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
*merge pid using "gen_i10_sib_noncores.dta"
merge 1:1 pid  using `sibnocores.dta' 
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

log close
log using "${logs}\siblings.smcl"

tab nsib_alive 
tab nbro_alive_10

log close
*sort pid

*save "gen_i10_sib.dta", replace


*DW's coding 

*number of live sibs/bros not living together
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
egen noldbro_alive=rowtotal(oldbro*_alive)
egen noldsis_alive=rowtotal(oldsis*_alive)
egen nyoungbro_alive=rowtotal(youngbro*_alive )
egen nyoungsis_alive=rowtotal(youngsis*_alive)

g nsib_alive=nsib_alive_cor +nsib_alive_nocore  //418 missing
g nbro_alive_nocor=noldbro_alive + nyoungbro_alive

keep pid nsib nsib_alive nbro_alive_nocor nsib_alive_cor nsib_alive_nocore
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
replace code_a_pbro = . if inlist(code_a_pbro, code_a_f, code_a_p)

// remove if no common parent
replace code_a_pbro=. if (code_a_f !=code_a_fbro) & (code_a_m !=code_a_mbro) 
collapse (count) nbro_alive_cor=code_a_pbro (firstnm)  tb2_a_p code_a_f code_a_m pid, by (fid code_a_p)

keep pid fid code_a_f code_a_m code_a_p  nbro_alive_cor
merge 1:1 pid using `sibnoncore.dta' , keep(match) nogen

g nbro_alive=nbro_alive_nocor + nbro_alive_cor
keep fid pid nsib_alive nbro_alive 


*------------calculate number of married bros living together-----------------------

use $w10hh,clear
keep pid fid tb2_a_p code_a_f code_a_m code_a_p tb3_a_p
replace code_a_f=. if code_a_f<0
replace code_a_m=. if code_a_m<0

* number of married bros living together 
//create a file of all married males 
preserve 
keep if tb2_a_p==1  & tb3_a_p==2
drop  tb2_a_p
rename code_a_* code_a_*bro
tempfile males 
save `males'
restore 

// match each person with all married males in the same household
joinby fid using `males', unmatched (master)

// remove self-matches and matches with father
replace code_a_pbro = . if inlist(code_a_pbro, code_a_f, code_a_p)

// remove if no common parent
replace code_a_pbro=. if (code_a_f !=code_a_fbro) & (code_a_m !=code_a_mbro) 

collapse (count) nmarbro10=code_a_pbro (firstnm)  tb2_a_p code_a_f code_a_m pid, by (fid code_a_p)

keep pid fid nmarbro10

save "${datadir}\marbro10.dta" ,replace 



use $w12hh,clear
keep pid fid12 fid10 tb2_a_p code_a_f code_a_m code_a_p tb3_a12_p
replace code_a_f=. if code_a_f<0
replace code_a_m=. if code_a_m<0

* number of married bros living together 
//create a file of all married males 
preserve 
keep if tb2_a_p==1  & tb3_a12_p==2
drop  tb2_a_p
rename code_a_* code_a_*bro
tempfile males 
save `males'
restore 

// match each person with all married males in the same household
joinby fid12 using `males', unmatched (master)

// remove self-matches and matches with father
replace code_a_pbro = . if inlist(code_a_pbro, code_a_f, code_a_p)

// remove if no common parent
replace code_a_pbro=. if (code_a_f !=code_a_fbro) & (code_a_m !=code_a_mbro) 

collapse (count) nmarbro12=code_a_pbro (firstnm)  tb2_a_p code_a_f code_a_m pid, by (fid12 code_a_p)

