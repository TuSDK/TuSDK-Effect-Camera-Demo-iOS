/********************************************************
 * @file    : DemoAppearance.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 样式工具类
*********************************************************/

#import "DemoAppearance.h"

@implementation DemoAppearance

/**
 配置默认阴影

 @param shadowSize 阴影大小
 @param layer 配置的图层
 */
+ (void)setShadowSize:(CGFloat)shadowSize onLayer:(CALayer *)layer {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = ABS(shadowSize);
    layer.shadowOpacity = 0.6;
}

+ (void)setupDefaultShadowOnLayer:(CALayer *)layer {
    [self setShadowSize:1.0 onLayer:layer];
}

+ (void)setupDefaultShadowOnViews:(NSArray<UIView *> *)views {
    for (UIView *view in views) {
        [self setShadowSize:1.0 onLayer:view.layer];
    }
}

@end
