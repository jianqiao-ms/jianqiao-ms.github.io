# Note: Sougou is not recommanded on linux, especially non-debian system. Use cloudpinyin installed.

---

# Install
```bash
$ sudo yum install fcitx fcitx-configtool fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 dpkg
...
```

**Download [sogou for linux](https://pinyin.sogou.com/linux/?r=pinyin)**
Get a package named `sogoupinyin_2.2.0.0108_amd64.deb`

**unzip(ar) package**
```bash
$ ar xv sogoupinyin_2.2.0.0108_amd64.deb
x - debian-binary
x - control.tar.gz
x - data.tar.xz
```

**install**
```bash
$ sudo tar -Jxvf data.tar.xz  -C /
$ sudo ln -snf /usr/lib/x86_64-linux-gnu/fcitx/fcitx-sogoupinyin.so /usr/lib64/fcitx/
$ sudo ln -snf /usr/share/applications/fctix.desktop ~/.config/autostart/
```
