*task : re-define living in parental home ; check SES and ego's home leaving stataus 
*created on 02162019


clear all 
clear matrix 
set more off 
capture log close 

global date "02162019"   // mmddyy
*global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // psu
global dir "C:\Users\wdhec\Desktop\Marriage"     // home  
sysdir
cfps // load cfps data (cfps.ado)
	 
*=========2010, use previous cleaned data set========= 
*hm: living in familial home 

use "${datadir}\panel_1016.dta" , clear // N=33600

		local fm "p  f m"
		foreach x of local fm{
		g hm`x'2010=1 if tb6_a_`x'==1
		replace hm`x'2010=0 if tb6_a_`x'==0
		}
		foreach x of numlist 10 12 14 16{
		rename livepa`x' livepa20`x'
		} 


*=========2011,2012========= 
		drop dup
		merge 1:m pid using $w12hh, keep(match master) nogen 
		duplicates tag pid, gen(dup) 
		drop if dup !=0 &  co_a12_p==0  // N=33597
		
		local fm "p  f m"
		foreach x of local fm {
		g 		hm`x'2012=1 if tb6_a12_`x'==1
		replace hm`x'2012=0 if tb6_a12_`x'==0
		replace hm`x'2012=. if tb6_a12_`x'==-8

		g       hm`x'2011=0  if leavingtime_y_`x' <= 2011  & leavingtime_y_`x' >0   & hm`x'2012==0  // if already left home prior to or on 2011: do not live in familial home in 2011 
		replace hm`x'2011=1  if leavingtime_y_`x' >2011    & leavingtime_y_`x'<.    & hm`x'2012==0 & hm`x'2011==. // if left home on or after 2011: still live in familial home in 2011
		replace hm`x'2011=1  if hm`x'2012==1 & hm`x'2011==.  	// if live in familial home in 2012, treat as if never left home 
		replace hm`x'2011=1 if leavingtime_y_`x'==-1 & hm`x'2012==0  & hm`x'2011==.   // treat unkown (N=23) as left prior to 2010 
		}

		forval i=2010/2012{
		tab hmp`i' if hmp2010 ==1,m
		}

		* very few had moved out of original familial home from 2010-2011. 
		* a sudden increase of home-leaving in 2012 : why ? 

keep pid fid12 hm* live* mar10 mar12 mar14 mar16 ///
	in_10a in_12a in_14a in_16a in_10hh in_12hh in_14hh in_16hh
	


*========2013, 2014============
*merge 1:1 pid using $w14a, keep(match master) keepusing(cyear cmonth ear*) nogen 
merge 1:1 pid using $w14a, keep(match master) nogen 
merge 1:m pid using $w14hh, keep(match master) keepusing(tb6* co_a14_p) force nogen 
 
duplicates tag pid, gen(dup) 
drop if dup !=0 &  co_a14_p==0  // N=33596 drop duplicates of living with pa

*2014hm
local fm "p  f m"
foreach x of local fm {
g 		hm`x'2014=1 if tb6_a14_`x'==1
replace hm`x'2014=0 if tb6_a14_`x'==0
*replace hm`x'2014=. if tb6_a14_`x'==-8
}

*============2013hm============

*A: stay at familial home in 2012  &  2012 address is the same as 2014 
global a "hmp2012==1 & ear102==1 & hmp2013==."

*B: stay at familal home in 2012  & 2012 add is Not same as 2014 add
global b "hmp2012==1 & ear102 ==0 & hmp2013==. "

*C: Did not stay at familial home in 2012 & 2012 add is Not as 2014 add (or was not interviewed in 2012) 
global c  "hmp2012==0 & ear102 ==0 & hmp2013==. "

*D: Did not stay at familial  home in 2012  & 2012 add is the same as 2014 add
global d  "hmp2012==0 & ear102 ==1 & hmp2013==. "

*E: ear102 NA, but hmp2012 & hmp2014 known 
global e " !missing(hmp2012, hmp2014) & ear102==-8 & hmp2013==. "

*tab hmp2014 if $e  // N=1,448  live in familial home => refer to ehc on 2014 residency history   


g hmp2013=.
*a & never moved  
replace hmp2013=1 if ear103==0 & $a

*d & never moved 
replace hmp2013=0 if ear103==0 & $d


*check earliest move out & latest move in date for 2012 address : ear104 ear105

