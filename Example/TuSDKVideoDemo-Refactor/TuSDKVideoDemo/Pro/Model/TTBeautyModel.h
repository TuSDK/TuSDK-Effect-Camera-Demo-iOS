//
//  TTBeautyModel.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/17.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBeautyItem.h"
#import "TTRenderDef.h"


NS_ASSUME_NONNULL_BEGIN


@protocol TTBeautyProtocol;

@interface TTBeautyModel : NSObject

@property (nonatomic, assign) TTEffectType effectType;

- (instancetype)initWithBeautyTarget:(id<TTBeautyProtocol>)beautyTarget;

#pragma mark - 微整形
/**
 * 配置微整形调节栏参数
 * @param item 微整形组件
 * @return 微整形调节栏参数
 */
- (NSMutableArray *)plasticParamtersViewUpdate:(TTFacePlasticItem *)item;

/**
 * 配置微整形改造调节栏参数
 * @param item 微整形组件
 * @return 微整形调节栏参数
 */
- (NSMutableArray *)plasticExtraParamtersViewUpdate:(TTFacePlasticItem *)item;

/**
 * 根据微整形code修改相对应的参数值
 * @param code 微整形code
 * @param value 参数值
 */
- (void)updatePlasticArgsValue:(NSString *)code value:(float)value;


#pragma mark - 美肤

/**
 * 配置美肤调节栏参数
 * @param item 美肤组件
 * @return 美肤调节栏参数
 */
- (NSMutableArray *)skinParamtersViewUpdate:(TTFaceSkinItem *)item;

/**
 * 根据美肤code修改相对应的参数值
 * @param code 微整形code
 * @param value 参数值
 */
- (void)updateSkinWithCode:(NSString *)code value:(float)value;


#pragma mark - 美妆
/**
 * 美妆开关
 * @param code 美妆code
 * @param enable 开关
 */
- (void)setCosmeticEnable:(NSString *)code enable:(BOOL)enable;

/**
 * 设置美妆参数百分比
 * @param code 美妆code
 * @param precent 百分比
 */
- (void)setCosmeticParamsArgKeyWithCode:(NSString *)code precent:(CGFloat)precent;

- (void)setCosmeticParamsArgKeyWithCode:(NSString *)code stickerId:(NSInteger)stickerId;

/**
 * 美妆参数面板是否隐藏
 * @param code 美妆code
 * @return 参数面板是否隐藏
 */
- (BOOL)cosmeticParamtersViewHidden:(NSString *)code;

/**
 * 获取美妆参数数组
 * @param code 美妆code
 * @return 获取美妆参数数组
 */
- (NSMutableArray *)cosmeticParamtersViewUpdate:(NSString *)code;

/**
 * 获取美妆不透明度参数
 * @param code 美妆code
 * @return 美妆不透明度参数
 */
- (NSString *)cosmeticOpacityCodeWithCode:(NSString *)code;

/**
 * 设置美妆贴纸ID
 * @param style 美妆类型
 * @param stickerId 美妆贴纸ID
 */
- (void)setCosmeticIDWithStyle:(NSString *)style stickerID:(NSInteger)stickerId;


/// 根据code、value改变参数
- (void)setCosmeticOpacityArg:(NSString *)opacityCode value:(CGFloat)value;
@end

NS_ASSUME_NONNULL_END
