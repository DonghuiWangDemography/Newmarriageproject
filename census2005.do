// census 
*2005 1% census does not sample on the basis of household, therefore unable to identify ego's living arragement 


cd "C:\Users\donghuiw\Desktop\chinacensus"

use census2005.dta,clear
keep if year_mar1== 2003 |  year_mar1== 2004 | year_mar1== 2005  //limit to newly weds: N=8798
keep if hhtype==1 // keep family houshold (exclude jitihu)

*sampled household or individual ??

*identify living arragement
*living with own parents 
*living with in-laws
*do not living with parents 
bysort hhid: g familysize=_N
bysort hhid: g pid=_n
egen d_n=diff(familysize n_hh)


g 		male=1 if sex==1
replace male=0 if sex==2

g 		urbanhukou=1 if hktype==2
replace urbanhukou=0 if hktype==1

g married=(maritus>1)
g birth=ym(year_birth, moth_birth) 
g mar=ym(year_mar1, month_mar1)
format birth mar %tm 

keep if year_birth>=1965 & year_birth<=1990  // the same cohort

g marage=year_mar1-year_birth if !missing(year_mar1,year_birth) & married==1  // quite some negatives 
g mar_age=int((mar-birth)/12) if !missing(birth,mar) & married==1


egen gr=group(urbanhukou male)
la def gr 1"non-urban hukou, female" 2"non-urban hukou, male" 3"urban hukou, female" 4"urban hukou male", modify 
la val gr gr 	

tab urbanhukou male,m
tab gr,m

bysort gr: sum  marage if marage>0, detail
histogram marage if marage>0, by(gr)
graph hbox marage if marage>0, over(gr)

bysort urbanhukou male : egen marage_p25=pctile(marage) if marage>0 & marage<=40 & married==1  ,p(25)   // 22:rural female, 23:rural male , 24: urban male, 25:urban female
bysort urbanhukou male : egen marage_p50=median(marage) if marage>0 & marage<=40 & married==1   // 22:rural female, 23:rural male , 24: urban male, 25:urban female
bysort urbanhukou male : egen marage_p75=pctile(marage) if marage>0 & marage<=40 & married==1  ,p(75)

tab gr marage_p25 
tab gr marage_p50 
tab gr marage_p75 

tab gr
tab 
