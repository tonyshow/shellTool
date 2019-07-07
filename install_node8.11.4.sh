#!/bin/sh

mkdir /software/

cd software
# 下载安装包
wget https://nodejs.org/dist/v8.11.4/node-v8.11.4-linux-x64.tar.xz

#解压
tar xvf node-v8.11.4-linux-x64.tar.xz 

move  node-v8.11.4-linux-x64    nodejs

ln -s /software/nodejs/bin/node     /usr/local/bin
ln -s /software/nodejs/bin/npm     /usr/local/bin