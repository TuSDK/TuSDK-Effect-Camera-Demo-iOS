#import "VideoCameraShower.h"
#import "TuSDKPulseCore.h"
#import "TuSDKPulse.h"
#import "TuSDKPulseFilter.h"
#import <AVFoundation/AVFoundation.h>

static NSInteger const kJoinerFilterIndex = 10000;
static NSInteger const kPitchProcessorIndex = 100;
//static NSInteger const kStretchProcessorIndex = 200;

@interface RecordFragment : NSObject
@property(nonatomic, strong) TUPFPFileExporter *exporter;
@property(nonatomic, strong) TUPFPFileExporter_Config *config;
@property(nonatomic) NSInteger videoTimeStart;
@property(nonatomic) NSInteger audioTimeStart;
@property(nonatomic) NSInteger timeDuration;
@property(nonatomic) NSInteger audioTimeDuration;
@property(nonatomic) bool isVideoConfiged;
@property(nonatomic) bool isAudioConfiged;

@end

@implementation RecordFragment
- (int)formatWidth:(int)width {
    if (width % 2 != 0) {
        return width + 1;
    } else {
        return width;
    }
}

@end


// Camera 接口相机渲染
@interface VideoCameraShower()<TuCameraVideoDataOutputDelegate,
                                TuCameraAudioDataOutputDelegate,
                                TuTSMotionDelegate,
                                SelesParametersListener>
{
    __weak TUPFPDisplayView *_displayView;
    TUPFPImage_CMSampleBufferCvt *_imgcvt;
    TUPFilterPipe *_pipeline;
    
    TUPFPImage* _pipeInImage;
    TUPFPImage* _pipeOutImage;
    NSLock *_pipeOutLock;
    
    TuTSAnimation *_displayViewAnimation;
    CGRect _displayViewRect;
    
    NSMutableArray<NSNumber *> *_filterChain; // 滤镜链[滤镜执行的先后顺序, 顺序改变会影响最终的效果。建议不要更改]
    NSMutableDictionary<NSNumber*, NSObject*> *_filterPropertys;

    
    dispatch_queue_t _audioProcessingQueue;

    TUPDispatchQueue *_pipeOprationQueue;
    void *_audioMixerData;
    NSMutableArray<RecordFragment *> *_recordFragments;
    
    TUPAudioPipe *_audioPipeline;
    void *_audioPipeData;
    void *_audioPipeQueueData;
}
@property (nonatomic, strong) TUPFPSimultaneouslyFilter_PropertyBuilder *joinerBuilder;
@property (nonatomic, strong) TUPFPAudioMixer_Config *audioMixerConfig;
@property (nonatomic, strong) TUPFPAudioMixer *audioMixer;
@property (nonatomic, strong) dispatch_queue_t audioMixerQueue;
@property (nonatomic, assign) BOOL startAudioMix;
@property (nonatomic, strong) TUPAudioStretchProcessor *stretchProcessor;
@property (nonatomic, strong) TUPAudioPitchProcessor *pitchProcessor;
@end


@implementation VideoCameraShower

- (instancetype)initWithRootView:(UIView *)rootView
{
    self = [super init];
    if (self)
    {
        _mixerMode = TTAudioMixerModeNone;
        _speedMode = lsqSpeedMode_Normal; // 设置视频速率 标准
        [self setup:rootView];
    }
    return self;
}

- (void)dealloc
{
    [_pipeOprationQueue runSync:^{
    
        if (self->_pipeline)
        {
            [self->_pipeline clearFilters];
            [self->_pipeline close];
            self->_pipeline = nil;
        }
        self->_imgcvt = nil;
        if (self->_audioPipeline) {
            [self->_audioPipeline close];
        }
    }];
    
    if (_displayView)
    {
        [_displayView teardown];
        _displayView = nil;
    }

    _camera = nil;
    [_audioMixer close];
    free(_audioMixerData);
    free(_audioPipeData);
    free(_audioPipeQueueData);
}
- (void)reset {
    [self removeAllFragments];
    if (self.mixerMode == TTAudioMixerModeJoiner) {
        [self updateJoinerPos:0];
    }
}
- (void)setup:(UIView *)rootView
{
    _pipeOprationQueue = [[TUPDispatchQueue alloc] initWithName:@"pipeOprationQueue"];
    
    _audioProcessingQueue = dispatch_queue_create("videorecord.audioProcessingQueue", DISPATCH_QUEUE_SERIAL);
//    _videoProcessingQueue = dispatch_queue_create("videorecord.videoProcessingQueue", DISPATCH_QUEUE_SERIAL);
    AVAudioSession *asession = [AVAudioSession sharedInstance];
    [asession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [asession setActive:YES error:nil];
    _minRecordingTime = 3;  // 最小录制时长 单位秒
    _maxRecordingTime = 15; // 最大录制时长 单位秒
    
    _recordState = lsqRecordStateNotStart;

    _recordFragments = [[NSMutableArray alloc] init];

    _filterChain = [[NSMutableArray alloc] init];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_None]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_ReshapeFace]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_CosmeticFace]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_MonsterFace]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_PlasticFace]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_SkinFace]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_StickerFace]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_Filter]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_Comic]];
    [_filterChain addObject:[NSNumber numberWithInteger:TuFilterModel_Ratio]];
    
    _filterPropertys = [NSMutableDictionary dictionary];

    _pipeOutLock = [[NSLock alloc] init];
    
    _camera = [[TuCamera alloc] init];
    _camera.videoDataOutputDelegate = self;
    _camera.audioDataOutputDelegate = self;
    
    [_pipeOprationQueue runSync:^{
        self->_imgcvt = [[TUPFPImage_CMSampleBufferCvt alloc] init];

        self->_pipeline = [[TUPFilterPipe alloc] init];
        [self->_pipeline open];
        self->_audioPipeline = [[TUPAudioPipe alloc] init];
        [self->_audioPipeline open:[TUPConfig new]];
    }];
    _audioPipeData = malloc(1024*4);
    _audioPipeQueueData = malloc(1024*8);
    TUPFPDisplayView* displayView = [[TUPFPDisplayView alloc] init];
    //displayView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [rootView addSubview:displayView];
    [displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(rootView);
    }];
//    [displayView.leadingAnchor constraintEqualToAnchor:rootView.leadingAnchor].active = YES;
//    [displayView.trailingAnchor constraintEqualToAnchor:rootView.trailingAnchor].active = YES;
//    [displayView.topAnchor constraintEqualToAnchor:rootView.topAnchor].active = YES;
//    [displayView.bottomAnchor constraintEqualToAnchor:rootView.bottomAnchor].active = YES;
    [rootView sendSubviewToBack:displayView];
    
    _displayViewRect = CGRectMake(0, 0, 1, 1);

    _displayView = displayView;
    [_displayView setup];
        
    
//    UILabel *technologyLabel = [[UILabel alloc] init];
//    technologyLabel.font = [UIFont systemFontOfSize:10];
//    technologyLabel.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
//    technologyLabel.text = @"Technology by TuSDK";
//    technologyLabel.frame = CGRectMake(5, CGRectGetMaxY(rootView.frame) - 20, 200, 20);
//    [rootView addSubview:technologyLabel];
    _pitchProcessor = [[TUPAudioPitchProcessor alloc] init];
    _stretchProcessor = [[TUPAudioStretchProcessor alloc] init];
}

- (void)setDisplayRect:(CGRect)displayRect
{
    _displayRect = displayRect;
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [_displayView setClearColor:backgroundColor];
}

- (NSInteger)FilterIndex:(TuFilterModel)filterModel
{
    NSInteger filterIndex = 0;

    if ([_filterChain containsObject:[NSNumber numberWithInteger:filterModel]])
    {
        filterIndex = [_filterChain indexOfObject:[NSNumber numberWithInteger:filterModel]];
    }
    
    return filterIndex;
}

- (CGFloat)getRatioByType:(TTRatioType)ratioType
{
    CGFloat ratio = 1.0f;
    switch (ratioType)
    {
        case TTRatio_1_1:
            ratio = 1.0f / 1.0f;
            break;
        case TTRatio_2_3:
            ratio = 2.0f / 3.0f;
            break;
        case TTRatio_3_4:
            ratio = 3.0f / 4.0f;
            break;
        case TTRatio_9_16:
            ratio = 9.0f / 16.0f;
            break;
        case TTRatio_3_2:
            ratio = 3.0f / 2.0f;
            break;
        case TTRatio_4_3:
            ratio = 4.0f / 3.0f;
            break;
        case TTRatio_16_9:
            ratio = 16.0f / 9.0f;
            break;

        case TTRatioOrgin:
        default:
            ratio = [[UIScreen mainScreen] bounds].size.width / [[UIScreen mainScreen] bounds].size.height;
            break;
    }
    
    return ratio;
}

