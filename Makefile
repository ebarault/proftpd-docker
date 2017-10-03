build:
	docker build -t proftpd .

stop:
	docker stop proftpd

rm:
	docker rm proftpd

run:
	docker run --name proftpd --net=host \
		-e FTP_DB_HOST=$$FTP_DB_HOST -e FTP_DB_NAME=$$FTP_DB_NAME -e FTP_DB_USER=$$FTP_DB_USER -e FTP_DB_PASS=$$FTP_DB_PASS \
		-e MASQ_ADDR=$$MASQ_ADDR \
		-v $$FTP_ROOT:/srv/ftp \
		-v $$LOGS:/var/log/proftpd \
		-v $$(pwd)/salt:/etc/proftpd/salt \
		-e MOD_SSL=ON \
		-v $$(pwd)/ssl:/etc/proftpd/ssl \
		-e MOD_EXEC=ON \
		-v $$(pwd)/exec:/etc/proftpd/exec \
		-e MOD_VROOT=ON \
		-v $$(pwd)/vroot:/etc/proftpd/vroot \
		-d proftpd

env_run:
	(export $$(cat .env | grep -v ^\# | xargs) && make run)

logs:
	docker logs proftpd

curl_list:
	curl -v --ssl --insecure --disable-epsv ftp://my-ftp-server.com:21 -u user:pwd

curl_put:
	curl -v -T </path/to/file> --ssl --insecure --disable-epsv ftp://my-ftp-server.com:21 -u user:pwd
