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

# MAIN CONF FILE
COPY proftpd.conf /etc/proftpd/proftpd.conf

# DEFAULT CONF FILES
COPY tls.conf /etc/proftpd/tls.conf
COPY sql.conf /etc/proftpd/sql.conf
COPY vroot.conf /etc/proftpd/vroot.conf
COPY ./certs /etc/proftpd/certs
COPY ./exec /etc/proftpd/exec

# SQL MIGRATION TEMPLATE
COPY sql/proftp_tables.sql.tpl /etc/proftpd/proftp_tables.sql.tpl

COPY entrypoint.sh ./entrypoint.sh
RUN chmod a+x ./entrypoint.sh

RUN mkdir /var/log/proftpd

# FTP ROOT
VOLUME /srv/ftp

EXPOSE 21 49152-49407

ENTRYPOINT ["./entrypoint.sh"]
