#!/bin/bash

XDB_VERSION=6.2
XDB_PATH="/usr/ppas-xdb-${XDB_VERSION}"
ENCRYPTED_ORA_PASS="deIuKoLKPi4=" # Plaintext password is "oracle"

if [[ `hostname` == 'oracle' ]]
then
  /usr/sbin/startup.sh
  sqlplus -S system/oracle@//localhost:1521/XE < /docker/oracle_files/load_oracle_test_data.sql
  echo "update test_data set first_name = 'my_name_changed' where id = 10000;" | sqlplus -S system/oracle@//localhost:1521/XE
else
  cp /docker/oracle_files/ojdbc6.jar ${XDB_PATH}/lib/jdbc/ojdbc6.jar
  rm -f /var/run/edb-xdbpubserver/edb-xdbpubserver.pid
  rm -f /var/run/edb-xdbsubserver/edb-xdbsubserver.pid
  service edb-as-10 start
  service edb-xdbpubserver start
  service edb-xdbsubserver start

  printf "\e[0;33m>>> SETTING UP REPLICATION\n\e[0m"
  java -jar ${XDB_PATH}/bin/edb-repcli.jar -addpubdb -repsvrfile ${XDB_PATH}/etc/xdb_repsvrfile.conf -dbtype oracle -dbhost oracle -dbuser system -dbpassword ${ENCRYPTED_ORA_PASS} -database XE -dbport 1521
  java -jar ${XDB_PATH}/bin/edb-repcli.jar -createpub xdbtest -repsvrfile ${XDB_PATH}/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables SYSTEM.TEST_DATA SYSTEM.TEST_DATAB SYSTEM.TEST_DATAC SYSTEM.TEST_DATAD -repgrouptype S
  java -jar ${XDB_PATH}/bin/edb-repcli.jar -addsubdb -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf -dbtype enterprisedb -dbhost epas -dbuser enterprisedb -dbpassword `cat ${XDB_PATH}/etc/xdb_subsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -dbport 5432 -repgrouptype S
  SUBDB_ID=`java -jar ${XDB_PATH}/bin/edb-repcli.jar -printsubdbids -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf | tail -n 1 | awk '{ printf("%d",$1) }'` # repcli does something funky with the output, so pipe it through awk to clean it up
  java -jar ${XDB_PATH}/bin/edb-repcli.jar -createsub xdbsub -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf -subdbid ${SUBDB_ID} -pubsvrfile ${XDB_PATH}/etc/xdb_repsvrfile.conf -pubname xdbtest
  java -jar ${XDB_PATH}/bin/edb-repcli.jar -dosnapshot xdbsub -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf
  # java -jar ${XDB_PATH}/bin/edb-repcli.jar -confschedule xdbsub -subsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf -realtime 5

  printf "\e[0;33m>>> VERIFYING REPLICATION\n\e[0m"
  psql -c "SELECT * FROM system.test_data WHERE id = 10000" edb
  sleep 5
  java -jar ${XDB_PATH}/bin/edb-repcli.jar -dosynchronize xdbsub -repsvrfile ${XDB_PATH}/etc/xdb_subsvrfile.conf
  sleep 10
  psql -c "SELECT * FROM system.test_data WHERE id = 10000" edb
fi

tail -f /dev/null
