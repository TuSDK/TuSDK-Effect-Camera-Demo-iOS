/********************************************************
 * @file    : TopNavigationBar.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 自定义导航栏
*********************************************************/

#import <UIKit/UIKit.h>

/**
 * 自定义顶部导航栏
 */
@interface TopNavigationBar : UIView

@property (nonatomic, strong, readonly) UIButton *backButton; // 返回按钮

@property (nonatomic, strong, readonly) UIButton *rightButton; // 右侧按钮

@end
