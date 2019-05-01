#!/bin/bash
eprs_client -joinnetwork -servername leaderNode -host 10.111.221.13 -port 8082 -user admin
eprs_client -adddb \
            -servername leaderNode \
            -dbid node1db \
            -dbtype enterprisedb \
            -dbhost 10.111.221.13 \
            -dbport 5444 \
            -dbuser enterprisedb \
            -dbpassword N7Ryv4TGFInSPnvctbilyg== \
            -database edb \
            -user admin

eprs_client -createpub \
            -pubname samplepub \
            -servername leaderNode \
            -dbid node1db \
            -nodetype RW \
            -tables public.rep_test \
            -user admin

eprs_client -joinpub -servername remoteNode2 -dbid node2db -nodetype RW -pubname samplepub -user admin

eprs_client -startsnapshot -pubname samplepub -dbid node2db -user admin

eprs_client -startstreaming -pubname samplepub -dbid node2db -user admin
