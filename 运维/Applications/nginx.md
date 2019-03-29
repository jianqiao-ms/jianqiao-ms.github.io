> Example environment  
System : CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](../运维/Linux/CentOS7 Post-Install.html))   

# Install
edit /etc/yum.repo.d/nginx.repo like:
```text
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
```  

`$ yum install -y nginx`

# Basic configuration  
/etc/nginx/nginx.conf  
```text
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  2048;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    gzip  on;
    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  120;

    include /etc/nginx/conf.d/*.conf;
}
```

TODO : Profiling nginx and kernel configuration for nginx