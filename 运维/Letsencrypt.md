> Example environment  
System: CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](../运维/Linux/CentOS 7 Minimal Post Install.html))   
Domain: example.com

# Issue [Letsencrypt](https://letsencrypt.org/) SSL using [acme.sh](https://github.com/Neilpang/acme.sh)

**Why acme.sh not certbot from Letsencrypt**  
As i know, certbot has no ali dns plugin. Generally, certbot suffers lacking dns plugins for this moment.

# Install acme.sh  
Specific cert-home to /etc/nginx to simple nginx configuration.

```bash
$ git clone https://github.com/Neilpang/acme.sh.git
$ cd acme.sh && ./acme.sh --install --home /opt/acme --cert-home /etc/nginx/certs
```

# Get Access Key&Secret from Domain Provider
Refer the document of the domain service providers.  
Useful access key configure url:  
* Aliyun(https://ram.console.aliyun.com)
* Godday(https://developer.godaddy.com)

# Issue the cert(Using [DNS API](https://github.com/Neilpang/acme.sh/wiki/dnsapi))  
### For a single domain  
Example domain [example.com]() from aliyun:
```bash
$ export DOMAIN="exmaple.com" && \
    export Ali_Key="sdfsdfsdfljlbjkljlkjsdfoiwje" && \
    export Ali_Secret="jlsdflanljkljlfdsaklkjflsa"
$ acme.sh --issue --dns dns_ali -d $DOMAIN -d *.$DOMAIN
```

This will get certs in **/etc/nginx/certs**, path we specify when installing acme.sh with **--cert-home**, contains:  
* ca.cer  
* fullchain.cer  
* example.com.cer  
* example.com.conf  
* example.com.csr  
* example.com.cer.conf  
* example.com.key  
"fullchain.cer" should be used as the domain's certificate while it contains example.com.cer and ca.cer.  

If your dns provider doesn't provide api access, you can use our **dns alias mode**:  
https://github.com/Neilpang/acme.sh/wiki/DNS-alias-mode  
This may help when you want to issue a cert for multi domains with only one access key.