- (void)setRatioType:(TTRatioType)ratioType
{
    CGFloat ratio = [self getRatioByType:ratioType];
    
    if (_camera)
    {
        CGFloat fullScreenRatio = [self getRatioByType:TTRatioOrgin];
        CGSize fullScreenSize = _camera.outputResolution;
        {
            CGSize cameraResolution = _camera.outputResolution;
            float cameraRatio = _camera.outputResolution.width / _camera.outputResolution.height;
            
            if (fullScreenRatio < cameraRatio)
            {
                fullScreenSize.height = cameraResolution.height;
                fullScreenSize.width = fullScreenSize.height * fullScreenRatio;
            }
            else
            {
                fullScreenSize.width = cameraResolution.width;
                fullScreenSize.height = fullScreenSize.width / fullScreenRatio;
            }
        }
        
        CGSize outputSize = fullScreenSize;
                
        if (ratio < fullScreenRatio)
        {
            outputSize.height = fullScreenSize.height;
            outputSize.width = outputSize.height * ratio;
        }
        else
        {
            outputSize.width = fullScreenSize.width;
            outputSize.height = outputSize.width / ratio;
        }
        
        if (_ratioType != ratioType)
        {
            CGFloat startRatio = [self getRatioByType:_ratioType];
            CGFloat completeRatio = ratio;

            CGSize startSize;
            CGSize completeSize = outputSize;
            
            if (startRatio < fullScreenRatio)
            {
                startSize.height = fullScreenSize.height;
                startSize.width = startSize.height * startRatio;
            }
            else
            {
                startSize.width = fullScreenSize.width;
                startSize.height = startSize.width / startRatio;
            }
            
            CGRect startRectNor = CGRectMake(0, 0, 1, 1);
            startRectNor.size.height = fullScreenRatio / startRatio;
            if (startRectNor.size.height != 1.0)
            {
                startRectNor.origin.y = 0.13;
            }
            
            CGRect completeRectNor = CGRectMake(0, 0, 1, 1);
            completeRectNor.size.height = fullScreenRatio / completeRatio;
            if (completeRectNor.size.height != 1.0)
            {
                completeRectNor.origin.y = 0.13;
            }
                             
            _displayViewAnimation = [TuTSAnimation animWithDuration:0.25 tween:[TuTweenQuadEaseOut tween] block:Nil];
            [_displayViewAnimation startWithBlock:^(TuTSAnimation *anim, NSTimeInterval step) {
                CGFloat progress = step;
                
                CGFloat x = startRectNor.origin.x + (completeRectNor.origin.x - startRectNor.origin.x) * progress;
                CGFloat y = startRectNor.origin.y + (completeRectNor.origin.y - startRectNor.origin.y) * progress;
                CGFloat w = startRectNor.size.width + (completeRectNor.size.width - startRectNor.size.width) * progress;
                CGFloat h = startRectNor.size.height + (completeRectNor.size.height - startRectNor.size.height) * progress;
                
                self->_displayViewRect = CGRectMake(x, y, w, h);

                CGFloat sw = startSize.width + (completeSize.width - startSize.width) * progress;
                CGFloat sh = startSize.height + (completeSize.height - startSize.height) * progress;
                [self->_imgcvt setOutputSize:CGSizeMake(sw, sh)];
            }];
        }
        
        _ratioType = ratioType;
    }
}

- (void)setSpeedMode:(lsqSpeedMode)speedMode {
    _speedMode = speedMode;
    if (_mixerMode == TTAudioMixerModeJoiner) {
        [self updateJoinerSpeed];
    }
    
//    [_pipeOprationQueue runSync:^{
//        if ([self->_audioPipeline getProcessor:kStretchProcessorIndex]) {
//            [self->_audioPipeline deleteProcessorAt:kStretchProcessorIndex];
//        }
//        TUPAudioProcessor *processor = [[TUPAudioProcessor alloc] init:[self->_audioPipeline getContext] withName:TUPAudioStretchProcessor_TYPE_NAME];
//        TUPConfig *config = [processor getConfig];
//        [config setDoubleNumber:[self getSpeed] forKey:TUPAudioStretchProcessor_CONFIG_STRETCH];
//        [processor setConfig:config];
//        [self->_audioPipeline add:processor atIndex:kStretchProcessorIndex];
//    }];
}
- (float)getSpeed
{
    float ret = 1.0f;
    
    switch (_speedMode)
    {
        case lsqSpeedMode_Normal:
            ret = 1.0f;
            break;
        case lsqSpeedMode_Fast1:
            ret = 0.75f;
            break;
        case lsqSpeedMode_Fast2:
            ret = 0.5f;
            break;
        case lsqSpeedMode_Slow1:
            ret = 1.5f;
            break;
        case lsqSpeedMode_Slow2:
            ret = 2.0f;
            break;

        default:
            break;
    }
    
    return ret;
}
- (float)getMixerSpeed
{
    float ret = 1.0f;
    
    switch (_speedMode)
    {
        case lsqSpeedMode_Normal:
            ret = 1.0f;
            break;
        case lsqSpeedMode_Fast1:
            ret = 1.5f;
            break;
        case lsqSpeedMode_Fast2:
            ret = 2.0f;
            break;
        case lsqSpeedMode_Slow1:
            ret = 0.75f;
            break;
        case lsqSpeedMode_Slow2:
            ret = 0.5f;
            break;

        default:
            break;
    }
    
    return ret;
}
- (void)setPitchMode:(lsqSoundPitch)pitchMode {
    _pitchMode = pitchMode;
    [_pipeOprationQueue runSync:^{
        if ([self->_audioPipeline getProcessor:kPitchProcessorIndex]) {
            [self->_audioPipeline deleteProcessorAt:kPitchProcessorIndex];
        }
        TUPAudioProcessor *processor = [[TUPAudioProcessor alloc] init:[self->_audioPipeline getContext] withName:TUPAudioPitchProcessor_TYPE_NAME];
        TUPConfig *config = [processor getConfig];
        [config setString:[self getPitch] forKey:TUPAudioPitchProcessor_CONFIG_TYPE];
        [processor setConfig:config];
        [self->_audioPipeline add:processor atIndex:kPitchProcessorIndex];
    }];
}
- (NSString *)getPitch {
    
    switch (_pitchMode) {
        case lsqSoundPitchNormal:
            return @"Normal";
        case lsqSoundPitchMonster:
            return @"Monster";
        case lsqSoundPitchUncle:
            return @"Uncle";
        case lsqSoundPitchGirl:
            return @"Girl";
        case lsqSoundPitchLolita:
            return @"Lolita";
        default:
            return @"Normal";
    }
}


#pragma mark - Filter Process Functions
// 滤镜添加删除功能列表 --------------------------------------------------
- (SelesParameters *)changeFilter:(NSString *)code
{
    NSString *filterCode = code;
    TuFilterModel filterModel = TuFilterModel_Filter;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    if ([filterCode isEqualToString:@"Normal"])
    {
        [_pipeOprationQueue runSync:^{
            if ([self->_pipeline getFilter:filterIndex])
            {
                [self->_pipeline deleteFilterAt:filterIndex];
            }
        }];
        
        // 无效果
        return nil;
    }
    
    // params
    SelesParameters *filterParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    TuFilterOption *filtrOption = [[TuFilterLocalPackage package] optionWithCode:filterCode];
    for (NSString *key in filtrOption.args)
    {
        NSNumber *val = [filtrOption.args valueForKey:key];
        [filterParams appendFloatArgWithKey:key value:val.floatValue];
    }
    filterParams.listener = self;


    // filter
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
        
        TUPFPFilter *filter = [[TUPFPFilter alloc] init:self->_pipeline.getContext withName:TUPFPTusdkImageFilter_TYPE_NAME];
        {
            TUPConfig *config = [[TUPConfig alloc] init];
            [config setString:filterParams.code forKey:TUPFPTusdkImageFilter_CONFIG_NAME];
            [filter setConfig:config];
        }
        [self->_pipeline addFilter:filter at:filterIndex];

        // property
        if (filterParams.count > 0)
        {
            TUPFPTusdkImageFilter_Type10PropertyBuilder *property = [[TUPFPTusdkImageFilter_Type10PropertyBuilder alloc] init];
            {
                property.strength = filterParams.args[0].value;
            }
            [filter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
            [self->_filterPropertys setObject:property forKey:@(filterModel)];
        }
    }];

    return filterParams;
}

- (SelesParameters *)addFacePlasticFilter:(SelesParameters *)params
{
    NSString *filterCode = TUPFPTusdkFacePlasticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_PlasticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    // params
    SelesParameters *filterParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    for (SelesParameterArg *arg in params.args)
    {
        
        
        [filterParams appendFloatArgWithKey:arg.key value:arg.value minValue:arg.minFloatValue maxValue:arg.maxFloatValue];
    }
    filterParams.listener = self;
    
    // Property
    TUPFPTusdkFacePlasticFilter_PropertyBuilder *property = [[TUPFPTusdkFacePlasticFilter_PropertyBuilder alloc] init];
    for (SelesParameterArg *arg in filterParams.args)
    {
        if ([arg.key isEqualToString:@"eyeSize"]) { property.eyeEnlarge = arg.value; }
        else if ([arg.key isEqualToString:@"chinSize"]) { property.cheekThin = arg.value; }
        else if ([arg.key isEqualToString:@"cheekNarrow"]) { property.cheekNarrow = arg.value; }
        else if ([arg.key isEqualToString:@"smallFace"]) { property.faceSmall = arg.value; }
        else if ([arg.key isEqualToString:@"noseSize"]) { property.noseWidth = arg.value; }
        else if ([arg.key isEqualToString:@"noseHeight"]) { property.noseHeight = arg.value; }
        else if ([arg.key isEqualToString:@"mouthWidth"]) { property.mouthWidth = arg.value; }
        else if ([arg.key isEqualToString:@"lips"]) { property.lipsThickness = arg.value; }
        else if ([arg.key isEqualToString:@"philterum"]) { property.philterumThickness = arg.value; }
        else if ([arg.key isEqualToString:@"archEyebrow"]) { property.browThickness = arg.value; }
        else if ([arg.key isEqualToString:@"browPosition"]) { property.browHeight = arg.value; }
        else if ([arg.key isEqualToString:@"jawSize"]) { property.chinThickness = arg.value; }
        else if ([arg.key isEqualToString:@"cheekLowBoneNarrow"]) { property.cheekLowBoneNarrow = arg.value; }
        else if ([arg.key isEqualToString:@"eyeAngle"]) { property.eyeAngle = arg.value; }
        else if ([arg.key isEqualToString:@"eyeInnerConer"]) { property.eyeInnerConer = arg.value; }
        else if ([arg.key isEqualToString:@"eyeOuterConer"]) { property.eyeOuterConer = arg.value; }
        else if ([arg.key isEqualToString:@"eyeDis"]) { property.eyeDistance = arg.value; }
        else if ([arg.key isEqualToString:@"eyeHeight"]) { property.eyeHeight = arg.value; }
        else if ([arg.key isEqualToString:@"forehead"]) { property.foreheadHeight = arg.value; }
        else if ([arg.key isEqualToString:@"cheekBoneNarrow"]) { property.cheekBoneNarrow = arg.value; }
    }
    [_filterPropertys setObject:property forKey:@(filterModel)];

    
    // filter
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
        TUPFPFilter *plasticFilter = [[TUPFPFilter alloc]init:[self->_pipeline getContext] withName:TUPFPTusdkFacePlasticFilter_TYPE_NAME];
        [self->_pipeline addFilter:plasticFilter at:filterIndex];
        [plasticFilter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
    
    return filterParams;
}

- (void)removeFacePlasticFilter
{
//    NSString *filterCode = TUPFPTusdkFacePlasticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_PlasticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
    }];
}


