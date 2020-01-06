*Project : transition into first marriage & co-residency   
*Date created: 01/11/2019
*Task: reconstruct detailed life histroy of work and education from 2010-2016 

clear all 
clear matrix 
set more off 
capture log close 

global date "01252019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

* load cfps data (cfps.ado)
sysdir
cfps 


*===========2010=============================
use $w10a, clear

*school status (copied from clean02_v2.do)
clonevar inschool=qd3 // N=5 NA

*work status (copied from clean02_v2.do)

g       inwork=1 if qg2==1 | qg4==1  // currently has a job or current engege ag job
replace inwork=0 if qg2==0 
replace inwork=0 if inwork==. & inschool==1  
replace inwork=0 if inwork==. & qj101>0 &qj101<. // has valid reason for not working  still N=158 mmissing 

// job categories  
g agjob2010= (qg303==5)  // mainly working on ag sector 
g wagejob2010= (qg303==3)

rename qg307code mc2010

keep pid  inwork inschool  agjob2010 wagejob2010 mc2010 cyear cmonth 

misschk mc2010
foreach x of varlist inwork inschool mc2010 {
rename `x' `x'_10a
}

g in_10a=1
save "${datadir}\2010_work_EHC.dta", replace 


*======2012=============================
use $w12a,clear

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

// *two new lines added on April 30th 
// replace job2012mn_occu=. if job2012mn_occu<0
// misschk job2012mn_occu if inwork==1  //22.1 missing


*!Note! work history is asked differently in 2012

*CFPS identification rule of mainjob in two yr interval (2010-2012) 
*（1）若受访者正在从事的受雇工作、非农自雇工作、家庭帮工的总数为 0 （JobBCN+JobC1CN+JobC2CN=0）， 则 job2012mn 为 最 近 结 束 一 份 工 作 的 工 作 单 位 名 称 （JobMRName）；
*（2) 若受访者正在从事的受雇工作、非农自雇工作、家庭帮工的总数为 1 （JobBCN+JobC1CN+JobC2CN=1），则 job2012mn 为当前正在从事的该项工作对应的工作单位名称 （JobBnameX 或 JobC1nameX 或 JobC2nameX）；
*（3）若受访者正在从事的受雇工作、非农自雇工作、 家庭帮工的工作总数为 2份及以上（JobBCN+JobC1CN+JobC2CN>=2），则直接提问受访者最主要的工 作单位，job2012mn 为该项工作的单位名称（qg702）。
*也就是说，2012 年调查时生成的“主要工作单 位名称”（job2012mn），是在受雇、非农自雇和不拿工资为家庭经营活动帮工 3 类非农工作中当前正 在从事或最近结束的一份工作，为字符型变量，其值为该项工作的单位名称。

* identification rules for 2010,2011 2012  
* njob2011==0 major occupation set as none 
* njob2011==1 occupation is THE occupation
* njob2011>1  occupation is the occupation that idetified by survey directly ?


* rename all jobs
* information needed for each job: start & end date, occupational category, work duration (year, hours)

* wage job: 1-10
rename qg4121y_a_* st*    
rename qg4122y_a_* fin*
rename qg411code_a_* oc*


* selfemp,  非农自雇 :11-14
forval i=1/4{
local j=`i'+10
rename qg5101y_a_`i' st`j'
rename qg5102y_a_`i' fin`j'
rename qg510code_a_`i' oc`j'
} 

*不拿工资为家庭经营活动帮工:15-22
forval i=1/8{
local j=`i'+14
rename qg6101y_a_`i' st`j'
rename qg6102y_a_`i' fin`j'
rename qg609code_a_`i' oc`j'
}


local yr=cyear
forval k=2010/`yr'{

forval i=1/22{
g job`k'_`i'=.
g jobclass`k'_`i'=.  // job class: 1 wage job, 2 non-ag selfemp 3. family helper 
g oc`k'_`i'=.

// question regarding whether having job or not are not trustworthy. Many still have valid job start & end date even if indicating not having job
// the reason for the inconsistencies could due to the fact that EHC 模块的问卷系统不能清除冗余值 (see 中国家庭追踪调查 2014 年数据库介绍及数据清理报告 pp 18)

