#!/bin/bash

# Run this admin setup script on leader node
export hostip=`hostname -i`
export nodenum=`echo ${hostip} | cut -f 4 -d'.'`
export eprs_client="/usr/edb/rs-7.0/client/bin/runRepCLI.sh"

${eprs_client} -joinnetwork -servername node${nodenum} -host ${hostip} -port 8082
${eprs_client} -setadminpassword -savepassword

# This is only necessary if the password in 03_eprs_subscription.sh has the wrong password
# echo 'adminedb' >/tmp/dbpassword.txt
# ${eprs_client} -encrypt -input /tmp/dbpassword.txt -output /tmp/dbpassword.out -user admin
