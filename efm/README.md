Simple Docker image for EnterpriseDB Failover Manager 3.3 on EDB Postgres Advanced Server (EPAS)

###Getting Started
1. Update repos with a valid EDB YUM repo login/password
1. Build image with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "efm:latest" .`
1. `cd` into `efm_demo` and issue `docker-compose up` to get a sample cluster up and running
