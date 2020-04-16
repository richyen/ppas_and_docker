#!/bin/bash

use_trigger=0
host_list="mdn pub1"
PGMAJOR=10
PGDATA="/var/lib/edb/as${PGMAJOR}"
XDB_VERSION=6.2
sed -i "s/^wal_level.*/wal_level = logical/" ${PGDATA}/data/postgresql.conf
sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" ${PGDATA}/data/postgresql.conf
sed -i "s/^#track_commit_timestamp.*/track_commit_timestamp = on/" ${PGDATA}/data/postgresql.conf
echo "host replication enterprisedb 0.0.0.0/0 trust" >> ${PGDATA}/data/pg_hba.conf
service edb-as-${PGMAJOR} restart

if [[ `hostname` == 'mdn' ]]
then
  printf "\e[0;33m>>> SETTING UP MASTER DATABASE\n\e[0m"
  if [[ use_trigger -eq 1 ]]
  then
    # Switch to trigger-based replication
    sed -i "s/changesetlogmode W/changesetlogmode T/" /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh
  fi
  sed -i "s/^export OTHER_MASTER_IPS.*/export OTHER_MASTER_IPS='${host_list/mdn /}'/" /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh

  printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
  /usr/ppas-xdb-${XDB_VERSION}/bin/build_xdb_mmr_publication.sh

  printf "\e[0;33m>>> DONE, VERIFYING REPLICATION\n\e[0m"
  for i in ${host_list}
  do
    psql -h ${i} -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
  done
  psql -c "UPDATE pgbench_accounts SET filler=md5(random()::text) WHERE aid = 1" edb
  sleep 10
  for i in ${host_list}
  do
    psql -h ${i} -c "SELECT * FROM pgbench_accounts WHERE aid = 1" edb
  done

  printf "\e[0;33m>>> xDB Status\n\e[0m"
  # Check uptime
  java -jar /usr/ppas-xdb-${XDB_VERSION}/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-${XDB_VERSION}/etc/xdb_repsvrfile.conf -uptime
fi

tail -f /dev/null
