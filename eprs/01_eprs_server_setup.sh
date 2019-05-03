#!/bin/bash

# Run this EPRS setup script on all relevant servers

export PGVERSION=10
export hostip=`hostname -i`
export eprs_client="/usr/edb/rs-7.0/client/bin/runRepCLI.sh"

sed -i -e "s/wal_level=hot_standby/wal_level=logical/" /var/lib/edb/as${PGVERSION}/data/postgresql.conf

cat <<EOT >> /var/lib/edb/as${PGVERSION}/data/postgresql.conf
max_wal_senders = 10
max_replication_slots = 10
track_commit_timestamp = on
EOT

if [[ `cat /etc/*release* | grep "^cpe" | cut -f5 -d ':'` -eq 6 ]]
then
  service edb-as-${PGVERSION} start
  /usr/edb/rs-7.0/server/bin/runServer.sh --host ${hostip} --config /usr/edb/rs-7.0/server/etc &
else
  systemctl start edb-as-${PGVERSION}
  sed -i "s/ngen.server.host=localhost/ngen.server.host=${hostip}/" /usr/edb/rs-7.0/server/etc/application.properties
  systemctl start edb-rs-server
fi
psql -c "alter user enterprisedb identified by adminedb"
pgbench -i
