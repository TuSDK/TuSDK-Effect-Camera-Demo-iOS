//
//  TTBeautyItem.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/6.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTBeautyItem : NSObject


/// 唯一标识
@property(nonatomic, copy) NSString *code;
/// 名称
@property(nonatomic, copy) NSString *name;
/// 图标
@property(nonatomic, strong) UIImage *icon;
/// 选中图标
@property(nonatomic, strong) UIImage *selectIcon;
/// 参数事件
@property(nonatomic, assign) SEL action;
/// 值
@property(nonatomic, assign) float value;
/**默认值 */
@property (nonatomic, assign) float defaultValue;
@property(nonatomic, assign) BOOL isSelected;

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action;


@end

typedef NS_ENUM(NSInteger, TTFilterSelectState)
{
    TTFilterSelectStateUnselected = 0,   //未选中
    TTFilterSelectStateSelected,         //选中
    TTFilterSelectStateParamAdjust       //效果调节
};

/// 滤镜组件
@interface TTFilterItem : TTBeautyItem

/**是否为漫画滤镜*/
@property (nonatomic, assign) BOOL isComics;
/**点击状态*/
@property (nonatomic, assign) TTFilterSelectState selectState;

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action;

@end

/// 微整形组件
@interface TTFacePlasticItem : TTBeautyItem

/**是否为微整形改造*/
@property (nonatomic, assign) BOOL isReshape;
/**是否重置*/
@property (nonatomic, assign) BOOL isReset;
/* 双向的参数  0.5是原始值*/
@property (nonatomic, assign) BOOL iSStyle101;

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action;

@end

/// 美肤组件
@interface TTFaceSkinItem : TTBeautyItem
/**美肤算法类型*/
@property (nonatomic, assign) TTSkinStyle skinType;
/**是否重置*/
@property (nonatomic, assign) BOOL isReset;
/**是否隐藏*/
@property (nonatomic, assign) BOOL isHidden;

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action;

@end


@interface TTCosmeticItem : TTBeautyItem
/// 唯一标识
@property (nonatomic, copy) NSString *id;
// 口红样式
@property (nonatomic, assign) TTBeautyLipstickStyle style;

+ (instancetype)itemWithCode:(NSString *)code ID:(NSString *)ID name:(NSString *)name;

@end


NS_ASSUME_NONNULL_END
