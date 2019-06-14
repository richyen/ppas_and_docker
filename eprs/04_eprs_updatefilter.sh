#!/bin/bash

### Simple script to update a table filter and re-apply it to the cluster

# Run this EPRS filter alteration script on the leader node
export hostip=`hostname -i`
export nodenum=`echo ${hostip} | cut -f 4 -d'.'`
export subnet=`echo ${hostip} | cut -f 1-3 -d'.'`
export pubname="samplepub"
export xdbadmin="admin"

runRepCLI.sh -updatefilter pgbaid -filtertype R -pubname ${pubname} -filtertable public.pgbench_accounts -filterrule 'aid in (10)' -user ${xdbadmin}

for n in `seq 12 13`
do
  runRepCLI.sh -enablefilter pgbaid -pubname ${pubname} -targetdbid node${n}db -user ${xdbadmin}
  runRepCLI.sh -startsnapshot -pubname ${pubname} -dbid node${n}db -user ${xdbadmin}
done
