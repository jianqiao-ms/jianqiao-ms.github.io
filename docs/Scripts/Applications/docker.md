> Example environment  
System : CentOS 7 x64  

# Install Docker CE
> current version 19.03.1
## Set up the repository
### Install required packages.
```bash
$ yum install -y yum-utils device-mapper-persistent-data lvm2
```

### Add Docker repository.
```bash
$ yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo &&  yum update -y && \
  yum clean all && yum makecache
```

## Install Docker CE.
```bash
$ && yum install docker-ce
```

# Setup daemon.
[Registry Mirror](https://lug.ustc.edu.cn/wiki/mirrors/help/docker)

```bash
$ mkdir /etc/docker && cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

$ mkdir -p /etc/systemd/system/docker.service.d
```

# Restart Docker
```bash
$ systemctl daemon-reload && systemctl restart docker && systemctl enable docker
```