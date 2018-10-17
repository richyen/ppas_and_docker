#!/bin/bash

### Please run this script as root
BART_PATH=/usr/edb/bart/bin

service edb-as-10 restart

for ((i=0;i<1000;i++));
do
  psql -c "CREATE TABLE table${i} (id serial primary key, first_name text not null default md5(random()::text), last_name text not null default md5(random()::text))" edb
	psql -c "INSERT INTO table${i} VALUES (generate_series(1,1000),default,default)" edb
done

sudo -u enterprisedb ${BART_PATH}/bart backup -s epas --backup-name full1

for ((i=0;i<1000;i++));
do
  psql -c "CREATE TABLE more_table${i} (id serial primary key, first_name text not null default md5(random()::text), last_name text not null default md5(random()::text))" edb
	psql -c "INSERT INTO more_table${i} VALUES (generate_series(1,1000),default,default)" edb
done

sudo -iu enterprisedb ${BART_PATH}/bart backup -s epas --backup-name inc1 --parent full1 -F p

sudo -u enterprisedb ${BART_PATH}/bart show-backups -s epas
