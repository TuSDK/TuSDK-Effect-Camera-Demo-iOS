//
//  TTAudioConvert.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//  音频转换对象

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TuSDKPulse/TuSDKPulse.h>
#import "TTRenderDef.h"
NS_ASSUME_NONNULL_BEGIN

@class TTAudioConvert;
@protocol TTAudioConvertDelegate <NSObject>
@optional

/**
 * 转换回调
 * @param audioConvert 转换会话
 * @param pcm pcm buffer
 * @param len 数据长度
 */
- (void)audioConvert:(TTAudioConvert *)audioConvert didOutputPCMData:(void *)pcm len:(size_t)len;
@end

@interface TTAudioConvert : NSObject
TT_INIT_UNAVAILABLE;
/**
 * 初始化转换会话
 * @param delegate 委托
 * @param queue 操作队列
 */
- (instancetype)initWithDelegate:(id<TTAudioConvertDelegate>)delegate delegateQueue:(TUPDispatchQueue *)queue NS_DESIGNATED_INITIALIZER;

/**
 * 向 SDK 发送采集的音频数据
 * @param sampleBuffer 音频样本 pcm
 */
- (void)sendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 * 向 SDK 发送播放的音频数据 需要添加背景音乐
 * @param bufferList 需要赋值的音频数据
 */
- (void)sendAudioPlayBufferList:(AudioBufferList)bufferList;

/**
 * 设置变声
 * @param soundPitchType 变声类型
 */
- (void)setSoundPitchType:(TTVideoSoundPitchType)soundPitchType;

/**
 * 设置背景音乐
 * path  背景音乐路径
 */
- (void)setBGM:(NSString *)path;

/**
 * 开始混音
 * @param startTime 音乐播放起始时间
 */
- (void)startMixerFromTime:(NSInteger)startTime;

/// 暂停混音 变声等
- (void)pause;

/// 停止播放背景音乐
- (void)stopBGM;

/// 销毁
- (void)destory;
@end

NS_ASSUME_NONNULL_END
