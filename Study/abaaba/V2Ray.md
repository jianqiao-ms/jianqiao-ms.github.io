> Example environment  
System: CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](/运维/Linux/CentOS-7-Post-Install.md))   
SSL Domain: example.com (After issue certificate following [Letsencrypt](/运维/Letsencrypts.md))

# [Introduce](https://www.v2ray.com/)

> Project V 是一个工具集合，它可以帮助你打造专属的基础通信网络。Project V 的核心工具称为V2Ray，其主要负责网络协议和功能的实现，与其它 Project V 通信。V2Ray 可以单独运行，也可以和其它工具配合，以提供简便的操作流程。

# Install [REF v2ray.com](https://www.v2ray.com/chapter_00/install.html#linuxscript)
```bash
$ bash <(curl -L -s https://install.direct/go.sh)
```



# Server Configuration  

SSL certificates from [Letsencrypts](https://letsencrypt.org). [HOWTO](/运维/Letsencrypts.md)

Example config.json:

```json
{
  "log": {
    "loglevel": "debug"
  },
  "inbounds": [
    {
      "port": ,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx",
            "level": 0,
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": false,
          "certificates": [
              {
                "certificateFile": "/etc/nginx/certs/example.com/fullchain.cer",
                "keyFile": "/etc/nginx/certs/example.com/example.com.key"
              }
            ]
        }
      }   
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
```

# Example config.json for client

```json
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error":  "/var/log/v2ray/error.log",
    "loglevel": "debug"
  },
  "dns": {
    "servers": [
      {
        "address": "8.8.8.8",
        "port": 53,
        "domains": [
          "geosite:geolocation-!cn"
        ]
      },
      "127.0.0.1"
    ]
  },
  "inbounds":[
    {
      "tag":"AUTO",
      "port":1080,
      "listen":"127.0.0.1",
      "protocol":"socks",
      "settings":{
        "udp":true
      }
    },
    {
      "tag":"ALL",
      "port":1081,
      "listen":"127.0.0.1",
      "protocol":"socks"
    },
    {
      "tag":"HTTP",
      "port":1082,
      "listen":"127.0.0.1",
      "protocol":"http"
    }
  ],
  "outbounds":[
    {
      "tag":"yes",
      "protocol":"vmess",
      "settings":{
        "vnext":[
          {
            "address":"",
            "port":,
            "users":[
              {
                "id":""
              }
            ]
          }
        ]
      },
      "streamSettings":{
        "network":"tcp",
        "security":"tls",
        "tlsSettings":{
          "serverName":""
        }
      }
    },
    {
      "protocol":"freedom",
      "tag":"direct",
      "settings":{
        "domainStrategy": "UseIPv4"
      }
    }
  ],
  "routing":{
    "domainStrategy":"IPIfNonMatch",
    "rules":[
      {
        "type":"field",
        "outboundTag":"yes",
	      "inboundTag": ["ALL"]
      },
      {
        "type":"field",
        "ip": [
           "8.8.8.8"
         ],
        "outboundTag":"yes"
      },
      {
        "type":"field",
        "domain":[
          "geosite:cn",
          "geosite:speedtest"
        ],
        "outboundTag":"direct",
	      "inboundTag": ["AUTO","HTTP"]
      },
      {
        "type":"field",
        "ip":[
          "geoip:private",
          "geoip:cn"
        ],
        "outboundTag":"direct",
        "inboundTag": ["AUTO","HTTP"]
      }
    ]
  }
}

```