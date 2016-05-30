title: glusterfs文件同步
tags: []
categories:
  - 技术
date: 2016-05-10 17:49:00
---
rsync是一种常用的远程文件同步方法, 这里将就其几种常用方式及与glusterfs的配合使用, 作简单介绍.

### 1. rsync
可以对节点间的数据作完全同步, 不能处理增量数据, 因此只能周期性的运行.

适合作小数据的同步或者大数据的离线同步. 

### 2. inotify + rsync
在rsync的基础上添加inotify服务, 监控内核文件事件处理增量数据服务. 

该方案对增量处理没有容错能力, 只能处理inotify服务正常运行中的事件, 
故而运行一段时间后, 则数据同步不完整.

可以辅助周期性的完全同步, 保证节点间的数据一致.

### 3. lsyncd + rsync
使用lsyncd服务代替inotify服务, 在一定程度上保证其首次启动后的所有事件.
也即是除首次需要作数据完全同步之后, 后续由lsyncd保障数据增量服务(即使服务重启或网络中断也可以恢复).

与inotify类似的是, 需要监控内核文件事件, 通常只能处理节点的本地文件系统.

### 4. glusterfs

glusterfs可以通过rsync从某个节点的本地文件系统获取数据, 方式如下:
```
rsync -PavhS --xattrs --ignore-existing /data/remote_dir/ client:/mnt/gluster
```

对于glusterfs这种分布式文件系统, 没有内核事件的支持, 导致没有办法使用inotify或lsyncd支持增量处理.

故而直接使用rsync这种方式, 只能周期性的运行完全同步对数据进行同步备份.

glusterfs通常作为大数据存储服务, 这种完全同步方式性能消耗大, 同步不及时.

在glusterfs3.x及以后版本, 原生支持一种异地备份服务 - geo-replication.
geo-replication是基于ssh和rsync工具实现的一套文件同步系统, 其中, ssh用于信息控制交互, rsync用于数据同步. 相关的具体命令如下

```
gluster volume geo-replication <master_volume> config allow-network ::1,127.0.0.1
gluster volume geo-replication <master_volume> start|stop|status

# local (system and gluster)
gluster volume geo-replication <master_volume> file:///path/to/dir
gluster volume geo-replication <master_volume> /path/to/dir

gluster volume geo-replication <master_volume> gluster://localhost:volname
gluster volume geo-replication <master_volume> :volname


# remote (system and gluster)
gluster volume geo-replication <master_volume> ssh://root@remote-host:/path/to/dir
gluster volume geo-replication <master_volume> root@remote-host:/path/to/dir
gluster volume geo-replication <master_volume> ssh://root@remote-host:gluster://localhost:volname
gluster volume geo-replication <master_volume> root@remote-host::volname
gluster volume geo-replication <master_volume> gluster://host:volname
gluster volume geo-replication <master_volume> host:volname
gluster volume geo-replication dist_repl_vol slave::dist_repl_vol config use_tarssh false
```

geo-replication支持如下几种同步方式
1). master gluster volume   ->  slave local filesystem
这种方式比较简单, gluster内建文件事件, 处理增量数据发送到远程slave节点.

2). master gluster volume   ->  slave gluster volume
glusterfs-glusterfs同步要求两个volume类型及参数一致.

### 5. 同步示例

这里以distribute replica voluem(replica: 2, total: 4)为例.   
卷名为dist_replica_vol, master节点node1/node2/node3/node4, 创建方式如下:
```
gluster volume create dist_replica_vol replicat 2 node1:/data node2:/data node3:/data node4:/data
```

slave节点分别为snode1/snode2/snode3/snode4, 卷名为dist_replica_vol, 创建方式如下:  
```
gluster volume create dist_replica_vol replicat 2 snode1:/data snode2:/data snode3:/data snode4:/data
```

同步方式, 将master数据同步到slave节点上, 具体如下.

a. 请使用root用户进行同步, 其它用户潜在问题多.  
b. 设置可以通过ssh root without-password方式从master访问slave.  
对于ubuntu用户, 需要修改/etc/ssh/sshd_config:
```
PermitRootLogin without-password
改为
PermitRootLogin yes
```

在master端用root用户生成ssh public/private key, 然后将id_rsa.pub拷贝到slave上, 并将其内容添加到/root/.ssh/.authroity_keys中即可.

c. 在master端创建geo-replication  
在该master卷dist_replica_vol中的任一节点上, 如在node1中创建geo-replication volume, 如此node1和node2成为geo-replication volume的active节点, node3/node4是passive节点, 而数据处理则全部在active节点中运行.

```
# create pem
gluster system:: execute gsec_create

# create geo-replication volume 
gluster volume geo-replication dist_repl_vol snode1::dist_repl_vol create push-pem [force]

# do operations
gluster volume geo-replication dist_repl_vol snode1::dist_repl_vol start|stop|pause|status
```

d. 错误处理  
如果出现key或者gsyncd错误, 在所有gluster节点中(本地和远程)运行以下脚本
```
#!/bin/bash

cp -f /root/.ssh/id_rsa /var/lib/glusterd/geo-replication/secret.pem
cp -f /root/.ssh/id_rsa /var/lib/glusterd/geo-replication/tar_ssh.pem

cp -f /root/.ssh/id_rsa.pub /var/lib/glusterd/geo-replication/secret.pem.pub
cp -f /root/.ssh/id_rsa.pub /var/lib/glusterd/geo-replication/tar_ssh.pem.pub

mkdir -p /nonexistent/
ln -s /usr/lib/x86_64-linux-gnu/glusterfs/gsyncd /nonexistent/gsyncd

exit 0
```