replace ear104y=cyear if ear104c==1  
replace ear104m=cmonth if ear104c==1   
replace ear105y=cyear if ear105c==1
replace ear105m=cmonth if ear105c==1

replace ear104m=3 if ear104m==13   // spring
replace ear104m=6 if ear104m==14   //summer
replace ear104m=9 if ear104m==15  // fall
replace ear104m=12 if ear104m==16  // for simplicity. only affect 8 individuals
replace ear104m=floor(12*runiform() + 1) if ear104m==-1 & ear104y>0 & ear104y !=. 

g er =ym(ear104y,ear104m) 

*latest move in date: a month later
replace ear105m=4 if ear105m==13   // spring
replace ear105m=7 if ear105m==14   //summer
replace ear105m=10 if ear105m==15  // fall
replace ear105m=1 if ear105m==16  // for simplicity. only affect 8 individuals
replace ear105m=floor(12*runiform() + 1) if ear105m==-1 & ear105y>0 & ear105y !=. 

g la=ym(ear105y,ear105m)

foreach x of varlist ear104y ear104m ear105y ear105m{
replace `x'=. if `x'<0
}
assert er<=la if er<.

g dur=la-er 

g hf13=ym(2013,6)  //half yr of 2013

* if A & the ealiest move out date is on or prior to June 2013: hmp2013==1  
replace hmp2013=1 if  er>=hf13 & er<. & $a

*if A & the latest move in date is on or prior to June 2013 
replace hmp2013=1 if la<=hf13  & $a

*Also applies to B
replace hmp2013=1 if  er>=hf13 & er<. & $b
replace hmp2013=1 if  la<=hf13 & $b

* duration less than 3 month, treat as continously live in the address 
replace hmp2013=1 if dur<3 & $a   //a:在家
replace hmp2013=0 if dur<3 & $d   //d:离家


*Note : what to do with -2020: date uncertain : treat as missing 


*Still missing: work on precise month for ehc of 2012 address

forval i=1/5{
*display "`i'"
*tab ear106_a_`i' if in_14a==1 ,m  
replace ear106_1fy_a_`i'=cyear  if ear106_1fc_a_`i'==1  // if continued to the current date
replace ear106_1fm_a_`i'=cmonth if ear106_1fc_a_`i'==1  // if continued to the current date
}

*convert seasons into month 
*a simpler way  
local s "ear106_1sm_a_"
local f "ear106_1fm_a_"
forval i=1/5{
g st`i'=.
g fin`i'=.
replace `s'`i'=3 if `s'`i'==13   // spring
replace `s'`i'=6 if `s'`i'==14   //summer
replace `s'`i'=9 if `s'`i'==16   // fall
replace `s'`i'=12 if `s'`i'==15  // winter
replace `s'`i'=. if `s'`i'<0

replace `f'`i'=4 if `f'`i'==13   // spring
replace `f'`i'=7 if `f'`i'==14   //summer
replace `f'`i'=10 if `f'`i'==16   // fall
replace `f'`i'=1 if `f'`i'==15  // winter
replace `f'`i'=. if `f'`i'<0

replace st`i'=ym(ear106_1sy_a_`i', ear106_1sm_a_`i')
replace fin`i'=ym(ear106_1fy_a_`i', ear106_1fm_a_`i')
}

forval i=1/5 {
assert st`i' <=fin`i' if st`i'<.
}

* 2013 detailed montly moving history of 2012 add 
local t1=ym(2013,1)
local t2=ym(2013,12) 

