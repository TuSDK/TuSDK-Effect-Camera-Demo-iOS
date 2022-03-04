//
//  TTCameraView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/4.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTCameraView.h"
#import "TTBeautyProxy.h"
#import "TTFilterPanelView.h"
#import "TTBeautyPanelView.h"
#import "TTStickerPanelView.h"


#import "TextPageControl.h"


#import "TextPageControl.h"


#import <TuSDKPulseCore/TuSDKPulseCore.h>

@interface TTCameraView()<TuFocusTouchViewDelegate,
                            TTFilterPanelViewDelegate,
                            TTBeautyPanelViewDelegate,
                            TTStickerPanelViewDelegate,
                            UIGestureRecognizerDelegate>
{
    
    //曝光相关组件
    UISlider *_exposureSlider;
    UIImageView *_lightImageView;
    //上一次曝光数值
    CGFloat _lastExposureValue;
    
    UIStackView *_headerToolsBar; /**顶部工具栏*/
    UIStackView *_filterToolsBar; /**滤镜工具栏*/
    /**录制模式切换控件*/
    TextPageControl *_captureModeView;
    
    UILabel *_filterNameLabel;     // 滤镜名称
    
    UIButton *_switchCameraButton; // 切换摄像头
    UIButton *_beautyButton;       // 美颜按钮
    UIButton *_speedButton;        // 录制速率页显示按钮
    UIButton *_moreButton;         // 更多按钮
    
    UIButton *_stickerButton;      // 贴纸按钮
    UIButton *_filterButton;       // 滤镜按钮
    
    UIButton *_undoButton;         // 回删按钮
    
    
    //滤镜视图
    TTFilterPanelView *_filterPanelView;
    //美颜视图
    TTBeautyPanelView *_beautyPanelView;
    
    
    TTStickerPanelView *_stickerPanelView;
    
    //拍照图片
    UIImage *_capturedPhoto;
    //能否滑动
    BOOL _canSwipeFilter;
}

@property (nonatomic, weak) UIView *currentBottomPanelView; // 当前的底部面板
@property (nonatomic, weak) UIView *currentTopPanelView; // 当前的顶部面板
@property(nonatomic, strong) id<TTBeautyProtocol> beautyTarget;
/// 比例
@property(nonatomic, assign) TTVideoAspectRatio ratioType;

@end

@implementation TTCameraView


