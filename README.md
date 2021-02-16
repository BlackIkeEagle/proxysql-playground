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

## Performance Question

To get some baseline idea how the query performance is, we use sysbench
`/usr/share/sysbench/oltp_read_only.lua`. In the test the number of cpu threads
is divided by 4 to be sure we don't just push everything of a cliff and leave
enough headroom for all processes to operate normally.

In this case the test was run on a cpu with 12 threads so the sysbench number
of threads becomes 3.

To make a basic comparison we run the benchmark once on mysql and once on proxysql.

```sh
cd bench
./bench-mysql.sh > mysql.log
./bench-proxysql.sh > proxysql.log
```

### MySQL results

Full results: [mysql.log](bench/mysql.log)

```
sysbench 1.0.20 (using system LuaJIT 2.0.5)

Running the test with following options:
Number of threads: 3
Report intermediate results every 5 second(s)
Initializing random number generator from current time

Forcing shutdown in 301 seconds

Initializing worker threads...

Threads started!

[ 5s ] thds: 3 tps: 1175.75 qps: 34107.80 (r/w/o: 34107.80/0.00/0.00) lat (ms,95%): 3.36 err/s: 0.00 reconn/s: 0.00
...
[ 300s ] thds: 3 tps: 1011.43 qps: 29335.80 (r/w/o: 29335.80/0.00/0.00) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            9292064
        write:                           0
        other:                           0
        total:                           9292064
    transactions:                        320416 (1068.03 per sec.)
    queries:                             9292064 (30973.01 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.0037s
    total number of events:              320416

Latency (ms):
         min:                                    1.62
         avg:                                    2.81
         max:                                   19.01
         95th percentile:                        3.75
         sum:                               899519.67

Threads fairness:
    events (avg/stddev):           106805.3333/116.29
    execution time (avg/stddev):   299.8399/0.00

```

### ProxySQL results

Full results: [proxysql.log](bench/proxysql.log)

```
sysbench 1.0.20 (using system LuaJIT 2.0.5)

Running the test with following options:
Number of threads: 3
Report intermediate results every 5 second(s)
Initializing random number generator from current time

Forcing shutdown in 301 seconds

Initializing worker threads...

Threads started!

[ 5s ] thds: 3 tps: 444.45 qps: 12903.18 (r/w/o: 12903.18/0.00/0.00) lat (ms,95%): 8.43 err/s: 0.00 reconn/s: 0.00
...
[ 300s ] thds: 3 tps: 355.99 qps: 10330.48 (r/w/o: 10330.48/0.00/0.00) lat (ms,95%): 10.46 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            3331230
        write:                           0
        other:                           0
        total:                           3331230
    transactions:                        114870 (382.89 per sec.)
    queries:                             3331230 (11103.76 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.0075s
    total number of events:              114870

Latency (ms):
         min:                                    4.00
         avg:                                    7.83
         max:                                   97.53
         95th percentile:                       10.09
         sum:                               899772.54

Threads fairness:
    events (avg/stddev):           38290.0000/564.11
    execution time (avg/stddev):   299.9242/0.00

```

### 1/3 ?

So even when these are on the same machine, ProxySQL does only 1/3 of the queries / transactions ?

Am I doing something wrong?
