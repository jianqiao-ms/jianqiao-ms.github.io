> Example environment  
System : CentOS 7 x64
Version : 3.7.3

# Get source package
```
$ yum groupinstall -y 'Development Tools'
$ yum install -y openssl-devel libffi-devel
$ wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
$ tar xvf Python-3.7.4.tgz && mkdir -p /opt/src && mv Python-3.7.4 /opt/src && rm -rf Python-3.7.4.tar.gz
$ cd /opt/src/Python-3.7.4 
$ ./configure --prefix=/opt/Python-3.7.4 --enable-shared && make && make install
$ ln -snf /opt/Python-3.7.4 /usr/local/python3 && \
ln -snf /usr/local/python3/lib/pkgconfig/python3.pc /usr/lib64/pkgconfig/python3.pc && \

$ cat << EOF > /etc/profile.d/python3.sh
pathmunge /usr/local/python3/bin
EOF
$ cat << EOF > /etc/ld.so.conf.d/python3.conf
pathmunge /usr/local/python3/lib
EOF
$ ldconfig
```  
    
