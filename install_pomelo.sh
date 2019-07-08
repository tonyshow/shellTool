#!/bin/sh
 
cd software

npm install pomelo -g
ln -s /software/nodejs/lib/node_modules/pomelo/bin/pomelo /usr/local/bin/

pomelo --version

scp ./output/%s  root@39.108.249.105:/localhost/www/localhost/platform/public/qppf_hot_update