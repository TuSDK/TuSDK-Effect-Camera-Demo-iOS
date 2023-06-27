//
//  TTViewController.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTViewController.h"
#import "TTPipeMediator.h"
#import "TTBeautyView.h"

#import "TTBeautyProxy.h"
#import <TuCamera/TuCamera.h>
#import <TuSDKPulseCore/TuSDKPulseCore.h>

#import "TTCameraView.h"
#import "PhotoCaptureConfirmView.h"
#import "MusicListController.h"
#import <TZImagePickerController.h>

@interface TTViewController () <TuCameraAudioDataOutputDelegate,
                                TuCameraVideoDataOutputDelegate,
                                TTCameraViewListener,
                                TTRecordListener,
                                RecordButtonDelegate,
                                MusicListDelegate,
                                TZImagePickerControllerDelegate,
                                CameraMoreMenuViewDelegate>

@property(nonatomic, strong) TuCamera *capture;
@property(nonatomic, strong) TTPipeMediator *mediator;
@property(nonatomic, strong) TTBeautyView *beautyView;
/// 相机视图
@property(nonatomic, strong) TTCameraView *cameraView;
/// 相机拍照结果展示页
@property(nonatomic, strong) PhotoCaptureConfirmView *photoCaptureView;
@property(nonatomic, assign) BOOL isTest;
/// 拍照显示图片
@property(nonatomic) UIImage *capturedPhoto;

/// 混音类型
@property(nonatomic, assign) TTAudioMixerMode audioMixMode;
/// 录制速率
@property(nonatomic, assign) TTVideoRecordSpeed recordSpeed;
/// 相机焦距数值
@property(nonatomic, assign) CGFloat zoomBeganVal;




@end

@implementation TTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recordSpeed = TTVideoRecordSpeed_NOMAL;
    _mediator = [[TTPipeMediator alloc] initWithContainer:self.view];
    //相机相关UI
    _cameraView = [[TTCameraView alloc] initWithFrame:self.view.bounds beautyTarget:[TTBeautyProxy transformObjc:_mediator]];    
    [_mediator setRecordDelegate:self];
    
    TTRecordManager *recordManager = [self.mediator getRecordManager];
    //最小录制时长，默认3000ms
    _cameraView.minRecordTime = recordManager.minDuration;
    //最大录制时长，默认15000ms
    _cameraView.maxRecordTime = recordManager.maxDuration;
    _cameraView.delegate = self;
    //设置录制按钮代理
    [_cameraView setRecordButtonDelegate:self];
    //设置更多页面代理
    [_cameraView setMoreMenuViewDelegate:self];
    //选择音乐点击事件
    [_cameraView.musicButton addTarget:self action:@selector(musicButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //合拍按钮点击事件
    [_cameraView.joinerEditButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
    //完成按钮点击事件
    [_cameraView.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //录制速率切换事件
    [_cameraView.speedSegmentView addTarget:self action:@selector(speedSegmentValueChangeAction:) forControlEvents:UIControlEventValueChanged];
    //设置相机对象
    _cameraView.focusTouchView.camera = _capture;

    [self.view addSubview:_cameraView];
    
    [self setupCapture];
    
    // 添加后台、前台切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackFromFront) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFrontFromBack) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminateAction) name:@"ApplicationwillTerminateAction" object:nil];
    //捏合手势
    UIPinchGestureRecognizer *zoomPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.view addGestureRecognizer:zoomPinch];
}


- (void)setupCapture {

    // 获取相册的权限
    [TuTSAssetsManager testLibraryAuthor:^(NSError *error) {
        if (error)
        {
            [TuTSAssetsManager showAlertWithController:self loadFailure:error];
        }
    }];
    
    AVAudioSession *asession = [AVAudioSession sharedInstance];
    [asession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [asession setActive:YES error:nil];
    
    _capture = [[TuCamera alloc] init];
    // 配置相机参数
    // 设置相机前后位置
    _capture.devicePosition = AVCaptureDevicePositionFront;

    // 设置相机输出画面的方向和镜像设置
    _capture.frontCameraOrientation = AVCaptureVideoOrientationPortrait;
    _capture.frontCameraMirrored = YES;
    _capture.backCameraOrientation = AVCaptureVideoOrientationPortrait;
    _capture.backCameraMirrored = NO;
    // 摄像头采集分辨率模式
    _capture.sessionPreset = AVCaptureSessionPresetHigh;
    //设置帧率
    _capture.fps = 30;
    // 是否支持双指缩放来调节焦距
    _capture.enableZoom = YES;
    
    _capture.audioDataOutputDelegate = self;
    _capture.videoDataOutputDelegate = self;
    
    [_capture prepare];
    
    //判断是否为前置摄像头
    _cameraView.isFrontDevicePosition = _capture.devicePosition == AVCaptureDevicePositionFront;
    //默认为全屏比例
    [_mediator setAspectRatio:TTVideoAspectRatio_full];
}

- (void)enterBackFromFront
{
    // 进入后台
    // 进入后台后取消录制，舍弃之前录制的信息
    if (_capture && _mediator) {
        [_capture stopPreview];
        //取消当前录制
        [[_mediator getRecordManager] cancleRecording];
    }
    // 关闭闪光灯
    _cameraView.moreMenuView.enableFlash = NO;
    _cameraView.isFrontDevicePosition = _capture.devicePosition == AVCaptureDevicePositionFront;
}

- (void)enterFrontFromBack
{
    //恢复前台
    if (_capture
        && _mediator
        && _capture.status != TuCameraState_START
        && _capture.status != TuCameraState_START_PREVIEW) {
        [_capture startPreview];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self->_capture resetAudioUnit];
        });
    }
    //重置页面
    [_cameraView resetCameraView];
}

