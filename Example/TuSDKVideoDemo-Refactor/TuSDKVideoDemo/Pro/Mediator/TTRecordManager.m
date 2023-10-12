//
//  TTRecordManager.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTRecordManager.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>

@interface TTVideoFragment : NSObject
@property(nonatomic, strong) TUPFPFileExporter_Config *config;
@property(nonatomic, strong) TUPFPFileExporter *exporter;
/// 多段录制 起始时间
@property(nonatomic, assign) NSInteger beginTime;
/// 时长
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, assign) NSInteger ts;
@end
@implementation TTVideoFragment
- (instancetype)initWithIndex:(NSInteger)index beginTime:(NSInteger)beginTime {
    self = [super init];
    if (self) {
        _duration = 0;
        _beginTime = beginTime;
        
        _config = [[TUPFPFileExporter_Config alloc] init];
        _config.savePath = [NSString stringWithFormat:@"file://%@TTRecordFragment%lu.mp4",NSTemporaryDirectory(),index + 1];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_config.savePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_config.savePath error:nil];
        }
        _exporter = [[TUPFPFileExporter alloc] init];
    }
    return self;
}

- (void)setupWidth:(NSInteger)width height:(NSInteger)height {
    self.config.width = (int)(width % 2 != 0 ? (width + 1) : width); //偶数
    self.config.height = (int)height;
    [self.exporter open:self.config];
}

- (NSInteger)getTime {
    return self.beginTime + self.duration * self.config.stretch;
}
@end

@interface TTRecordManager ()
@property(nonatomic, assign) float speed;
@property(nonatomic, strong) UIImage *watermarkImage;
@property(nonatomic, assign) BOOL isMute;
@property(nonatomic, assign) TTVideoWaterMarkPosition waterMarkPosition;
@property(nonatomic, strong) NSMutableArray<TTVideoFragment *> *fragments;
@property(nonatomic, assign) TTRecordState state;
@property(nonatomic, assign) NSInteger videoStartTs;
@property(nonatomic, assign) NSInteger audioStartTs;
@property(nonatomic, assign) TTVideoRecordSpeed videoRecordSpeed;   //视频录制速率

@end

@implementation TTRecordManager
- (instancetype)init {
    self = [super init];
    if (self) {
        _minDuration = 3000;
        _maxDuration = 15000;
        _channels = 1;
        _sampleRate = 44100;
        _watermarkImage = [UIImage imageNamed:@"sample_watermark.png"];
        _waterMarkPosition = TTVideoWaterMarkPositionBottomRight;
        _speed = 1;
        _isMute = false;
        _fragments = [NSMutableArray array];
        _state = TTRecordStateNone;
        _videoRecordSpeed = TTVideoRecordSpeed_NOMAL;
    }
    return self;
}

- (void)sendFPImage:(TUPFPImage *)fpImage timestamp:(NSInteger)timestamp {
    if (self.state == TTRecordStateNone) {
        return;
    }
    
    TTVideoFragment *fragment = [self.fragments lastObject];
    if (self.state == TTRecordStatePrepare) {
        [fragment setupWidth:[fpImage getWidth] height:[fpImage getHeight]];
        self.state = TTRecordStateRecording;
    } else if (self.state == TTRecordStateRecording) {
        if (fragment.ts == 0) {
            fragment.ts = timestamp;
        }
        fragment.duration = timestamp - fragment.ts;
        NSInteger totalDuration = [fragment getTime];
        NSLog(@"TTRecordManager recording total: %ld duration: %ld", (long)totalDuration, fragment.duration);
        if (totalDuration >= self.maxDuration) {
            self.state = TTRecordStateTimeout;
        } else {
            if ([self.delegate respondsToSelector:@selector(recordManager:progress:)]) {
                [self.delegate recordManager:self progress:totalDuration];
            }
            [fragment.exporter sendVideo:fpImage withTimestamp:fragment.duration];
        }
    }
}

