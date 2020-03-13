#!/bin/bash

# Run this EPRS setup script on all relevant servers

export PGVERSION=10
export hostip=`hostname -i`
export EPRS_HOME=/usr/edb/rs-7.0
ln -s ${EPRS_HOME}/client/bin/runRepCLI.sh /usr/local/bin

sed -i -e "s/wal_level=hot_standby/wal_level=logical/" /var/lib/edb/as${PGVERSION}/data/postgresql.conf

cat <<EOT >> /var/lib/edb/as${PGVERSION}/data/postgresql.conf
max_wal_senders = 10
max_replication_slots = 10
track_commit_timestamp = on
EOT

if [[ `cat /etc/*release* | grep "^cpe" | cut -f5 -d ':'` -eq 6 ]]
then
  service edb-as-${PGVERSION} start
  ${EPRS_HOME}/server/bin/runServer.sh --host ${hostip} --config ${EPRS_HOME}/server/etc &
else
  systemctl start edb-as-${PGVERSION}
  sed -i "s/#ngen.server.host=localhost/ngen.server.host=${hostip}/" ${EPRS_HOME}/server/etc/application.properties
  systemctl start edb-rs-server
fi
psql -c "alter user enterprisedb identified by adminedb"
pgbench -i
