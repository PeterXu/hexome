title: DNS服务器dnsmasq
tags: []
categories:
  - 技术
date: 2016-04-19 00:41:00
---
在构建数据中心网络时, 建立一个独立的dns服务是必不可少的.

dns服务器有很多种, 如bind9/skydns等, 但是bind9显得笨重难以配置维护, skydns是不错的软件, 在多种分布式系统中被使用, 如google的k8s.

这里介绍另一种简洁的dns服务软件 - dnsmasq, 配置简单如下所示.

```
#listen-address=..
expand-hosts
domain=example.com
cache-size=300
#no-resolv
domain-needed

# for other servers(consul)
server=/consul./127.0.0.1#8600

# for common domain
address=/ntp.io/10.10.10.9
address=/dns.io/10.10.10.10
```

listen-address默认不配置时则在所有ip地址监听.  
expand-hosts和domain搭配使用, 自动将/etc/hosts中的名字扩展到example.com.   
no-resolv不使用/etc/resolv.conf对域名解析.  
domain-needed不转发没有格式的域名.   
server=..用于某些域名转发到其它dns server, 在这个例子中将所有以.consul为后缀的域名, 转发到127.0.0.1:8600的dns服务器进行解析.  
address=..用于定义本地网络的dns域名解析.  