- (SelesParameters *)addFacePlasticExtraFilter:(SelesParameters *)params
{
    NSString *filterCode = TUPFPTusdkFaceReshapeFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_ReshapeFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    // params
    SelesParameters *filterParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    for (SelesParameterArg *arg in params.args)
    {
        [filterParams appendFloatArgWithKey:arg.key value:arg.value];
    }
    filterParams.listener = self;
    
    // Property
    TUPFPTusdkFaceReshapeFilter_PropertyBuilder *property = [[TUPFPTusdkFaceReshapeFilter_PropertyBuilder alloc] init];
    for (SelesParameterArg *arg in filterParams.args)
    {
        if ([arg.key isEqualToString:@"eyelid"]) { property.eyelidOpacity = arg.value; }
        else if ([arg.key isEqualToString:@"eyemazing"]) { property.eyemazingOpacity = arg.value; }
        else if ([arg.key isEqualToString:@"whitenTeeth"]) { property.whitenTeethOpacity = arg.value; }
        else if ([arg.key isEqualToString:@"eyeDetail"]) { property.eyeDetailOpacity = arg.value; }
        else if ([arg.key isEqualToString:@"removePouch"]) { property.removePouchOpacity = arg.value; }
        else if ([arg.key isEqualToString:@"removeWrinkles"]) { property.removeWrinklesOpacity = arg.value; }
    }
    [_filterPropertys setObject:property forKey:@(filterModel)];

    // filter
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
        TUPFPFilter *reshapeFilter = [[TUPFPFilter alloc]init:[self->_pipeline getContext] withName:filterCode];
        [self->_pipeline addFilter:reshapeFilter at:filterIndex];
        [reshapeFilter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
    
    return filterParams;
}

- (void)removeFacePlasticExtraFilter
{
//    NSString *filterCode = TUPFPTusdkFaceReshapeFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_ReshapeFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
    }];
}

- (SelesParameters *)addFaceSkinBeautifyFilter:(SelesParameters *)params type:(TuSkinFaceType)type
{
    NSString *filterCode = nil;
    TuFilterModel filterModel = TuFilterModel_SkinFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    switch (type)
    {
    case TuSkinFaceTypeNatural:
        filterCode = TUPFPTusdkImageFilter_NAME_SkinNatural;
        break;
    case TuSkinFaceTypeMoist:
        filterCode = TUPFPTusdkImageFilter_NAME_SkinHazy;
        break;
    case TuSkinFaceTypeBeauty:
    default:
        filterCode = TUPFPTusdkBeautFaceV2Filter_TYPE_NAME;
        break;
    }
    
    
    // params
    SelesParameters *filterParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    for (SelesParameterArg *arg in params.args)
    {
        [filterParams appendFloatArgWithKey:arg.key value:arg.value];
    }
    filterParams.listener = self;
    
    switch (type)
    {
        case TuSkinFaceTypeNatural:
        {
            TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder *property = [[TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder alloc] init];
            for (SelesParameterArg *arg in filterParams.args)
            {
                if ([arg.key isEqualToString:@"smoothing"]) { property.smoothing = arg.value; }
                else if ([arg.key isEqualToString:@"whitening"]) { property.fair = arg.value; }
                else if ([arg.key isEqualToString:@"ruddy"]) { property.ruddy = arg.value; }
            }
            [_filterPropertys setObject:property forKey:@(TuFilterModel_SkinFace)];
            
            TUPFPFilter* skinBeautifyFilter = [[TUPFPFilter alloc] init:_pipeline.getContext withName:TUPFPTusdkImageFilter_TYPE_NAME];
            {
                TUPConfig* config = [[TUPConfig alloc] init];
                [config setString:filterCode forKey:TUPFPTusdkImageFilter_CONFIG_NAME];
                [skinBeautifyFilter setConfig:config];
            }
            
            
            // filter
            [_pipeOprationQueue runSync:^{
                if ([self->_pipeline getFilter:filterIndex])
                {
                    [self->_pipeline deleteFilterAt:filterIndex];
                }
                [self->_pipeline addFilter:skinBeautifyFilter at:filterIndex];
                [skinBeautifyFilter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
            }];
        }
        break;
                
        case TuSkinFaceTypeMoist:
        {
            TUPFPTusdkImageFilter_SkinHazyPropertyBuilder *property = [[TUPFPTusdkImageFilter_SkinHazyPropertyBuilder alloc] init];
            for (SelesParameterArg *arg in filterParams.args)
            {
                if ([arg.key isEqualToString:@"smoothing"]) { property.smoothing = arg.value; }
                else if ([arg.key isEqualToString:@"whitening"]) { property.fair = arg.value; }
                else if ([arg.key isEqualToString:@"ruddy"]) { property.ruddy = arg.value; }
            }
            [_filterPropertys setObject:property forKey:@(TuFilterModel_SkinFace)];
            
            TUPFPFilter* skinBeautifyFilter = [[TUPFPFilter alloc] init:_pipeline.getContext withName:TUPFPTusdkImageFilter_TYPE_NAME];
            {
                TUPConfig* config = [[TUPConfig alloc] init];
                [config setString:filterCode forKey:TUPFPTusdkImageFilter_CONFIG_NAME];
                [skinBeautifyFilter setConfig:config];
            }

            // filter
            [_pipeOprationQueue runSync:^{
                if ([self->_pipeline getFilter:filterIndex])
                {
                    [self->_pipeline deleteFilterAt:filterIndex];
                }
                [self->_pipeline addFilter:skinBeautifyFilter at:filterIndex];
                [skinBeautifyFilter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
            }];
        }
        break;
                
        case TuSkinFaceTypeBeauty:
        default:
        {
            TUPFPTusdkBeautFaceV2Filter_PropertyBuilder *property = [[TUPFPTusdkBeautFaceV2Filter_PropertyBuilder alloc] init];
            for (SelesParameterArg *arg in filterParams.args)
            {
                if ([arg.key isEqualToString:@"smoothing"]) { property.smoothing = arg.value; }
                else if ([arg.key isEqualToString:@"whitening"]) { property.whiten = arg.value; }
                else if ([arg.key isEqualToString:@"sharpen"]) { property.sharpen = arg.value; }
            }
            [_filterPropertys setObject:property forKey:@(TuFilterModel_SkinFace)];
            
            // filter
            [_pipeOprationQueue runSync:^{
                if ([self->_pipeline getFilter:filterIndex])
                {
                    [self->_pipeline deleteFilterAt:filterIndex];
                }
                TUPFPFilter *skinBeautifyFilter = [[TUPFPFilter alloc] init:self->_pipeline.getContext withName:filterCode];
                [self->_pipeline addFilter:skinBeautifyFilter at:filterIndex];
                [skinBeautifyFilter setProperty:property.makeProperty forKey:TUPFPTusdkBeautFaceV2Filter_PROP_PARAM];
            }];
        }
        break;
    }

    return filterParams;
}

- (void)removeFaceSkinBeautifyFilter
{
//    NSString *filterCode = TUPFPTusdkFacePlasticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_SkinFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
    }];
    
}

- (void)addFaceMonsterFilter:(TuSDKMonsterFaceType)type
{
    NSString *filterCode = nil;
    TuFilterModel filterModel = TuFilterModel_MonsterFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    switch (type)
    {
    case TuSDKMonsterFaceTypeBigNose:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_BigNose;
        break;
    case TuSDKMonsterFaceTypePieFace:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_PieFace;
        break;
    case TuSDKMonsterFaceTypeSquareFace:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_SquareFace;
        break;
    case TuSDKMonsterFaceTypeThickLips:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_ThickLips;
        break;
    case TuSDKMonsterFaceTypeSmallEyes:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_SmallEyes;
        break;
    case TuSDKMonsterFaceTypePapayaFace:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_PapayaFace;
        break;
    case TuSDKMonsterFaceTypeSnakeFace:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_SnakeFace;
        break;
    default:
        filterCode = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_Empty;
        break;
    }
    
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
        TUPFPFilter* monsterFilter = [[TUPFPFilter alloc] init:self->_pipeline.getContext withName:TUPFPTusdkFaceMonsterFilter_TYPE_NAME];
        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:filterCode forKey:TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE];
            [monsterFilter setConfig:config];
        }
        [self->_pipeline addFilter:monsterFilter at:filterIndex];
    }];
}

- (void)removeFaceMonsterFilter
{
//    NSString *filterCode = TUPFPTusdkFacePlasticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_MonsterFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
    }];
}

- (void)addStickerFilter:(TuStickerGroup *)stickerGroup
{
    NSString *filterCode = TUPFPTusdkLiveStickerFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_StickerFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    if (stickerGroup == nil)
    {
        return;
    }
        
    NSInteger stickerGroupId = stickerGroup.idt;

    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }

        TUPFPFilter* stickerFilter = [[TUPFPFilter alloc] init:self->_pipeline.getContext withName:filterCode];
        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setNumber:[NSNumber numberWithInteger:stickerGroupId] forKey:TUPFPTusdkLiveStickerFilter_CONFIG_GROUP];
            [stickerFilter setConfig:config];
        }
        [self->_pipeline addFilter:stickerFilter at:filterIndex];
    }];
}

- (void)removeStickerFilter
{
//    NSString *filterCode = TUPFPTusdkLiveStickerFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_StickerFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
    }];
}

