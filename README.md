# proftpd-docker

## Requirements

- docker
- (docker-compose)
- PostgreSQL instance
- Creating the necessary tables on the PostgreSQL instance using the included migration: `sql/proftp_tables.sql`.
- openssl (for creating passwords)

## Running with docker-compose, building image

* Create a `.env` containing the requirements environnement variables

This file should be located next to the provided `docker-compose.yml` file.
The `.env.tpl` file can be used to bootstrap the `.env` file.

The required/optional parameters are described here after:

- **FTP_DB_HOST**: db hostname or ip address, required
- **FTP_DB_NAME**: db name, required
- **FTP_DB_USER**: db user, required
- **FTP_DB_PASS**: db password, required
- **FTP_DB_ADMIN**: db admin user, required if FTP_PG_MIGRATE=ON
- **FTP_DB_ADMIN_PASS**: db admin password, required if FTP_PG_MIGRATE=ON
- **FTP_PG_MIGRATE**: ON/OFF, activate/deactivate automatic creation of tables required by proftpd in postgresql database
- **FTP_ROOT**: /path/to/ftp/root, optional, defaults to /data/ftp_root
- **LOGS**: /path/to/log/dir, optional, defaults to /var/log/proftpd
- **SALT**: /path/to/salt/file, optional, defaults to `./.salt`
- **MOD_TLS**: ON/OFF, activate/deactivate module mod_tls, optional, defaults to OFF
- **MOD_TLS_CONF**: /path/to/mod_tls.conf, optional, defaults to included tls.conf
- **CERTS**: /path/to/tls/certs/dir, optional, defaults to `./certs`
- **MOD_EXEC**: ON/OFF, activate/deactivate module mod_exec, optional, defaults to OFF
- **MOD_EXEC_DIR**: /path/to/mod/exec/dir, optional, defaults to `./exec`
- **MOD_VROOT**: ON/OFF, activate/desactivate module_vroot, optional, default to OFF
- **MOD_VROOT_CONF**: /path/to/mod_vroot.conf, optional, defaults to included vroot.conf

* Build and run the container as follows:
```sh
docker-compose build
docker-compose up -d
```

