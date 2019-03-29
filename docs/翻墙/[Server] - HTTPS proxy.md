> Example environment  
System : CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](../运维/Linux/CentOS7 Post-Install.html))   
SSL Domain : example.com (After issue certificate following [Letsencrypt](../运维/Letsencrypt.html))  
Proxy Server : [Squid](http://www.squid-cache.org/)
Generate pac file using [genpac](https://github.com/JinnLynn/genpac)

# Install squid 
```bash
$ yum install -y http://ngtech.co.il/repo/centos/7/squid-repo-1-1.el7.centos.noarch.rpm && \
    yum install -y squid
```

# Configurate squid

/etc/squid/squid.conf
```text
http_access allow all
https_port 60000 tls-cert=/etc/nginx/certs/mhonyi.com/fullchain.cer tls-key=/etc/nginx/certs/mhonyi.com/mhonyi.com.key

coredump_dir /var/spool/squid
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .      
```

# Add nginx virtual server configuration
```text
server {
    listen       80;
    server_name  proxy.example.com;

    charset utf-8;
    access_log  /data/logs/proxy.example.com.log  main;

    location ~* / {
        rewrite ^.*$ https://$server_name$request_uri? permanent;
    }
}

server {
    listen       443 ssl;
    server_name  proxy.example.com;

    charset utf-8;
    access_log  /data/logs/proxy.example.com.log  main;
    client_max_body_size 100m;

    include conf.d/ssl/ssl-common.conf;
    include conf.d/ssl/example.com.conf;

    location / {
        root /data/wwwroot/proxy.example.com;
    }
}
```