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

