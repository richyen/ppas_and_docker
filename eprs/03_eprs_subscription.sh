#!/bin/bash

# Run this EPRS setup script on the leader node
export hostip=`hostname -i`
export nodenum=`echo ${hostip} | cut -f 4 -d'.'`
export subnet=`echo ${hostip} | cut -f 1-3 -d'.'`
export eprs_client="/usr/edb/rs-7.0/client/bin/runRepCLI.sh"

for n in `seq 12 13`
do
  ${eprs_client} -joinnetwork -servername node${n} -host ${subnet}.${n} -port 8082 -user admin
done

for n in `seq 11 13`
do
  ${eprs_client} -adddb \
            -servername node${n} \
            -dbid node${n}db \
            -dbtype enterprisedb \
            -dbhost ${subnet}.${n} \
            -dbport 5432 \
            -dbuser enterprisedb \
            -dbpassword N7Ryv4TGFInSPnvctbilyg== \
            -database edb \
            -user admin
done

${eprs_client} -createpub \
            -pubname samplepub \
            -servername node${nodenum} \
            -dbid node${nodenum}db \
            -nodetype RW \
            -tables public.pgbench_accounts \
            -user admin

for n in `seq 12 13`
do
  ${eprs_client} -joinpub -servername node${n} -dbid node${n}db -nodetype RW -pubname samplepub -user admin
  ${eprs_client} -startsnapshot -pubname samplepub -dbid node${n}db -user admin
  ${eprs_client} -startstreaming -pubname samplepub -dbid node${n}db -user admin
done