*replace job`k'_`i'=0 if qg1011==5
*replace job`k'_`i'=0 if   1<=`i'<=10 & qg401==0 & job`k'_`i'==.    // no wage job
*replace job`k'_`i'=0 if  11<=`i'<=14 & qg502==0 & job`k'_`i'==.    // no self-employed 
*replace job`k'_`i'=0 if  15<=`i'<=22 & qg601==0 & job`k'_`i'==.    // family help

// replace starting date as prior to 2010 if finishing date knwon but starting date unknown
replace st`i'=2009  if fin`i' ~=. & st`i'==.
replace st`i'=2009  if fin`i' ~=. & st`i'== -1 

replace job`k'_`i'=1 if  `k'>= st`i' & `k'<= fin`i' & fin`i'<. & job`k'_`i'==.

// in-between jobs, not working
replace job`k'_`i'=0 if  `k'<st`i' & st`i'<. &  job`k'_`i'==.
replace job`k'_`i'=0 if `k'> fin`i' & job`k'_`i'==.

// occupation if work 
replace  oc`k'_`i'=oc`i' if  job`k'_`i'==1

// job class
replace jobclass`k'_`i'=1 if  1<=`i'<=10
replace jobclass`k'_`i'=2 if  11<=`i'<=14
replace jobclass`k'_`i'=3 if  15<=`i'<=22

// set occupation as missing if Na
replace oc`k'_`i'=. if oc`k'_`i'<0 
replace oc`k'_`i'=. if oc`k'_`i'==80000 | oc`k'_`i'==90000

}

g mc`k'=.
// working in year t as far as having one identified job
egen inwork`k'= anymatch(job`k'_*), values(1)
egen njob`k'=rowtotal(job`k'_*), missing


// identify main job's occupation
egen max_oc`k'=rowmax(oc`k'_*) 
replace mc`k'=0         if njob`k'==0 & mc`k'==.
replace mc`k'=max_oc`k' if njob`k'==1 & mc`k'==.

 // if have more than one job in 2012, the survey asked main occupation in 2012 direcetly. 
 // assume occupation in yr t equals 2012 main occupation  
replace mc`k'=job2012mn_occu if njob`k'>=1 & mc`k'==.


//identify main job class
// what if ego has multiple jobs? 
*multiple job holdings 

}



tab mc2010 if inwork2010==1, m  // seems fine 
tab mc2012 if inwork2012==1, m  // seems fine 
tab mc2011 if inwork2011==1, m
 
// ag activity : ag work for own hh and ag work hired by others 
*G201 过去一年，您有没有为自家从事农业生产经营活动？ : how to define "paster year" ? 
*G301 过去一年里，您有没有至少 10 天在为其他农户做农活/打散工挣钱？
// for those interviewed in 2013, cmonth=1,2 or 3
g       agjob2011=1 if qg201==1
replace agjob2011= 1 if qg301==1

g       agjob2012=1 if qg201==1
replace agjob2012=1 if qg301==1


// another version of inwork which include both ag work and non ag work
forval i=2011/2012 {
gen inwork`i'_v2=(inwork`i'==1| agjob`i'==1)
}

keep pid  inwork* njob201* mc201* cyear job2012mn_occu agjob201* 
foreach x of varlist   inwork* njob201* mc201* cyear{
rename `x' `x'_12a
}
g in_12a=1

save "${datadir}\2012_work_EHC.dta", replace 


*===========2014=============================
use $w14a, clear
** work histroy 1. main work  2. other work 
** note : may need to pay attention to the diffent coding scheme bewtween 自答/代答问卷。(表 6 2014 年成人自答和代答问卷不完全匹配问题信息列表 in 中国家庭追踪调查 2014年数据库介绍及数据清理报告)
g       inschool=1 if wc01==1  
replace inschool=0 if wc01==0
replace inschool=0 if employ2014==1 |employ2014==3 //N=1547 missing 
replace inschool=0 if cfps2014_age>= 45 & cfps2014_age<. // replace NA with 0

