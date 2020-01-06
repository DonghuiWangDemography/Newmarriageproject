clear
input family person father mother age education
 1 1001    .    . 45 12
 1 1002    .    . 47 16
 1 1003 1001 1002 10  4
 1 1004 1001 1002 11  5
 1 1005 1001 1002 12  6
 2 2001    .    . 52 11
 2 2002    . 2001 24 10
 2 2003    . 2002  7  2
end

list, sepby(family) noobs

preserve

keep person age education
rename (person age education) (mother age_m edu_m)
tempfile mothers
save "`mothers'"

rename (mother age_m edu_m) (father age_f edu_f)
tempfile fathers
save "`fathers'"

restore

merge m:1 mother using "`mothers'", keep(master match) nogen
merge m:1 father using "`fathers'", keep(master match) nogen

sort family person
list, sepby(family) noobs
