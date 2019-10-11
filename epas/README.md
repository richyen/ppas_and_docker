Collection of Dockerfiles to build images for EDB Postgres Advanced Server (EPAS)

# Getting Started
* Some of these Dockerfiles are dependent upon access to the EDB Yum repository; you'll need to first get access to those.  Email `support@enterprisedb.com` for access
* Make sure your `~/.bash_profile` has the necessary variables in your environment (unless you're comfortable seeing your passwords in plaintext):
```
export YUMUSERNAME="my-yum-username"
export YUMPASSWORD="1234567890abcdef1234567890"
```
* Once you get your login/password, you can build images based off EDB products:
  * Edit `docker-compose.yml` and set your Yum credentials and desired EPAS version
  * `docker-compose build`
  * `docker-compose up`
