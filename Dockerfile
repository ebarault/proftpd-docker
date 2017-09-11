FROM ubuntu:14.04
MAINTAINER "@ebarault"

RUN apt-get -y update && \
    echo 'proftpd-basic shared/proftpd/inetd_or_standalone select standalone' | debconf-set-selections && \
    apt-get -y install proftpd-basic proftpd-mod-pgsql && \
    apt-get -y --no-install-recommends install openssh-server

COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY modules.conf /etc/proftpd/modules.conf
COPY tls.conf /etc/proftpd/tls.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

# SSL CERTS
VOLUME ["/etc/proftpd/ssl"]

# FTP ROOT
VOLUME ["/srv/ftp"]
RUN chown ftp:nogroup /srv/ftp

EXPOSE 21 23 49152-49407

ENTRYPOINT ["/entrypoint.sh"]