- (SelesParameters *)addFaceCosmeticFilter:(SelesParameters *)params
{
    NSString *filterCode = TUPFPTusdkCosmeticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_CosmeticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    // params
    SelesParameters *filterParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    for (SelesParameterArg *arg in params.args)
    {
        [filterParams appendFloatArgWithKey:arg.key value:arg.value];
    }
    filterParams.listener = self;
            

    // Property
    TUPFPTusdkCosmeticFilter_PropertyBuilder *cosmeticProperty = [[TUPFPTusdkCosmeticFilter_PropertyBuilder alloc] init];
    
    for (SelesParameterArg *arg in filterParams.args)
    {
        if ([arg.key isEqualToString:@"facialEnable"]) { cosmeticProperty.facialEnable = arg.value; } // 修容开关
        else if ([arg.key isEqualToString:@"facialOpacity"]) { cosmeticProperty.facialOpacity = arg.value; } // 修容不透明度
        else if ([arg.key isEqualToString:@"facialId"]) { cosmeticProperty.facialId = arg.value; } // 修容贴纸id

        else if ([arg.key isEqualToString:@"lipEnable"]) { cosmeticProperty.lipEnable = arg.value; } // 口红开关
        else if ([arg.key isEqualToString:@"lipOpacity"]) { cosmeticProperty.lipOpacity = arg.value; } // 口红不透明度
        else if ([arg.key isEqualToString:@"lipStyle"]) { cosmeticProperty.lipStyle = arg.value; } // 口红类型
        else if ([arg.key isEqualToString:@"lipColor"]) { cosmeticProperty.lipColor = arg.value; } // 口红颜色
        
        else if ([arg.key isEqualToString:@"blushEnable"]) { cosmeticProperty.blushEnable = arg.value; } // 腮红开关
        else if ([arg.key isEqualToString:@"blushOpacity"]) { cosmeticProperty.blushOpacity = arg.value; } // 腮红不透明度
        else if ([arg.key isEqualToString:@"blushId"]) { cosmeticProperty.blushId = arg.value; } // 腮红贴纸id

        else if ([arg.key isEqualToString:@"browEnable"]) { cosmeticProperty.browEnable = arg.value; } // 眉毛开关
        else if ([arg.key isEqualToString:@"browOpacity"]) { cosmeticProperty.browOpacity = arg.value; } // 眉毛不透明度
        else if ([arg.key isEqualToString:@"browId"]) { cosmeticProperty.browId = arg.value; } // 眉毛贴纸id

        else if ([arg.key isEqualToString:@"eyeshadowEnable"]) { cosmeticProperty.eyeshadowEnable = arg.value; } // 眼影开关
        else if ([arg.key isEqualToString:@"eyeshadowOpacity"]) { cosmeticProperty.eyeshadowOpacity = arg.value; } // 眼影不透明度
        else if ([arg.key isEqualToString:@"eyeshadowId"]) { cosmeticProperty.eyeshadowId = arg.value; } // 眼影贴纸id

        else if ([arg.key isEqualToString:@"eyelineEnable"]) { cosmeticProperty.eyelineEnable = arg.value; } // 眼线开关
        else if ([arg.key isEqualToString:@"eyelineOpacity"]) { cosmeticProperty.eyelineOpacity = arg.value; } // 眼线不透明度
        else if ([arg.key isEqualToString:@"eyelineId"]) { cosmeticProperty.eyelineId = arg.value; } // 眼线贴纸id

        else if ([arg.key isEqualToString:@"eyelashEnable"]) { cosmeticProperty.eyelashEnable = arg.value; } // 睫毛开关
        else if ([arg.key isEqualToString:@"eyelashOpacity"]) { cosmeticProperty.eyelashOpacity = arg.value; } // 睫毛不透明度
        else if ([arg.key isEqualToString:@"eyelashId"]) { cosmeticProperty.eyelashId = arg.value; } // 睫毛贴纸id
    }
    [_filterPropertys setObject:cosmeticProperty forKey:@(filterModel)];

    
    // filter
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }

        TUPFPFilter *cosmeticFilter = [[TUPFPFilter alloc]init:[self->_pipeline getContext] withName:filterCode];
        [self->_pipeline addFilter:cosmeticFilter at:filterIndex];
        [cosmeticFilter setProperty:cosmeticProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
    return filterParams;
}

- (void)removeFaceCosmeticFilter
{
//    NSString *filterCode = TUPFPTusdkCosmeticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_CosmeticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:filterIndex])
        {
            [self->_pipeline deleteFilterAt:filterIndex];
        }
    }];
}

