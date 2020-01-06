*Project : transition into first marriage & co-residency   
*Date created: 01/11/2019
*Task: reconstruct monthly life histroy of marriage, work and education from 2010-2016 
*May not necessary . Discard

clear all 
clear matrix 
set more off 
capture log close 


global date "01/11/2019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps  // load cfps 



use $w10a, clear


*school status (copied from clean02_v2.do)
clonevar inschool=qd3 // N=5 NA

*work status (copied from clean02_v2.do)
g       inwork=1 if qg3==1 | qg4==1  // currently has a job or current engege ag job
replace inwork=0 if qg3==0 
replace inwork=0 if inwork==. & inschool==1  
replace inwork=0 if inwork==. & qj101>0 &qj101<. // has valid reason for not working  still N=158 mmissing 


// job categories  
g agjob2010= (qg303==5)  // mainly working on ag sector 
g wagejob2010= (qg303==3)

rename qg307code mc2010

keep pid  inwork inschool  agjob2010 wagejob2010 mc2010 cyear cmonth 

foreach x of varlist inwork inschool mc2010 {
rename `x' `x'_10a
}

g in_10a=1
save "${datadir}\2010_work_EHC.dta", replace 


*===========2012=============================

use $w12a,clear
* interview date and year: cmonth and cyear 
g cdate=ym(cyear, cmonth)
format %tm cdate


***************work ***************
* current work status (copied from clean02_v2.do)
g 		inschool=wc01
replace inschool=wc01ckp2 if wc01ckp2>0 & wc01ckp2<.

g        inwork =1 if qg101==1 
replace  inwork =1 if qg102==1 & inwork==.
replace  inwork =1 if qg103==1 & qg105==1 & inwork==.   // on vacation or sick leave, treated as in work 
replace  inwork =1 if qg108==1 & inwork==.     // business off season 
replace  inwork =1 if qg109==1 &  inwork==. 
replace  inwork =0 if qg101==5 
replace  inwork =0 if  qg110>0 & qg110<77  // has valid reason not working 
replace  inwork =0 if inwork==. & inschool==1  // only 8 missing 


* work history 
*naming covention for work 
*inwork (agjob,wagejob and selfemployment ) ; 

// interview month and year

// ag activity : ag work for own hh and ag work hired by others 
*G201 过去一年，您有没有为自家从事农业生产经营活动？
*G301 过去一年里，您有没有至少 10 天在为其他农户做农活/打散工挣钱？
g       agjob2011=1 if qg201==1
replace agjob2011= 1 if qg301==1

g       agjob2012=1 if qg201==1
replace agjob2012= 1 if qg301==1

//wage job
*convert year and month to internal stata format 


*set trace on
forval i=1/10 {

*for year known but month unkown, assign a random month
replace qg4121y_a_`i'=. if qg4121y_a_`i'<0
replace qg4121m_a_`i'=. if qg4121m_a_`i'<0 

replace qg4122y_a_`i'=. if qg4122y_a_`i'<0 
replace qg4122m_a_`i'=. if qg4122m_a_`i'<0 

replace qg4121m_a_`i' =floor(12*runiform() + 1) if (qg4121m_a_`i' <0 |qg4121m_a_`i'==.) & qg4121y_a_`i'>0 
replace qg4122m_a_`i' =floor(12*runiform() + 1) if (qg4122m_a_`i'<0  |qg4122m_a_`i'==.) & qg4122y_a_`i'>0

g st`i'=ym(qg4121y_a_`i', qg4121m_a_`i')
g fin`i'=ym(qg4122y_a_`i', qg4122m_a_`i')
format %tm st`i' fin`i'

tab  fin`i' if st`i'>0 & st`i'<. ,m

// a few has ending date unkown but starting date known.  what to do with it ? 
* !! Note: replace as current date for now. Not sure if it 
replace fin`i'=cdate if st`i'>0 & st`i'<. & fin`i'==.
}
*set trace off 


local t1=ym(2010,1)
local t2=cdate
forval k=`t1'/`t2'{
g wagejob`k'=.
replace wagejob`k'=0 if qg1011==5   //从 2010 年 1 月 1 日起到现在没有过任何工作

forval i=1/10 {
replace wagejob`k'=1 if  `k'>= st`i' & `k'<= fin`i' & fin`i'<. & wagejob`k'==.
}
replace wagejob`k'=0  if wagejob`k'==.   // not in work if missing 
}
drop st* fin* 

*2.selfemp,  非农自雇 

forval i=1/4 {

*for month don't know, assign a random month
replace qg5101m_a_`i'=. if qg5101m_a_`i'<0
replace qg5102m_a_`i'=. if qg5102m_a_`i'<0 

replace qg5101y_a_`i'=. if qg5101y_a_`i'<0
replace qg5102y_a_`i'=. if qg5102y_a_`i'<0 

replace qg5101m_a_`i' =floor(12*runiform() + 1) if (qg5101m_a_`i' <0 |qg5101m_a_`i'==.) & qg5101m_a_`i'>0 
replace qg5102m_a_`i' =floor(12*runiform() + 1) if (qg5102m_a_`i'<0  |qg5102m_a_`i'==.) & qg5102m_a_`i'>0

g st`i'=ym(qg5101y_a_`i', qg5101m_a_`i')
g fin`i'=ym(qg5102y_a_`i', qg5102m_a_`i')
format %tm st`i' fin`i'

