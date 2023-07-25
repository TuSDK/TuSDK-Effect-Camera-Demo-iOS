//
//  TTImageConvert.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//  图像转换对象

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TTRenderDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TUPFPImage;
@class TUPFPBuffer;

@interface TTImageConvert : NSObject

/**
 * 向 SDK 发送采集的视频数据 返回图像
 * @param sampleBuffer 视频样本
 */
- (TUPFPImage *)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (TUPFPBuffer *)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 * 向 SDK 发送采集的视频数据 返回图像
 * @param pixelBuffer 视频样本
 */
- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer ;
/**
 * 向 SDK 发送采集的视频数据 返回图像
 * @param pixelBuffer 视频样本
 * @param timestamp 连续时间戳
 */
- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp;
- (TUPFPBuffer *)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp;
/**
 * 向 SDK 发送采集的视频数据 返回图像
 * @param pixelBuffer 视频样本
 * @param timestamp 连续时间戳
 * @param rotation 旋转方向
 * @param flip 是否上下镜像
 * @param mirror 是否左右镜像
 */
- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp rotation:(int)rotation flip:(BOOL)flip mirror:(BOOL)mirror;

/**
 * 设置视频像素格式
 * @param pixelFormat yuv bgra
 */
- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat;

/// 设置样本输出分辨率(size 归一化)
- (void)setOutputSize:(CGSize)outputSize;

/// 设置分辨率，默认1080P
- (void)setOutputResolution:(CGSize)outputResolution;


//对象销毁
- (void)destory;
@end

NS_ASSUME_NONNULL_END