#pragma mark - SelesParametersListener
// 滤镜参数调节功能列表 --------------------------------------------------
- (void)onSelesParametersUpdate:(TuFilterModel)model code:(NSString *)code arg:(SelesParameterArg *)arg
{
    NSInteger filterIndex = [self FilterIndex:model];

    switch (model)
    {
        case TuFilterModel_Filter:
        {
            TUPFPTusdkImageFilter_Type10PropertyBuilder *property = (TUPFPTusdkImageFilter_Type10PropertyBuilder *)[_filterPropertys objectForKey:@(model)];
            {
                property.strength = arg.value;
            }
            
            [_pipeOprationQueue runSync:^{
                TUPFPFilter *filter = [self->_pipeline getFilter:filterIndex];
                [filter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
            }];
        }
        break;
        
        case TuFilterModel_PlasticFace:
            [self updatePlasticParams:arg];
            break;
        
        case TuFilterModel_ReshapeFace:
            [self updatePlasticExtraParams:arg];
            break;
            
            
        case TuFilterModel_SkinFace:
            [self updateSkinBeautifyParams:arg];
            break;
            
        case TuFilterModel_CosmeticFace:
            [self updateCosmeticParams:arg];
            break;
        
        default:
        break;
    }
}

- (void)updatePlasticParams:(SelesParameterArg*)arg
{
//    NSString *filterCode = TUPFPTusdkFacePlasticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_PlasticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    TUPFPTusdkFacePlasticFilter_PropertyBuilder *plasticProperty = (TUPFPTusdkFacePlasticFilter_PropertyBuilder*)[_filterPropertys objectForKey:@(filterModel)];

    if ([arg.key isEqualToString:@"eyeSize"]) { plasticProperty.eyeEnlarge = arg.value; } // 大眼
    
    else if ([arg.key isEqualToString:@"chinSize"]) { plasticProperty.cheekThin = arg.value; } // 瘦脸
    else if ([arg.key isEqualToString:@"cheekNarrow"]) { plasticProperty.cheekNarrow = arg.value; } // 窄脸
    
    else if ([arg.key isEqualToString:@"smallFace"]) { plasticProperty.faceSmall = arg.value; } // 小脸
    else if ([arg.key isEqualToString:@"cheekBoneNarrow"]) { plasticProperty.cheekBoneNarrow = arg.value; } // 瘦颧骨
    else if ([arg.key isEqualToString:@"cheekLowBoneNarrow"]) { plasticProperty.cheekLowBoneNarrow = arg.value; } // 下颌骨

    else if ([arg.key isEqualToString:@"forehead"]) { plasticProperty.foreheadHeight = arg.value; } // 额头高低

    else if ([arg.key isEqualToString:@"archEyebrow"]) { plasticProperty.browThickness = arg.value; } // 眉毛粗细
    else if ([arg.key isEqualToString:@"browPosition"]) { plasticProperty.browHeight = arg.value; } // 眉毛高低

    else if ([arg.key isEqualToString:@"eyeHeight"]) { plasticProperty.eyeHeight = arg.value; } // 眼睛高低
    else if ([arg.key isEqualToString:@"eyeAngle"]) { plasticProperty.eyeAngle = arg.value; } // 眼角
    else if ([arg.key isEqualToString:@"eyeDis"]) { plasticProperty.eyeDistance = arg.value; } // 眼距
    else if ([arg.key isEqualToString:@"eyeInnerConer"]) { plasticProperty.eyeInnerConer = arg.value; } // 内眼角
    else if ([arg.key isEqualToString:@"eyeOuterConer"]) { plasticProperty.eyeOuterConer = arg.value; } // 外眼角
    
    else if ([arg.key isEqualToString:@"noseSize"]) { plasticProperty.noseWidth = arg.value; } // 鼻子宽度
    else if ([arg.key isEqualToString:@"noseHeight"]) { plasticProperty.noseHeight = arg.value; } // 鼻子长度
    
    else if ([arg.key isEqualToString:@"philterum"]) { plasticProperty.philterumThickness = arg.value; } // 缩人中
    
    else if ([arg.key isEqualToString:@"mouthWidth"]) { plasticProperty.mouthWidth = arg.value; } // 嘴巴宽度
    else if ([arg.key isEqualToString:@"lips"]) { plasticProperty.lipsThickness = arg.value; } // 嘴唇厚度

    else if ([arg.key isEqualToString:@"jawSize"]) { plasticProperty.chinThickness = arg.value; }  // 下巴高低
    
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:filterIndex];
        [filter setProperty:plasticProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
}

- (void)updatePlasticExtraParams:(SelesParameterArg*)arg
{
//    NSString *filterCode = TUPFPTusdkFaceReshapeFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_ReshapeFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    TUPFPTusdkFaceReshapeFilter_PropertyBuilder *property = (TUPFPTusdkFaceReshapeFilter_PropertyBuilder*)[_filterPropertys objectForKey:@(filterModel)];

    if ([arg.key isEqualToString:@"eyeDetail"]) { property.eyeDetailOpacity = arg.value; } // 亮眼
    else if ([arg.key isEqualToString:@"eyelid"]) { property.eyelidOpacity = arg.value; } // 双眼皮
    else if ([arg.key isEqualToString:@"eyemazing"]) { property.eyemazingOpacity = arg.value; } // 卧蚕
    else if ([arg.key isEqualToString:@"removePouch"]) { property.removePouchOpacity = arg.value; } // 祛除眼袋
    else if ([arg.key isEqualToString:@"removeWrinkles"]) { property.removeWrinklesOpacity = arg.value; } // 祛除法令纹
    else if ([arg.key isEqualToString:@"whitenTeeth"]) { property.whitenTeethOpacity = arg.value; } // 白牙

    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:filterIndex];
        [filter setProperty:property.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
}

- (void)updateSkinBeautifyParams:(SelesParameterArg*)arg
{
    TuFilterModel filterModel = TuFilterModel_SkinFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];
    
    TUPFPFilter *skinBeautifyFilter = [_pipeline getFilter:filterIndex];

    NSObject *property = [_filterPropertys objectForKey:@(filterModel)];
    if ([property isKindOfClass:[TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder class]])
    {
        TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder *naturalProperty = (TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder *)property;

        if ([arg.key isEqualToString:@"smoothing"]) { naturalProperty.smoothing = arg.value; }
        else if ([arg.key isEqualToString:@"whitening"]) { naturalProperty.fair = arg.value; }
        else if ([arg.key isEqualToString:@"ruddy"]) { naturalProperty.ruddy = arg.value; }
        
        [_pipeOprationQueue runSync:^{
            [skinBeautifyFilter setProperty:naturalProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
        }];
    }
    else if ([property isKindOfClass:[TUPFPTusdkImageFilter_SkinHazyPropertyBuilder class]])
    {
        TUPFPTusdkImageFilter_SkinHazyPropertyBuilder *hazyProperty = (TUPFPTusdkImageFilter_SkinHazyPropertyBuilder *)property;

        if ([arg.key isEqualToString:@"smoothing"]) { hazyProperty.smoothing = arg.value; }
        else if ([arg.key isEqualToString:@"whitening"]) { hazyProperty.fair = arg.value; }
        else if ([arg.key isEqualToString:@"ruddy"]) { hazyProperty.ruddy = arg.value; }
        
        [_pipeOprationQueue runSync:^{
            [skinBeautifyFilter setProperty:hazyProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
        }];
    }
    else if ([property isKindOfClass:[TUPFPTusdkBeautFaceV2Filter_PropertyBuilder class]])
    {
        TUPFPTusdkBeautFaceV2Filter_PropertyBuilder *beautyFaceV2Property = (TUPFPTusdkBeautFaceV2Filter_PropertyBuilder *)property;

        if ([arg.key isEqualToString:@"smoothing"]) { beautyFaceV2Property.smoothing = arg.value; }
        else if ([arg.key isEqualToString:@"whitening"]) { beautyFaceV2Property.whiten = arg.value; }
        else if ([arg.key isEqualToString:@"sharpen"]) { beautyFaceV2Property.sharpen = arg.value; }
        
        [_pipeOprationQueue runSync:^{
            [skinBeautifyFilter setProperty:beautyFaceV2Property.makeProperty forKey:TUPFPTusdkBeautFaceV2Filter_PROP_PARAM];
        }];
    }
}

- (void)updateCosmeticParams:(SelesParameterArg*)arg
{
//    NSString *filterCode = TUPFPTusdkCosmeticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_CosmeticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    // Property
    TUPFPTusdkCosmeticFilter_PropertyBuilder *cosmeticProperty = (TUPFPTusdkCosmeticFilter_PropertyBuilder*)[_filterPropertys objectForKey:@(filterModel)];

    if ([arg.key isEqualToString:@"facialEnable"]) { cosmeticProperty.facialEnable = arg.value; } // 修容开关
    else if ([arg.key isEqualToString:@"facialOpacity"]) { cosmeticProperty.facialOpacity = arg.value; } // 修容不透明度
    else if ([arg.key isEqualToString:@"facialId"]) { cosmeticProperty.facialId = arg.value; } // 修容贴纸id

    else if ([arg.key isEqualToString:@"lipEnable"]) { cosmeticProperty.lipEnable = arg.value; } // 口红开关
    else if ([arg.key isEqualToString:@"lipOpacity"]) { cosmeticProperty.lipOpacity = arg.value; } // 口红不透明度
    else if ([arg.key isEqualToString:@"lipStyle"]) { cosmeticProperty.lipStyle = arg.value; } // 口红类型
    else if ([arg.key isEqualToString:@"lipColor"]) { cosmeticProperty.lipColor = arg.value; } // 口红颜色
    
    else if ([arg.key isEqualToString:@"blushEnable"]) { cosmeticProperty.blushEnable = arg.value; } // 腮红开关
    else if ([arg.key isEqualToString:@"blushOpacity"]) { cosmeticProperty.blushOpacity = arg.value; } // 腮红不透明度
    else if ([arg.key isEqualToString:@"blushId"]) { cosmeticProperty.blushId = arg.value; } // 腮红贴纸id

    else if ([arg.key isEqualToString:@"browEnable"]) { cosmeticProperty.browEnable = arg.value; } // 眉毛开关
    else if ([arg.key isEqualToString:@"browOpacity"]) { cosmeticProperty.browOpacity = arg.value; } // 眉毛不透明度
    else if ([arg.key isEqualToString:@"browId"]) { cosmeticProperty.browId = arg.value; } // 眉毛贴纸id

    else if ([arg.key isEqualToString:@"eyeshadowEnable"]) { cosmeticProperty.eyeshadowEnable = arg.value; } // 眼影开关
    else if ([arg.key isEqualToString:@"eyeshadowOpacity"]) { cosmeticProperty.eyeshadowOpacity = arg.value; } // 眼影不透明度
    else if ([arg.key isEqualToString:@"eyeshadowId"]) { cosmeticProperty.eyeshadowId = arg.value; } // 眼影贴纸id

    else if ([arg.key isEqualToString:@"eyelineEnable"]) { cosmeticProperty.eyelineEnable = arg.value; } // 眼线开关
    else if ([arg.key isEqualToString:@"eyelineOpacity"]) { cosmeticProperty.eyelineOpacity = arg.value; } // 眼线不透明度
    else if ([arg.key isEqualToString:@"eyelineId"]) { cosmeticProperty.eyelineId = arg.value; } // 眼线贴纸id

    else if ([arg.key isEqualToString:@"eyelashEnable"]) { cosmeticProperty.eyelashEnable = arg.value; } // 睫毛开关
    else if ([arg.key isEqualToString:@"eyelashOpacity"]) { cosmeticProperty.eyelashOpacity = arg.value; } // 睫毛不透明度
    else if ([arg.key isEqualToString:@"eyelashId"]) { cosmeticProperty.eyelashId = arg.value; } // 睫毛贴纸id
    
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:filterIndex];
        [filter setProperty:cosmeticProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
}

- (void)updateCosmeticParam:(NSString *)code enable:(BOOL)enable
{
//    NSString *filterCode = TUPFPTusdkCosmeticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_CosmeticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    // Property
    TUPFPTusdkCosmeticFilter_PropertyBuilder *cosmeticProperty = (TUPFPTusdkCosmeticFilter_PropertyBuilder*)[_filterPropertys objectForKey:@(filterModel)];

    if ([code isEqualToString:@"facialEnable"])
    {
        cosmeticProperty.facialEnable = enable; // 修容开关
    }
    else if ([code isEqualToString:@"lipEnable"])
    {
        cosmeticProperty.lipEnable = enable; // 口红开关
    }
    else if ([code isEqualToString:@"blushEnable"])
    {
        cosmeticProperty.blushEnable = enable; // 腮红开关
    }
    else if ([code isEqualToString:@"browEnable"])
    {
        cosmeticProperty.browEnable = enable; // 眉毛开关
    }
    else if ([code isEqualToString:@"eyeshadowEnable"])
    {
        cosmeticProperty.eyeshadowEnable = enable; // 眼影开关
    }
    else if ([code isEqualToString:@"eyelineEnable"])
    {
        cosmeticProperty.eyelineEnable = enable; // 眼线开关
    }
    else if ([code isEqualToString:@"eyelashEnable"])
    {
        cosmeticProperty.eyelashEnable = enable; // 睫毛开关
    }
    
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:filterIndex];
        [filter setProperty:cosmeticProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
}

- (void)updateCosmeticParam:(NSString *)code value:(NSInteger)value
{
//    NSString *filterCode = TUPFPTusdkCosmeticFilter_TYPE_NAME;
    TuFilterModel filterModel = TuFilterModel_CosmeticFace;
    NSInteger filterIndex = [self FilterIndex:filterModel];

    // Property
    TUPFPTusdkCosmeticFilter_PropertyBuilder *cosmeticProperty = (TUPFPTusdkCosmeticFilter_PropertyBuilder*)[_filterPropertys objectForKey:@(filterModel)];

    if ([code isEqualToString:@"lipStyle"])
    {
        cosmeticProperty.lipStyle = value; // 口红类型
    }
    else if ([code isEqualToString:@"lipColor"])
    {
        cosmeticProperty.lipColor = value; // 口红颜色
    }
    else
    {
        NSInteger stickerId = -1;
        
        TuStickerGroup *stickerGroup = [[TuStickerLocalPackage package] groupWithGroupID:value];
        if (stickerGroup && stickerGroup.stickers)
        {
            TuSticker *sticker = stickerGroup.stickers[0];
            stickerId = sticker.idt;
        }

        if (stickerId == -1)
        {
            return;
        }
        
        if ([code isEqualToString:@"facialId"])
        {
            cosmeticProperty.facialId = stickerId; // 修容贴纸id
        }
        else if ([code isEqualToString:@"blushId"])
        {
            cosmeticProperty.blushId = stickerId; // 腮红贴纸id
        }
        else if ([code isEqualToString:@"browId"])
        {
            cosmeticProperty.browId = stickerId; // 眉毛贴纸id
        }
        else if ([code isEqualToString:@"eyeshadowId"])
        {
            cosmeticProperty.eyeshadowId = stickerId; // 眼影贴纸id
        }
        else if ([code isEqualToString:@"eyelineId"])
        {
            cosmeticProperty.eyelineId = stickerId; // 眼线贴纸id
        }
        else if ([code isEqualToString:@"eyelashId"])
        {
            cosmeticProperty.eyelashId = stickerId; // 睫毛贴纸id
        }
    }
    
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:filterIndex];
        [filter setProperty:cosmeticProperty.makeProperty forKey:TUPFPTusdkImageFilter_PROP_PARAM];
    }];
}


