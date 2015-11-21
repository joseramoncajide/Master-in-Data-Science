
select name, "2char_code", airline_code_2c, flight_freq
from optd_airlines
left outer join ref_airline_nb_of_flights
on "2char_code" = airline_code_2c
order by flight_freq desc   limit 10;

select airline_code_2c,name, flight_freq
from optd_airlines AS o
left outer join ref_airline_nb_of_flights AS r
on o."2char_code" = airline_code_2c
order by flight_freq desc   limit 10;


select airline_code_2c,name, flight_freq
from ref_airline_nb_of_flights AS r
right outer join optd_airlines AS o
on o."2char_code" = airline_code_2c
order by flight_freq desc   limit 10;

select name, country, elevation
from optd_por_public
where elevation > (select avg(elevation) from optd_por_public)
limit 10;

#csvgrep -d '^' optd_por_public.csv -c moddate -r '[0-9]{4}-[0-9]{2}-[0-9]{2}' > optd_clean.csv
copy optd_por_public from '/tmp/optd_clean.csv' delimiter ',' csv header;

csvsql -d '^' optd_aircraft.csv 
CREAR TABLE:
csvsql -d '^' optd_aircraft.csv   -i postgresql | psql optd 
psql optd
copy optd_airlines from '/tmp/optd_airlines.csv' delimiter '^' csv header;

