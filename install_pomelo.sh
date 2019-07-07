#!/bin/sh
 
cd software

npm install pomelo -g
ln -s /software/nodejs/lib/node_modules/pomelo/bin/pomelo /usr/local/bin/

pomelo --version