#!/bin/bash

NUM_AGENTS=2

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing PEM cluster ====\n\e[0m"
	docker rm -f pem-server
  for ((i=1;i<=${NUM_AGENTS};i++))
  do
    docker rm -f pem-agent${i}
  done
  exit 0
fi

# Create Containers
printf "\e[0;33m==== Building containers for PEM cluster ====\n\e[0m"
printf "\e[0;33m>>> SETTING UP PEM SERVER\n\e[0m"
docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=pem-server --detach=true --name=pem-server pemserver:latest
MASTER_IP=`docker exec -it pem-server ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
docker exec -t pem-server sed -i "s/%%PEM_SERVER_IP%%/pem-server/" /tmp/configure_pem_server.sh
# docker exec -t pem-server sed -i "s/%%PEM_SERVER_IP%%/${MASTER_IP}/" /tmp/configure_pem_server.sh
docker exec -t pem-server bash --login -c "/tmp/configure_pem_server.sh"

for ((i=1;i<=${NUM_AGENTS};i++))
do
  C_NAME="pem-agent${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} pemagent:latest
  docker exec -t pem-agent${i} sed -i "s/pemagent/pemworker/" /tmp/register_pem_agent.sh
  docker exec -t pem-agent${i} sed -i "s/%%PEM_SERVER_IP%%/${MASTER_IP}/" /tmp/register_pem_agent.sh
  docker exec -t pem-agent${i} sed -i "s/%%AGENT_NAME%%/pemagent${i}/" /tmp/register_pem_agent.sh
  docker exec -tu enterprisedb pem-agent${i} bash --login -c "/tmp/register_pem_agent.sh"
  docker exec pem-agent${i} service pemagent start
done

if [[ `uname` = 'Darwin' ]]
then
  printf "\e[0;33m>>> LAUNCHING PEM CONSOLE\n\e[0m"
  dockerip="127.0.0.1"
  # If using docker-machine or boot2docker, then uncomment below
  # dockerip=`docker-machine ip docker-vm`;
  port=`docker ps -f name=pem-server | grep 8443 | sed -e 's/.*0.0.0.0:\(.*\)->8443.*/\1/'`
  open -a Safari https://${dockerip}:${port}/pem
fi
