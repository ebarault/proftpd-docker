# docker-proftpd
Varying configurations of ProFtpd installs

## Setup
* Install the Docker Toolbox https://docs.docker.com/mac/step_one/

## Using ProFtpd
* Change directory into desired flavor
* Build image:
```
docker build -t proftpd .
```
* Create the necessary tables on a PostgreSQL instance using the included migration: `proftp_tables.sql`.
* Start container and provide the necessary PostgreSQL connection information:
```
docker run -p 21:21 -p 23:23 --name proftp -e DB_HOST=<host> -e DB_NAME=<db> -e DB_USER=proftp -e DB_PASS=<pwd_in_script> -d proftpd
```
