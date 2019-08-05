> Example environment  
System : CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](../运维/Linux/CentOS7 Post-Install.html))  
Specific "/data/wwwroot" the root path of nginx virtual server. Virtual server's root path should place here usually.    

# Install
```bash
$ curl https://packages.mhonyi.com/repo/nginx.repo | sudo tee /etc/yum.repo.nginx.repo
$ yum install -y nginx
```

# Basic configuration  
/etc/nginx/nginx.conf  
```text
user                     nginx;
worker_processes         auto;
worker_rlimit_nofile     655350; # worker进程的最大打开文件数限制

pid                      /var/run/nginx.pid;
error_log                /var/log/nginx/error.log warn;
events {
  # 最大连接数 由系统的可用socket连接数限制 65535
  worker_connections     4096;
}

http {
  charset                UTF-8;
  include                /etc/nginx/mime.types;
  default_type           application/octet-stream;

  log_format main        '$remote_addr|$http_x_forwarded_for [$time_iso8601|$msec] "$status $request_method $scheme://$server_name:$server_port$request_uri"  $request_time|$upstream_connect_time|$upstream_header_time|$upstream_response_time  $request_length|$bytes_sent "$http_referer" "$http_user_agent" UPSTREAM_ADDR:$upstream_addr;';

  gzip                   on;
  sendfile               on;
  tcp_nopush             on; # 在一个数据包里发送所有头文件，而不一个接一个的发送
  tcp_nodelay            on; # 
  server_tokens          off;
  keepalive_timeout      120;

  include                /etc/nginx/conf.d/*.conf;
}
```

TODO : Profiling nginx and kernel configuration for nginx