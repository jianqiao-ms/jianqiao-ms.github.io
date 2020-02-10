> Example environment
System : ubuntu 16
Specific "/data/mysql" the root path of nginx virtual server. Virtual server's root path should place here usually.


# [Installing Percona Server from Percona apt repository](https://www.percona.com/doc/percona-server/5.7/installation/apt_repo.html#installing-percona-server-from-percona-apt-repository)

```bash
$ wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
$ dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
$ apt-get update
$ apt-get install percona-server-server-5.7
```
