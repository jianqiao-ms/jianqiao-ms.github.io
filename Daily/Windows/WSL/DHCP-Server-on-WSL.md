> Example environment  
> System : WSL1 OS build 18362.592  
> WSL Distribution: CentOS-7.6.1810  
> Kea Version: 1.16.1



# Introduction

Refer [Kea page on ISC](https://www.isc.org/kea/)

> Kea. Modern, open source DHCPv4 & DHCPv6 server
>
> ISC distributes and maintains TWO open source, standards-based DHCP server distributions: Kea DHCP and ISC DHCP. Kea includes all the most-requested features, is far newer, and is designed for a more modern network environment.



# Installation

Refer [cloudsmith.io](https://cloudsmith.io/~isc/repos/kea-1-6/setup/#formats-rpm)

```bash
$ curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/setup/bash.rpm.sh' \
  | sudo bash
  
$ yum insatll -y kea
```



# Configuration

Refer [Administrator Reference Manual (ARM)](https://kea.readthedocs.io/en/latest/arm/config.html)