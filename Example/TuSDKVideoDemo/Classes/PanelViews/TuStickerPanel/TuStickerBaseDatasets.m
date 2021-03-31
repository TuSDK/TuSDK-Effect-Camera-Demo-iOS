/********************************************************
 * @file    : TuStickerBaseDatasets.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   :
*********************************************************/
#import "TuStickerBaseDatasets.h"

/** TuStickerBaseData************************************************/
@implementation TuStickerBaseData
- (void)loadThumb:(UIImageView *)thumbImageView completed:(void(^)(BOOL))hander
{
}
- (void)load
{
}
@end


/** TuStickerBaseDatasets************************************************/
@implementation TuStickerBaseDatasets
- (BOOL)canRemovePropsItem:(TuStickerBaseData *)propsItem
{
    return (propsItem && !propsItem.online);
}

- (BOOL)removePropsItem:(TuStickerBaseData *)propsItem;
{
    if (!self.propsItems || self.propsItems.count == 0 ||propsItem.online || ![self canRemovePropsItem:propsItem])
    {
        return NO;
    }
    
    NSMutableArray<TuStickerBaseData *> *newPropsItemArray = [NSMutableArray arrayWithArray:self.propsItems];
    [newPropsItemArray removeObject:propsItem];
    
    return YES;
}

@end


