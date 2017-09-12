## proftpd-docker

## Requirements
- docker
- (docker-compose)

## Running with docker-compose

## Running with docker

* Build image:
```
docker build -t proftpd .
```
* Create the necessary tables on a PostgreSQL instance using the included migration: `proftp_tables.sql`.
* Start container and provide the necessary PostgreSQL connection information:
```
docker run -p 21:21 -p 23:23 --name proftp -e DB_HOST=<host> -e DB_NAME=<db> -e DB_USER=proftp -e DB_PASS=<pwd_in_script> -d proftpd
```
* Passwords in the db are encrypted using the CRYPT(3) algorithm. To generate encrypted password use the following:
  * Command Line: `openssl passwd -crypt your_pwd`
  * Java: http://commons.apache.org/proper/commons-codec/
