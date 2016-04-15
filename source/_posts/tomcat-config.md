title: Tomcat常用配置
tags: []
categories:
  - 技术
date: 2016-04-07 21:22:00
---
tomcat默认配置已能满足正常需求，为了优化服务可以进行以下的简单设置。

以下配置针对tomcat8。

#### 1. 设置Connector(server.xml) 

```
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="30000"
               acceptCount="1024"
               maxThreads="1024"
               minSpareThreads="16"
               acceptorThreadCount="4"
               URIEncoding="UTF-8"
               useURIValidationHack="false"
               enableLookups="false"
               compression="on"
               compressionMinSize="2048" 
               compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain"
               redirectPort="8443" />

```
acceptCount: 等待处理队列的最大长度，超过该数目的后续请求将被refuse
maxThreads: 处理任务的最大线程数，即同时能够处理的最大任务数目
minSpareThreads: 保留的最少空闲线程数
acceptorThreadCount: 接受连接(socket accept调用)的线程数，默认为1，通常设置为cpu核心数
protocol="HTTP/1.1": java http connector协议。

tomcat8标准连接器包括BIO阻塞模式，非阻塞NIO1，非阻塞NIO2和ARP/Native四种模式。
```
protocol="org.apache.coyote.http11.Http11Protocol" - blocking Java connector
protocol="org.apache.coyote.http11.Http11NioProtocol" - non blocking Java NIO connector
protocol="org.apache.coyote.http11.Http11Nio2Protocol" - non blocking Java NIO2 connector
protocol="org.apache.coyote.http11.Http11AprProtocol" - the APR/native connector.
```
当使用protocol="HTTP/1.1"时，如果PATH(windows)或LD_LIBRARY_PATH(linux)路径下，存在tomcat native库，则使用APR/native模式；否选使用一种NIO模式。
实际部署中，建议设置protocol="HTTP/1.1"。

各个模式具体说明见[官方链接](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Connector_Comparison)。

这里主要调整acceptCount/maxThreads这几个参数，提高并发处理能力，同时对文本文件进行压缩(compression=on)。


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
-Xms512M -Xmx4096M
-XX:LargePageSizeInBytes=128m
-XX:+AggressiveOpts
-XX:+UseBiasedLocking
-XX:+DisableExplicitGC
-XX:+UseFastAccessorMethods
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:+CMSParallelRemarkEnabled
-XX:+UseCMSCompactAtFullCollection
-XX:+UseCMSInitiatingOccupancyOnly
-Djava.awt.headless=true
-Djava.security.egd=file:/dev/./urandom
"
```
-Xms: 初始化内存
-Xmx: 最大内存
-Xss: 线程栈大小，无需设置
-XX:+AggressiveOpts: JVM性能优化，加快编译
-XX:+UseBiasedLocking: JVM lock优化
-XX:LargePageSizeInBytes=128m: 堆的内存页大小
-XX:+DisableExplicitGC: 关闭系统System.gc()
-Djava.awt.headless=true: headless模式，适于server程序，无鼠标/显示/键盘等。
-Djava.security.egd=file:/dev/./urandom: 默认/dev/random是block模式，针对大并发有性能影响，若对随机数要求不高则用伪随机代替(使用file:/dev/./urandom,不是file:/dev/urandom)。

-----------------
更多的优化服务设置，请参照[官方文档](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html)。