forval k= `t1'/`t2'{
forval i=1/5{
g hm13p`k'_`i'=.
replace hm13p`k'_`i'=1 if  st`i'<=`k'<=fin`i' 	& !missing(st`i',fin`i')
replace hm13p`k'_`i'=0 if `k'>fin`i' 			& !missing(st`i',fin`i')
replace hm13p`k'_`i'=0 if `k'<st`i' 			& !missing(st`i',fin`i')
}

*living in month t as long as one segments =1
egen hm13p`k'=anymatch(hm13p`k'_*), values(1)
drop hm13p`k'_*
}
egen hm13=rowtotal(hm13p*)

replace hmp2013=1 if hm13 >=3 & hm13!=. & $a
replace hmp2013=1 if hm13 >=3 & hm13!=. & $b

replace hmp2013=0 if hm13 <3 & hm13!=. & $a
replace hmp2013=0 if hm13 <3 & hm13!=. & $b



tab hmp2013 if in_14a==1,m  // N=4830 missing


*C & D: 2012 home is not familial home

* drop so that not to confuse with 2016 ehc
drop st* fin* 

*c & e 2014 home is familial home :aka moved back in 2014
*ear202y: the most recent date moved back 
replace ear202y=2011 if ear202y==-1900 // set precise date unkonwn but known prior to 2012 as 2011
replace ear202y=. if ear202y<0

replace ear202m=3 if ear202m==13   // spring
replace ear202m=6 if ear202m==14   //summer
replace ear202m=9 if ear202m==15  // fall
replace ear202m=12 if ear202m==16  // for simplicity. only affect 8 individuals
replace ear202m=floor(12*runiform() + 1) if ear202m==-9 & ear202y>0 & ear202y !=. 

g la2=ym(ear202y, ear202m)


replace  hmp2013=1 if la2 <=hf13 & $c & hmp2014==1    // if the most recent move in date is on or prior to June 2013 
replace  hmp2013=1 if la2 <=hf13 & $e & hmp2014==1  // also applies to e

*still missing : work on precise month 

local s "ear3_1sm_a_"
local f "ear3_1fm_a_"
local ys "ear3_1sy_a_"
local yf "ear3_1fy_a_"

forval i=1/5{
g st`i'=.
g fin`i'=.
 
*continue to the current date 
replace `yf'`i'=cyear if ear3_1fc_a_`i'==1
 
replace `s'`i'=3 if `s'`i'==13   // spring
replace `s'`i'=6 if `s'`i'==14   //summer
replace `s'`i'=9 if `s'`i'==16   // fall
replace `s'`i'=12 if `s'`i'==15  // winter
replace `s'`i'=. if `s'`i'<0

replace `f'`i'=4 if `f'`i'==13   // spring
replace `f'`i'=7 if `f'`i'==14   //summer
replace `f'`i'=10 if `f'`i'==16   // fall
replace `f'`i'=1 if `f'`i'==15  // winter
replace `f'`i'=. if `f'`i'<0

replace st`i'=ym(`ys'`i', `s'`i')
replace fin`i'=ym(`yf'`i', `f'`i')
}

* only 1-3 has valid values 
forval i=1/3 {
*tab st`i' 
*tab fin`i' 
assert st`i' <=fin`i' if st`i'<.
}


drop hm13p* hm13

local t1=ym(2013,1)
local t2=ym(2013,12) 

forval k= `t1'/`t2'{
forval i=1/3{
g hm13p`k'_`i'=.
replace hm13p`k'_`i'=1 if  st`i'<=`k'<=fin`i' 	& !missing(st`i',fin`i')
replace hm13p`k'_`i'=0 if `k'>fin`i' 			& !missing(st`i',fin`i')
replace hm13p`k'_`i'=0 if `k'<st`i' 			& !missing(st`i',fin`i')
}

*living in month t as long as one segments =1
egen hm13p`k'=anymatch(hm13p`k'_*), values(1)
drop hm13p`k'_*
}
egen hm13=rowtotal(hm13p*)

*hm2013==1 as long as one lives in the 2012 address for more than 3 month 

replace hmp2013=1 if hm13 >=3 & hm13!=. & $c & hmp2014 ==1
replace hmp2013=0 if hm13 <3 & hm13!=.  & $c & hmp2014 ==1

* also applies if ear102 ==NA & adjacent hmp no missing 
replace hmp2013=1 if hm13 >=3 & hm13!=. & $e & hmp2014 ==1
replace hmp2013=0 if hm13 <3 & hm13!=.  & $e & hmp2014 ==1


replace hmp2013=0 if $c & hmp2014 ==0
replace hmp2013=0 if $e & hmp2014 ==0 


*D:hmp2013=0 :assume hmp2013==0 if moved in between 2012-2014
replace hmp2013=0 if $d & ear103 ==1

* further check 
* how many live in hm2014, but not in 2013 
tab hmp2012  hmp2014 if in_14a==1 & hmp2013==. ,m



forval i=2012/2014 {
tab hmp`i' if in_14a==1,m
*tab hmp`i' if in_14hh==1,m
*tab  hmp`i',m
}

