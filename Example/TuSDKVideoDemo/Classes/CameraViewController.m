
/********************************************************
 * @file    : CameraViewController.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 相机控制器
*********************************************************/

#import "CameraViewController.h"

#import "TuSDKFramework.h"
// 资源配置列表
#import "Constants.h"
#import "TuCameraFilterPackage.h"
#import "TuBeautyPanelConfig.h"
#import "TextPageControl.h"
#import "videoCameraShower.h"
#import "TuVideoFocusTouchView.h"
#import "SpeedSegmentView.h"
#import "PhotoCaptureConfirmView.h"

#import "TuFilterPanelView.h"
#import "TuBeautyPanelView.h"
#import "TuStickerPanelView.h"


@interface CameraViewController()<CameraMoreMenuViewDelegate,
                                    videoCameraShowerDelegate,
                                    TuCameraDelegate,
                                    TuFocusTouchViewDelegate,
                                    TuFilterPanelViewDelegate,
                                    TuBeautyPanelViewDelegate,
                                    TuStickerPanelViewDelegate,
                                    RecordButtonDelegate,
                                    UIGestureRecognizerDelegate>

{
    TuVideoFocusTouchView *_focusTouchView;
    
    UISlider *_exposureSlider;
    UIImageView *_lightImageView;
    
    UIStackView *_headerToolsBar; /**顶部工具栏*/
    UIStackView *_filterToolsBar; /**滤镜工具栏*/
    UIButton *_switchCameraButton; // 切换摄像头
    UIButton *_beautyButton;
    UIButton *_speedButton; // 录制速率页显示按钮
    UIButton *_moreButton; // 更多按钮

    UIButton *_stickerButton;
    UIButton *_filterButton;

    RecordButton *_captureButton;
    UIButton *_doneButton; /**完成按钮*/
    UIButton *_undoButton; /**回删按钮*/

    SpeedSegmentView *_speedSegmentView; // 录制速率控制页面
    CameraMoreMenuView *_moreMenuView;
    TuFilterPanelView *_filterPanelView;
    TuBeautyPanelView *_beautyPanelView;
    TuStickerPanelView *_stickerPanelView;
    TextPageControl *_captureModeView; /**录制模式切换控件*/
    PhotoCaptureConfirmView *_photoCaptureConfirmView; // 拍照完成保存确认页
    
    videoCameraShower *_cameraShower;
    UIImage *_capturedPhoto;
    
    BOOL _isOpenSetting;
    CGFloat _zoomBeganVal;
    
    lsqRatioType _ratioType;
}

