title: HTTP URI末尾斜杠在nginx中的处理
tags: []
categories:
  - 技术
date: 2016-04-11 17:39:00
---
HTTP协议请求的uri, 是以斜杠"/"(slash)作为基本分割符。而对于末尾的斜杠容易被我们忽略，下面将就这个问题进行具体分析。

首先得明确，http uri是否以slash结尾，是意味着不同的含义，例如以slash分割后的最后一个单元字段命名为lastsection。那么通常情况下，不是以slash结尾是指向服务器请求名字为lastsection的资源(`http://localhost/lastsection`)，以slash结尾的是请求路径lastsection下的某个资源(`http://localhost/lastsection/`)。

具体到nginx中，又是如何进行处理的，下面以静态资源为例，并将index设置为index.html。

<b>情形1: nginx root下不存在test目录</b>  
如果请求`http://localhost/test`, 则nginx返回错误(404 Not Found)。

<b>情形2: root下存在test空目录</b>  
如果请求`http://localhost/test`, 则nginx返回(301 Moved Permanently), 浏览器在收到后，将重新请求(Redirect) `http://localhost/test/`, 由于test为空目录不存在index.html, 故而nginx返回错误(403 Forbidden)。

如果请求`http://localhost/test/`, 则nginx直接返回错误(403 Forbidden)。

<b>情形3: test目录中存在文件index.html</b>  
如果请求`http://localhost/test`, 则nginx返回(301 Moved Permanently), 浏览器在收到后，将重定向到(Redirect) `http://localhost/test/`, nginx返回(200 OK)。

如果请求`http://localhost/test/`, 则nginx直接返回(200 OK)。

注意，当在浏览器中重复请求同一个有效资源时，Nginx将返回(304 Not Modified)而不是(200 OK)。

-------------
如上所述，nginx对这些末尾没有slash而相应目录下不存在相应资源的请求，将会返回301致使客户端尝试带有slash重新redirect请求一次。在使用nginx作为反向代理(如tomcat)时，也会发生相关未预料的行为。同时这种行为也导致客户端重复请求一次。

在实际部署中通过rewrite模块等方式可以避免这种情况。
