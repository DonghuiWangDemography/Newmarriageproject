// ado file on where where all the data are stored 

program cfps

global logs "${dir}\logs"
global graphs "${dir}\graphs"
global tables "${dir}\tables"
global code "${dir}\code"

*====================CFPS data ====================

global datadir "${dir}\CFPSrawdata_Chinese"  

global w10hh "${datadir}\2010\cfps2010famconf_report_nat092014.dta"
global w10hh2 "${datadir}\2010\cfps2010family_report_nat092014.dta"
global w10a "${datadir}\2010\cfps2010adult_report_nat092014.dta"
global w10c "${datadir}\2010\cfps2010child_report_nat092014.dta"

global w11a "${datadir}\2011\cfps2011adult_102014.dta"

global w12hh "${datadir}\2012\cfps2012famros_092015compress.dta"
global w12a "${datadir}\2012\cfps2012adultcombined_092015compress.dta"
global w12c "${datadir}\2012\cfps2012childcombined_032015compress.dta"
global w12cross "${datadir}\2012\crossyearid_032015compress.dta"
global w12hh2 "${datadir}\2012\cfps2012family_092015compress.dta"

global w14hh "${datadir}\2014\cfps2014famconf_170630.dta"
global w14a "${datadir}\2014\cfps2014adult_170630.dta"
global w14c "${datadir}\2014\Cfps2014child_170630.dta"
global w14hh2 "${datadir}\2014\Cfps2014famecon_170630.dta"

global w16hh "${datadir}\2016\cfps2016famconf_201804.dta"
global w16hh2 "${datadir}\2016\cfps2016famecon_201807.dta" 
global w16a "${datadir}\2016\cfps2016adult_201808.dta"
global w16c "${datadir}\2016\cfps2016child_201807.dta"
global cross "${datadir}\2016\Cfps2016crossyearid_201807.dta"

end 