- (void)willTerminateAction {
    [self.mediator destory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 相机启动预览
    [self.capture startPreview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 相机停止预览
    [self.capture pausePreview];
}
/**
 * 相机采集视频回调
 * @param sampleBuffer 相机采集返回的视频数据
 */
- (void)onTuCameraDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    //将相机采集到的Buffer传入meditor进行特效处理
    [self.mediator sendVideoSampleBuffer:sampleBuffer];
}
/**
 * 麦克风采集音频回调
 * @param sampleBuffer 麦克风采集返回的音频数据
 */
- (void)onTuCameraDidOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    //将麦克风采集到的Buffer传入meditor进行音频处理
    [self.mediator sendAudioSampleBuffer:sampleBuffer];
}
/**
 * 麦克风采集音频回调
 * @param bufferList 麦克风采集返回的音频数据
 */
- (void)onTuCameraDidOutputPlayBufferList:(AudioBufferList)bufferList {
    //将麦克风采集到的Buffer传入meditor进行音频处理
    [self.mediator sendAudioPlayBufferList:bufferList];
}

#pragma mark - TTRecordListener
/**
 * 当前录制进度更新
 * @param recordManager 录制功能类
 * @param milliSecond 录制进
 */
- (void)recordManager:(TTRecordManager *)recordManager progress:(NSInteger)milliSecond
{
    if (_cameraView) {
        CGFloat progress = 1.0 * milliSecond / recordManager.maxDuration;
        [_cameraView recordProgressChanged:progress];
        
    }
}

/**
 * 录制状态回调
 * @param recordManager 录制功能类
 * @param state 录制状态
 */
- (void)recordManager:(TTRecordManager *)recordManager  onRecordState:(TTRecordState)state
{
    if (_cameraView) {
        [_cameraView recordStateChanged:state];
    }
    if (state == TTRecordStateTimeout) {
        [self.mediator pauseRecord];
    }
}

/**
 * 录制完成
 * @param recordManager 录制功能类
 * @param videoPath 视频路径
 */
- (void)recordManager:(TTRecordManager *)recordManager didFinish:(NSURL *)videoPath;
{
    //录制完成保存到相册
    [self saveToPhotosAlbum:videoPath];
}



#pragma mark - TTCameraViewListener
/**
 * 设置曝光强度
 * @param cameraView 相机视图
 * @param value 曝光强度数值
 */
- (void)cameraView:(TTCameraView *)cameraView setExposureBiasValue:(CGFloat)value;
{
    [self.capture setExposureBias:value];
}
/**
 * 设置音频混音类型
 * @param cameraView 相机视图
 * @param music 音乐名称
 */
- (void)cameraView:(TTCameraView *)cameraView setMusicName:(NSString *)music
{
    [self addAudioMixer:music];
}

/**
 * 设置画面比例
 * @param cameraView 相机视图
 * @param aspectRatio 画面比例
 */
