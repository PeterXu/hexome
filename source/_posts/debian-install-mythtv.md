title: 在Debian下安装mythtv
tags: []
categories:
  - 技术
date: 2009-05-12 22:23:00
---
一. 环境配置  
如果是debian或ubuntu系统，可以直接通过以下命令来安装mythtv；

对于debian或ubuntu系统，首先选择源:
1. 打开/etc/apt/sources.list文件，添加源：（国内）
deb http://debian.ustc.edu.cn/debian lenny main
deb http://debian.ustc.edu.cn/debian lenny main contrib
deb http://debian.ustc.edu.cn/debian lenny main non-free
deb http://www.debian-multimedia.org lenny main  
或者：（国外）  
deb http://ftp.debian.org/ lenny main
deb http://ftp.debian.org/debian lenny main contrib
deb http://ftp.debian.org/debian lenny main non-free
deb http://www.debian-multimedia.org lenny main  
如果以上源都无法连上，可以找其他国内源

2. 添加完保存退出后，使用sudo apt-get update命令更新上面的源，然后开始mythtv的安装

二. 安装使用mythtv  

第一步：mythtv安装
1. Sound安装  
	1) aptitute install alsa-base alsa-utils libesd-alsa0    
	2) 配置声卡命令：alsaconf
2. 引入gpg keys  
   命令：aptitute install debian-multimedia-keyring
3. 安装mythtv  
1) aptitute install mythtv  
2) mythtv安装过程配置mysql数据库(该数据库可以提前安装:aptitute install mysql-server),该数据库需要在root用户下进入：命令mysql -uroot -p  
４. 安装mythtv其他组件，如mythvideo, mythmusic,mythphoto等
命令：aptitute install 组件名  
然后重启mythtv，使用mythfrontend命令  
5. 配置mythtv，可以参考：http://parker1.co.uk/mythtv_ubuntu.php，其中大部分都选择默认方式，需要最好选择英文，如果选hanzi的话就是繁体中文。

第二步：播放本地视频文件  
1. 使用mythfrontend命令启动mythtv
2. 选择Utilities/Setup->Setup->Media Settings->Videos Settings->General Settings，在Directories that hold videos:一栏输入本地视频存放路径，然后保存设置。返回上一级，进入File Types，在Extension中选择播放的视频后缀，对于想播放的视频文件，其Use default player和Ignore项空起来，而在Command项如果mythtv自身可以播放就会出现Internal，如果为空，就可以输入系统中安装的播放器，如mplayer等。
3. 通过选择Utilities/Setup->Video Manager可以看到视频目录中存在的文件
4. 返回最上层，选择Media Library->Watch Videos，就可以看到可以播放的视频文件，任意选择一个，按Enter键显示该文件信息，再次Enter键就可以看到播放内容了

第三步：播放流媒体文件
1. 使用aptitute install mythstream来安装mythstream组件
2. 安装完后就可以使用流媒体功能了，可以尝试mythstream组件中已有的流媒体文件
3. 使用sudo mythfrontend命令（注意前面使用了sudo）启动mythtv，进入Media Library->Play online streams后，就可以选择里面的流媒体文件进行播放（需要能够连接国外网站）