#pragma mark - TuCameraVideoDataOutputDelegate
// 视频帧处理功能列表 --------------------------------------------------
- (void)onTuCameraDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    NSInteger timeStampMs = (1000 * presentationTimeStamp.value) / presentationTimeStamp.timescale;

//    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);

    [_pipeOprationQueue runSync:^{

        bool isMarkSense = false;
        if ([self->_pipeline getFilter:[self FilterIndex:TuFilterModel_ReshapeFace]]
            || [self->_pipeline getFilter:[self FilterIndex:TuFilterModel_CosmeticFace]])
        {
            isMarkSense = true;
        }
        
        self->_pipeInImage = [self->_imgcvt convert:sampleBuffer];
        [self->_pipeInImage setMarkSenceEnable:isMarkSense];

        [self->_pipeOutLock lock];

        self->_pipeOutImage = [self->_pipeline process:self->_pipeInImage];
        
        [self videoRecordProcess:timeStampMs];
        
        [self->_pipeOutLock unlock];

        
//        [self->_displayView update:self->_pipeOutImage];
        [self->_displayView update:self->_pipeOutImage atRect:self->_displayViewRect];

    }];
}
- (void)videoRecordProcess:(NSInteger)timeStamp
{
    BOOL deleteAllRecordFragments = NO;
    
    switch (_recordState)
    {
        case lsqRecordStateNotStart:
            break;
            
        case lsqRecordStatePrepare:
        {
            NSInteger totalDuration = 0;
            for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
            {
                totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
            }
                        
            if (totalDuration >= _maxRecordingTime * 1000)
            {
                NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is more than %lu seconds", (unsigned long)_maxRecordingTime]
                                                     code:lsqRecordVideoErrorMoreMaxDuration
                                                 userInfo:nil];
                
                if (_delegate && [_delegate respondsToSelector:@selector(recordFailedWithError:)])
                {
                    [_delegate recordFailedWithError:error];
                }
                
                [self setRecordState:lsqRecordStatePaused];
            }
            else
            {
                
                RecordFragment *fragment = [_recordFragments lastObject];
                
                if (fragment && fragment.exporter) {
                    if (fragment.isVideoConfiged == NO)
                    {
                        fragment.config.width = [fragment formatWidth:(int)[_pipeOutImage getWidth]];
                        fragment.config.height = (int)[_pipeOutImage getHeight];
                        fragment.config.stretch = [self getSpeed];
                        //fragment.config.pitchType = (int)[self getPitch];
                        fragment.isVideoConfiged = YES;
                    }
                    
                    if (fragment.isAudioConfiged && fragment.isVideoConfiged)
                    {
                        [fragment.exporter open:fragment.config];
                        [self setRecordState:lsqRecordStateRecording];
                    }
                } else {
                    TUPFPFileExporter_Config *config = [[TUPFPFileExporter_Config alloc] init];
                    {
                        NSString *savePath = [NSString stringWithFormat:@"file://%@recordfragment%lu.mp4",
                                              NSTemporaryDirectory(),
                                              _recordFragments.count + 1];
                        
                        config.savePath = savePath;
                        config.watermark = [UIImage imageNamed:@"sample_watermark.png"];
                        //水印位置，默认为右上
//                        config.watermarkPosition = -1;
                                        
                        TUPFPFileExporter *exporter = [[TUPFPFileExporter alloc] init];
                        RecordFragment *fragment = [[RecordFragment alloc] init];
                        fragment.config = config;
                        fragment.exporter = exporter;
                        fragment.videoTimeStart = 0;
                        fragment.isAudioConfiged = NO;
                        fragment.isVideoConfiged = NO;
                        
                        // video config
                        fragment.config.width = [fragment formatWidth:(int)[_pipeOutImage getWidth]];
                        fragment.config.height = (int)[_pipeOutImage getHeight];
                        fragment.config.stretch = [self getSpeed];
                        //fragment.config.pitchType = (int)[self getPitch];
                        fragment.isVideoConfiged = YES;
                        
                        [_recordFragments addObject:fragment];
                    }
                }
            }
        }
            break;
            
        case lsqRecordStateRecording:
        {
            RecordFragment *fragment = [_recordFragments lastObject];
            
            if (fragment && fragment.exporter)
            {
                if (fragment.videoTimeStart == 0)
                {
                    fragment.videoTimeStart = timeStamp;
                }
                fragment.timeDuration = timeStamp - fragment.videoTimeStart;
                NSLog(@"v %ld", fragment.timeDuration);

                NSInteger totalDuration = 0;
                for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
                {
                    totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
                }
                
                if (_delegate && [_delegate respondsToSelector:@selector(recordProgressChanged:durationTime:)])
                {
                    [_delegate recordProgressChanged:totalDuration/(_maxRecordingTime * 1000.0f) durationTime:totalDuration];
                }

                if (totalDuration < _maxRecordingTime * 1000)
                {
                    
                    [fragment.exporter sendVideo:_pipeOutImage withTimestamp:fragment.timeDuration];
                }
                else
                {
                    [self pauseAudioMixer];
                    [self setRecordState:lsqRecordStatePaused];
                }
            }
            else
            {
                [self setRecordState:lsqRecordStateCanceled];
            }
        }
            break;
            
        case lsqRecordStateRecordingCompleted:
        {
            NSInteger totalDuration = 0;
            for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
            {
                totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
            }

            if (totalDuration < _minRecordingTime * 1000)
            {
                NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is less than %lu seconds", (unsigned long)_minRecordingTime]
                                            code:lsqRecordVideoErrorLessMinDuration
                                        userInfo:nil];
                
                if (_delegate && [_delegate respondsToSelector:@selector(recordFailedWithError:)])
                {
                    [_delegate recordFailedWithError:error];
                }
            }
            else
            {
                [self setRecordState:lsqRecordStateSaveing];
            }
        }
            break;
            
        case lsqRecordStatePaused:
        {

            RecordFragment *fragment = [_recordFragments lastObject];
            if (fragment && fragment.exporter)
            {
                if (fragment.isAudioConfiged && fragment.isVideoConfiged)
                {
                    [fragment.exporter close];
                }
                fragment.exporter = Nil;
                
                if (fragment.isVideoConfiged == false
                    || fragment.isAudioConfiged == false
                    || fragment.videoTimeStart == 0
                    || fragment.audioTimeStart == 0
                    || fragment.timeDuration == 0)
                {
                    [_recordFragments removeLastObject];
                }
                else
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(recordMarkPush)])
                    {
                        [_delegate recordMarkPush];
                    }
                }
                    
            }
            //[self.audioUnit resetPlay];
        }
            break;
            
        case lsqRecordStateSaveing:
        {
            // saving
            NSMutableArray<NSString *> *fragmentSavedPath = [[NSMutableArray alloc] init];
            for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
            {
                if (_recordFragments[fragIndex].config.savePath)
                {
                    [fragmentSavedPath addObject:_recordFragments[fragIndex].config.savePath];
                }
            }
            
            NSDate* date = [NSDate date];
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];

            NSString *savePath = [NSString stringWithFormat:@"file://%@TUSDK%@.mp4",
                                  NSTemporaryDirectory(),
                                  [dateFormat stringFromDate:date]];

            bool ret = [TUPFPFileExporter mergeVideoFiles:fragmentSavedPath to:savePath];
            
            if (ret)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(recordResult:)])
                {
                    [_delegate recordResult:[NSURL URLWithString:savePath]];
                }
            }
            else
            {
                NSError *error = [NSError errorWithDomain:@"There was an error while saving the video"
                                                     code:lsqRecordVideoErrorSaveFailed
                                                 userInfo:nil];
                
                if (_delegate && [_delegate respondsToSelector:@selector(recordFailedWithError:)])
                {
                    [_delegate recordFailedWithError:error];
                }
            }
            [self setRecordState:lsqRecordStateSaveingCompleted];
        }
            break;
            
        case lsqRecordStateCanceled:
        case lsqRecordStateSaveingCompleted:
            deleteAllRecordFragments = YES;
            break;
            
        default:
            break;
    }
    
    if (deleteAllRecordFragments && _recordFragments.count > 0)
    {
        [self removeAllFragments];
        
    }
}

- (UIImage *)processImage:(CMSampleBufferRef)sampleBuffer devicePosition:(AVCaptureDevicePosition)devicePosition
{
    return nil;
}


#pragma mark - TuCameraAudioDataOutputDelegate
// 音频数据处理功能列表 --------------------------------------------------
- (void)onTuCameraDidOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    NSInteger timeStampMs = (1000 * presentationTimeStamp.value) / presentationTimeStamp.timescale;

    [_pipeOprationQueue runSync:^{
        [self->_pipeOutLock lock];
        
        CMAudioFormatDescriptionRef audioFormatDes = (CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer);
        AudioStreamBasicDescription inAudioStreamBasicDescription = *(CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDes));
        CMBlockBufferRef blockBuffer;
        AudioBufferList audioBufferList;
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
        [self audioRecordProcessBufferList:audioBufferList basicDescription:inAudioStreamBasicDescription timeStamp:timeStampMs];
        CFRelease(blockBuffer);
        
        [self->_pipeOutLock unlock];
    }];
}

- (void)onTuCameraDidOutputBufferList:(AudioBufferList)bufferList basicDescription:(AudioStreamBasicDescription)basicDescription timeStamp:(NSInteger)timeStamp {
    [_pipeOprationQueue runSync:^{
        [self->_pipeOutLock lock];
        [self audioRecordProcessBufferList:bufferList basicDescription:basicDescription timeStamp:timeStamp];
        [self->_pipeOutLock unlock];
    }];
}

