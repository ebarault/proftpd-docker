build:
	docker build -t proftpd .
run:
	docker run --net=host --name proftpd -e FTP_DB_HOST=prd-lagrange-rds-postgres-dev-1.cswvwnh8mmab.eu-west-1.rds.amazonaws.com -e FTP_DB_NAME=htprodata -e FTP_DB_USER=xydatadev_user -e FTP_DB_PASS=S29JnRK4nARYdjMySFwgqyDUjJmqtswC -e SSL_CERTS=$(pwd)/ssl -v /data/target:/srv/ftp -d proftpd

crypt_pass:
	openssl passwd -crypt password

curl_list:
	curl -v --ssl --insecure --disable-epsv ftp://ftp.datagate.lagrangenumerique.fr:21 -u user:pwd

curl_put:
	curl -v -T </path/to/file> --ssl --insecure --disable-epsv ftp://ftp.datagate.lagrangenumerique.fr:21 -u user:pwd
