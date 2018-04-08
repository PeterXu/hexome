title: WebRTC实时通信 (2) - SDP
author: Peter Xu
date: 2018-01-29 13:59:05
tags:
---



### 1. SDP介绍

#### *. m=audio/video/application
媒体行: 最基本的媒体类型标识,其中m=application可用于创建sctp数据通道。

sdp中必须至少存在一个`m=..`， 同一种类型的媒体可以同时存在多个`m=..`.


#### a. a=sendrecv/sendonly/recvonly
offer/answer的数据传输属性的匹配方式如下:

|offer(A)| answer(B)|说明|
|---|---|---|
|sendrecv|sendrecv|可互相发送媒体数据|
|sendrecv|sendonly/recvonly|-|
|sendonly|recvonly|-|
|recvonly|sendonly|-|
|inactive|inactive|-|


#### b. a=rtpmap
标识RTP数据(payload), 可以用于区分音视频编码类型/RTP数据类型(如正常数据包，重传包，FEC包等)

#### c. a=rtcp-fb
标识RTP数据(payload)所支持的RTCP类型，如

```
a=rtcp-fb:* nack    	     => 所有rtp数据均支持重传(*表示所有payload的RTP数据)
a=rtcp-fb:100 nack pli     => payload为100编码的RTP数据支持PLI请求
a=rtcp-fb:96 ccm fir       => payload为96编码的RTP数据支持CCM和FIR请求
a=rtcp-fb:96 goog-remb     => payload为96编码的RTP数据支持google REMB。
```

注意:   
* 在最新版本的firefox中并未支持NACK数据重传。  
* PLI/FIR对于H264编码具有同等作用。  
* REMB在Firefox与Chrome中实现基本一致，但对于Multi-stream模式有区别(后续将详细解释)。

#### d. a=ice-ufrag/ice-pwd

ice-ufrag用于标识stun消息是否合法，ice-pwd用于stun数据体的加/解密。


#### e. a=fingerprint
用于对媒体数据(audio/video/data)的加解密。

#### f. a=mid
媒体数据标识ID: 如果使用`a=group:BUNDLE`属性，a=mid值必须与其匹配。

a=mid必须被用在具体的媒体行'm='里面。

#### g. a=extmap
RTP媒体数据(audio/video)的扩展头标识。回复Answer中的该项值必须是Offer的子集。

#### h. a=rtcp-mux
启用rtcp-mux复合包，即一个RTCP包中有多个类型数据(如RR/SR/PLI/CNAME)，复合包中必须包含一个CNAME类型数据。

#### i. a=fmtp
媒体数据属性，如编解码参数/RTP打包模式等。
fmtp子属性`apt=`指的是该RTP的重传包具有不同的payload值。

#### j. a=msid
用于标识媒体流的streamID和trackID。

最新标准中推荐的格式为(firefox): `a=msid:{stream_id} {track_id}`

之前标准中所使用的格式为(chrome):
`a=ssrc:1424320061 msid:stream_id track_id`



### 2. Chrome SDP

SDP具有Offer和Answer两种模式, 两种模式格式基本类似当含义却不同:
  
 *	Offer是向对方列举自身设备所允许的能力。  
 * Answer是从对方Offer中选择自身也支持的若干种能力，然后通知对方。

#### 1). SDP Offer

以视频和数据这两个媒体类型为例, 如下所示描述当前设备所具备的接收视频的能力:   

