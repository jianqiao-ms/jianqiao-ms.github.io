# Todo
未完全成功

# 集群安装、建立
## hostname
```test
$ vi /etc/hosts
# ...add
192.168.0.160 idc1-prd-app-boss-cfgmgr-0-160 idc1-prd-app-boss-cfgmgr-0-160.localdomain
192.168.0.161 idc1-prd-app-boss-cfgmgr-0-161 idc1-prd-app-boss-cfgmgr-0-161.localdomain
```

## SSH Authentication
###### on idc1-prd-app-boss-cfgmgr-0-160
`$ ssh-copy-id root@idc1-prd-app-boss-cfgmgr-0-161`
###### on idc1-prd-app-boss-cfgmgr-0-161
`$ ssh-copy-id root@idc1-prd-app-boss-cfgmgr-0-160`

## 组件安装
`$ yum install -y pacemaker* pcs psmisc policycoreutils-python corosync* fence-agents-vmware-soap`

## passwd hacluster
`$ passwd hacluster`

## Enable pcs Daemon
`$ systemctl start pcsd.service && systemctl enable pcsd.service`
`

## Setup集群
```text
$ pcs cluster auth idc1-prd-app-boss-cfgmgr-0-160 idc1-prd-app-boss-cfgmgr-0-161
$ pcs cluster setup --enable --start --name cfgmgr \
 idc1-prd-app-boss-cfgmgr-0-160 idc1-prd-app-boss-cfgmgr-0-161
$ pcs property set no-quorum-policy=stop
$ pcs resource defaults resource-stickiness=100
```

### 配置Fence
###### list uuid of vm in vcenter(192.168.0.250)
```text
$ fence_vmware_soap --ssl --ssl-insecure -o list -a 192.168.0.251 \
 -l 'administrator@vsphere.local' -p 'shangwei@EC.2018' | grep cfgmgr
0.161-boss-cfgmgr,423aa705-ef2c-f927-2d07-2b4f48db6c86
0.160-boss-cfgmgr,423ae881-496b-6007-4078-f074fcdc1117

pcs cluster cib stonith_cfg
pcs -f stonith_cfg stonith create Fence_cfgmgr-160 fence_vmware_soap ssl=1 ssl_insecure=1 \
    ipaddr=192.168.0.251 login='administrator@vsphere.local' passwd='shangwei@EC.2018' \
    pcmk_host_check="static-list" pcmk_host_list="cfgmgr-160" \
    port="423aa705-ef2c-f927-2d07-2b4f48db6c86"
pcs -f stonith_cfg stonith create Fence_cfgmgr-161 fence_vmware_soap ssl=1 ssl_insecure=1 \
    ipaddr=192.168.0.251 login='administrator@vsphere.local' passwd='shangwei@EC.2018' \
    pcmk_host_check="static-list" pcmk_host_list="cfgmgr-161" \
    port="423ae881-496b-6007-4078-f074fcdc1117"
pcs -f stonith_cfg constraint location Fence_cfgmgr-160 prefers cfgmgr-161=INFINITY
pcs -f stonith_cfg constraint location Fence_cfgmgr-161 prefers cfgmgr-160=INFINITY
pcs -f stonith_cfg property set stonith-enabled=true
pcs cluster cib-push stonith_cfg
```

### 配置SMTP
```text
$ install --mode=0755 \
 /usr/share/pacemaker/alerts/alert_smtp.sh.sample \
 /var/lib/pacemaker/alert_smtp.sh
$ pcs alert create id=alert_smtp \
 path=/var/lib/pacemaker/alert_smtp.sh \
 meta timestamp-format="%Y-%m-%d %H:%M:%S"
$ pcs alert recipient add alert_smtp value=devops@shangweiec.com
```


# Install Rabbitmq
## Create User&Group
```text
$ groupadd -g 2001 rabbitmq
$ useradd -u 2001 -g rabbitmq -d /var/lib/rabbitmq rabbitmq
```
## Install erlang
```text
$ wget -O erlang-20.3.6-1.el7.centos.x86_64.rpm \
https://bintray.com/rabbitmq/rpm/download_file?\
file_path=erlang%2F20%2Fel%2F7%2Fx86_64%2F\
erlang-20.3.6-1.el7.centos.x86_64.rpm
$ yum install -y erlang-20.3.6-1.el7.centos.x86_64.rpm
```
## Install rabbitmq-server
```text
$ wget -O rabbitmq-server-3.7.5-1.el7.noarch.rpm \
https://bintray.com/rabbitmq/rpm/download_file?\
file_path=rabbitmq-server%2Fv3.7.x%2Fel%2F7%2Fnoarch%2F\
rabbitmq-server-3.7.5-1.el7.noarch.rpm
$ yum install -y rabbitmq-server-3.7.5-1.el7.noarch.rpm
```

# Configuration of rabbitmq
```text
$ pcs cluster cib rabbitmq
$ pcs -f rabbitmq resource create rabbitmq-server ocf:rabbitmq:rabbitmq-server-ha \
    op monitor interval=30 timeout=60 \
    op monitor interval=27 role=Master timeout=60 \
    op start interval=0 timeout=360 \
    op stop interval=0 timeout=120 \
    op promote interval=0 timeout=120 \
    op demote interval=0 timeout=120 \
    op notify interval=0 timeout=180 
$ pcs -f rabbitmq resource master rabbitmq-server master-max=1 master-node-max=1 notify=true
$ pcs -f rabbitmq constraint colocation add master rabbitmq-server-master with vIP-nas INFINITY
$ pcs cluster cib-push rabbitmq
```

# Install Validation
## On Both
### Open Web UI
```test
$ rabbitmq-plugins enable rabbitmq_management
$ pcs resource restart rabbitmq-server-master
```

## On master
### Add User [URL](https://www.rabbitmq.com/man/rabbitmqctl.8.html)
`$ rabbitmqctl add_user admin admin123`

### Configure User Permmission [URL](https://www.rabbitmq.com/management.html)
```
$ rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
$ rabbitmqctl set_user_tags admin administrator
```

## On client
### Login via Web UI
### Shutdown master and try RELogin via Web UI