@property(weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet MarkableProgressView *markableProgressView; // 录制进度
@property (nonatomic, weak) IBOutlet UILabel *filterNameLabel;

// 拍照模式中，确认照片视图
@property (nonatomic, weak) UIView *currentBottomPanelView; // 当前的底部面板
@property (nonatomic, weak) UIView *currentTopPanelView; // 当前的顶部面板

@end


@implementation CameraViewController

#pragma mark - controller
// --------------------------------------------------
+ (instancetype)recordController
{
    return [[CameraViewController alloc] initWithNibName:nil bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationDidBecomeActiveNotification object:nil];
   
    // 获取相册的权限
    [TuTSAssetsManager testLibraryAuthor:^(NSError *error) {
        if (error)
        {
            [TuTSAssetsManager showAlertWithController:self loadFailure:error];
        }
    }];
        
    // 设置UI
    [self setupUI];
    
    // 相机权限
    [self requestCameraPermission];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden
{
    // 隐藏状态栏
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // 只支持竖屏
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    // 不允许旋转
    return NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 当从别的页面返回相机页面时，需要判断相机状态
    // [_camera resumeCameraCapture];
    // 设置屏幕常亮，默认是NO
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 相机跳转至其他页面，操作后如需返回相机界面，需要暂停相机
    // [_camera pauseCameraCapture];
    // 关闭屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

// --------------------------------------------------
- (void)enterBackFromFront
{
    // 进入后台
    // 进入后台后取消录制，舍弃之前录制的信息
    if (_cameraShower && _cameraShower.camera)
    {
        [self cancelRecording];
        [_cameraShower.camera stopPreview];
    }
    
    // 关闭闪光灯
    _moreMenuView.enableFlash = NO;
    _moreMenuView.disableFlashSwitching = (_cameraShower.camera.devicePosition == AVCaptureDevicePositionFront);
}

- (void)enterFrontFromBack
{
    // 恢复前台
    // 为匹配：进入后台后取消录制，舍弃之前录制的信息  , 回复到前台后重启相机，回复UI页面
    if (_cameraShower
        && _cameraShower.camera
        && _cameraShower.camera.status != TuCameraState_START
        && _cameraShower.camera.status != TuCameraState_START_PREVIEW)
    {
        [_cameraShower.camera startPreview];
    }
    
    if ([_captureButton getRecordStyle] == RecordButtonStyle_LongPressRecord
        || [_captureButton getRecordStyle] == RecordButtonStyle_TapRecord)
    {
        [_markableProgressView reset];
        [self updateRecordConfrimViewsDisplay];
    }
    if (self.currentBottomPanelView != nil)
    {
        _stickerButton.hidden = YES;
        _captureButton.hidden = YES;
        _captureModeView.hidden = YES;
        _filterToolsBar.hidden = YES;
        _speedSegmentView.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews
{
    // 获取相机的权限并启动相机
    if(self->_isOpenSetting)
    {
        [self requestCameraPermission];
    }
            
    self->_exposureSlider.frame = CGRectMake(self.view.bounds.size.width - 45, (self.view.bounds.size.height-220)*0.5, 40, 220);
    self->_lightImageView.frame = CGRectMake(self.view.bounds.size.width - 40, (self.view.bounds.size.height-220)*0.5 - 35, 30, 30);
    self->_focusTouchView.frame = self.view.bounds;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect safeBounds = [UIScreen mainScreen].bounds;
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *))
    {
        safeAreaInsets = self.view.safeAreaInsets;
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, safeAreaInsets);
    }
    
    const CGFloat speedSegmentSideMargin = 37.5;
    const CGFloat speedSegmentH = 30;
    const CGFloat height_3_4 = CGRectGetWidth(safeBounds) / 3 * 4;
    const CGFloat speedSegmentOffset = 10;
    CGFloat speedSegmentY = height_3_4 - speedSegmentOffset - speedSegmentH;
    if (@available(iOS 11.0, *))
    {
        // 顶部工具栏高度
        const CGFloat kTopBarHeight = 64.0;

        CGFloat topOffset = self.view.safeAreaInsets.top;
        if (topOffset > 0)
        {
            speedSegmentY = topOffset + kTopBarHeight + height_3_4 - speedSegmentOffset - speedSegmentH;
        }
    }

    _speedSegmentView.frame = CGRectMake(CGRectGetMinX(safeBounds) + speedSegmentSideMargin,
                                         speedSegmentY,
                                         CGRectGetMaxX(safeBounds) - speedSegmentSideMargin * 2,
                                         speedSegmentH);
    
    // 初始化折叠功能菜单视图
    const CGFloat moreMenuX = 10;
    _moreMenuView.frame = CGRectMake(CGRectGetMinX(safeBounds) + moreMenuX, CGRectGetMinY(safeBounds) + 74, CGRectGetWidth(safeBounds) - moreMenuX * 2, _moreMenuView.intrinsicContentSize.height);
    // 初始化贴纸视图
    const CGFloat stickerPanelHeight = 200 + safeAreaInsets.bottom;
    _stickerPanelView.frame = CGRectMake(0, size.height - stickerPanelHeight, size.width, stickerPanelHeight);
    // 初始化滤镜视图
    const CGFloat filterPanelHeight = 216 + safeAreaInsets.bottom;
    
    _filterPanelView.frame = CGRectMake(0, size.height - filterPanelHeight, size.width, filterPanelHeight);
    _beautyPanelView.frame = CGRectMake(0, size.height - filterPanelHeight, size.width, filterPanelHeight);
    
    [_captureModeView setNeedsDisplay];
    
    
    //new
    const CGFloat captureButtonWidth = 72;
    const CGFloat captureModelHeight = 55;
    const CGFloat buttonWidth = 50;
    _headerToolsBar.frame = CGRectMake(0, CGRectGetMaxY(_markableProgressView.frame), size.width, 64);
    _filterToolsBar.center = CGPointMake(size.width * 3 / 4 + 18, _captureButton.center.y);
    [_filterToolsBar lsqSetSize:CGSizeMake(120, 64)];

    _captureModeView.frame = CGRectMake(0, size.height - safeAreaInsets.bottom - captureModelHeight, size.width, captureModelHeight);
    _captureButton.frame = CGRectMake((size.width - captureButtonWidth) / 2, size.height - safeAreaInsets.bottom - captureModelHeight - captureButtonWidth, captureButtonWidth, captureButtonWidth);
    
    _stickerButton.center = CGPointMake(size.width / 4 - 18, _captureButton.center.y);
    [_stickerButton lsqSetSize:CGSizeMake(buttonWidth, buttonWidth)];
//    _filterButton.center = CGPointMake(size.width * 3 / 4 + 18, _captureButton.center.y);
//    [_filterButton lsqSetSize:CGSizeMake(buttonWidth, buttonWidth)];
//    _doneButton.center = CGPointMake(size.width * 3 / 4 + 18, _captureButton.center.y);
//    [_doneButton lsqSetSize:CGSizeMake(buttonWidth, buttonWidth)];

    _undoButton.center = _captureModeView.center;
    [_undoButton lsqSetSize:CGSizeMake(32, 32)];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];

    [self setNavigationBarHidden:YES animated:NO];
    
    if (![UIDevice lsqIsDeviceiPhoneX])
    {
        [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    _focusTouchView = [[TuVideoFocusTouchView alloc] initWithFrame:self.view.bounds];
    _focusTouchView.delegate = self;
    [self.view addSubview:_focusTouchView];


    _lightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _lightImageView.image = [UIImage imageNamed:@"ic_light"];
    [self.view addSubview:_lightImageView];
    
    _exposureSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    _exposureSlider.transform = CGAffineTransformMakeRotation(-M_PI/2);
    _exposureSlider.maximumValue = 1.0;
    _exposureSlider.minimumValue = 0.0;
    _exposureSlider.value = 0.5;
    _exposureSlider.minimumTrackTintColor = [UIColor whiteColor];
    _exposureSlider.maximumTrackTintColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.3];
    [_exposureSlider setThumbImage:[UIImage imageNamed:@"slider_thum_icon"] forState:UIControlStateNormal];
    [_exposureSlider addTarget:self action:@selector(exposureSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_exposureSlider];

    //顶部工具栏
    _headerToolsBar = [[UIStackView alloc] init];
    _headerToolsBar.axis = UILayoutConstraintAxisHorizontal;
    _headerToolsBar.distribution = UIStackViewDistributionFillEqually;
    _headerToolsBar.alignment = UIStackViewAlignmentCenter;
    [self.view addSubview:_headerToolsBar];
    
    //滤镜工具栏
    _filterToolsBar = [[UIStackView alloc] init];
    _filterToolsBar.axis = UILayoutConstraintAxisHorizontal;
    _filterToolsBar.distribution = UIStackViewDistributionFillEqually;
    _filterToolsBar.alignment = UIStackViewAlignmentCenter;
    [self.view addSubview:_filterToolsBar];
        
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
        
    //底部切换控件
    _captureModeView = [[TextPageControl alloc] init];
    [_captureModeView addTarget:self action:@selector(captureModeChangeAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_captureModeView];
    
    //录制按钮
    _captureButton = [[RecordButton alloc] init];
    [_captureButton switchStyle:RecordButtonStyle_LongPressRecord];
    _captureButton.delegate = self;
    [self.view addSubview:_captureButton];
    
    //贴纸按钮
    _stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_stickerButton setImage:[UIImage imageNamed:@"video_ic_sticker"] forState:0];
    [_stickerButton addTarget:self action:@selector(stickerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stickerButton];
    
    //滤镜按钮
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_filterButton setImage:[UIImage imageNamed:@"video_ic_filter"] forState:0];
    [_filterButton addTarget:self action:@selector(filterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_filterToolsBar addArrangedSubview:_filterButton];

    //完成按钮
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setImage:[UIImage imageNamed:@"video_ic_save"] forState:0];
    [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _doneButton.hidden = YES;
    [_filterToolsBar addArrangedSubview:_doneButton];

    //回删按钮
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _undoButton.hidden = YES;
    [_undoButton setImage:[UIImage imageNamed:@"video_ic_undo"] forState:0];
    [_undoButton addTarget:self action:@selector(undoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_undoButton];
    
    _speedSegmentView = [[SpeedSegmentView alloc] initWithFrame:CGRectZero];
    _speedSegmentView.hidden = YES;
    [_speedSegmentView addTarget:self action:@selector(speedSegmentValueChangeAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_speedSegmentView];
    
    // 折叠功能菜单视图
    _moreMenuView = [[CameraMoreMenuView alloc] initWithFrame:CGRectZero];
    _moreMenuView.alpha = 0;
    _moreMenuView.delegate = self;
    
    // 滤镜视图
    _filterPanelView = [[TuFilterPanelView alloc] initWithFrame:CGRectZero];
    _filterPanelView.alpha = 0;
    _filterPanelView.delegate = self;
    
    // 贴纸视图
    _stickerPanelView = [[TuStickerPanelView alloc] initWithFrame:CGRectZero];
    _stickerPanelView.alpha = 0;
    _stickerPanelView.delegate = self;

    // 美颜视图
    _beautyPanelView = [[TuBeautyPanelView alloc] initWithFrame:CGRectZero];
    _beautyPanelView.alpha = 0;
    _beautyPanelView.delegate = self;
    
    // 相机模式
    _captureModeView.titles = @[NSLocalizedStringFromTable(@"tu_拍照", @"VideoDemo", @"拍照"),
                                NSLocalizedStringFromTable(@"tu_长按拍摄", @"VideoDemo", @"长按拍摄"),
                                NSLocalizedStringFromTable(@"tu_单击拍摄", @"VideoDemo", @"单击拍摄")];
    _captureModeView.selectedIndex = 1;

    // 滤镜标题
    _filterNameLabel.alpha = 0;
}


#pragma mark - property

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
        [self.view addSubview:panel];
        panel.center = CGPointMake(panelCenter.x, panelCenter.y - 44 * multiplier);
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            panel.alpha = 1;
            panel.center = panelCenter;
        }];
    }
}

- (void)hideViewsWhenRecording
{
//    _currentTopPanelView.sender.selected = NO;
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
}

- (void)showViewsWhenPauseRecording
{
    _headerToolsBar.hidden = NO;
    _filterToolsBar.hidden = NO;
    _stickerButton.hidden = NO;
    
    _captureButton.selected = NO;

    [self updateRecordConfrimViewsDisplay];
    _filterButton.hidden = NO;

    _speedSegmentView.hidden = !_speedButton.selected;
}

- (void)updateRecordConfrimViewsDisplay
{
    BOOL hasRecordFragment = _markableProgressView.progress > 0;
    
//    _filterButton.hidden = hasRecordFragment;
    
    _doneButton.hidden = !hasRecordFragment;
    _undoButton.hidden = !hasRecordFragment;
    
    _captureModeView.hidden = hasRecordFragment;
}

- (void)updateFilterNameStatus
{
    if (_filterNameLabel.alpha != 0.0) return;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        
        self.filterNameLabel.alpha = 1;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration delay:1 options:0 animations:^{
            
            self.filterNameLabel.alpha = 0;
            
        } completion:^(BOOL finished) {}];
    }];
}


