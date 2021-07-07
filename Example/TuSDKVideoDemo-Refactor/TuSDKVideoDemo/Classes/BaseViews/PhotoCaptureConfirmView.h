/********************************************************
 * @file    : PhotoCaptureConfirmView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 相机拍照结果展示页
*********************************************************/

#import <UIKit/UIKit.h>

/**
 拍照结果确认视图
 */
@interface PhotoCaptureConfirmView : UIView

@property (nonatomic, strong, readonly) UIView *backgroundView; // 背景容器视图

@property (nonatomic, strong, readonly) UIImageView *photoView; // 拍照结果展示视图

@property (nonatomic, strong, readonly) UIButton *backButton; // 返回按钮

@property (nonatomic, strong, readonly) UIButton *doneButton; // 确认按钮

@property (nonatomic, assign) CGFloat photoRatio; // 图片宽高比

/**
 * 视图显示状态
 */
- (void)show;

/**
 * 完成后回调操作
 * @param completion 完成后的操作
 */
- (void)hideWithCompletion:(void (^)(void))completion;

@end
