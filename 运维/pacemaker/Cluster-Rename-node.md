# Cluster node 修改系统主机名

1. `hostnamectl --static set-hostname HOSTNAME`
2. Update hosts file
3. Update /etc/corosync/corosync.conf  
4. Relogin to Shell/SSH  
5. `export EDITOR=/usr/bin/vi`  
6. `pcs cluster edit --config`  
Modify all HOSTNAME related strings to newer ones, examples:  
`1,$s/OLDHOSTNAME/NEWHOSTNAME/g`