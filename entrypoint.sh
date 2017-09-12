#!/bin/sh

# allow proftpd writing custom logs
chown -R proftpd:nogroup /var/log/proftpd

exec /usr/sbin/proftpd --nodaemon -DMOD_EXEC=$MOD_EXEC
