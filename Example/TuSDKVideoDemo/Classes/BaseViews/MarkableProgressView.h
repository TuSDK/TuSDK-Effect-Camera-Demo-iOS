/********************************************************
 * @file    : MarkableProgressView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 录制进度视图
*********************************************************/

#import <UIKit/UIKit.h>

/**
 可标记进度视图
 */
@interface MarkableProgressView : UIProgressView

/**
 设置录制占位视图
 
 @param progress 进度
 */
- (CALayer *)addPlaceholder:(CGFloat)progress markWidth:(CGFloat)markWidth;

/**
 移除最后一个标记
 */
- (void)pushMark;

/**
 压入一个标记
 */
- (void)popMark;

/**
 重置
 */
- (void)reset;

@end
