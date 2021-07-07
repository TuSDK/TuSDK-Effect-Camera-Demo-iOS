//
//  TTAudioQueuePlayer.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/6/18.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTAudioQueuePlayer.h"
typedef short SAMPLE_TYPE;

#define BUFFER_COUNT 2
static void ttAudio_callback(void* user_data, AudioQueueRef queue, AudioQueueBufferRef buffer) {
    TTAudioQueuePlayer *aqPlay = (__bridge TTAudioQueuePlayer *)user_data;
    int ret = [aqPlay readPCMAndPlay:queue buffer:buffer];
    if (ret < 0) {
        memset(buffer->mAudioData, 0, aqPlay.channels * aqPlay.sampleCount * sizeof(SAMPLE_TYPE));
    }
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}
@interface TTAudioQueuePlayer () {
    AudioQueueRef aqueue;
}
@property (nonatomic, strong) NSLock *synlock;
@end

@implementation TTAudioQueuePlayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sampleRate = 44100;
        _channels = 1;
        _sampleCount = 1024;
        
    }
    return self;
}
- (int)open {
    AudioStreamBasicDescription format;
    AudioQueueBufferRef buffers[BUFFER_COUNT];
    
    format.mSampleRate       = _sampleRate;
    format.mFormatID         = kAudioFormatLinearPCM;
    format.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    format.mBitsPerChannel   = 8 * sizeof(SAMPLE_TYPE);
    format.mChannelsPerFrame = _channels;
    format.mBytesPerFrame    = sizeof(SAMPLE_TYPE) * _channels;
    format.mFramesPerPacket  = 1;
    format.mBytesPerPacket   = format.mBytesPerFrame * format.mFramesPerPacket;
    format.mReserved         = 0;
    
    //frame_size_ = channels_ * sample_count_ * sizeof(SAMPLE_TYPE);
    
    
//    AVAudioSession *asession = [AVAudioSession sharedInstance];
//    [asession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [asession setActive:YES error:nil];
    
    OSStatus res = AudioQueueNewOutput(&format, ttAudio_callback, (__bridge void * _Nullable)(self), NULL, kCFRunLoopCommonModes, 0, &aqueue);
    if (res != noErr) {
        //LOG_ERROR("AudioQueueNewOutput() failure", res);
        return -2;
    }
    
    int frame_size = _channels * _sampleCount * sizeof(SAMPLE_TYPE);
    for (int i = 0; i < BUFFER_COUNT; i++)
    {
        AudioQueueAllocateBuffer(aqueue, frame_size, &buffers[i]);
        buffers[i]->mAudioDataByteSize = frame_size;
        
        SAMPLE_TYPE *casted_buffer = (SAMPLE_TYPE *)buffers[i]->mAudioData;
        memset(casted_buffer, 0, frame_size);
        AudioQueueEnqueueBuffer(aqueue, buffers[i], 0, NULL);
        //callback(NULL, queue, buffers[i]);
    }
    _synlock = [[NSLock alloc] init];
    return (int)res;
}

- (int)close {
    OSStatus res = AudioQueueStop(aqueue, true);
    res = AudioQueueDispose(aqueue, true);
    return (int)res;
}
- (int)play {
    OSStatus res = AudioQueueStart(aqueue, NULL);
    return (int)res;
}
- (int)pause {
    OSStatus res = AudioQueuePause(aqueue);
    return (int)res;
}
- (int)readPCMAndPlay:(AudioQueueRef)ref buffer:(AudioQueueBufferRef)buffer {
    if ([self.delegate respondsToSelector:@selector(audio_callback:buffer:)]) {
        return [self.delegate audio_callback:ref buffer:buffer];
    }
    return -11111;
}
@end
