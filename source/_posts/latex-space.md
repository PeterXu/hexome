title: Latex (wiki) 空格处理
tags: []
categories:
  - 其他
date: 2009-03-11 19:30:00
---
注意TeX能够自动处理大多数的空格，但是您有时候需要自己来控制。

```
功能　　　		　语法　　　	　显示　　　　　　备注 
两个quad空格　　　a \qquad b	　a \qquad b　　两个m的宽度
quad空格　　　　　a \quad b	 　a \quad b　　一个m的宽度
大空格　　　　　　a\ b　　　　　　a\ b　　　　　1/3m宽度
中等空格　　　　　a\;b　　　　　　a\;b　　　　　2/7m宽度
小空格　　　　　　a\,b　　　　　　a\,b　　　　　1/6m宽度
没有空格　　　　　ab　　　　　　　ab\,	
紧贴　　　　　　　a\!b　　　　　　a\!b　　　　　缩进1/6m宽度
```