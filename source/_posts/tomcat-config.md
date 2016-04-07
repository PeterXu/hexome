title: Tomcat常用配置
tags: []
categories:
  - 技术
date: 2016-04-07 21:22:00
---
tomcat默认配置已能满足正常需求，为了优化服务可以进行以下的简单设置。

#### 1. 设置Connector(server.xml) 

```
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               acceptCount="1024"
               maxThreads="512"
               minProcessors="16" 
               maxProcessors="512"
               minSpareThreads="16" 
               maxSpareThreads="64"
               URIEncoding="UTF-8"
               useURIValidationHack="false"
               enableLookups="false"
               compression="on"
               compressionMinSize="2048" 
               compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain"
               redirectPort="8443" />

```
这里主要调整acceptCount/max(min)[Spare]Threads/min(max)Processors
这几个参数，提高并发处理能力，具体参照官方文档；其次对一些文本文件进行压缩(compression=on)。


#### 2. nginx前端+tomcat后端的配置  

首先, nginx作为反向代理前端，需要设置将用户信息传送到tomcat。
```
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-Ip $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_set_header Cookie $http_cookie;
        proxy_pass http://tomcat;
    }
```

其次，tomcat将这些真实用户信息写到日志中(默认是代理nginx的信息)(server.xml)。
```
      <Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">
      
        <Valve className="org.apache.catalina.valves.RemoteIpValve"
           remoteIpHeader="x-forwarded-for"
           remoteIpProxiesHeader="x-forwarded-by"
           protocolHeader="x-forwarded-proto"
        />

        <Context path="/" docBase="" debug="0" privileged="true" reloadable="false"/>

        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt" resolveHosts="false"
               pattern="%h %l %u %t &quot;%r&quot; %s %b %{x-forwarded-for}i" />

      </Host>
```
这里存在另一个细节，在产品部署中建议设置reloadable="false"以提高tomcat性能。

#### 3. tomcat启动设置
tomcat使用的是java默认参数，实际部署中可以根据系统的具体性能进行调整，如下所示将其添加到tomcat的启动脚本catalina.sh和daemon.sh中。
```
JAVA_OPTS="-server
-Xms1024M -Xmx1024M -Xss512k
-XX:+AggressiveOpts
-XX:+UseBiasedLocking
-XX:+DisableExplicitGC
-XX:+UseConcMarkSweepGC
-XX:+UseParNewGC
-XX:+CMSParallelRemarkEnabled
-XX:+UseCMSCompactAtFullCollection
-XX:LargePageSizeInBytes=128m
-XX:+UseFastAccessorMethods
-XX:+UseCMSInitiatingOccupancyOnly
-Djava.awt.headless=true
-Djava.security.egd=file:/dev/./urandom
"
```

更多的优化服务设置，请参照apache.tomcat.org官方文档。