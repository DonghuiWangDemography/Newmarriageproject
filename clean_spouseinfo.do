*spouse information  : dob, education, how did couple meet 
*created on 03142019

clear all 
clear matrix 
set more off 
capture log close 

global date "03142019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 

*identify spouse's age and education at the time of the survey 
*correcting rule: 
*1.trust corrected spouse info at t+1 in adult survey
*2.spouse infor at time t in adult survey
*3.spouse info in household survey
 
*Collect info of married, divorced, & widowed sopuse at the time of the survey 
*age/birth date, educational level & (how did they meet) 


use $w10a,clear 
merge 1:1 pid using $w12a , keepusing(qec*) keep(master match) nogen 

*EC section in 2012 adult survey: [2010 年婚姻确认]
*EC1 当前配偶确认; EC2 同居伙伴确认; EC3 离婚配偶确认;EC4 去世配偶确认 ; EC5 上一任配偶（2010 的同伴或配偶）确认;
*EC6 过世配偶（2010 的同伴或配偶）确认; EC7 多次婚姻初婚配偶确认; EC8 成为配偶同居伙伴确认

*配偶的出生年月
*qec106 qec107y qec107m : current spouse       ==> correct E211y, E211m
*qec305 qec306y qec306m : divorced spouse      ==> correct E406y E406m    [EC305您上一任配偶的出生年月是“CFPS2010_E406y”，对吗？]
*qec405 qec406y qec406m : passwed-away soupse  ==> correct E406y E406y

*qec503 qec504y qec504m : previous spouse     ==> correct E211 /E302    [EC503 根据我们的记录，您上一任配偶的出生年月是“CFPS2010_E211y” 或“CFPS2010_E302y”，对吗？]
*EC603 qec604y qec604m : passed-away spouse   ==> correct E211y /E302 
*EC801 qec802y qec802m: current spouse 		  ==> correct E302          [EC801 根据我们的记录，您现在配偶的出生年月是“CFPS2010_E302y”， 对吗？]

*Additional Note: what is the difference btw [E1 初访婚姻状态确认] and [EC 2010年婚姻确认]??

local ym "y m"
foreach x of local ym {
replace qe211`x' = qec107`x' if qec106==5 & qec107`x'>0 & qec107`x' !=. 
replace qe406`x' = qec306`x' if qec305==5 & qec306`x'>0 & qec306`x' !=.
replace qe406`x' = qec406`x' if qec405==5 & qec406`x'>0 & qec406`x' !=.

*qec503 qec504y qec504m : previous spouse     ==> correct E211 /E302
replace qe211`x' = qec504`x' if qec503==5 & qec504`x'>0 & qec504`x' !=.
replace qe302`x' = qec504`x' if qec503==5 & qec504`x'>0 & qec504`x' !=.

*EC603 qec604y qec604m : passed-away spouse   ==> correct E211y /E302 
replace qe211`x' = qec604`x' if qec603==5 & qec604`x'>0 & qec604`x' !=.
replace qe302`x' = qec604`x' if qec603==5 & qec604`x'>0 & qec604`x' !=.

*EC801 qec802y qec802m: current spouse 		  ==> correct E302        
replace qe302`x' = qec802`x' if qec801==5 & qec802`x'>0 & qec802`x' !=.
}

*birth of the 2010 spouse:
g 		bys = qe211y if qe211y>0  				//在婚
g 		bms = qe211m if qe211m>0  

replace bys=qe406y if qe406y>0 & bys==.  		//离婚
replace bms= qe406m if qe406m>0 & bms==.

replace bys=qe502y if qe502y>0 & bys==.   		//丧偶
replace bms=qe502m  if qe502m>0 & bms==.

*tab bms if bys>0 &bys !=., m  // quite some missing in month :keep both yr and month for now 

*how did couple meet : for current 在婚, 离婚,丧偶couple 
clonevar meet=qe214 if qe214>0           		//在婚
replace  meet=qe409 if qe409>0 & meet==.        //离婚
replace  meet=qe506 if qe506>0 & meet==. 		//丧偶

*note: no infor on education is asked in 2010 adult survey 
keep pid bys bms meet 
rename (bys bms meet) (bys_10a bms_10a meet_10a)