g		inwork=1 if employ2014==1
replace inwork=0 if employ2014==0 | employ2014==3

replace inwork=1 if inwork==. & pg02==1  // has job in past 12 month
replace inwork=0 if inwork==. & pg02==5  // N=3503 missing 
replace inwork=qga1 if inwork==. & qga1>0 & qga1<.   // work history from 2012- present: 0 change 


*two new lines add on 04302019
replace qg303code=. if qg303code<0
misschk qg303code if inwork==1  //only 0.4 missing


* main job
replace egc1052y=2011 if egc1052y==-1900   // set 不确定年份（2012年以前） as starting from 2011
replace egc1052y=(cyear-2012)*runiform()+2012 if egc1052y==-2020   // assign a random value for job start in between 2012 & t. 
replace egc1053y=cyear if egc1053c==1

replace egc1052y=. if egc1052y<0
replace egc1053y=. if egc1053y<0

*other jobs
rename egc2012y_a_* st*
rename egc2013y_a_* fin*

local yr=cyear
forval k=2012/`yr' {

// previous job
g mainjobpre`k'=.
replace mainjobpre`k'=1 if `k'<= egc104y  & egc104y<.   // if 2012 job continue 
replace mainjobpre`k'=0 if `k'>egc104y 


// main job 
g mainjob`k'=.

replace mainjob`k'=0 if egc105==0 &  mainjob`k'==.  //set to zero if not working in 2012-2014 (only 948 has job? many NAs also have valid answer to egc1052y) 
replace mainjob`k'=1 if `k'>=egc1052y & `k'<= egc1053y  & egc1053y<. & mainjob`k'==.
replace mainjob`k'=0 if `k'<egc1052y  & mainjob`k'==. 
replace mainjob`k'=0 if `k'>egc1053y  & egc1052y<. & mainjob`k'==.  //in between jobs 

forval i=1/5 {
g otherjob`k'_`i'=.
replace otherjob`k'_`i'=0 if egc201==0  // no other jobs

replace st`i'=2011 if st`i'==-1900
replace st`i'=(`yr'-2012)*runiform()+2012 if st`i'==-2020 
replace fin`i'=`yr' if egc2013c_a_`i'==1  
replace st`i'=. if st`i'<0
replace fin`i'=. if fin`i'<0

replace otherjob`k'_`i'=1 if  `k'>= st`i' & `k'<= fin`i' & fin`i'<.  & otherjob`k'_`i'==.
replace otherjob`k'_`i'=0 if `k'<st`i' & st`i' <. & otherjob`k'_`i'==.
replace otherjob`k'_`i'=0 if  `k'>fin`i' & otherjob`k'_`i'==.
}
egen otherjob`k'=anymatch(otherjob`k'_*), values(1)

egen notherjob`k'=rowtotal(otherjob`k'_*), missing
g njob`k' =notherjob`k'+1  

//create composite measure of jobs 
g inwork`k'=.
replace inwork`k'=( mainjobpre`k'==1 | mainjob`k'==1 | otherjob`k'==1)

g mc`k'=.
replace mc`k'=qg303code if mainjob`k'==1 

/*
 identify major occupations: occupation is only asked for main job category 
However it is possible that the person engage in other job  , not the main job in 2013
 specific occupational category of "other jobs" are not asked. only job class are asked 
#1 JOBCLASS _base=1（自家农业生产经营）if GC202=1 & GC2021=1。 
#2 JOBCLASS_base =2（私营企业/个体工商户/其它自雇）if GC202=1 & GC2021=5。 
#3 JOBCLASS_base =3 （农业打工）if GC202=5 & GC2021=1。 
#4 JOBCLASS _base =4（受雇）if GC202=5 & GC2021=5。
*/
}

tab mc2013 if mainjob2013==1,m
tab mc2013 if inwork2013==1,m    // N=1057 engage in "other job" in 2013 therefore unable to identify occupation 


keep pid  mainjob201* otherjob* njob201*  inwork* mc201* employ2014 cyear qg303code inschool inwork 