- (instancetype)initWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    if (self = [super initWithFrame:frame]) {
        
        _beautyTarget = beautyTarget;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    //默认可以加载滑动手势
    _canSwipeFilter = YES;
//    _ratioType = TTVideoAspectRatio_9_16;
    
    _focusTouchView = [[TuVideoFocusTouchView alloc] initWithFrame:self.bounds];
    _focusTouchView.delegate = self;
    [self addSubview:_focusTouchView];
    
    //曝光相关组件
    _lightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _lightImageView.image = [UIImage imageNamed:@"ic_light"];
    [self addSubview:_lightImageView];
    
    _exposureSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    _exposureSlider.transform = CGAffineTransformMakeRotation(-M_PI/2);
    _exposureSlider.maximumValue = 0.8;
    _exposureSlider.minimumValue = 0.4;
    _exposureSlider.value = 0.6;
    _exposureSlider.minimumTrackTintColor = [UIColor whiteColor];
    _exposureSlider.maximumTrackTintColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.3];
    [_exposureSlider setThumbImage:[UIImage imageNamed:@"slider_thum_icon"] forState:UIControlStateNormal];
    [_exposureSlider addTarget:self action:@selector(exposureSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_exposureSlider];
    
    // 滤镜标题
    _filterNameLabel = [[UILabel alloc] init];
    _filterNameLabel.font = [UIFont systemFontOfSize:20];
    _filterNameLabel.text = @"滤镜标题";
    _filterNameLabel.textColor = UIColor.whiteColor;
    _filterNameLabel.textAlignment = NSTextAlignmentCenter;
    _filterNameLabel.alpha = 0;
    _filterNameLabel.layer.shadowOpacity = 0.6;
    _filterNameLabel.layer.shadowOffset = CGSizeZero;
    _filterNameLabel.layer.shadowRadius = 1;
    [self addSubview:_filterNameLabel];
    
    // 设置默认曝光强度
    _lastExposureValue = _exposureSlider.value;
    
    //录制进度条
    _markableProgressView = [[MarkableProgressView alloc] init];
    [self addSubview:_markableProgressView];
    
    //顶部工具栏
    _headerToolsBar = [[UIStackView alloc] init];
    _headerToolsBar.axis = UILayoutConstraintAxisHorizontal;
    _headerToolsBar.distribution = UIStackViewDistributionFillEqually;
    _headerToolsBar.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_headerToolsBar];
    
    //滤镜工具栏
    _filterToolsBar = [[UIStackView alloc] init];
    _filterToolsBar.axis = UILayoutConstraintAxisHorizontal;
    _filterToolsBar.distribution = UIStackViewDistributionFillEqually;
    _filterToolsBar.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_filterToolsBar];
    
    //切换摄像头按钮
    _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchCameraButton setImage:[UIImage imageNamed:@"video_nav_ic_turn"] forState:UIControlStateNormal];
    [_switchCameraButton addTarget:self action:@selector(switchCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headerToolsBar addArrangedSubview:_switchCameraButton];
    
    //美颜按钮
    _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_beautyButton setImage:[UIImage imageNamed:@"video_nav_ic_beauty"] forState:UIControlStateNormal];
    [_beautyButton setImage:[UIImage imageNamed:@"video_nav_ic_beauty_selected"] forState:UIControlStateSelected];
    [_beautyButton addTarget:self action:@selector(beautyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headerToolsBar addArrangedSubview:_beautyButton];
    
    //切换速率按钮
    _speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_speedButton setImage:[UIImage imageNamed:@"video_nav_ic_speed"] forState:UIControlStateNormal];
    [_speedButton setImage:[UIImage imageNamed:@"video_nav_ic_speed_selected"] forState:UIControlStateSelected];
    [_speedButton addTarget:self action:@selector(speedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headerToolsBar addArrangedSubview:_speedButton];
    
    //更多按钮
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"video_nav_ic_more"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"video_nav_ic_more_selected"] forState:UIControlStateSelected];
    [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headerToolsBar addArrangedSubview:_moreButton];
    
    //选择音乐
    _musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _musicButton.backgroundColor = [UIColor lightGrayColor];
    _musicButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _musicButton.layer.cornerRadius = 16;
    _musicButton.clipsToBounds = YES;
    [_musicButton setTitle:NSLocalizedStringFromTable(@"tu_选择音乐", @"VideoDemo", @"选择音乐") forState:UIControlStateNormal];
    [_musicButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_musicButton setImage:[UIImage imageNamed:@"ic_music"] forState:UIControlStateNormal];
    [self addSubview:_musicButton];
    
    //滤镜按钮
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_filterButton setImage:[UIImage imageNamed:@"video_ic_filter"] forState:0];
    [_filterButton addTarget:self action:@selector(filterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_filterToolsBar addArrangedSubview:_filterButton];
    
    //完成按钮
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setImage:[UIImage imageNamed:@"video_ic_save"] forState:0];
    _doneButton.hidden = YES;
    [_filterToolsBar addArrangedSubview:_doneButton];

    //回删按钮
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _undoButton.hidden = YES;
    [_undoButton setImage:[UIImage imageNamed:@"video_ic_undo"] forState:0];
    [_undoButton addTarget:self action:@selector(undoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_undoButton];
    
    //贴纸按钮
    _stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_stickerButton setImage:[UIImage imageNamed:@"video_ic_sticker"] forState:0];
    [_stickerButton addTarget:self action:@selector(stickerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_stickerButton];
    
    // 滤镜视图
    _filterPanelView = [TTFilterPanelView beautyPanelWithFrame:CGRectZero beautyTarget:self.beautyTarget];
    _filterPanelView.alpha = 0;
    _filterPanelView.delegate = self;
    [self addSubview:_filterPanelView];
    
    // 贴纸视图
    _stickerPanelView = [TTStickerPanelView beautyPanelWithFrame:CGRectZero beautyTarget:self.beautyTarget];
    _stickerPanelView.alpha = 0;
    _stickerPanelView.delegate = self;
    
    //美颜视图
    _beautyPanelView = [TTBeautyPanelView beautyPanelWithFrame:CGRectZero beautyTarget:self.beautyTarget];
    _beautyPanelView.delegate = self;
    _beautyPanelView.alpha = 0;
    [self addSubview:_beautyPanelView];
    
    //速率调节视图
    _speedSegmentView = [[SpeedSegmentView alloc] initWithFrame:CGRectZero];
    _speedSegmentView.hidden = YES;
    [self addSubview:_speedSegmentView];
    
    //折叠功能菜单视图
    _moreMenuView = [[CameraMoreMenuView alloc] initWithFrame:CGRectZero];
    _moreMenuView.alpha = 0;
    //默认隐藏合拍布局配置
    [_moreMenuView setJoinerHidden:YES];
    
    //底部切换控件
    _captureModeView = [[TextPageControl alloc] init];
    [_captureModeView addTarget:self action:@selector(captureModeChangeAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_captureModeView];
    // 相机模式
    _captureModeView.titles = @[NSLocalizedStringFromTable(@"tu_拍照", @"VideoDemo", @"拍照"),
                                NSLocalizedStringFromTable(@"tu_录制", @"VideoDemo", @"录制"),
                                NSLocalizedStringFromTable(@"tu_合拍", @"VideoDemo", @"合拍")];
    _captureModeView.selectedIndex = 1;
    
    //录制按钮
    _captureButton = [[RecordButton alloc] init];
    [_captureButton switchStyle:RecordButtonStyle_TapRecord];
    [self addSubview:_captureButton];
    
    //合拍选择素材按钮
    _joinerEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _joinerEditButton.hidden = YES;
    [_joinerEditButton setImage:[UIImage imageNamed:@"rhythm_ic_pic"] forState:UIControlStateNormal];
    [self addSubview:_joinerEditButton];
    
    //侧滑手势
    UISwipeGestureRecognizer *nextFilterSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextFilterSwipeAction:)];
    nextFilterSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    nextFilterSwipe.delegate = self;
    [self addGestureRecognizer:nextFilterSwipe];
    
    UISwipeGestureRecognizer *lastFilterSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(lastFilterSwipeAction:)];
    lastFilterSwipe.delegate = self;
    lastFilterSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:lastFilterSwipe];
    
    
}

