> Example environment  
System : CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](../运维/Linux/CentOS7 Post-Install.html))  
Shadowsocks Port: 465 *Use some usaual port for public service, maybe safer, maybe.*  
Shadowsocks Password: SSPASSWORD

# Install shadowsocks server endpoint
```bash
$ pip3.6 install shadowsocks
```

**save follow to /data/scripts/shadowsocks.service**

```text
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -p 465 -m aes-256-cfb -k SSPASSWORD
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

**make it auto start**  
```bash
$ ln -snf /data/scripts/ssserver.service /etc/systemd/system/ssserver.service
$ ln -snf /data/scripts/ssserver.service /etc/systemd/system/multi-user.target.wants/ssserver.service
```  

**start ssserver**  
```bash
$ systemctl start ssserver
```

# Optimizing 
**/etc/sysctl.d/shadowsocks.conf**
```text
# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096

# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1

# for high-latency network
#net.ipv4.tcp_congestion_control = hybla

# for low-latency network, use cubic instead
# net.ipv4.tcp_congestion_control = cubic

# for bbr instance on bandwagon
net.ipv4.tcp_congestion_control = bbr
```