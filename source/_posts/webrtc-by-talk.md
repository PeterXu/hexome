title: WebRtc 网络基本流程
tags:
  - media
categories:
  - 技术
date: 2014-12-10 12:12:00
---
WebRtc是一款非常优秀的实时音视频通信框架，采用RFC方案SDP offer/answer的方式建立网络会话。

### 1. 发起Setup Call

1).call and create local
 
CreatePeerConnection()  
GetUserMedia() => AddLocalStream()/SetLocalRender()    

2).send offer

createOffer() => SetLocalSdp(offer) => SendOffer()     

3).recv answer

RecvAnswer() => SetRemoteSdp(answer)  
OnRemoteStream()  => SetRemoteRender()


### 2. 应答Answer Call

1).recv call
 
CreatePeerConnection()  
 
2).recv offer

RecvOffer() => SetRemoteSdp()   
GetUserMedia() => AddLocalStream()/SetLocalRender()   
 
3).send answer

createAnswer() => SetLocalSdp(answer) => SendAnswer()  
OnRemoteStream()  => SetRemoteRender()  


### 3. stun网络

下面将就网络的基本类型作简单描述，以便理解stun的作用，假设内网主机I:i, 防火墙F:f, 外网主机S1:s1和S2:s2.

1) full cone:  I:i <=> F:f, 任意外网主机均可通过F:f发给I:i

2) restricted cone: I:i <=> F:f <=> S1, I:i <=> F:f <=> S2, 只有S1和S2可以通过F:f发给I:i

3) port restricted cone:  I:i <=> F:f <=> S1:s1, I:i <=> F:f <=> S2:s2, 只有S1:s1和S2:s2可以通过F:f发数据给I:i

4) symmetric NAT: I:i <=> F:f1 <=> S1:s1, I:i <=> F:f2 <=> S2:s2


基本处理流程如下(来着mozilla):
![STUN/TURN in WebRTC](https://mdn.mozillademos.org/files/6119/webrtc-complete-diagram.png)

--------------
相关webrtc源代码封装库和浏览器插件实现，可以参照[librtc](https://github.com/peterxu/librtc)和[RTCHub](https://github.com/peterxu/RTCHub)。