tempfile w10
save `w10.dta', replace 



use $w12a, clear // N=35719
merge 1:1 pid using $w14a, keepusing(qea* cfps2012_marriage_update) keep(master match) nogen  
 
*[E section in 2012 adult suvey]
*E2 在婚
*E201 您目前的配偶是“您接受初访时的配偶吗？ 1.是（跳至婚姻确认模块，出现引语后，提问 EC101）;5.否（继续回答E202）
*E209A 您现在配偶已完成（毕业）的最高学历是什么？
*E209B 您现在配偶的具体职业是
*E209 您现在的配偶的出生年月
*E212 您与现在的配偶是如何认识的

*E4 离婚
*E414 您上一任配偶的出生年月是
*E417 您与上一任配偶是如何认识的

*E5 过世
*E515 您刚过世的配偶的出生年月是
*E518 您与刚过世的配偶是如何认识的？

*===================
*[EA section in 2014 adult survey: 2012 年婚姻状况]
*CFPS2012_marriage_update=2、3、4、5 分别在题干中加载当时的配偶/当时的同伴/离婚的那位配偶/过世的那位配偶），然后继续提问EA200

*EA1 : 调查时，您的婚姻状况是 "CFPS2012_marriage”，对吗
*EA2 : 调查时/2012 年 1 月 1 日时 的婚姻状况是？

* EA201 当时的配偶出生日期					==> correct E209 /E414/E515
* EA202 当时的配偶/同伴学历状况			    ==> correct E209A
* EA203 当时的配偶/同伴职业”                 ==> correct E209B
* EA204 与配偶/同伴如何认识				    ==> correct E212/E417/E518

*use EA section in 2014 suvey to correct age, education and how did the couple meet in E section in 2012 adult survey ]
local ym "y m"
foreach x of local ym {
replace qe209`x'=qea201`x' if qea1==0 & qea201`x'>0 & qea201`x' !=.
replace qe414`x'=qea201`x' if qea1==0 & qea201`x'>0 & qea201`x' !=.
replace qe515`x'=qea201`x' if qea1==0 & qea201`x'>0 & qea201`x' !=.
}

replace qe209a = qea202    if qea1==0 & qea202>0 & qea202 !=. 
replace qe209bcode_best =qea203code     if qea1==0 & qe209bcode_best>0 & qe209bcode_best !=. 
replace qe212 = qea204	   if qea1==0 & qea204>0 & qea204 !=. 
replace qe417 = qea204	   if qea1==0 & qe417>0 &  qe417 !=. 
replace qe518 = qea204	   if qea1==0 & qe518>0 &  qe518 !=. 

*birth date 
g bys=qe209y if qe209y>0 & qe209y !=.           //在婚
g bms=qe209m if qe209m>0 & qe209m !=.			

replace bys=qe414y if qe414y>0 & qe414y!=.		//离婚
replace bms=qe414m if qe414m>0 & qe414m!=.

replace bys=qe515y if qe515y>0 & qe515y!=.		//丧偶
replace bms=qe515m if qe515m>0 & qe515m!=.

*how did couple meet : for current 在婚, 离婚,丧偶couple 
clonevar meet= qe212 if qe212>0 & qe212 !=.
replace  meet= qe417 if qe417>0 & qe417 !=. & meet==.
replace  meet= qe518 if qe518>0 & qe518 !=. & meet==.
 
*educational level : only for 2012 married couple
clonevar educs=qe209a if qe209a>0 & qe209a !=.

keep pid bys bms meet educs 
rename (bys bms meet educs ) (bys_12a bms_12a meet_12a educs_12a)

tempfile w12
save `w12.dta', replace 


use $w14a, clear   //N=37147
merge 1:1 pid using $w16a, keep(master match) keepusing(qea*) nogen 

*[EB section in 2012 adult suvey: 2012-2013 婚姻]
*EB1 从“CFPS2012_time”调查时/2012 年 1 月 1 日至今， 您是否结过婚？ 1.是 5.否
*EB2 ”您与“CFPS2012_time” 调查时/2012 年 1 月 1 日时的同居伙伴是否结婚？

*EB402  对方的出生年月是
*EB4021 对方最高学历
*EB403  您与对方是如何认识的？
*EB406 您与对方的这段婚姻一直持续到什么时候:only  eeb406c_a_1 has valid value N-1207


*===================
*[EA in 2016 adult survey: 2014 年婚姻状况] : the same as EA section in 2014 

*EA1    “2014调查时婚姻状是“CFPS2014_marriage”，对吗？
*EEB4021”对方最高学历”对方已完成（毕业）的最高学历是什么？   N=235 incorrect 
*CFPS2014_marriage_update=2、3、4、5 且（CFPS2014_interv=0 或 5，或（CFPS2014_interv=1 且 EA1=5））
*分别在题干中加载当时的配偶/当时的同伴/离婚 的那位配偶/过世的那位配偶），然后继续提问EA200

*EA201: 出生年月								==> correct EB402
*EA202 “配偶/同伴学历状况”					==> correct EB4021
*EA204 “与配偶/同伴如何认识”					==> correct EB403

replace eeb402y_a_1=qea201y if qea1==0 & qea201y>0 & qea201y !=.
replace eeb402m_a_1=qea201m if qea1==0 & qea201m>0 & qea201m !=.

replace eeb4021_a_1=qea202 if qea1==0 &  qea202>0 & qea202 !=.
replace eeb403_a_1 =qea204 if qea1==0 &  qea204>0 & qea204 !=.


* birth, ed and how did couple meet for CURRENT spoulse
* birth date 
g bys=eeb402y_a_1 if eeb406c_a_1==1   // if marriage persists today 
g bms=eeb402m_a_1 if eeb406c_a_1==1 

*how did couple meet
g meet=eeb403_a_1 if eeb406c_a_1==1 

*spouse'education 
clonevar educs=eeb4021_a_1 if eeb406c_a_1==1 

keep pid bys bms meet educs 
rename (bys bms meet educs ) (bys_14a bms_14a meet_14a educs_14a)

tempfile w14
save `w14.dta', replace 



