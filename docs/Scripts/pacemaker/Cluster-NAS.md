> Example environment  
> System : CentOS 7 x64 Minimal VG : datapool  
> pv : new add /dev/sdc 100G disk  
> lv : /dev/drbdpool/nas-data  
> drbd resource name : nas  
> mount-point : /nas-data

# Prepare disk 

## create new partition

```text
$ fdisk /dev/sdb
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0xa3c2c890.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-4194303, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-4194303, default 4194303): 
Using default value 4194303
Partition 1 of type Linux and of size 2 GiB is set

Command (m for help): t
Selected partition 1
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

## create lvm

```text
$ pvcreate /dev/sdb1
$ vgcreate drbdpool /dev/sdb1
$ lvcreate -l 100%VG drbdpool -n nas-data
```

# 安装DRBD

```text
$ rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
$ rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
$ yum install -y kmod-drbd84 drbd84-utils gfs2-utils dlm
$ echo drbd >/etc/modules-load.d/drbd.conf

$ touch /etc/drbd.d/nas.res
resource nas {
  device /dev/drbd1;
  disk   /dev/drbdpool/nas-data;
  meta-disk internal;
  net {
    protocol C;
    allow-two-primaries yes;
    after-sb-0pri discard-zero-changes;
    after-sb-1pri discard-secondary;
    after-sb-2pri disconnect;
  }
  syncer {
    verify-alg md5;
  }
  on idc1-prd-cluster-nas-a-0-28 {
    address  192.168.0.28:7789;
  }
  on idc1-prd-cluster-nas-p-0-29 {
    address  192.168.0.29:7789;
  }
}

$ vi /etc/drbd.conf
resource resource {
  disk {
    fencing resource-only;
    ...
  }
  handlers {
    fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
    after-resync-target "/usr/lib/drbd/crm-unfence-peer.sh";
    ...
  }
  ...
}


```
### adjust sync rate tempory
`$ drbdadm disk-options --resync-rate=700M`

## on both
```text
$ drbdadm create-md nas
$ drbdadm up all
```

## on either
```text
$ mkfs.ext4 /dev/drbd1
$ drbdadm primary --force all

...waitting for sync...
```

# 集群安装
## hostname
` vi /etc/hosts`

## SSH 认证
### on both
`$ ssh-copy-id root@HOSTNAME`

## 组件安装
`$ yum install -y pcs pacemaker fence-agents-vmware-rest`

## Enable pcs Daemon
```text
$ systemctl start pcsd.service
$ systemctl enable pcsd.service
```

## passwd hacluster
` passwd hacluster`

## 新建集群
```text
$ pcs cluster auth idc1-prd-cluster-nas-a-0-28 idc1-prd-cluster-nas-p-0-29
$ pcs cluster setup --enable --start --name cluster-nas idc1-prd-cluster-nas-a-0-28 idc1-prd-cluster-nas-p-0-29
$ pcs property set no-quorum-policy=ignore
```

## 配置Fence
list hostname of vm in vcenter(192.168.0.250), using fence-agents-vmware-rest
```text
$ fence_vmware_rest --ssl --ssl-insecure --action list --ip=192.168.0.251 --username='administrator@vsphere.local' --password='shangwei@EC.2018' | grep cluster
0.28-cluster-nas,
0.29-cluster-nas,

$ pcs stonith create vmware_rest_fencing fence_vmware_rest ipaddr=192.168.0.251  ipport=443 ssl=1 ssl_insecure=1 inet4_only=1 login="administrator@vsphere.local" passwd="shangwei@EC.2018" pcmk_host_map="idc1-prd-cluster-nas-a-0-28:0.28-cluster-nas;idc1-prd-cluster-nas-p-0-29:0.29-cluster-nas" pcmk_host_list="0.28-cluster-nas,0.29-cluster-nas"