```c
v=0
o=- 2313687692229239915 3 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE video data
a=msid-semantic: WMS

m=video 52510 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 124 127 123 125 107 108
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:dLaN
a=ice-pwd:gRWPwtQj8OYQl0TNPsXjXzZ8
a=ice-options:trickle
a=fingerprint:sha-256 7C:68:A9:F6:9C:CE:45:47:CA:42:F2:7A:98:48:7F:65:3F:06:1C:65:8E:B8:AF:82:3A:5F:E1:EF:DB:38:26:C1
a=setup:actpass

a=mid:video
a=extmap:2 urn:ietf:params:rtp-hdrext:toffset
a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:4 urn:3gpp:video-orientation
a=extmap:5 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:6 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay
a=extmap:7 http://www.webrtc.org/experiments/rtp-hdrext/video-content-type
a=extmap:8 http://www.webrtc.org/experiments/rtp-hdrext/video-timing
a=recvonly
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:96 VP8/90000
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack
a=rtcp-fb:96 nack pli
a=rtcp-fb:96 goog-remb
a=rtcp-fb:96 transport-cc
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96
a=rtpmap:98 VP9/90000
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack
a=rtcp-fb:98 nack pli
a=rtcp-fb:98 goog-remb
a=rtcp-fb:98 transport-cc
a=rtpmap:99 rtx/90000
a=fmtp:99 apt=98
a=rtpmap:100 H264/90000
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=rtcp-fb:100 goog-remb
a=rtcp-fb:100 transport-cc
a=fmtp:100 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=64001f
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=rtpmap:102 H264/90000
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack
a=rtcp-fb:102 nack pli
a=rtcp-fb:102 goog-remb
a=rtcp-fb:102 transport-cc
a=fmtp:102 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:124 rtx/90000
a=fmtp:124 apt=102
a=rtpmap:127 H264/90000
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack
a=rtcp-fb:127 nack pli
a=rtcp-fb:127 goog-remb
a=rtcp-fb:127 transport-cc
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=rtpmap:123 rtx/90000
a=fmtp:123 apt=127
a=rtpmap:125 red/90000
a=rtpmap:107 rtx/90000
a=fmtp:107 apt=125
a=rtpmap:108 ulpfec/90000

...<<webrtc_video_sending_sdp>>...

m=application 62968 DTLS/SCTP 5000
c=IN IP4 0.0.0.0
a=ice-ufrag:dLaN
a=ice-pwd:gRWPwtQj8OYQl0TNPsXjXzZ8
a=ice-options:trickle
a=fingerprint:sha-256 7C:68:A9:F6:9C:CE:45:47:CA:42:F2:7A:98:48:7F:65:3F:06:1C:65:8E:B8:AF:82:3A:5F:E1:EF:DB:38:26:C1
a=setup:actpass
a=mid:data
a=sctpmap:5000 webrtc-datachannel 1024
```

* `m=video`是video的基本描述信息; `a-mid`是具体视频参数相关信息，用于实际视频的接收和发送
* `m=application`是application的基本描述信息; `a=mid`是具体数据通道相关信息,用于传递带外数据


如果需要发送视频, 则在此处`webrtc_video_sending_sdp`添加发送视频的基本信息: 在调用addStream API添加发送媒体流后，createOffer将会自动生成，格式如下

``` c
a=ssrc-group:FID 1424320061 772564596
a=ssrc:1424320061 cname:+T5LKYkAJtmH1euA
a=ssrc:1424320061 msid:afef2129-baba-431e-aa45-be0986777c1a 3ad04812-b787-4f60-804e-1665a03e12a7
a=ssrc:1424320061 mslabel:afef2129-baba-431e-aa45-be0986777c1a
a=ssrc:1424320061 label:3ad04812-b787-4f60-804e-1665a03e12a7
a=ssrc:772564596 cname:+T5LKYkAJtmH1euA
a=ssrc:772564596 msid:afef2129-baba-431e-aa45-be0986777c1a 3ad04812-b787-4f60-804e-1665a03e12a7
a=ssrc:772564596 mslabel:afef2129-baba-431e-aa45-be0986777c1a
a=ssrc:772564596 label:3ad04812-b787-4f60-804e-1665a03e12a7
```

上述SDP片段表示将要发送视频的基本信息如下：

