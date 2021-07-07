/********************************************************
 * @file    : TextPageControl.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 文字切换控件
*********************************************************/

#import <UIKit/UIKit.h>

// 动画时长
static const NSTimeInterval kAnimationDuration = 0.25;

/**
 * 页面切换控件
 */
@interface TextPageControl : UIControl

@property (nonatomic, strong) NSArray *titles; // 标题数组

@property (nonatomic, strong) UIFont *titleFont; // 标题字体

@property (nonatomic, strong) UIColor *normalColor; // 常态颜色

@property (nonatomic, strong) UIColor *selectedColor; // 选中颜色

@property (nonatomic, assign) CGFloat titleSpacing; // 标题间隔

@property (nonatomic, assign) NSInteger selectedIndex; // 选中索引

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
@end
