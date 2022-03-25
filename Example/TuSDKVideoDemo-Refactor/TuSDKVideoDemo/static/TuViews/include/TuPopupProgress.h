//
//  TuPopupProgress.h
//  TuSDK
//
//  Copyright 2011-2014 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//
//  修改：SVProgressHUD 修改为 TuPopupProgress
//       SVProgressHUD.bundle 修改为 TuSDKUI.bundle/style_default_hud_*
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

extern NSString * const TTProgressHUDDidReceiveTouchEventNotification;
extern NSString * const TTProgressHUDDidTouchDownInsideNotification;
extern NSString * const TTProgressHUDWillDisappearNotification;
extern NSString * const TTProgressHUDDidDisappearNotification;
extern NSString * const TTProgressHUDWillAppearNotification;
extern NSString * const TTProgressHUDDidAppearNotification;

extern NSString * const TTProgressHUDStatusUserInfoKey;

typedef NS_ENUM(NSUInteger, TTProgressHUDMaskType) {
    TTProgressHUDMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    TTProgressHUDMaskTypeClear,     // don't allow user interactions
    TTProgressHUDMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD
    TTProgressHUDMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la-alert-view background gradient
};

@interface TuPopupProgress : UIView

#pragma mark - Customization

+ (void)setBackgroundColor:(UIColor*)color;                 // default is [UIColor whiteColor]
+ (void)setForegroundColor:(UIColor*)color;                 // default is [UIColor blackColor]
+ (void)setRingThickness:(CGFloat)width;                    // default is 4 pt
+ (void)setFont:(UIFont*)font;                              // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setSuccessImage:(UIImage*)image;                    // default is the bundled success image provided by Freepik
+ (void)setErrorImage:(UIImage*)image;                      // default is the bundled error image provided by Freepik
+ (void)setDefaultMaskType:(TTProgressHUDMaskType)maskType; // default is TuSDKProgressHUDMaskTypeNone

#pragma mark - Show Methods

+ (void)show;
+ (void)showWithMaskType:(TTProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(TTProgressHUDMaskType)maskType;

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress maskType:(TTProgressHUDMaskType)maskType;
+ (void)showProgress:(float)progress status:(NSString*)status;
+ (void)showProgress:(float)progress status:(NSString*)status maskType:(TTProgressHUDMaskType)maskType;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses HUD a little bit later
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showSuccessWithStatus:(NSString*)string maskType:(TTProgressHUDMaskType)maskType;

+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string maskType:(TTProgressHUDMaskType)maskType;

// use 28x28 white pngs
+ (void)showImage:(UIImage*)image status:(NSString*)status;
+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(TTProgressHUDMaskType)maskType;

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; // decrease activity count, if activity count == 0 the HUD is dismissed
+ (void)dismiss;

+ (BOOL)isVisible;

@end

/**
 *  TuSDK 扩展
 */
@interface TuPopupProgress(TuSDKExtend)
/**
 *  在主线程中显示信息
 *
 *  @param status 信息
 */
+ (void)showMainThreadWithStatus:(NSString*)status;

/**
 *  在主线程中显示信息
 *
 *  @param message 信息
 */
+ (void)showMainThreadWithMessage:(NSString*)message;

/**
 *  在主线程中显示进度和信息
 *
 *  @param progress
 *             进度
 *  @param status
 *             信息
 */
+ (void)showMainThreadProgress:(float)progress withStatus:(NSString *)status;

/**
 *  在主线程中显示成功信息
 *
 *  @param string 信息
 */
+ (void)showMainThreadSuccessWithStatus:(NSString*)string;

/**
 *  在主线程中显示错误信息
 *
 *  @param string 信息
 */
+ (void)showMainThreadErrorWithStatus:(NSString *)string;
@end
