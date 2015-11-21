# SQL
In order to avoid low performance issues when dealing with big CSV files, it is recommended to use a database engine where we can import the datasets for faster queries.



## Installing and running PostgreSQL in Fedora

The first step will be to download and install PostgreSQL in Linux.

Installing as root:
```
sudo dnf install postgresql postgresql-server
```
When necessary, check for updates:
```
sudo postgresql-setup --upgrade
```
Once installed:
```
sudo postgresql-setup initdb
```
Then enable to run as service and start the service
```
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service
```

## Creating de database and importing the datasets

Once PostgreSQL is installed in the system, we can proceed with creating a database for storing the CSV files.

Depending of the system configuration, it may be necessary to disable SELinux
```
sudo setenforce 0
```
Gain access as root
```
sudo su postgres
```
Creating the database:
```
createdb optd
```
Entering psql with the previous database selected:
```
psql optd
```
Checking with *csvsql* the database schema needed for one of our CSV files:
```
csvsql -d '^' optd_airlines.csv | less
```
Generating the schema for specific use with postgresql and import the dataset:
```
csvsql -d '^' -i postgresql  optd_por_public.csv | psql optd
psql optd
copy optd_por_public from '/tmp/optd_por_public.csv' delimiter '^' csv header;
```
In order to fix optd_por_public.csv file we need to save a clean copy of this file and the import it with as stated before:
```
csvgrep -d '^' optd_por_public.csv -c moddate -r '[0-9]{4}-[0-9]{2}-[0-9]{2}' > optd_clean.csv
less optd_clean.csv
chmod 777 optd_clean.csv
copy optd_por_public from '/tmp/optd_clean.csv' delimiter ',' csv header;
```
It's necessary to note that csvgrep command will use a ',' delimiter by default, so in the copy command we must specify it.

## Backup the database
In order to make a copy of our database we can use *pg_dump*
```
pg_dump optd |less 
pg_dump optd | bzip2 -9  > optd_backup.sql.bz2
```
Just for testing, we can create a test database and restore the backup
```
bzcat optd_backup.sql.bz2 | head
bzcat optd_backup.sql.bz2 | psql optd_backup
```

## Data base optimization

When can test the performance of a complex sql query with *EXPLAIN ANALYZE*

```sql
EXPLAIN ANALYZE select name, "2char_code", airline_code_2c, flight_freq
from optd_airlines
left outer join ref_airline_nb_of_flights
on "2char_code" = airline_code_2c
order by flight_freq desc   limit 10;
```

It is always recommended to create the necessary indexes in the table in order to optimize database speed. Example:
```sql
CREATE INDEX flight_freq_idx ON ref_airline_nb_of_flights(flight_freq)
```

Within psql we can check the new index (by default a btree)
```
\d ref_airline_nb_of_flights 
```

Another can of optimization can be done with the following commands:
```sql
VACUUM ANALYZE VACUUM ANALYZE ref_airline_nb_of_flights;
VACUUM FULL ANALYZE ref_airline_nb_of_flights;
```