tab  fin`i' if st`i'>0 & st`i'<. ,m

// a few missings on the ending date (given starting date is avaiable). what to do with it ? 
* !! Note: replace as current date for now. Not sure if it is correct 
replace fin`i'=cdate if st`i'>0 & st`i'<. & fin`i'==.
}

local t1=ym(2010,1)
local t2=cdate

forval k=`t1'/`t2' {
g selfemp`k'=.
replace selfemp`k'=0 if qg1011==5 

forval i=1/4 {
replace selfemp`k'=1 if `k'>=st`i' & `k'<= fin`i' & fin`i'<. & selfemp`k'==.
} 
replace selfemp`k'=0 if selfemp`k'==.

}

keep pid wagejob* selfemp* mar1st_y mar_ymin agjob* inwork cdate

// create composite measure of work status : treat as work as far as having either wage job or self employment 
forval i=600/635{
g nonagjob`i'=.
replace nonagjob`i'=(wagejob`i'==1 | selfemp`i'==1)
}

*reshape long wagejob selfemp, i(pid) j(monyear) 
*format monyear %tm


foreach x of varlist wagejob* selfemp*   inwork* {
rename `x' `x'_12a
}
g in_12a=1

save "${datadir}\2012_EHC.dta", replace 


*===========2014=============================
use $w14a, clear
// first marriage
local date "qea205y eeb201y eeb401y_a_1 eeb401y_a_2 eeb401y_a_3 eeb401y_a_4 eeb401y_a_5"
foreach x of local date {
tab `x',m nolab
replace `x'=. if `x'<0
}
egen mar_ymin=rowmin(`date')
*drop `date'
la var mar_ymin "earliest year of marriage identified"


// work  
** note : pay attention to the diffent coding scheme bewtween 自答/代答问卷。(表 6 2014 年成人自答和代答问卷不完全匹配问题信息列表 in 中国家庭追踪调查 2014年数据库介绍及数据清理报告)
** work histroy 1. main work  2. other work 

*main job
*previous main job 
replace egc104y=. if egc104y<0   // 请问您“【CAPI】加载MAINJOB_2012_update”这份工作持续到什么时候？ [why so many NAs?]
replace egc104y=2014 if egc104c==1 

forval k=2012/2014 {
g mainjob_pre`k'=.
replace mainjob_pre`k'=1 if `k'<= egc104y  & egc104y<.   // if 2012 job continue 
replace mainjob_pre`k'=0 if `k'>egc104y 
}

*new main job
replace egc1052y=2011 if egc1052y==-1900   // set 不确定年份（2012年以前） as starting from 2011
replace egc1052y=.  if egc1052y<0
replace egc1053y=.  if egc1053y<0
replace egc1053y=2014 if egc1053c==1
 
forval k=2012/2014 {
g mainjob`k'=.

replace mainjob`k'=0 if egc105==0 &  mainjob`k'==.  //set to zero if not working in 2012-2014 (only 948 has job? many NAs also have valid answer to egc1052y) 
replace mainjob`k'=1 if `k'>=egc1052y  & `k'<= egc1053y  & egc1053y<. & mainjob`k'==.
replace mainjob`k'=0 if `k'<egc1052y  & mainjob`k'==. 
replace mainjob`k'=0 if `k'>egc1053y  & egc1052y<. & mainjob`k'==.  //in between jobs 

// identify main job category 
}


*other job
rename egc2012y_a_* st*
rename egc2013y_a_* fin*

forval k=2012/2014 {
g otherjob`k'=.
replace otherjob`k'=0 if egc201==0  // no other jobs

forval i=1/5 {
replace st`i'=2011 if st`i'==-1900
replace fin`i'=2016 if egc2013c_a_`i'==1  
replace st`i'=. if st`i'<0
replace fin`i'=. if fin`i'<0

replace otherjob`k'=1 if `k'>= st`i' & `k'<= fin`i' & fin`i'<.  & otherjob`k'==.
}
replace otherjob`k'=0 if otherjob`k'==. //treat missing as having no other jobs : this might be problematic 
}

//create composite measure of jobs 
forval k=2012/2014{
g inwork`k'=.
replace inwork`k'=1 if mainjob_pre`k'==1 |  mainjob`k'==1 | otherjob`k'==1 
replace inwork`k'=0 if mainjob_pre`k'==0 & mainjob`k'==0 & otherjob`k'==0 & inwork`k'==.
}
keep pid mar_ymin mainjob* otherjob* inwork* employ2014

foreach x of varlist mar_ymin mainjob* otherjob* inwork* employ2014 {
rename `x' `x'_14a
}
g in_14a=1
save "${datadir}\2014_EHC.dta", replace 
 
 
use $w16a, clear
*first marriage 
foreach x of varlist qea205y eeb201y eeb401y_a_1 {
replace `x'=. if `x'<0 
}
egen mar_ymin=rowmin(qea205y eeb201y eeb401y_a_1)


*****jobs************

*previous main job 
replace egc104y=. if egc104y<0
replace egc104y=2016 if egc104c==1  

forval k=2014/2016 {
g mainjob_pre`k'=.
replace mainjob_pre`k'=1 if `k'<= egc104y  & egc104y<.   // if 2012 job continue 
replace mainjob_pre`k'=0 if `k'>egc104y 
}



*main job 
replace egc1052y=. if egc1052y<0
replace egc1053y=. if egc1053y<0
replace egc1053y=2016 if egc1053c==1

forval k=2014/2016 {
g mainjob`k'=.
replace mainjob`k'=0 if   egc105==0  // 请问从“CFPS2014_time调查/2014年1月1日” 至今您是否有过任何工作？
replace mainjob`k'=1 if  `k'>=egc1052y & `k'<= egc1053y  & egc1053y<. & mainjob`k'==.
replace mainjob`k'=0 if  `k'<egc1052y & egc1052y<.  & mainjob`k'==.
replace mainjob`k'=0 if  `k'>egc1053y & mainjob`k'==. 
}

list mainjob201*  egc1052y  egc1053y if egc1052y>0 in 1/100


*other jobs
rename egc2012y_a_* st*
rename egc2013y_a_* fin*

forval k=2014/2016 {

g otherjob`k'=.
replace otherjob`k'=0 if egc201==0  // no other jobs

forval i=1/10 {

replace fin`i'=2016 if egc2013c_a_`i'==1  
replace st`i'=. if st`i'<0
replace fin`i'=. if fin`i'<0

replace otherjob`k'=1 if  `k'>= st`i' & `k'<= fin`i' & fin`i'<.  & otherjob`k'==.
}
replace otherjob`k'=0 if  otherjob`k'==. 
}

*create cotamposite measure of jobs 
forval k=2014/2016{
g inwork`k'=.
replace inwork`k'=1 if mainjob_pre`k'==1 | mainjob`k'==1 | otherjob`k'==1
replace inwork`k'=0 if mainjob_pre`k'==0 & mainjob`k'==0 & otherjob`k'==0 & inwork`k'==.
}


keep pid mar_ymin mainjob* otherjob* inwork* employ
foreach x of varlist mar_ymin mainjob* otherjob* inwork* employ {
rename `x' `x'_16a
}

g in_16a=1
save "${datadir}\2016_EHC.dta", replace


use "${datadir}\2010_EHC.dta", clear
merge 1:1 pid using "${datadir}\2012_EHC.dta", nogen
merge 1:1 pid using "${datadir}\2014_EHC.dta", nogen
merge 1:1 pid using "${datadir}\2016_EHC.dta", nogen

// check in consistencies : why so many inconsistencies ?
*assert inwork2012_12a==inwork2012_14a
*assert inwork2014_14a==inwork2014_16a


tab inwork2012_12a inwork2014_14a if in_12a==1 &  in_14a==1
tab inwork2014_14a inwork2014_16a if in_14a==1 &  in_16a==1



* there is no other source to cross check work status of these four years
rename inwork2011_12a inwork2011 
rename inwork2013_14a inwork2013
rename inwork2015_16a inwork2015

g inwork2010=inwork_10a if in_10a==1  // trust current work status asked in 2010 
g inwork2012=inwork_12a if in_12a==1
g inwork2014= (employ2014_14a==1) if in_14a==1
g inwork2016=(employ_16a==1) if in_16a==1


misschk in_10a in_12a in_14a in_16a, gen(miss)
list  inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016 if missnumber==0 in 1/100  // so many missing

*list mainjob_pre2013_14a mainjob2013_14a otherjob2013_14a inwork2012 inwork2014 if inwork2013==.
list inwork2012 inwork2014 if inwork2013==. in 1/100


* marriage 
list mar_ymin_* mar1st* in 1/50
egen mar_ymin=rowmin(mar_ymin_* mar1st*)

forval k=2010/2016 {
g married`k'=.
replace married`k'=1 if `k'>=mar_ymin 
replace married`k'=0 if married`k'==. 

// check: marital status cannot reversable 
assert married`k'<= married`k'+1  // assert is correct 
}

* for those inconsisencies in 2012, 2014, cross-compare with the information 

list married*  mar_ymin_* mar1st*   in 1/100

save ""






* what additional information can we use 


erase "${datadir}\2010_EHC.dta"
erase "${datadir}\2012_EHC.dta"
erase "${datadir}\2014_EHC.dta"
erase "${datadir}\2016_EHC.dta"
