#!/bin/bash

printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
PGMAJOR=10
PGDATA="/var/lib/edb/as${PGMAJOR}"
sed -i "s/^wal_level.*/wal_level = logical/" ${PGDATA}/data/postgresql.conf
sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" ${PGDATA}/data/postgresql.conf
sed -i "s/^#track_commit_timestamp.*/track_commit_timestamp = on/" ${PGDATA}/data/postgresql.conf
echo "host replication enterprisedb 0.0.0.0/0 trust" >> ${PGDATA}/data/pg_hba.conf
service edb-as-${PGMAJOR} restart

printf "\e[0;33m>>> SETTING UP MASTER DATABASE\n\e[0m"
sed -i "s/^export OTHER_MASTER_IPS.*/export OTHER_MASTER_IPS='10.111.220.12'/" /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh

printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
/usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh

printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
psql -h mdn -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
psql -h pub1 -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
psql -h mdn -c "UPDATE pgbench_accounts SET filler=md5(random()::text) WHERE aid = 1" edb
sleep 10
psql -h mdn -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
psql -h pub1 -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb

printf "\e[0;33m>>> xDB Status\n\e[0m"
# Check uptime
java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -uptime
tail -f /dev/null
