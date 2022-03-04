//
//  TTPreviewManager.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/20.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"
NS_ASSUME_NONNULL_BEGIN

@class TUPFPImage;

@interface TTPreviewManager : NSObject
TT_INIT_UNAVAILABLE;
/**
 * 初始化预览画布
 * @param containerView 容器视图
 */
- (instancetype)initWithContainer:(UIView *)containerView NS_DESIGNATED_INITIALIZER;

/**
 * 更新预览画面
 * @param fpImage 图像显示
 */
- (void)update:(TUPFPImage *)fpImage;

/**
 * 设置画面比例
 * @param aspectRatio full 3:4 1:1
 */
- (CGRect)setAspectRatio:(TTVideoAspectRatio)aspectRatio;

/// 设置分辨率，默认1080P
- (void)setOutputResolution:(CGSize)outPutResolution;

/**
 * 设置画面背景颜色
 * @param backgroundColor 背景颜色
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor;

/// 拍照/截图
- (UIImage *)snapshot;

/// 销毁
- (void)destory;
@end

NS_ASSUME_NONNULL_END
