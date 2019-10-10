#!/bin/bash

printf "\e[0;33m==== Building containers for xDB cluster ====\n\e[0m"
PGMAJOR=10
PGDATA="/var/lib/edb/as${PGMAJOR}"
sed -i "s/^wal_level.*/wal_level = logical/" ${PGDATA}/data/postgresql.conf
sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" ${PGDATA}/data/postgresql.conf
sed -i "s/^#track_commit_timestamp.*/track_commit_timestamp = on/" ${PGDATA}/data/postgresql.conf
echo "host replication enterprisedb 0.0.0.0/0 trust" >> ${PGDATA}/data/pg_hba.conf
service edb-as-${PGMAJOR} restart
tail -f /dev/null
