//
//  TUPFPBuffer.h
//  TuSDKPulseFilter
//
//  Created by 刘鹏程 on 2023/7/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CVPixelBuffer.h>

@class TUPFPDetectResult;

NS_ASSUME_NONNULL_BEGIN

@interface TUPFPBuffer : NSObject
{
    @package
    void *_pimpl;
}

//初始化
- (instancetype)initWithImpl:(void *)impl;

//销毁
- (void)destory;

@end


@interface TUPFPDetector : NSObject

- (instancetype)initWithType:(NSInteger)type;

- (TUPFPDetectResult *)do_detect:(TUPFPBuffer *)buffer;

//销毁
- (void)destory;

@end

NS_ASSUME_NONNULL_END
