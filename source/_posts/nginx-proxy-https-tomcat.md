title: nginx和tomcat配置完美支持HTTPS
tags:
  - nginx
  - tomcat
categories:
  - 技术
date: 2016-04-26 22:07:00
---
之前几篇文章简单描述了nginx和tomcat的一些配置，可以满足一些常规需求。
随着互联网安全隐患的频繁发生，现如今安全性已经是一项基本需求，而https则是最基础平台之一。

在nginx中启用ssl非常简单，只需要几句简单的配置和证书即可。当nginx和tomcat配合使用，其中nginx作为反向代理前端时，该如何实现https呢？

第一种方法，即在nginx和tomcat中使用同样的证书，打开https功能。  
nginx接受到用户请求进行解密进行处理，加密请求发送到tomcat；  
tomcat节点接受到请求解密进行处理，对响应数据进行加密转发回到ningx；  
最后，nginx需要解密tomcat的响应数据，再重新加密转发给客户端。

可以看到，整个过程非常复杂，并且tomcat和nginx节点均需要加密解密多次。


第二种方法，只需要在nginx前端启用ssl, nginx与后台tomcat之间的通信走http/1.0明文。  
nginx接受用户请求进行解密处理，发送明文请求到tomcat;  
tomcat对请求明文进行处理，返回响应数据的明文给ningx;  
最后nginx对tomcat的响应数据加密转发到用户。


需要注意在第二种方法中，默认tomcat返回的响应明文中的url link全部是http地址。    
也即是说，用户的第一次请求(逻辑上的首次http get)可以正常返回，随后根据在该返回内容中的访问link都被拒绝，由于这些link（由相对地址转化而来，原本就是绝对url地址除外）都是http而不是https。

对于这个问题，需要从两方面配置解决，首先在nginx前端代理请求到tomcat时需要附带上用户请求的协议名字schema（http或https）, 配置如下:
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
X-Forwarded-Proto即是在http header请求中添加用户真实协议，而不是代理协议http.


其次在tomcat中需要显示使用http head中该字段x-forwarded-proto, 配置如下:
```
  <Valve className="org.apache.catalina.valves.RemoteIpValve"
     remoteIpHeader="x-forwarded-for"
     remoteIpProxiesHeader="x-forwarded-by"
     protocolHeader="x-forwarded-proto"
  />
```
tomcat的mod_remoteip模块将会根据protocolHeader字段和protocolHeaderHttpsValue值作如下逻辑判断：  
如果protocolHeader对应字段的值与protocolHeaderHttpsValue(默认是https,可以设置)一致且是https，则root url是https://ip;  
否则采用http://ip作为root url,不论用户真实请求的协议.  

这样，nginx和tomcat搭配的https请求就可以工作了，但这仅仅适用于nginx和tomcat均处于内网中。

在数据中心中，前端nginx一般位于DMZ区域拥有公网IP地址，而tomcat可能位于局域网中只有内网地址。这时我们会发现以上配置不起作用。  
由于tomcat默认机制中需要判断代理服务器的IP地址，如果该IP地址是内网网段，则启用以上逻辑否则无效，而转而使用默认规则http处理。

为了解决这个问题，需要将代理IP(例如a.b.c.d)添加到tomcat的允许区域中，可进行如下配置:
```
  <Valve className="org.apache.catalina.valves.RemoteIpValve"
     remoteIpHeader="x-forwarded-for"
     remoteIpProxiesHeader="x-forwarded-by"
     protocolHeader="x-forwarded-proto"
     internalProxies="a\.b\.c\.d"
  />
```
internalProxies将会覆盖tomcat的默认内网网段设置，这时通过公网ip可以正常访问https，但在内部直接连接tomcat则只能获取到首页内容，类似上面访问nginx的情形。  
internalProxies支持正则表达式，可以在将nginx代理公网ip和内网网段全部添加进去即可，如下所示:
```
	internalProxies="a\.b\.c\.d,10\.*,192\.168\.*"
```

既然tomcat已经在数据中心内网中，可以有更简单的设置:
```
  <Valve className="org.apache.catalina.valves.RemoteIpValve"
     remoteIpHeader="x-forwarded-for"
     remoteIpProxiesHeader="x-forwarded-by"
     protocolHeader=".*"
  />
```
如此，完美解决nginx + tomcat + https的问题。