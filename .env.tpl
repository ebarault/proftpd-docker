FTP_DB_HOST=    # db hostname or ip address, required
FTP_DB_NAME=    # db name, required
FTP_DB_USER=    # db user, required
FTP_DB_PASS=    # db password, required

FTP_ROOT=       # /path/to/ftp/root, optional, defaults to /data/ftp_root
LOGS=           # /path/to/log/dir, optional, defaults to /var/log/proftpd
SALT=           # /path/to/salt/dir, optional, defaults to `./salt`
MASQ_ADDR=			#	ipv4_addr, hostname or "AWS", optional

MOD_SSL=        # ON/OFF, activate/deactivate module mod_tls, optional, defaults to OFF
SSL_CERTS=      # /path/to/ssl/certs/dir, optional, defaults to `./ssl`

MOD_EXEC=       # ON/OFF, activate/deactivate module mod_exec, optional, defaults to OFF
MOD_EXEC_CONF=  # /path/to/mod/exec/dir, optional, defaults to `./exec`
