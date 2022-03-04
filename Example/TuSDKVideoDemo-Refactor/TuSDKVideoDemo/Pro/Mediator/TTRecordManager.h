//
//  TTRecordManager.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"

NS_ASSUME_NONNULL_BEGIN
@class TUPFPImage;
@class TTRecordManager;
@protocol TTRecordListener <NSObject>
@optional
/// 录制状态
- (void)recordManager:(TTRecordManager *)recordManager  onRecordState:(TTRecordState)state;
/// 录制进度 毫秒
- (void)recordManager:(TTRecordManager *)recordManager progress:(NSInteger)milliSecond;
/// 录制结束 视频沙盒地址
- (void)recordManager:(TTRecordManager *)recordManager didFinish:(NSURL *)videoPath;
/// 错误回调
- (void)recordManager:(TTRecordManager *)recordManager error:(NSError * __nullable)error;
@end

@interface TTRecordManager : NSObject
@property(nonatomic, weak) id<TTRecordListener> delegate;
@property(nonatomic, readonly) TTRecordState state;

/// 最小录制时长 单位: ms 默认: 3000
@property(nonatomic) NSInteger minDuration;
/// 最大录制时长 单位: ms 默认: 15000
@property(nonatomic) NSInteger maxDuration;
/// 音频声道
@property(nonatomic) int channels;
/// 音频采样率
@property(nonatomic) int sampleRate;

/// 向 录制 发送fpImage
/// @param fpImage 图像
/// @param timestamp 时间戳
- (void)sendFPImage:(TUPFPImage *)fpImage timestamp:(NSInteger)timestamp;

/// 向 录制 发送pcm
/// @param pcm 音频
/// @param len 数据长度
- (void)sendPCMData:(void *)pcm len:(size_t)len;

/// 设置录制速率
/// @param recordSpeed 录制速率
- (void)setRecordSpeed:(TTVideoRecordSpeed)recordSpeed;

/// 设置全局水印
/// @param waterMark 全局水印图片
/// @param position 水印位置
- (void)setWaterMark:(UIImage *)waterMark position:(TTVideoWaterMarkPosition)position;

/// 设置是否静音录制
- (void)setMute:(BOOL)isMute;

/// start/resume recording
- (BOOL)record;

/// 暂停录制 每一次暂停录制都会生成一个视频片段
- (void)pauseRecord;

/// 结束录制 close the file.
- (void)stopRecord;

/// 取消当前录制
- (void)cancleRecording;

// MARK: - 多段录制
////////////////////////////////////////////////////////////////////////////////////////////////

/// 获取录制总时长 单位: ms
- (NSInteger)getDuration;

/// 获取录制总进度
- (CGFloat)getRecordingProgress;

/// 获取当前录制所有视频片段路径
- (NSArray<NSString *> *)getVideoPathList;

/// 删除当前录制视频最后一片段
- (void)deleteLastPart;

/// 删除当前录制视频所有片段
- (void)deleteAllParts;

@end

NS_ASSUME_NONNULL_END
