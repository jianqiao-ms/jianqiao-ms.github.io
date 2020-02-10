# OpenSSL生成根证书CA及签发子证书 [[REF oschina.net]](https://my.oschina.net/itblog/blog/651434)

#### General Process

##### 生成根证书
  * a).生成根证书私钥(pem文件)
  * b).生成根证书签发申请文件(csr文件)  
  * c).自签发根证书(cer文件)

##### 用根证书签发server端证书
  * a).生成服务端私钥
  * b).生成证书请求文件
  * c).使用根证书签发服务端证书
