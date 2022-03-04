//
//  TTCameraView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/4.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRenderDef.h"

#import "RecordButton.h"
#import "CameraMoreMenuView.h"
#import "MarkableProgressView.h"
#import "SpeedSegmentView.h"
#import "TuVideoFocusTouchView.h"
NS_ASSUME_NONNULL_BEGIN

/// 方法类型
typedef NS_ENUM(NSUInteger, TTMethodStyle) {
    /// 显示合拍
    TTMethodShowJoiner,
    /// 移除合拍
    TTMethodRemoveJoiner,
    /// 移除最后一个片段
    TTMethodRemoveLastRecordPart,
    /// 切换摄像头
    TTMethodRotateCamera,
};

@protocol TTBeautyProtocol;

@class TTCameraView;

@protocol TTCameraViewListener <NSObject>

@optional
/**
 * 设置曝光强度
 * @param cameraView 相机视图
 * @param value 曝光强度数值
 */
- (void)cameraView:(TTCameraView *)cameraView setExposureBiasValue:(CGFloat)value;

/**
 * 设置自动聚焦
 * @param cameraView 相机视图
 * @param autoFocus 是否自动聚焦
 */
- (void)cameraView:(TTCameraView *)cameraView setAutoFocus:(BOOL)autoFocus;
/**
 * 设置音频混音类型
 * @param cameraView 相机视图
 * @param music 音乐名称
 */
- (void)cameraView:(TTCameraView *)cameraView setMusicName:(NSString*)music;

/**
 * 设置画面比例
 * @param cameraView 相机视图
 * @param aspectRatio 画面比例
 */
- (void)cameraView:(TTCameraView *)cameraView setAspectRatio:(TTVideoAspectRatio)aspectRatio;

/**
 * 根据事件类型实现相应的方法
 * @param cameraView 相机视图
 * @param methodStyle 事件类型
 */
- (void)cameraView:(TTCameraView *)cameraView method:(TTMethodStyle)methodStyle;

@end

@interface TTCameraView : UIView

@property (nonatomic, weak) id<TTCameraViewListener> delegate;
/// 是否为前置摄像头
@property (nonatomic, assign) BOOL isFrontDevicePosition;
/// 最大录制时长
@property (nonatomic, assign) NSInteger maxRecordTime;
/// 最小录制时长
@property (nonatomic, assign) NSInteger minRecordTime;


/// 录制按钮
@property (nonatomic, strong) RecordButton *captureButton;
/// 选择音乐
@property (nonatomic, strong) UIButton *musicButton;
/// 合拍编辑按钮
@property (nonatomic, readonly) UIButton *joinerEditButton;
/// 完成按钮
@property (nonatomic, readonly) UIButton *doneButton;


/// 录制速率控制页面
@property (nonatomic, readonly) SpeedSegmentView *speedSegmentView;
/// 录制进度
@property (nonatomic, strong) MarkableProgressView *markableProgressView;
/// 更多页面
@property (nonatomic, strong) CameraMoreMenuView *moreMenuView;
/// 聚焦视图
@property (nonatomic, strong) TuVideoFocusTouchView *focusTouchView;



- (instancetype)initWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;


/**
 * 设置录制按钮的委托对象
 * @param delegate RecordButtonDelegate
 */
- (void)setRecordButtonDelegate:(id<RecordButtonDelegate>)delegate;

/**
 * 设置更多页面的委托对象
 * @param delegate CameraMoreMenuViewDelegate
 */
- (void)setMoreMenuViewDelegate:(id<CameraMoreMenuViewDelegate>)delegate;

/**
 * 当前录制进度更新
 * @param progress 录制进度
 */
- (void)recordProgressChanged:(CGFloat)progress;
/**
 * 当前录制状态更新
 * @param recordState 录制状态
 */
- (void)recordStateChanged:(TTRecordState)recordState;

/**
 * 设置比例
 * @param ratioType 比例
 */
- (void)setRatioByType:(TTVideoAspectRatio)ratioType;

/// 正在录制时隐藏控件
- (void)hideViewsWhenRecording;

/// 录制结束/暂停时显示控件
- (void)showViewsWhenPauseRecording;

/// 录制失败相关信息
- (void)recordFailedWithError:(NSError *)error;

/// 更新UI状态
- (void)updateRecordViewsDisplay;

/// 更新合拍布局
- (void)refreshJoinerRect:(CGRect)rect;

/// 取消合拍时更新录制按钮状态
- (void)cancelJoinerUpdateRecordState;

/// 更新合拍时按钮状态
- (void)moreJoinerDisable:(BOOL)isDisable;

/// 重置页面，恢复前台时使用
- (void)resetCameraView;

/// 销毁
- (void)destoryView;

@end

NS_ASSUME_NONNULL_END
