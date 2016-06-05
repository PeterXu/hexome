title: jenkins工具
tags: []
categories:
  - 技术
date: 2016-06-05 11:21:00
---
今天介绍一个强大的工具 - jenkins, 其本身是一种CI&CD平台, 具有设计合理简洁等优点.  

jenkins具有的几个基本特点:

a. 既有内建账户管理模式, 也支持ldap系统.  
b. 支持多种操作系统: linux/windows/...  
c. 支持多种内建脚本语言: grovvy/python/shell/bat.  
d. 支持单机模式, master/slave模式和cluster模式.  
e. 拥有丰富的扩展插件.  

除了其本职功能之外, jenkins容易将传统的后台模式转为前台可视化, 方面用户的使用.
可以适用于如下几种应用场景中:   

a. 普通调度任务, 如周期性和触发任务  
b. 制造业的自动化调度任务
c. 各种系统及服务的状态监控  


采用docker方式安装使用jenkins非常简单, 如下:
```
docker pull jenkins
docker run -d -it -p 8080:8080 -e JAVA_OPTS="-Duser.timezone=Asia/Shanghai" jenkins
```
然后即可以通过浏览器访问`http://ip:8080/`进行登录使用.


