# Attention  
根据现有资料及历史故障，生产环境的Redis-HA配置存在以下问题:  
1、Float IP和Redis Daemon的启动顺序不正确(根据测试情况Redis Daemon先启动比较好）；  
2、Redis Daemon使用systemd方式启动，在发生主从切换时数据会完全丢失；  
3、Redis Master Role 跟随 Float IP 强制设置在一台机器上，该节点失效再恢复过程会造成两次数据完全丢失。

# OS Configuration
```text
$ useradd redis
$ mkdir -p /var/redis
$ chown -R redis.redis /var/redis
```

```text
$ vi /etc/default/grub

    # Add transparent_hugepage=never like follow:
    GRUB_CMDLINE_LINUX="...transparent_hugepage=never"

$ grub2-mkconfig -o /boot/grub2/grub.cfg
```

```text
$ vi /etc/sysctl.d/redis.conf

    # Add follow lines
    vm.overcommit_memory = 1
    net.core.somaxconn= 2048
    fs.file-max = 655360
    
$ sysctl -p /etc/sysctl.d/redis.conf
```

## Redis内存使用优化
TODO: 新建Linux内核参数优化文档  
[理解LINUX的MEMORY OVERCOMMIT](http://linuxperf.com/?p=102)  
__允许进程使用超过50%的物理内存。__
```text
$ echo 'vm.overcommit_ratio=80' > /etc/sysctl.d/memory.conf
$ sysctl -p /etc/sysctl.d/memory.conf
```


# 集群安装  
### Edit hosts file
```text
$vi /etc/hosts  
    add the follow lines  
    192.168.4.24 RC-4-24-redis  
    192.168.4.25 RC-4-25-redis
```

### SSH 认证
on RC-4-24-redis
```text
$ ssh-copy-id root@RC-4-25-redis
```  
on RC-4-25-redis
```text
$ ssh-copy-id root@RC-4-24-redis
```

### 组件安装
```text
$ yum install -y pcs pacemaker fence-agents-vmware-rest
```

### Start&enable pcs Daemon
```text
$ systemctl start pcsd.service
$ systemctl enable pcsd.service
```

### Passwd hacluster
on all node  
```text
$ passwd hacluster
```

### 新建集群
```text
$ pcs cluster auth RC-4-24-redis RC-4-25-redis
$ pcs cluster setup --enable --start --name cluster-redis RC-4-24-redis RC-4-25-redis
$ pcs property set no-quorum-policy=ignore
```

Prevent Resources from Moving after Recovery. Frequently moving of resource or resource role may cause data lose!!!
```text
$ pcs resource defaults resource-stickiness=100
```

## 配置Fence
list hostname of vm in vcenter(192.168.0.250), using fence-agents-vmware-rest
```text
$ fence_vmware_rest --ssl --ssl-insecure --action list --ip=192.168.3.10 --username='administrator@vsphere.local' --password='shangwei@EC.2017' | grep redis
    RC-4.25-redis,
    RC-4.24-redis,
$ pcs stonith create vmware_rest_fencing fence_vmware_rest ipaddr=192.168.3.10  ipport=443 ssl=1 ssl_insecure=1 inet4_only=1 login="administrator@vsphere.local" passwd="shangwei@EC.2017" pcmk_host_map="RC-4-24-redis:RC-4.24-redis;RC-4-25-redis:RC-4.25-redis" pcmk_host_list="RC-4.24-redis,RC-4.25-redis"
```

## 配置SMTP [TODO]
```text
$ install --mode=0755 /usr/share/pacemaker/alerts/alert_smtp.sh.sample /var/lib/pacemaker/alert_smtp.sh
$ pcs alert create id=alert_smtp path=/var/lib/pacemaker/alert_smtp.sh meta timestamp-format="%Y-%m-%d %H:%M:%S"
$ pcs alert recipient add alert_smtp value=devops@shangweiec.com
```

# 添加资源  
### Daemon Redis  
> Redis is started in PROTECTED mode by default, In this mode connections are only accepted from the loopback interface.
Disable this mode by add 'protected-mode no' to /etc/redis.conf OR configure the 'bind' option.

```text
$ pcs cluster cib redis_cfg
$ pcs -f redis_cfg resource create Redis-HA ocf:heartbeat:redis \
    bin=/usr/local/redis/src/redis-server \
    client_bin=/usr/local/redis/src/redis-cli \
    rundir=/var/redis \
    user=redis \
    config=/etc/redis.conf
$ pcs -f redis_cfg resource master Redis-HA master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
$ pcs -f redis_cfg constraint order promote Redis-HA-master then vIP-Redis
$ pcs -f redis_cfg constraint colocation add master vIP-Redis with Redis-HA-master INFINITY
$ pcs cluster cib-push redis_cfg
```

### Float ip of Redis Master  
```text
$ pcs cluster cib vip_cfg
$ pcs -f vip_cfg resource create vIP-Redis ocf:heartbeat:IPaddr2 ip=192.168.4.26 cidr_netmask=32 nic=eth0 op monitor interval=30s
$ pcs -f vip_cfg constraint colocation add vIP-Redis with master Redis-HA-master INFINITY 
$ pcs cluster cib-push vip_cfg
```

# Fencing Operation Example

## Action reboot
`$ stonith_admin --reboot [node-name]`

## Confirm offline status  
#### Attention   
> This operation will cause data lose.  
But with a low load NAS system, we generally asume that the drbd process is always totally in sync.
  
When either host in a dual node cluster is down and STONITH device cannot fence it(for example vsphere pysical host  is down), the offline-node's status shown on the other will be offline(unclean), and the cluster will be stoped because of it.  
If the offline node CANNOT be repaired in time, administrators should STONITH it with confirm operation. As shown below:  
`$ stonith_admin --confirm [offline-node-name]`