tab hmp2013 if in_14a==1,m   // around 10% misssing leave for now 
tab hmp2013 ,m   // around 10% misssing leave for now 


drop ear*  st* fin* er la* dur
	
	
*=======2015, 2016=======
merge 1:1 pid using $w16a, keep(match master) keepusing(cyear cmonth ear*) nogen force
merge 1:m pid using $w16hh, keep(match master) keepusing(tb6_a16_*) force nogen  // N=33596
drop dup // no duplicates

*2016hm
local fm "p  f m"
foreach x of local fm {
g 		hm`x'2016=1 if tb6_a16_`x'==1
replace hm`x'2016=0 if tb6_a16_`x'==0
replace hm`x'2016=. if tb6_a16_`x'==-8
}

*=========2015 hm===========
* repeat the same procedure 

*A: stay at familial home in 2014  & 2014 add is the same as 2016 add
global a "hmp2014==1 & ear102==1 & hmp2015==."
*B: stay at familal home in 2014  & 2014 add is Not same as 2016 add
global b "hmp2014==1 & ear102 ==0 & hmp2015==. "

*C: Did not stay at familial home in 2014 & 2014 add is Not as 2016 add
global c  "hmp2014==0 & ear102 ==0 & hmp2015==. "

*D: Did not stay at familial  home in 2014  & 2014 add is the same as 2016 add
global d  "hmp2014==0 & ear102 ==1 & hmp2015==. "

*E: ear102 NA, but hmp2014 & hmp2016 known 
global e " !missing(hmp2014, hmp2016) & ear102==-8 & hmp2015==. "

*tab hmp2016 if $e  // N= 79 live in familial home => refer to ehc on 2014 residency history   
*tab hmp2014 if $e  // N= 902  live in familial home => refer to ehc on 2014 residency history   


g hmp2015=.
*a & never moved  
replace hmp2015=1 if ear103==0 & $a

*d & never moved 
replace hmp2015=0 if ear103==0 & $d


*check earliest move out & latest move in date for 2012 address : ear104 ear105

foreach x of varlist ear104y ear104m ear105y ear105m{
replace `x'=. if `x'<0
}

replace ear104y=cyear if ear104c==1  
replace ear104m=cmonth if ear104c==1   
replace ear105y=cyear if ear105c==1
replace ear105m=cmonth if ear105c==1

replace ear104m=3 if ear104m==13   // spring
replace ear104m=6 if ear104m==14   //summer
replace ear104m=9 if ear104m==15  // fall
replace ear104m=12 if ear104m==16  // for simplicity. only affect 8 individuals
replace ear104m=floor(12*runiform() + 1) if ear104m==-1 & ear104y>0 & ear104y !=. 

g er =ym(ear104y,ear104m) 

*latest move in date: a month later
replace ear105m=4 if ear105m==13   // spring
replace ear105m=7 if ear105m==14   //summer
replace ear105m=10 if ear105m==15  // fall
replace ear105m=1 if ear105m==16  // for simplicity. only affect 8 individuals
replace ear105m=floor(12*runiform() + 1) if ear105m==-1 & ear105y>0 & ear105y !=. 

g la=ym(ear105y,ear105m)


*assert er<=la if er<.
*replace contradition as missing 
replace er=. if er>la & er<.
replace la=. if er>la & er<.

g dur=la-er 


g hf15=ym(2015,6)
* if A & the ealiest move out date is after 2015: hmp2015==1  
replace hmp2015=1 if  er>=hf15 & ear104y<. & $a

*if A & the latest move in date is on or prior to 2015
replace hmp2015=1 if la<=hf15 & ear105y>0 & $a

*Also applies to B
replace hmp2015=1 if  er>=hf15 & ear104y<. & $b
replace hmp2015=1 if  la<=hf15 & ear105y>0 & $b

*Note : what to do with -2020: date uncertain 

* duration less than 3 month, treat as continously live in the address 
replace hmp2015=1 if dur<3 & $a 
replace hmp2015=0 if dur<3 & $d



*Still missing: work on precise month for ehc of 2012 address

forval i=1/4{
*display "`i'"
*tab ear106_a_`i' if in_14a==1 ,m  
replace ear106_1fy_a_`i'=cyear  if ear106_1fc_a_`i'==1  // if continued to the current date
replace ear106_1fm_a_`i'=cmonth if ear106_1fc_a_`i'==1  // if continued to the current date
}

