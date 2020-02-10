> Example environment  
System : CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](../Linux/CentOS-7-Post-Install.md))  
Loadbalancer Application : nginx

# Install Nginx
[REF](../Applications/nginx.md)

## Install nginx_upstream_check_module

```
$ nginx -v
nginx version: nginx/1.12.2

$ nginx -V
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib64/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx nginx \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong \
--param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' \
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'

wget http://nginx.org/download/nginx-1.12.2.tar.gz
tar zxvf nginx-1.12.2.tar.gz

wget -O nginx_upstream_check_module-master.zip https://codeload.github.com/yaoweibin/nginx_upstream_check_module/zip/master
unzip nginx_upstream_check_module-master.zip

cd nginx-1.12.2
patch -p1 < ../nginx_upstream_check_module-master/check_1.12.1+.patch
./configure --prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib64/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' \
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' \
--add-module=../nginx_upstream_check_module-master

make

cp /usr/sbin/nginx{,.ori}
cp objs/nginx /usr/sbin/nginx
````



## nginx configuration file


```
$ cat /etc/nginx/nginx.conf

#user  nginx;
#worker_processes  8;

#error_log  /var/log/nginx/error.log warn;
#pid        /var/run/nginx.pid;

#events {
#    worker_connections  1024;
#}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main '$remote_addr [$time_iso8601] "$status $request_method $scheme://$server_name:$server_port$request_uri"  $request_time|$upstream_connect_time|$upstream_header_time|$upstream_response_time  $request_length|$bytes_sent "$http_referer" "$http_user_agent"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush     on;
    tcp_nodelay         on;
    keepalive_timeout  65;
    gzip  on;

    include /etc/nginx/conf.d/*.conf;
}


## files in  /etc/nginx/conf.d

server {
    listen       PORT;
    server_name  hostname;

    charset utf-8;
    access_log  /home/logs/access.hostname.log  main;

    location / {
      root /home;
      index index.html index.htm;
    }
}
```


# 策略路由

```
$ vi /etc/iproute2/rt_tables
# add by jianqiao
10    t_local
128   t_www

$ touch /etc/sysconfig/network-scripts/route-eth0
192.168.0.0/24 dev eth0 table 10
default via 192.168.0.1 dev eth0 table 10

$ touch /etc/sysconfig/network-scripts/route-eth1
61.240.30.128/28 dev eth1 table 128
default via 61.240.30.129 dev eth1 table 128$ touch /etc/sysconfig/network-scripts/rule-eth0

$ touch /etc/sysconfig/network-scripts/rule-eth0
from 61.240.30.128/28 table t_www

$ touch /etc/sysconfig/network-scripts/rule-eth0
from 61.240.30.128/28 table t_www
```

# 集群安装
## hostname
`$ vi /etc/hosts`

## SSH 认证
`$ ssh-copy-id`

## 组件安装
`$ yum install -y pacemaker* pcs psmisc policycoreutils-python corosync* fence-agents-vmware-soap`

## Enable pcs Daemon
```
$ systemctl start pcsd.service
$ systemctl enable pcsd.service
```

## passwd hacluster
`$ passwd hacluster`

## 配置集群

### 新建集群
```
pcs cluster auth LB-11 LB-12
pcs cluster setup --enable --start --name LoadBalance LB-11 LB-12
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=stop
pcs resource defaults resource-stickiness=100
```

### 配置Fence
list uuid of vm in vcenter(192.168.0.250)
```
fence_vmware_soap --ssl --ssl-insecure -o list -a 192.168.0.251 -l 'administrator@vsphere.local' -p 'shangwei@EC.2018' | grep LB
0.11-LB,423a10d8-b76b-4608-bf29-b2b39ac6ecb7
0.12-LB,423a0ccf-026d-d87d-e297-a7bcbc9501de

pcs cluster cib stonith_cfg
pcs -f stonith_cfg stonith create Fence_LB-11 fence_vmware_soap ssl=1 ssl_insecure=1 \
    ipaddr=192.168.0.251 login='administrator@vsphere.local' passwd='shangwei@EC.2018' \
    pcmk_host_check="static-list" pcmk_host_list="LB-11" \
    port="423a10d8-b76b-4608-bf29-b2b39ac6ecb7"
pcs -f stonith_cfg stonith create Fence_LB-12 fence_vmware_soap ssl=1 ssl_insecure=1 \
    ipaddr=192.168.0.251 login='administrator@vsphere.local' passwd='shangwei@EC.2018' \
    pcmk_host_check="static-list" pcmk_host_list="LB-12" \
    port="423a0ccf-026d-d87d-e297-a7bcbc9501de"
pcs -f stonith_cfg constraint location Fence_LB-11 prefers LB-12=INFINITY
pcs -f stonith_cfg constraint location Fence_LB-12 prefers LB-11=INFINITY
pcs -f stonith_cfg property set stonith-enabled=true
pcs cluster cib-push stonith_cfg
```

### 添加资源
```
pcs cluster cib vip_cfg
pcs -f vip_cfg resource create vIP-local ocf:heartbeat:IPaddr2 ip=192.168.0.10 cidr_netmask=24 nic=eth0 op monitor interval=30s
pcs -f vip_cfg resource create vIP-www-130 ocf:heartbeat:IPaddr2 ip=61.240.30.130 cidr_netmask=28 nic=eth1 op monitor interval=30s
pcs -f vip_cfg resource create vIP-www-131 ocf:heartbeat:IPaddr2 ip=61.240.30.131 cidr_netmask=28 nic=eth1 op monitor interval=30s
pcs -f vip_cfg resource create vIP-www-132 ocf:heartbeat:IPaddr2 ip=61.240.30.132 cidr_netmask=28 nic=eth1 op monitor interval=30s
pcs -f vip_cfg resource create vIP-www-133 ocf:heartbeat:IPaddr2 ip=61.240.30.133 cidr_netmask=28 nic=eth1 op monitor interval=30s
pcs -f vip_cfg constraint location vIP-www-130 prefers LB-11 INFINITY
pcs -f vip_cfg constraint location vIP-www-131 prefers LB-12 INFINITY
pcs -f vip_cfg constraint location vIP-www-132 prefers LB-11 INFINITY
pcs -f vip_cfg constraint location vIP-www-133 prefers LB-12 INFINITY
pcs cluster cib-push vip_cfg

pcs cluster cib nfs_cfg
pcs -f nfs_cfg resource create Mount-nginx_cfg ocf:heartbeat:Filesystem device=192.168.0.23:/data/nginx_cfg directory=/etc/nginx fstype=nfs options="defaults,noatime"
pcs -f nfs_cfg resource clone Mount-nginx_cfg clone-max=2 clone-node-max=1 notify=true
pcs cluster cib-push nfs_cfg

echo "DefaultLimitCORE=infinity" >> /etc/systemd/system.conf
echo "DefaultLimitNOFILE=102400" >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=102400" >> /etc/systemd/system.conf

pcs cluster cib nginx_cfg
pcs -f nginx_cfg resource create nginx systemd:nginx op monitor interval=20
pcs -f nginx_cfg resource clone nginx clone-max=2 clone-node-max=1 notify=true
pcs -f nginx_cfg constraint order Mount-nginx_cfg-clone then nginx-clone

pcs -f nginx_cfg constraint order nginx-clone then vIP-www-130
pcs -f nginx_cfg constraint order nginx-clone then vIP-www-131
pcs -f nginx_cfg constraint order nginx-clone then vIP-www-132
pcs -f nginx_cfg constraint order nginx-clone then vIP-www-133

pcs cluster cib-push nginx_cfg

```
