#!/bin/bash

# Run this admin setup script on leader node
export hostip=`hostname -i`
export nodenum=`echo ${hostip} | cut -f 4 -d'.'`

runRepCLI.sh -joinnetwork -servername node${nodenum} -host ${hostip} -port 8082
runRepCLI.sh -setadminpassword -savepassword

# This is only necessary if the password in 03_eprs_subscription.sh has the wrong password
# echo 'adminedb' >/tmp/dbpassword.txt
# runRepCLI.sh -encrypt -input /tmp/dbpassword.txt -output /tmp/dbpassword.out -user admin
