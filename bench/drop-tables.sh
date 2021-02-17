#!/usr/bin/env bash

for ((x=1; x<=10; x++)); do
    echo "$x"
    mysql -uroot -ptoor -hmysql.sysbench.test bench \
        -e "drop table sbtest$x"
done