- (void)cameraView:(TTCameraView *)cameraView setAspectRatio:(TTVideoAspectRatio)aspectRatio;
{
    if (_mediator) {
        [_mediator setAspectRatio:aspectRatio];
    }
}

/**
 * 根据事件类型实现相应的方法
 * @param cameraView 相机视图
 * @param methodStyle 事件类型
 */
- (void)cameraView:(TTCameraView *)cameraView method:(TTMethodStyle)methodStyle;
{
    switch (methodStyle) {
        case TTMethodShowJoiner:
        {
            //显示合拍
            [self showImagePicker];
        }
            break;
        case TTMethodRemoveJoiner:
        {
            //移除合拍
            [[self.mediator getBeautyManager] removeEffect:TTEffectTypeJoiner];
        }
            break;
        case TTMethodRemoveLastRecordPart:
        {
            //回删最后一个片段
            if (_mediator) {
                [_mediator deleteLastRecordPart];
            }
        }
            break;
        case TTMethodRotateCamera:
        {
            //切换摄像头
            [self.capture rotateCamera];
        }
            break;
        default:
            break;
    }
}

// MARK: - method
//切换录制速率
- (void)speedSegmentValueChangeAction:(SpeedSegmentView *)sender
{
    TTVideoRecordSpeed speed = TTVideoRecordSpeed_NOMAL;
    switch (sender.selectedIndex) {
        case 0: // 极慢模式  原始速度 0.5 倍率
            speed = TTVideoRecordSpeed_SLOWEST;
            break;
        case 1: // 慢速模式 原始速度 0.7 倍率
            speed = TTVideoRecordSpeed_SLOW;
            break;
        case 2: // 标准模式 原始速度
            speed = TTVideoRecordSpeed_NOMAL;
            break;
        case 3: // 快速模式 原始速度 1.5 倍率
            speed = TTVideoRecordSpeed_FAST;
            break;
        case 4: // 极快模式 原始速度 2.0 倍率
            speed = TTVideoRecordSpeed_FASTEST;
            break;
    }
    if (speed == _recordSpeed) return;
    [_mediator setRecordSpeed:speed];
    _recordSpeed = speed;
}

/// 录制完成
- (void)doneButtonAction:(UIButton *)sender
{
    //获取当前录制时间
    //如果当前录制时间小于最小录制时间，则弹窗提示
    CGFloat currentRecordTime = _cameraView.markableProgressView.progress * _cameraView.maxRecordTime;
    if (currentRecordTime < _cameraView.minRecordTime) {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is less than %lu seconds", (unsigned long)_cameraView.minRecordTime / 1000]
                                    code:lsqRecordVideoErrorLessMinDuration
                                userInfo:nil];
        [_cameraView recordFailedWithError:error];
        return;
    }
    
    if (_mediator) {
        // 结束录制
        [_mediator stopRecord];
        
        //录制完成更新UI片段
        [_cameraView updateRecordViewsDisplay];
    }
}

- (void)addAudioMixer:(NSString *)musicName {
    if ([musicName isEqualToString:NSLocalizedStringFromTable(@"tu_选择音乐", @"VideoDemo", @"选择音乐")]) {
        
        self.audioMixMode = TTAudioMixerMode_None;
        //停止播放
        //stopBGM
    } else {
        //设置背景音乐
        NSString *path = [[NSBundle mainBundle] pathForResource:musicName ofType:@"mp3"];

        self.audioMixMode = TTAudioMixerMode_Music;
        
        [_mediator setBGM:path];
    }
}

- (void)setAudioMixMode:(TTAudioMixerMode)audioMixMode
{
    _audioMixMode = audioMixMode;
    [self.capture audioUnitRecord:(audioMixMode != TTAudioMixerMode_None)];
}

/// 调节相机焦距
- (void)pinchAction:(UIPinchGestureRecognizer *)sender
{
    //先判断是否开启调节焦距开关
    if (!_capture.enableZoom) return;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        _zoomBeganVal = _capture.zoom;
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        _capture.zoom = _zoomBeganVal * sender.scale;
    }
}

