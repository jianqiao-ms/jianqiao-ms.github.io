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
$ ln -snf /data/scritps/ssserver.service /etc/systemd/system/ssserver.service
$ ln -snf /data/scritps/ssserver.service /etc/systemd/system/multi-user.target.wants/ssserver.service
```  

**start ssserver**  
```bash
$ systemctl start ssserver
```