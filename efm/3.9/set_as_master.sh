#!/bin/bash

SERVICE_NAME=service_name_placeholder
EFM_VER=efm_ver_placeholder

# Make sure Postgres is running
service ${SERVICE_NAME} stop
service ${SERVICE_NAME} start

psql edb enterprisedb -c "create user repuser replication"

sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/edb/efm-${EFM_VER}/efm.properties
service edb-efm-${EFM_VER} start
