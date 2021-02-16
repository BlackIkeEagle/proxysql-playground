#!/usr/bin/env bash

sysbench \
    /usr/share/sysbench/oltp_read_only.lua \
    --threads=$(nproc) \
    --tables=10 \
    --table-size=1000000 \
    --mysql-host=mysql.sysbench.test \
    --mysql-port=3306 \
    --mysql-user=bench \
    --mysql-password=bench \
    --mysql-db=bench \
    --mysql-storage-engine=INNODB \
    prepare
