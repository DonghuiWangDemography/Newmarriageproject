// a simpler version of w12 

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


use $w12a,clear
*!Note! work coding scheme is different in 2012

*CFPS identification rule of mainjob in two yr interval (2010-2012) 
*（1）若受访者正在从事的受雇工作、非农自雇工作、家庭帮工的总数为 0 （JobBCN+JobC1CN+JobC2CN=0）， 则 job2012mn 为 最 近 结 束 一 份 工 作 的 工 作 单 位 名 称 （JobMRName）；
*（2) 若受访者正在从事的受雇工作、非农自雇工作、家庭帮工的总数为 1 （JobBCN+JobC1CN+JobC2CN=1），则 job2012mn 为当前正在从事的该项工作对应的工作单位名称 （JobBnameX 或 JobC1nameX 或 JobC2nameX）；
*（3）若受访者正在从事的受雇工作、非农自雇工作、 家庭帮工的工作总数为 2份及以上（JobBCN+JobC1CN+JobC2CN>=2），则直接提问受访者最主要的工 作单位，job2012mn 为该项工作的单位名称（qg702）。
*也就是说，2012 年调查时生成的“主要工作单 位名称”（job2012mn），是在受雇、非农自雇和不拿工资为家庭经营活动帮工 3 类非农工作中当前正 在从事或最近结束的一份工作，为字符型变量，其值为该项工作的单位名称。

* identification rules for 2010,2011 2012  
* njob2011==0 major occupation set as none 
* njob2011==1 occupation is THE occupation
* njob2011>1  occupation is the occupation that spent the longest time ?


* rename all jobs
* information needed for each job: start & end date, occupational category, work duration (year, hours)

* wage job: 1-10
rename qg4121y_a_* st*    
rename qg4122y_a_* fin*
rename qg411code_a_* oc*

rename qg413_a_* day*
rename qg414_a_* hr*

* selfemp,  非农自雇 :11-14
forval i=1/4{
local j=`i'+10
rename qg5101y_a_`i' st`j'
rename qg5102y_a_`i' fin`j'
rename qg510code_a_`i' oc`j'

rename qg512_a_`i' day`j'
rename qg513_a_`i' hr`j'
} 

*不拿工资为家庭经营活动帮工:15-22
forval i=1/8{
local j=`i'+14
rename qg6101y_a_`i' st`j'
rename qg6102y_a_`i' fin`j'
rename qg609code_a_`i' oc`j'

g day`j'=.  //did not ask work hrs 
g hr`j'=.
}


local yr=cyear
forval k=2010/`yr'{

forval i=1/22{
g job`k'_`i'=.
g oc`k'_`i'=.
g day`k'_`i'=.  
g hr`k'_`i'=.

// question regarding whether having job or not are not trustworthy. Many still have valid job start & end date even if indicating not having job
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

// working hrs and days if work 
replace day`k'_`i'=day`i' if  job`k'_`i'==1
replace hr`k'_`i'=hr`i'   if job`k'_`i'==1

// set occupation as missing if Na
replace oc`k'_`i'=. if oc`k'_`i'<0 
replace oc`k'_`i'=. if oc`k'_`i'==80000 | oc`k'_`i'==90000
}


g mc`k'=.
// working in year t as far as having one identified job
egen job`k'= anymatch(job`k'_*), values(1)
egen njob`k'=rowtotal(job`k'_*), missing
egen max_oc`k'=rowmax(oc`k'_*)


// identify main job's occupation 
replace mc`k'=0         if njob`k'==0 & mc`k'==.
replace mc`k'=max_oc`k' if njob`k'==1 & mc`k'==.

 // if have more than one job in 2012, the survey asked main occupation in 2012 direcetly. 
 // assume occupation in yr t equals 2012 main occupation  
replace mc`k'=job2012mn_occu if njob`k'>=1 & mc`k'==.
}



*tab njob2011
*tab job2011

*no need to reshape 
// for more than two occupations, identify number of unique occupations 
keep pid *job* st* fin* *oc* mc*
drop cfps*_latest_job* job*lastdate_a_* 

reshape long st fin day hr oc2010_ oc2011_ oc2012_ , i(pid) j(job)
forval i=2010/2012{
qui: unique(oc`i'_), by(pid) gen(uoc`i')  // identify unique occupations 
by pid: egen unioc`i'=max(uoc`i')
drop uoc`i' 
}

reshape wide st fin day hr oc2010_ oc2011_ oc2012_ , i(pid) j(job)

// njob >=2 
forval k=2010/2012{
* with more than one unique occupation : identify the one that spent the longest hour on
replace mc`k'=max_oc`k'      if njob`k'>=2 & unioc`k'==2 & mc`k'==.  

*replace mc`k'=job2012mn_occu if njob`k'>=2 & unioc`k'>=3 & mc`k'==.   

}

tab mc2010 if job2010==1 , m  // where does 1 even comefrom ?
tab mc2011 if job2011==1, m




// if all multiple work are wag job or self-emp, identify the ones with longest working hrs or highest earning


// identify occupation 



