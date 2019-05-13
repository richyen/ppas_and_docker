#!/bin/bash

for i in 9.5 9.6 10 11
do
  # Build new images
  R="docker-reg.ma.us.enterprisedb.com:5000"
  V=`echo $i | sed "s/\.//"`
  docker build --no-cache --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t ${R}/centos6/epas${V}:latest ${i}/. &
  docker build --no-cache --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t ${R}/centos7/epas${V}:latest ${i}/centos7/.

  # Set tags
  VF=`docker run -it --rm ${R}/centos7/epas${V}:latest psql --version`
  VN=`echo -n ${VF} | awk '{ print \$3 }' | sed "s/\r$//"`
  docker tag ${R}/centos6/epas${V}:latest ${R}/centos6/epas${V}:${VN}
  docker tag ${R}/centos7/epas${V}:latest ${R}/centos7/epas${V}:${VN}

  # Push images to registry
  docker push ${R}/centos6/epas${V}:latest
  docker push ${R}/centos6/epas${V}:${VN} &
  docker push ${R}/centos7/epas${V}:latest
  docker push ${R}/centos7/epas${V}:${VN} &
done
