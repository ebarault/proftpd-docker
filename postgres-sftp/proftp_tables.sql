CREATE SCHEMA ftp;
GRANT USAGE ON SCHEMA ftp TO xydatadev_user;

CREATE TABLE ftp.users (
  pkid      serial      PRIMARY KEY,
  userid    text        NOT NULL UNIQUE,
  passwd    text,
  uid       int,
  gid       int,
  homedir   text,
  shell     text
);
GRANT SELECT ON ftp.users TO xydatadev_user;

CREATE TABLE groups (
        groupname text NOT NULL,
        gid integer,
        members text
);
GRANT SELECT ON ftp.groups TO xydatadev_user;

CREATE TABLE ftp.file_log (
  pkid               serial      PRIMARY KEY,
  userid             text        REFERENCES ftp.users(userid),
  abs_path           text,
  file               text,
  dns                text,
  time_transaction   text,
  ts_in              timestamp with time zone   NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT INSERT ON ftp.file_log TO xydatadev_user;
GRANT UPDATE ON TABLE ftp.file_log_pkid_seq TO xydatadev_user;
