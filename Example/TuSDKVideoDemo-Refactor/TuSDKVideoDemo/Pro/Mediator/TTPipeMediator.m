//
//  TTPipeMediator.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTPipeMediator.h"
#import <TuSDKPulse/TuSDKPulse.h>
#import "TTImageConvert.h"
#import "TTAudioConvert.h"
#import "TTBeautyManager.h"
#import "TTPreviewManager.h"

@interface TTPipeMediator () <TTAudioConvertDelegate, TTRecordListener>
@property(nonatomic, strong) TUPDispatchQueue *queue;
@property(nonatomic, strong) TTImageConvert *imageConvert;
@property(nonatomic, strong) TTAudioConvert *audioConvert;
@property(nonatomic, strong) TTPreviewManager *previewManager;
@property(nonatomic, strong) TTBeautyManager *beautyManager;
@property(nonatomic, strong) TTRecordManager *recordManager;
@property(nonatomic, strong) TUPFPImage *outputFPImage;

@end

@implementation TTPipeMediator

- (instancetype)initWithContainer:(UIView *)containerView {
    self = [super init];
    if (self) {
        _queue = [[TUPDispatchQueue alloc] initWithName:@"TTCameraMediator_Queue"];
        _imageConvert = [[TTImageConvert alloc] init];
        _audioConvert = [[TTAudioConvert alloc] initWithDelegate:self delegateQueue:_queue];
        _beautyManager = [[TTBeautyManager alloc] initWithQueue:_queue];
        _previewManager = [[TTPreviewManager alloc] initWithContainer:containerView];
        _recordManager = [[TTRecordManager alloc] init];
        _recordManager.delegate = self;
    }
    return self;
}

- (TUPFPImage *)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    NSInteger timestamp = [TTPipeMediator timestampWithSampleBuffer:sampleBuffer];
    [_queue runSync:^{
        TUPFPImage *fpImage = [self.imageConvert sendVideoSampleBuffer:sampleBuffer];
        // 前后处理: 美颜、滤镜等
        TUPFPImage *processFPImage = [self.beautyManager sendFPImage:fpImage];
        
        self.outputFPImage = processFPImage;
        // 预览
        [self.previewManager update:self.outputFPImage];
        // 录制
        [self.recordManager sendFPImage:self.outputFPImage timestamp:timestamp];
        
    }];
    return self.outputFPImage;
}

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    [_queue runSync:^{
        
        int64_t timestamp = (int64_t)([[NSDate date]timeIntervalSince1970] * 1000);
        TUPFPImage *fpImage = [self.imageConvert sendVideoPixelBuffer:pixelBuffer withTimestamp:timestamp];
        // 前后处理: 美颜、滤镜等
        TUPFPImage *processFPImage = [self.beautyManager sendFPImage:fpImage];
        
        self.outputFPImage = processFPImage;
        // 预览
        [self.previewManager update:self.outputFPImage];
        // 录制
        [self.recordManager sendFPImage:self.outputFPImage timestamp:timestamp];
        
    }];
    return self.outputFPImage;
}

- (void)sendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // 前后处理：变速、混音等
    [self.audioConvert sendAudioSampleBuffer:sampleBuffer];
}

// MARK: - TTAudioConvertDelegate
- (void)audioConvert:(TTAudioConvert *)audioConvert didOutputPCMData:(void *)pcm len:(size_t)len {
    // 录制
    [self.recordManager sendPCMData:pcm len:len];
}

- (void)sendAudioPlayBufferList:(AudioBufferList)bufferList {
    [self.audioConvert sendAudioPlayBufferList:bufferList];
}

- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat {
    [self.imageConvert setPixelFormat:pixelFormat];
}

- (void)setOutputSize:(CGSize)outputSize {
    [self.previewManager setOutputResolution:outputSize];
    [self.imageConvert setOutputSize:outputSize];
}

- (void)setOutputResolution:(CGSize)outPutResolution
{
    [self.previewManager setOutputResolution:outPutResolution];
}

- (void)setSoundPitchType:(TTVideoSoundPitchType)soundPitchType {
    [self.audioConvert setSoundPitchType:soundPitchType];
}

- (void)setBGM:(NSString *)path {
    [self.audioConvert setBGM:path];
}

- (TTBeautyManager *)getBeautyManager {
    return self.beautyManager;
}

- (TTRecordManager *)getRecordManager {
    return self.recordManager;
}

- (void)setJoiner:(TTJoinerDirection)direction videoPath:(NSString *)videoPath {
    [self.beautyManager setJoiner:direction videoPath:videoPath];
    [self.audioConvert setBGM:videoPath];
}


- (void)setAspectRatio:(TTVideoAspectRatio)aspectRatio {
    CGRect rect = [self.previewManager setAspectRatio:aspectRatio];
    [self.imageConvert setOutputSize:rect.size];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self.previewManager setBackgroundColor:backgroundColor];
}

- (UIImage *)snapshot {
    return [self.previewManager snapshot];
}

- (void)setRecordDelegate:(id<TTRecordListener>)recordDelegate {
    self.recordManager.delegate = recordDelegate;
}

- (BOOL)startRecording {
    BOOL res = [self.recordManager record];
    if (res) {
        // 开始混音
        [self.audioConvert startMixerFromTime:[self.recordManager getDuration]];
        // 播放合拍视频
        [self.beautyManager playJoiner:YES];
    }
    return res;
}

- (void)pauseRecord {
    [self.recordManager pauseRecord];
    // 暂停BGM
    [self.audioConvert pause];
    // 合拍暂停
    [self.beautyManager playJoiner:NO];
}

- (void)stopRecord {
    [self.recordManager stopRecord];
    [self.beautyManager setJoinerStartTime:0];
}

- (void)deleteLastRecordPart {
    [self.recordManager deleteLastPart];
    [self.beautyManager setJoinerStartTime:[self.recordManager getDuration]];
}

- (void)setRecordSpeed:(TTVideoRecordSpeed)recordSpeed {
    [self.recordManager setRecordSpeed:recordSpeed];
    // 设置合拍视频速率
    [self.beautyManager setJoinerSpeed:recordSpeed startTime:[self.recordManager getDuration]];
}
/// 获取录制总进度
- (CGFloat)getRecordingProgress;
{
    return [self.recordManager getRecordingProgress];
}

- (void)setMute:(BOOL)isMute {
    [self.recordManager setMute:isMute];
}

- (void)destory {
    [_audioConvert destory];
    [_previewManager destory];
    [_beautyManager destory];
    [_imageConvert destory];
    _beautyManager = nil;
    _imageConvert = nil;
    _previewManager = nil;
    _outputFPImage = nil;
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self classForCoder]);
}

+ (NSInteger)timestampWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    return (1000 * presentationTimeStamp.value) / presentationTimeStamp.timescale;
}

@end
