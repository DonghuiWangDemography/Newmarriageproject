*identify independent living 
*created in 07202019
clear all 
global date "07182019"   // mmddyy
global dir "C:\Users\donghuiw\Desktop\Marriage"  // office 
*global dir "W:\Marriage"                         // pri 
*global dir "C:\Users\wdhec\Desktop\Marriage"     // home  

cfps 

*define independent living :

use $w10hh , clear 
*if live with in-laws

bysort tb6_a_s
