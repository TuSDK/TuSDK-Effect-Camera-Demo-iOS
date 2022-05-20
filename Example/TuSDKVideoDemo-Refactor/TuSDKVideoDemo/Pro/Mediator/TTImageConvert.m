//
//  TTImageConvert.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTImageConvert.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>
#import "TTRenderDef.h"

@interface TTImageConvert ()
/// 视频样本转换
@property(nonatomic, strong) TUPFPImage_CMSampleBufferCvt *bufferConvert;
/// 像素格式
@property(nonatomic, assign) TTVideoPixelFormat pixelFormat;
/// 分辨率
@property(nonatomic, assign) CGSize outputResolution;
@end

@implementation TTImageConvert
- (instancetype)init {
    self = [super init];
    if (self) {
        self.bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] initWithPixelFormatType_32BGRA];
        _pixelFormat = TTVideoPixelFormat_YUV;
        _outputResolution = CGSizeMake(1080, 1920);
    }
    return self;
}

- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat {
    if (_pixelFormat == pixelFormat) {
        return;
    }
    _pixelFormat = pixelFormat;
    if (pixelFormat == TTVideoPixelFormat_YUV) {
        _bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] init];
    } else {
        _bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] initWithPixelFormatType_32BGRA];
    }
}

- (void)setOutputSize:(CGSize)outputSize {
    CGSize size = CGSizeMake(self.outputResolution.width * outputSize.width, self.outputResolution.height * outputSize.height);
    [self.bufferConvert setOutputSize:size];
    NSLog(@"TTImageConvert ouputSize: %@", NSStringFromCGSize(size));
}

- (void)setOutputResolution:(CGSize)outputResolution;
{
    _outputResolution = outputResolution;
}

- (TUPFPImage *)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    self.outputResolution = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    
    return [self.bufferConvert convert:sampleBuffer];
}

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    // 如果没有timestamp，则可以直接使用当前的系统时间
    int64_t timestamp = (int64_t)([[NSDate date]timeIntervalSince1970] * 1000);
    return [self.bufferConvert convert:pixelBuffer withTimestamp:timestamp];
}

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp;
{
    return [self.bufferConvert convert:pixelBuffer withTimestamp:timestamp];
}

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp rotation:(int)rotation flip:(BOOL)flip mirror:(BOOL)mirror {
    return [self.bufferConvert convert:pixelBuffer withTimestamp:timestamp orientaion:rotation flip:flip mirror:mirror];
}

- (TUPFPImage *)flip:(TUPFPImage *)fpImage {
    return [self.bufferConvert convertImage:fpImage];
}

- (void)destory {
    _bufferConvert = nil;
}
@end
