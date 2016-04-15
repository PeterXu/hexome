title: nginx配置和tomcat会话保持
tags:
  - nginx
  - tomcat
categories:
  - 技术
date: 2016-04-06 23:37:00
---
使用nginx提供web服务，除了配置简单以外，主要有以下两个优点：a. 高并发处理能力; b. 负载均衡。

#### 1. 高性能设置
对于高并发处理能力，通常进行如下配置。  
a. linux内核配置

```
[/etc/sysctl.d/60-kernel.conf]:
# net.core
net.core.wmem_default=8388608
net.core.rmem_default=8388608
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.netdev_max_backlog=262144
net.core.somaxconn=65535

# net.ipv4
net.ipv4.ip_forward=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.ip_local_port_range=10240 65000

# net.ipv4.tcp
net.ipv4.tcp_sack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_max_orphans=262144
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_mem=1543458 2057947 3086916
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_keepalive_time=300
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog=262144
net.ipv4.tcp_syn_retries=1
net.ipv4.tcp_synack_retries=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_max_tw_buckets=262144

[/etc/security/limits.d/nofile.conf]:
*               hard    nofile            65535 
*               soft    nofile            65535 
```

b. nginx并发配置

```
worker_processes 8; 		# cpu core num
worker_rlimit_nofile 65535; # nofile.conf
events {
    use epoll;
    worker_connections 20480;
}
```

#### 2. 负载均衡
nginx常被作为应用服务前端的反向代理服务器，很容易提供负载均衡能力，即通过proxy_pass和upstream语法实现，如下所示。
```
upstream servers {
    server host1;
    server host2;
    ...
} 
```
在该配置下，nginx按rr(round-robin)轮询模式，将用户请求分发到不同的server上进行处理，从而达到负载均衡的效果。轮询模式非常适合那些无状态的应用服务。

但是，如果针对有状态的应用服务如tomcat(即需要保持session)，轮询模式不能够保证同一用户的访问请求，总是被映射到同一台tomcat服务器上，从而导致不能正确处理同一个用户的请求，例如，用户在tomcat1上登录，然而后续的请求被发送到tomcat2上，tomcat2并不能验证该用户是否已经登录从而要求用户重新登录。

常见的解决方法，是通过nginx内建的ip_hash模式，保证同一个用户的请求始终被同一个tomcat所处理，如下所示。
```
upstream servers {
    ip_hash;
    server tomcat1;
    server tomcat2;
    ...
} 
```
然而，ip_hash不能够提供高质量的负载均衡能力。

为了让tomcat能够处理用户的session会话，常见的几种解决办法有:   
a. 建立tomcat集群共享session，任意一个tomcat均能够处理集群内其他tomcat所产生的session。  
b. 建立key/value服务(如redis/memcached)，让nginx和应用程序在这个服务中维护session达到共享的目的。  
但是，这两种解决办法增加了系统架构的复杂度，增添了潜在风险，如tomcat集群/kv服务的稳定性。

这里，还有一种比较简洁的，也是重点推荐的一种解决办法。通过将第三方模块sticky(nginx-sticky-module-ng)编译进nginx中，然后进行如下配置:
```
upstream servers {
    sticky path=/app_cookie_path;
    server tomcat1;
    server tomcat2;
    ...
} 
```
sticky模块的实现原理如下:  
a. 对upstream下的所有server进行hash标识(即每一个server有一个hash值)；  
b. 对用户请求按rr模式分配一个server，并将该server的hash值添加到用户cookie的route属性中；  
c. 对用户的随后请求，通过其cookie中的route属性值，映射到同一个tomcat服务器中进行处理。  
从而保证同一个用户的请求，始终被分配到同一个tomcat中进行处理。

<b>在sticky模块使用过程中，需要注意一个问题: 建议显示设置sticky的path值，即应用程序的cookie标识。</b>

官方文档path值为可选且默认为"/"，这是非常误导的，并且在国内网上的各种博客中都没有设置，大伙在测试demo时测试正确然后就没有下文。

正如前面sticky实现原理中所说的，sticky是通过对应用程序的cookie设置route值实现的。  

而在实际产品部署中，常见的是nginx同时配置多个应用，而每个应用都会有自己的cookie标识，而不是默认的"/"，这样导致nginx所设置的cookie route值在用户随后的访问中不起作用。