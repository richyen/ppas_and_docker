FROM centos6/epas12:latest
MAINTAINER richard.yen@enterprisedb.com

# This Dockerfile assumes the PG/EPAS version in the base image was installed using EDB Yum repo

# run update and install required packages.
RUN yum -y install which edb-as12-server-sslutils openssl-devel edb-as12-server-edb-modules\
 && yum -y install epel-release centos-release-scl rh-python36 \
 && yum -y install edb-pem-agent \
 && service edb-as-12 start

# Create script to register agent
RUN echo "PGPASSWORD=abc123 /usr/edb/pem/agent/bin/pemworker --register-agent --pem-server %%PEM_SERVER_IP%% --pem-port 5432 --pem-user enterprisedb --display-name %%AGENT_NAME%%" >> /tmp/register_pem_agent.sh

RUN mkdir -p /var/lib/edb/.pem \
 && chown enterprisedb:enterprisedb /var/lib/edb/.pem \
 && chmod 700 /var/lib/edb/.pem \
 && cp /usr/edb/pem/agent/etc/agent.cfg.sample /usr/edb/pem/agent/etc/agent.cfg \
 && chown enterprisedb:enterprisedb /usr/edb/pem/agent/etc/agent.cfg \
 && chmod 755 /tmp/register_pem_agent.sh