#pragma mark - button actions callback
// --------------------------------------------------
- (void)switchCameraButtonAction:(UIButton *)sender
{
    [_cameraShower.camera rotateCamera];
    
    _moreMenuView.enableFlash = NO;
    _moreMenuView.disableFlashSwitching = _cameraShower.camera.devicePosition == AVCaptureDevicePositionFront;
}

- (void)beautyButtonAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.currentBottomPanelView = sender.selected ? _beautyPanelView : nil;
}

- (void)speedButtonAction:(UIButton *)sender
{
    _speedSegmentView.hidden = sender.selected;
    
    
    if (!sender.selected)
    {
        _beautyButton.selected = NO;
        self.currentBottomPanelView = nil;
    }
    sender.selected = !sender.selected;
}

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
 *  滤镜按钮点击
 *  @param sender 选中的按钮
 */
- (void)filterButtonAction:(UIButton *)sender
{
    self.currentBottomPanelView = _filterPanelView.alpha == 0 ? _filterPanelView : nil;
}

- (void)doneButtonAction:(UIButton *)sender
{
    [self finishRecording];
}

- (void)undoButtonAction:(UIButton *)sender
{
    [self undoLastRecordedFragment];
    // 更新 UI
//    [_markableProgressView popMark];
//    [self updateRecordConfrimViewsDisplay];
}