//销毁
- (void)destoryView
{
    
}

- (void)layoutSubviews
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect safeBounds = [UIScreen mainScreen].bounds;
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    //速率调节栏高度
    const CGFloat speedSegmentSideMargin = 37.5;
    const CGFloat speedSegmentH = 30;
    const CGFloat height_3_4 = CGRectGetWidth(safeBounds) / 3 * 4;
    const CGFloat speedSegmentOffset = 10;
    CGFloat speedSegmentY = height_3_4 - speedSegmentOffset - speedSegmentH;
    
    if (@available(iOS 11.0, *))
    {
        safeAreaInsets = self.safeAreaInsets;
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, safeAreaInsets);
        
        // 顶部工具栏高度
        const CGFloat kTopBarHeight = 64.0;

        CGFloat topOffset = self.safeAreaInsets.top;
        if (topOffset > 0)
        {
            speedSegmentY = topOffset + kTopBarHeight + height_3_4 - speedSegmentOffset - speedSegmentH;
        }
    }
    
    self->_exposureSlider.frame = CGRectMake(self.bounds.size.width - 45, (self.bounds.size.height - 220) * 0.5, 40, 220);
    self->_lightImageView.frame = CGRectMake(self.bounds.size.width - 40, (self.bounds.size.height - 220) * 0.5 - 35, 30, 30);
    self->_focusTouchView.frame = self.bounds;
    
    CGFloat statesBarHeight = lsq_STATES_BAR_HEIGHT;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        statesBarHeight = lsq_STATES_BAR_HEIGHT_iPhoneX;
    }
    
    self->_filterButton.frame = CGRectMake((size.width - 100) / 2, (size.height - 100) / 2, 100, 100);
    _markableProgressView.frame = CGRectMake(0, statesBarHeight, self.bounds.size.width, 4);
    _headerToolsBar.frame = CGRectMake(0, CGRectGetMaxY(_markableProgressView.frame), size.width, 64);
    _musicButton.frame = CGRectMake((size.width - 120)/2, CGRectGetMaxY(_headerToolsBar.frame) + 5, 120, 32);
    _filterNameLabel.frame = CGRectMake((size.width - 120)/2, CGRectGetMaxY(_musicButton.frame) + 5, 120, 32);
    _filterToolsBar.center = CGPointMake(size.width * 3 / 4 + 18, _captureButton.center.y);
    [_filterToolsBar lsqSetSize:CGSizeMake(120, 64)];
    
    // 初始化滤镜视图
    const CGFloat filterPanelHeight = 216 + safeAreaInsets.bottom;
    self->_filterPanelView.frame = CGRectMake(0, size.height - filterPanelHeight, size.width, filterPanelHeight);
    self->_beautyPanelView.frame = CGRectMake(0, size.height - filterPanelHeight, size.width, filterPanelHeight);
    self->_speedSegmentView.frame = CGRectMake(CGRectGetMinX(safeBounds) + speedSegmentSideMargin,
                                               speedSegmentY,
                                               CGRectGetMaxX(safeBounds) - speedSegmentSideMargin * 2,
                                               speedSegmentH);
    // 初始化贴纸视图
    const CGFloat stickerPanelHeight = 200 + safeAreaInsets.bottom;
    self->_stickerPanelView.frame = CGRectMake(0, size.height - stickerPanelHeight, size.width, stickerPanelHeight);
    // 初始化折叠功能菜单视图
    const CGFloat moreMenuX = 10;
    _moreMenuView.frame = CGRectMake(CGRectGetMinX(safeBounds) + moreMenuX, CGRectGetMinY(safeBounds) + 74, CGRectGetWidth(safeBounds) - moreMenuX * 2, _moreMenuView.intrinsicContentSize.height);
    
    const CGFloat captureButtonWidth = 72;
    const CGFloat captureModelHeight = 55;
    const CGFloat buttonWidth = 50;
    
    //切换模式
    [_captureModeView setNeedsDisplay];
    _captureModeView.frame = CGRectMake(0, size.height - safeAreaInsets.bottom - captureModelHeight, size.width, captureModelHeight);
    //录制按钮
    _captureButton.frame = CGRectMake((size.width - captureButtonWidth) / 2, size.height - safeAreaInsets.bottom - captureModelHeight - captureButtonWidth, captureButtonWidth, captureButtonWidth);
    
    _stickerButton.center = CGPointMake(size.width / 4 - 18, _captureButton.center.y);
    [_stickerButton lsqSetSize:CGSizeMake(buttonWidth, buttonWidth)];
    
    _undoButton.center = _captureModeView.center;
    [_undoButton lsqSetSize:CGSizeMake(32, 32)];
    
    [_markableProgressView addPlaceholder:1.0 * _minRecordTime / _maxRecordTime markWidth:4];
}

