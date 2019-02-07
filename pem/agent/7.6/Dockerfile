FROM epas10:latest
MAINTAINER richard.yen@enterprisedb.com

# This Dockerfile assumes the PG/EPAS version in the base image was installed using EDB Yum repo

# run update and install require packages.
RUN yum -y install which edb-as10-server-sslutils openssl-devel
RUN yum -y install epel-release centos-release-scl rh-python36
RUN yum -y --enablerepo=edbas10 --enablerepo=enterprisedb-dependencies --enablerepo=enterprisedb-tools install edb-pem-agent
RUN service edb-as-10 start


# Create script to register agent
RUN echo "/usr/edb/pem/agent/bin/pemworker --register-agent --pem-server %%PEM_SERVER_IP%% --pem-user enterprisedb --display-name %%AGENT_NAME%%" >> /tmp/register_pem_agent.sh
RUN chmod 755 /tmp/register_pem_agent.sh