``` c
仅发送一路视频，视频的基本信息参照a=rtpmap/a=rtcp-fb属性。
cname为+T5LKYkAJtmH1euA(用于RTCP中)
streamId和streamLabel是afef2129-baba-431e-aa45-be0986777c1a, 
trackId和trackLabel是3ad04812-b787-4f60-804e-1665a03e12a7, 
发送的主RTP数据包ssrc是1424320061，
重传(NACK)RTP数据包的ssrc是772564596，
```

如果存在多组`a=ssrc-group:FID`相关数据(生成多个本地流并调用addStream添加进去)，则意味着将同时发送多路视频。


#### 2). SDP Answer

从前部分Offer的示例中，根据当前设备能力和喜好选择所接收的能力列表(以H264为例)，回复的Answer如下

``` c
v=0
o=- 909859953 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE video data
a=msid-semantic:WMS

m=video 1 UDP/TLS/RTP/SAVPF 100 101
c=IN IP4 0.0.0.0
a=rtcp:1 IN IP4 0.0.0.0
a=ice-ufrag:YyTaBDA/vFKmKipltm8SSnv4/Cg6IQoh-1
a=ice-pwd:OdFkQMmoppx2pAYPCWdbCsYA
a=fingerprint:sha-256 CC:0F:BE:B4:1B:5E:A5:72:B2:49:80:03:54:88:27:42:84:83:6C:F1:8C:C9:23:B3:6C:98:67:87:D8:AF:9C:F4
a=setup:passive
a=mid:video
a=sendrecv
a=rtcp-mux
a=rtpmap:100 H264/90000
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 goog-remb
a=fmtp:100 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=fmtp:100 x-google-start-bitrate=300
a=fmtp:100 x-google-min-bitrate=80
a=fmtp:100 x-google-max-bitrate=1000

...<<webrtc_video_sending_sdp>>...

m=application 9 DTLS/SCTP 5000
c=IN IP4 0.0.0.0
a=ice-ufrag:YyTaBDA/vFKmKipltm8SSnv4/Cg6IQoh-1
a=ice-pwd:OdFkQMmoppx2pAYPCWdbCsYA
a=fingerprint:sha-256 CC:0F:BE:B4:1B:5E:A5:72:B2:49:80:03:54:88:27:42:84:83:6C:F1:8C:C9:23:B3:6C:98:67:87:D8:AF:9C:F4
a=setup:passive
a=mid:data
a=sctpmap:5000 webrtc-datachannel 1024
```

如果当前设备也需要发送视频, 则在此处`webrtc_video_sending_sdp`添加发送视频的基本信息(调用addStream API添加视频后将会自动生成)，如下所示

``` c
a=ssrc-group:FID 3405199308 3405199309
a=ssrc:3405199308 cname:+T5LKYkAJtmH1eBB
a=ssrc:3405199308 msid:54b40235-260b-4f6b-96cf-e72940e4ea9d_streamid 54b40235-260b-4f6b-96cf-e72940e4ea9d_trackid
a=ssrc:3405199308 mslabel:54b40235-260b-4f6b-96cf-e72940e4ea9d_streamid
a=ssrc:3405199308 label:54b40235-260b-4f6b-96cf-e72940e4ea9d_trackid
a=ssrc:3405199309 cname:+T5LKYkAJtmH1eBB
a=ssrc:3405199309 msid:54b40235-260b-4f6b-96cf-e72940e4ea9d_streamid 54b40235-260b-4f6b-96cf-e72940e4ea9d_trackid
a=ssrc:3405199309 mslabel:54b40235-260b-4f6b-96cf-e72940e4ea9d_streamid
a=ssrc:3405199309 label:54b40235-260b-4f6b-96cf-e72940e4ea9d_trackid
```

至此双方的Offer和Answer协商完毕，随后在stun连接成功后将发送/接收视频数据。

#### c. 注意事项

在Chrome中如果同时发送多路视频，目前存在两种方式：

