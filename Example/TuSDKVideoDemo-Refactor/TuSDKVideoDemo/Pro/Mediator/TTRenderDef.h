//
//  TTRenderDef.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2022/1/6.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TT_INIT_UNAVAILABLE - (instancetype)init NS_UNAVAILABLE; \
                            + (instancetype)new  NS_UNAVAILABLE;
/// 录制分辨率
typedef NS_ENUM(NSUInteger, TTVideoResolution) {
    /// 540P 分辨率
    TTVideoResolution960x540,
    /// 720P 分辨率
    TTVideoResolution1280x720,
    /// 1080P 分辨率
    TTVideoResolution1920x1080,
    /// 360P 分辨率
    TTVideoResolution3840x2160,
};

/// 画面比例
typedef NS_ENUM(NSUInteger, TTVideoAspectRatio) {
    TTVideoAspectRatio_Default,
    /// full
    TTVideoAspectRatio_full,
    /// 3:4
    TTVideoAspectRatio_3_4,
    /// 4:3
    TTVideoAspectRatio_4_3,
    /// 1:1
    TTVideoAspectRatio_1_1,
    /// 16:9
    TTVideoAspectRatio_16_9,
    /// 9:16
    TTVideoAspectRatio_9_16,
    /// 2:3
    TTVideoAspectRatio_2_3,
    /// 3:2
    TTVideoAspectRatio_3_2,
};

/// 视频像素格式
typedef NS_ENUM(NSUInteger, TTVideoPixelFormat) {
    /// YUV420P(I420) 格式
    TTVideoPixelFormat_YUV,
    /// BGRA 格式
    TTVideoPixelFormat_BGRA
};

/// 视频水印位置
typedef NS_ENUM(NSUInteger, TTVideoWaterMarkPosition) {
    TTVideoWaterMarkPositionTopLeft,
    TTVideoWaterMarkPositionTopRight,
    TTVideoWaterMarkPositionBottomLeft,
    TTVideoWaterMarkPositionBottomRight,
};

/// 录制视频速率
typedef NS_ENUM(NSUInteger, TTVideoRecordSpeed) {
    ///极慢速
    TTVideoRecordSpeed_SLOWEST,
    ///慢速
    TTVideoRecordSpeed_SLOW,
    ///正常速
    TTVideoRecordSpeed_NOMAL,
    ///快速
    TTVideoRecordSpeed_FAST,
    ///极快速
    TTVideoRecordSpeed_FASTEST,
};

/// 变声
typedef NS_ENUM(NSUInteger, TTVideoSoundPitchType) {
    /// 正常
    TTVideoSoundPitchType_Normal,
    /// 怪兽
    TTVideoSoundPitchType_Monster,
    /// 大叔
    TTVideoSoundPitchType_Uncle,
    /// 女生
    TTVideoSoundPitchType_Girl,
    /// 萝莉
    TTVideoSoundPitchType_Lolita,
};

/// 混音类型
typedef NS_ENUM(NSInteger, TTAudioMixerMode) {
    TTAudioMixerMode_None,
    TTAudioMixerMode_Music, // 背景音乐
    TTAudioMixerMode_Joiner, // 合拍
};

/// 特效类型
typedef NS_ENUM(NSUInteger, TTEffectType) {
    /// 微整形
    TTEffectTypePlastic,
    /// 微整形改造
    TTEffectTypeReshape,
    /// 美妆
    TTEffectTypeCosmetic,
    /// 美肤
    TTEffectTypeSkin,
    /// 滤镜
    TTEffectTypeFilter,
    /// 动态贴纸
    TTEffectTypeLiveSticker,
    /// 哈哈镜
    TTEffectTypeMonster,
    /// 合拍
    TTEffectTypeJoiner
};

/// 美肤（磨皮）算法
typedef NS_ENUM(NSUInteger, TTSkinStyle) {
    /// 自然，算法更多地保留了面部细节，磨皮效果更加自然
    TTSkinStyleNatural = 0,

    /// 极致，算法比较激进，磨皮效果比较明显
    TTSkinStyleHazy = 1,

    /// 精准，磨皮效果介于光滑和自然之间，比光滑保留更多皮肤细节，比自然磨皮程度更高。
    TTSkinStyleBeauty = 2
};

/// 美妆-口红 样式
typedef NS_ENUM(NSUInteger, TTBeautyLipstickStyle) {
    /// 水润
    TTBeautyLipstickStyleWaterWet,
    /// 滋润
    TTBeautyLipstickStyleMoist,
    /// 雾面
    TTBeautyLipstickStyleMatte,
};

