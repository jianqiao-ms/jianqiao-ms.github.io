> Example environment  
System : CentOS 7 x64 with Gnome

# Install Elasticsearch with RPM
[REF elastic.co](https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html#rpm)  

```bash
$ sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
$ sudo touch /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
$ sudo yum install elasticsearch
```