#pragma mark - button actions callback
//切换摄像头
- (void)switchCameraButtonAction:(UIButton *)sender
{
    if (_isFrontDevicePosition) {
        _isFrontDevicePosition = NO;
    } else {
        _isFrontDevicePosition = YES;
    }
    //切换摄像头时先关闭闪光灯，再根据摄像头方向判断是否允许使用闪关灯
    _moreMenuView.enableFlash = NO;
    _moreMenuView.disableFlashSwitching = _isFrontDevicePosition;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:method:)]) {
        [self.delegate cameraView:self method:TTMethodRotateCamera];
    }
}

//美颜按钮
- (void)beautyButtonAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.currentBottomPanelView = sender.selected ? _beautyPanelView : nil;
}

//录制速率按钮
- (void)speedButtonAction:(UIButton *)sender
{
    _speedSegmentView.hidden = sender.selected;
    
    if (!sender.selected) {
        _beautyButton.selected = NO;
        self.currentBottomPanelView = nil;
    }
    if (!_speedSegmentView.hidden) {
        [self bringSubviewToFront:_speedSegmentView];
    }
    sender.selected = !sender.selected;
}

// 更多按钮
- (void)moreButtonAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.currentTopPanelView = sender.selected ? _moreMenuView : nil;
}

/**
 *  贴纸按钮点击
 *  @param sender 选中的按钮
 */
- (void)stickerButtonAction:(UIButton *)sender
{
    self.currentBottomPanelView = _stickerPanelView.alpha == 0 ? _stickerPanelView : nil;
}

/**
 *  相机模式切换
 *  @param sender 选中的按钮
 */
- (void)captureModeChangeAction:(TextPageControl *)sender {
    [self captureModeChangeStyle:sender.selectedIndex];
    if (!_moreMenuView.isHidden) {
        [self setPanel:_moreMenuView hidden:YES fromTop:YES];
        _moreButton.selected = NO;
    }
}
/**
 *  相机模式切换
 *  @param style 相机拍照模式
 */