/// 美妆-眉毛 样式
typedef NS_ENUM(NSUInteger, TTBeautyEyebrowStyle) {
    /// 雾眉
    TTBeautyEyebrowStyleFog,
    /// 雾根眉
    TTBeautyEyebrowStyleFogen,
};

/// 哈哈镜 样式
typedef NS_ENUM(NSUInteger, TTMonsterStyle) {
    /// 无
    TTMonsterStyleEmpty,
    /// 大鼻子
    TTMonsterStyleBigNose,
    /// 大饼脸
    TTMonsterStylePieFace,
    /// 国字脸
    TTMonsterStyleSquareFace,
    /// 厚嘴唇
    TTMonsterStyleThickLips,
    /// 眯眯眼
    TTMonsterStyleSmallEyes,
    /// 木瓜脸
    TTMonsterStylePapayaFace,
    /// 蛇精脸
    TTMonsterStyleSnakeFace,
};

/// 合拍 布局
typedef NS_ENUM(NSInteger, TTJoinerDirection) {
    TTJoinerDirectionHorizontal, //左右
    TTJoinerDirectionVertical, // 上下
    TTJoinerDirectionCross // 抢镜
};

typedef NS_ENUM(NSUInteger, TTRecordState) {
    TTRecordStateStopped,
    TTRecordStatePrepare,
    TTRecordStateRecording,
    TTRecordStatePaused,
    TTRecordStateComplete,
};

FOUNDATION_EXPORT CGFloat TTVideoRecordSpeedValue(TTVideoRecordSpeed speed);
FOUNDATION_EXPORT CGFloat TTVideoRecordSpeedMixerValue(TTVideoRecordSpeed speed);
FOUNDATION_EXPORT NSString *TTEffectTypeDescription(TTEffectType type);

@protocol TTBeautyProtocol <NSObject>

/// 添加特效
- (void)addEffect:(TTEffectType)effectType;
/// 移除特效
- (void)removeEffect:(TTEffectType)effectType;

/// 重置特效
- (void)resetEffect:(TTEffectType)effectType;

// MARK: - 美肤

/// 设置美肤（磨皮）算法
/// @param skinStyle 自然 极致 新美颜
- (void)setSkinStyle:(TTSkinStyle)skinStyle;

/// 设置磨皮级别
- (void)setSmoothLevel:(float)level;

/// 设置美白级别
- (void)setWhiteningLevel:(float)level;

/// 设置红润级别
- (void)setRuddyLevel:(float)level;

/// 设置锐化级别
- (void)setSharpenLevel:(float)level;

// MARK: - 微整形

/// 设置大眼级别 取值范围0 - 1
- (void)setEyeEnlargeLevel:(float)level;

/// 设置瘦脸级别 取值范围0 - 1
- (void)setCheekThinLevel:(float)level;

/// 设置窄脸级别 取值范围0 - 1
- (void)setCheekNarrowLevel:(float)level;

/// 设置小脸级别 取值范围0 - 1
- (void)setFaceSmallLevel:(float)level;

/// 设置瘦鼻级别 取值范围0 - 1
- (void)setNoseWidthLevel:(float)level;

/// 设置长鼻级别 取值范围0 - 1
- (void)setNoseHeightLevel:(float)level;

/// 设置嘴型级别 取值范围-1 - 1
- (void)setMouthWidthLevel:(float)level;

/// 设置唇厚级别 取值范围-1 - 1
- (void)setLipsThicknessLevel:(float)level;

/// 设置瘦人中级别 取值范围-1 - 1
- (void)setPhilterumThicknessLevel:(float)level;

/// 设置细眉级别 取值范围-1 - 1
- (void)setBrowThicknessLevel:(float)level;

/// 设置眉高级别 取值范围-1 - 1
- (void)setBrowHeightLevel:(float)level;

/// 设置下巴（拉伸或收缩）级别 取值范围-1 - 1
- (void)setChinThicknessLevel:(float)level;

/// 设置下颌骨级别 取值范围0 - 1
- (void)setCheekLowBoneNarrowLevel:(float)level;

/// 设置眼角级别 取值范围-1 - 1
- (void)setEyeAngleLevel:(float)level;

/// 设置开内眼角级别 取值范围0 - 1
- (void)setEyeInnerConerLevel:(float)level;

/// 设置开外眼角级别 取值范围0 - 1
- (void)setEyeOuterConerLevel:(float)level;

/// 设置眼距级别 取值范围-1 - 1
- (void)setEyeDistanceLevel:(float)level;

/// 设置眼移动级别 取值范围-1 - 1
- (void)setEyeHeightLevel:(float)level;

