//
//  TTAudioConvert.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTAudioConvert.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>

static int const kSampleCount = 1024;
static int const kBufferSize = kSampleCount * 1 * sizeof(int16_t);
static NSInteger const kPipePitchIndex = 100;
static NSInteger const kPipeSpeedIndex = 200;
//static NSInteger const kStretchProcessorIndex = 200;

typedef NS_ENUM(NSInteger, TTAudioMixerType) {
    TTAudioMixerTypeNone,
    TTAudioMixerTypeMusic, // 背景音乐
    TTAudioMixerTypeJoiner, // 合拍
};

@interface TTAudioConvert () {
    void *_queueData;
    void *_pipeData;
    void *_mixerData;
}
@property(nonatomic, weak) id<TTAudioConvertDelegate> delegate;
@property(nonatomic, strong) TUPDispatchQueue *queue;
@property(nonatomic, strong) TUPAudioPipe *pipe;
@property(nonatomic, assign) BOOL starting;

@property(nonatomic, assign) BOOL mixerEnable;
@property(nonatomic, strong) TUPFPAudioMixer *audioMixer;
@property(nonatomic, strong) TUPFPAudioMixer_Config *mixerConfig;
@property(nonatomic, strong) dispatch_queue_t mixerQueue;

@property(nonatomic, assign) BOOL pipeEnable;
@property(nonatomic, assign) TTVideoSoundPitchType pitchType;
@property(nonatomic, assign) TTVideoRecordSpeed speed;
@end

@implementation TTAudioConvert

- (instancetype)initWithDelegate:(id<TTAudioConvertDelegate>)delegate delegateQueue:(TUPDispatchQueue *)queue {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _queue = queue;
        _queueData = malloc(1024*8);
        _pipeData = malloc(1024*4);
        _mixerEnable = NO;
        _pipeEnable = NO;
        _starting = NO;
        _pitchType = TTVideoSoundPitchType_Normal;
        _speed = TTVideoRecordSpeed_NOMAL;
        
        [_queue runSync:^{
            self.pipe = [[TUPAudioPipe alloc] init];
            [self.pipe open:[TUPConfig new]];
        }];
    }
    return self;
}

- (void)sendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [_queue runSync:^{
//        CMAudioFormatDescriptionRef audioFormatDes = (CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer);
//        AudioStreamBasicDescription asbd = *(CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDes));
        CMBlockBufferRef blockBuffer;
        AudioBufferList audioBufferList;
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
        AudioBuffer audioBuffer = audioBufferList.mBuffers[0];
        CFRelease(blockBuffer);
        if (!self.starting) {
            [self didOutputPCMData:audioBuffer.mData len:audioBuffer.mDataByteSize];
        } else {
            // SDK 对每次传入的 PCM buffer 大小有严格要求，每一个采样点要求是16位宽。如果是单声道，传入的 PCM 长度为2048；如果是双声道，传入的 PCM 长度为4096。
            size_t nc = audioBuffer.mDataByteSize / 1 / sizeof(int16_t);
            if (self.sampleMuted) {
                memset(audioBuffer.mData, 0, audioBuffer.mDataByteSize);
            }
            [self.pipe enqueue:audioBuffer.mData andLength:nc];
            while ([self.pipe getSize] >= kSampleCount) {
                [self.pipe dequeue:self->_queueData andLength:kSampleCount];
                [self sendMixerPCMData:self->_queueData len:kBufferSize];
            }
        }
    }];
}

/// 向 混音 发送音频pcm
- (void)sendMixerPCMData:(void *)pcm len:(size_t)len {
    if (!self.mixerEnable) {
        [self reciveMixerPCMData:pcm len:len];
        return;
    }
    int ret = [self.audioMixer sendPrimaryAudio:pcm andLength:len];
    NSLog(@"TTAudioConvert sendMixer ret: %d", ret);
}

/// 接收混音后pcm
- (void)reciveMixerPCMData:(void *)pcm len:(size_t)len {
    [self sendPipePCMData:pcm len:len];
}

/// 向 pipe 发送pcm
- (void)sendPipePCMData:(void *)pcm len:(size_t)len {
    if (!self.pipeEnable) {
        [self didOutputPCMData:pcm len:len];
        return;
    }
    int ret = [self.pipe send:pcm andLength:len];
    NSLog(@"TTAudioConvert sendPipe ret: %d", ret);
    while (true) {
        int res = [self.pipe receive:self->_pipeData andLength:len];
        if (res < 0) {
            break;
        }
        [self didOutputPCMData:self->_pipeData len:len];
    }
}

/// 音频处理回调
- (void)didOutputPCMData:(void *)pcm len:(size_t)len {
    if ([self.delegate respondsToSelector:@selector(audioConvert:didOutputPCMData:len:)]) {
        [self.delegate audioConvert:self didOutputPCMData:pcm len:len];
    }
}

