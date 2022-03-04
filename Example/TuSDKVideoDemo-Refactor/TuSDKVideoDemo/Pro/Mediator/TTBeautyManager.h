//
//  TTBeautyManager.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TUPDispatchQueue;
@class TUPFPImage;
@interface TTBeautyManager : NSObject
TT_INIT_UNAVAILABLE;
/**
 * 初始化美颜会话
 * @param queue 操作队列
 */
- (instancetype)initWithQueue:(TUPDispatchQueue *)queue NS_DESIGNATED_INITIALIZER;

/**
 * 向 美颜 发送图像 并返回编辑处理后的图像
 * @param fpImage 图像
 */
- (TUPFPImage *)sendFPImage:(TUPFPImage *)fpImage;
/**
 * 添加特效
 * @param effectType 特效类型
 */
- (void)addEffect:(TTEffectType)effectType;
/**
 * 移除特效
 * @param effectType 特效类型
 */
- (void)removeEffect:(TTEffectType)effectType;
/**
 * 重置特效
 * @param effectType 特效类型
 */
- (void)resetEffect:(TTEffectType)effectType;

/// 销毁
- (void)destory;
// MARK: - 美肤

/**
 * 设置美肤（磨皮）算法
 * @param skinStyle 自然 极致 新美颜
 */
- (void)setSkinStyle:(TTSkinStyle)skinStyle;

/// 设置磨皮级别 取值范围0 - 1
- (void)setSmoothLevel:(float)level;

/// 设置美白级别 取值范围0 - 1
- (void)setWhiteningLevel:(float)level;

/// 设置红润级别 取值范围0 - 1
- (void)setRuddyLevel:(float)level;

/// 设置锐化级别 取值范围0 - 1
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
/// @param startTime 开始时间
- (void)setJoinerStartTime:(NSInteger)startTime;

/// 获取合拍布局
- (CGRect)getJoinerVideoRect;

@end

NS_ASSUME_NONNULL_END
