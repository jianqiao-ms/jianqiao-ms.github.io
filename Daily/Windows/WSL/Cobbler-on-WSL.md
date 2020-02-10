> Example environment  
> System : WSL1 OS build 18362.592  
> WSL Distribution: CentOS-7.6.1810  
> Cobbler Version: 2.8.5

# Cobbler on WSL V1

## Install

```bash
$ yum install -y cobbler cobbler-web
```

##### Download network boot-loads

````bash
$ cobbler get-loaders
````

##### Other components

``` bash
$ yum install -y pykickstart fence-agents debmirror
```



## Change settings

Refer [Quickstart](https://cobbler.readthedocs.io/en/latest/quickstart-guide.html)

##### Default encrypted password

```bash
$ openssl passwd -l
Password: 
Verifying - Password: 
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

##### Server and next_server

Server should be set to the IP you want hosts that are being built to contact the Cobbler server on for such protocols as HTTP and TFTP. **NOT 0.0.0.0**

`server: 192.168.0.1`

The `next_server` option is used for DHCP/PXE as the IP of the TFTP server from which network boot files are downloaded.

```bash/sei
next_server: 192.168.0.1
```

##### Update /etc/xinetd.d/tftp

`disable                 = yes`    =>    `disable                 = no`

##### Update /etc/debmirror.conf

* comment out 'dists' on /etc/debmirror.conf for proper debian support
* comment out 'arches' on /etc/debmirror.conf for proper debian support

##### Run `cobbler check` to find unresolved problems and deal with them

##### Restart cobbled and run `cobbler sync`



## Create Installation Media

> Use CentOS ISO image

As descriped on [Quick Start](https://cobbler.readthedocs.io/en/latest/quickstart-guide.html#importing-your-first-distribution), we need mount iso to Linux. But WSL cannot made it. So I extract the ISO file on windows and import it directly from disk.

**DO NOT EXTRACT ISO USING NORMAL UNZIP APPS LIKE 7-zip**

I choose UltroISO and extract it to `D:\WSL\ISOS\CentOS-7-x86_64-Minimal-1908`

Check files in `D:\WSL\ISOS\CentOS-7-x86_64-Minimal-1908\repodata`, if the files with a long digits and alpha name end with .gz or something like that, the extract is OK.

##### Import

```bash
$  cobbler import --name=CentOS7 --arch=x86_64 --path=/mnt/d/WSL/ISOS/CentOS-7-x86_64-Minimal-1908
```

## Workaround for EFI boot

Refer [基于DHCP、PXE和kickstart自动安装设置CentOS 7.3](http://hmli.ustc.edu.cn/doc/linux/centos-autoinstall.htm)

```bash
$ rpm2cpio /mnt/d/WSL/ISOS/CentOS-7-x86_64-Minimal-1908/Packages/shim-x64-15-2.el7.centos.x86_64.rpm | cpio -dimv
$ rpm2cpio /mnt/d/WSL/ISOS/CentOS-7-x86_64-Minimal-1908/Packages/grub2-efi-x64-2.02-0.80.el7.centos.x86_64.rpm | cpio -dimv
$ rpm2cpio /mnt/d/WSL/ISOS/CentOS-7-x86_64-Minimal-1908/Packages/grub2-efi-ia32-2.02-0.80.el7.centos.x86_64.rpm | cpio -dimv

$ cp boot/efi/EFI/centos/{shim.efi,shimx64.efi,grubx64.efi,grubia32.efi} /var/lib/tftpboot/grub

$ cp /mnt/d/WSL/ISOS/CentOS-7-x86_64-Minimal-1908/EFI/BOOT/grub.cfg
```

使用efidfault中的启动项替换grub.cfg中的相关内容



##  TODO: Kickstart file

