build:
	docker build -t proftpd .
run:
	docker run --net=host --name proftp -e DB_HOST=prd-lagrange-rds-postgres-dev-1.cswvwnh8mmab.eu-west-1.rds.amazonaws.com -e DB_NAME=htprodata -e DB_USER=xydatadev_user -e DB_PASS=S29JnRK4nARYdjMySFwgqyDUjJmqtswC -v "$(pwd)"/target:/srv/ftp -d proftpd

crypt_pass:
	openssl passwd -crypt password

curl_list:
	curl -v --ssl --insecure --disable-epsv ftp://ftp.datagate.lagrangenumerique.fr:21 -u user:pwd

curl_put:
	curl -v -T </path/to/file> --ssl --insecure --disable-epsv ftp://ftp.datagate.lagrangenumerique.fr:21 -u user:pwd
