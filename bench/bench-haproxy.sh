#!/usr/bin/env bash

sysbench \
    /usr/share/sysbench/oltp_read_only.lua \
    --threads="$(($(nproc)/4))" \
    --tables=10 \
    --table-size=1000000 \
    --report-interval=5 \
    --rand-type=pareto \
    --forced-shutdown=1 \
    --time=300 \
    --events=0 \
    --point-selects=25 \
    --range_size=5 \
    --skip_trx=on \
    --percentile=95  \
    --mysql-host=haproxy.sysbench.test \
    --mysql-port=3306 \
    --mysql-user=bench \
    --mysql-password=bench \
    --mysql-db=bench \
    --mysql-storage-engine=INNODB \
    run
