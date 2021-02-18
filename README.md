ProxySQL playground
===================

## TL;DR starup

```sh
docker-compose up -d
./setup-proxysqlmonitor.sh
```

## Setup

This is a simple approach to do some basic tests locally with ProxySQL.

Contents:
- mysql 8.0.22-13 (percona server)
- proxysql 2.0.17

mysql is reachable on `mysql.sysbench.test` on port `3306`

proxsql is reachable on `proxysql.sysbench.test` on port `3306`.
the admin part of proxysql is `proxysql.sysbench.test` on port `6032`

## MySQL

MySQL has 2 regular users, `root` and `bench`, the proxysqlmonitor user is
created with a separate shell script on first startup.

connect:

```sh
mysql -uroot -ptoor -hmysql.sysbench.test
```

For proxysql its the same but with another host

## ProxySQL Admin

To connect to the ProxySQL admin you can use:

```sh
mysql -uradmin -pradmin -hproxysql.sysbench.test -P6032 --prompt='ProxyAdmin> '
```

## Caveats

To make sure ProxySQL can connect to MySQL we had to "disable" the new and
improved password hashing `caching_sha2_password` and use
`mysql_native_password`.

There were also some issues with
`performance_schema_session_connect_attrs_size` which default to `512` in the
container. This caused some warnings because the connection attrs from ProxySQL
just exceeded these.

```
mysql_1     | 2021-02-16T09:30:48.843787Z 24 [Warning] [MY-010288] [Server] Connection attributes of length 554 were truncated (60 bytes lost) for connection 24, user bench@172.22.0.3 (as bench), auth: yes
mysql_1     | 2021-02-16T09:30:48.844525Z 25 [Warning] [MY-010288] [Server] Connection attributes of length 554 were truncated (60 bytes lost) for connection 25, user bench@172.22.0.3 (as bench), auth: yes
mysql_1     | 2021-02-16T09:30:48.850774Z 31 [Warning] [MY-010288] [Server] Connection attributes of length 554 were truncated (60 bytes lost) for connection 31, user bench@172.22.0.3 (as bench), auth: yes
```

So therefore the increase to `4096` because we can.

## Basic Performance Question

[Read here](https://blog.herecura.eu/blog/2021-02-18-proxying-mysql-setting-things-up/)
