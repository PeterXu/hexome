title: 分布式文件系统 - glusterfs
tags: []
categories:
  - 技术
date: 2016-05-01 10:26:00
---
分布式文件系统自身架构也可以分为集中式和分布式两种, 典型的gluster属于前者, ceph属于后者, 孰优孰劣暂不作评论, 这里将就gluster相关概念和使用方法作介绍.

### 1. glusterfs简述

gluster是基于一致性hash算法的纯分布式架构的分布式文件系统.  

从服务架构上分析, 仅存在一种节点即数据服务节点, 无单点故障. 
从系统功能上分析, 可以分成两类节点: client节点和数据服务节点.  

client节点并不存在于gluster的服务端架构中. 当应用程序需要存储服务时, 才会启动client节点为其提供服务. 实际进行各种存储调度算法逻辑, 以及保证数据的一致性和可靠性都是在client节点中进行处理. 每一个应用程序均可以拥有独立的client节点.

而服务节点是正常提供数据的被动数据存储服务, 当然也有一些内建的各种数据保障服务.  

可以看到, 对于gluster系统的升级, 通常需要同时升级服务端和客户端, 由于许多新功能和调度算法都是通过client进行实现的. 闲扯下, 21世纪初p2p技术大行天下的那几年, 对于同样的服务端(tracker), 各种p2p客户端(bt/emule/bitcomet)下载的效果大不相同.  

### 2. glusterfs卷类型
在建立glusterfs服务之前, 就需要明确定义存储的需求.

如mac osx系统存储一样, glusterfs通过volume对存储进行管理, 每一个volume对应用程序都类似一个disk. 服务支持的volume类型也基本决定了gluster分布式系统的基本架构, 简单来讲决定了gluster中服务节点的数量. 

gluster支持多种类型的volume, 常见如下所示:  

#### a. distribute volume  
分布卷是glusterfs最基本的卷类型, 最少需要两个节点.   
`$> gluster volume create dist_volume node1:/mnt/brick1/dist1 node2:/mnt/brick1/dist1`   
根据文件hash值存储到不同节点的brick, 任一个节点失败都会导致数据丢失.


#### b. replica volume  
复制卷类似于raid1, 最少需要两个节点  
`$> gluster volume create replica_volume replica 2 node1:/mnt/brick1/replica1 node2:/mnt/brick1/replica1`  
将文件存储到所有节点的brick, 任一个节点失败都不影响数据服务.

#### c. distribute replica volume
将两个或多个相同的复制卷组合在一起构成分布复制卷, 最少需要4个节点.
    
创建方式一: 在2)复制卷上再添加一组
`$> gluster volume add-brick replica_volume node3:/mnt/brick1/replica1 node4:/mnt/brick1/replica1`   
replica_volume从复制卷变成一个分布式复制卷.  
    
创建方式二: 全新创建  
`$> gluster volume create distribute_replica_volume replica 2 node1:/mnt/brick1/replica1 node2:/mnt/brick1/replica1 node3:/mnt/brick1/replica1 node4:/mnt/brick1/replica1`   
	
注意, node1&node2和node3&node4分别是一个复制卷, 然后共同构建成一个分布卷. 在此例中最多可以容忍两个节点失败, 但只能是复制卷1中(node1&node2)的任一个节点, 以及复制卷2(node3&node4)中的任一个节点.

分布复制卷的存储逻辑是, 首先根据文件的hash值选中一个复制卷, 然后将数据拷贝到这个复制卷中所有节点的brick.

#### d. disperse volume
离散卷是一种高级卷，通过rs码构建冗余数据保证数据的可靠性和一致性(类似raid5). 创建方式如下:  
```
$> gluster volume create disperse_volume disperse 5 redundancy 2  node1:/mnt/brick1/disp1 node2:/mnt/brick1/disp1 node3:/mnt/brick1/disp1 node4:/mnt/brick1/disp1 node5:/mnt/brick1/disp1
```
disperse: 离散卷的数目  
redundancy: 冗余卷的数目

这里的设置意味着根据5个卷中的任意3个卷可以计算得到所有的存储数据, 也即是说, 五个节点中可以容忍任意2个节点down. 具体设置的优化值请参照官方. 其数据存储逻辑是:　按照2/5冗余值, 从文件内容计算出新内容, 然后将结果存储到五个节点中.

#### e. distribute disperse volume  
类似于分布复制卷, 将多个离散卷进行合并, 即可构成一个分布离散卷. 


### 3. glusterfs建立服务

glusterfs所有节点都是平等的, 因此可以简单的从其中任一个节点, 去建立一个完整的分布式网络服务, 如下所示:  
```
$> gluster peer probe host1
$> gluster peer probe host2
$> gluster peer probe host3
$> gluster peer probe host4
$> gluster peer probe host5
$> gluster peer status
```
删除节点操作如下:
`$> gluster peer detach host5`


### 4. glusterfs管理优化

glusterfs卷管理操作命令:  
```
$>gluster volume start|stop|delete <volname>
$>gluster volume add-brick|remove-brick <volname> …
$>gluster volume rebalance <volname> start|stop|status
$>gluster volume heal <volname> [full|info..]
$>gluster volume get <volname> all
$>gluster volume set <volname> key value
$>gluster volume log rotate <volname>
$>gluster volume top <volname> …
$>gluster volume status all|<volname> …
$>gluster volume replace-brick <volname> commit force
$>gluster volume shared profile start|info|stop
$>gluster volume profile start|info|stop
```

优化属性(针对小文件)
```
# Specifies the number of network connections to be handled simultaneously by the client processes 
gluster volume set <volname> client.event-threads 4

# Specifies the number of network connections to be handled simultaneously by the server processes 
gluster volume set <volname> server.event-threads 4

gluster volume set <volname> cluster.lookup-optimize on

# Specifies whether proactive self-healing on replicated volumes is activated.
gluster volume set <volname> cluster.self-heal-daemon on|off
gluster volume set <volname> performance.readdir-ahead on|off
```

控制访问
```
auth.allow *|ip|hostname
auth.reject none|ip|hostname
```


其它属性设置
```
cluster.min-free-disk
cluster.weighted-rebalance

performance.cache-size
performance.cache-min-file-size
performance.cache-max-file-size

performance.write-behind: off
server.allow-insecure: on
cluster.server-quorum-type: server
cluster.quorum-type: auto
network.remote-dio: enable
cluster.eager-lock: enable
performance.stat-prefetch: off
performance.io-cache: off
performance.read-ahead: off
performance.quick-read: off
```

### 5. glusterfs应用服务

通过以上方式成功建立了glusterfs分布式文件服务. 具体使用还需要在应用程序节点上, 通过gluster client建立虚拟磁盘节点(如使用gluster mount), 随后应用程序即可通过类似访问本地磁盘的方式对gluster磁盘进行数据读取.  
故而, 各个节点应用程序都可以通过gluster文件系统, 方便地进行数据共享服务.