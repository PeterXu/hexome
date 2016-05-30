title: consul集群建立及使用方式
tags: []
categories:
  - 技术
date: 2016-05-17 15:04:00
---
consul是一种为分布式系统提供查询服务的系统, 既可以支持HTTP REST的方式提供服务, 也支持DNS接口与已有的dns服务集成.

为了维持consul的高可用性, 一般通过集群的方式对分布式系统提供服务, 集群创建方法如下.

### 1. 在各节点中启动consul server 
```
agent -bind NODE1_IP -client 0.0.0.0 -data-dir /consul/data -config-dir /consul/config -ui -dc dc_consul -rejoin -server -bootstrap-expect=2
agent -bind NODE2_IP -client 0.0.0.0 -data-dir /consul/data -config-dir /consul/config -ui -dc dc_consul -rejoin -server -bootstrap-expect=2
agent -bind NODE3_IP -client 0.0.0.0 -data-dir /consul/data -config-dir /consul/config -ui -dc dc_consul -rejoin -server -bootstrap-expect=2
```

-client: 绑定的客户端地址(HTTP/DNS/RPC), 默认为127.0.0.1;  
-data-dir: agent数据存放路径;  
-config-dir: agent配置加载路径;  
-ui: 启动内建web管理界面;   
-dc: datacenter名称;  
-rejoin: agent自动重新加入集群即使之前已主动退出
-server: agent运行模式;   
-bootstrap-expect: datacenter中需求的最少server数目.  

### 2. 建立集群  
在其中一个节点中(例如在node1), 添加其余server节点
```
consul join ${NODE2_IP} 
consul join ${NODE3_IP} 
...
```

### 3. consul服务方式
应用程序有以下几种方式使用consul集群服务, 具体如下  
a. 直接连接集群中的任一个consul server;  
b. 设置haproxy(+keepalived)代理consul集群, 通过haproxy提供服务;  
c. 建立consul client然后连接client提供服务

### 4. 创建client
```
agent -advertise ${client_ip} -client 0.0.0.0 -data-dir /consul/data -config-dir /consul/config -ui -dc dc_consul -rejoin
consul join ${NODE1_IP} 
```

为防止单点故障, 每一个应用程序都可以建立属于自己的client服务.
