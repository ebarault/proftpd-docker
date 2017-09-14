FROM alpine:3.6
MAINTAINER "@ebarault"

RUN set -x && \
  apk add --no-cache --virtual .persistent-deps \
    ca-certificates \
    curl \
    postgresql-client && \
  apk add --no-cache --virtual .build-deps \
    git \
    build-base \
    postgresql-dev

RUN git clone https://github.com/proftpd/proftpd.git

RUN cd proftpd && \
  sed -i 's/__mempcpy/mempcpy/g' lib/pr_fnmatch.c && \
  ./configure --sysconfdir=/etc/proftpd --localstatedir=/var/proftpd --with-modules=mod_sql:mod_sql_postgres:mod_sql_passwd:mod_tls --enable-openssl --disable-ident && \
  make && \
  make install && \
  cd ../ && \
  rm -rf proftpd && \
  apk del .build-deps

# man adduser: https://linux.die.net/man/1/busybox
RUN addgroup proftpd && \
  adduser -H -D -G proftpd proftpd

# CONF FILES
COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY tls.conf /etc/proftpd/tls.conf
COPY sql.conf /etc/proftpd/sql.conf

COPY entrypoint.sh ./entrypoint.sh
RUN chmod a+x ./entrypoint.sh

# PROFTPD LOGS
VOLUME /var/log/proftpd

# FTP ROOT
VOLUME /srv/ftp

# SSL CERTS
VOLUME /etc/proftpd/ssl

# SQL PASSWORD SALT
VOLUME /etc/proftpd/salt

# MOD EXEC CONF
VOLUME /etc/proftpd/exec

EXPOSE 21 49152-49407

ENTRYPOINT ["./entrypoint.sh"]
