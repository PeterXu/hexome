title: 优化playmp3list代码
tags:
  - mp3
categories:
  - 技术
date: 2008-09-13 11:43:00
---
今天修改了播放器playmp3list的部分代码bug。直接使用aptitude install playmp3list安装上的player存在两个问题：  
（1）对中文支持不好，  
（2）cpu消耗太多，也是最大的bug。  

我使用的平台及硬件属性为: debian 2.6.24-1-686 GNU/Linux, Genuine Intel(R) CPU T2050  @ 1.60GHz，cpu占有率平均为80%!!!

首先增加对中文的支持，  
(1) 需要安装ncursesw开发库，  
(2) 将playmp3list.h中的宏定义#define NCURSES <ncurses/ncurses.h>修改为#define NCURSES <ncursesw/ncurses.h>，  
(3)将生成的Makefile中的行LIBS =  -lcurses修改为LIBS =  -lncursesw，  
(4) 在main.cc中包含#include <locale.h>，并在main()函数的开始处调用setlocale(LC_ALL, “”); 注意不能使用setlocale(LC_ALL, NULL)。   
之后make; make install即可安装完成, playmp3list yourMusicPath 运行后可以看到正确中文字符了。

其次，修改高cpu消耗的bug, 实际上这个很简单，只需在主循环里面增加个usleep函数即可，以防止持续高速的屏幕刷新(估计作者在没有测试内存消耗的情况下即提交代码了)。我添加的位置是: 在void play_list(void)函数中的do{}while的循环体起始处添加usleep(300);语句 //这里的睡眠时间只要不影响界面的正常刷新即可。

若发现播放mp3时程序退出，需要修改一个地方重新编译即可。将interface.cc文件中的函数
```
void
playmp3listWindow::do_refresh()
{ /*touchwin(stdscr);
  refresh();*/  // I don’t know why this doesn’t work, so I’m using this instead…
  resize();
} // do_refresh
修改为:
void
playmp3listWindow::do_refresh()
{ touchwin(stdscr);
  refresh();  // I don’t know why this doesn’t work, so I’m using this instead…
  //resize();
} // do_refresh
```
关于原因，我想你已经看到的注释了。另外需要安长mpg123解码库才能播放mp3(附件有我improve的代码)。

最后，一个完整的shell下mp3播放器完成了，去体验一下。