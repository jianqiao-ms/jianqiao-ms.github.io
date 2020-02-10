> Example environment  
> System : WSL1 OS build 18362.592  
> WSL Distribution: CentOS-7.6.1810

## Annotation

* 找到可以安装CentOS的方法。Refer [LxRunOffline](https://github.com/DDoSolitary/LxRunOffline)(Failed for me)   [CentWSL](https://github.com/yuk7/CentWSL)



# WSL Install & Reset

### Install - Using LxRunOffline.exe

**Failed**

Install CentOS instead of Ubuntu.

Refer to [https://docs.microsoft.com/en-us/windows/wsl/install-win10](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

Refer to [如何安装CentOS版本的WSL](https://www.jianshu.com/p/ca22e0e08d0f)

Refer to [chocolatey](https://chocolatey.org/install)

Refer to [LxRunOffline](https://github.com/DDoSolitary/LxRunOffline)

Refer to [CentOS Docker Image](https://github.com/CentOS/sig-cloud-instance-images)



Simple description of installation:

* Enable WSL

* Install chocolatey

  **Powershell  with admin privileges**

  ```powershell
  > Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  ```

  

* Install LxRunOffline using chocolatey

  **Powershell**

  ```powershell
  > choco install LxRunOffline
  ```

  if `LxRunOffline` is not recognized by Windows, update the PATH and reopen the terminal.

  ```
  SET "PATH=%PATH%;C:\tools\lxrunoffline"
  ```

  

* Download CentOS docker image [RAW](https://raw.githubusercontent.com/CentOS/sig-cloud-instance-images/CentOS-7-x86_64/docker/centos-7-x86_64-docker.tar.xz)

* Install CentOS using LxRunOffline

  **Powershell  with admin privileges**

  ```powershell
  > LxRunOffline.exe  install -n centos -d D:\WSL\images\CentOS -f  "C:\Users\XXX\Downloads\centos-7-x86_64-docker.tar.xz"
  ```



TODO: Reinstall and record the details.



## Install - Using [CentWSL](https://github.com/yuk7/CentWSL)

Refer [https://github.com/yuk7/CentWSL](https://github.com/yuk7/CentWSL)



### Initialization

##### Create user

3. Open a bash terminal. The bash will started with root

4. Create user, create user directory ...

   ```bash
   $ useradd -M -s /bin/bash user.name
   $ usermod -a -G sudo user.name
   $ mkdir -p /home/user.name
   $ passwd user.name
   ```

##### Profiling windows disks mount

```bash
$ cat > /etc/wsl.conf << EOF
#Enable extra metadata options by default

[automount]
#enabled = true
#root = /windir/
options = "metadata,umask=22,fmask=111"
#mountFsTab = false

#Enable DNS – even though these are turned on by default, we’ll specify here just to be explicit.

[network]
generateHosts = true
generateResolvConf = true
EOF
```



##### Create user home on windows disk

Assume path is "D:\WSL\user.name"

```bash
$ cat > /etc/sudoers.d/mount << EOF
user.name ALL= NOPASSWD: /bin/mount
EOF

$ cat >> /etc/bashrc << 'EOF'
function mountHomeDir {
  user=`whoami`
  mountCount=`ls -l /home|grep $user|awk '{print $2}'`
  [ $((mountCount)) -eq 1 ] && sudo mount -t ext4 -o defaults,noatime,bind /mnt/d/WSL/$user /home/$user
}

[ `whoami` != 'root' ] && mountHomeDir
EOF
```

##### Reboot WSL

```basic
> ubuntu1804.exe config --default-user user.name
> wsl.exe -t Ubuntu-18.04
> Restart-Service LxssManager
```

##### Change yum mirrors to aliyun.com

```bash
$ wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
$ yum makecache fast
$ yum update -y
```



### Reset

Suit for distribution installed using official method.

Refer to [https://docs.microsoft.com/en-us/windows/wsl/install-win10](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

1. Open "Start" -> "Settings"

2. Go to "Apps" -> "Apps & features"

3. On the right, look for the installed WSL distro you want to reset and click it

4. The "Advanced options" link will appear. Click it to open the next page.

   ![](D:\workspace\wiki.mhonyi.com\images\Ubuntu-WSL-in-Apps-and-Features.png)

5. Under the "Reset" section, click on the "Reset" button.

   ![](D:\workspace\wiki.mhonyi.com\images\Windows-10-Reset-WSL-Distro.png)

6. It's done.



### Reboot

```basic
> Restart-Service LxssManager
```