// MARK: - RecordButtonDelegate
/// 录制按钮按下状态
- (void)recordButtonDidTouchDown:(RecordButton *)sender
{
    //获取当前录制按钮状态
    RecordButtonStyle style = [_cameraView.captureButton getRecordStyle];
    switch (style) {
        case RecordButtonStyle_PhotoCapture:
            sender.selected = YES;
            break;
            
        default:
        {
            //判断当前录制进度是否为最大
            if ([_mediator getRecordingProgress] < 1.0f) {
                BOOL isSelected = sender.selected;
                if (!isSelected) {
                    //开始录制
                    
                    if (_audioMixMode != TTAudioMixerMode_None) {
                        [_capture startAudioUnit];
                    }
                    [_mediator startRecording];
                    
                    [_cameraView hideViewsWhenRecording];
                    [_cameraView moreJoinerDisable:YES];
                } else {
                    //暂停录制
                    [_mediator pauseRecord];
                    [_cameraView showViewsWhenPauseRecording];
                    [_cameraView moreJoinerDisable:NO];
                }
                
                sender.selected = !isSelected;
                
                //禁用比例切换
                _cameraView.moreMenuView.disableRatioSwitching = YES;
            } else {
                NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is more than %lu seconds", (unsigned long)[_mediator getRecordingProgress]]
                                                     code:lsqRecordVideoErrorMoreMaxDuration
                                                 userInfo:nil];
                [_cameraView recordFailedWithError:error];
            }
        }
            break;
    }
}

/// 录制按钮抬起状态
- (void)recordButtonDidTouchEnd:(RecordButton *)sender
{
    //获取当前录制按钮状态
    RecordButtonStyle style = [_cameraView.captureButton getRecordStyle];
    switch (style) {
        case RecordButtonStyle_PhotoCapture:
        {
            sender.selected = NO;
            //获取拍照图像
            _capturedPhoto = [_mediator snapshot];
            
            if (_capturedPhoto) {
                //弹出展示视图
                self.photoCaptureView = [[PhotoCaptureConfirmView alloc] initWithFrame:self.view.bounds];
                self.photoCaptureView.photoView.image = _capturedPhoto;
                self.photoCaptureView.photoRatio = 1.0;
                [self.photoCaptureView.doneButton addTarget:self action:@selector(photoCaptureViewSaveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.photoCaptureView.backButton addTarget:self action:@selector(photoCaptureViewCancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:self.photoCaptureView];
                [self.photoCaptureView show];
            }
        }
            break;
            
        default:
            break;
    }
}

/// 照片保存到相册成功
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
        } else {
            
        }
    } ablumCompletionBlock:nil];
    
    [_photoCaptureView hideWithCompletion:^{
        [self->_photoCaptureView removeFromSuperview];
        [self->_cameraView showViewsWhenPauseRecording];
    }];
}

/// 照片保存到相册失败
- (void)photoCaptureViewCancelButtonAction:(UIButton *)sender
{
    [_photoCaptureView hideWithCompletion:^{
        [self->_photoCaptureView removeFromSuperview];
        [self->_cameraView showViewsWhenPauseRecording];
    }];
}

// MARK: - CameraMoreMenuViewDelegate
//设置屏幕比例
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSelectedRatio:(CGFloat)ratio
{
    TTVideoAspectRatio ratioType = TTVideoAspectRatio_full;
    if (ratio == 0)
    {
        ratioType = TTVideoAspectRatio_full;
    }
    else if (ratio == 1)
    {
        ratioType = TTVideoAspectRatio_3_4;
    }
    else if (ratio == 2)
    {
        ratioType = TTVideoAspectRatio_1_1;
    }

    if (_mediator) {
        [_mediator setAspectRatio:ratioType];
    }
}

