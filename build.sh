#!/usr/bin/env bash
# Release Family
DEBIAN=10
RHEL=20


function get_destribution() {
  apt 1>/dev/null 2>&1
  RETVAL=$?
  [ $RETVAL -ne 127 ] && return $DEBIAN
  yum 1>/dev/null 2>&1
  RETVAL=$?
  [ $RETVAL -ne 127 ] && return $RHEL
}

function init() { 
  [ `whoami` != 'root' ] && echo 'Need root!!!' && exit 1
  get_destribution
  RETVAL=$?
  case $RETVAL in
    10)
      echo 'Family Debian'
      curl -sL https://deb.nodesource.com/setup_12.x | bash -
      apt-get install -y node-js
      npm install -y gitbook-cli
    ;;
    20)
      echo 'Family RHEL'
      [ $((get_destribution)) = "rhel" ] && curl -sL https://rpm.nodesource.com/setup_12.x | bash
      yum install -y nodejs
      npm install -y gitbook-cli
    ;;
  esac
}

function build() {
  gitbook build . docs
}

function debug() {
  gitbook serve . docs
}

function update () {
  build
  cp CNAME docs/
  git add --all .
  git commit -m "`date +'%Y-%m-%d %H:%M:%S'`"
  git push
}

case "$1" in
  build)
    build
    ;;
  debug)
    debug
    ;;
  update)
    update
    ;;
  init)
    init
    ;;
  *)
    echo "Usage: build.sh {build|debug|update|init}" >&2
  ;;
esac
