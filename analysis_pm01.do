*created on 04282019
*task: created detailed person-month file for entry into marriage


clear all 
clear matrix 
set more off 
capture log close 


global date "04282019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 

cfps

*===============
*marriage detailed date
use "${datadir}\marr_EHC.dta", clear
merge 1:1 pid using "${datadir}\panel_1016.dta", nogen 

*==================
*sample restriction : same as analysis pw01
*1. alive in 10-16
g 	    alivep= alivep_16hh 
replace alivep=0 if alivep_12hh==0 & alivep==.
replace alivep=0 if alivep_14hh==0 & alivep==. 
drop if alivep==0    //==> 32387

*2.at least one parent alive
keep if alivefm10==1 & alivefm12==1 &  alivefm14==1 & alivefm16==1 

*3. live at parental home in 2010 (to ensure family wealth includes parental wealth)
keep if livepa10==1    //==>5721

*4.single in 2010 
keep if marstat10==0  
keep if age>=15 & age<=45  // N=1565
*==================




*calculate total month since married 
format mar_min %tm

g birth=ym(birthy_best,birthm_cross) if birthm_cross>0  // N=3 missing 
drop if birth==.
format birth %tm




*missing or single in 2016: censored 
g        censor=1 if marstat16==0 | marstat16==.
replace  censor=0 if marstat16==1

replace mar_min=. if censor==1
misschk mar_min if censor==0  // N=172 missing  

*missing in detailed marriage date but marital status in between waves known: assign a random marrying date 39+39+58=155
misschk mar_min if marstat12==1    				//39
misschk mar_min if marstat12==0 & marstat14==1   //58
misschk mar_min if marstat14==0 & marstat16==1   //56


*generate ui = floor((b–a+1)*runiform() + a)
replace mar_min=floor(interv_12a-interv_10a+1)*runiform()+interv_10a  if mar_min==. & marstat12==1
replace mar_min=floor(interv_14a-interv_12a+1)*runiform()+interv_12a  if mar_min==. & marstat12==0 & marstat14==1
replace mar_min=floor(interv_16a-interv_14a+1)*runiform()+interv_14a  if mar_min==. & marstat14==0 & marstat16==1 

*calculate age at marriage:
g mar_age_d=(mar_min-birth)/12
g mar_age_y=int((mar_min-birth)/12)
g mar_age_m=int((mar_min-birth)-mar_age_y*12)

stset mar_age_d, id(pid) failure(censor==0)









*==> still N=19 missing : leave as it is 
*misschk marstat12 marstat14 marstat16 if mar_min==. & censor==0
misschk mar_age if censor==0  

* calculate duration 

drop mardate
g mardate=dofm(mar_min) 
g int10d=dofm(interv_10a)
g int16d=dofm(interv_16a)

format mardate int10d int16d %d

*convert into number of month married since 2010

g       dur=(year(mardate)-year(int10d))*12+month(mardate)-month(int10d)  if censor==0   // if married by 16(censor==0), 
replace dur=(year(int16d)-year(int10d))*12+month(int16d)-month(int10d)    if censor==1 & dur==.

g dur_m=dur-int(dur/12)*12 
g dur_y=int(dur/12)
g dur_ym=ym(dur_y,dur_m)

g dur_age=age+dur_y
g dur_age15=dur_age-15
*g dur_agem=birthm_cross+dur_m


// tab dur
// stset dur_age15, id(pid) failure(censor==0)
// sts graph , by(educ_fm)  xtitle("Age")

save "${datadir}\marr_EHC_pm.dta",replace 


use  "${datadir}\marr_EHC_pm.dta", clear
*convert into person-month 
expand dur 
bysort pid: g spell=_n
by pid :gen pycount=_N     
tab pycount 
tab pycount if spell==1 ,m  //N=76,254


*=======work on predictors, copy most from analysis pw01

*own attributes 
g han=(ethnicity_cross==1)	   

g 		urbanhukou3=1 if hukou3_10a==3
replace urbanhukou3=0 if hukou3_10a==1 |hukou3_10a==5  

g urbanhukou10=(hukou10_10a==3 )
clonevar urban=urban10



*family wealth:2010 only 
g 		ltasset=log(total_asset_10hh2+1) if total_asset_10hh2>0
replace ltasset=0 if total_asset_10hh2==0

egen passet =rowtotal(houseasset10 companyasset10 financeasset_gross land_asset_10hh2 valuable_10hh2 otherasset_10hh2)
egen nasset= rowtotal(house_debts10 nonhousing_debts)
g lasset_p=log(passet+1)
g lasset_n=log(nasset+1)


// g dif=(houseasset10+companyasset10+financeasset_gross+land_asset_10hh2+valuable_10hh2+otherasset_10hh2)- ///
// 	(house_debts10+nonhousing_debts)-total_asset_10hh2

g ngtasset=(total_asset_10hh2<0)
*detailed measure of wealth and asset 

*detailed assets and debts
*资产：房产，土地，金融，公司
*houseasset10 companyasset10 financeasset_gross house_debts10 nonhousing_debts 
g 		lhouseasset=log(houseasset10+1)
replace lhouseasset=0 if houseasset10==0

