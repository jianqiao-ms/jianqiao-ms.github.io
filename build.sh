#!/usr/bin/env bash
gitbook build . docs
cp CNAME docs/
git add --all .
git commit -m "`date +'%Y-%m-%d %H:%M:%S'`"
git push