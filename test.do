*practice of interflex
cd "C:\Users\donghuiw\Desktop\Marriage\CFPSrawdata_Chinese"
ssc install interflex, replace all

use interflex_s1.dta, clear 
twoway (sc Y X) (lowess Y X), by(D)

interflex Y D X Z1, type(linear) sav(fig1) 
interflex Y D X Z1, vce(r) ylab(Outcome) dlab(Treat) xlab(XX)
interflex Y D X Z1, vce(r) n(4) ti(Marginal Effect) xr(-2 8) yr(-30 20)
