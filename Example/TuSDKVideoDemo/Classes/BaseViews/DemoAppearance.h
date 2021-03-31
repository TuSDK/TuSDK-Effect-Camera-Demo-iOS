/********************************************************
 * @file    : DemoAppearance.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 样式工具类
*********************************************************/


#import <UIKit/UIKit.h>

/**
 样式工具类
 */
@interface DemoAppearance : NSObject

/**
 配置默认阴影

 @param layer 配置层级视图
 */
+ (void)setupDefaultShadowOnLayer:(CALayer *)layer;

/**
 配置一组视图默认阴影

 @param views 一组视图
 */
+ (void)setupDefaultShadowOnViews:(NSArray<UIView *> *)views;

@end