- (void)captureModeChangeStyle:(RecordButtonStyle)style
{
    [_captureButton switchStyle:style];
    //拍照时隐藏更多里变声开关
    _moreMenuView.pitchHidden = style == RecordButtonStyle_PhotoCapture;
    //合拍时显示更多里合拍布局
    _moreMenuView.joinerHidden = style != RecordButtonStyle_JoinerRecord;
    //拍照时隐藏更多里麦克风开关
    _moreMenuView.microphoneHidden = style == RecordButtonStyle_PhotoCapture;
    //合拍时隐藏更多里比例开关
    _moreMenuView.ratioHidden = style == RecordButtonStyle_JoinerRecord;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        //拍照时隐藏-速率调节按钮、速率调节面板、录制进度
        self->_speedButton.hidden = style == RecordButtonStyle_PhotoCapture;
        self->_speedSegmentView.hidden = self->_speedButton.hidden;
        self->_markableProgressView.hidden = style == RecordButtonStyle_PhotoCapture;
        //选择音乐仅在录制模式下使用
        self->_musicButton.hidden = style != RecordButtonStyle_TapRecord;
        
        if (style == RecordButtonStyle_PhotoCapture) {
            self->_speedSegmentView.hidden = YES;
        } else {
            //录制模式切换时根据按钮点击状态来判断是否隐藏
            self->_speedSegmentView.hidden = !self->_speedButton.selected;
        }
    }];
    
    if (style == RecordButtonStyle_JoinerRecord) {
        //合拍时如果当前画布比例不为全屏时则设置为全屏
        if (_ratioType != TTVideoAspectRatio_full) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:setAspectRatio:)]) {
                [self.delegate cameraView:self setAspectRatio:TTVideoAspectRatio_full];
            }
        }
        
        //显示合拍控制器
        if ([self.delegate respondsToSelector:@selector(cameraView:method:)]) {
            [self.delegate cameraView:self method:TTMethodShowJoiner];
        }
        
    } else if (style == RecordButtonStyle_TapRecord) {
        _joinerEditButton.hidden = YES;
        NSString *musicName = _musicButton.titleLabel.text;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_markableProgressView addPlaceholder: 1.0 * self->_minRecordTime / self->_maxRecordTime markWidth:4];
        });
        //仅在录制时添加音乐
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:setMusicName:)]) {
            [self.delegate cameraView:self setMusicName:musicName];
        }
    } else {
        _joinerEditButton.hidden = YES;
        //设置混音类型为空
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:setMusicName:)]) {
            [self.delegate cameraView:self setMusicName:@""];
        }
    }
    //非合拍时移除合拍特效
    if (style != RecordButtonStyle_JoinerRecord) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:method:)]) {
            [self.delegate cameraView:self method:TTMethodRemoveJoiner];
        }
    }
}

/// 回删片段
- (void)undoButtonAction:(UIButton *)sender
{

    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:method:)]) {
        [self.delegate cameraView:self method:TTMethodRemoveLastRecordPart];
        
        //删除录制进度UI片段
        dispatch_async(dispatch_get_main_queue(), ^{

            [self->_markableProgressView popMark];
            [self updateRecordConfrimViewsDisplay];
        });
    }
}

/// 点击滤镜
- (void)filterButtonAction:(UIButton *)sender
{
    self.currentBottomPanelView = _filterPanelView.alpha == 0 ? _filterPanelView : nil;
}

/// 曝光强度变化
- (void)exposureSliderValueChanged:(UISlider *)slider
{
    if (_lastExposureValue == slider.value) return;
    
    _lastExposureValue = slider.value;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:setExposureBiasValue:)]) {
        
        [self.delegate cameraView:self setExposureBiasValue:slider.value];
    }
}

#pragma mark method

/// 重置页面，恢复前台时使用
- (void)resetCameraView
{
    //当前非拍照时
    if ([_captureButton getRecordStyle] != RecordButtonStyle_PhotoCapture) {

        [self updateRecordViewsDisplay];
    }
    if (self.currentBottomPanelView != nil) {
        _stickerButton.hidden = YES;
        _captureButton.hidden = YES;
        _captureModeView.hidden = YES;
        _filterToolsBar.hidden = YES;
        _speedSegmentView.hidden = YES;
    }
}
/// 更新滤镜名称状态
- (void)updateFilterLabelStatus
{
    if (_filterNameLabel.alpha != 0.0) return;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        
        self->_filterNameLabel.alpha = 1;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration delay:1 options:0 animations:^{
            
            self->_filterNameLabel.alpha = 0;
            
        } completion:^(BOOL finished) {}];
    }];
}

