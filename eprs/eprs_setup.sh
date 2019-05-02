#!/bin/bash
node_num=3
host_ip="10.111.221.1${node_num}"
export eprs_client="/usr/edb/rs-7.0/client/bin/runRepCLI.sh"
${eprs_client} -joinnetwork -servername Node${node_num} -host ${host_ip} -port 8082 -user admin
${eprs_client} -adddb \
            -servername Node${node_num} \
            -dbid node${node_num}db \
            -dbtype enterprisedb \
            -dbhost ${host_ip} \
            -dbport 5444 \
            -dbuser enterprisedb \
            -dbpassword N7Ryv4TGFInSPnvctbilyg== \
            -database edb \
            -user admin

${eprs_client} -createpub \
            -pubname samplepub \
            -servername Node${node_num} \
            -dbid node${node_num}db \
            -nodetype RW \
            -tables public.rep_test \
            -user admin

${eprs_client} -joinpub -servername remoteNode${node_num} -dbid node${node_num}db -nodetype RW -pubname samplepub -user admin

${eprs_client} -startsnapshot -pubname samplepub -dbid node${node_num}db -user admin

${eprs_client} -startstreaming -pubname samplepub -dbid node${node_num}db -user admin
