*exploratory of 2005 census 


clear all
cd "C:\Users\donghuiw\Desktop\chinacensus" 
  unicode analyze census2005.dta
  unicode encoding set gb18030 
  unicode translate census2005.dta ,   invalid(mark)
  unicode retranslate census2005.dta, transutf8 invalid(mark)


use census2005.dta, clear 
