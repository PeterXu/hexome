#!/bin/sh

dpath=$(dirname $0)
pkill -9 hexo
sleep 1

cd $dpath && nohup hexo server -d &

exit 0
