title: 视频编码的颜色空间
tags:
  - media
categories:
  - 技术
date: 2016-05-24 08:18:00
---
简单来说，视频编解码即是对构成图像的颜色进行处理，减少表达颜色效果所需要的比特数。
颜色效果是由颜色空间(colorspace)来表达，在视频编解码中常用的有两种: RGB和YUV。


### 1. RGB和YUV

RGB即三基色(红绿蓝)，是日常生活中使用的一种表达方式。  
三种基色的地位基本平等，在计算机里也基本由同样bit数来表达(当然也存在类似RGB565的)。  

而YUV是根据人眼视觉系统的特性而定义的一种颜色空间。  
其基本理论是：人眼对亮度信息比色度和饱和度更为敏感。  
因而可以通过对亮度信息分配更多的bit并减少饱和度bit数，从整体上减少bit数而不减弱观看效果，起到压缩效果。

YUV常见的格式有: I420, YV12, NV12, NV21, 其像素排布如下

```
I420:   (1Y) + (1/4U) + (1/4V), | Y...Y | U..U | V..V |
YV12:   (1Y) + (1/4U) + (1/4V), | Y...Y | V..V | U..U |
NV12:   (1Y) + (1/4U) + (1/4V), | Y...Y | UVUV.. |
NV21:   (1Y) + (1/4U) + (1/4V), | Y...Y | VUVU.. |

```

### 2. YUV内存分布

![YUV_DATA](https://github.com/PeterXu/wiki-streaming/raw/master/trunk/res/colorspace_data.png)


### 3. YUV转换示例

```
# color convert
void convert_nv21_to_i420(const char *src, char *dst, int stride, int height)
{
    int ysize = stride * height;
    int usize = ysize / 4;

    char *udst = dst + ysize;
    char *vdst = dst + ysize + usize;

    const char *vusrc = src + ysize;

    /* copy y color */
    memcpy(dst, src, ysize);

    /* copy u and v color */
    for (int i=0; i < usize; i++) 
    {
        udst[i] = vusrc[i*2+1];
        vdst[i] = vusrc[i*2];
    }
}
```