* 多路视频方式(Multi-stream)  
	* 通过获取多个本地视频流并添加到RTCPeerConenction中(addStream)，createOffer将会自动在同一个`m=video`和`a=mid`下生成相应的`a=ssrc-group:FID`子项.  
	* 获取多个视频流具有如下要求: 后续视频流宽高不能大于第一路视频流，并且第一路视频流是其它路视频流的整数倍(宽和高)。  
	也即是说,其它路视频流实际是第一路视频流的下采样子流。
	
* 视频联播方式(Simulcast)  
	最新版本Chrome支持Simulcast, 基本语法与多路视频流类似，具体方式如下:
	
	* 只需要调用一次addStream添加第一个视频流,
	* 发送多路视频(N路)，则需在同一个`m=video`和`a=mid`下额外添加(N-1)个`a=ssrc-group:FID`子项（API不支持需手动修改SDP）,
	* 添加一些simulcast辅助属性(参照下例),并调用setLocalDescription生效
	* 多路视频中其它视频流的宽高与第一路视频流的关系，与Multi-stream一样
	
	```
	a=ssrc-group:FID 111 112
	...
	a=ssrc-group:FID 211 212
	...
	a=ssrc-group:SIM 111 211
	a=x-google-flag:conference
	```
	注意：Simulcast仅支持VP8编码，对于VP9/H264将被自动降为一路视频(firefox类似)。
	
	
### 3. Firefox SDP

#### 1). SDP Offer

只发送一路视频且支持接收一路视频的示例如下

```
v=0
o=mozilla...THIS_IS_SDPARTA-57.0.2 8160053667584719276 1 IN IP4 0.0.0.0
s=-
t=0 0
a=sendrecv
a=fingerprint:sha-256 2E:25:88:57:24:8E:54:31:94:59:FA:25:7E:0A:37:D8:48:B7:92:0E:C4:13:0F:AD:68:31:83:08:0A:01:CE:9B
a=group:BUNDLE sdparta_0 sdparta_1
a=ice-options:trickle
a=msid-semantic:WMS *

m=video 62739 UDP/TLS/RTP/SAVPF 126 121 120 97
c=IN IP4 0.0.0.0
a=sendrecv
a=extmap:1 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:2 urn:ietf:params:rtp-hdrext:toffset
a=fmtp:126 profile-level-id=42e01f;level-asymmetry-allowed=1;packetization-mode=1
a=fmtp:97 profile-level-id=42e01f;level-asymmetry-allowed=1
a=fmtp:121 max-fs=12288;max-fr=60
a=fmtp:120 max-fs=12288;max-fr=60
a=ice-pwd:588d6957e8e15f85dbdbb853825240c3
a=ice-ufrag:419b2f0d
a=mid:sdparta_0
a=msid:{454102ee-59c8-476d-b1e7-5428bb17a318} {b657b0be-8b2a-4321-8770-2526e16991ea}
a=rtcp-fb:126 nack
a=rtcp-fb:126 nack pli
a=rtcp-fb:126 ccm fir
a=rtcp-fb:126 goog-remb
a=rtcp-fb:121 nack
a=rtcp-fb:121 nack pli
a=rtcp-fb:121 ccm fir
a=rtcp-fb:121 goog-remb
a=rtcp-fb:120 nack
a=rtcp-fb:120 nack pli
a=rtcp-fb:120 ccm fir
a=rtcp-fb:120 goog-remb
a=rtcp-fb:97 nack
a=rtcp-fb:97 nack pli
a=rtcp-fb:97 ccm fir
a=rtcp-fb:97 goog-remb
a=rtcp-mux
a=rtpmap:126 H264/90000
a=rtpmap:121 VP9/90000
a=rtpmap:120 VP8/90000
a=rtpmap:97 H264/90000
a=setup:actpass
a=ssrc:2639986493 cname:{dc684271-f581-421e-aaed-2a2fb69b2e27}

m=application 62739 DTLS/SCTP 5000
c=IN IP4 0.0.0.0
a=sendrecv
a=ice-pwd:588d6957e8e15f85dbdbb853825240c3
a=ice-ufrag:419b2f0d
a=mid:sdparta_1
a=sctpmap:5000 webrtc-datachannel 256
a=setup:actpass
a=max-message-size:1073741823
```

