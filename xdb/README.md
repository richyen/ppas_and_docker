Simple Docker image for EnterpriseDB xDB on EDB Postgres Advanced Server (EPAS)

###Getting Started
1. Be sure to build an EPAS image from which this Dockerfile can build.  If you need help with that, you can visit the `../epas` folder
1. Build image with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "xdb6:latest" .`
1. Start up the cluster with `docker-compose up`
1. Test and verify your replication is working
