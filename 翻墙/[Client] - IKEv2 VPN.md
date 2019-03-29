> Example environment  
> Windows : Version 10  
> Linux : Release of CentOS7 with gnome  
> IKEv2 VPN Server : Build follow [This Guide]([Server]%20-%20IKEv2%20VPN via%20strongswan.html)


# Windows 10

### 开始 -> 设置 -> 网络和Internet -> VPN  
![img](../images/lALPDgQ9qlCeWe7NAnjNAyA_800_632.png)  

![img](../images/lALPDgQ9qlChM8DNAobNAYY_390_646.png)  

### 添加VPN连接  
![img](../images/lALPDgQ9qlCinN_M480CPA_572_227.png)  

![img](../images/lALPDgQ9qlCr8ELNAwHNAs0_717_769.png)  

### 保存

# Linux(Using NetworkManager strongswan plugin)  
### Install "NetworkManager strongswan plugin"  
`$ sudo yum install -y NetworkManager-strongswan-gnome NetworkManager-strongswan`  
reload gnome-shell with 'Alt+F2 restart'

### Get fullchain.cer to somewhere( Example in ~/Documents/certs/exmaple.com/)

### Open gnome-settting -> Select Network -> Click '+' in the VPN part  
![img](../images/Screenshot from 2019-03-29 10-50-07.png)  

### Choose IPsec/IKEv2(strongswan) -> Configure it like this:  
![img](../images/Screenshot from 2019-03-29 10-52-34.png)  

### Click Add button to save the connection