/**
 *  相机模式切换
 *  @param sender 选中的按钮
 */
- (void)captureModeChangeAction:(TextPageControl *)sender
{
    switch (sender.selectedIndex)
    {
        case 0: // 拍照模式
            [_captureButton switchStyle:RecordButtonStyle_PhotoCapture];
            break;
        case 1: // 长按录制模式
            [_captureButton switchStyle:RecordButtonStyle_LongPressRecord];
            break;
        case 2: // 点按录制模式
            [_captureButton switchStyle:RecordButtonStyle_TapRecord];
            break;
    }
    

    _moreMenuView.pitchHidden = sender.selectedIndex == 0 ? YES : NO;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self->_speedButton.hidden = sender.selectedIndex == 0 ? YES : NO;
        self->_speedSegmentView.hidden = self->_speedButton.hidden;
        self.markableProgressView.hidden = sender.selectedIndex == 0 ? YES : NO;
        
        if (sender.selectedIndex == 0)
        {
            self->_speedSegmentView.hidden = YES;
        }
        else
        {
            //录制模式切换时根据按钮点击状态来判断是否隐藏
            self->_speedSegmentView.hidden = !self->_speedButton.selected;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)pinchAction:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        _zoomBeganVal = _cameraShower.camera.zoom;
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        _cameraShower.camera.zoom = _zoomBeganVal * sender.scale;
    }
}

- (void)exposureSliderValueChanged:(UISlider *)slider
{
    if (_cameraShower.recordState == lsqRecordStateNotStart)
    {
        [_cameraShower.camera setExposureBias:slider.value];
    }
}

- (void)speedSegmentValueChangeAction:(SpeedSegmentView *)sender
{
    lsqSpeedMode speedMode = _cameraShower.speedMode;

    switch (sender.selectedIndex)
    {
        case 0: // 极慢模式  原始速度 0.5 倍率
            speedMode = lsqSpeedMode_Slow2;
            break;
        case 1: // 慢速模式 原始速度 0.7 倍率
            speedMode = lsqSpeedMode_Slow1;
            break;
        case 2: // 标准模式 原始速度
            speedMode = lsqSpeedMode_Normal;
            break;
        case 3: // 快速模式 原始速度 1.5 倍率
            speedMode = lsqSpeedMode_Fast1;
            break;
        case 4: // 极快模式 原始速度 2.0 倍率
            speedMode = lsqSpeedMode_Fast2;
            break;
    }
    _cameraShower.speedMode = speedMode;
}

