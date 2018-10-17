FROM epas10:latest
MAINTAINER richard.yen@enterprisedb.com

### Assuming base image has edb.repo installed
### If not, then un-comment the following lines and build with --build-args YUMUSERNAME=*** --build-args YUMPASSWORD=***

#ARG YUMUSERNAME
#ARG YUMPASSWORD
#RUN rpm -ivh https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
#RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

ENV BART_VERSION=2.1
ENV BART_PATH="/usr/edb/bart"

# make BART binary available in $PATH
RUN echo "export PATH=${BART_PATH}/bin:\${PATH}" >> /etc/profile.d/pg_env.sh

# install required packages
RUN yum -y install yum-plugin-ovl
RUN yum -y install epel-release
RUN yum -y install boost*
RUN yum -y --enablerepo=edbas10 install vim tar edb-as10-server-libs sudo openssh-server
RUN yum -y --enablerepo=enterprisedb-tools install edb-bart

# set custom BART config
COPY bart.cfg ${BART_PATH}/etc/bart.cfg
RUN mkdir -p /tmp/bart_backups/epas/archived_wals
RUN chown -R enterprisedb:enterprisedb /tmp/bart_backups/epas
RUN sed -i "s/^#archive_mode.*/archive_mode = on/" /var/lib/edb/as10/data/postgresql.conf
RUN sed -i "s/^#archive_command.*/archive_command = 'cp %p \/tmp\/bart_backups\/epas\/archived_wals\/%f'/" /var/lib/edb/as10/data/postgresql.conf
RUN sed -i "s/repuser/all/" /var/lib/edb/as10/data/pg_hba.conf

# initialize BART
RUN sudo -u enterprisedb /usr/edb/bart/bin/bart init

# install test script
COPY bart_test.sh /tmp/bart_test.sh

CMD sudo -u enterprisedb /usr/edb/bart/bin/bart-scanner -d --daemon && service sshd start && tail -f /var/log/yum.log