/// 录制结束时显示控件
- (void)showViewsWhenPauseRecording
{
    _headerToolsBar.hidden = NO;
    _filterToolsBar.hidden = NO;
    _stickerButton.hidden = NO;
    
    _captureButton.selected = NO;

    [self updateRecordConfrimViewsDisplay];
    _filterButton.hidden = NO;
    _musicButton.hidden = ([_captureButton getRecordStyle] != RecordButtonStyle_TapRecord);
    _speedSegmentView.hidden = !_speedButton.selected;
}

/// 正在录制时隐藏相关UI
- (void)hideViewsWhenRecording
{
    _moreButton.selected = NO;
    self.currentBottomPanelView = nil;
    self.currentTopPanelView = nil;
    _speedSegmentView.hidden = YES;
    
    _headerToolsBar.hidden = YES;
    _filterToolsBar.hidden = YES;
    _stickerButton.hidden = YES;
    _filterButton.hidden = YES;

    _doneButton.hidden = YES;
    _undoButton.hidden = YES;
    _captureModeView.hidden = YES;
    _musicButton.hidden = YES;
}
///  更新相关UI控件
- (void)updateRecordViewsDisplay
{
    [_markableProgressView reset];
    [self updateRecordConfrimViewsDisplay];
}

///  更新相关UI控件
- (void)updateRecordConfrimViewsDisplay
{
    BOOL hasRecordFragment = _markableProgressView.progress > 0;

    _doneButton.hidden = !hasRecordFragment;
    _undoButton.hidden = !hasRecordFragment;
    
    _captureModeView.hidden = hasRecordFragment;
}

/// 更新合拍布局
- (void)refreshJoinerRect:(CGRect)rect
{
    if (_joinerEditButton.hidden) {
        _joinerEditButton.hidden = NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.joinerEditButton.frame = CGRectMake(rect.origin.x * lsqScreenWidth + 8, lsqScreenHeight*(rect.origin.y + rect.size.height) - 32, 24, 24);
    });
}

/// 录制进度更新
- (void)recordProgressChanged:(CGFloat)progress;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_markableProgressView.progress = progress;
        if (progress >= 1.0)
        {
            [[TuViews shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_完成录制", @"VideoDemo", @"完成录制")];
        } 
    });
}

/// 录制进度状态更新
- (void)recordStateChanged:(TTRecordState)recordState
{
    switch (recordState) {
        case TTRecordStatePaused:    //暂停
        {
            [self->_markableProgressView pushMark];
            [self showViewsWhenPauseRecording];
        }
            break;
        case TTRecordStateComplete:  //完成
        {
            if ([_captureButton getRecordStyle] == RecordButtonStyle_TapRecord) {
                _moreMenuView.disableRatioSwitching = NO;
            }
            _captureButton.selected = NO;
            [self showViewsWhenPauseRecording];
        }
            break;
        default:
            break;
    }
}

/// 获取当前的控制器
- (UIViewController *)currentViewController
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    return vc;
}

/// 录制失败相关信息
- (void)recordFailedWithError:(NSError *)error
{
    switch (error.code)
    {
        case lsqRecordVideoErrorUnknow:
            [[TuViews shared].messageHub showError:NSLocalizedStringFromTable(@"tu_录制失败：未知原因失败", @"VideoDemo", @"录制失败：未知原因失败")];
            break;
            
        case lsqRecordVideoErrorSaveFailed: // 取消录制 同时 重置UI
        {
            [self updateRecordViewsDisplay];

            [[TuViews shared].messageHub setStatus:NSLocalizedStringFromTable(@"tu_录制失败", @"VideoDemo", @"录制失败")];
        }
            break;
            
        case lsqRecordVideoErrorLessMinDuration:
            [[TuViews shared].messageHub showError:NSLocalizedStringFromTable(@"tu_不能低于最小时间", @"VideoDemo", @"不能低于最小时间")];
            break;
            
        case lsqRecordVideoErrorMoreMaxDuration:
            [self showViewsWhenPauseRecording];
            [[TuViews shared].messageHub showError:NSLocalizedStringFromTable(@"tu_大于最大时长，请保存视频后继续录制", @"VideoDemo", @"大于最大时长，请保存视频后继续录制")];
            break;
            
        case lsqRecordVideoErrorNotEnoughSpace:
            [[TuViews shared].messageHub showError:NSLocalizedStringFromTable(@"tu_手机可用空间不足，请清理手机", @"VideoDemo", @"手机可用空间不足，请清理手机")];
            break;
            
        default:
            break;
    }
}

