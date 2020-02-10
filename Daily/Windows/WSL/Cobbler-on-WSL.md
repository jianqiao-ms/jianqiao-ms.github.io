> Example environment  
> System : WSL1 OS build 18362.592  
> WSL Distribution: CentOS-7.6.1810

# Cobbler on WSL V1

## Installation

Refer to [Install Guide](https://cobbler.readthedocs.io/en/latest/installation-guide.html) [2020-02-04]

Deb packages not found for WSL ubuntu, this article in aimed to install from source.



#### Prerequirements

My WSL distributed system is ubuntu, so refer to the [DEB](https://cobbler.readthedocs.io/en/latest/installation-guide.html#deb) section

As mentioned, dependencies list as below(with install command):

```bash
$ yum makecache fast && \
    yum install -y epel-release && \
    yum install -y https://repo.ius.io/ius-release-el7.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum makecache fast
$ yum install -y cobbler cobbler-web

$ a2enmod proxy proxy_http rewrite

$ ln -snf /srv/tftp /var/lib/tftp
$ chown www-data /var/lib/cobbler/webui_sessions
```



### Install

```bash
$ sudo mkdir -p /opt/source && cd source
$ git clone https://github.com/cobbler/cobbler.git
$ cd cobbler
$ make install
```

