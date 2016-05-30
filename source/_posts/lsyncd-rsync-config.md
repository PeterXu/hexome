title: lsyncd+rsync文件同步
tags: []
categories:
  - 技术
date: 2016-05-15 11:02:00
---
Lsyncd (Live Syncing Daemon), 用于实时将本地文件备份到远程目录, 集成了inotify/fsevents服务, 能够支持rsync/ssh多种数据同步方式.
 
这里将介绍lsyncd+rsync的基本使用.

### 1. 简单示例
```
lsyncd -rsync /home remotehost.org::share/
```
监控本地目录/home的文件事件, 实时将其更新到远程rsync服务share模块的目的目录中.
```
lsyncd -rsyncssh /home remotehost.org backup-home/
```
监控本地目录/home的文件事件, 但通过ssh实时将其更新到远程目录backup-home中. (需要设置ssh为无密码登录).
 
### 2. lsyncd+rsync模式 

#### 0). 基本数据流
 
a. 源节点: lsyncd服务端 + rsync客户端  
b. 目的节点: rsyncd服务端

数据流方向: 将文件从源节点中备份到目的节点的存储空间中.
 
 
#### 1). 源文件端
 
##### a. lsyncd服务配置文件
 
/etc/lsyncd/lsyncd.conf
```
settings {
    logfile         = "/var/log/lsyncd.log",
    statusFile      = "/var/run/lsyncd.status",
    nodaemon        = false,
    statusInterval  = 10,
    inotifyMode     = "CloseWrite",
    maxProcesses    = 4,
    maxDelays       = 4
}

sync {
    default.rsync,
    source      = "/tmp/src",
    target      = "rsync_user@192.168.10.10::rsync_mod",
    -- init        = false,
    delay       = 30,
    exclude     = { "lost+found", ".tmp", ".*" },
    -- excludeFrom = "/etc/rsync_exclude.lst",
    delete      = "running",

    rsync       = {
        binary      = "/usr/bin/rsync",
        password_file = "/etc/lsyncd/rsyncd.pass",
        _extra = {"--temp-dir=/tmp/"},

        bwlimit     = 4096, -- kb/s
        archive     = true,
        compress    = true,
        verbose     = true
    }
}
```

stausFile: 定义状态文件, 记录已经处理的事件.  
nodaemon=false: 表示启用守护模式，默认前端模式.  
statusInterval: 将lsyncd的状态写入上面的statusFile的间隔，默认10秒.  
inotifyMode: 指定inotify监控的事件，默认是CloseWrite.  
```
Modify
CloseWrite
CloseWrite or Modify
```
maxProcesses: 同步进程(如rsync/ssh)的最大个数.  
maxDelays: 累计到多少监控的事件激活一次同步，即使sync中delay延迟时间还未到.  

sync同步参数:  
```
default.rsync: 使用rsync进行备份(本地或远程);  
default.direct: 使用cp/rm等命令进行本地备份;  
default.rsyncssh: 同步到远程主机目录，rsync的ssh模式; 
```

source: 源目录，使用绝对路径;  
target: 支持配置如下,  
```
a) rsync远程目录同步(如remote_host::rsync_mod), 用于rsync模式    
b) 本地目录同步(如/tmp/dest), 可用于direct和rsync模式  
c) ssh远程目录同步(remote_host:/tmp/dest): 可用于rsync和rsyncssh模式  
```

init: 当init = false, 只同步进程启动以后发生改动事件的文件，原有目录即使有差异也不会同步; 默认是true(但不能显示设置init = true).  
delay: 累计事件延迟时间默认15秒, 避免过于频繁的同步.

delete: 保持target与souce同步.
```
delete	=	true	Default. Lsyncd will delete on the target whatever is not in the source. At startup and what's being deleted during normal operation.
delete	=	false	Lsyncd will not delete any files on the target. Not on startup nor on normal operation. (Overwrites are possible though)
delete	=	'startup'	Lsyncd will delete files on the target when it starts up but not on normal operation.
delete	=	'running'	Lsyncd will not delete files on the target when it starts up but will delete those that are removed during normal operation.
```
bwlimit: rsync同步限速(kb/s).  
compress: 压缩传输默认为true.  
perms: 默认保留文件权限.  

注意: lsyncd.conf可以有多个sync模块，独立配置互不影响。

##### b. 配置rsync密码

密码文件/etc/lsyncd/rsyncd.pass:
```
rsyncd_password
```

设置密码文件权限
```
chown root:root /etc/lsyncd/rsyncd.pass
chmod 0400 /etc/lsyncd/rsyncd.pass
```

#### 2). 目的文件端

##### a. rsyncd服务端
配置文件/etc/rsyncd.conf
```
# sample rsyncd.conf configuration file

# GLOBAL OPTIONS
motd file=/etc/motd
log file=/var/log/rsyncd
# for pid file, do not use /var/run/rsync.pid if
# you are going to run rsync out of the init.d script.
# The init.d script does its own pid file handling,
# so omit the "pid file" line completely in that case.
pid file=/var/run/rsyncd.pid
syslog facility=daemon
#socket options=

# MODULE OPTIONS
[rsync_mod]
comment = public archive
path = /mnt/backup/data
use chroot = no
max connections = 4
lock file = /var/lock/rsyncd
read only = no
hosts allow = 192.168.0.1/24

uid = root
gid = root
auth users = rsync_user
secrets file = /etc/rsyncd.scrt
strict modes = yes

timeout = 600
#refuse options = checksum dry-run
dont compress = *.gz *.tgz *.zip *.z *.rpm *.deb *.iso *.bz2 *.tbz *.png *.jpg *.jpeg *.gif

```

##### b. 配置rsyncd密码

密码文件/etc/rsyncd.scrt:
```
rsync_user:rsyncd_password
```

设置密码文件权限
```
chown root:root /etc/rsyncd.scrt
chmod 0400 /etc/rsyncd.scrt
```

##### c. 启动rsyncd服务
在ubuntu上默认rsyncd服务不能通过init.d/upstart启动, 需要修改配置文件/etc/default/rsync:
```
RSYNC_ENABLE=false
修改为
RSYNC_ENABLE=true
```
