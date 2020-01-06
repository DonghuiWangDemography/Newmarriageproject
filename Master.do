*master do file
 
 
clear all 
clear matrix 
set more off 
capture log close 

global date "01022019"   // mmddyy
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
global dir "E:\Marriage"  // usb 

*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  


* prelimiary data cleaning : compile all six waves 
do "${code}\clean02_v2"     // why file cannot find ? 
*output datafile: "${datadir}\marriage.dta" 

do "${code}\clean03_v2.do"
*output datafile:"${datadir}\panel_1016.dta"

do "${code}\clean04_senA.do"

*EHC 
* marriage 
do "$code\clean03_v2.do"
*output datafile:${datadir}\marr_EHC.dta" 




do "E:\Marriage\code\clean02_v2"
