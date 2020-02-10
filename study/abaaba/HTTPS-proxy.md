> Example environment  
System : CentOS 7 x64 Minimal (After optimized by [CentOS 7 Minimal Post Install](/运维/Linux/CentOS-7-Post-Install.md))   
SSL Domain : example.com (After issue certificate following [Letsencrypt](/运维/Letsencrypts.md))  
Proxy Server : [Squid](http://www.squid-cache.org/)  
Proxy Server Port : 60000  
PAC file generator : [genpac](https://github.com/JinnLynn/genpac)  
Proxy Basic Authentication User :  HTUSER  
Proxy Basic Authentication Password :  HTPASSWORD  

# Get genpac
```bash
$ pip3.6 install -U genpac
```

# Generate PAC file  
The PAC file should be hosted by nginx or other httpd service, mean it should be accessable on the Internet.  
We will create a "proxy.example.com" virtual server and directory same named to host the PAC file.

```bash
$ mkdir -p /data/wwwroot/proxy.example.com
$ /usr/bin/genpac --user-rule="@@*.example.com" --user-rule="example.com" --pac-proxy="HTTPS proxy.example.com:60000" 
    --output=/data/wwwroot/proxy.example.com/proxy.pac
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
Reload nginx, make sure https://proxy.example.com/proxy.pac is accessable.

# Install squid   
```bash
$ yum install -y htpasswd http://ngtech.co.il/repo/centos/7/squid-repo-1-1.el7.centos.noarch.rpm && \
    yum install -y squid squid-helpers
```  
**Check the installation**
```bash
$ rpm -ql squid-helpers/usr/lib64/squid/basic_db_auth
/usr/lib64/squid/basic_fake_auth
/usr/lib64/squid/basic_getpwnam_auth
/usr/lib64/squid/basic_ldap_auth
/usr/lib64/squid/basic_ncsa_auth
/usr/lib64/squid/basic_nis_auth
/usr/lib64/squid/basic_pam_auth
/usr/lib64/squid/basic_pop3_auth
/usr/lib64/squid/basic_radius_auth
/usr/lib64/squid/basic_sasl_auth
/usr/lib64/squid/basic_smb_auth
/usr/lib64/squid/basic_smb_auth.sh
/usr/lib64/squid/cachemgr.cgi
/usr/lib64/squid/cert_tool
/usr/lib64/squid/digest_edirectory_auth
/usr/lib64/squid/digest_file_auth
/usr/lib64/squid/digest_ldap_auth
/usr/lib64/squid/ext_delayer_acl
/usr/lib64/squid/ext_file_userip_acl
/usr/lib64/squid/ext_kerberos_ldap_group_acl
/usr/lib64/squid/ext_ldap_group_acl
/usr/lib64/squid/ext_session_acl
/usr/lib64/squid/ext_sql_session_acl
/usr/lib64/squid/ext_time_quota_acl
/usr/lib64/squid/ext_unix_group_acl
/usr/lib64/squid/ext_wbinfo_group_acl
/usr/lib64/squid/helper-mux
/usr/lib64/squid/log_db_daemon
/usr/lib64/squid/negotiate_kerberos_auth
/usr/lib64/squid/negotiate_kerberos_auth_test
/usr/lib64/squid/negotiate_wrapper_auth
/usr/lib64/squid/ntlm_fake_auth
/usr/lib64/squid/security_fake_certverify
/usr/lib64/squid/security_file_certgen
/usr/lib64/squid/storeid_file_rewrite
/usr/lib64/squid/url_fake_rewrite
/usr/lib64/squid/url_fake_rewrite.sh
/usr/lib64/squid/url_lfs_rewrite
```

# Configurate squid  
[Authentication Refer](https://wiki.squid-cache.org/Features/Authentication)  
*Authentication with Basic method using "basic_ncsa_auth"*  
**Create htpasswd file**
```bash
$ htpasswd -c /data/squid-htpasswd HTUSER HTPASSWORD 
```  
**/etc/squid/squid.conf**  
```text
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /data/squid-passwd

acl authenticated_users proxy_auth REQUIRED
http_access deny !authenticated_users
http_access allow authenticated_users
http_access deny all
https_port 60000 tls-cert=/etc/nginx/certs/example.com/fullchain.cer tls-key=/etc/nginx/certs/example.com/example.com.key

coredump_dir /var/spool/squid

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320  
```

# Start squid  
```bash
$ systemctl start squid
$ systemctl enable squid
```