> Example environment  
System : CentOS 7 x64  

# Install using repository 
[REF mongodb.com](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/#install-mongodb-community-edition-on-red-hat-enterprise-or-centos-linux)

```bash
$ cat << EOF > /etc/yum.repos.d/mongodb-org-4.2.repo
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF
$ yum install -y mongodb-org
```