#!/bin/sh

#Permisos de ejecución: chmod a+x hola.sh
echo "Hello world"

csvsort -r -d '^' -c nb_engines optd_aircraft.csv | uniq | uniq -c | head  | csvcut  -c model | head -2 | tail -n +2
