# EDB Postgres Replication Server (EPRS) Template

## Introduction
This `docker-compose` instance will set up an EPRS 7 cluster with Multi-master continuous/streaming replication (MMR) between nodes.  It employs `pgbench` tables and serves as a template to more complex arrangements.

## Setup
* `docker-compose build`
  * Note that you will need an image with EDB Postgres Advanced Server built on CentOS 7 to be able to use the included `docker-compose.yml` file out-of-the-box.
  * The `docker-compose.yml` file can be altered to be compatible with CentOS 6 if the `command:` element is changed to something more generic, like `tail -f /var/log/yum.log`
* `docker-compose up -d`
* Run `01_eprs_server_setup.sh` on **all 3 resulting nodes** to set up EPRS and prepare the databases
* Run `02_eprs_admin_password.sh` on the leader node (`eprs-leader`), and enter `adminedb` as the password
* Run `03_eprs_subscription.sh` to activate replication
* Enjoy!

## References
More explations (and a YouTube demo video) can be found on [Raghav's blog](https://www.raghavt.com/blog/2019/04/28/3-node-multi-master-replication-with-edb-postgres-replication-server-7.beta/)
