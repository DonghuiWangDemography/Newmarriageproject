ssc install ua, replace

clear all
cd "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese\2010" 
ua: unicode encoding set gb18030 
ua: unicode translate  *.dta

// family 2010 fail to translate 
cd "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese\2010"
  unicode analyze cfps2010family_report_nat092014.dta
  unicode encoding set GBK
  unicode translate cfps2010family_report_nat092014.dta ,  transutf8 invalid(mark)
  unicode retranslate cfps2010family_report_nat092014.dta, transutf8 invalid(mark)
// 
 cd "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese\2010"
  unicode analyze cfps2010famconf_report_nat092014.dta
  unicode encoding set GBK
  unicode translate cfps2010famconf_report_nat092014.dta ,  transutf8 invalid(mark)
  unicode retranslate cfps2010famconf_report_nat092014.dta, transutf8 invalid(mark) 

cd "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese\2012" 
ua: unicode encoding set gb18030 
ua: unicode translate  *.dta


cd "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese\2014" 
ua: unicode encoding set gb18030 
ua: unicode translate  *.dta

cd "C:\Users\wdhec\Desktop\Marriage\CFPSrawdata_Chinese\2016" 
ua: unicode encoding set gb18030 
ua: unicode translate  *.dta

cd "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"
ua: unicode encoding set gb18030 
ua: unicode translate   CFPScountycode.dta
