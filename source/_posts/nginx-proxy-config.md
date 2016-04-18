title: Nginx反向代理的压缩设置和日志格式
tags: []
categories:
  - 技术
date: 2016-04-09 21:29:00
---

使用Nginx作反向代理时，在实际部署中对代理压缩和日志格式作一些调整，以提高性能和便于后续的数据处理。

在之前一篇[《nginx配置和tomcat会话保持》](http://zenvv.com/2016/04/06/nginx-tomcat-config/)的基础上作一些总结和加强。

#### 1. 反向代理压缩

```
http {
	...
    
    gzip  on;
    gzip_disable "msie6";

    gzip_vary on;
    gzip_proxied any;
    gzip_min_length 1k;
    gzip_comp_level 3;
    gzip_buffers 16 8k;
    gzip_http_version 1.0;
    gzip_types text/plain text/css application/json application/x-javascript application/javascript text/javascript application/xml;
}
```
如果被代理的服务器已经打开gzip, 则此处建议关闭`gzip_proxied off;`。


#### 2. 反向代理日志格式

```
http {
	...
    
    log_format access '$remote_addr - $remote_user [$time_local] "$request" $http_host '
        '$status $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for" '
        '$upstream_addr $upstream_status $upstream_cache_status '
        '"$upstream_http_content_type" $upstream_response_time > $request_time';
    
}
```


```
server {
	server_name vhost;
	access_log /var/log/nginx/access_vhost.log access;
}
```

设置目的是记录用户地址和处理服务器地址，便于作数据分析和系统监控。