*convert seasons into month 
*a simpler way  
local s "ear106_1sm_a_"
local f "ear106_1fm_a_"
forval i=1/4{
g st`i'=.
g fin`i'=.
replace `s'`i'=3 if `s'`i'==13   // spring
replace `s'`i'=6 if `s'`i'==14   //summer
replace `s'`i'=9 if `s'`i'==16   // fall
replace `s'`i'=12 if `s'`i'==15  // winter
replace `s'`i'=. if `s'`i'<0

replace `f'`i'=4 if `f'`i'==13   // spring
replace `f'`i'=7 if `f'`i'==14   //summer
replace `f'`i'=10 if `f'`i'==16   // fall
replace `f'`i'=1 if `f'`i'==15  // winter
replace `f'`i'=. if `f'`i'<0

replace st`i'=ym(ear106_1sy_a_`i', ear106_1sm_a_`i')
replace fin`i'=ym(ear106_1fy_a_`i', ear106_1fm_a_`i')
}

forval i=1/4 {
assert st`i' <=fin`i' if st`i'<.
}


* 2015 detailed montly moving history of 2012 add 
local t1=ym(2015,1)
local t2=ym(2015,12) 

forval k= `t1'/`t2'{
forval i=1/4{
g hm15p`k'_`i'=.
replace hm15p`k'_`i'=1 if  st`i'<=`k'<=fin`i' 	& !missing(st`i',fin`i')
replace hm15p`k'_`i'=0 if `k'>fin`i' 			& !missing(st`i',fin`i')
replace hm15p`k'_`i'=0 if `k'<st`i' 			& !missing(st`i',fin`i')
}

*living in month t as long as one segments =1
egen hm15p`k'=anymatch(hm15p`k'_*), values(1)
drop hm15p`k'_*
}
egen hm15=rowtotal(hm15p*)

replace hmp2015=1 if hm15 >=3 & hm15!=. & $a
replace hmp2015=1 if hm15 >=3 & hm15!=. & $b

replace hmp2015=0 if hm15 <3 & hm15!=. & $a
replace hmp2015=0 if hm15 <3 & hm15!=. & $b


*less than 6 month, treat as not living in the address  : should impose this assumption or not ?

*replace hmp2015=0 if hm15<6 & hm15!=.  & hmp2012==1  & hmp2015==.


tab hmp2015 if in_16a==1,m  // N=3,922 missing 


*C & D: 2012 home is not familial home

* drop so that not to confuse with 2016 ehc
drop st* fin* 

*c &2016 home is familial home :aka moved back in 2016

replace ear202m=3 if ear202m==13   // spring
replace ear202m=6 if ear202m==14   //summer
replace ear202m=9 if ear202m==15  // fall
replace ear202m=12 if ear202m==16  // for simplicity. only affect 8 individuals
replace ear202m=floor(12*runiform() + 1) if ear202m==-9 & ear202y>0 & ear202y !=. 

g la2=ym(ear202y, ear202m)


replace  hmp2015=1 if la2 <=hf15 & $c & hmp2016==1    // if the most recent move in date is prior to 2015 
replace  hmp2015=1 if la2 <=hf15 & $e & hmp2016==1    // also applies to case when ear102 is NA 


*still missing : work on precise month 

local s "ear3_1sm_a_"
local f "ear3_1fm_a_"
local ys "ear3_1sy_a_"
local yf "ear3_1fy_a_"

forval i=1/8{
g st`i'=.
g fin`i'=.
 
*continue to the current date 
replace `yf'`i'=cyear if ear3_1fc_a_`i'==1
 
replace `s'`i'=3 if `s'`i'==13   // spring
replace `s'`i'=6 if `s'`i'==14   //summer
replace `s'`i'=9 if `s'`i'==16   // fall
replace `s'`i'=12 if `s'`i'==15  // winter
replace `s'`i'=. if `s'`i'<0

replace `f'`i'=4 if `f'`i'==13   // spring
replace `f'`i'=7 if `f'`i'==14   //summer
replace `f'`i'=10 if `f'`i'==16   // fall
replace `f'`i'=1 if `f'`i'==15  // winter
replace `f'`i'=. if `f'`i'<0

replace st`i'=ym(`ys'`i', `s'`i')
replace fin`i'=ym(`yf'`i', `f'`i')
}

