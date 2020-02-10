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

```json
# The whole configuration starts here.
{
    # DHCPv4 specific configuration starts here.
    "Dhcp4": {
        "next-server": "192.168.0.1",
        "boot-file-name": "pxelinux.0",
        "interfaces-config": {
            "interfaces": [ "eth3" ],
            "dhcp-socket-type": "raw"
        },
        "valid-lifetime": 4000,
        "renew-timer": 1000,
        "rebind-timer": 2000,
        "subnet4": [{
           "pools": [ { "pool": "192.168.0.2-192.168.0.200" } ],
           "subnet": "192.168.0.0/24"
        }],



        "option-data": [
            // Section 8.2.10 Standard DHCPv4 Options
            // https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-std-options-list
            // Section 8.11 Suppored DHCP Standards
            // https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#supported-dhcp-standards
            {
                "name": "subnet-mask",
                "code": 1,
                "data": "255.255.255.0"
            },
            {
                "name": "routers",
                "code": 3,
                "data": "192.168.0.1"
            },
            {
                "name": "domain-name-servers",
                "code": 6,
                "data": "192.168.0.1"
            },
            {
                "name": "tftp-server-name",
                "code": 66,
                "data": "192.168.0.1"
            }
        ],
        "client-classes": [
        // Section 8.2.17
        // https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#setting-fixed-fields-in-classification
        // Section 2.1 of RFC 4578
        // https://tools.ietf.org/html/rfc4578#section-2.1
            {
            "name": "ipxe_efi_x86",
            "test": "option[93].hex == 0x0006",
            "boot-file-name": "/grub/shim.efi"
            },
            {
            "name": "ipxe_efi_x64",
            "test": "(option[93].hex == 0x0007) or (option[93].hex == 0x0009)",
            "boot-file-name": "/grub/shim.efi"
            }
        ],



       # Now loggers are inside the DHCPv4 object.
       "loggers": [{
            "name": "*",
            "severity": "DEBUG"
        }]
    }

# The whole configuration structure ends here.
}
```