g lcompanyasset=log(companyasset10+1)
replace lcompanyasset=0 if companyasset10==0

g 		lfinanceasset=log(financeasset_gross+1)
replace lfinanceasset=0 if financeasset_gross==0


g 		lhouse_debts=log(house_debts10+1)
replace lhouse_debts=0 if house_debts10==0

g lnonhousing_debts=log(nonhousing_debts+1)
replace lnonhousing_debts=0 if nonhousing_debts==0

g lland_asset =log(land_asset_10hh2+1)
replace lland_asset=0 if land_asset_10hh2==0


*parents characheristics 

*party-membership
g 		fparty=1 if fparty_10hh==1   // communist party 
replace fparty=0 if fparty_10hh==2 |  fparty_10hh==3 | fparty_10hh==4 

g 		mparty=1 if mparty_10hh==1  // communist party 
replace mparty=0 if mparty_10hh==2 | mparty_10hh==3 | mparty_10hh==4 
g partypa=(fparty==1 |mparty==1)


*==========work on IVs==========
*lag time-varying predictors by one-wave : education, work, income housing condition migrant familyincome

*homeownership 
rename own_p_*hh2 own_p*
rename own_f_*hh2 own_f*
rename own_m_*hh2 own_m*

*time-varying predictors 
*1. carry forward values 
*2. lag by 12 month 

local var "alivef alivem alivefm livepa eduy educ income fincome fincomeper house_owned house_sqr otherhh houseasset nonaghukou migrant  familysize farmhh nonagbushh"
local it10=interv_10a
local it12=interv_12a
local it14=interv_14a
local it16=interv_16a

foreach x of local var {

*for 10-12 interval, use measurement at 10
forval i=`it10'/`it12' {
g L`x'_`i'=`x'10
}

*12-14 interval, use measurement at 12
forval i=`it12'/`it14' {
g L`x'_`i'=`x'12
}
*14-16 inteval, use measurment at 14
forval i=`it14'/`it16' {
g L`x'_`i'=`x'14
}
}
 
 
 
local var "alivef alivem alivefm livepa eduy educ  income fincome fincomeper house_owned house_sqr otherhh houseasset nonaghukou migrant  familysize farmhh nonagbushh"
foreach x of local var {
g        L`x'= `x'10  if spell==1  		// 10 -12 wave , uses wave10 predictor 
replace  L`x'= `x'12  if spell==2      // 12-14 wave, wave12 predictor
replace  L`x'= `x'10  if spell==2 & `x'12==.  // if missing, use wave 10 predictor
 
replace  L`x'= `x'14  if spell==3     
replace  L`x'= `x'12  if spell==3 & `x'14==.
replace  L`x'= `x'10  if spell==3 & `x'14==. & `x'12==.
}







// forval i=2010/2015 {
// local j=`i'+1
// g newlyweds`j'=1 if married`i'==0 & married`j'==1
// } 
//
// *assign mid point if marriage year know but month unknown 
// replace mar_min=ym(2010,6) if newlyweds2011==1 & mardate==.
// replace mar_min=ym(2011,6) if newlyweds2012==1 & mardate==.
// replace mar_min=ym(2012,6) if newlyweds2013==1 & mardate==.
// replace mar_min=ym(2013,6) if newlyweds2014==1 & mardate==.
// replace mar_min=ym(2014,6) if newlyweds2015==1 & mardate==.
// replace mar_min=ym(2015,6) if newlyweds2016==1 & mardate==.
//
// gen 	censor=1 if mar_min==ym(2018,1)
// replace censor=1 if mar_min==.
// replace censor=0 if mar_min<=ym(2018,1)
//
// g mar_age=(mar_min-birth)/12 if censor==0
//
// stset mar_age, failure(censor==0) id(pid) 
//
// recode edu_fm (0=1) (6=2) (9=3) (12=4) (15=5) (16=6) (19=7) (22=8),gen(eduy_fm_aux)
// recode eduy_fm_aux (1/2=1 "primary or less") (3=2 "middle school") (4/8=3 "high school and above"), gen(educ_fm)
// drop  eduy_fm_aux
//
// sts graph , by(male)  xtitle("Age")
// sts graph , by(educ_fm)  xtitle("Age")
//
//
// pctile p=total_asset_10hh2, nquantiles(5)
// egen pwealth=cut(total_asset_10hh2), group(5)
// sts graph , by(educ_fm)  xtitle("Age")
//
//
// *parent ses 
// g elite_f=(foccupcode<40000 )
// g elite_m=(moccupcode<40000 )
//
// egen gr=group(male elite_f),la
// la def gr 1"female, non-elite father" 2"female,elite father"  3"male,non-elite father" 4"male, elite father",modify
// la val gr gr
//
// g       dur=mar_min-interv_10a if mar_min<=interv_16a  // if marriage occur during the observation period
// replace dur=interv_16a-interv_10a if dur==. & mar_min>interv_16a  & mar_min !=.


*for ivs, lag 12 month and carry value foward 




*what about mar_min unkonwn ?



