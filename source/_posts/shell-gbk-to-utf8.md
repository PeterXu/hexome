title: 'Shell批处理编码转换gbk->utf8'
tags: []
categories:
  - 技术
date: 2009-03-24 15:59:00
---
最近遇到工程里面c/c++代码注释utf8和gbk共存的情况,在服务器上使用vim编辑非常不方便.于是编写了一个shell程序遍历所有文件，并将所有文件中中文gbk编码转化为utf8。

```
#!/bin/sh

# 定义一个方法
foreachd(){
  	# 遍历参数1
  	for file in $1/*
  	do
        # 如果是目录就打印处理，然后继续遍历，递归调用
        if [ -d $file ]
        then
            # echo $file
            foreachd $file
        else
            if [[ $file =~ ".h" || $file =~ ".cpp" ]]
            then
                echo $file
                tempfile=`echo $file”.5″`
                iconv -f gbk -t utf8 $file > $tempfile
                mv $tempfile $file
            fi
        fi
    done
}

#执行，如果有参数就遍历指定的目录，否则遍历当前目录
if [ $# -gt 0 ]
then
    foreachd “$1″
else
    foreachd “.”
fi

exit 0
```
