clear all 
clear matrix 
set more off 
capture log close 

global date "03142019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 

use $w10a, clear
keep if pid_s>0 & pid_s<.
*physical attractiveness
clonevar attract_s=qz204
*height, weight
clonevar height_s=qp1 if qp1>0
clonevar weight_s=qp2 if qp2>0
rename bmivalue bmivalue_s
keep pid_s attract_s  height_s weight_s bmivalue_s 

rename pid_s pid
tempfile sp 
save `sp.dta', replace



use $w10a, clear
merge 1:1 pid using  "${datadir}\panel_1016.dta", keep(match) nogen 
merge 1:1 pid using `sp.dta', keep(match) nogen 
clonevar attract=qz204
clonevar height=qp1 if qp1>0
clonevar weight=qp2 if qp2>0

g height_d=height-height_s

histogram height_d if male==1
tab height_d if male==1

* by cohort
age height_d if male==1
 
reg height_s height eduy2010 if male==1