#pragma mark - property
/**
 * 设置录制按钮的委托对象
 * @param delegate RecordButtonDelegate
 */
- (void)setRecordButtonDelegate:(id<RecordButtonDelegate>)delegate
{
    self.captureButton.delegate = delegate;
}

/**
 * 设置更多页面的委托对象
 * @param delegate CameraMoreMenuViewDelegate
 */
- (void)setMoreMenuViewDelegate:(id<CameraMoreMenuViewDelegate>)delegate;
{
    self.moreMenuView.delegate = delegate;
}

- (void)setIsFrontDevicePosition:(BOOL)isFrontDevicePosition
{
    _isFrontDevicePosition = isFrontDevicePosition;
    _moreMenuView.disableFlashSwitching = isFrontDevicePosition;
}

- (void)setCapture:(TuCamera *)capture
{
    _focusTouchView.camera = capture;
}

/**
 设置当前顶部视图

 @param currentTopPanelView 当前顶部显示的视图
 */
- (void)setCurrentTopPanelView:(UIView *)currentTopPanelView
{
    [self setPanel:_currentTopPanelView hidden:YES fromTop:YES];
    
    _currentTopPanelView = currentTopPanelView;
    if (!_currentTopPanelView)
    {
        return;
    }
    
    [self setPanel:_currentTopPanelView hidden:NO fromTop:YES];
}

/**
 设置当前底部视图

 @param currentBottomPanelView 当前底部显示的视图
 */
- (void)setCurrentBottomPanelView:(UIView *)currentBottomPanelView
{
    [self setPanel:_currentBottomPanelView hidden:YES fromTop:NO];
    
    // 页面下部出现的控件会遮挡原本的视图，因此在此需要做切换显示
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self->_stickerButton.hidden = NO;
        self->_captureButton.hidden = NO;
        self->_filterToolsBar.hidden = NO;
        //模式切换按钮和完成按钮不会共存
        self->_captureModeView.hidden = !self->_doneButton.hidden;
    }];
    
    _currentBottomPanelView = currentBottomPanelView;
    if (!_currentBottomPanelView)
    {
        return;
    }
    
    
    [self setPanel:_currentBottomPanelView hidden:NO fromTop:NO];
    
    // 页面下部出现的控件会遮挡原本的视图，因此在此需要做切换显示
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self->_stickerButton.hidden = YES;
        self->_captureButton.hidden = YES;
        self->_captureModeView.hidden = YES;
        self->_filterToolsBar.hidden = YES;
    }];
    
    // 下部面板显示时，取消选中速率按钮，处理速率控件
    _speedButton.selected = NO;
    _speedSegmentView.hidden = YES;
}
/**
 设置视图显示位置和状态

 @param panel 显示视图
 @param hidden 视图显隐状态
 @param fromTop 距离
 */
- (void)setPanel:(UIView *)panel hidden:(BOOL)hidden fromTop:(BOOL)fromTop
{
    if ((panel.alpha == 0.0) == hidden)
    {
        return;
    }
    
    CGFloat multiplier = fromTop ? 1.0 : -1.0;
    CGPoint panelCenter = panel.center;
    
    if (hidden)
    {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            panel.alpha = 0;
            panel.center = CGPointMake(panelCenter.x, panelCenter.y + 44);
        } completion:^(BOOL finished) {
            panel.center = panelCenter;
            [panel removeFromSuperview];
        }];
    }
    else
    {
        [self addSubview:panel];
        panel.center = CGPointMake(panelCenter.x, panelCenter.y - 44 * multiplier);
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            panel.alpha = 1;
            panel.center = panelCenter;
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 当美颜面板出现时则禁用左滑、右滑手势
    if (_beautyPanelView.alpha == 1) {
        _canSwipeFilter = NO;
        return NO;
    }
    // 在滤镜面板上禁止滑动
    if ([_filterPanelView.layer containsPoint:[touch locationInView:_filterPanelView]]) {
        return NO;
    }
    if (!_canSwipeFilter) {
        _canSwipeFilter = YES;
    }
    return YES;
}

