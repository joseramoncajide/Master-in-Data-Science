#!/bin/sh

#Obtener el avión con el mayor número de motores
csvsort -r -d '^' -c nb_engines optd_aircraft.csv | uniq | uniq -c | head  | csvcut  -c model | head -2 | tail -n +2

#Alternativa: csvsort -r -d '^' -c nb_engines optd_aircraft.csv | head -2 | csvcut  -c model | tail -1
