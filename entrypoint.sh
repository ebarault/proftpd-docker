#!/bin/sh

# allow proftpd writing custom logs
chown -R proftpd:proftpd /var/log/proftpd

exec /usr/local/sbin/proftpd --nodaemon -DMOD_EXEC=$MOD_EXEC
