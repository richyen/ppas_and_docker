#!/bin/bash

VER='3.3'
IMAGE_NAME="efm:${VER}"
# INSTALLDIR="/usr/efm-${VER}"
INSTALLDIR="/usr/edb/efm-${VER}"
standby_name_list="standby1 standby2"

if [[ ${1} == 'destroy' ]]
then
	printf "\e[0;31m==== Destroying existing EFM cluster ====\n\e[0m"
  for i in master witness ${standby_name_list}
  do
    docker rm -f efm-${i} &
  done
  exit 0
fi

if [[ ${1} == 'image' ]]
then
  # Warn user before building image--give them a chance to stop and go set the passwords
	printf "\e[0;31mBuilding Image -- be sure to set passwords as necessary (sleeping for 10sec so you can abort)\n\e[0m"
	sleep 10

	printf "\e[0;33m==== Building new image for EFM cluster ====\n\e[0m"
  # Create Image
  PWD=`pwd`
  cd ${PWD}/${VER}/
  docker build --no-cache -t "${IMAGE_NAME}" .
	cd ${PWD}
fi

printf "\e[0;33m==== Building containers for EFM cluster ====\n\e[0m"
for i in master witness ${standby_name_list}
do
  C_NAME="efm-${i}"
  docker run --privileged=true --publish-all=true --interactive=false --tty=true -v /Users/${USER}/Desktop:/Desktop --hostname=${C_NAME} --detach=true --name=${C_NAME} ${IMAGE_NAME}
  # Uncomment and fill in license as needed
  # docker exec -t efm-${i} sed -i "s/efm.license=/efm.license=#####-#####-#####-#####-#####/" /etc/efm-2.1/efm.properties
done

# Set up master
printf "\e[0;32m>>> SETTING UP MASTER DATABASE\n\e[0m"
docker exec -it efm-master bash --login -c "${INSTALLDIR}/bin/set_as_master.sh"
MASTER_IP=`docker exec -it efm-master ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
list="${MASTER_IP}"

# Set up and register standby
printf "\e[0;32m>>> REGISTERING STANDBY INTO EFM\n\e[0m"
for i in ${standby_name_list}
do
STANDBY_IP=`docker exec -it efm-${i} ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
list="$list ${STANDBY_IP}"
# docker exec -t efm-master ${INSTALLDIR}/bin/efm add-node efm ${STANDBY_IP} 1
docker exec -t efm-master ${INSTALLDIR}/bin/efm allow-node efm ${STANDBY_IP}

# Set up standby
printf "\e[0;32m>>> SETTING UP STREAMING REPLICATION\n\e[0m"
if [[ $VER == "2.0" ]]
then
  docker exec -t efm-${i} bash --login -c "echo ${MASTER_IP}:5430 >> /etc/efm-${VER}/efm.nodes"
else
  docker exec -t efm-${i} bash --login -c "echo ${MASTER_IP}:5430 ${STANDBY_IP}:5430 >> /etc/edb/efm-${VER}/efm.nodes"
fi
docker exec -t efm-${i} bash --login -c "${INSTALLDIR}/bin/set_as_standby.sh ${MASTER_IP}"
done

# Verify replication is working
printf "\e[0;33m==== Verifying Streaming Replication Functionality ====\n\e[0m"
docker exec -t efm-master bash --login -c "psql -ac 'CREATE TABLE efm_test (id serial primary key, filler text)' edb enterprisedb"
sleep 5
for i in ${standby_name_list}
do
docker exec -t efm-${i} bash --login -c "psql -ac 'SELECT * FROM efm_test' edb enterprisedb"
done
docker exec -t efm-master bash --login -c "psql -ac 'INSERT INTO efm_test VALUES (generate_series(1,10), md5(random()::text))' edb enterprisedb"
sleep 5
for i in ${standby_name_list}
do
docker exec -t efm-${i} bash --login -c "psql -ac 'SELECT * FROM efm_test' edb enterprisedb"
done

# Register witness
printf "\e[0;32m>>> REGISTERING WITNESS INTO EFM\n\e[0m"
WITNESS_IP=`docker exec -it efm-witness ifconfig | grep Bcast | awk '{ print $2 }' | cut -f2 -d':' | xargs echo -n`
# docker exec -t efm-master ${INSTALLDIR}/bin/efm add-node efm ${WITNESS_IP} 1
docker exec -t efm-master ${INSTALLDIR}/bin/efm allow-node efm ${WITNESS_IP}

# Set up witness
printf "\e[0;32m>>> STARTING UP WITNESS EFM PROCESS\n\e[0m"
for HOSTIP in $list
do
docker exec -t efm-witness bash --login -c "echo '${HOSTIP}:5430 ' >> /etc/edb/efm-${VER}/efm.nodes"
done
docker exec -t efm-witness ${INSTALLDIR}/bin/set_as_witness.sh

# Show status
docker exec -it efm-master ${INSTALLDIR}/bin/efm cluster-status efm
