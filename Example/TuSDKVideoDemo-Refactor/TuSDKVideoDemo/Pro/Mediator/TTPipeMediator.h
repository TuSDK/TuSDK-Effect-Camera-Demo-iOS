//
//  TTPipeMediator.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>
#import "TTRenderDef.h"
#import "TTRecordManager.h"
#import "TTBeautyManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTPipeMediator : NSObject
TT_INIT_UNAVAILABLE;

/**
 * 初始化预览画面
 * @param containerView 容器视图
 */
- (instancetype)initWithContainer:(UIView *)containerView NS_DESIGNATED_INITIALIZER;

// MARK: - Convert
////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * 向 SDK 发送采集的视频数据 并返回处理过图像
 * @param sampleBuffer 视频样本 yuv/bgra
 * @return 返回处理过的图像
 */
- (TUPFPImage *)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 * 向 SDK 发送采集的视频数据 并返回处理过图像
 * @param pixelBuffer 视频样本 yuv/bgra
 * @return 返回处理过的图像
 */
- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 * 向 SDK 发送采集的音频数据
 * @param sampleBuffer 音频样本 pcm
 */
- (void)sendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 * 向 SDK 发送播放的音频数据
 * @param bufferList 需要赋值音频数据
 */
- (void)sendAudioPlayBufferList:(AudioBufferList)bufferList;
/**
 * 设置视频像素格式
 * @param pixelFormat yuv bgra
 */
- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat;

/**
 * 设置样本输出分辨率(size 归一化)
 */
- (void)setOutputSize:(CGSize)outputSize;

/**
 * 设置分辨率，默认1080*1920
 */
- (void)setOutputResolution:(CGSize)outPutResolution;

/**
 * 设置变声
 * @param soundPitchType 变声类型
 */
- (void)setSoundPitchType:(TTVideoSoundPitchType)soundPitchType;

/**
 * 设置背景音乐
 * @param path 音乐路径
 */
- (void)setBGM:(NSString *)path;

// MARK: - Editor
////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * 获取美颜对象
 * 美肤、微整形、美妆、滤镜、动态贴纸、哈哈镜
 * @return 获取美颜对象管理器
 */
- (TTBeautyManager *)getBeautyManager;
/**
 * 设置合拍
 * @param direction 布局
 * @param videoPath 视频地址
 */
- (void)setJoiner:(TTJoinerDirection)direction videoPath:(NSString *)videoPath;


// MARK: - Preview
////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * 设置画面比例
 * @param aspectRatio full 3:4 1:1
 */
- (void)setAspectRatio:(TTVideoAspectRatio)aspectRatio;

/**
 * 设置画面背景颜色
 * @param backgroundColor 背景颜色
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor;

/**
 * 拍照/截图
 */
- (UIImage *)snapshot;

// MARK: - Record
////////////////////////////////////////////////////////////////////////////////////////////////
///
/// 获取录制管理器
- (TTRecordManager *)getRecordManager;
/**
 * 设置视频录制的委托对象
 * @param recordDelegate TTRecordListener
 */
- (void)setRecordDelegate:(id<TTRecordListener>)recordDelegate;

/// start/resume recording
- (BOOL)startRecording;

/**
 * 暂停录制 每一次暂停录制都会生成一个视频片段
 */
- (void)pauseRecord;

/**
 * 结束录制
 */
- (void)stopRecord;

/**
 * 删除当前录制视频最后一片段
 */
- (void)deleteLastRecordPart;

/**
 * 设置录制速率
 * @param recordSpeed 录制速率
 */
- (void)setRecordSpeed:(TTVideoRecordSpeed)recordSpeed;

/**
 * 获取录制总进度
 */
- (CGFloat)getRecordingProgress;

/**
 * 设置是否静音录制，默认为NO
 * @param isMute 静音状态
 */
- (void)setMute:(BOOL)isMute;

/// 销毁
- (void)destory;

@end

NS_ASSUME_NONNULL_END
