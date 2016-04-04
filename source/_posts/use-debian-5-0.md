title: debian 5.0安装及配置
tags: []
categories:
  - 技术
date: 2009-03-03 16:53:00
---
下面将就debian lenny 5.0在我本子上的具体安装及相关配置作些介绍，以作备份之用。

debian lenny 5.0的启动速度约为10s, 关机速度为5s，比上一个版本确实升级了许多。之前我是从debian etch 4.0 r2升级到5.0，速度较慢(启动20s，关机10-15s)，升级之后gnome经常崩溃以及klog重启，实在经受不了于是昨天整修了下系统，但不小心将splashy给删除了，结果导致系统的许多服务启动不了, 不想将相关修补程序copy到系统下，于是重装了事省心。

## 1. 安装debian lenny 5.0 

从debian.org官方网站上下载lenny 5.0的cd-image-1即可, 将其刻录成光盘。  
开始进行安装，区域选择中国，语言选择中文，键盘选择US(一般)，其它默认即可，直到硬盘分区，默认自动分区没有问题，但建议手动分区：      
(1)设置主分区，  
(2)设置swap分区，  
(3)单独分一块作为/home分区(这样能防止系统崩溃时数据不会丢失)。  
然后开始copy并install系统。整个过程大约30-40分钟。  
安装完毕后重新启动进入debian X系统，进行如下配置可以更加友好地使用系统。

## 2. 相关配置  
(1). 首先将当前帐户设置为sudo用户，先使用root登录，然后执行visudo, 仿照root插入新的一行，具体如下(假设当前用户为test)
$su -
密码:
```
#visudo
# /etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
#
# See the man page for details on how to write a sudoers file.
#
Defaults env_reset
# Host alias specification
# User alias specification
# Cmnd alias specification
# User privilege specification
root ALL=(ALL) ALL
# 下面这个是你要添加的
test ALL=(ALL) ALL
#exit
logout
$
```
至此你的用户即为sudo用户，可以使用sudo + command执行root权限所能执行的东西。

(2) 配置apt源  
编辑/etc/apt/source.list文件，将以下几行加入到其中，并建议将其中cd源那几行注释掉。
```
deb http://ftp.debian.org/ lenny main
deb http://ftp.debian.org/debian lenny main contrib
deb http://ftp.debian.org/debian lenny main non-free
deb http://www.debian-multimedia.org lenny main
```
后面的那个多媒体源需要去其网站上下载key并安装即可。然后执行
```
$ aptitude update
```

(3)安装相关软件  
debian 5.0默认已经安装好ice-weasel(即是firefox的debian名称)，还需要安装的有以下几个：  

工具类
```
$sudo aptitude install scim scim-chinese scim-pinyin ##安装中文输入法，fcitx也挺好用的
$sudo aptitude install unrar unzip ## 用来解压rar和.zip之类的压缩文件的
$sudo aptitude install pidgin ## 可以用来登录msn, qq等聊天工具
$sudo aptitude install lftp gftp ## lftp是比较好用的shell ftp工具，gftp是GUI工具
$sudo aptitude install qterm ## 用来上bbs的term
```

娱乐类
```
$sudo aptitude install vlc ##安装vlc播放器
$sudo aptitude install mplayer smplayer ##安装mplayer播放器，其中smplayer是比较好用的mplayer界面
$sudo aptitude install w32codecs ##安装mplayer相关解码器，可以支持rmvb等多种格式播放
$sudo aptitude install wine ##安装windows程序模拟器wine,可以用来玩魔兽，CS等游戏
```

办公类
```
$sudo aptitude install icedove ## 这是邮件客户端mozilla-thunderbird的debian名称。
$sudo aptitude install openoffice.org ##安装办公套装openoffice
$sudo aptitude install stardict ## 安装英汉词典，另外有个qt版本qstardict，感兴趣的可以试试；词典库需要另外下载
```

开发类
```
$sudo aptitude install vim ##将vim升级安装，会更加好用，当然需要配置下文件/etc/vim/vimrc
$sudo aptitude install emacs ## 喜欢用emacs可以安装这个编辑器
$sudo aptitude install sun-java6-bin sun-java6-jre sun-java6-jdk ## 安装java库
$sudo aptitude install eclipse ## 安装eclipse开发工具
$sudo aptitude install manpages manpages-dev manpages-posix manpages-posix-dev ## 安装gcc开发文档
## 另外std c++文档直接用aptitude安装后不能使用，需要先下载该文档。
$aptitude download libstdc++6-4.3-doc
## 再解压缩该包将里面man下的文档，copy到/usr/share/man1下面，然后执行
$mandb ## 该命令更新man手册文件
## 对于其它的手册不能使用的均可以采取上述方法。
```

添加新字体
```
$sudo mkdir /usr/local/share/fonts/simsung
将windows下的simsung.ttf文件
$sudo cp simsung.ttf /usr/local/share/fonts/simsung
$sudo fc-cache
然后即可在“外观首选项”中的“字体”项里面找到宋体和新宋体了。
删除方法如下：
$sudo rm -r /usr/local/share/fonts/simsung
$sudo fc-cache
```

修正debian时间
```
修改/etc/timezone文件和/etc/localtime文件:
$sudo echo "Asia/Shanghai" > /etc/timezone
$sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
并将文件/etc/default/rcS中的UTC值改为no
通过网络校正本地时间
$sudo aptitude install ntpdate
$sudo ntpdate pool.ntp.org
然后将时间更新到BIOS里面
$sudo hwclock --systohc
```

其它
```
$sudo aptitude install virtualbox ## 比较好用的一款虚拟机，可以玩玩windows xp/vista/7等
$sudo aptitude install freemind ## 随时记录自己的奇思妙想
```