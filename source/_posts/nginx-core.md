title: nginx的core模块
tags:
  - nginx
categories:
  - 技术
date: 2016-05-28 15:42:00
---
ngx_http_core_module提供了nginx最基本的功能, 包括一些内置变量和配置文件中的基本指令.

#### 1. 常见内置变量
1) uri相关  
```
$uri: 当前请求uri  
$document_uri: 同$uri  
$request_uri: 原始完整请求URI(带参数)   
$scheme: 请求scheme, “http” or “https”  
$https: 如果处于ssl模式则值为“on”, 否则为空  
$host: 请求的server地址, 具体见下面的描述  
$cookie_name: cookie名    
```
其中, nginx rewrite模块是基于内置变量$request_uri进行处理的.

2) remote请求相关  
```
$remote_addr: 客户端地址  
$remote_port: 客户端端口  
$remote_user: Basic认证中的用户名     
$request: 原始完整请求URI  
$request_body: request body
$is_args: 如果有参数值为"?", 否则为空  
$args: 请求uri中的参数(?后的部分)  
$query_string: 同$args  
```

3) server相关  
```
$server_addr: 接收请求的server地址  
$server_name: 接收请求的server名字    
$server_port: 接收请求的server端口    
$server_protocol: 请求协议, “HTTP/1.0”, “HTTP/1.1”, 或 “HTTP/2.0”
```

4) 其它  
```
$hostname: nginx主机名      
$limit_rate: 限速   
$nginx_version: nginx版本  
```

#### 2. $host与$http_host  
$http_host是对应http请求头的Host完整值.   
$host是可能是以下几种情形中的一种(按顺序处理):  
　　a. http请求url中的host name,  
　　b. http请求header中的Host部分值(除去port),  
　　c. 处理该请求server{}中的server_name.
  
#### 3. location指令
```
location [ = | ~ | ~* | ^~ ] uri { ... }
location @name { ... }
```
可以被用在server/location等指令语句中.  
location有两种匹配模式: prefix匹配(location uri)或者正则匹配.   
nginx首先处理prefix匹配(无论配置文件中的顺序), 然后进行正则匹配.  

匹配规则的含义: 
```
 "":  前缀部分匹配  
 “=”: 精确完整匹配, 成功则停止其它匹配处理   
 "~": 大小写敏感匹配  
 "~*": 大小写无关匹配  
 "^~": 最长大小写敏感匹配, 匹配成功则不检查其它正则.     
```
"location @.."是定义一个命名location, 通常用于请求重定向.
  
#### 4. error_page指令
```
error_page code ... [=[response]] uri;
```
可以被用在http/server/location/if等指令语句中.

使用内部请求处理.
```
error_page 404             /404.html;
error_page 500 502 503 504 /50x.html;
error_page 404 =200        /empty.gif;
error_page 404 =           /404.php;
```

使用重定向进行处理.
```
error_page 403             http://example.com/forbidden.html;
error_page 404 =301        http://example.com/notfound.html;
```

使用命名location进行处理.
```
location / {
    error_page 404 = @fallback;
}

location @fallback {
    proxy_pass http://backend;
}
```