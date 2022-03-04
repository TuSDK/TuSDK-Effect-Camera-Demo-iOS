//
//  TTBeautyManager.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTBeautyManager.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>
#import <TuSDKPulse/TuSDKPulse.h>
#import "TTEffectFactory.h"

static NSInteger const kFilterIndex = 100;

@interface TTBeautyManager ()
@property(nonatomic, strong) TUPDispatchQueue *queue;
/// 编辑
@property(nonatomic, strong) TUPFilterPipe *pipe;
@property(nonatomic, assign) BOOL pbout;
@property(nonatomic, assign) BOOL markSenceEnable;
@property(nonatomic, strong) TUPFPImage *inFPImage;
@property(nonatomic, strong) TTEffectFactory *effectFactory;
/// 微整形
@property(nonatomic, strong) TUPFPTusdkFacePlasticFilter_PropertyBuilder *plasticBuilder;
/// 微整形改造
@property(nonatomic, strong) TUPFPTusdkFaceReshapeFilter_PropertyBuilder *reshapeBuilder;
/// 美妆
@property(nonatomic, strong) TUPFPTusdkCosmeticFilter_PropertyBuilder *cosmeticBuilder;
/// 美肤
@property(nonatomic, assign) TTSkinStyle skinStyle;
/// 自然美肤
@property(nonatomic, strong) TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder *naturalBuilder;
/// 极致美肤
@property(nonatomic, strong) TUPFPTusdkImageFilter_SkinHazyPropertyBuilder *hazyBuilder;
/// 精准美肤
@property(nonatomic, strong) TUPFPTusdkBeautFaceV2Filter_PropertyBuilder *beautyBuilder;
/// 滤镜
@property(nonatomic, strong) TUPFPTusdkImageFilter_Type10PropertyBuilder *filterBuilder;
/// 合拍
@property (nonatomic, strong) TUPFPSimultaneouslyFilter_PropertyBuilder *joinerBuilder;

@end

@implementation TTBeautyManager

- (instancetype)initWithQueue:(TUPDispatchQueue *)queue {
    self = [super init];
    if (self) {
        _queue = queue;
        _markSenceEnable = NO;
        _pbout = NO;
        [_queue runSync:^{
            self.pipe = [[TUPFilterPipe alloc] init];
            if (self.pbout) {
                TUPConfig *config = [self.pipe getConfig];
                [config setIntNumber:1 forKey:@"pbout"];
                [self.pipe setConfig:config];
            }
            [self.pipe open];
        }];
        _effectFactory = [[TTEffectFactory alloc] init];
        
        _plasticBuilder = [[TUPFPTusdkFacePlasticFilter_PropertyBuilder alloc] init];
        _reshapeBuilder = [[TUPFPTusdkFaceReshapeFilter_PropertyBuilder alloc] init];
        _cosmeticBuilder = [[TUPFPTusdkCosmeticFilter_PropertyBuilder alloc] init];
        _naturalBuilder = [[TUPFPTusdkImageFilter_SkinNaturalPropertyBuilder alloc] init];
        _hazyBuilder = [[TUPFPTusdkImageFilter_SkinHazyPropertyBuilder alloc] init];
        _beautyBuilder = [[TUPFPTusdkBeautFaceV2Filter_PropertyBuilder alloc] init];
        _filterBuilder = [[TUPFPTusdkImageFilter_Type10PropertyBuilder alloc] init];
        _joinerBuilder = [[TUPFPSimultaneouslyFilter_PropertyBuilder alloc] init];
        
        [self setupDefault];
    }
    return self;
}

- (void)setupDefault {
    // 设置默认参数
    [self defaultParams:TTEffectTypePlastic];
    [self defaultParams:TTEffectTypeSkin];
    
    // 添加默认特效
    [self addEffect:TTEffectTypePlastic];
    [self addEffect:TTEffectTypeSkin];
}

