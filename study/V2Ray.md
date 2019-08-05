> Example environment  
System: CentOS 7 x64 Minimal (After Profiling by [CentOS 7 Minimal Post Install](/运维/Linux/CentOS-7-Post-Install.md))   
SSL Domain: example.com (After issue certificate following [Letsencrypt](/运维/Letsencrypts.md))

# [Introduce](https://www.v2ray.com/)

> Project V 是一个工具集合，它可以帮助你打造专属的基础通信网络。Project V 的核心工具称为V2Ray，其主要负责网络协议和功能的实现，与其它 Project V 通信。V2Ray 可以单独运行，也可以和其它工具配合，以提供简便的操作流程。

# Install [REF v2ray.com](https://www.v2ray.com/chapter_00/install.html#linuxscript)
`# bash <(curl -L -s https://install.direct/go.sh)`

# Server Configuration  
SSL certificates from [Letsencrypts](https://letsencrypt.org). [HOWTO](/运维/Letsencrypts.md)
```json
{
  "log": {
    "loglevel": "debug"
  },
  "inbounds": [
    {
      "port": 62121,
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
        },
        "quicSettings": {
          "security": "chacha20-poly1305",
          "key": "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzz",
          "header": {
            "type": "none"
          }
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

# Client Configuration
```json
{
  "inbounds": [{
    "port": 1080,
    "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "vmess",
    "settings": {
      "vnext": [{
        "address": "example.com",
        "port": 62121, 
        "users": [{ "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx" }]
      }]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "tls",
      "tlsSettings": {
        "serverName": "example.com"
      },
      "quicSettings": {
        "security": "chacha20-poly1305",
        "key": "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzz",
        "header": {
          "type": "none"
        }
      }
    }
  },{
    "protocol": "freedom",
    "tag": "direct",
    "settings": {}
  }],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [{
      "type": "field",
      "domain": [
        "cn",
        "speedtest",
        "domain:example.com"
      ],
      "ip": [
        "geoip:private",
        "geoip:cn"
      ],
      "outboundTag": "direct"
    }]
  }
}
```