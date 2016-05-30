title: nginx的rewrite模块
tags:
  - nginx
categories:
  - 技术
date: 2016-05-26 14:50:00
---
ngx_http_rewrite_module是通过对内置变量$request_uri进行正则处理, 改写用户请求的uri, 包括多条常用的指令如break/if/return/rewrite等.

##### 1. break指令
停止当前request_uri的后续rewrite规则处理.  
可以在server/location/if等指令中使用.

##### 2. if指令
```
if (condition) { ... }

condition:
	a. 变量名: 空字符串或"0"则为false, 否则为true
    b. 字符串变量比较:  “=”和“!=” 
    c. 正则匹配: 
    	“~”(“!~”)        - 大小写敏感字符串比较
        “~*”(“!~*”)      - 大小写无关字符串比较
        “-f”(“!-f”)      - 检测文件是否存在
        “-d”(“!-d”)      - 检测文件夹是否存在
        “-e”(“!-e”)      - 检测文件/文件夹/符号连接是否存在
        “-x”(“!-x”)      - 检测文件是否可执行
        

```
可以在server/location等指令中使用.

##### 3. return指令
```
return code [text];
return code URL;
return URL;
```
停止后续所有处理返回code给client端, 注意return 444将关闭连接不返回任何数据.  
可以在server/location/if等指令中使用.

通过return将http重定向到https, 有两种方法
```
# server_name is customed by user in server.
return    301 https://$server_name$request_uri;
# http_host is a embedded variable in nginx.
return    301 https://$http_host$request_uri;
```

##### 4. rewrite指令
```
rewrite regex replacement [flag];
```
可以在server/location/if等指令中使用.   
rewrite按照在配置文件中出现的顺序进行处理, 具体行为由flag决定. 
但是如果某个replacement值由http://(https://)开头, 则停止处理返回给client.  

四种flag作用:  
last: 停止当前rewirte模块后续规则处理.  
　　将修改后的url重新按照location规则进行匹配处理.  
　　即是说(rewrite .. last)在location{}中可能被循环处理, 而在server{}中不会.  
　　循环次数超过10次则停止处理并返回500错误.   
break: 与上面的break指令一样.  
redirect: 返回一个临时302重定向.  
permanent: 返回一个永久301重定向.  

例如给请求url添加前缀prefix:  
```
location ^~ / {
        if ($request_uri !~ ^/prefix) {
            	rewrite ^(.*)$ /prefix/$1 break;
        }
}
```


##### 5. rewrite_log指令
```
rewrite_log on | off;
```
可以在http/server/location/if等指令中使用.  
启动rewrite log(写到文件error_log), 日志级别为notice.  

##### 6. set指令
```
set $variable value;
```