*Project : transition into first marriage & co-residency   
*date : 11122018

// task: data cleaning : 2010 -2016 new marriages  Version 2: (marriage information from adult data)
*============================================
//ssc install blindschemes, replace all

//set scheme plotplainblind, permanently

clear all 
clear matrix 
set more off 
capture log close 

global date "11122018"   // ddmmyy
global dir "C:\Users\wdhec\Desktop\Marriage"
global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"
//global data "${dir}\CFPSrawdata_Chinese"

******CFPS data **********************************************************************
global datadir "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese"
global w10hh "${datadir}\2010\cfps2010famconf_report_nat092014.dta"
global w10hh2 "${datadir}\2010\cfps2010family_report_nat092014.dta"
global w10a "${datadir}\2010\cfps2010adult_report_nat092014.dta"
global w10c "${datadir}\2010\cfps2010child_report_nat092014.dta"

global w12hh "${datadir}\2012\cfps2012famros_092015compress.dta"
global w12a "${datadir}\2012\cfps2012adultcombined_092015compress.dta"
global w12c "${datadir}\2012\cfps2012childcombined_032015compress.dta"
global w12cross "${datadir}\2012\crossyearid_032015compress.dta"

global w14hh "${datadir}\2014\cfps2014famconf_170630.dta"
global w14a "${datadir}\2014\cfps2014adult_170630.dta"
global w14c "${datadir}\2014\Cfps2014child_170630.dta"

global w16hh "${datadir}\2016\cfps2016famconf_201804.dta"
global w16a "${datadir}\2016\cfps2016adult_201808.dta"
global w16c "${datadir}\2016\cfps2016child_201807.dta"
global cross "${datadir}\2016\Cfps2016crossyearid_201807.dta"

*============================================
use $w10a, clear
keep if qe1_best==1  // N=4419
keep  pid fid qe1_best
rename (fid qe1_best) (fid10 mar10) 
tempfile unmar10
save  `unmar10.dta', replace

use $w12a, clear
keep if cfps2010_marriage==1 // 
g mar12=(qe104==2)
rename cfps2010_marriage mar10

use $w14a, clear 

tab mar12,m

// which ma

/*
      mar12 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      3,232       88.14       88.14
          1 |        435       11.86      100.00
------------+-----------------------------------
      Total |      3,667      100.00
*/