//重置所有美妆效果
- (void)resetAllCosmeticAction
{
    typeof(self)weakSelf = self;
    NSString *title = NSLocalizedStringFromTable(@"tu_美妆", @"VideoDemo", @"美妆");
    NSString *msg = NSLocalizedStringFromTable(@"tu_确定删除所有美妆效果?", @"VideoDemo", @"美妆");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LSQString(@"lsq_nav_cancel", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confimAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf->_cameraShower removeFaceCosmeticFilter];
        weakSelf->_beautyPanelView.resetCosmetic = YES;
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:confimAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - camera functions
// --------------------------------------------------
-(void)requestCameraPermission
{
    // 开启访问相机权限
    // 查看有没有相机访问权限
    [TuTSDeviceSettings checkAllowWithController:self
                                            type:TuDeviceSettingsCamera
                                       completed:^(TuDeviceSettingsType type, BOOL openSetting) {
        self->_isOpenSetting = openSetting;

        if (openSetting)
        {
            lsqLError(@"Can not open camera");
            return;
        }
        
        [self setupCamera];
        
        [self->_markableProgressView addPlaceholder:self->_cameraShower.minRecordingTime / self->_cameraShower.maxRecordingTime markWidth:4];
        
        self->_moreMenuView.disableFlashSwitching = (self->_cameraShower.camera.devicePosition == AVCaptureDevicePositionFront);

    }];
}

- (void)setupCamera
{
    _cameraShower = [[videoCameraShower alloc] initWithRootView:_cameraView];
    _cameraShower.delegate = self;

    _cameraShower.backgroundColor = [UIColor clearColor];
    _cameraShower.minRecordingTime = 3;  // 最小录制时长 单位秒
    _cameraShower.maxRecordingTime = 15; // 最大录制时长 单位秒
    _cameraShower.speedMode = lsqSpeedMode_Normal; // 设置视频速率 标准
    
//    _camera.waterMarkImage = [UIImage imageNamed:@"sample_watermark.png"];  // 设置水印，默认为空
//    _camera.waterMarkPosition = lsqWaterMarkBottomRight; // 设置水印图片的位置

    // 配置相机参数
    // 设置相机前后位置
    _cameraShower.camera.devicePosition = AVCaptureDevicePositionFront;

    // 设置相机输出画面的方向和镜像设置
    _cameraShower.camera.frontCameraOrientation = AVCaptureVideoOrientationPortrait;
    _cameraShower.camera.frontCameraMirrored = YES;
    _cameraShower.camera.backCameraOrientation = AVCaptureVideoOrientationPortrait;
    _cameraShower.camera.backCameraMirrored = NO;

    _cameraShower.camera.sessionPreset = AVCaptureSessionPresetHigh; // 摄像头分辨率模式
    _cameraShower.camera.fps = 30;

    _cameraShower.camera.enableZoom = YES; // 是否支持双指缩放来调节焦距
    
    [_cameraShower.camera prepare];
    
    _cameraShower.camera.delegate = self;
    
    [_cameraShower.camera startPreview];
    
    _focusTouchView.camera = _cameraShower.camera;
     
    _ratioType = lsqRatioOrgin;
}

- (void)startRecording
{
    [_cameraShower startRecording];
}

- (void)pauseRecording
{
    [_cameraShower pauseRecording];
}

- (void)finishRecording
{
    [_cameraShower finishRecording];
}

- (void)cancelRecording
{
    [_cameraShower cancelRecording];
}

- (void)undoLastRecordedFragment
{
    // 删除最后一段录制的视频片段
    [_cameraShower popMovieFragment];
}


#pragma mark - TuCameraDelegate
// --------------------------------------------------
- (void)onTuCameraStatusChanged:(TuCameraState)status camera:(TuCamera *)camera
{
    // 相机状态回调
    switch (status)
    {
        case TuCameraState_START:
            NSLog(@"TuSDKRecordVideoCamera state: 相机正在启动");
            break;
            
        case TuCameraState_PAUSE_PREVIEW:
            NSLog(@"TuSDKRecordVideoCamera state: 相机录制暂停");
            break;
            
        case TuCameraState_START_PREVIEW:
        {
            NSLog(@"TuSDKRecordVideoCamera state: 相机启动完成");
            _exposureSlider.value = 0.5;

            if (_ratioType == lsqRatioOrgin)
            {
                [_cameraShower setRatioType:lsqRatioOrgin];
            }

            // 添加默认特效， 必须在相机开始预览之后。
            [_beautyPanelView enablePlastic:YES];
            [_beautyPanelView enableSkin:YES mode:TuSkinFaceTypeBeauty];
        }
            break;
            
        case TuCameraState_PREPARE_SHOT:
            NSLog(@"TuSDKRecordVideoCamera state: 相机正在拍摄");
            break;
            
        case TuCameraState_STOP:
            NSLog(@"TuSDKRecordVideoCamera state: 相机停止");
            break;
            
        case TuCameraState_SHOTED:
            NSLog(@"TuSDKRecordVideoCamera state: 相机拍摄完成");
            break;
            
        default:
            break;
    }
}

#pragma mark - TuFocusTouchViewDelegate
// --------------------------------------------------
- (BOOL)focusTouchView:(TuFocusTouchViewBase *)focusTouchView didTapPoint:(CGPoint)point
{
    if (_currentTopPanelView
        || _currentBottomPanelView
        || _speedSegmentView.hidden == NO)
    {
        //点击去除所有叠层面板
//        _currentTopPanelView.sender.selected = NO;
//        _currentBottomPanelView.sender.selected = NO;
        self.currentBottomPanelView = nil;
        self.currentTopPanelView = nil;
//        _speedSegmentView.hidden = YES;
//        _speedSegmentView.sender.selected = NO;
        
        //重置按钮的选中状态
        [self resetAllBtnStatus];
        
        return NO;
    }
    else
    {
        _exposureSlider.value = 0.5;
        [_cameraShower.camera setExposureBias:0.5];

        return YES;
    }
}

//重置按钮的选中状态
- (void)resetAllBtnStatus
{
    _beautyButton.selected = _moreButton.selected = NO;
}

#pragma mark - UISwipeGestureRecognizer
- (IBAction)leftSwipeAction:(UISwipeGestureRecognizer *)sender
{
    
    [_filterPanelView swipeToNextFilter];
}

- (IBAction)rightSwipeAction:(UISwipeGestureRecognizer *)sender
{
    
    [_filterPanelView swipeToLastFilter];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 当美颜面板出现时则禁用左滑、右滑手势
    if (_beautyPanelView.isHidden == NO)
    {
        return NO;
    }
    
    // 在滤镜面板上禁止滑动
    if ([_filterPanelView.layer containsPoint:[touch locationInView:_filterPanelView]])
    {
        return NO;
    }
    
    return YES;
}


#pragma mark - CameraMoreMenuViewDelegate
// --------------------------------------------------
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSelectedRatio:(CGFloat)ratio
{
    lsqRatioType ratioType = lsqRatioOrgin;
    if (ratio == 0.0f)
    {
        ratioType = lsqRatioOrgin;
    }
    else if (ratio == 0.75f)
    {
        ratioType = lsqRatio_3_4;
    }
    else if (ratio == 1.0f)
    {
        ratioType = lsqRatio_1_1;
    }
    
    _ratioType = ratioType;
    
    [_cameraShower setRatioType:ratioType];
}

- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchAutoFocus:(BOOL)autoFocus
{
    _cameraShower.camera.enableAutoFocus = autoFocus;
}

- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchFlashMode:(BOOL)enableFlash
{    
    if (enableFlash)
    {
        [_cameraShower.camera setFlashMode:AVCaptureFlashModeOn];
        [_cameraShower.camera setTorchMode:AVCaptureTorchModeOn];
    }
    else
    {
        [_cameraShower.camera setFlashMode:AVCaptureFlashModeOff];
        [_cameraShower.camera setTorchMode:AVCaptureTorchModeOff];
    }
}

- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchPitchType:(lsqSoundPitch)pitchType
{
    [_cameraShower setPitchMode:pitchType];
}


#pragma mark - TuFilterPanelViewDelegate
// --------------------------------------------------
- (SelesParameters *)tuFilterPanelView:(TuFilterPanelView *)panelView didSelectedFilterCode:(NSString *)code
{
    SelesParameters *params = [_cameraShower changeFilter:code];
    
    NSString *filterCode = [NSString stringWithFormat:@"lsq_filter_%@", code];
    
    _filterNameLabel.text = NSLocalizedStringFromTable(filterCode, @"TuSDKConstants", @"无需国际化");
    
    [self updateFilterNameStatus];
    
    return params;
}


#pragma mark - TuBeautyPanelViewDelegate
// --------------------------------------------------
- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enablePlastic:(BOOL)enable
{
    // 哈哈镜移除
    [_cameraShower removeFaceMonsterFilter];

    if (enable)
    {
        SelesParameters *params = [TuBeautyPanelConfig defaultPlasticParameters];
        SelesParameters *palsticParams = [_cameraShower addFacePlasticFilter:params];
        return palsticParams;
    }
    else
    {
        [_cameraShower removeFacePlasticFilter];
        return nil;
    }
}

- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enableExtraPlastic:(BOOL)enable
{
    // 哈哈镜移除
    [_cameraShower removeFaceMonsterFilter];

    if (enable)
    {
        SelesParameters *params = [TuBeautyPanelConfig defaultPlasticExtraParameters];
        SelesParameters *palsticExtraParams = [_cameraShower addFacePlasticExtraFilter:params];
        return palsticExtraParams;
    }
    else
    {
        [_cameraShower removeFacePlasticExtraFilter];
        return nil;
    }
}

- (void)tuBeautyPanelView:(TuBeautyPanelView *)view plasticdidSelectCode:(NSString *)code
{
    // 哈哈镜移除
    [_stickerPanelView enableStickers:YES];
}


- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode
{
    if (enable)
    {
        SelesParameters *params = [TuBeautyPanelConfig defaultSkinParameters:mode];
        {
            SelesParameters *preParams = [_beautyPanelView skinParams];
            if (preParams)
            {
                [params setArgWithKey:@"smoothing" precent:[preParams argWithKey:@"smoothing"].value];
                [params setArgWithKey:@"whitening" precent:[preParams argWithKey:@"whitening"].value];
                
                SelesParameterArg *ruddyOrSharpenArg = [params argWithKey:@"ruddy"];
                if (ruddyOrSharpenArg == Nil)
                {
                    ruddyOrSharpenArg = [params argWithKey:@"sharpen"];
                }
                
                if (ruddyOrSharpenArg)
                {
                    SelesParameterArg *preRuddyOrSharpenArg = [preParams argWithKey:@"ruddy"];
                    if (preRuddyOrSharpenArg == Nil)
                    {
                        preRuddyOrSharpenArg = [preParams argWithKey:@"sharpen"];
                    }
                    
                    if (preRuddyOrSharpenArg)
                    {
                        ruddyOrSharpenArg.value = preRuddyOrSharpenArg.value;
                    }
                }
            }
        }
        SelesParameters *skinParams = [_cameraShower addFaceSkinBeautifyFilter:params type:mode];
        
        switch (mode) {
            case TuSkinFaceTypeNatural:
                _filterNameLabel.text = NSLocalizedStringFromTable(@"lsq_filter_set_skin_precision", @"TuSDKConstants", @"无需国际化");
                break;
            case TuSkinFaceTypeMoist:
                _filterNameLabel.text = NSLocalizedStringFromTable(@"lsq_filter_set_skin_extreme", @"TuSDKConstants", @"无需国际化");
                break;
            case TuSkinFaceTypeBeauty:
                _filterNameLabel.text = NSLocalizedStringFromTable(@"lsq_filter_set_skin_beauty", @"TuSDKConstants", @"无需国际化");
                break;
            default:
                break;
        }
        [self updateFilterNameStatus];
        
        return skinParams;
    }
    else
    {
        [_cameraShower removeFaceSkinBeautifyFilter];
        return nil;
    }
}

- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enableCosmetic:(BOOL)enable isAskPop:(BOOL)isAskPop
{
    // 哈哈镜移除
//    [_cameraShower removeFaceMonsterFilter];

    if (enable)
    {
        SelesParameters *params = [TuBeautyPanelConfig defaultCosmeticParameters];
        SelesParameters *cosmeticParams = [_cameraShower addFaceCosmeticFilter:params];
        return cosmeticParams;
    }
    else
    {
        if (isAskPop)
        {
            //清除所有美妆效果
            [self resetAllCosmeticAction];
        }
        else
        {
            [_cameraShower removeFaceCosmeticFilter];
            _beautyPanelView.resetCosmetic = YES;
        }
        return nil;
    }
}

- (void)tuBeautyPanelView:(TuBeautyPanelView *)view cosmeticParamCode:(NSString *)code enable:(BOOL)enable
{
    // 哈哈镜移除
//    [_stickerPanelView removeStickers];

    [_cameraShower updateCosmeticParam:code enable:enable];
}

- (void)tuBeautyPanelView:(TuBeautyPanelView *)view cosmeticParamCode:(NSString *)code value:(NSInteger)value
{
    // 哈哈镜移除
//    [_stickerPanelView removeStickers];

    [_cameraShower updateCosmeticParam:code value:value];
}


#pragma mark - TuStickerPanelViewDelegate
- (void)stickerPanelView:(TuStickerPanelView *)panelView didSelectItem:(__kindof TuStickerBaseData *)categoryItem;
{
    //哈哈镜移除
    [_stickerPanelView enableStickers:NO];

    //动态贴纸和哈哈镜不能同时存在
    if ([categoryItem isKindOfClass:[TuMonsterData class]])
    {
        // 微整形移除
        [_beautyPanelView enablePlastic:NO];
        [_beautyPanelView enableExtraPlastic:NO];
//        [_cameraShower removeFacePlasticFilter];
//        [_cameraShower removeFacePlasticExtraFilter];
        // 美妆移除
//        [_beautyPanelView enableCosmetic:NO];
//        [_cameraShower removeFaceCosmeticFilter];
        //贴纸移除
        [_cameraShower removeStickerFilter];
        
        TuMonsterData *monsterData = (TuMonsterData *)categoryItem;
        [_cameraShower addFaceMonsterFilter:(TuSDKMonsterFaceType)[((NSNumber *)monsterData.item) unsignedIntValue]];
    }
    else
    {
        TuStickerGroup *item = (TuStickerGroup *)categoryItem.item;
        if (item)
        {
            [_cameraShower addStickerFilter:item];
        }
    }
}

- (void)stickerPanelView:(TuStickerPanelView *)panelView unSelectItem:(__kindof TuStickerBaseData *)categoryItem;
{
    //贴纸移除
    [_cameraShower removeStickerFilter];
    //哈哈镜移除
    [_cameraShower removeFaceMonsterFilter];
}

- (void)stickerPanelView:(TuStickerPanelView *)panelView didRemoveItem:(__kindof TuStickerBaseData *)categoryItem;
{
    //[[TuViews shared].messageHub showToast:@"贴纸删除"];
}

- (void)stickerPanelViewHidden:(TuStickerPanelView *)panelView;
{
    //[[TuViews shared].messageHub showToast:@"贴纸页面隐藏"];
}


#pragma mark - RecordButtonDelegate
// --------------------------------------------------
- (void)recordButtonDidTouchDown:(RecordButton *)sender
{
    switch ([_captureButton getRecordStyle])
    {
        case RecordButtonStyle_PhotoCapture:
            sender.selected = YES;
            break;
            
        case RecordButtonStyle_LongPressRecord:
        {
            if ([_cameraShower getRecordingProgress] < 1.0f)
            {
                sender.selected = YES;

                [self startRecording];
                [self hideViewsWhenRecording];

                _moreMenuView.disableRatioSwitching = YES;
            }
            else
            {
                NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is more than %lu seconds", (unsigned long)[_cameraShower maxRecordingTime]]
                                                     code:lsqRecordVideoErrorMoreMaxDuration
                                                 userInfo:nil];
                
                [self recordFailedWithError:error];
            }
        }
            break;
            
        case RecordButtonStyle_TapRecord:
        {
            if ([_cameraShower getRecordingProgress] < 1.0f)
            {
                BOOL isSelected = sender.selected;
                if (!isSelected)
                {
                    [self startRecording];
                    [self hideViewsWhenRecording];
                }
                else
                {
                    [self pauseRecording];
                    [self showViewsWhenPauseRecording];
                }
                
                sender.selected = !isSelected;
                
                _moreMenuView.disableRatioSwitching = YES;
            }
            else
            {
                NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is more than %lu seconds", (unsigned long)[_cameraShower maxRecordingTime]]
                                                     code:lsqRecordVideoErrorMoreMaxDuration
                                                 userInfo:nil];
                
                [self recordFailedWithError:error];
            }
        }
            break;
            
        default:
            break;
    }
      
}

