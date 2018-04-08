title: WebRTC实时通信 (1) - 架构
author: Peter Xu
date: 2018-01-28 20:01:16
tags:
---
实时通信，最常见例子是个人电话，可以称之为Peer模式。而在企业组织等群体性的通信中(同时多人参与通信)，电话会议是更加有效的一种交流方式，这种模式叫做Server模式。

无论是Peer或是Server模式，信令传递通道(Signal)都是不可缺少，用于建立数据通道。在WebRTC实时通信这个范畴中，Peer和Server模式的主要不同在于的数据通道的不同。

### 1. 信令通道

```数据流: |Peer-A| <-> |Signal Server| <-> |Peer-B| ```

节点A与B之间需要相互传递一系列信息，才能建立通信，基本流程如下:

首先, 用户A和B需要到Signal Server注册自己的地址等信息，以便Signal Server随时找到自己。  
其次，用户A需要与B通信，将该请求通过Signal Server发送到B;B决定是否接受该请求。  
最后，信令通道建立成功。

针对webrtc通信，信令通道除了一些日常的用户行为管理功能之外，还需要传递SDP offer/answer/ICE candidate等数据。

目前Signal通道采用最流行的协议是SIP协议, 不仅能够满足WebRTC的所有基本需求，而且能够非常好的兼容第三方产品(这对企业应用尤为的重要)。


### 2. 对等模式

```|Peer-A| <->  ..data.. <-> |Peer-B|```

信令通道主要用来传递SDP信息(offer/answer/ICE candidate)以及用户的管理功能。

当STUN/TURN连接成功后，WebRTC模块将开始建立数据通道用于音视频等数据的传输。

为了与其他产品的互联，WebRTC信令通道大多采取sip协议。

附注： Chrome代码中提供的示例是通过HTTP协议作为信令通道的。


### 3. 中心模式

```|Peer-A| <-> |data server| <-> |Peer-B|```

当用户同时与多个用户进行通信时，Peer模式有其巨大的局限性：需要同时建立多个不同的WebRTC实例。故而在实际的产品中是以中心模式为主的，此类开源产品主要有Kurento/Janus.



### 4. 解决方案