use $w16a, clear
*[EB section in 2016 adult suvey]
*EB1 从“CFPS2014_time”调查时/2014 年 1 月 1 日至今， 您是否结过婚？ 1.是 5.否
*EB2 ”您与“CFPS2014_time” 调查时/2014 年 1 月 1 日时的同居伙伴是否结婚？

*EB402  对方的出生年月是
*EB4021 对方最高学历
*EB403 您与对方是如何认识的？
*EB406 您与对方的这段婚姻一直持续到什么时候


* birth, ed and how did couple meet for CURRENT spoulse
* birth date 
g bys=eeb402y_a_1 if eeb402y_a_1>0 & eeb406_1_a_1==1   // if marriage persists today 
g bms=eeb402m_a_1 if eeb402m_a_1>0 & eeb406_1_a_1==1 

*how did couple meet
g meet=eeb403_a_1 if eeb403_a_1>0 & eeb406_1_a_1==1 

*spouse'education 
clonevar educs=eeb4021_a_1 if eeb4021_a_1>0 & eeb406_1_a_1==1 

keep pid bys bms meet educs 
rename (bys bms meet educs ) (bys_16a bms_16a meet_16a educs_16a)

tempfile w16
save `w16.dta', replace 


* merge with previous data 
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen 
merge 1:1 pid using `w10.dta', keep(master match) nogen 
merge 1:1 pid using `w12.dta', keep(master match) nogen
merge 1:1 pid using `w14.dta', keep(master match) nogen
merge 1:1 pid using `w16.dta', keep(master match) nogen


*trust adult interview, then impute missing with household interview 
clonevar educs_10a=sedu_10a if sedu_10a>0

forval i=10(2)16 {
*birth year
g 		bys_`i'=bys_`i'a  if bys_`i'a >0 
replace bys_`i'=bys_`i'hh if bys_`i'==.  & bys_`i'hh>0 
g 		bms_`i'=bms_`i'a  if bms_`i'a>0
replace bms_`i'=bms_`i'hh if bms_`i'==.  & bms_`i'hh>0
*age
g ages_`i'=20`i'-bys_`i' if bys_`i'>0

*education 
g 		educs_`i'=educs_`i'a  if educs_`i'a>0 
replace educs_`i'=educs_`i'hh if educs_`i'==. & educs_`i'hh>0

clonevar meet_`i'=meet_`i'a 
}


* newlyweds 
forval i=12(2)16 {
local j=`i'-2
g 		newlyweds`i'=(marstat`j'==0 & marstat`i'==1)
replace newlyweds`i'=. if marstat`i'==. | marstat`j'==.   // cannot decide if either missing 
}

forval i=12(2)16 {
*misschk bys_`i'   if newlyweds`i'==1 
misschk educs_`i' if newlyweds`i'==1
}


forval i=12(2)16 {
tab educs_`i' if newlyweds`i'==1,m
*tab bms_`i' if bys_`i' > 0 & bys_`i' !=. ,m    // quite some missing in birth month
*tab ages_`i' if newlyweds`i'==1,m   // min:16
}

*a couple of hundred missing on spouse's eudcatonal & birth year infor: leave for now 
#delimit ; 
keep pid bys_10 bys_12 bys_14 bys_16 
		 bms_10 bms_12 bms_14 bms_16 
		 ages_10 ages_12 ages_14 ages_16
		 educs_10 educs_12 educs_14 educs_16
		 meet_10 meet_12 meet_14 meet_16 
		 newlyweds* ;
		 
#delimit cr

save "${datadir}\spouseinfo.dta", replace 	

 