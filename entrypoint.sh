#!/bin/sh

PROFTPD_ARGS="-DMOD_EXEC=$MOD_EXEC -DMOD_TLS=$MOD_TLS -DMOD_VROOT=$MOD_VROOT -DVERBOSE=$FTP_VERBOSE"

if [ "$MASQ_ADDR" = "AWS" ]; then
	MASQ_ADDR=`curl -f -s http://169.254.169.254/latest/meta-data/public-ipv4`
fi

if [ ! -z "$MASQ_ADDR" ]; then
	PROFTPD_ARGS="$PROFTPD_ARGS -DUSE_MASQ_ADDR"
fi

if [ "$FTP_PG_MIGRATE" = "ON" ]; then
	## Create sql migration file from proftp_tables.sql.tpl template
	envsubst < /etc/proftpd/proftp_tables.sql.tpl > /etc/proftpd/proftp_tables.sql
	rm /etc/proftpd/proftp_tables.sql.tpl

	## Init the PGPASSWORD env var so psql does not prompt it
	export PGPASSWORD=$FTP_DB_ADMIN_PASS

	## Wait for it : Postgres db is ready
	until psql -h $FTP_DB_HOST -d $FTP_DB_NAME -U $FTP_DB_ADMIN -p 5432 -c '\l'; do
	  echo "Postgres is unavailable - sleeping"
	  sleep 1
	done

	echo "Postgres is up - executing command"
	psql -h $FTP_DB_HOST -d $FTP_DB_NAME -U $FTP_DB_ADMIN -p 5432 < /etc/proftpd/proftp_tables.sql -w
fi

echo $PWD_SALT > /etc/proftpd/.salt

# allow proftpd writing custom logs
chown -R proftpd:proftpd /var/log/proftpd

exec /usr/local/sbin/proftpd --nodaemon $PROFTPD_ARGS
