FROM ubuntu:16.04
MAINTAINER "@ebarault"

RUN apt-get -y update && \
  apt-get -y install git curl postgresql-client build-essential libssl-dev libpq-dev openssl

# RUN curl -o proftpd.tar.gz ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.6rc4.tar.gz && \
#   tar zxvf proftpd.tar.gz

# RUN cd proftpd-1.3.6rc4 && \

RUN git clone https://github.com/proftpd/proftpd.git && \
    git clone https://github.com/Castaglia/proftpd-mod_vroot.git

RUN cd proftpd-mod_vroot && \
    git checkout tags/v0.9.5 && \
    cd ..

RUN mv proftpd-mod_vroot proftpd/contrib/mod_vroot

RUN cd proftpd && \
  ./configure --sysconfdir=/etc/proftpd --localstatedir=/var/proftpd --with-modules=mod_sql:mod_sql_postgres:mod_sql_passwd:mod_tls:mod_exec:mod_vroot --enable-openssl --disable-ident && \
  make && \
  make install

RUN groupadd proftpd && \
  useradd -g proftpd proftpd

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

# TLS CERTS
VOLUME /etc/proftpd/certs

# SQL PASSWORD SALT
VOLUME /etc/proftpd/salt

# OVERRIDING MOD TLS CONF
VOLUME /etc/proftpd/tls.conf

# MOD EXEC CONF
VOLUME /etc/proftpd/exec

# MOD VROOT CONF
VOLUME /etc/proftpd/vroot

EXPOSE 21 49152-49407

ENTRYPOINT ["./entrypoint.sh"]
