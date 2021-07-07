//
//  TTAudioQueuePlayer.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/6/18.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol TTAudioQueuePlayerDelegate <NSObject>

- (int)audio_callback:(AudioQueueRef)queue buffer:(AudioQueueBufferRef)buffer;

@end

@interface TTAudioQueuePlayer : NSObject
@property (nonatomic, weak) id<TTAudioQueuePlayerDelegate> delegate;
@property (nonatomic, assign) int sampleRate; // default is 44100
@property (nonatomic, assign) int channels; // default is 1
@property (nonatomic, assign) int sampleCount; // default is 1024

- (int)open;
- (int)close;
- (int)play;
- (int)pause;

- (int)readPCMAndPlay:(AudioQueueRef)ref buffer:(AudioQueueBufferRef)buffer;
@end

NS_ASSUME_NONNULL_END
