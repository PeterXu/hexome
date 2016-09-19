title: ffmpeg-usage
date: 2016-07-04 15:46:50
tags:
---
ffmpeg常用命令参数
=================



## devices

show system devices/codecs/..
  
```
ffmpeg -devices  
ffmpeg -devices true -f dshow -i dummy  
ffmpeg -encoders  
ffmpeg -decoders

# read audio/video data from device  
ffmpeg -f dshow -i video="Integrated Camera" -f dshow -i audio=".."  
ffmpeg -f video4linux2 -i /dev/video0   
```


## video
video encoder

```
-c:v libx264 -v profile baseline -s 640x480 -b:v 512k -g 12
```

-c:v:  					codec of video  
-b:v bitrate:  			bitrate of video(-b)  
-s size:  				frame size(WxH)    
-r rate:				frame rate(HZ, e.g. 90000)  
-g size: 				gop size(default 12)  
-aspect aspect:			aspect ratio (4:3, 16:9 or 1.3333, 1.7777)  
-v profile baseline:  	codec profile  
-keyint_min <int>:		minimum interval between IDR-frames(default 25)  
-force_key_frames timestamps:  force key frames at timestamps, e.g. -force_key_frames 0,2,4,6,8  
-vn:					diasbale video


if issues happen as below:  
1). "ffmpeg Past duration 0.999992 too large"  
due to uncertain framerates, fix it by setting -filter:v fps=(your framerate).  
```
-filter:v fps=20
```

2). "[video input] too full or near too full"  
This is because h264 encoder requires yuv420 input  
```
-pix_fmt yuv420p
```


## audio

```
-c:a aac -ar 44100 -ac 1 -ab 64k -strict -2 -f flv rtmp://localhost/hls/test
```

-c:a codec:  			codec of audio  
-b:a bitrate:			audio bitrate(-ab)  
-ar rate:				audio sampling rate(HZ, default 0)  
-ac channels:			audio channels(default 0)  
-f fmt:					force format  
-an:					disable audio


## outputs

duplicate outputs. One to file, second to nginx-rtmp.
```
ffmpeg -i input1 -i input2 
	-acodec … -vcodec … output1 
	-acodec … -vcodec … output2 
	-acodec … -vcodec … output3
    
ffmpeg -i input 
	-s 1280x720 -acodec … -vcodec … output1 
	-s 640x480  -acodec … -vcodec … output2 
	-s 320x240  -acodec … -vcodec … output3    
```


## examples

ffmpeg examples  
```
ffmpeg -re -i test.mp4 -c copy -f flv rtmp://localhost/hls/test0  
ffmpeg -re -i test.mp4 
	-pix_fmt yuv420p -c:v libx264 -vprofile baseline 
	-c:a aac -ar 44100 -ac 1 -strict -2 
	-f flv rtmp://localhost/hls/test1 
ffmpeg -f dshow -i video="Integrated Camera" -f dshow -i audio="Audio" 
    -pix_fmt yuv420p -c:v libx264 -vprofile baseline -s 640x480 -b:v 512k -filter:v fps=20 -g 10 
	-c:a aac -ar 44100 -ac 1 -b:a 64k -strict -2 
	-f flv rtmp://localhost/hls/test2  
```

ffplay examples  
```
ffplay -fflags nobuffer rtmp://localhost/hls/mystream -loglevel verbose  
ffplay -live_start_index -1 hls://localhost/app/mystream.m3u8
```


