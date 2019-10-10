Simple Docker image for EnterpriseDB Postgres Enterprise Manager (PEM) on EDB Postgres Advanced Server (EPAS)

###Getting Started
1. Be sure to build an EPAS image from which this Dockerfile can build.  If you need help with that, you can visit the `../epas` folder
1. Build agent image from the `agent/` directory with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "pemagent:latest" .`
1. Build server image from the `server/` directory with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "pemserver:latest" .`
1. Start up the cluster with `docker-compose up`
1. Test and verify the PEM Server is running by visiting `https://docker_ip_address:8443/pem`
1. Add and verify agents as desired
