/********************************************************
 * @file    : CameraMoreMenuView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 相机更多功能视图
*********************************************************/

#import "VerticalMenuView.h"
#import "TTRenderDef.h"
@class CameraMoreMenuView;
@protocol CameraMoreMenuViewDelegate <NSObject>
@optional

/**
 更多菜单切换预览画面比率回调
 
 @param moreMenu 更多菜单视图
 @param ratio 相机视图比例
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSelectedRatio:(CGFloat)ratio;

/**
 更多菜单切换自动聚焦回调

 @param moreMenu 更多菜单视图
 @param autoFocus 自动聚焦
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchAutoFocus:(BOOL)autoFocus;

/**
 更多菜单切换闪光灯回调

 @param moreMenu 更多菜单视图
 @param enableFlash 闪光灯开启状态
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchFlashMode:(BOOL)enableFlash;

/**
 更多菜单切换变声回调

 @param moreMenu 更多菜单视图
 @param pitchType 变声类型
 */
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchPitchType:(TTVideoSoundPitchType)pitchType;

- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchJoinerMode:(TTJoinerDirection)joinerDirection;

- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchMicrophoneMode:(BOOL)enableMic;

@end

@interface CameraMoreMenuView : VerticalMenuView

@property (nonatomic, weak) id<CameraMoreMenuViewDelegate> delegate; //相机折叠功能菜单代理

@property (nonatomic, assign) BOOL autoFocus; // 自动对焦开关

@property (nonatomic, assign) BOOL disableFlashSwitching; // 是否禁用闪光开关

@property (nonatomic, assign) BOOL enableFlash; // 闪光灯开关

@property (nonatomic, assign) BOOL ratioHidden; // 比例开关
@property (nonatomic, assign) BOOL disableRatioSwitching; // 是否禁用比例切换

@property (nonatomic, assign) BOOL pitchHidden; // 是否隐藏变声开关

@property (nonatomic, assign) BOOL joinerHidden; // 是否隐藏合拍布局开关
@property (nonatomic, assign) BOOL disableJoiner;
@property (nonatomic, assign) TTJoinerDirection currentJoinerDirection;

@property (nonatomic, assign) BOOL disableMicrophone; // 是否禁用麦克风
@property (nonatomic, assign) BOOL microphoneHidden; 

@end
