*addtional analysis of attrition
*created 02/13/2019

* the hypothesis is that females would be disproportionally more likely to leave parental home and get married, therefore marry within household would be severly undercount for women
 

clear all 
clear matrix 
set more off 
capture log close 

global date "01282019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

sysdir
cfps // load cfps data (cfps.ado)

use "${datadir}\panel_1016.dta" , clear // N=33600
merge 1:1 pid using "${datadir}\marr_EHC.dta" , nogen 
misschk in_12a in_14a in_16a, gen(ma)
encode mapattern, g(ma2)

*from adult survey 
g mad=1 if inlist(ma2, 1,5,7)
replace mad=0 if inlist(ma2,8)
replace mad=2 if inlist(ma2,2,3,4,6)

histogram  income_10a 

* who are more likely dropped  out from the adult survey ?
la def mp 0 "no missing" 1 "permanent attrition" 2 "interval missing"
la val mad mp

local dv "male age agesq i.cfps2010edu_best_cross livepa10 i.married2010 nonaghukou10 urban10 alive_a_f_10a alive_a_m_10a edu_fm inschool_10a  income_10a hukounow_10a hukou3_10a hukou12_10a parstay_child_10a house_owned10 fincome_10hh2"

mlogit mad `dv'

*leave as it is 
