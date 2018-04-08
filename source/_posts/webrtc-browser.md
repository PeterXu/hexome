title: WebRTC实时通信 (0) - 浏览器
author: Peter Xu
date: 2018-01-28 19:18:42
tags:
---

### 1. WebRTC

在2011年之前，实时音视频的开发具有非常大的门槛，全球仅有很少的几家公司拥有这种技术。随着互联网的发展及其实时音视频需求的增大，一种更为简易的开发方式便顺势而出 - WebRTC。

WebRTC(Web Real-Time Communications)是基于Web的一种实时通信技术平台，即在浏览器节点间进行彼此音频，视频和消息等数据的交互。
	
WebRTC通过Web方式对音视频应用进行开发，大大简化了开发难度并进一步推动了音视频应用的普及。

当前,几家主流的浏览器均已经支持WebRTC技术，如Microsoft Edge/Apple Safari-11/Google Chrome/Mozilla Firefox等。
其中，Edge和Safari距离实际使用仍然存在较大的差距，这里将仅叙述具有代表性的Chrome和Firefox。


### 2. 音视频特性

对基本audio/video特性的支持如下。

| Browser | Audio | Video | Video Simulcast | Video MultiStream |
|----|----|----|----|----|
| Chrome  | opus/DTMF | H264/VP8 | VP8-only | H264/VP8 |
| Firefox | opus/DTMF | H264/VP8 | VP8-only | H264/VP8 |

对RTCP特性支持如下:

| Browser | RTCP PLI | RTCP NACK | RTCP REMB | ulpfec |
|----|----|----|----|----|
| Chrome  | yes | yes | yes | yes |
| Firefox | yes | no  | yes | yes |



### 3. API介绍

##### 1). getUserMedia
支持webrtc的浏览器都有类似Navigator.getUserMedia这样的API, 用于获取当前系统的设备资源，如Speaker/Micphone/Camera/DesktopSharing等.

最新标准中已经废弃使用navigator.getUserMedia，推荐navigator.mediaDevices.getUserMedia.

``` js
navigator.getUserMedia = navigator.getUserMedia ||
                         navigator.webkitGetUserMedia ||  // chrome
                         navigator.mozGetUserMedia;       // firefox
if (navigator.getUserMedia) {
	var constraints = { audio: true, video: { width: 1280, height: 720 } }; 
   navigator.getUserMedia(constraints},
      function(stream) {
         var video = document.querySelector('video-element-id');
         video.srcObject = stream;
         video.onloadedmetadata = function(e) {
           video.play();
         };
      },
      function(err) {
         console.log("The following error occurred: " + err.name);
      }
   );
} else {
   console.log("getUserMedia not supported");
}
```


##### 2). RTCPeerConnection

RTCPeerConnection是Webrtc最基本的API接口，用于管理媒体属性，并与远程节点建立数据连接。
RTCPeerConnection基本的媒体单位是MediaStream(最新标准中推荐使用MediaTrack).

在媒体数据连接之外，RTCPeerConnection还支持在相同的连接上管理创建数据通道(createDataChannel),用于传输一些带外数据（如媒体控制数据）.

```js
RTCPeerConnection():
	addIceCandidate()
	addStream()
	addTrack()
	createDataChannel() 
	createOffer()
	setLocalDescription()
	setRemoteDescription()
	onAddStream()
	getSenders()
```



### 4. API使用示例

```
A发送视频，B观看视频.
A和B注册建立signal通道(能够彼此互相通信)。
A创建RTCPeerConnection对象(A-pc).
B创建RTCPeerConnection对象(B-pc).
```

##### 1). 准备阶段  
    
Step1: A发送视频
>  
调用getUserMedia获取本地视频流添加到A-pc中(addStream)。  
调用createOffer()生成A-sdp-offer.  
调用setLocalDescription设置A-sdp-offer.  
通过signal通道将A-sdp-offer发送给B.


Step2: B观看视频
>
调用createOffer()生成B-sdp-offer.  
调用setLocalDescription设置B-sdp-offer.  
通过signal通道将B-sdp-offer发送给A.  

##### 2). 交互阶段
>
A调用setRemoteDescription()设置收到的B-sdp-offer.   
B调用setRemoteDescription()设置收到的A-sdp-offer.  
随后A与B交互彼此的SDP ICE candidate数据直到ice stun/turn连接成功。
   (调用addIceCandidate()处理ICE sdp消息).   
ICE连接成功后B将会收到onAddStream事件 - 远程stream建立成功.


##### 3). 媒体数据互通
>
A发送视频数据，B接收视频数据并解码
    

### 5. 现状

目前，WebRTC的标准仍在持续改进中，各个厂商的浏览器对其支持的力度也不尽相同。其中，Chrome对最新标准API的支持较为迟缓，Firefox比较积极但不够稳定成熟。

总体上，开放的API接口对基本功能的支持已经覆盖，但是对更精细的控制不足以及也缺少相应的文档说明，故而在实际使用中需要研究浏览器代码逻辑和修改SDP属性来达到某些具体的需求。


