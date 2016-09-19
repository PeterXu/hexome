title: linux-logrotate
date: 2016-09-13 10:15:02
tags:
---
title: linux-logrotate
tags:
---


```
#!/bin/bash

set -e

logs=""
for it in /opt/*_root; do
    log="$it/logs/catalina.out"
    if [ -f $log ]; then
        echo $it
        [ "$logs" = "" ] && logs="$log" || logs="$logs\n$log"
    fi
done


[ "$logs" = "" ] && exit 0

echo "$logs" > /tmp/tomcat

cat >> /tmp/tomcat <<EOF
{
  copytruncate
  daily
  rotate 90
  delaycompress
  missingok
  dateformat .%Y-%m-%d
  dateext
  create 640 root adm
}
EOF

echo "set in /etc/logrotate.d/tomcat"
sudo mv /tmp/tomcat /etc/logrotate.d/tomcat
sudo chown root:root /etc/logrotate.d/tomcat
sudo chmod 644 /etc/logrotate.d/tomcat

exit 0
```