- (void)sendPCMData:(void *)pcm len:(size_t)len {
    if (self.state == TTRecordStateNone || self.isMute) {
        return;
    }
    if (self.state == TTRecordStateRecording) {
        TTVideoFragment *fragment = [self.fragments lastObject];
        [fragment.exporter sendAudio:pcm andSize:len withTimestamp:fragment.duration];
    }
}
//设置录制速率
- (void)setRecordSpeed:(TTVideoRecordSpeed)recordSpeed {
    _videoRecordSpeed = recordSpeed;
    _speed = TTVideoRecordSpeedValue(recordSpeed);
}

- (void)setWaterMark:(UIImage *)waterMark position:(TTVideoWaterMarkPosition)position {
    _watermarkImage = waterMark;
    _waterMarkPosition = position;
}

- (void)setMute:(BOOL)isMute {
    _isMute = isMute;
}

- (BOOL)record {
    if (self.state == TTRecordStateRecording) {
        return false;
    }
    NSInteger duration = [self getDuration];
    if (duration >= self.maxDuration) {
        [self fetchErrorMessage:@"大于最大时长，请保存视频后继续录制"];
        return false;
    }
    
    TTVideoFragment *fragment = [[TTVideoFragment alloc] initWithIndex:self.fragments.count beginTime:duration];
    fragment.config.channels = self.channels;
    fragment.config.sampleRate = self.sampleRate;
    fragment.config.watermark = self.watermarkImage;
    fragment.config.watermarkPosition = (int)self.waterMarkPosition;
    fragment.config.stretch = self.speed;
    [self.fragments addObject:fragment];
    self.state = TTRecordStatePrepare;
    return true;
}

- (void)pauseRecord {
    self.state = TTRecordStatePaused;
    TTVideoFragment *fragment = [self.fragments lastObject];
    if (!fragment) {
        return;
    }
    [fragment.exporter close];
}

- (void)stopRecord {
    NSInteger duration = [self getDuration];
    if (duration < self.minDuration) {
        [self fetchErrorMessage:@"不能低于最小时间"];
        return;
    }
    
    NSArray *paths = [self getVideoPathList];
    if (paths.count == 1) {
        [self outputPath:paths.firstObject];
        return;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *mergePath = [NSString stringWithFormat:@"file://%@TUSDK%@.mp4", NSTemporaryDirectory(), [dateFormat stringFromDate:[NSDate date]]];
    
    BOOL ret = [TUPFPFileExporter mergeVideoFiles:paths to:mergePath];
    NSLog(@"录制合并 %d",ret);
    if (!ret) {
        [self fetchErrorMessage:@"录制失败"];
        return;
    }
    [self outputPath:mergePath];
}

- (void)outputPath:(NSString *)path {
    self.state = TTRecordStateComplete;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(recordManager:didFinish:)]) {
            [self.delegate recordManager:self didFinish:[NSURL URLWithString:path]];
        }
    });
    [self deleteAllParts];
}

- (void)cancleRecording {
    self.state = TTRecordStateNone;
    [self deleteAllParts];
}

- (NSInteger)getDuration {
    NSInteger total = 0;
    for (TTVideoFragment *fragment in self.fragments) {
        total += (fragment.duration * fragment.config.stretch);
    }
    return total;
}

/// 获取录制进度
- (CGFloat)getRecordingProgress
{
    NSInteger totalDuration = [self getDuration];
    return 1.0f * totalDuration / _maxDuration;
}

- (NSArray<NSString *> *)getVideoPathList {
    NSMutableArray<NSString *> *paths = [NSMutableArray array];
    for (TTVideoFragment *fragment in self.fragments) {
        [paths addObject:fragment.config.savePath];
    }
    return [paths copy];
}

- (void)deleteLastPart {
    if (self.state == TTRecordStateRecording) {
        return;
    }
    [self.fragments removeLastObject];
    if (self.fragments.count == 0) {
        self.state = TTRecordStateNone;
    }
}

- (void)deleteAllParts {
    if (self.state == TTRecordStateRecording) {
        return;
    }
    [self.fragments removeAllObjects];
    self.state = TTRecordStateNone;
}

- (void)setState:(TTRecordState)state {
    _state = state;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(recordManager:onRecordState:)]) {
            [self.delegate recordManager:self onRecordState:state];
        }
    });
}

- (void)fetchErrorMessage:(NSString *)message {
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey : message}];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(recordManager:error:)]) {
            [self.delegate recordManager:self error:error];
        }
    });
}
@end
