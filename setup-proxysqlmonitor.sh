#!/usr/bin/env bash

mysql -uroot -ptoor -hmysql.sysbench.test mysql -e "CREATE USER 'proxysqlmonitor'@'%' IDENTIFIED BY 'proxysqlmonitor'; GRANT REPLICATION CLIENT ON *.* TO 'proxysqlmonitor'@'%';"