foreach x of varlist  mainjob* otherjob* inwork* njob201* employ2014 mc201* qg303code cyear{
rename `x' `x'_14a
}
g in_14a=1
save "${datadir}\2014_work_EHC.dta", replace 
 
 
use $w16a, clear

*sch, work
g inschool=(pc1==1) // treating NA as 0
g       inwork=1 if employ==1
replace inwork=0 if employ==0 | employ==3 |employ==-8 // treating NA as 0??
replace inwork=0 if inwork==. & inschool==1  //N=3456 missing


*main job 
replace egc1052y=. if egc1052y<0
replace egc1053y=. if egc1053y<0
replace egc1053y=2016 if egc1053c==1

*other jobs
rename egc2012y_a_* st*
rename egc2013y_a_* fin*

local yr=cyear
forval k=2014/`yr' {

g mainjobpre`k'=.
replace mainjobpre`k'=1 if `k'<= egc104y  & egc104y<.   // if 2012 job continue 
replace mainjobpre`k'=0 if `k'>egc104y 

g mainjob`k'=.
replace mainjob`k'=0 if   egc105==0  // 请问从“CFPS2014_time调查/2014年1月1日” 至今您是否有过任何工作？
replace mainjob`k'=1 if  `k'>=egc1052y & `k'<= egc1053y  & egc1053y<. & mainjob`k'==.
replace mainjob`k'=0 if  `k'<egc1052y & egc1052y<.  & mainjob`k'==.
replace mainjob`k'=0 if  `k'>egc1053y & mainjob`k'==. 

forval i=1/10 {

g otherjob`k'_`i'=.
replace otherjob`k'_`i'=0 if egc201==0  // no other jobs

replace st`i'=. if st`i'<0
replace fin`i'=cyear if egc2013c_a_`i'==1  

replace otherjob`k'_`i'=1 if  `k'>= st`i' & `k'<= fin`i' & fin`i'<.  & otherjob`k'_`i'==.
replace otherjob`k'_`i'=0 if `k'<st`i' & st`i' <. & otherjob`k'_`i'==.
replace otherjob`k'_`i'=0 if  `k'>fin`i' & otherjob`k'_`i'==.

}
egen otherjob`k'=anymatch(otherjob`k'_*), values(1)

egen notherjob`k'=rowtotal(otherjob`k'_*), missing
g njob`k' =notherjob`k'+1 

*create cotamposite measure of jobs 
g inwork`k'=.
replace inwork`k'= (mainjobpre`k'==1|mainjob`k'==1 | otherjob`k'==1)
*replace inwork`k'=0 if mainjob_pre`k'==0 & mainjob`k'==0 & otherjob`k'==0 & inwork`k'==.

g mc`k'=.
replace mc`k'=qg303code if mainjob`k'==1 
}

tab mc2015 if mainjob2015==1,m
tab mc2015 if otherjob2015==1, m

tab mc2016,m

keep pid  mainjob* njob201* otherjob* inwork* mainjob* employ mc201* qg303code inschool inwork
foreach x of varlist  mainjob* njob201*  otherjob* inwork* mc201* employ qg303code {
rename `x' `x'_16a
}
g in_16a=1
save "${datadir}\2016_work_EHC.dta", replace

* only keep those sampled in 2010 
use "${datadir}\2010_work_EHC.dta", clear
merge 1:1 pid using "${datadir}\2012_work_EHC.dta", keep (master match) nogen
merge 1:1 pid using "${datadir}\2014_work_EHC.dta", keep(master match) nogen
merge 1:1 pid using "${datadir}\2016_work_EHC.dta", keep(master match) nogen
merge 1:1 pid using $cross, keepusing(jobstatus_*) keep(match master) nogen  // only for the purpose of cross-check

tab inwork_10a if  job2012mn_occu==-8,m
tab inwork_12a if  qg303code_14a==-8,m 

gen neverwork=(inwork_10a==0 & inwork_12a==0 & inwork2014_14a==0 & inwork2016_16a==0)


* there are no other source to cross check work status of these three years, trust as it is
rename inwork2011_v2_12a inwork2011  // included ag activity
rename inwork2013_14a inwork2013
rename inwork2015_16a inwork2015

