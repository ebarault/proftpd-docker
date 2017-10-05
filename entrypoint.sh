#!/bin/sh

PROFTPD_ARGS="-DMOD_EXEC=$MOD_EXEC -DMOD_TLS=$MOD_TLS -DMOD_VROOT=$MOD_VROOT"

if [ "$MASQ_ADDR" = "AWS" ]; then
	MASQ_ADDR=`curl -f -s http://169.254.169.254/latest/meta-data/public-ipv4`
fi

if [ ! -z "$MASQ_ADDR" ]; then
	PROFTPD_ARGS="$PROFTPD_ARGS -DUSE_MASQ_ADDR"
fi

echo $PWD_SALT > /etc/proftpd/.salt

# allow proftpd writing custom logs
chown -R proftpd:proftpd /var/log/proftpd

exec /usr/local/sbin/proftpd --nodaemon $PROFTPD_ARGS
