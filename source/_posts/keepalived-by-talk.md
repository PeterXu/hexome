title: keepalived建立HA系统的几种模式
tags: []
categories:
  - 技术
date: 2016-04-25 01:13:00
---
keepalived是一种基于虚拟IP原理通过组播通信建立的软件HA系统, 简单有效得到广泛的应用. 

通常有master/backup和backup/backup两种模式, 基本配置构成如下:  
a). global_defs: 定义全局属性 
```
global_defs {
   notification_email {
      test@example.com
   }
   notification_email_from admin@example.com
   smtp_server mail.example.com
   smtp_connect_timeout 30
}
```
b). vrrp_script: 检查应用程序状态
```
vrrp_script chk_app {
    script "</dev/tcp/127.0.0.1/80" # connects and exits
    #script "/etc/keepalived/check_app.sh"
    #script "killall -0 nginx"
    interval 3                      # check every 3 seconds
    weight -2                       # default prio: -2 if fails
}
```
c). vrrp_instance: 服务相关配置如下.  


#### 1. master-backup模式
##### 节点1设置
```
vrrp_instance VI_1 {
    state MASTER            
    garp_master_delay 3

    interface eth0          # 设置虚拟ip的iface
    track_interface {
        eth0				# 监控iface, 可以不是eth0
    }

    virtual_router_id 81	# route id
    priority 100            # 节点优先级
    advert_int 2			# keepalived节点之间通信间隔
    authentication {
        auth_type PASS
        auth_pass pass123	# keepalived密码
    }

    virtual_ipaddress {
        192.168.10.1/24		# 要设置的虚拟ip
    }

    track_script {
       chk_app
    }
}

```
state用于标识该节点的初始状态: MASTER或BACKUP. 
track_script的chk_app检测应用程序, 若失败则节点优先级降低(具体值在chk_app的weight中设置).

##### 节点2设置
```
vrrp_instance VI_1 {
    state BACKUP            
    #nopreempt				# 非抢占模式
    garp_master_delay 3

    interface eth0          # 设置虚拟ip的iface
    track_interface {
        eth0				# 监控iface, 可以不是eth0
    }

    virtual_router_id 81	# 必须与master中一样
    priority 99             # 比master中小, 需要保证master权限降低时比这个值小
    advert_int 2			# keepalived节点之间通信间隔
    authentication {
        auth_type PASS
        auth_pass pass123	# keepalived密码, 必须与master中一样 
    }

    virtual_ipaddress {
        192.168.10.1/24		# 要设置的虚拟ip, 必须与master中一样
    }

    track_script {
       chk_app
    }
}

```

在master-backup模式中,   
a) 正常情况下, 节点1成为master并设置虚拟IP(vip).   
b) 节点1检测错误(chk_app)或keepalived失败, 节点2将接管master角色.   
c) 当节点1恢复正常时, 将重新抢占成为master.  
  

#### 2. backup-backup模式
所有Backup配置如下
```
vrrp_instance VI_1 {
    state BACKUP            
    garp_master_delay 3

    interface eth0          # 设置虚拟ip的iface
    track_interface {
        eth0				# 监控iface, 可以不是eth0
    }

    virtual_router_id 83	# 必须与master中一样
    #nopreempt
    priority 99             
    advert_int 2			# keepalived节点之间通信间隔
    authentication {
        auth_type PASS
        auth_pass pass123	# keepalived密码, 必须与master中一样 
    }

    virtual_ipaddress {
        192.168.10.1/24		# 要设置的虚拟ip, 必须与master中一样
    }

    track_script {
       chk_app
    }
}

```

在backup-backup模式中节点行为如下:  
a) 假设节点1首先启动, 节点1则成为master并设置vip;   
b) 如果节点1失败,节点2将自动接管成为master;   
c) 当节点1恢复时不会抢占master, 除非节点2失败.


#### 3. nopreempt属性
在某些情形下, keepalived的自动切换可能导致Brain-Split: 即两个节点都成为master并设置虚拟IP地址.  

对此, keepalived提供了nopreempt属性, 其允许priority较低的节点作为master, 只在backup节点中设置有效, 具体如下:

1) master-backup模式  
若backup设置nopreempt, 当节点1失败时节点2不会抢占master, 切换方法:  
a) 手动干预, 如关闭节点1的keepalived程序;  
b) 自动切换, 在节点1检测脚本中添加逻辑: 若检测失败自动关闭keepalived.

2) backup-backup模式  
若backup设置nopreempt, 也需要手动干预或者在检测脚本中自动关闭keepalived.  

通过关闭无效节点的keepalived服务, 可以有效避免Brain-Split; 若失败节点恢复需要手动处理才能起作用.

-----
一般情况下, 没有设置nopreempt的backup-backup模式即可以满足大多数需求.