//设置是否自动聚焦
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchAutoFocus:(BOOL)autoFocus
{
    [self.capture setEnableAutoFocus:autoFocus];
}
//设置是闪光灯
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchFlashMode:(BOOL)enableFlash
{
    if (enableFlash) {
        [self.capture setFlashMode:AVCaptureFlashModeOn];
        [self.capture setTorchMode:AVCaptureTorchModeOn];
    } else {
        [self.capture setFlashMode:AVCaptureFlashModeOff];
        [self.capture setTorchMode:AVCaptureTorchModeOff];
    }
}
//设置变声类型
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchPitchType:(TTVideoSoundPitchType)pitchType
{
//    TTVideoSoundPitchType soundPitchType = TTVideoSoundPitchType_Normal;
//    switch (pitchType) {
//        case lsqSoundPitchNormal:   //正常
//            soundPitchType = TTVideoSoundPitchType_Normal;
//            break;
//        case lsqSoundPitchMonster:  //怪兽
//            soundPitchType = TTVideoSoundPitchType_Monster;
//            break;
//        case lsqSoundPitchUncle:    //大叔
//            soundPitchType = TTVideoSoundPitchType_Uncle;
//            break;
//        case lsqSoundPitchGirl:     //女生
//            soundPitchType = TTVideoSoundPitchType_Girl;
//            break;
//        case lsqSoundPitchLolita:   //萝莉
//            soundPitchType = TTVideoSoundPitchType_Lolita;
//            break;
//    }
    if (_mediator) {
        [_mediator setSoundPitchType:pitchType];
    }
}

/// 更新合拍布局
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchJoinerMode:(TTJoinerDirection)joinerDirection {
    
    TTJoinerDirection direction = _cameraView.moreMenuView.currentJoinerDirection;
    
    [[self.mediator getBeautyManager] updateJoinerDirection:direction];
    CGRect videoRect = [[self.mediator getBeautyManager] getJoinerVideoRect];
    [_cameraView refreshJoinerRect:videoRect];
}

//是否开启麦克风
- (void)moreMenu:(CameraMoreMenuView *)moreMenu didSwitchMicrophoneMode:(BOOL)enableMic {
    
    if (_mediator) {
        [_mediator setMute:!enableMic];
    }
}


// MARK: - save album
/**
 * 保存到相册
 * @param videoPath 视频沙盒路径
 */
- (void)saveToPhotosAlbum:(NSURL *)videoPath;
{
    // 进行自定义操作，例如保存到相册（系统方法）
    BOOL videoCompatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath.path);
    //检查视频能否保存至相册
    if (videoCompatible)
    {
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
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
    [_cameraView updateRecordViewsDisplay];
}

// MARK: - music method
- (void)musicButtonAction:(UIButton *)sender
{
    //弹出音乐列表
    MusicListController *ctrl = [[MusicListController alloc] init];
    ctrl.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    ctrl.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    ctrl.defaultMusicName = _cameraView.musicButton.titleLabel.text;
    ctrl.delegate = self;
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)controller:(MusicListController *)controller didSelectedAtItem:(NSString *)musicName {
    [controller dismiss];
    NSString *item = musicName;
    if ([musicName isEqualToString:@"无"]) {
        item = NSLocalizedStringFromTable(@"tu_选择音乐", @"VideoDemo", @"选择音乐");
        
    }
    [_cameraView.musicButton setTitle:item forState:UIControlStateNormal];
    
    [self addAudioMixer:item];
}

// MARK: - JoinerPicker 合拍控制器
#pragma mark - TZImagePickerController、TZImagePickerControllerDelegate
/// 展示相册选择器
- (void)showImagePicker
{
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePicker.allowPickingImage = NO;
    imagePicker.allowPickingVideo = YES;
    imagePicker.allowTakeVideo = NO;
    imagePicker.allowTakePicture = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset
{
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
#warning 视频URL路径为null
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        NSInteger duration = CMTimeGetSeconds(urlAsset.duration);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (duration > self->_cameraView.maxRecordTime) {
                self->_cameraView.maxRecordTime = duration;
                [self->_cameraView.markableProgressView addPlaceholder:self->_cameraView.minRecordTime / self->_cameraView.maxRecordTime markWidth:4];
            }
        });
        //默认左右布局
        TTJoinerDirection joinerDirection = self->_cameraView.moreMenuView.currentJoinerDirection;
        self.audioMixMode = TTAudioMixerMode_Joiner;
        //设置合拍
        [self.mediator setJoiner:joinerDirection videoPath:urlAsset.URL.absoluteString];
        
        CGRect videoRect = [[self.mediator getBeautyManager] getJoinerVideoRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_cameraView refreshJoinerRect:videoRect];
        });
        
    }];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
    /// 取消合拍时更新录制按钮状态
    [_cameraView cancelJoinerUpdateRecordState];
}

// MARK: - dealloc
- (void)dealloc {
    [self.mediator destory];
    [self.cameraView destoryView];
    NSLog(@"%@ dealloc", [self classForCoder]);
}



@end
