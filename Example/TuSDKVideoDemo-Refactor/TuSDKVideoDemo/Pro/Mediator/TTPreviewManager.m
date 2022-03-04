//
//  TTPreviewManager.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/20.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTPreviewManager.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>
#import <TuSDKPulseCore/TuSDKPulseCore.h>
@interface TTPreviewManager ()
/// 画布
@property(nonatomic, strong) TUPFPDisplayView *previewView;
/// 预览frame 归一化 取值范围 0~1
@property(nonatomic, assign) CGRect previewRect;
/// 设置输出frame 归一化 取值范围 0~1
@property(nonatomic, assign) CGRect outputRect;
/// 画面比例
@property(nonatomic, assign) TTVideoAspectRatio ratio;
@property(nonatomic, strong) TUPFPImage *outImage;
/// 分辨率
@property(nonatomic, assign) CGSize outputResolution;
@end

@implementation TTPreviewManager
- (instancetype)initWithContainer:(UIView *)containerView {
    self = [super init];
    if (self) {
        _previewView = [[TUPFPDisplayView alloc] init];
        _previewView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        [_previewView setClearColor:UIColor.blackColor];
        [containerView addSubview:_previewView];
        [_previewView setup];
        
        _previewRect = CGRectMake(0, 0, 1, 1);
        _outputRect = CGRectMake(0, 0, 1, 1);
        _ratio = TTVideoAspectRatio_Default;
        _outputResolution = CGSizeMake(1080, 1920);
    }
    return self;
}

- (CGRect)setAspectRatio:(enum TTVideoAspectRatio)aspectRatio {
        
    if (_ratio == aspectRatio) {
        return self.outputRect;
    }
    
    _ratio = aspectRatio;
    CGSize canvasSize = _previewView.frame.size;
    CGFloat canvasRatio = canvasSize.width / canvasSize.height;
    CGFloat ratio;
    switch (aspectRatio) {
        case TTVideoAspectRatio_1_1:
            ratio = 1;
            break;
        case TTVideoAspectRatio_3_4:
            ratio = 3.0 / 4;
            break;
        case TTVideoAspectRatio_4_3:
            ratio = 4.0 / 3;
            break;
        case TTVideoAspectRatio_16_9:
            ratio = 16.0 / 9;
            break;
        case TTVideoAspectRatio_9_16:
            ratio = 9.0 / 16;
            break;
        case TTVideoAspectRatio_2_3:
            ratio = 2.0 / 3;
            break;
        case TTVideoAspectRatio_3_2:
            ratio = 3.0 / 2;
            break;
        default:
            ratio = canvasRatio;
            break;
    }
    CGFloat cameraRatio = _outputResolution.width / _outputResolution.height;
    if (cameraRatio > ratio) {
        CGFloat width = _outputResolution.height * ratio / _outputResolution.width;
        self.previewRect = CGRectMake(0, 0, 1, 1);
        self.outputRect = CGRectMake((1 - width) / 2, 0, width, 1);

    } else {
        CGFloat height = canvasSize.width / ratio / canvasSize.height;
        self.previewRect = CGRectMake(0, (1-height)/2, 1, height);
        self.outputRect = CGRectMake(CGRectGetMinX(self.outputRect), (1-height)/2, CGRectGetWidth(self.outputRect), height);
        NSLog(@"TTPreviewManager normalization rect: %@", NSStringFromCGRect(self.previewRect));
    }
    return self.outputRect;
}

/// 设置分辨率，默认1080P
- (void)setOutputResolution:(CGSize)outPutResolution;
{
    _outputResolution = outPutResolution;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [_previewView setClearColor:backgroundColor];
}

- (void)update:(TUPFPImage *)fpImage {
    _outImage = fpImage;
    [self.previewView update:fpImage atRect:self.previewRect];
}

- (UIImage *)snapshot {
    UIImage *ret = [self.outImage getUIImage];
    UIImage *outPutImage = [self drawWaterMarkToCaptureImage:ret];
    return outPutImage;
}

- (UIImage *)drawWaterMarkToCaptureImage:(UIImage *)captureImage {
    CGFloat safeBottom = 0;
    if ([UIDevice lsqIsDeviceiPhoneX])
    {
        safeBottom = 44;
    }
    UIGraphicsBeginImageContext(captureImage.size);
    [captureImage drawInRect:CGRectMake(0, 0, captureImage.size.width, captureImage.size.height)];
    
    UIImage *waterMarkImage = [UIImage imageNamed:@"sample_watermark"];
    [waterMarkImage drawInRect:CGRectMake(captureImage.size.width - 220, safeBottom + 20, 200, 88)];
    
    UIImage *outPutImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     
    return outPutImage;
}

- (void)destory {
    [self.previewView teardown];
    _outImage = nil;
    _previewView = nil;
}
@end