- (void)audioRecordProcessBufferList:(AudioBufferList)bufferList basicDescription:(AudioStreamBasicDescription)basicDescription timeStamp:(NSInteger)timeStamp {
    switch (_recordState)
    {
        case lsqRecordStatePrepare:
        {
            NSInteger totalDuration = 0;
            for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
            {
                totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
            }

            if (totalDuration < _maxRecordingTime * 1000)
            {
                RecordFragment *fragment = [_recordFragments lastObject];
                
                if (fragment && fragment.exporter)
                {
                    if (fragment.isAudioConfiged == NO)
                    {
                        
                        fragment.config.channels = basicDescription.mChannelsPerFrame;
                        fragment.config.sampleRate = basicDescription.mSampleRate;
                        
                        fragment.isAudioConfiged = YES;
                    }
                    
                    if (fragment.isAudioConfiged && fragment.isVideoConfiged)
                    {
                        [fragment.exporter open:fragment.config];
                        [self setRecordState:lsqRecordStateRecording];
                    }
                }
                else
                {
                    TUPFPFileExporter_Config *config = [[TUPFPFileExporter_Config alloc] init];
                    {
                        NSString *savePath = [NSString stringWithFormat:@"file://%@recordfragment%lu.mp4",
                                              NSTemporaryDirectory(),
                                              _recordFragments.count + 1];
                        config.savePath = savePath;
                        config.watermark = [UIImage imageNamed:@"sample_watermark.png"];
                        //水印位置，默认值为 -1，右上位置
//                        config.watermarkPosition = -1;
                                                
                        TUPFPFileExporter *exporter = [[TUPFPFileExporter alloc] init];
                        RecordFragment *fragment = [[RecordFragment alloc] init];
                        fragment.config = config;
                        fragment.exporter = exporter;
                        fragment.videoTimeStart = 0;
                        fragment.isAudioConfiged = NO;
                        fragment.isVideoConfiged = NO;
                        
                        // audio config
                        
                        fragment.config.channels = basicDescription.mChannelsPerFrame;
                        fragment.config.sampleRate = basicDescription.mSampleRate;
                        fragment.isAudioConfiged = YES;
                        
                        [_recordFragments addObject:fragment];
                    }
                }
            }
        }
            break;
            
        case lsqRecordStateRecording:
        {
            RecordFragment *fragment = [_recordFragments lastObject];
            
            if (fragment && fragment.exporter)
            {
                if (fragment.videoTimeStart > 0)
                {
                    if (fragment.audioTimeStart == 0)
                    {
                        fragment.audioTimeStart = timeStamp;
                    }
                    //fragment.audioTimeDuration = fragment.timeDuration;
                    fragment.audioTimeDuration = timeStamp - fragment.audioTimeStart;

                    //NSLog(@"audio duration %ld %ld %ld", timeStamp, fragment.audioTimeDuration, fragment.timeDuration);
                    NSLog(@"a %ld", fragment.timeDuration);
                    NSInteger totalDuration = 0;
                    for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count - 1; fragIndex++)
                    {
                        totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
                    }

                    if (totalDuration < _maxRecordingTime * 1000)
                    {
                        
                        AudioBuffer audioBuffer = bufferList.mBuffers[0];
                        
                        size_t nc = audioBuffer.mDataByteSize / 1 / sizeof(int16_t);
                        [_audioPipeline enqueue:audioBuffer.mData andLength:nc];
//                        TTLog(@"_audioPipeline receive: %d %zu",audioBuffer.mDataByteSize, [_audioPipeline getSize]);
                        size_t bufferSize = 1024 * 1 * sizeof(int16_t);
                        while ([_audioPipeline getSize] >= 1024) {
                            [_audioPipeline dequeue:_audioPipeQueueData andLength:1024];
                            
                            [_audioPipeline send:_audioPipeQueueData andLength:bufferSize];
                            while (true) {
                                int ret = [_audioPipeline receive:_audioPipeData andLength:bufferSize];
                                //TTLog(@"_audioPipeline receive:  %d %zu %zu %d ",audioBuffer.mDataByteSize, enq, [_audioPipeline getSize], ret);
                                if (ret < 0) {
                                    break;
                                }
                                if (self.mixerMode != TTAudioMixerModeNone && _audioMixer != nil) {
                                    [self.audioMixer sendPrimaryAudio:_audioPipeData andLength:bufferSize];
                                    //TTLog(@"audioMixer sendPrimaryAudio %d %d",ret, audioBuffer.mDataByteSize);
                                } else {
                                    if (!self.disableMicrophone) {
                                        [fragment.exporter sendAudio:_audioPipeData andSize:bufferSize withTimestamp:fragment.audioTimeDuration];
                                    }
                                }
                            }
                        }

                        
                    }
            }
        }
        }
            break;
            
        default:
            break;
    }
    
}


- (void)setRecordState:(lsqRecordState)recordState
{
    _recordState = recordState;
        
    if ([NSThread isMainThread])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(recordStateChanged:)])
        {
            [_delegate recordStateChanged:_recordState];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(recordStateChanged:)])
            {
                [self->_delegate recordStateChanged:self->_recordState];
            }
        });
    }
}

- (void)startRecording
{
    NSLog(@"startRecording");
    if (_mixerMode != TTAudioMixerModeNone) {
        [_camera startAudioUnit];
    }
    
    [_pipeOutLock lock];
    [self setRecordState:lsqRecordStatePrepare];
    [_pipeOutLock unlock];
    [self startAudioMixerWithDuration:[self getRecordingDuration]];
    [self updateJoinerFilterPlay:YES];
}

- (void)pauseRecording
{
    
    NSLog(@"pauseRecording");
    [self pauseAudioMixer];
    [_pipeOutLock lock];
    [self setRecordState:lsqRecordStatePaused];
    [_pipeOutLock unlock];
}

- (void)finishRecording
{
    NSLog(@"finishRecording");

    [_pipeOutLock lock];
    
    NSInteger totalDuration = 0;
    for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
    {
        totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
    }

    if (totalDuration < _minRecordingTime * 1000)
    {
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Recording time is less than %lu seconds", (unsigned long)_minRecordingTime]
                                    code:lsqRecordVideoErrorLessMinDuration
                                userInfo:nil];
        
        if (_delegate && [_delegate respondsToSelector:@selector(recordFailedWithError:)])
        {
            [_delegate recordFailedWithError:error];
        }
    }
    else
    {
        [self setRecordState:lsqRecordStateRecordingCompleted];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.mixerMode == TTAudioMixerModeJoiner) {
                [self updateJoinerPos:0];
            }
        });
    }
    
    [_pipeOutLock unlock];
    
    
}

- (void)cancelRecording
{
    NSLog(@"cancelRecording");

    [_pipeOutLock lock];
    [self setRecordState:lsqRecordStateCanceled];
    [_pipeOutLock unlock];
}

- (NSUInteger)popMovieFragment
{
    [_pipeOutLock lock];

    RecordFragment *fragment = [_recordFragments lastObject];

    if (fragment)
    {
        if (fragment.isAudioConfiged && fragment.isVideoConfiged)
        {
            [fragment.exporter close];
        }
        fragment.exporter = Nil;
        
        [_recordFragments removeLastObject];
        if (_audioMixer) {
            [_audioMixer close];
        }
        
    }

    [_pipeOutLock unlock];
    if (self.mixerMode == TTAudioMixerModeJoiner) {
        [self updateJoinerPos:[self getRecordingDuration]];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(recordMarkPop)])
    {
        [_delegate recordMarkPop];
    }
    return _recordFragments.count;
}
- (void)removeAllFragments {
    for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
    {
        RecordFragment *fragment = [_recordFragments objectAtIndex:fragIndex];

        if (fragment && fragment.exporter)
        {
            if (fragment.isAudioConfiged && fragment.isVideoConfiged)
            {
                [fragment.exporter close];
            }
            fragment.exporter = nil;
        }
        
        if (fragment.config.savePath)
        {
            NSURL *saveUrl = [NSURL URLWithString:fragment.config.savePath];
            if (saveUrl)
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:saveUrl.path])
                {
                    [fileManager removeItemAtURL:[NSURL URLWithString:fragment.config.savePath] error:nil];
                }
            }
        }
    }
    
    [_recordFragments removeAllObjects];
}
- (NSInteger)getRecordingDuration {
    NSInteger totalDuration = 0;
    for (NSInteger fragIndex = 0; fragIndex < _recordFragments.count; fragIndex++)
    {
        totalDuration += _recordFragments[fragIndex].timeDuration * _recordFragments[fragIndex].config.stretch;
    }
    return totalDuration;
}
- (CGFloat)getRecordingProgress
{
    NSInteger totalDuration = [self getRecordingDuration];
    return  1.0f * totalDuration / (_maxRecordingTime * 1000);
}


- (UIImage *)getCaptureImage
{
    [_pipeOutLock lock];
    UIImage *ret = [_pipeOutImage getUIImage];
    UIImage *outPutImage = [self drawWaterMarkToCaptureImage:ret];
    
    [_pipeOutLock unlock];

    return outPutImage;
}

- (UIImage *)drawWaterMarkToCaptureImage:(UIImage *)captureImage
{
    CGFloat safeBottom = 0;
    if ([UIDevice lsqIsDeviceiPhoneX])
    {
        safeBottom = 44;
    }
    UIGraphicsBeginImageContext(captureImage.size);
    [captureImage drawInRect:CGRectMake(0, 0, captureImage.size.width, captureImage.size.height)];
    
    UIImage *waterMarkImage = [UIImage imageNamed:@"sample_watermark"];
    [waterMarkImage drawInRect:CGRectMake(captureImage.size.width - 220, safeBottom + 20, 200, 88)];
    
    UIImage *outPutImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     
    return outPutImage;
}

