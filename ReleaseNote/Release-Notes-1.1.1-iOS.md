# TuSDK-Effect-Camera Release Notes for 1.1.1



## 简介

涂图流处理（特效相机） SDK 是涂图基于特效渲染引擎与采集相结合的 SDK 产品。产品分为 2 个分类，一种是使用完整的涂图相机 + 特效渲染引擎；一种是使用第三方采集 + 涂图特效渲染引擎。
前者更多是适用于自采集和视频录制场景，后者更多是适用于使用第三方直播 SDK 场景使用。



## 功能

* 人脸模块分离；
* 已知BUG修复 ;



## 方法变更

#### 新增

`TTImageConvert.m` 里新增

```objective-c
@class TUPFPBuffer;
/**
 * 向 SDK 发送采集的视频数据 返回图像
 * @param pixelBuffer 视频样本
 * @param timestamp 连续时间戳
 */
- (TUPFPBuffer *)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp;
/**
 * 向 SDK 发送采集的视频数据 返回图像
 * @param sampleBuffer 视频样本
 */
- (TUPFPBuffer *)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
```

#### 变更

`TTBeautyManager.m` 里变更

```objective-c
@class TUPFPBuffer;
/**
 * 向 美颜 发送图像 并返回编辑处理后的图像
 * @param fpImage 图像
 */

//变更前
- (TUPFPImage *)sendFPImage:(TUPFPImage *)fpImage;

//变更后
- (TUPFPImage *)sendFPImage:(TUPFPImage *)fpImage buffer:(TUPFPBuffer *)fpBuffer;
```

## 接口变更

#### 新增

`TUPFPBuffer` 类

该处理需声明为全局变量

 ```objective-c
 @interface TUPFPDetector : NSObject
 
 - (instancetype)initWithType:(NSInteger)type;
 
 - (TUPFPDetectResult *)do_detect:(TUPFPBuffer *)buffer;
 
 //销毁
 - (void)destory;
 
 @end
 
 //声明
 @property(nonatomic, strong) TUPFPDetector *detector;
 //实现(此处type固定传1)
 self.detector = [[TUPFPDetector alloc] initWithType:1];
 //处理 TUPFPBuffer 获得 TUPFPDetectResult，然后传入process处理
 TUPFPDetectResult *result = [_detector do_detect:fpBuffer];
 ```

#### 变更

`TUPFilterPipe` 类

```objective-c
//无需处理人脸相关接口
- (TUPFPImage*) process:(TUPFPImage*) image;
//处理人脸相关接口
- (TUPFPImage*) process:(TUPFPImage*) image buffer:(TUPFPDetectResult *)buffer;
```

