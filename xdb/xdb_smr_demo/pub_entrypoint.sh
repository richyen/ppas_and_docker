#!/bin/bash

XDB_VERSION=6.2

ln -s /usr/ppas-xdb-${XDB_VERSION} /usr/ppas-xdb-6.0
printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
# Uncomment below to use WAL-based replication
# sed -i "s/addpubdb/addpubdb -changesetlogmode W/" /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_smr_publication.sh
service edb-as-10 start
/usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_smr_publication.sh sub

psql -h pub -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
psql -h sub -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
psql -h pub -c "UPDATE pgbench_accounts SET filler = md5(random()) WHERE aid = 1" edb
java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -dosynchronize xdbsub -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf
psql -h pub -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
psql -h sub -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb

# Uncomment below to set up synchronization schedule
# java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -confschedule xdbsub -jobtype s -realtime 1 -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_subsvrfile.conf
tail -f /dev/null