- (void)addJoinerFilter:(TuJoinerDirection)direction path:(NSString *)path {
    TUPMediaInspector_Result *result = [[TUPMediaInspector shared] inspect:path];
    CGSize videoSize = CGSizeZero;
    for (TUPMediaInspector_Result_Item *item in result.streams) {
        if ([item isKindOfClass:[TUPMediaInspector_Result_VideoItem classForCoder]]) {
            TUPMediaInspector_Result_VideoItem *videoItem = (TUPMediaInspector_Result_VideoItem *)item;
            videoSize = CGSizeMake(videoItem.width, videoItem.height);
            if (videoItem.rotation/90 % 2 == 0) {
                videoSize = CGSizeMake(videoItem.width, videoItem.height);
            } else {
                videoSize = CGSizeMake(videoItem.height, videoItem.width);
            }
        }
    }
    TUPConfig* config = [[TUPConfig alloc] init];
    [config setString:path forKey:TUPFPSimultaneouslyFilter_CONFIG_PATH];
    [config setDoubleNumber:[self getMixerSpeed] forKey:TUPFPSimultaneouslyFilter_CONFIG_STRETCH];
    CGRect cameraRect = CGRectZero;
    CGRect videoRect = CGRectZero;
    CGSize outputSize = CGSizeMake([_pipeInImage getWidth], [_pipeInImage getHeight]);
    if (direction == TuJoinerDirectionHorizontal) {
        cameraRect = CGRectMake(0, 0.25, 0.5, 0.5);
        if (videoSize.width > videoSize.height) {
            CGFloat heightPercent = outputSize.width/2 * (videoSize.height/videoSize.width) / outputSize.height;
            videoRect = CGRectMake(0.5, (1 - heightPercent)/2, 0.5, heightPercent);
        } else {
            CGFloat heightPercent = outputSize.width/2 * (videoSize.height/videoSize.width) / outputSize.height;
            videoRect = CGRectMake(0.5, (1 - heightPercent)/2, 0.5, heightPercent);
        }
    } else if (direction == TuJoinerDirectionVertical) {
        if (videoSize.width > videoSize.height) {
            CGFloat heightPercent = outputSize.width * (videoSize.height/videoSize.width) / outputSize.height;
            videoRect = CGRectMake(0, (0.5 - heightPercent)/2, 1, heightPercent);
        } else {
            CGFloat widthPercent = outputSize.height/2.0 * (videoSize.width/videoSize.height) / outputSize.width;
            videoRect = CGRectMake((1-widthPercent)/2, 0, widthPercent, 0.5);
        }
        //CGFloat cameraWidthPercent = outputSize.width/outputSize.height;
        cameraRect = CGRectMake(0.25, 0.5, 0.5, 0.5);
    } else if (direction == TuJoinerDirectionCross) {
        cameraRect = CGRectMake(0, 0, 1, 1);
        if (videoSize.width > videoSize.height){
            CGFloat width = 0.5f;
            CGFloat height = outputSize.width * width * (videoSize.height/videoSize.width) / outputSize.height;
            videoRect = CGRectMake(0.05, 0.15, width, height);
        } else {
            CGFloat height = 0.3f;
            CGFloat width = outputSize.height * height * (videoSize.width/videoSize.height) / outputSize.width;
            videoRect = CGRectMake(0.05, 0.15, width, height);
        }
    }
    self.joinerBuilder.videoDstRect = videoRect;
    self.joinerBuilder.cameraDstRect = cameraRect;
    [config setNumber:@(outputSize.width) forKey:TUPFPSimultaneouslyFilter_CONFIG_WIDTH];
    [config setNumber:@(outputSize.height) forKey:TUPFPSimultaneouslyFilter_CONFIG_HEIGHT];
    [self addJoinerFilterWithConfig:config];
}
- (void)addJoinerFilterWithConfig:(TUPConfig *)config {
    if (!config) {
        return;
    }
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:kJoinerFilterIndex]) {
            [self->_pipeline deleteFilterAt:kJoinerFilterIndex];
        }
        TUPFPFilter *filter = [[TUPFPFilter alloc] init:self->_pipeline.getContext withName:TUPFPSimultaneouslyFilter_TYPE_NAME];
        [filter setConfig:config];
        [self->_pipeline addFilter:filter at:kJoinerFilterIndex];
        
        [filter setProperty:[self.joinerBuilder makeRectProperty] forKey:TUPFPSimultaneouslyFilter_PROP_RECT_PARAM];
        [filter setProperty:[self.joinerBuilder makeSeekProperty] forKey:TUPFPSimultaneouslyFilter_PROP_SEEK_PARAM];
    }];
    NSString *path = [config getString:TUPFPSimultaneouslyFilter_CONFIG_PATH];
    [self addAudioMixer:path];
    self.mixerMode = TTAudioMixerModeJoiner;
}
- (void)updateJoinerPos:(NSInteger)pos {
    [self->_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:kJoinerFilterIndex];
        self.joinerBuilder.currentPos = pos;
        [filter setProperty:[self.joinerBuilder makeSeekProperty] forKey:TUPFPSimultaneouslyFilter_PROP_SEEK_PARAM];
    }];
}
- (void)updateJoinerFilterPlay:(BOOL)playing {
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:kJoinerFilterIndex];
        self.joinerBuilder.enable_play = playing;
        [filter setProperty:[self.joinerBuilder makeProperty] forKey:TUPFPSimultaneouslyFilter_PROP_PARAM];
    }];
}
- (void)updateJoinerFilterDirection:(TuJoinerDirection)joinerDirection {
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:kJoinerFilterIndex];
        TUPConfig *config = [filter getConfig];
        NSString *path = [config getString:TUPFPSimultaneouslyFilter_CONFIG_PATH];
        [self addJoinerFilter:joinerDirection path:path];
    }];
}
- (void)updateJoinerSpeed {
    [_pipeOprationQueue runSync:^{
        TUPFPFilter *filter = [self->_pipeline getFilter:kJoinerFilterIndex];
        TUPConfig *config = [filter getConfig];
        self.joinerBuilder.currentPos = [self getRecordingDuration];
        [config setDoubleNumber:[self getMixerSpeed] forKey:TUPFPSimultaneouslyFilter_CONFIG_STRETCH];
        [self addJoinerFilterWithConfig:config];
    }];
}
- (void)removeJoinerFilter {
    [_pipeOprationQueue runSync:^{
        if ([self->_pipeline getFilter:kJoinerFilterIndex]) {
            [self->_pipeline deleteFilterAt:kJoinerFilterIndex];
        }
    }];
}
- (TUPFPSimultaneouslyFilter_PropertyBuilder *)joinerBuilder {
    if (!_joinerBuilder) {
        _joinerBuilder = [[TUPFPSimultaneouslyFilter_PropertyBuilder alloc] init];
    }
    return _joinerBuilder;
}
- (void)addAudioMixer:(NSString *)path {
    self.audioMixerConfig.path = path;
    self.mixerMode = TTAudioMixerModeMusic;
    
    if (!_audioMixerQueue) {
        _audioMixerQueue = dispatch_queue_create("videorecord.audioMixerQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    _audioMixerData = malloc(1024*4);
    
}
- (void)startAudioMixerWithDuration:(NSInteger)pos {
    if (self.mixerMode == TTAudioMixerModeNone) {
        return;
    }
    if (_audioMixer) {
        [_audioMixer close];
    }
    _audioMixer = [[TUPFPAudioMixer alloc] init];
    _audioMixerConfig.startPos = pos;
    _audioMixerConfig.stretch = [self getMixerSpeed];
    [_audioMixer open:self.audioMixerConfig];
    self.startAudioMix = YES;
    [self audioMixerLoop];
}
- (void)onTuCameraDidOutputPlayBufferList:(AudioBufferList)bufferList {
    AudioBuffer buffer = bufferList.mBuffers[0];
    [self.audioMixer getPCMForPlay:buffer.mData andLength:buffer.mDataByteSize];
    //TTLog(@"audioMixer getPCMForPlay1 %d %d",ret, buffer.mDataByteSize);
}

- (void)audioMixerLoop {
    if (self.mixerMode == TTAudioMixerModeNone) {
        return;
    }
    dispatch_async(_audioMixerQueue, ^{
        while (1) {
            if (!self.startAudioMix) {
                break;
            }
            if (self->_recordFragments) {
                RecordFragment *fragment = [self->_recordFragments lastObject];
                if (fragment) {
                    int ret = [self.audioMixer getPCMForRecord:self->_audioMixerData andLength:1024*4];
                    //TTLog(@"audioMixer getPCMForRecord %d",ret);
                    if (ret > 0) {
                         [fragment.exporter sendAudio:self->_audioMixerData andSize:ret withTimestamp:fragment.audioTimeDuration];
                        //TTLog(@"audioMixer sendAudio %d",sendRet);
                    } else if (ret < 0) {
                        break;
                    }
                }
            }
        };
    });
}
- (void)pauseAudioMixer {
    [self updateJoinerFilterPlay:NO];
    self.startAudioMix = NO;
    if (_mixerMode != TTAudioMixerModeNone) {
        [_camera stopAudioUnit];
    }
}
- (TUPFPAudioMixer_Config *)audioMixerConfig {
    if (!_audioMixerConfig) {
        _audioMixerConfig = [[TUPFPAudioMixer_Config alloc] init];
        _audioMixerConfig.sampleRate = 44100;
        _audioMixerConfig.channels = 1;
        _audioMixerConfig.sampleCount = 1024;
        _audioMixerConfig.fileMixWeight = 0.3;
        _audioMixerConfig.recordMixWeight = self.disableMicrophone ? 0 : 0.5;
    }
    return _audioMixerConfig;
}
- (void)setDisableMicrophone:(BOOL)disableMicrophone {
    _disableMicrophone = disableMicrophone;
    if (self.mixerMode != TTAudioMixerModeNone) {
        _audioMixerConfig.recordMixWeight = disableMicrophone ? 0 : 0.5;
    }
}
- (void)setMixerMode:(TTAudioMixerMode)mixerMode {
    _mixerMode = mixerMode;
    [self.camera audioUnitRecord:(mixerMode != TTAudioMixerModeNone)];
}
@end