从该sdp中可以知道如下信息:   

```
cname为dc684271-f581-421e-aaed-2a2fb69b2e27.
支持的视频编码为H264/VP9/VP8，通过rtpmap payload区分,
发送视频RTP数据ssrc为2639986493，
发送视频streamId为454102ee-59c8-476d-b1e7-5428bb17a318,
发送视频trackId为b657b0be-8b2a-4321-8770-2526e16991ea,
```


#### 2). SDP Answer

只接收一路且不发送视频(选择H264编码)的Answer格式如下。

```c
v=0
o=- 909859953 2 IN IP4 127.0.0.1
s=-
t=0 0
a=sendrecv
a=fingerprint:sha-256 B6:51:99:A3:14:B9:E5:AC:98:9C:D1:2C:B5:96:18:FA:01:4A:C0:12:39:32:EB:D9:AC:CB:0D:16:5F:09:3F:EF
a=group:BUNDLE sdparta_0 sdparta_1
a=msid-semantic:WMS

m=video 1 UDP/TLS/RTP/SAVPF 126
c=IN IP4 0.0.0.0
a=fmtp:126 profile-level-id=42e01f;level-asymmetry-allowed=1;packetization-mode=1
a=ice-pwd:Mxm8W16Cojz6ViZ1xriFr0fE
a=ice-ufrag:jvhy0bTdQQ7XxaxxFCpIIh/6QKwSv7qL-0
a=mid:sdparta_0
a=rtcp:1 IN IP4 0.0.0.0
a=rtcp-fb:126 nack
a=rtcp-fb:126 nack pli
a=rtcp-fb:126 ccm fir
a=rtcp-fb:126 goog-remb
a=rtcp-mux
a=rtpmap:126 H264/90000
a=setup:passive

m=application 9 DTLS/SCTP 5000
c=IN IP4 0.0.0.0
a=sendrecv
a=ice-pwd:Mxm8W16Cojz6ViZ1xriFr0fE
a=ice-ufrag:jvhy0bTdQQ7XxaxxFCpIIh/6QKwSv7qL-0
a=mid:sdparta_1
a=sctpmap:5000 webrtc-datachannel 256
a=setup:passive
```

如果当前接收一路视频且需要发送一路视频，则需要添加发送信息(格式与offer类似)

```
a=msid:{54b40235-260b-4f6b-96cf-e72940e4ea9d_streamid} {54b40235-260b-4f6b-96cf-e72940e4ea9d_trackid} 
...
a=ssrc:1287668962 cname:{+T5LKYkAJtmH1eBB}
```

#### 3). 注意事项
如果同时发送多路视频，Firefox也存在两种方式：

* 多路视频方式(Multi-stream)
	* Firefox将会添加新的`m=video`和`a=mid`并在其中添加`a=ssrc:...`子项。
	* 其它与Chrome中类似。

* 视频联播方式(Simulcast)   
	Firefox支持使用API(rid)设置Simulcast属性，只支持VP8编码。
	通过rid属性标识多组流(rtp扩展头也将带有这个属性).
	
	```
	var videoSender = RTCPeerConnection.getSenders()[0];
	videoSender.setParameters({encodings: [
		{ rid: "r0", active: true, priority: "low" },
		{ rid: "r1", active: true, priority: "high" }
	]);
		
	>>offer格式
	a=rid:r0 send
	a=rid:r1 send
	a=simulcast: send rid=r0;r1
		
	>>answer格式:
	a=rid:r0 recv
	a=rid:r1 recv
	a=simulcast: recv rid=r0;r1
	```
	
	
