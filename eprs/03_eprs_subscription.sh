#!/bin/bash

# Run this EPRS setup script on the leader node
export hostip=`hostname -i`
export nodenum=`echo ${hostip} | cut -f 4 -d'.'`
export subnet=`echo ${hostip} | cut -f 1-3 -d'.'`
export pubname="samplepub"
export xdbadmin="admin"

for n in `seq 12 13`
do
  runRepCLI.sh -joinnetwork -servername node${n} -host ${subnet}.${n} -port 8082 -user ${xdbadmin}
done

for n in `seq 11 13`
do
  # password is '${xdbadmin}edb'
  runRepCLI.sh -adddb \
            -servername node${n} \
            -dbid node${n}db \
            -dbtype enterprisedb \
            -dbhost ${subnet}.${n} \
            -dbport 5432 \
            -dbuser enterprisedb \
            -dbpassword N7Ryv4TGFInSPnvctbilyg== \
            -database edb \
            -user ${xdbadmin}
done

runRepCLI.sh -createpub \
            -pubname ${pubname} \
            -servername node${nodenum} \
            -dbid node${nodenum}db \
            -nodetype RW \
            -tables public.pgbench_accounts \
            -user ${xdbadmin}

# Uncomment this line if a filter is to be created
# runRepCLI.sh -addfilter pgbaid -filtertype R -pubname ${pubname} -filtertable public.pgbench_accounts -filterrule "aid in (10,20,30)" -user ${xdbadmin}

for n in `seq 12 13`
do
  runRepCLI.sh -joinpub -servername node${n} -dbid node${n}db -nodetype RW -pubname ${pubname} -user ${xdbadmin}
  # Uncomment this line if a filter is to be created
  # runRepCLI.sh -enablefilter pgbaid -pubname ${pubname} -targetdbid node${n}db -user ${xdbadmin}
  runRepCLI.sh -startsnapshot -pubname ${pubname} -dbid node${n}db -user ${xdbadmin}
done
sleep 10
for n in `seq 12 13`
do
  runRepCLI.sh -startstreaming -pubname ${pubname} -dbid node${n}db -user ${xdbadmin}
done