/// 默认参数
- (void)defaultParams:(TTEffectType)effectType {
    switch (effectType) {
        case TTEffectTypePlastic: {
            self.plasticBuilder.eyeEnlarge = 0.3;
            self.plasticBuilder.cheekThin = 0.5;
            self.plasticBuilder.noseWidth = 0.2;
        }
            break;
        case TTEffectTypeSkin: {
            _skinStyle = TTSkinStyleNatural;
            self.naturalBuilder.smoothing = 0.8;
            self.naturalBuilder.fair = 0.3;
            self.naturalBuilder.ruddy = 0.2;
            
            self.hazyBuilder.smoothing = 0.8;
            self.hazyBuilder.fair = 0.3;
            self.hazyBuilder.ruddy = 0.2;
            
            self.beautyBuilder.smoothing = 0.8;
            self.beautyBuilder.whiten = 0.3;
            self.beautyBuilder.sharpen = 0.6;
        }
            break;
        case TTEffectTypeFilter: {
            self.filterBuilder.strength = 0.75;
        }
            break;
        default:
            break;
    }
}

- (NSInteger)indexWithEffect:(TTEffectType)effectType {
    return effectType + kFilterIndex;
}

- (TTEffectSettings *)settingsWithEffect:(TTEffectType)effectType {
    TTEffectSettings *settings = [self.effectFactory settingsWithEffect:effectType];
    if (effectType == TTEffectTypeSkin) {
        settings = [self.effectFactory skinSettingsWithEffect:self.skinStyle];
    }
    return settings;
}

- (nullable TUPFPFilter *)filterWithEffect:(TTEffectType)effectType {
    TUPFPFilter *filter = [self.pipe getFilter:[self indexWithEffect:effectType]];
    return filter;
}

/// 设置特效参数
- (void)setProperty:(TTEffectType)effectType filter:(TUPFPFilter *)filter {
    TUPProperty *property;
    switch (effectType) {
        case TTEffectTypePlastic:
            property = [self.plasticBuilder makeProperty];
            break;
        case TTEffectTypeReshape:
            property = [self.reshapeBuilder makeProperty];
            break;
        case TTEffectTypeCosmetic:
            property = [self.cosmeticBuilder makeProperty];
            break;
        case TTEffectTypeSkin:
            if (self.skinStyle == TTSkinStyleNatural) {
                property = [self.naturalBuilder makeProperty];
            } else if (self.skinStyle == TTSkinStyleHazy) {
                property = [self.hazyBuilder makeProperty];
            } else {
                property = [self.beautyBuilder makeProperty];
            }
            break;
        case TTEffectTypeFilter:
            property = [self.filterBuilder makeProperty];
            break;
        case TTEffectTypeJoiner:
            [filter setProperty:[self.joinerBuilder makeRectProperty] forKey:TUPFPSimultaneouslyFilter_PROP_RECT_PARAM];
            [filter setProperty:[self.joinerBuilder makeSeekProperty] forKey:TUPFPSimultaneouslyFilter_PROP_SEEK_PARAM];
            break;
        default:
            break;
    }
    if (!property) {
        return;
    }
    [filter setProperty:property forKey:TUPFPTusdkImageFilter_PROP_PARAM];
}

- (TUPFPImage *)sendFPImage:(TUPFPImage *)fpImage {
    _inFPImage = fpImage;
    self.markSenceEnable = NO;
    if ([self filterWithEffect:TTEffectTypeReshape] || [self filterWithEffect:TTEffectTypeCosmetic]) {
        self.markSenceEnable = YES;
    }
    [fpImage setMarkSenceEnable:self.markSenceEnable];
    return [self.pipe process:fpImage];
}

