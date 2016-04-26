title: 系统监控及日志收集elk+beats
tags: []
categories:
  - 技术
date: 2016-04-18 23:13:00
---
针对数据中心的监控, 许多公司积极响应并开源自己的方案, 传统的有nagios和zabbix等.

当前比较流行的方案有flume/scribe/openfalcon/elk(beats), 这里将具体介绍下elk.

最新官方建议使用轻量级的beats(golang)取代logstash作为客户端, beats收集数据发送到logstash broker或者直接发送到elasticsearch. 

笔者建议使用beats => logstash => elasticsearch => kibana这种数据流, 利用logstash可以对数据作额外处理以及减少系统耦合性.  


##### beats客户端

beats包含多种工具, 常用的有三种:  
topbeat: 主要监控系统的cpu/memory/disk, 周期性的收集系统数据.  
filebeat: 用于收集系统和应用程序日志, 发送日志到logstash作额外处理可以收集感兴趣的信息.
packetbeat: 用于嗅探系统网络信息(被动), 如http/mysql/等等.

但是, topbeat中没有收集linux系统/proc/net基本信息的功能, 而是集成到packetbeat中显得稍笨重不方便使用.


##### logstash
logstash起初是作为elk中的客户端, 但作为一个收集系统基本数据的工具, 而显得太笨重而一直被诟病.  
尽管如此, logstash提供了许多插件功能极其丰富, 很适合作为broker节点.

logstash的数据处理通常有三部分构成, 分别对应于三种插件:  
(1) input插件, 获取数据, 比如监听端口或者从消息队列中订阅数据.  
(2) filter插件, 对收集到的数据作进一步的处理, 例如解析ip地址为经纬度.  
(3) output插件, 输出数据到其它服务中,如elasticsearch/kafka/zeromq.  

##### elasticsearch
终于回到正题了, elasticsearch是基于lucence引擎的一套简单高可用系统, 提供了非常方面的nosql/rest服务的功能, 也是这套监控系统的核心所在. 

最新版本的elasticsearch可以很方便建立一个分布式集群, 在该集群中通常有master和数据这两大类节点.

(1) 节点属性
```
cluster.name: es_cluster    # 集群名
node.name: ${HOSTNAME}		# 将hostname作为节点名字
node.master: true			# 节点是否可以被选作为master节点
node.data: true				# 节点是否可以被选作为data节点
```
这里注意, 如果node.master和node.data均为false, 则该节点是一个仲裁节点, 类似nginx负载均衡的功能.

(2) 发现机制zen
```
discovery.zen.ping.multicast.enabled: false
discovery.zen.ping_interval: 3s
discovery.zen.ping_timeout: 30s
discovery.zen.ping_retries: 5
discovery.zen.ping.unicast.hosts: "host1", "host2:9300"
```
采用unicast方式显示设置集群中的节点, 默认各个节点之间使用的端口是9300.

(3) 配置网络
```
# network
network.host: 0.0.0.0
network.bind_host: 0.0.0.0
network.publish_host: 0.0.0.0

# http service
http.compression: true
http.compression_level: 3
```

##### kibana
收集数据是为了展现, kibana即是一种基于elasticsearch数据展现的工具.  
kibana默认提供了topbeat/filebeat/packetbeat等的数据展示模版. 


##### elastalert
作为一个监控系统, 报警机制不得缺少, elastic官方提供的收费方案比较简单.
这里介绍一种免费开源方案, 那就是[elastalert](https://github.com/Yelp/elastalert.git), 具体参考官方代码.

