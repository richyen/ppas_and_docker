#!/bin/bash

EFM_VER=efm_ver_placeholder

sed -i "s/is.witness=.*/is.witness=true/" /etc/edb/efm-${EFM_VER}/efm.properties
sed -i "s/bind.address.*/bind.address=`hostname -i`:5430/" /etc/edb/efm-${EFM_VER}/efm.properties

service efm-${EFM_VER} start
