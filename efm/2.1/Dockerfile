FROM epas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD

ENV PGMAJOR=9.5
ENV INSTALLDIR=/usr/efm-2.1

RUN rpm -ivh https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

# run update and install require packages.
RUN yum -y install yum-plugin-ovl
RUN yum -y update
RUN yum -y --enablerepo=enterprisedb-tools install which efm21 java-1.7.0-openjdk vim

RUN mkdir -p /opt/backup
RUN mkdir -p /var/lib/ppas/${PGMAJOR}/wal_archive
RUN chown -R enterprisedb:enterprisedb /var/lib/ppas
RUN chown enterprisedb:enterprisedb /opt/backup

# copy EFM files into place
COPY set_as_master.sh  ${INSTALLDIR}/bin/set_as_master.sh
COPY set_as_standby.sh ${INSTALLDIR}/bin/set_as_standby.sh
COPY set_as_witness.sh ${INSTALLDIR}/bin/set_as_witness.sh
RUN sed -i "s/PGMAJOR=null/PGMAJOR=${PGMAJOR}/g" ${INSTALLDIR}/bin/set_as_master.sh
RUN sed -i "s/PGMAJOR=null/PGMAJOR=${PGMAJOR}/g" ${INSTALLDIR}/bin/set_as_standby.sh

COPY efm.properties /etc/efm-2.1/efm.properties
RUN cp /etc/efm-2.1/efm.nodes.in /etc/efm-2.1/efm.nodes

# expose ports.
EXPOSE 5431 5430

CMD service ppas-${PGMAJOR} restart && tail -F /var/log/messages
