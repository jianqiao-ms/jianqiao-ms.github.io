# 开始之前
### 系统要求
* Disable swap
* Lastest verified docker version 18.06.2 (package name will be "docker-ce-18.06.2.ce")
* One or more machines running a deb/rpm-compatible OS, for example Ubuntu or CentOS
* 2 GB or more of RAM per machine. Any less leaves little room for your apps.
* 2 CPUs or more on the control-plane node
* Full network connectivity among all machines in the cluster. A public or private network is fine.

# 安装kubeadm
## 安装运行时(runtime) [[REF]](../Applications/docker.md) 
禁用swap
```bash
$ swapoff -a
``` 

## 安装kubeadm、kubelet、kubectl [[REF]](https://opsx.alibaba.com/mirror)  
> 使用阿里镜像站代替官方kubernetes仓库  

```bash
$ cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
$ setenforce 0
$ sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

$ yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

$ systemctl enable --now kubelet

```

#### kubeadm 常用命令
* kubeadm init 启动一个 Kubernetes 主节点
* kubeadm join 启动一个 Kubernetes 工作节点并且将其加入到集群
* kubeadm upgrade 更新一个 Kubernetes 集群到新版本
* kubeadm config 如果使用 v1.7.x 或者更低版本的 kubeadm 初始化集群，您需要对集群做一些配置以便使用 kubeadm upgrade 命令
* kubeadm token 管理 kubeadm join 使用的令牌
* kubeadm reset 还原 kubeadm init 或者 kubeadm join 对主机所做的任何更改
* kubeadm version 打印 kubeadm 版本
* kubeadm alpha 预览一组可用的新功能以便从社区搜集反馈

## 配置控制节点CGroup [[REF kubernetes.io]](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-control-plane-node)
使用Docker做为运行时不用手动配置

# 使用kubeadm创建单节点集群

#### 在有条件的机器上获取镜像列表
```bash
$ kubeadm config images list
  k8s.gcr.io/kube-apiserver:v1.15.1
  k8s.gcr.io/kube-controller-manager:v1.15.1
  k8s.gcr.io/kube-scheduler:v1.15.1
  k8s.gcr.io/kube-proxy:v1.15.1
  k8s.gcr.io/pause:3.1
  k8s.gcr.io/etcd:3.3.10
  k8s.gcr.io/coredns:1.3.1
```

#### 拉取镜像 [[REF]](https://zhuanlan.zhihu.com/p/46341911)


```bash
$ images=(
  kube-apiserver:v1.15.1
  kube-controller-manager:v1.15.1
  kube-scheduler:v1.15.1
  kube-proxy:v1.15.1
  pause:3.1
  etcd:3.3.10
  coredns:1.3.1
)

$ for imageName in ${images[@]} ; do
    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done

$ docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-apiserver            v1.15.1             68c3eb07bfc3        10 days ago         207MB
k8s.gcr.io/kube-controller-manager   v1.15.1             d75082f1d121        10 days ago         159MB
k8s.gcr.io/kube-scheduler            v1.15.1             b0b3c4c404da        10 days ago         81.1MB
k8s.gcr.io/kube-proxy                v1.15.1             89a062da739d        10 days ago         82.4MB
k8s.gcr.io/coredns                   1.3.1               eb516548c180        6 months ago        40.3MB
k8s.gcr.io/etcd                      3.3.10              2c4adeb21b4f        8 months ago        258MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        19 months ago       742kB
```

#### Init cluster
```bash
$ kubeadm init
```

#### 加入其他节点  
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.27.108.107:6443 --token oba8yt.qw5dfi4dwg0t3xa4 \  
    --discovery-token-ca-cert-hash sha256:b533650e5a1e397e04e471dea3a6dd709d8dc88671eaf6d17d4bbd3651bd2401 

# 安装网络插件 [[REF Github]](https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md)

[kubernetes.io插件介绍](https://kubernetes.io/docs/concepts/cluster-administration/addons/)  

选用Flannel
* [1. Prepare node](https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md#1-preparing-the-nodes)  
  确认vm使用的网卡驱动正确.(默认是e1000,需要VMXNET3)
  ```bash
  $ sudo lshw -class network -businfo
  ```
  * [1.1 Setting up network adapter(s)](https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md#11-setting-up-network-adapters)
  TODO: What is DPDK?
  
    ```bash
    $ modprobe vfio-pci
    $ lsmod |grep vfio-pci
      vfio_pci               41268  0 
      vfio                   32657  2 vfio_iommu_type1,vfio_pci
      irqbypass              13503  1 vfio_pci
    ```
  * [1.2 Setting up the VPP vSwitch to use the network adapters](https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md#12-setting-up-the-vpp-vswitch-to-use-the-network-adapters)  
    * [Setup a node with multiple NICs](https://github.com/contiv/vpp/blob/master/docs/setup/MULTI_NIC_SETUP.md) (preferred; one NIC for management and one for VPP)
    * [Setting up a node with a single NIC](https://github.com/contiv/vpp/blob/master/docs/setup/SINGLE_NIC_SETUP.md) (for nodes with only single NIC)
  
    暂时选择使用单网卡  
    * Installing the STN daemon
      ```bash
      $ bash <(curl -s https://raw.githubusercontent.com/contiv/vpp/master/k8s/stn-install.sh)
      ```
      Check that the STN daemon is running:
      ```bash
      $ docker ps -a 
        CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
        550334308f85        contivvpp/stn       "/stn"              33 seconds ago      Up 33 seconds                           contiv-stn
      ```
      Check that the STN daemon is operational:
      ```bash
      $ docker logs contiv-stn
      ```
    * Creating VPP configuration [[REF]](https://github.com/contiv/vpp/blob/master/docs/setup/VPP_CONFIG.md#single-nic-configuration)  
    * [Configuring STN in Contiv-VPP K8s deployment files](https://github.com/contiv/vpp/blob/master/docs/setup/SINGLE_NIC_SETUP.md#configuring-stn-in-contiv-vpp-k8s-deployment-files)
      > The STN feature is disabled by default. It needs to be enabled either globally, or individually for every node  
       in the cluster.
      
      Get vpp setup source
      ```bash
      $ git clone https://github.com/contiv/vpp.git
      ```
      Modify
      ```bash
      data:
        contiv.conf: |-
          ...
          stealFirstNIC: True
          ...
      ```
  * [2. Installing & intializing Kubernetes (using kubeadm)]() 
  
    enable [Hugepages](https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md#hugepages)
    ```bash
    $ sysctl -w vm.nr_hugepages=512
    $ echo "vm.nr_hugepages=512" >> /etc/sysctl.d/hugepages.conf
    $ service kubelet restart
    ```
    
  * [Installing the Contiv-VPP CNI plugin](https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md#4-installing-the-contiv-vpp-cni-plugin)
    ```bash
    $ bash <(curl -s https://raw.githubusercontent.com/contiv/vpp/master/k8s/pull-images.sh)
    $ kubectl apply -f ./vpp/k8s/contiv-vpp.yaml
    ```