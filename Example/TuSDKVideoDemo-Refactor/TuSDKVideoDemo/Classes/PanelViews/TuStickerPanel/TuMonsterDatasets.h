/********************************************************
 * @file    : TuMonsterDatasets.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 哈哈镜
*********************************************************/
#import "TuStickerBaseDatasets.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuMonsterData : TuStickerBaseData
@property (nonatomic, strong) NSString *thumbImageName;
@end


@interface TuMonsterDatasets : TuStickerBaseDatasets
+ (NSArray<TuStickerBaseDatasets *> *) allCategories; // 获取所有哈哈镜分类
@end

NS_ASSUME_NONNULL_END