forval i=1/8 {

* set contraditions as missing 
replace st`i'=. if st`i' > fin`i' &  st`i'<.
replace fin`i'=. if st`i' > fin`i' &  st`i'<.
assert st`i' <=fin`i' if st`i'<.
}


drop hm15p* hm15

local t1=ym(2015,1)
local t2=ym(2015,12) 

forval k= `t1'/`t2'{
forval i=1/3{
g hm15p`k'_`i'=.
replace hm15p`k'_`i'=1 if  st`i'<=`k'<=fin`i' 	& !missing(st`i',fin`i')
replace hm15p`k'_`i'=0 if `k'>fin`i' 			& !missing(st`i',fin`i')
replace hm15p`k'_`i'=0 if `k'<st`i' 			& !missing(st`i',fin`i')
}

*living in month t as long as one segments =1
egen hm15p`k'=anymatch(hm15p`k'_*), values(1)
drop hm15p`k'_*
}
egen hm15=rowtotal(hm15p*)

*hm2015==1 as long as one lives in the 2012 address for more than 6 month 

replace hmp2015=1 if hm15 >=3 & hm15!=. & $c & hmp2016 ==1
replace hmp2015=0 if hm15 <3 & hm15!=. & $c & hmp2016 ==1

* also applies to e (if ear102 ==NA)
replace hmp2015=1 if hm13 >=3 & hm15!=. & $e & hmp2016 ==1
replace hmp2015=0 if hm13 <3 & hm15!=. &  $e & hmp2016 ==1


replace hmp2015=0 if $c & hmp2016 ==0
replace hmp2015=0 if $e & hmp2014 ==0 


*D:hmp2015=0 :assume hmp2015==0 if moved in between 2012-2014
replace hmp2015=0 if $d & ear103 ==1



tab hmp2015 if in_16a==1,m  

forval i=2014/2016 {
tab hmp`i' if in_16a==1,m
}


*========attrition analysis========
forval i=10(2)16 {
clonevar in_20`i'=in_`i'a 
}
clonevar in_2011=in_2012
clonevar in_2013=in_2014
clonevar in_2015=in_2016


forval i=10(2)16 {
clonevar in_20`i'hh=in_`i'hh
}
clonevar in_2011hh=in_2012hh
clonevar in_2013hh=in_2014hh
clonevar in_2015hh=in_2016hh


* generate a new tag that capture if ego were interviewed in each survey  (13, 15 being adult survey, the rest are household)
foreach x of numlist 2011 2012 2014 2016 {
clonevar in_`x'b=in_`x'hh
}

foreach x of numlist 2010 2013 2015 {
clonevar in_`x'b=in_`x'
}


*log using "${logs}\home-leaving$date}", text replace 

/*
*remedy to  missings in 2011, 2013 & 2015
replace hmp2011=hmp2012 if !missing(hmp2010, hmp2012) & hmp2010==hmp2012 & hmp2011==.
replace hmp2013=hmp2014 if !missing(hmp2012, hmp2014) & hmp2012==hmp2014 & hmp2013==.
replace hmp2015=hmp2016 if !missing(hmp2014, hmp2016) & hmp2014==hmp2016 & hmp2015==.
*/

*for missing, what if simply assume home-leaving status to be unchanged in between waves ? : looks fine 
replace hmp2011=hmp2012 if !missing(hmp2012) & hmp2011==.
replace hmp2013=hmp2014 if !missing(hmp2014) & hmp2013==.
replace hmp2015=hmp2016 if !missing(hmp2016) & hmp2015==.
*/

tab hmp2012 hmp2014 if hmp2013==. & in_2013b==1,m
tab hmp2014 if hmp2013==. & in_2013==1,m

/*
forval i=2010/2016{
*tab hmp`i', m
*tab hmp`i' if in_`i'b==1,m 
*tab hmp`i' if in_`i'==1,m 
*tab hmp`i' if in_`i'hh==1,m 
*tab hmp`i' if livepa2010==1 & in_`i'==1,m 
*tab hmp`i' if livepa2010==0,m 
}

log using "${logs}\livepa$date", text replace 
forval i=2010/2016{
tab hmp`i' if livepa2010==1 & in_`i'b==1, m
}
log close

*/

keep pid in_201* livepa201* hmp201*
save "${datadir}\homeleaving_EHC.dta" ,replace 


