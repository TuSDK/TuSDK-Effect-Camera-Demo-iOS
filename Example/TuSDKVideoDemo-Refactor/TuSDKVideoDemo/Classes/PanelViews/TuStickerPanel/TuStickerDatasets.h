/********************************************************
 * @file    : TuStickerDatasets.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸组分类
*********************************************************/
#import "TuStickerBaseDatasets.h"

NS_ASSUME_NONNULL_BEGIN




@interface TuStickerCategoryItem : TuStickerBaseData<TuStickerGroup *>
@end


@interface TuStickerDatasets : TuStickerBaseDatasets
+ (NSArray<TuStickerBaseDatasets *> *) allCategories; // 获取所有贴纸分类
@end

NS_ASSUME_NONNULL_END
