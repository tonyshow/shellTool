#!/bin/sh

# 下载安装包
wget https://nodejs.org/dist/v8.11.4/node-v8.11.4-linux-x64.tar.xz

#解压
tar xvf node-v8.11.4-linux-x64.tar.xz 

cd  node-v8.11.4-linux-x64

ln -s bin/node /usr/local/bin/node
ln -s bin/npm /usr/local/bin/npm