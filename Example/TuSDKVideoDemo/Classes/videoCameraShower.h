#import "TuSDKPulseCore/TuSDKPulseCore.h"
#import "TuCamera/TuCamera.h"
#import "TuViews/TuViews.h"
#import <TuSDKPulseFilter/TUPFPImage.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PipeThreadState)
{
    PipeThreadState_Init,
    PipeThreadState_SetRatio,
    PipeThreadState_Preview,
    PipeThreadState_AddFilter,
    PipeThreadState_DeleteFilter,

    PipeThreadState_Destory,
};


@protocol videoCameraShowerDelegate<NSObject>
- (void)recordStateChanged:(lsqRecordState)recordState;
- (void)recordProgressChanged:(CGFloat)progress durationTime:(CGFloat)durationTime;
- (void)recordFailedWithError:(NSError *)error;
- (void)recordResult:(NSURL *)fileUrl;
- (void)recordMarkPush;
- (void)recordMarkPop;


@end






@interface videoCameraShower : NSObject

@property(nonatomic, readonly) TuCamera *camera; // 相机接口
@property(nonatomic) CGRect displayRect; // 显示选区百分比
@property(nonatomic, strong) UIColor *backgroundColor; // 视频背景区域颜色
@property(nonatomic) lsqRatioType ratioType;

@property(nonatomic) CGFloat minRecordingTime; // 最小录制时长 单位秒
@property(nonatomic) CGFloat maxRecordingTime; // 最大录制时长 单位秒
@property(nonatomic) lsqSpeedMode speedMode; // 设置视频速率 默认：标准 [标准、慢速、极慢、快速、极快]
@property(nonatomic) lsqSoundPitch pitchMode;
@property(nonatomic, readonly) lsqRecordState recordState; // 录制状态

@property(nonatomic, weak) id<videoCameraShowerDelegate> delegate;



- (instancetype)initWithRootView:(UIView *)rootView;// 请求初始化

- (SelesParameters *)changeFilter:(NSString *)code; // 切换滤镜 [返回参数列表]

- (SelesParameters *)addFacePlasticFilter:(SelesParameters *)params;
- (void)removeFacePlasticFilter;

- (SelesParameters *)addFacePlasticExtraFilter:(SelesParameters *)params;
- (void)removeFacePlasticExtraFilter;

- (SelesParameters *)addFaceSkinBeautifyFilter:(SelesParameters *)params type:(TuSkinFaceType)type;
- (void)removeFaceSkinBeautifyFilter;

- (void)addFaceMonsterFilter:(TuSDKMonsterFaceType)type;
- (void)removeFaceMonsterFilter;

- (void)addStickerFilter:(TuStickerGroup *)stickerGroup;
- (void)removeStickerFilter;

- (SelesParameters *)addFaceCosmeticFilter:(SelesParameters *)params;
- (void)removeFaceCosmeticFilter;
- (void)updateCosmeticParam:(NSString *)code enable:(BOOL)enable;
- (void)updateCosmeticParam:(NSString *)code value:(NSInteger)value;


- (void)startRecording;
- (void)pauseRecording;
- (void)finishRecording;
- (void)cancelRecording;
- (void)popMovieFragment;

- (NSInteger)getRecordFragmentsCount;
- (CGFloat)getRecordingProgress;

- (UIImage *)getCaptureImage;

@end


NS_ASSUME_NONNULL_END