// MARK: - Pipe
- (void)setSoundPitchType:(TTVideoSoundPitchType)soundPitchType {
    if (self.pitchType == soundPitchType) {
        return;
    }
    self.pitchType = soundPitchType;
    if (soundPitchType == TTVideoSoundPitchType_Normal) {
        [self removePipeProcessor:kPipePitchIndex];
        if (self.speed == TTVideoRecordSpeed_NOMAL) {
            self.pipeEnable = NO;
        }
        return;
    }
    NSString *type = TUPAudioPitchProcessor_CONFIG_TYPE_Normal;
    switch (soundPitchType) {
        case TTVideoSoundPitchType_Monster:
            type = TUPAudioPitchProcessor_CONFIG_TYPE_Monster;
            break;
        case TTVideoSoundPitchType_Uncle:
            type = TUPAudioPitchProcessor_CONFIG_TYPE_Uncle;
            break;
        case TTVideoSoundPitchType_Girl:
            type = TUPAudioPitchProcessor_CONFIG_TYPE_Girl;
            break;
        case TTVideoSoundPitchType_Lolita:
            type = TUPAudioPitchProcessor_CONFIG_TYPE_Lolita;
            break;
        default:
            break;
    }
    self.pipeEnable = YES;
    TUPConfig *config = [[TUPConfig alloc] init];
    [config setString:type forKey:TUPAudioPitchProcessor_CONFIG_TYPE];
    [self addPipeProcessor:config index:kPipePitchIndex];
}

- (void)setAudioSpeed:(TTVideoRecordSpeed)audioSpeed {
    if (self.speed == audioSpeed) {
        return;
    }
    self.speed = audioSpeed;
    if (audioSpeed == TTVideoRecordSpeed_NOMAL) {
        [self removePipeProcessor:kPipeSpeedIndex];
        if (self.pitchType == TTVideoSoundPitchType_Normal) {
            self.pipeEnable = NO;
        }
        return;
    }
    self.pipeEnable = YES;
    CGFloat speedValue = TTVideoRecordSpeedValue(audioSpeed);
    TUPConfig *config = [[TUPConfig alloc] init];
    [config setDoubleNumber:speedValue forKey:TUPAudioStretchProcessor_CONFIG_STRETCH];
    [self addPipeProcessor:config index:kPipeSpeedIndex];
}

- (void)addPipeProcessor:(TUPConfig *)config index:(NSInteger)index {
    [self.queue runSync:^{
        if ([self.pipe getProcessor:index]) {
            [self.pipe deleteProcessorAt:index];
        }
        TUPAudioProcessor *processor = [[TUPAudioProcessor alloc] init:[self.pipe getContext] withName:TUPAudioPitchProcessor_TYPE_NAME];
        [processor setConfig:config];
        [self.pipe add:processor atIndex:index];
    }];
}

- (void)removePipeProcessor:(NSInteger)index {
    [self.queue runSync:^{
        if ([self.pipe getProcessor:index]) {
            [self.pipe deleteProcessorAt:index];
        }
    }];
}

// MARK: - Mixer
- (void)setBGM:(NSString *)path {
    _mixerData = malloc(4096);
    _mixerConfig = [[TUPFPAudioMixer_Config alloc] init];
    _mixerConfig.fileMixWeight = 0.3;
    _mixerConfig.path = path;
    _mixerConfig.repeatDuration = 15000;
    if (!_mixerQueue) {
        _mixerQueue = dispatch_queue_create("TTAudioConvert.audioMixerQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    if (_audioMixer) {
        [_audioMixer close];
    }
    _audioMixer = [[TUPFPAudioMixer alloc] init];
}

- (void)startMixerFromTime:(NSInteger)startTime {
    self.starting = YES;
    if (!self.mixerConfig.path) {// 未设置混音
        return;
    }
    [self setBGM:self.mixerConfig.path];
    self.mixerConfig.startPos = startTime;
    [self.audioMixer open:self.mixerConfig];
    
    self.mixerEnable = true;
    dispatch_async(_mixerQueue, ^{
        while (1) {
            if (!self.mixerEnable) {
                break;
            }
            int ret = [self.audioMixer getPCMForRecord:self->_mixerData andLength:2048];
            NSLog(@"TTAudioConvert mixer get ret: %d", ret);
            if (ret > 0) {
                [self reciveMixerPCMData:self->_mixerData len:2048];
            } else if (ret < 0) {
                break;
            }
        };
    });
}

- (void)sendAudioPlayBufferList:(AudioBufferList)bufferList {
    if (self.mixerEnable) { // 播放背景音乐
        AudioBuffer buffer = bufferList.mBuffers[0];
        [self.audioMixer getPCMForPlay:buffer.mData andLength:buffer.mDataByteSize];
    }
}

- (void)pause {
    self.starting = NO;
    self.mixerEnable = false;
}

- (void)stopBGM {
    self.mixerEnable = false;
    _mixerConfig = nil;
    [_audioMixer close];
    _audioMixer = nil;
}

- (void)destory {
    free(_pipeData);
    free(_mixerData);
    free(_queueData);
    [_queue runSync:^{
        [self.pipe close];
    }];
    _pipe = nil;
}
@end