```

## 配置SMTP
```text
$ install --mode=0755 /usr/share/pacemaker/alerts/alert_smtp.sh.sample /var/lib/pacemaker/alert_smtp.sh
$ pcs alert create id=alert_smtp path=/var/lib/pacemaker/alert_smtp.sh meta timestamp-format="%Y-%m-%d %H:%M:%S"
$ pcs alert recipient add alert_smtp value=devops@shangweiec.com
```



## 添加资源

### Float ip of NAS
```text
$ pcs cluster cib vip_cfg
$ pcs -f vip_cfg resource create vIP-nas ocf:heartbeat:IPaddr2 ip=192.168.0.27 cidr_netmask=32 nic=eth0 op monitor interval=30s
$ pcs -f vip_cfg constraint location vIP-nas prefers idc1-prd-cluster-nas-a-0-28 INFINITY
$ pcs cluster cib-push vip_cfg
```

### Daemon drbd
```text
$ pcs cluster cib drbd_cfg
$ pcs -f drbd_cfg resource create DRBD-nas ocf:linbit:drbd drbd_resource=nas op monitor interval=30s
$ pcs -f drbd_cfg resource master DRBD-nas master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
$ pcs -f drbd_cfg constraint order vIP-nas then promote DRBD-nas-master
$ pcs -f drbd_cfg constraint colocation add master DRBD-nas-master with vIP-nas INFINITY
$ pcs cluster cib-push drbd_cfg
```

### drbd-mount 
```text
$ pcs cluster cib fs_cfg
$ pcs -f fs_cfg resource create Mount-nas Filesystem device="/dev/drbd1" directory="/data" fstype="ext4"
$ pcs -f fs_cfg constraint order promote DRBD-nas-master then Mount-nas
$ pcs -f fs_cfg constraint colocation add Mount-nas with master DRBD-nas-master INFINITY
$ pcs cluster cib-push fs_cfg
```

### Float ip of Redis 
```text
$ pcs cluster cib vip_cfg
$ pcs -f vip_cfg resource create vIP-Redis ocf:heartbeat:IPaddr2 ip=192.168.0.26 cidr_netmask=24 nic=eth0 op monitor interval=30s
$ pcs -f vip_cfg constraint location vIP-Redis prefers idc1-prd-cluster-nas-p-0-29 INFINITY
$ pcs cluster cib-push vip_cfg
```

### Daemon Redis
```text
# GRUB_CMDLINE_LINUX="...transparent_hugepage=never"
# echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
# echo 'net.core.somaxconn= 1024' >> /etc/sysctl.conf

$ pcs cluster cib redis_cfg
$ pcs -f redis_cfg resource create Redis-HA ocf:heartbeat:redis bin=/usr/local/redis/bin/redis-server client_bin=/usr/local/redis/bin/redis-cli config=/etc/redis.conf
$ pcs -f redis_cfg resource master Redis-HA master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
$ pcs -f redis_cfg constraint order vIP-Redis then promote Redis-HA-master
$ pcs -f redis_cfg constraint colocation add master Redis-HA-master with vIP-Redis INFINITY
$ pcs cluster cib-push redis_cfg
```

### NFS nginx-cfg-file
```text
$ pcs cluster cib nfs_cfg
$ pcs -f nfs_cfg resource create NFS-nginx_cfg exportfs clientspec="192.168.0.0/24" options="rw,no_root_squash,sync" directory="/nas-data/nginx_cfg" fsid=231
$ pcs -f nfs_cfg constraint colocation add NFS-nginx_cfg with vIP-nas INFINITY
$ pcs -f nfs_cfg constraint order Mount-nas then NFS-nginx_cfg
$ pcs cluster cib-push nfs_cfg
```

### NFS pm-upload
```text
$ pcs cluster cib nfs_cfg
$ pcs -f nfs_cfg resource create NFS-pm_upload exportfs clientspec="192.168.0.0/24" options="rw,no_root_squash,sync" directory="/nas-data/pm_upload" fsid=232
$ pcs -f nfs_cfg constraint colocation add NFS-pm_upload with vIP-nas INFINITY
$ pcs -f nfs_cfg constraint order Mount-nas then NFS-pm_upload
$ pcs cluster cib-push nfs_cfg
```


# Extend drbd volumn  

_**You must do this on both nodes**_  

* [TODO:extend lv by adding disk]()  
* [TODO:extend lv by resizing disk]()  
* Updata drbd volumn [REFER](https://docs.linbit.com/docs/users-guide-8.4/#s-resizing)  
  After **Extend LV**, **don't** excute _Update mounted lvm filesystem_  
    ```bash
    $ drbdadm resize nas
    ```
* Update mounted lvm filesystem



# Fencing Operation Example

## Action reboot
`stonith_admin --reboot [node-name]`

## Confirm offline status

#### Attention with this operation will cause data lose.But with a low load NAS system, we generally asume that the drbd process is always totally in sync.

When either host in a dual node cluster is down and STONITH device cannot fence it(for example vsphere pysical host is down), the offline-node's status shown on the other will be offline(unclean), and the cluster will be stoped because of it.

If the offline node CANNOT be repaired in time, administrators should STONITH it with confirm operation. As shown below:

`$ stonith_admin --confirm [offline-node-name]`
