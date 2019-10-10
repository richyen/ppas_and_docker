#!/bin/bash

VER='3.3'
INSTALLDIR="/usr/edb/efm-${VER}"

if [[ `hostname` == 'primary' ]]
then
  ${INSTALLDIR}/bin/set_as_master.sh
  for i in 12 13
  do
    ${INSTALLDIR}/bin/efm allow-node efm 10.111.220.${i}
  done
  ${INSTALLDIR}/bin/efm allow-node efm witness
elif [[ `hostname` == 'witness' ]]
then
  echo 'primary:5430 ' >> /etc/edb/efm-${VER}/efm.nodes
  for i in 12 13
  do
    echo "10.111.220.${i}:5430 " >> /etc/edb/efm-${VER}/efm.nodes
  done
  sleep 15 # ugly, but saves me from writing a new file; give non-witnesses time to set up
  ${INSTALLDIR}/bin/set_as_witness.sh

  # Test to see if replication is working
  psql -h primary -ac 'CREATE TABLE efm_test (id serial primary key, filler text)' edb enterprisedb
  sleep 5
  for i in primary standby1 standby2
  do
    psql -h ${i} -ac 'SELECT * FROM efm_test' edb enterprisedb
  done
  psql -h primary -ac 'INSERT INTO efm_test VALUES (generate_series(1,10), md5(random()::text))' edb enterprisedb
  sleep 5
  for i in primary standby1 standby2
  do
    psql -h ${i} -ac 'SELECT * FROM efm_test' edb enterprisedb
  done

  # Check EFM cluster status
  ${INSTALLDIR}/bin/efm cluster-status efm
else
  # This is a standby server
  echo primary:5430 `hostname`:5430 >> /etc/edb/efm-${VER}/efm.nodes

  sleep 5 # ugly, but saves me from writing a new file; give primary some time to `allow-node`
  ${INSTALLDIR}/bin/set_as_standby.sh 10.111.220.11
fi

tail -f /dev/null
