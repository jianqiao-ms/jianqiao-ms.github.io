> Example environment  
> System : WSL1 OS build 18362.592  
> WSL Distribution: CentOS-7.6.1810  
> BIND version: 9.11.4



# Install

From CentOS Base yum repo:

```
$ sudo yum insatll -y bind
```



# Configuration

I use bind only for dns cache, so the configuration is simple. Just change several options in the default configuration file:

* `pid-file "run/named.pid";` => `pid-file "/var/run/named.pid";`

  Adapte for the init.d script. Why don't modify the pid file location in init.d script? Because the install procedure didnot create the /run/named directory.

* `dnssec-validation yes;` ==> `dnssec-validation no;`

  speed up dns recursion

* Add forwarders:

  ```text
         forwarders {
           114.114.114.114;
           10.25.2.30;
           223.5.5.5;
           10.26.2.30;
         };
  ```

* generate rndc configuration

  ```bash
  $ rndc-confgen > /etc/rndc.conf
  ```

* copy similar paragram from /etc/rndc.conf into /etc/named.conf as list below:

  ```
  # Use with the following in named.conf, adjusting the allow list as needed:
  key "rndc-key" {
        algorithm hmac-md5;
        secret "7dqHX7NxVqTcHp5xqvUlmA==";
  };
  
  controls {
        inet 127.0.0.1 port 953
                allow { 127.0.0.1; } keys { "rndc-key"; };
  };
  # End of named.conf
  ```

  Start the named daemon and test the rndc utility with `rndc status`

  ![image-20200210191804850](D:\workspace\wiki.mhonyi.com\images\DNS-Server-on-WSL\image-20200210191804850.png)

* make init.d service file for named daemon

  since WSL donot boot with systemd, so the best way for managing service is traditional init.d scripts, I found a init.d script template file from Internet(so I fotgot the source address) and it works for many applications with just a few options to change.

  named version init.d script:

  ```bash
  #!/bin/sh
  #
  # named        Startup script for Apache Hypertext Transfer Protocol Server
  #
  # processname: named
  # pidfile: /var/run/named.pid
  # description: Apache Hypertext Transfer Protocol Server
  
  DESC=named
  NAME=named
  DAEMON=/usr/sbin/named
  PIDFILE=/var/run/$NAME.pid
  LOCKFILE=/var/lock/$NAME
  SCRIPTNAME=/etc/init.d/$NAME
  RETVAL=0
  
  DAEMON_OPTS="-u named -c /etc/named.conf -f -4"
  
  # Exit if the package is not installed
  [ -x $DAEMON ] || exit 0
  
  # Read configuration variable file if it is present
  [ -r /etc/default/$NAME ] && . /etc/default/$NAME
  
  # Source function library.
  . /etc/rc.d/init.d/functions
  
  start() {
    local pids=$(pgrep -f $DAEMON)
    if [ -n "$pids" ]; then
      echo "$NAME (pid $pids) is already running"
      RETVAL=0
      return 0
    fi
  
    echo -n $"Starting $NAME: "
  
    $DAEMON $DAEMON_OPTS 1>/dev/null 2>&1 &
  #  echo $! > $PIDFILE
  
    sleep 2
    pgrep -f $DAEMON >/dev/null 2>&1
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
      success; echo
      touch $LOCKFILE
    else
      failure; echo
    fi
    return $RETVAL
  }
  
  stop() {
    local pids=$(pgrep -f $DAEMON)
    if [ -z "$pids" ]; then
      echo "$NAME is not running"
      RETVAL=0
      return 0
    fi
  
    echo -n $"Stopping $NAME: "
    #killproc -p ${PIDFILE} ${NAME}
    /usr/sbin/rndc stop > /dev/null 2>&1 || killproc -p ${PIDFILE} ${NAME}
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${LOCKFILE} 
  #${PIDFILE}
  }
  
  reload() {
    echo -n $"Reloading $NAME: "
    #killproc -p ${PIDFILE} ${NAME} -HUP
  
    /usr/sbin/rndc reload > /dev/null 2>&1 || killproc -p ${PIDFILE} ${NAME} -HUP
  
    RETVAL=$?
    echo
  }
  
  rh_status() {
    status -p ${PIDFILE} ${DAEMON}
  }
  
  # See how we were called.
  case "$1" in
    start)
      rh_status >/dev/null 2>&1 && exit 0
      start
      ;;
    stop)
      stop
      ;;
    status)
      rh_status
      RETVAL=$?
      ;;
    restart)
      stop
      start
      ;;
    reload)
      reload
    ;;
    *)
      echo "Usage: $SCRIPTNAME {start|stop|status|reload|restart}" >&2
      RETVAL=2
    ;;
  esac
  exit $RETVAL
  ```

  