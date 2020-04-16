FROM centos6/epas10:latest
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD

ENV PGMAJOR=10
ENV SERVICE_NAME=edb-as-${PGMAJOR}
ENV EFM_VER=3.1
ENV INSTALLDIR=/usr/edb/efm-${EFM_VER}

## Need this if your base image doesn't have edb.repo installed
# RUN rpm -ivh https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
# RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo
RUN yum -y upgrade edb-repo

# run update and install require packages.
RUN yum -y install yum-plugin-ovl
RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install which edb-efm${EFM_VER/./} java-1.8.0-openjdk vim

# copy EFM files into place
COPY set_as_master.sh  ${INSTALLDIR}/bin/set_as_master.sh
COPY set_as_standby.sh ${INSTALLDIR}/bin/set_as_standby.sh
COPY set_as_witness.sh ${INSTALLDIR}/bin/set_as_witness.sh
RUN sed -i "s/pgmajor_placeholder/${PGMAJOR}/g" ${INSTALLDIR}/bin/set_as_standby.sh
RUN sed -i "s/efm_ver_placeholder/${EFM_VER}/g" ${INSTALLDIR}/bin/set_as_master.sh
RUN sed -i "s/efm_ver_placeholder/${EFM_VER}/g" ${INSTALLDIR}/bin/set_as_standby.sh
RUN sed -i "s/efm_ver_placeholder/${EFM_VER}/g" ${INSTALLDIR}/bin/set_as_witness.sh
RUN sed -i "s/service_name_placeholder/${SERVICE_NAME}/g" ${INSTALLDIR}/bin/set_as_master.sh
RUN sed -i "s/service_name_placeholder/${SERVICE_NAME}/g" ${INSTALLDIR}/bin/set_as_standby.sh

RUN cp /etc/edb/efm-${EFM_VER}/efm.properties.in /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.bin=/db.bin=\/usr\/edb\/as${PGMAJOR}\/bin/g"       /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.user=/db.user=enterprisedb/"                       /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.port=/db.port=5432/"                               /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.database=/db.database=edb/"                        /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.service\.owner=/db.service.owner=enterprisedb/"    /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/user\.email=/user.email=richard.yen@enterprisedb.com/" /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/bind\.address=.*/bind.address=127.0.0.1:5430/"         /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/admin\.port=.*/admin.port=5431/"                       /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/is\.witness=.*/is.witness=false/"                      /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/auto\.allow\.hosts=.*/auto.allow.hosts=true/"          /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.password\.encrypted=/db.password.encrypted=4bcdcec94b6e66deec70559f904f7e52/"    /etc/edb/efm-${EFM_VER}/efm.properties
RUN sed -i "s/db\.recovery\.conf\.dir=/db.recovery.conf.dir=\/var\/lib\/edb\/as${PGMAJOR}\/data/g" /etc/edb/efm-${EFM_VER}/efm.properties

RUN cp /etc/edb/efm-${EFM_VER}/efm.nodes.in /etc/edb/efm-${EFM_VER}/efm.nodes
RUN chmod 766 /etc/edb/efm-${EFM_VER}/efm.nodes

RUN mkdir -p /opt/backup
RUN mkdir -p /var/lib/edb/as${PGMAJOR}/wal_archive
RUN chown -R enterprisedb:enterprisedb /var/lib/edb
RUN chown -R enterprisedb:enterprisedb /opt/backup

# expose ports.
EXPOSE 5431 5430

CMD service ${SERVICE_NAME} restart && tail -F /var/log/messages
