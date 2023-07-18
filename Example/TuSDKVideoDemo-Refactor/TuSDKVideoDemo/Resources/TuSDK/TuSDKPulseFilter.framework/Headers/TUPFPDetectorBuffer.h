//
//  DetectorBufferCvt.h
//  TuSDKPulseFilter
//
//  Created by 刘鹏程 on 2023/6/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <CoreMedia/CMSampleBuffer.h>
#import <CoreVideo/CVPixelBuffer.h>

#import "TUPFPBuffer.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUPFPDetectorBuffer : NSObject

/**
 *  设置渲染尺寸
 *  @param outPutSize 渲染尺寸
 */
- (void)setOutputSize:(CGSize)outPutSize;
/**
 * convert 转换
 */
- (TUPFPDetectResult *)convert:(CMSampleBufferRef)sb;

- (TUPFPDetectResult *)convert:(CVPixelBufferRef)pb withTimestamp:(int64_t)ts;

- (TUPFPDetectResult *)convertWithUIImage:(UIImage *)image;

- (void)destory;

@end

NS_ASSUME_NONNULL_END
