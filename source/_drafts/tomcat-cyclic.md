title: tomcat-cyclic
date: 2016-07-04 15:46:02
tags:
---
tomcat启动加载web容器过程中产生异常(非必现情况)

```
Caused by: java.lang.IllegalStateException: Unable to complete the scan for annotations for web application [/website] due to a StackOverflowError. Possible root causes include a too low setting for -Xss and illegal cyclic inheritance dependencies. The class hierarchy being processed was [org.bouncycastle.asn1.ASN1EncodableVector->org.bouncycastle.asn1.DEREncodableVector->org.bouncycastle.asn1.ASN1EncodableVector]
```

log提示中可能存在两个原因:  
1) -Xss过小导致栈溢出  
2) 错误的循环依赖  

若通过调整-Xss参数进行测试, 发现大多数情况下都可以正常启动. 
但根源却不在于-Xss参数, 另外tomcat8官方文档中已经明确说明-Xss已经desperated, 其值可以根据实际运行自动调整.

即是说该问题并非是由于-Xss过小导致溢出, 而是由于illegal cyclic inheritance dependencies.

通常, 这是由于pom.xml的jar包依赖树中, 可能存在如下情况之一:  
1) 依赖同一个jar包的多个版本库  
2) 存在循环依赖.  

具体, 通过mvn dependency:tree检测当前项目的依赖情况, 在存在上述情况的包引入中添加exclude语句, 去掉重复的jar包, 即可从根本上解决问题.