### Configuring postgreSQL connection
Refer to this [link](http://www.proftpd.org/docs/howto/SQL.html) and on `sql/proftpd_tables.sql` file for detailed information on required SQL data model.

The migration should be run by a user with owner privilege on the designated database. The script supposes a second user exists beforehand, whose privileges are managed by the migration.

The `FTP_DB_HOST`, `FTP_DB_NAME`, `FTP_DB_USER` and `FTP_DB_PASS` env vars should be provided to the container to configure proftpd's connection with the postgreSQL instance.

### Automatic migration
Env vars `FTP_DB_ADMIN` and `FTP_DB_ADMIN_PASS` can also be provided combined with option `FTP_PG_MIGRATE=ON` to automatically create the tables required by proftpd in the postgreSQL database.

### Create users and groups
First create a group, or make sure an appropriate group already exists. The main attributes for groups are:
- **groupname** (unique)
- **gid** (unique, in [999-65533] as per the server config)

```sql
INSERT INTO ftp.groups
(groupname, gid)
VALUES('users', 999);
```

Then create the user. The required attributes are:
- **userid** (unique)
- **passwd** (salted sh256/512 hash, covered in next section)
- **uid** (unique, in [999-65533] as per the server config)
- **gid** (referencing an existing group id)
- **home** (absolute path to user's home `/srv/ftp/...` , created at first connection if required)

```sql
INSERT INTO ftp.users
(userid, passwd, uid, gid, homedir)
VALUES('JonDoe', 'am4Q3ukBh...QXg2UeRms=', 999, 999, '/srv/ftp/homes/jon_doe');
```

### User's passwords
Passwords are stored in the db as salted SHA256/512 digests, in hex64 encoding.

A random crypto string, known as **salt**, is used to mitigate dictionnary attacks and should be provided to the ftp server using the `SALT` env var.

The `SALT` env var let you define the path to a salt file mounted as a bound volume in the docker container. By default the container will look at a `.salt` file stored along the Dockerfile.

To generate an encrypted password use the following command:
```sh
{ echo -n myPassword; echo -n $(cat .salt); } | openssl dgst -binary -sha256 | openssl enc -base64 -A
```

where `.salt` is a file containing the **salt**.

The helper script `genpass.sh` is also provided in this distribution:
The usage is as follows:
```sh
package -s path/to/salt password
```

### Server address masquerading
The server can be instructed to send back to the client a specified IP address, or hostname. This is useful when dealing with NAT gateways, or boad balancers where passive mode is required.

The env var `MASQ_ADDR` can be set to either a given IP address or hostame, or to the value `AWS` in which case the server the server public ip will be automatically retrieved (if available) from AWS EC2 instance's metadata to set the env var.

### Configuring ftp root directory
The ftp root (home for all user's directories) can be configured using the `FTP_ROOT` env variable. Otherwise it default to the directory `/data/ftp_root` of the docker's host.

### Configuring proftpd logs directory
The ftp root (home for all user's directories) can be configured using the `LOGS` env variable. Otherwise it default to the directory `/var/log/proftpd` of the docker's host.

### Module mod_tls
When enabling the module with env var MOD_TLS=ON, a module configuration file and associated certificates should be provided as binded volumes. Default included configuration expects a self-signed TLS certificate `proftpd.cert.pem` and it's key file `proftpd.key.pem`.

A custom mod_tls configuration can be provided as a bound volume whose path is defined by the `MOD_TLS_CONF` env var.

Certificates should be stored in a directory accessible by the docker image, whose path is to be provided as the `CERTS` env var.

### Module mod_exec
When enabling the module with env var MOD_EXEC=ON, a `exec.conf` file containing the module configuration should be provided, as per the [module's documentation](http://www.proftpd.org/docs/contrib/mod_exec.html).

This file should be stored in a directory accessible by the docker image, whose path is to be provided as the `MOD_EXEC_CONF` env var.

### Module mod_vroot
When enabling the module with env var MOD_VROOT=ON, a vroot.conf file containing the module configuration should be provided, as per the [module's documentation](http://www.proftpd.org/docs/contrib/mod_vroot.html)

This file can be provided as a bound volume whose path is defined by the `MOD_VROOT_CONF` env var.

## Running with docker-compose, pulling image from docker hub

With `docker-compose-image.yml` an example is provided on how to integrate the proftpd-docker image hosted on docker hub inside a larger set-up, orchestrated with docker-compose.

Literally the main point is to declare the volume attachments inside the `docker-compose.yml` file as in:
```yml
volumes:
  - type: bind
    source: "${LOGS:-/var/log/proftpd}"
    target: /var/log/proftpd
```

The example relies on bound volumes but again any kind of volume you do.

_**Just mind:**_
- covering all required volumes as described in the **Running with docker** section,
- exposing any required port (or dropping `network_mode: host`)
- passing the env vars (with env_file or environment directive, or plain env vars)

when ok, run `docker-compose -f docker-compose-image.yml run`
**...and you're all set!**


## Running with docker

Following the previous sections, a number a env vars and volumes needs to be specified right to the cli when running the server with docker:

- **Env vars**:
  - `FTP_DB_HOST`
  - `FTP_DB_NAME`
  - `FTP_DB_USER`
  - `FTP_DB_PASS`
  - `FTP_DB_ADMIN`
  - `FTP_DB_ADMIN_PASS`
  - `FTP_PG_MIGRATE`
  - `MASQ_ADDR`
  - `MOD_TLS`
  - `MOD_EXEC`
  - `MOD_VROOT`
- **Volumes**:
  - **/srv/ftp** (_ftp root containing users' homes_)
  - **/var/log/proftpd** (_server's logs_)
  - **/etc/proftpd/.salt** (_`.salt` file_)
  - **/etc/proftpd/tls.conf** (_mod_tls config file_)
  - **/etc/proftpd/certs** (_dir containing server's certificates_)
  - **/etc/proftpd/exec** (_dir containing server's mod_exec conf and scripts_)
  - **/etc/proftpd/vroot.conf** (_mod_vroot config file_)

The following `docker run` example assumes bound volumes, but the anykind of docker volume config can be used.

* Build image:
```sh
docker build -t proftpd .
```
* Start container and provide the necessary env vars and volume information:
```sh
docker run --name proftpd --net=host \
  -e FTP_DB_HOST=mydb.com -e FTP_DB_NAME=db_name -e FTP_DB_USER=db_user -e FTP_DB_PASS=db_password \
  -e MASQ_ADDR:AWS \
  -v /data/ftp_root:/srv/ftp \
  -v /var/log/proftpd:/var/log/proftpd \
  -v $(pwd)/.salt:/etc/proftpd/.salt \
  -e MOD_TLS=ON \
  -v $(pwd)/tls.conf:/etc/proftpd/tls.conf \
  -v $(pwd)/certs:/etc/proftpd/certs \
  -e MOD_EXEC=ON \
  -v $(pwd)/exec:/etc/proftpd/exec \
  -e MOD_VROOT=ON \
  -v $(pwd)/vroot.conf:/etc/proftpd/vroot.conf
	-d proftpd
```

_**Note**_: a Makefile is also provided in the repository to help testing the `docker run` syntax. The Makefile contains a special function `make env_run` leveraging the exact same `.env` file expected by **docker-compose**. Just make sure the `.env` file is located right next to the `Makefile` to make it work.

## Testing with curl

* Listing files:
```sh
curl -v --ssl --insecure --disable-epsv ftp://my-ftp-server.com:21 -u user:pwd
```
* Uploading files:
```sh
curl -v -T </path/to/file> --ssl --insecure --disable-epsv ftp://my-ftp-server.com:21 -u user:pwd
```
