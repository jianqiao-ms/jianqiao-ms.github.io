> Example environment
System : CentOS 7 x64

# Install
[REF Electron 文档](https://electronjs.org/docs/tutorial/installation)
[REF 国内配置Electron开发环境的正确方式](https://blog.yasking.org/a/zh-install-electron-development.html)

```bash
$ yarn config set registry https://registry.npm.taobao.org
$ export ELECTRON_MIRROR="https://npm.taobao.org/mirrors/electron/"
$ yarn global add electron electron-builder node-sass
```
