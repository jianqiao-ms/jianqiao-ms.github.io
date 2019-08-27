> Example environment  
SSH_PORT = 22  
No ipv6 supported for now

*TODO: Basic kernel performance profiling with sysctl*  

# Disable Selinux
```bash
$ cp /etc/selinux/config /etc/selinux/config.init
$ sed -i '/SELINUX=/d' /etc/selinux/config && \
    sed -i '5i SELINUX=disabled' /etc/selinux/config
```

# Profiling OpenSSH Server Configurations  
Examples:
```bash
$ new_port=10086
$ cp /etc/ssh/sshd_config /etc/ssh/sshd_config.init
$ cp /etc/postfix/main.cf   /etc/postfix/main.cf.init
$ old_port=`ss -anlp|grep sshd|grep tcp|awk '{printf $5}'|cut -d ':' -f2` && \
    eval "sed -i '/^Port $old_port/d' /etc/ssh/sshd_config" && \
    echo 'Port $new_port' >> /etc/ssh/sshd_config
$ sed -i '/^AddressFamily/d' /etc/ssh/sshd_config && \
    echo 'AddressFamily inet' >> /etc/ssh/sshd_config
$ sed -i '/^inet_protocols/d' /etc/postfix/main.cf && \
    echo 'inet_protocols = ipv4' >> /etc/postfix/main.cf
```

# Install epelrepo and other essential tools debugging system  
```bash
$ yum install -y epel-release net-tools tcpdump telnet iperf3 nload iptables-services git unzip unar wget
$ yum update -y
$ yum install -y python36 python36-pip
$ pip3.6 install -U pip
```

# Disable ipv6
```bash
$ echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/disable-ipv6.conf
$ echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/disable-ipv6.conf
$ sysctl -p /etc/sysctl.d/disable-ipv6.conf
```

# Change ensp** device to eth*
```bash
$ cp /etc/default/grub /etc/default/grub.bak
$ opts=`cat /etc/default/grub |grep -e '^GRUB_CMDLINE_LINUX='|cut -c21-|sed 's/.$//'`
$ sed -i '/^GRUB_CMDLINE_LINUX=/d' /etc/default/grub && \
    echo "GRUB_CMDLINE_LINUX=\"$opts net.ifnames=0 biosdevname=0\"" >> /etc/default/grub && \
    grub2-mkconfig -o /boot/grub2/grub.cfg
```

# Profiling fstab
```bash
$ cp /etc/fstab /etc/fstab.bak
$ sed -i 's/,noatime//g' /etc/fstab && \ 
    sed -i 's/defaults/defaults,noatime/g' /etc/fstab
```

# Disable normally useless services
```bash
$ systemctl disable postfix
$ systemctl disable firewalld
$ systemctl disable NetworkManager
```

# Firewall(iptables)
```bash
SSH_PORT=10086
$ iptables -F
$ iptables -P INPUT ACEPT
$ iptables -A INPUT -p tcp -m state --state RELATE,ESTABLISHED -j ACCEPT
$ iptables -A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
$ iptables -A INPUT -p tcp -m state --state NEW,ESTABLISHED --dport $SSH_PORT -j ACCEPT
$ iptables -P INPUT DROP
$ service iptables save
$ systemctl restart iptables
```

# Create data directory
```bash
$ mkdir -p /data
```

# Alias rm to trash  
*TODO: Add function list trash & restore-from-trash*  

Alias rm to 'move to trash'.   
Add follow function to /etc/bashrc  
```text
function rm() {
  case $# in
    0)
      echo 'Usage:::rm [options] [path]' 
      echo 'All options will be ignored.But must be start with -.'
      echo 'Input any options for fun!' 
      return 1;;
    1)
      [ ! -e $1 ] && echo 'No such file or directory [$1]' && return 2
      gio trash $1;;
    2)
      [ ${1:0:1} == '-' ] && [ ! -e $2 ] && echo 'No such file or directory [$2]' && return 2
      gio trash $2;;
    *)
      ALLFILES=${@:2:$(($# - 1))}
      for file in $ALLFILES
      do
        gio trash `realpath -- $file`
      done;;
  esac
}
```