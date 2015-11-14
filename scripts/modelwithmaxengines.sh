#!/bin/sh

#Fisrt argument is the dataset (optd_aircraft.csv)
#Example: ./modelwithmaxengines.sh ../data/optd_aircraft.csv

#Get the airplane with maximun number of engines from the dataset
csvsort -r -d '^' -c nb_engines $1 | uniq | uniq -c | head  | csvcut  -c model | head -2 | tail -n +2

#Alternate method: csvsort -r -d '^' -c nb_engines optd_aircraft.csv | head -2 | csvcut  -c model | tail -1
