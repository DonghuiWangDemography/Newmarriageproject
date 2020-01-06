*lifetable practice 
*https://data.princeton.edu/eco572/periodlt

infile age N D using https://data.princeton.edu/eco572/datasets/prestonb31.dat, clear
gen n=age[_n+1]-age
replace n=0 in -1
g m=D/N  // events by exposure

merge 1:1 age using https://data.princeton.edu/eco572/datasets/kfnax