/// 添加特效
- (void)addEffect:(TTEffectType)effectType {
    NSInteger index = [self indexWithEffect:effectType];
    TTEffectSettings *settings = [self settingsWithEffect:effectType];
    
    [self.queue runSync:^{
        if ([self.pipe getFilter:index]) {
            [self.pipe deleteFilterAt:index];
        }
        TUPFPFilter *filter = [[TUPFPFilter alloc] init:[self.pipe getContext] withName:settings.name];
        if (settings.config) {
            [filter setConfig:settings.config];
        }
        BOOL res = [self.pipe addFilter:filter at:index];
        NSLog(@"TTBeautyManager addEffect: %ld Description: %@ res: %d", index, TTEffectTypeDescription(effectType), res);
        [self setProperty:effectType filter:filter];
    }];
}

/// 更新特效
- (void)updateEffect:(TTEffectType)effectType {
    NSLog(@"TTBeautyManager updateEffect: %@", TTEffectTypeDescription(effectType));
    TUPFPFilter *filter = [self filterWithEffect:effectType];
    if (!filter) {
        [self addEffect:effectType];
        return;
    }
    [self.queue runSync:^{
        [self setProperty:effectType filter:filter];
    }];
}

/// 移除特效
- (void)removeEffect:(TTEffectType)effectType {
    NSInteger index = [self indexWithEffect:effectType];
    [self.queue runSync:^{
        BOOL res = [self.pipe deleteFilterAt:index];
        NSLog(@"TTBeautyManager removeEffect: %@ res: %d", TTEffectTypeDescription(effectType), res);
    }];
}

/// 重置特效
- (void)resetEffect:(TTEffectType)effectType {
    if (effectType == TTEffectTypePlastic) {
        [self defaultParams:TTEffectTypePlastic];
        [self addEffect:TTEffectTypePlastic];
        return;
    }
    [self removeEffect:effectType];
}

- (void)destory {
    [self.queue runSync:^{
        [self.pipe clearFilters];
        [self.pipe close];
    }];
    _pipe = nil;
    _inFPImage = nil;
}

/// 设置美肤（磨皮）算法
- (void)setSkinStyle:(TTSkinStyle)skinStyle {
    if (_skinStyle == skinStyle) {
        return;
    }
    _skinStyle = skinStyle;
    [self addEffect:TTEffectTypeSkin];
}

/// 设置磨皮级别
- (void)setSmoothLevel:(float)level {
    switch (self.skinStyle) {
        case TTSkinStyleNatural:
            self.naturalBuilder.smoothing = level;
            break;
        case TTSkinStyleHazy:
            self.hazyBuilder.smoothing = level;
            break;
        case TTSkinStyleBeauty:
            self.beautyBuilder.smoothing = level;
    }
    [self updateEffect:TTEffectTypeSkin];
}

/// 设置美白级别
- (void)setWhiteningLevel:(float)level {
    switch (self.skinStyle) {
        case TTSkinStyleNatural:
            self.naturalBuilder.fair = level;
            break;
        case TTSkinStyleHazy:
            self.hazyBuilder.fair = level;
            break;
        case TTSkinStyleBeauty:
            self.beautyBuilder.whiten = level;
    }
    [self updateEffect:TTEffectTypeSkin];
}

/// 设置红润级别
- (void)setRuddyLevel:(float)level {
    switch (self.skinStyle) {
        case TTSkinStyleNatural:
            self.naturalBuilder.ruddy = level;
            [self updateEffect:TTEffectTypeSkin];
            break;
        case TTSkinStyleHazy:
            self.hazyBuilder.ruddy = level;
            [self updateEffect:TTEffectTypeSkin];
            break;
        default:
            break;
    }
}

/// 设置锐化级别
- (void)setSharpenLevel:(float)level {
    self.beautyBuilder.sharpen = 0.6;
    [self updateEffect:TTEffectTypeSkin];
}

// MARK: - 微整形

