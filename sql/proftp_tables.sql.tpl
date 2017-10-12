CREATE SCHEMA ftp;
GRANT USAGE ON SCHEMA ftp TO $FTP_DB_USER;

CREATE TABLE ftp.users (
  userid    VARCHAR(30) NOT NULL UNIQUE,
  passwd    VARCHAR(80) NOT NULL,
  uid       INTEGER UNIQUE,
  gid       INTEGER,
  homedir   VARCHAR(255),
  shell     VARCHAR(255),
  last_accessed TIMESTAMP WITH TIME ZONE
);
GRANT SELECT, UPDATE ON ftp.users TO $FTP_DB_USER;

CREATE TABLE ftp.groups (
  groupname VARCHAR(30) NOT NULL,
  gid INTEGER NOT NULL,
  members VARCHAR(255)
);
GRANT SELECT ON ftp.groups TO $FTP_DB_USER;

CREATE TABLE ftp.login_history (
  userid VARCHAR NOT NULL,
  client_ip VARCHAR NOT NULL,
  server_ip VARCHAR NOT NULL,
  protocol VARCHAR NOT NULL,
  login_date TIMESTAMP WITH TIME ZONE
);
GRANT INSERT ON ftp.login_history TO $FTP_DB_USER;
