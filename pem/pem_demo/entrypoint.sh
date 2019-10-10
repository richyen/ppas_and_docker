#!/bin/bash

printf "\e[0;33m>>> SETTING UP PEM SERVER\n\e[0m"
if [[ `hostname` == 'pem-server' ]]
then
  sed -i "s/%%PEM_SERVER_IP%%/pem-server/" /tmp/configure_pem_server.sh
  /tmp/configure_pem_server.sh

  printf "\e[0;33m>>> INFORMATION FOR LAUNCHING PEM CONSOLE:\n\e[0m"
  echo "Open your browser to https://127.0.0.1:8443/pem"
else
  sed -i "s/pemagent/pemworker/" /tmp/register_pem_agent.sh
  sed -i "s/%%PEM_SERVER_IP%%/10.111.220.11/" /tmp/register_pem_agent.sh
  sed -i "s/%%AGENT_NAME%%/`hostname`/" /tmp/register_pem_agent.sh
  /tmp/register_pem_agent.sh
  service pemagent start
fi

tail -f /dev/null
