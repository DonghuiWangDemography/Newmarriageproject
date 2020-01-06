*task: impute 2012 occupation category 
*code from Bing Tian 
*created on April 30th 
global date "03172019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 

use $w12a, clear

* current work status (copied from clean02_v2.do)
g 		inschool=wc01
replace inschool=wc01ckp2 if wc01ckp2>0 & wc01ckp2<.

g        inwork =1 if qg101==1 
replace  inwork =1 if qg102==1 & inwork==.
replace  inwork =1 if qg103==1 & qg105==1 & inwork==.   // on vacation or sick leave, treated as in work 
replace  inwork =1 if qg108==1 & inwork==.      // business off season 
replace  inwork =1 if qg109==1 & inwork==. 
replace  inwork =0 if qg101==5 
replace  inwork =0 if  qg110>0 & qg110<77      // has valid reason not working 
replace  inwork =0 if inwork==. & inschool==1  // only 8 missing 


* Current Occupation Type (ISCO88) / 当前职业（ISCO88）
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

	tab occ if inwork==1 ,m
