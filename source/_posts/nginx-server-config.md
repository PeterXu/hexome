title: Nginx虚拟主机和多域名处理逻辑
tags:
  - nginx
categories:
  - 技术
date: 2016-04-13 20:30:00
---
与apache httpd类似，在nginx中通过server字段定义多个虚拟主机。
nginx按照server加载顺序处理用户请求, 但可能导致一些意外行为，下面将进行具体描述。

假设服务器地址为ServerIP, 该IP被多个域名映射(www.b.com, www.c.com和www.d.com).

#### 情形1：所有server在同一个文件中, 例如default.conf.

```
# server-b
server {
	listen 80;
	server_name b.com www.b.com;
	...
}

# server-c
server {
	listen 80;
	server_name c.com www.c.com;
	...
}

```
显然b.com/c.com将会分别正确访问到server-b/server-c的资源,

d.com/ServerIP也可以访问到nginx, 由于没有匹配的server_name，
nginx按照server加载顺序进行处理，将使用第一个server资源进行响应请求。
于是d.com访问的是server-b的资源。

##### 1) 禁止d.com
如果仅禁止d.com访问server-b/c的资源，可以显示定义server处理d.com。
```
# server-b
server {
	listen 80;
	server_name b.com www.b.com;
	...
}

# server-c
server {
	listen 80;
	server_name c.com www.c.com;
	...
}

# server-d
server {
	listen 80;
	server_name d.com www.d.com;
    location / {
    	try_files $uri $uri/ =404;
    }
}
```

##### 2) 同时禁止d.com和ServerIP
如果同时禁止d.com和ServerIP访问资源(server-b/server-c), 则需在server-b之再定义一个空server虚拟主机。

```
# server-non
server {
	listen 80;
	server_name _;
    
	location / {
		try_files $uri $uri/ =404;
	}
}

# server-b
server {
	listen 80;
	server_name b.com www.b.com;
	...
}

# server-c
server {
	listen 80;
	server_name c.com www.c.com;
}

```
对于server-non设置中的server-name值无所谓，只要不影响正常服务即可。

显然，第二种设置更简单通用，但需要在所有虚拟主机之前定义空server才起作用。

#### 情形2: server在不同的文件中
假设b.com设置在bsize.conf中，c.com设置在csite.conf中. b/c.com均能正常访问资源。
但d.com/ServerIP仍然是访问server-b的资源，而不是server-c，原因是由于Nginx include是按照文件名字ascii属性进行加载的。

也即是说，bsite.conf中server比csite.conf优先加载, 如果c.com设置在bsite.conf,b.com设置在csite.conf，则d.com/ServerIP访问到的是server-c的资源。

因此，对于仅禁止d.com访问server-b/server-c的资源，仅需要显示设置其即可(文件名无所谓)，如下所示。
```
# server-d
server {
	listen 80;
	server_name d.com www.d.com;
	location / {
		try_files $uri $uri/ =404;
	}
}
```

如果需要通用禁止所有非b.com/c.com(如d.com/ServerIP)访问资源，则必须设置比已有配置文件名ascii更靠前的文件名。在这个案例中，创建一个文件名为aaa.conf即可，其内容如下
```
# server-non
server {
	listen 80;
	server_name _;
    
	location / {
		try_files $uri $uri/ =404;
	}
}
```