- (void)recordButtonDidTouchEnd:(RecordButton *)sender
{
    switch ([_captureButton getRecordStyle])
    {
        case RecordButtonStyle_PhotoCapture:
        {
            sender.selected = NO;
              
            _capturedPhoto = [_cameraShower getCaptureImage];

            if (_capturedPhoto)
            {
                PhotoCaptureConfirmView *confirmView = [[PhotoCaptureConfirmView alloc] initWithFrame:self.view.bounds];
                
                confirmView.photoView.image = _capturedPhoto;
                confirmView.photoRatio = 1.0;
                [confirmView.doneButton addTarget:self action:@selector(photoCaptureViewSaveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [confirmView.backButton addTarget:self action:@selector(photoCaptureViewCancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
                _photoCaptureConfirmView = confirmView;

                [self.view addSubview:confirmView];
                [confirmView show];
            }
        }
            break;
            
        case RecordButtonStyle_LongPressRecord:
        {
            if ([_cameraShower getRecordingProgress] < 1.0f)
            {
                sender.selected = NO;

                [self pauseRecording];
                [self showViewsWhenPauseRecording];
            }
        }
            break;
            
        case RecordButtonStyle_TapRecord:
            break;
            
        default:
            break;
    }
}

- (void)photoCaptureViewSaveButtonAction:(UIButton *)sender
{
    // 保存到相册
    [TuTSAssetsManager saveWithImage:_capturedPhoto compress:0 metadata: nil toAblum:nil completionBlock:^(id<TuTSAssetInterface> asset, NSError *error)
    {
        if (!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_capturedPhoto = nil;
                [[TuViews shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];
            });
        }
    } ablumCompletionBlock:nil];
    
    [_photoCaptureConfirmView hideWithCompletion:^{
        [self->_photoCaptureConfirmView removeFromSuperview];
        [self showViewsWhenPauseRecording];
    }];
}

- (void)photoCaptureViewCancelButtonAction:(UIButton *)sender
{
    [_photoCaptureConfirmView hideWithCompletion:^{
        [self->_photoCaptureConfirmView removeFromSuperview];
        [self showViewsWhenPauseRecording];
    }];
}


#pragma mark - TuSDKRecordVideoCameraDelegate
// --------------------------------------------------
- (void)recordStateChanged:(lsqRecordState)state
{
    if ([_captureButton getRecordStyle] == RecordButtonStyle_LongPressRecord
        || [_captureButton getRecordStyle] == RecordButtonStyle_TapRecord)
    {
        switch (state)
        {
            case lsqRecordStatePaused:
            {
//                [_markableProgressView pushMark];
                [self showViewsWhenPauseRecording];
            }
                break;

            case lsqRecordStateCanceled:
            {
                _moreMenuView.disableRatioSwitching = NO;
                [self showViewsWhenPauseRecording];
            }
                break;

            case lsqRecordStateSaveingCompleted:
                _moreMenuView.disableRatioSwitching = NO;
                _captureButton.selected = NO;
                break;

            default:
                break;
        }
    }

    switch (state)
    {
        case lsqRecordStateRecordingCompleted: // 录制完成
        {
            [_markableProgressView reset];
            [self updateRecordConfrimViewsDisplay];

            [[TuViews shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_完成录制", @"VideoDemo", @"完成录制")];
        }
            break;
            
        case lsqRecordStateRecording: // 正在录制
            break;
            
        case lsqRecordStatePaused: // 暂停录制
            NSLog(@"TuSDKRecordVideoCamera record state: 暂停录制");
            break;
            
        case lsqRecordStateCanceled: // 取消录制
        {
            [_markableProgressView reset];
            [self updateRecordConfrimViewsDisplay];
        }
            break;
            
        case lsqRecordStateSaveing: // 正在保存
        {
            NSLog(@"TuSDKRecordVideoCamera record state: 正在保存");
            [[TuViews shared].messageHub setStatus:NSLocalizedStringFromTable(@"tu_正在保存...", @"VideoDemo", @"正在保存...")];
        }
            break;
            
        default:
            break;
    }
}

- (void)recordProgressChanged:(CGFloat)progress durationTime:(CGFloat)durationTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.markableProgressView.progress = progress;
        if (progress >= 1.0)
        {
            [[TuViews shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_完成录制", @"VideoDemo", @"完成录制")];
        }
    });
}

- (void)recordFailedWithError:(NSError *)error
{
    switch (error.code)
    {
        case lsqRecordVideoErrorUnknow:
            [[TuViews shared].messageHub showError:NSLocalizedStringFromTable(@"tu_录制失败：未知原因失败", @"VideoDemo", @"录制失败：未知原因失败")];
            break;
            
        case lsqRecordVideoErrorSaveFailed: // 取消录制 同时 重置UI
        {
            [_markableProgressView reset];
            [self updateRecordConfrimViewsDisplay];

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

- (void)recordMarkPush
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self->_markableProgressView pushMark];
    });
}

- (void)recordMarkPop
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self->_markableProgressView popMark];
        [self updateRecordConfrimViewsDisplay];
    });
}

- (void)recordResult:(NSURL *)fileUrl
{
    // 进行自定义操作，例如保存到相册（系统方法）
    
    BOOL videoCompatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileUrl.path);
    //检查视频能否保存至相册
    if (videoCompatible)
    {
        UISaveVideoAtPathToSavedPhotosAlbum(fileUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    else
    {
        NSLog(@"该视频无法保存至相册");
    }
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        NSLog(@"保存视频失败：%@", error);
    }
    else
    {
        [[TuViews shared].messageHub showSuccess:NSLocalizedStringFromTable(@"tu_保存成功", @"VideoDemo", @"保存成功")];
        NSLog(@"保存视频成功");
    }
    
    // 删除录制临时文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:videoPath])
    {
        [fileManager removeItemAtURL:[NSURL URLWithString:videoPath] error:nil];
    }
    
    // 自动保存后设置为 恢复进度条状态
    [_markableProgressView reset];
    [self updateRecordConfrimViewsDisplay];
}


@end


