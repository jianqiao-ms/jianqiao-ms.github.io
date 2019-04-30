# Install  
```bash
$ sudo yum install fcitx fcitx-configtool fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 dpkg
...
```

__Download (sogou for linux)[https://pinyin.sogou.com/linux/?r=pinyin]__  
I get a package named `sogoupinyin_2.2.0.0108_amd64.deb`

__unzip(ar) package__    
```bash
$ ar xv sogoupinyin_2.2.0.0108_amd64.deb
x - debian-binary
x - control.tar.gz
x - data.tar.xz
```  

__install__  
```bash
$ sudo tar -Jxvf data.tar.xz  -C /
$ sudo ln -snf /usr/lib/x86_64-linux-gnu/fcitx/fcitx-sogoupinyin.so /usr/lib64/fcitx/
$ sudo ln -snf /usr/share/applications/fctix.desktop ~/.config/autostart/
```