*========check distribution=================
use "${datadir}\panel_1016.dta" , clear  // previous panel 
merge 1:1 pid using "${datadir}\marr_EHC.dta" , nogen 
merge 1:1 pid using "${datadir}\edu_EHC_temp.dta", keep(master match)nogen    // temprorary file
merge 1:1 pid using  "${datadir}\work_EHC.dta", keep (master match) nogen 
merge 1:1 pid using  "${datadir}\homeleaving_EHC.dta" , keep(master match) nogen 

*======impose sample restrictions====== 
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
*keep if age>=20 & age<=45  // N=1565
keep if age>=16 & age<=34  // N= 2962



misschk hmp2010 hmp2011 hmp2012 hmp2013 hmp2014 hmp2015 hmp2016, gen(m)
drop if mnumber>0

forval i=2010/2016{
tab hmp`i', m  		
}

forval i=0/6 {
g age201`i'=age+`i'
}

preserve 
drop age
reshape long hmp age, i(pid) j(year )
collapse (mean)hmp, by (age male)
bytwoway (line hmp age), by(male) aes(color lpattern) 



forval i=2010/2016{
g marhm`i'=(married`i'==1 & hmp`i'==1)      // married & stay at 2010 home 
g marmove`i'=(married`i'==1 & hmp`i'==0)    // married & move out from 2010 home 

replace marhm`i'=.   if married`i'==. |hmp`i'==. 
replace marmove`i'=. if married`i'==. |hmp`i'==. 
}


forval i=2010/2016 {
tab marhm`i',m
tab marmove`i',m
}


forval i=2011/2016{
local j=`i'-1
g newlywed`i'=(married`i'==1 & married`j'==0)
replace newlywed`i'=. if married`i'==. |  married`j'==. 
}

forval i=2011/2016 {
tab urban10 marhm`i' if newlywed`i'==1 & male==1 ,m 
*tab newlywed`i' marmove`i',m
}


// *check distribution of home-leaving 
// g byr=2010-age
// egen bdif=diff(byr birthy_best)
// replace byr=birthy_best if bdif==1
//
// keep pid hmp* byr age
// reshape long hmp, i(pid) j(year)


forval i=2010/2016 {
tab hmp`i',m
}





*relationships betwee missings & living arragements 
* hypothesis : one may moved out (lost follow up 
erase "${datadir}\resi2014_temp.dta" 



*updated on 07092019: cross check with two-year measurement
use "${datadir}\panel_1016.dta", clear
merge 1:1 pid using "${datadir}\marr_EHC.dta", nogen 


forval i=12(2)16{
g 		marstay`i'=1 if marstat`i'==1 & livepa`i'==1
replace marstay`i'=0 if marstat`i'==0 
replace marstay`i'=0 if marstat`i'==1 & livepa`i'==0

g       marleave`i'=1 if marstat`i'==1 & livepa`i'==0
replace marleave`i'=0 if marstat`i'==0 
replace marleave`i'=0 if marstat`i'==1 & livepa`i'==1 
}

misschk marstay12 marstay14 marstay16
misschk marleave12 marleave14 marleave16


merge 1:1 pid using "${datadir}\homeleaving_EHC.dta" ,  nogen  // N=2129

*======impose sample restrictions====== 
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
*keep if age>=20 & age<=45  // N=1565
keep if age>=15 & age<=45  // N= 2962


*====================missing on Y=====================
*main analysis drop missings
misschk marstat12 marstat14 marstat16  livepa12 livepa14 livepa16, gen(m)
keep if mnumber==0   // N=2131

// marital status is irreversable 
drop if marstat12==1 & marstat14==0  // 2 observation dropped ==> 2131

*keep pid livepa* hmp*

*check inconsistencies 
forval i=2010(2)2016{
tab livepa`i' hmp`i',m
}

*some indicated not living with parents 

// *proportion of the status over age
// reshape long hmp,i(pid)j(year)
//
// prop hmp, over(age)
//
// mat c=r(table)
// mat phm==c[1, 8..14]
//
// foreach x of varlist hmp {
// qui: prop `x', over (year)
// // mat `x'=r(table)
// // mat list r(table)
// // mat p`x'= `x'[1,22..42]
// // mat list p`x'
// }


*sample restriction 
*many who were zero in livepa are identified as 1 in hmp. What happend ? 