#pragma mark - UISwipeGestureRecognizer
- (void)nextFilterSwipeAction:(UISwipeGestureRecognizer *)sender
{
    if (_canSwipeFilter)
    {
        [_filterPanelView swipeToLastFilter];
    }
}

- (void)lastFilterSwipeAction:(UISwipeGestureRecognizer *)sender
{
    if (_canSwipeFilter)
    {
        [_filterPanelView swipeToNextFilter];
    }
}

#pragma mark - TuFocusTouchViewDelegate
- (BOOL)focusTouchView:(TuFocusTouchViewBase *)focusTouchView didTapPoint:(CGPoint)point
{
    if (_currentTopPanelView
        || _currentBottomPanelView
        || _speedSegmentView.hidden == NO)
    {
        //点击去除所有叠层面板
        self.currentBottomPanelView = nil;
        self.currentTopPanelView = nil;
        
        //重置按钮的选中状态
        [self resetAllBtnStatus];
        
        return NO;
    }
    else
    {
        _exposureSlider.value = 0.5;
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraView:setExposureBiasValue:)]) {
            
            [self.delegate cameraView:self setExposureBiasValue:_exposureSlider.value];
        }

        return YES;
    }
}

//重置按钮的选中状态
- (void)resetAllBtnStatus
{
    _beautyButton.selected = _moreButton.selected = NO;
}

#pragma mark - TTFilterPanelViewDelegate
/**
 * 切换滤镜
 * @param view 滤镜视图
 * @param filterCode 滤镜code
 */
- (void)filterPanelView:(TTFilterPanelView *)view didSelectFilterCode:(NSString *)filterCode
{
    NSString *code = [NSString stringWithFormat:@"lsq_filter_%@", filterCode];
    _filterNameLabel.text = NSLocalizedStringFromTable(code, @"TuSDKConstants", @"无需国际化");
    [self updateFilterLabelStatus];
}

#pragma mark - TTBeautyPanelViewDelegate
/**
 * 切换美肤类型
 * @param view 当前视图
 * @param skinStyle 美肤类型
 */
- (void)beautyPanelView:(TTBeautyPanelView *)view didSelectSkinType:(TTSkinStyle)skinStyle;
{
    switch (skinStyle) {
        case TTSkinStyleNatural:
            _filterNameLabel.text = NSLocalizedStringFromTable(@"lsq_filter_set_skin_beauty", @"TuSDKConstants", @"无需国际化");
            break;
        case TTSkinStyleHazy:
            _filterNameLabel.text = NSLocalizedStringFromTable(@"lsq_filter_set_skin_extreme", @"TuSDKConstants", @"无需国际化");
            break;
        case TTSkinStyleBeauty:
            _filterNameLabel.text = NSLocalizedStringFromTable(@"lsq_filter_set_skin_precision", @"TuSDKConstants", @"无需国际化");
            break;
        default:
            break;
    }
    [self updateFilterLabelStatus];
}

#pragma mark - TTStickerPanelViewDelegate
//选中贴纸类型为哈哈镜时，取消微整形效果
- (void)stickerPanelView:(TTStickerPanelView * _Nullable)panelView didSelectItem:(__kindof TuStickerBaseData *)categoryItem;
{
    //动态贴纸和哈哈镜不能同时存在
    if ([categoryItem isKindOfClass:[TuMonsterData class]])
    {
        // 微整形移除
        [_beautyPanelView enablePlastic:NO];
        [_beautyPanelView enableExtraPlastic:NO];
    }
}

/// 取消合拍时更新录制按钮状态
- (void)cancelJoinerUpdateRecordState
{
    [_captureModeView setSelectedIndex:RecordButtonStyle_TapRecord animated:YES];
    [self captureModeChangeStyle:RecordButtonStyle_TapRecord];
}

/// 更新合拍时按钮状态
- (void)moreJoinerDisable:(BOOL)isDisable {
    if ([_captureButton getRecordStyle] != RecordButtonStyle_JoinerRecord) {
        return;
    }
    _moreMenuView.disableJoiner = isDisable;
    _joinerEditButton.hidden = isDisable;
}



@end
