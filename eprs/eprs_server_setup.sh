#!/bin/bash

export PGVERSION=10
sed -i -e "s/wal_level=hot_standby/wal_level=logical/" /var/lib/edb/as${PGVERSION}/data/postgresql.conf 

cat <<EOT >> /var/lib/edb/as${PGVERSION}/data/postgresql.conf 
max_wal_senders = 10 
max_replication_slots = 10
track_commit_timestamp = on
EOT

if [[ `cat /etc/*release* | grep cpe | cut -f5 -d ':'` -eq 6 ]]
then
  service edb-as-${PGVERSION} start
  #/usr/edb/rs-7.0/server/bin/runServer.sh --host 10.111.221.11 --config /usr/edb/rs-7.0/server/etc &
else
  systemctl start edb-as-${PGVERSION}
  #systemctl start edb-rs-server
fi
psql -c "alter user enterprisedb identified by adminedb"
pgbench -i


#eprs_client -setadminpassword -savepassword
echo 'adminedb' >/tmp/dbpassword.txt
#/usr/edb/rs-7.0/client/bin/runRepCLI.sh -encrypt -input /tmp/dbpassword.txt -output /tmp/dbpassword.out