/// 设置大眼级别
- (void)setEyeEnlargeLevel:(float)level {
    self.plasticBuilder.eyeEnlarge = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置瘦脸级别
- (void)setCheekThinLevel:(float)level {
    self.plasticBuilder.cheekThin = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置窄脸级别
- (void)setCheekNarrowLevel:(float)level {
    self.plasticBuilder.cheekNarrow = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置小脸级别
- (void)setFaceSmallLevel:(float)level {
    self.plasticBuilder.faceSmall = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置瘦鼻级别
- (void)setNoseWidthLevel:(float)level {
    self.plasticBuilder.noseWidth = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置长鼻级别
- (void)setNoseHeightLevel:(float)level {
    self.plasticBuilder.noseHeight = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置嘴型级别
- (void)setMouthWidthLevel:(float)level {
    self.plasticBuilder.mouthWidth = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置唇厚级别
- (void)setLipsThicknessLevel:(float)level {
    self.plasticBuilder.lipsThickness = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置瘦人中级别
- (void)setPhilterumThicknessLevel:(float)level {
    self.plasticBuilder.philterumThickness = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置细眉级别
- (void)setBrowThicknessLevel:(float)level {
    self.plasticBuilder.browThickness = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置眉高级别
- (void)setBrowHeightLevel:(float)level {
    self.plasticBuilder.browHeight = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置下巴（拉伸或收缩）级别
- (void)setChinThicknessLevel:(float)level {
    self.plasticBuilder.chinThickness = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置下颌骨级别
- (void)setCheekLowBoneNarrowLevel:(float)level {
    self.plasticBuilder.cheekLowBoneNarrow = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置眼角级别
- (void)setEyeAngleLevel:(float)level {
    self.plasticBuilder.eyeAngle = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置开内眼角级别
- (void)setEyeInnerConerLevel:(float)level {
    self.plasticBuilder.eyeInnerConer = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置开外眼角级别
- (void)setEyeOuterConerLevel:(float)level {
    self.plasticBuilder.eyeOuterConer = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置眼距级别
- (void)setEyeDistanceLevel:(float)level {
    self.plasticBuilder.eyeDistance = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置眼移动级别
- (void)setEyeHeightLevel:(float)level {
    self.plasticBuilder.eyeHeight = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置发际线级别
- (void)setForeheadHeightLevel:(float)level {
    self.plasticBuilder.foreheadHeight = level;
    [self updateEffect:TTEffectTypePlastic];
}

/// 设置瘦颧骨级别
- (void)setCheekBoneNarrowLevel:(float)level {
    self.plasticBuilder.cheekBoneNarrow = level;
    [self updateEffect:TTEffectTypePlastic];
}

// MARK: - 微整形改造
/// 设置双眼皮级别
- (void)setEyelidLevel:(float)level {
    self.reshapeBuilder.eyelidOpacity = level;
    [self updateEffect:TTEffectTypeReshape];
}

/// 设置卧蚕级别
- (void)setEyemazingLevel:(float)level {
    self.reshapeBuilder.eyemazingOpacity = level;
    [self updateEffect:TTEffectTypeReshape];
}

/// 设置白牙级别
- (void)setWhitenTeethLevel:(float)level {
    self.reshapeBuilder.whitenTeethOpacity = level;
    [self updateEffect:TTEffectTypeReshape];
}

/// 设置亮眼级别
- (void)setEyeDetailLevel:(float)level {
    self.reshapeBuilder.eyeDetailOpacity = level;
    [self updateEffect:TTEffectTypeReshape];
}

/// 设置祛黑眼圈级别
- (void)setRemovePouchLevel:(float)level {
    self.reshapeBuilder.removePouchOpacity = level;
    [self updateEffect:TTEffectTypeReshape];
}

/// 设置祛法令纹级别
- (void)setRemoveWrinklesLevel:(float)level {
    self.reshapeBuilder.removeWrinklesOpacity = level;
    [self updateEffect:TTEffectTypeReshape];
}

// MARK: - 美妆
/// 设置口红
- (void)setLipEnable:(BOOL)enable {
    self.cosmeticBuilder.lipEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setLipStyle:(TTBeautyLipstickStyle)style {
    if (!self.cosmeticBuilder.lipEnable) {
        return;
    }
    self.cosmeticBuilder.lipStyle = style;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setLipOpacity:(float)opacity {
    if (!self.cosmeticBuilder.lipEnable) {
        return;
    }
    self.cosmeticBuilder.lipOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setLipSticker:(float)idt {
    if (!self.cosmeticBuilder.lipEnable) {
        return;
    }
    self.cosmeticBuilder.lipColor = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

/// 设置腮红
- (void)setBlushEnable:(BOOL)enable {
    self.cosmeticBuilder.blushEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setBlushOpacity:(float)opacity {
    if (!self.cosmeticBuilder.blushEnable) {
        return;
    }
    self.cosmeticBuilder.blushOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setBlushSticker:(float)idt {
    if (!self.cosmeticBuilder.blushEnable) {
        return;
    }
    self.cosmeticBuilder.blushId = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

/// 设置眉毛
- (void)setBrowEnable:(BOOL)enable {
    self.cosmeticBuilder.browEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setBrowOpacity:(float)opacity {
    if (!self.cosmeticBuilder.browEnable) {
        return;
    }
    self.cosmeticBuilder.browOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setBrowSticker:(float)idt {
    if (!self.cosmeticBuilder.browEnable) {
        return;
    }
    self.cosmeticBuilder.browId = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

/// 设置眼影
- (void)setEyeshadowEnable:(BOOL)enable {
    self.cosmeticBuilder.eyeshadowEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setEyeshadowOpacity:(float)opacity {
    if (!self.cosmeticBuilder.eyeshadowEnable) {
        return;
    }
    self.cosmeticBuilder.eyeshadowOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setEyeshadowSticker:(float)idt {
    if (!self.cosmeticBuilder.eyeshadowEnable) {
        return;
    }
    self.cosmeticBuilder.eyeshadowId = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

/// 设置眼线
- (void)setEyelineEnable:(BOOL)enable {
    self.cosmeticBuilder.eyelineEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setEyelineOpacity:(float)opacity {
    if (!self.cosmeticBuilder.eyelineEnable) {
        return;
    }
    self.cosmeticBuilder.eyelineOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setEyelineSticker:(float)idt {
    if (!self.cosmeticBuilder.eyelineEnable) {
        return;
    }
    self.cosmeticBuilder.eyelineId = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

/// 设置睫毛
- (void)setEyelashEnable:(BOOL)enable {
    self.cosmeticBuilder.eyelashEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setEyelashOpacity:(float)opacity {
    if (!self.cosmeticBuilder.eyelashEnable) {
        return;
    }
    self.cosmeticBuilder.eyelashOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setEyelashSticker:(float)idt {
    if (!self.cosmeticBuilder.eyelashEnable) {
        return;
    }
    self.cosmeticBuilder.eyelashId = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

/// 设置修容
- (void)setFacialEnable:(BOOL)enable {
    self.cosmeticBuilder.facialEnable = enable;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setFacialOpacity:(float)opacity {
    if (!self.cosmeticBuilder.facialEnable) {
        return;
    }
    self.cosmeticBuilder.facialOpacity = opacity;
    [self updateEffect:TTEffectTypeCosmetic];
}

- (void)setFacialSticker:(float)idt {
    if (!self.cosmeticBuilder.facialEnable) {
        return;
    }
    self.cosmeticBuilder.facialId = idt;
    [self updateEffect:TTEffectTypeCosmetic];
}

// MARK: - Filter

/// 设置滤镜
- (void)setFilter:(NSString *)code {
    if ([code isEqualToString:@"Normal"]) {
        [self removeEffect:TTEffectTypeFilter];
        return;
    }
    [self.effectFactory fetchEffect:TTEffectTypeFilter setString:code forKey:TUPFPTusdkImageFilter_CONFIG_NAME];
    [self addEffect:TTEffectTypeFilter];
}

/// 设置滤镜的强度
- (void)setFilterStrength:(float)strength {
    self.filterBuilder.strength = strength;
    [self updateEffect:TTEffectTypeFilter];
}

/// 设置动态贴纸
- (void)setLiveSticker:(NSInteger)idt {
    [self.effectFactory fetchEffect:TTEffectTypeLiveSticker setNumber:@(idt) forKey:TUPFPTusdkLiveStickerFilter_CONFIG_GROUP];
    [self addEffect:TTEffectTypeLiveSticker];
}

/// 设置哈哈镜
- (void)setMonsterStyle:(TTMonsterStyle)monsterStyle {
    if (monsterStyle == TTMonsterStyleEmpty) {
        [self removeEffect:TTEffectTypeMonster];
        return;
    }
    [self.effectFactory fetchMonster:monsterStyle];
    [self addEffect:TTEffectTypeMonster];
}

/// 设置合拍
- (void)setJoiner:(TTJoinerDirection)direction videoPath:(NSString *)videoPath {
    if (!videoPath) {
        return;
    }
    CGSize outputSize = CGSizeMake([self.inFPImage getWidth], [self.inFPImage getHeight]);
    // config
    [self.effectFactory fetchEffect:TTEffectTypeJoiner setNumber:@(1) forKey:TUPFPSimultaneouslyFilter_CONFIG_STRETCH];
    [self.effectFactory fetchEffect:TTEffectTypeJoiner setString:videoPath forKey:TUPFPSimultaneouslyFilter_CONFIG_PATH];
    [self.effectFactory fetchEffect:TTEffectTypeJoiner setNumber:@(outputSize.width) forKey:TUPFPSimultaneouslyFilter_CONFIG_WIDTH];
    [self.effectFactory fetchEffect:TTEffectTypeJoiner setNumber:@(outputSize.height) forKey:TUPFPSimultaneouslyFilter_CONFIG_HEIGHT];
    // property
    CGSize videoSize = [TTBeautyManager videoSizeWithPath:videoPath];
    self.joinerBuilder.cameraDstRect = [TTBeautyManager joinerCameraRect:direction];
    self.joinerBuilder.videoDstRect = [TTBeautyManager joinerVideoRect:direction outputSize:outputSize videoSize:videoSize];
    
    [self addEffect:TTEffectTypeJoiner];
}

/// 更新合拍 布局
- (void)updateJoinerDirection:(TTJoinerDirection)direction {
    if (![self filterWithEffect:TTEffectTypeJoiner]) {
        return;
    }
    NSString *videoPath = [self.effectFactory stringForKey:TUPFPSimultaneouslyFilter_CONFIG_PATH inEffect:TTEffectTypeJoiner];
    if (!videoPath) {
        return;
    }
    CGSize outputSize = CGSizeMake([self.inFPImage getWidth], [self.inFPImage getHeight]);
    CGSize videoSize = [TTBeautyManager videoSizeWithPath:videoPath];
    self.joinerBuilder.cameraDstRect = [TTBeautyManager joinerCameraRect:direction];
    self.joinerBuilder.videoDstRect = [TTBeautyManager joinerVideoRect:direction outputSize:outputSize videoSize:videoSize];
    
    [self addEffect:TTEffectTypeJoiner];
}

/// 设置合拍变速
- (void)setJoinerSpeed:(TTVideoRecordSpeed)speed startTime:(NSInteger)startTime {
    if (![self filterWithEffect:TTEffectTypeJoiner]) {
        return;
    }
    
    TTEffectSettings *settings = [_effectFactory settingsWithEffect:TTEffectTypeJoiner];
    [settings.config setDoubleNumber:TTVideoRecordSpeedMixerValue(speed) forKey:TUPFPSimultaneouslyFilter_CONFIG_STRETCH];
    self.joinerBuilder.currentPos = startTime;
    [self addEffect:TTEffectTypeJoiner];
}

/// 获取合拍布局
- (CGRect)getJoinerVideoRect
{
    return self.joinerBuilder.videoDstRect;
}

/// 播放/暂停合拍素材
- (void)playJoiner:(BOOL)playing {
    TUPFPFilter *filter = [self filterWithEffect:TTEffectTypeJoiner];
    if (!filter) {
        return;
    }
    [_queue runSync:^{
        self.joinerBuilder.enable_play = playing;
        [filter setProperty:[self.joinerBuilder makeProperty] forKey:TUPFPSimultaneouslyFilter_PROP_PARAM];
    }];
}

/// 设置合拍开始播放时间
- (void)setJoinerStartTime:(NSInteger)startTime {
    TUPFPFilter *filter = [self filterWithEffect:TTEffectTypeJoiner];
    if (!filter) {
        return;
    }
    
    [_queue runSync:^{
        self.joinerBuilder.currentPos = startTime;
        [filter setProperty:[self.joinerBuilder makeSeekProperty] forKey:TUPFPSimultaneouslyFilter_PROP_SEEK_PARAM];
    }];
}


+ (CGSize)videoSizeWithPath:(NSString *)videoPath {
    TUPMediaInspector_Result *result = [[TUPMediaInspector shared] inspect:videoPath];
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
    return videoSize;
}

/// 合拍 相机采集 归一化Frame
/// @param direction 方向
+ (CGRect)joinerCameraRect:(TTJoinerDirection)direction {
    switch (direction) {
        case TTJoinerDirectionHorizontal:
            return CGRectMake(0, 0.25, 0.5, 0.5);
        case TTJoinerDirectionVertical:
            return CGRectMake(0.25, 0.5, 0.5, 0.5);
        case TTJoinerDirectionCross:
            return CGRectMake(0, 0, 1, 1);
        default:
            break;
    }
}

/// 合拍 视频 归一化Frame
/// @param direction 布局
/// @param outputSize 画布尺寸
/// @param videoSize 视频尺寸
+ (CGRect)joinerVideoRect:(TTJoinerDirection)direction outputSize:(CGSize)outputSize videoSize:(CGSize)videoSize {
    CGRect videoRect = CGRectZero;
    switch (direction) {
        case TTJoinerDirectionHorizontal:
            if (videoSize.width > videoSize.height) {
                CGFloat heightPercent = outputSize.width/2 * (videoSize.height/videoSize.width) / outputSize.height;
                videoRect = CGRectMake(0.5, (1 - heightPercent)/2, 0.5, heightPercent);
            } else {
                CGFloat heightPercent = outputSize.width/2 * (videoSize.height/videoSize.width) / outputSize.height;
                videoRect = CGRectMake(0.5, (1 - heightPercent)/2, 0.5, heightPercent);
            }
            break;
        case TTJoinerDirectionVertical:
            if (videoSize.width > videoSize.height) {
                CGFloat heightPercent = outputSize.width * (videoSize.height/videoSize.width) / outputSize.height;
                videoRect = CGRectMake(0, (0.5 - heightPercent)/2, 1, heightPercent);
            } else {
                CGFloat widthPercent = outputSize.height/2.0 * (videoSize.width/videoSize.height) / outputSize.width;
                videoRect = CGRectMake((1-widthPercent)/2, 0, widthPercent, 0.5);
            }
            break;
        case TTJoinerDirectionCross:
            if (videoSize.width > videoSize.height){
                CGFloat width = 0.5f;
                CGFloat height = outputSize.width * width * (videoSize.height/videoSize.width) / outputSize.height;
                videoRect = CGRectMake(0.05, 0.15, width, height);
            } else {
                CGFloat height = 0.3f;
                CGFloat width = outputSize.height * height * (videoSize.width/videoSize.height) / outputSize.width;
                videoRect = CGRectMake(0.05, 0.15, width, height);
            }
            break;
        default:
            break;
    }
    return videoRect;
}

@end
