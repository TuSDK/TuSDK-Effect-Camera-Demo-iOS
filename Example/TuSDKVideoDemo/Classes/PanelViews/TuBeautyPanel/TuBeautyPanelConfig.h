/********************************************************
 * @file    : TuBeautyPanelConfig.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美肤、微整形和美妆默认配置
*********************************************************/

#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"
#import "Constants.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuBeautyPanelConfig : NSObject

+ (SelesParameters *)defaultPlasticParameters;
+ (SelesParameters *)defaultPlasticExtraParameters;
+ (SelesParameters *)defaultSkinParameters:(TuSkinFaceType)mode;
+ (SelesParameters *)defaultCosmeticParameters;





/**设置默认的微整形参数值*/
+ (NSDictionary *)defaultPlasticValue;

/**设置微整形参数值*/
+ (NSDictionary *)defaultExtraPlasticValue;

/**设置默认的美妆参数值*/
+ (NSDictionary *)defaultCosmeticValue;

/**设置美肤参数值*/
+ (NSDictionary *)defaultSkinValue;

//获取美妆数组
+ (NSArray *)cosmeticDataSet;

/**
 根据美妆code获取数组
 @param code 美妆code
 @return code名称数组
 */
+ (NSArray *)dataSetWithCosmeticCode:(NSString *)code;

/**
 根据眉毛类型 和 贴纸名称获取贴纸code
 @param browType 眉毛类型
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)eyeBrowCodeByBrowType:(NSInteger)browType stickerName:(NSString *)stickerName;

/**
 根据美妆code 和 贴纸名称获取贴纸code
 @param code 美妆code
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)effectCodeByCosmeticCode:(NSString *)code stickerName:(NSString *)stickerName;


+ (int)stickLipParamByStickerName:(NSString *)stickerName;


@end

NS_ASSUME_NONNULL_END