// trust the current work status asked in wave t 
*tab jobstatus_10 inwork_10a if in_10a==1,m

replace inwork_10a=0 if inwork_10a==. & jobstatus_10==2 |jobstatus_10==-8
g inwork2010=inwork_10a if in_10a==1   
*tab jobstatus_12 inwork_12a if in_12a==1,m //=> ignore job status coded in cross-wave data
*merge 1:1 pid using $w12a , keepusing(qg101 qg102 qg103 qg108 qg109) keep(match master)
g inwork2012=inwork_12a if in_12a==1

*tab employ2014_14a  jobstatus_14 if in_14a==1, m // looks consistent  
g inwork2014=inwork2014_14a if in_14a==1
*tab employ_16a  jobstatus_16 if in_16a==1, m  
g inwork2016=inwork2016_16a if in_16a==1


// identify occupation 
rename mc2010_10a mc2010
rename mc2011_12a mc2011
rename mc2013_14a mc2013
rename mc2015_16a mc2015
rename job2012mn_occu mc2012
rename qg303code_14 mc2014
rename qg303code_16a mc2016


// identify mainjob : maybe not necessary 
clonevar mainjob2010=inwork2010
clonevar mainjob2011=inwork2011
clonevar mainjob2012=inwork2012

clonevar mainjob2013=mainjob2013_14a
clonevar mainjob2014=mainjob2014_14a
clonevar mainjob2015=mainjob2015_16a
clonevar mainjob2016=mainjob2016_16a

misschk in_10a in_12a in_14a in_16a, gen(miss)
*encode misspattern, g(misspattern2)

*misschk mc2010 mc2011 mc2012 mc2013 mc2014 mc2015 mc2016 if missnumber==0
forval i=2010/2016 {
misschk mc`i' if inwork`i'==1
}

// 2013, 2015 has a lot of missings in occupation, bx some ppl work in "other job" category, which did not ask occupation
*misschk mc2013 if mainjob2013_14a==1
*misschk mc2015 if mainjob2015_16a==1


// njob : too many missings 
*misschk njob2010_12a njob2011_12a njob2012_12a njob2013_14a njob2014_16a njob2015_16a njob2016_16a  

keep pid  inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016 ///
	mc2010 mc2011 mc2012 mc2013 mc2014 mc2015 mc2016 ///
	mainjob2010 mainjob2011 mainjob2012 mainjob2013 mainjob2014 mainjob2015 mainjob2016



* fill up missings with the value before , but only in between valid observations 
misschk inwork2010 inwork2011 inwork2012 inwork2013 inwork2014 inwork2015 inwork2016


forval i=2010/2016{
replace mc`i'=. if mc`i'<=0
replace mc`i'=. if mc`i'==999999 
}

misschk mc2010 mc2011 mc2012 mc2013 mc2014 mc2015 mc2016, gen(mc)  
encode mcpattern, gen(mcp)

reshape long mc inwork  mainjob, i(pid) j(year)

g mc2=mc
bysort pid (year): gen first= sum(mc2<.)==1 & sum(mc2[_n-1]<.) ==0  // first valid mc
gsort pid -year
by pid: gen last=sum(mc2<.)==1 & sum(mc2[_n-1]<.)==0 // last valid mc 

bysort pid (year): gen spell=sum(first)-sum(last[_n-1])

bysort pid : replace mc2=mc2[_n-1] if mc2==. & spell==1  

list year mc mc2 first last spell  in 1/60, sepby(pid)

rename mc2 mcadj


keep pid year mc mcadj inwork  mainjob  


// looks fine, reshape back
reshape wide mc mcadj inwork  mainjob, i(pid) j(year)
misschk mcadj2010 mcadj2011 mcadj2012 mcadj2013 mcadj2014 mcadj2015 mcadj2016


save "${datadir}\work_EHC.dta", replace


erase "${datadir}\2010_work_EHC.dta"
erase "${datadir}\2012_work_EHC.dta"
erase "${datadir}\2014_work_EHC.dta"
erase "${datadir}\2016_work_EHC.dta"
*erase "${datadir}\work_EHC2.dta"