/// 设置发际线级别 取值范围-1 - 1
- (void)setForeheadHeightLevel:(float)level;

/// 设置瘦颧骨级别 取值范围0 - 1
- (void)setCheekBoneNarrowLevel:(float)level;

// MARK: - 微整形改造

/// 设置双眼皮级别 取值范围0 - 1
- (void)setEyelidLevel:(float)level;

/// 设置卧蚕级别 取值范围0 - 1
- (void)setEyemazingLevel:(float)level;

/// 设置白牙级别 取值范围0 - 1
- (void)setWhitenTeethLevel:(float)level;

/// 设置亮眼级别 取值范围0 - 1
- (void)setEyeDetailLevel:(float)level;

/// 设置祛黑眼圈级别 取值范围0 - 1
- (void)setRemovePouchLevel:(float)level;

/// 设置祛法令纹级别 取值范围0 - 1
- (void)setRemoveWrinklesLevel:(float)level;

// MARK: - 美妆

/// 设置口红开关
- (void)setLipEnable:(BOOL)enable;

/// 设置口红样式
/// @param style 水润 滋润 雾面
- (void)setLipStyle:(TTBeautyLipstickStyle)style;

/// 设置口红不透明度
- (void)setLipOpacity:(float)opacity;

/// 设置口红贴纸id
- (void)setLipSticker:(float)idt;


/// 设置腮红开关
- (void)setBlushEnable:(BOOL)enable;

/// 设置腮红不透明度
- (void)setBlushOpacity:(float)opacity;

/// 设置腮红贴纸id
- (void)setBlushSticker:(float)idt;


/// 设置眉毛开关
- (void)setBrowEnable:(BOOL)enable;

/// 设置眉毛样式
/// @param style 雾眉 雾根眉
- (void)setBrowStyle:(TTBeautyEyebrowStyle)style;

/// 设置眉毛不透明度
- (void)setBrowOpacity:(float)opacity;

/// 设置眉毛贴纸id
- (void)setBrowSticker:(float)idt;


/// 设置眼影开关
- (void)setEyeshadowEnable:(BOOL)enable;

/// 设置眼影不透明度
- (void)setEyeshadowOpacity:(float)opacity;

/// 设置眼影贴纸id
- (void)setEyeshadowSticker:(float)idt;


/// 设置眼线开关
- (void)setEyelineEnable:(BOOL)enable;

/// 设置眼线不透明度
- (void)setEyelineOpacity:(float)opacity;

/// 设置眼线贴纸id
- (void)setEyelineSticker:(float)idt;


/// 设置睫毛开关
- (void)setEyelashEnable:(BOOL)enable;

/// 设置睫毛不透明度
- (void)setEyelashOpacity:(float)opacity;

/// 设置睫毛贴纸id
- (void)setEyelashSticker:(float)idt;


/// 设置修容开关
- (void)setFacialEnable:(BOOL)enable;

/// 设置修容不透明度
- (void)setFacialOpacity:(float)opacity;

/// 设置修容贴纸id
- (void)setFacialSticker:(float)idt;

// MARK: - 滤镜

/// 设置滤镜
/// @param code 通过 code 在 SDK 内部映射表获取滤镜
- (void)setFilter:(NSString *)code;

/// 设置滤镜的强度
- (void)setFilterStrength:(float)strength;

// MARK: - 动态贴纸、哈哈镜
/// 设置动态贴纸
/// @param idt 贴纸id
- (void)setLiveSticker:(NSInteger)idt;

/// 设置哈哈镜
/// @param monsterStyle TTMonsterStyle
- (void)setMonsterStyle:(TTMonsterStyle)monsterStyle;

// MARK: - 合拍

/// 设置合拍
/// @param direction 布局
/// @param videoPath 视频地址
- (void)setJoiner:(TTJoinerDirection)direction videoPath:(NSString *)videoPath;

/// 更新合拍 布局
/// @param direction 布局
- (void)updateJoinerDirection:(TTJoinerDirection)direction;

/// 设置合拍变速
/// @param speed 速度
/// @param startTime 开始时间
- (void)setJoinerSpeed:(TTVideoRecordSpeed)speed startTime:(NSInteger)startTime;

/// 播放/暂停合拍素材
- (void)playJoiner:(BOOL)playing;

/// 设置合拍开始播放时间
- (void)setJoinerStartTime:(NSInteger)startTime;

/// 获取合拍布局
- (CGRect)getJoinerVideoRect;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TTRenderDef : NSObject

@end

NS_ASSUME_NONNULL_END
