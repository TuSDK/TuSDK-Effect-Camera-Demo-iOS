//
//  TTFaceSkinModel.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/14.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFaceSkinModel.h"

@interface TTFaceSkinModel()



@end

@implementation TTFaceSkinModel


- (instancetype)init
{
    if (self = [super init]) {
        
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    NSMutableArray *items = [NSMutableArray array];
    //重置
    TTFaceSkinItem *resetItem = [TTFaceSkinItem itemWithCode:@"reset" action:@selector(resetEffect:)];
    //名称
    resetItem.name = NSLocalizedStringFromTable(@"tu_无", @"VideoDemo", @"无");
    //图标
    resetItem.icon = [UIImage imageNamed:@"face_ic_reset"];
    resetItem.selectIcon = [UIImage imageNamed:@"face_ic_reset_sel"];
    resetItem.isReset = YES;
    [items addObject:resetItem];
    
    //美肤类型
    TTFaceSkinItem *skinTypeItem = [self itemWithCode:@"skin_beauty" value:0.0 action:@selector(setSkinStyle:)];
    skinTypeItem.skinType = TTSkinStyleNatural;
    [items addObject:skinTypeItem];
    
    //间隔符
    TTFaceSkinItem *pointItem = [TTFaceSkinItem itemWithCode:@"point" action:@selector(resetEffect:)];
    [items addObject:pointItem];
    
    //磨皮
    TTFaceSkinItem *smoothItem = [self itemWithCode:@"smoothing" value:0.8 action:@selector(setSmoothLevel:)];
    [items addObject:smoothItem];
    //美白
    TTFaceSkinItem *whiteItem = [self itemWithCode:@"whitening" value:0.3 action:@selector(setWhiteningLevel:)];
    [items addObject:whiteItem];
    //锐化
    TTFaceSkinItem *sharpenItem = [self itemWithCode:@"sharpen" value:0.6 action:@selector(setSharpenLevel:)];
    [items addObject:sharpenItem];
    //红润
    TTFaceSkinItem *ruddyItem = [self itemWithCode:@"ruddy" value:0.2 action:@selector(setRuddyLevel:)];
    ruddyItem.isHidden = YES;
    [items addObject:ruddyItem];
    
    _skinItems = [items copy];
}

/**
 * 切换美肤类型
 * @param skinItem  美肤item
 */
- (void)changeSkinType:(TTFaceSkinItem *)skinItem;
{
    if (skinItem.skinType == TTSkinStyleNatural)
    {
        //自然 -> 极致(此模式包括红润、不包含锐化)
        skinItem.skinType = TTSkinStyleHazy;
        [self updateItem:skinItem withCode:@"skin_extreme"];
        for (TTFaceSkinItem *item in _skinItems) {
            //展示红润、隐藏锐化
            if ([item.code isEqualToString:@"ruddy"]) {
                item.isHidden = NO;
            } else if ([item.code isEqualToString:@"sharpen"]) {
                item.isHidden = YES;
            }
            
        }
    }
    else if (skinItem.skinType == TTSkinStyleHazy)
    {
        //极致 -> 精准(此模式包括红润、不包含锐化)
        skinItem.skinType = TTSkinStyleBeauty;
        [self updateItem:skinItem withCode:@"skin_precision"];
    }
    else
    {
        //极致 -> 自然(此模式包括锐化、不包含红润)
        skinItem.skinType = TTSkinStyleNatural;
        [self updateItem:skinItem withCode:@"skin_beauty"];
        for (TTFaceSkinItem *item in _skinItems) {
            //展示锐化、隐藏红润
            if ([item.code isEqualToString:@"ruddy"]) {
                item.isHidden = YES;
            } else if ([item.code isEqualToString:@"sharpen"]) {
                item.isHidden = NO;
            }
        }
    }
    //将功能组件里的美肤类型统一替换为切换后的类型
    NSArray *effectItems = @[@"smoothing", @"whitening", @"ruddy", @"sharpen"];
    for (TTFaceSkinItem *item in _skinItems) {
        if ([effectItems containsObject:item.code]) {
            item.skinType = skinItem.skinType;
        }
    }
}
/**
 * 更新item里code、title、icon信息
 * @param skinItem  更新组件
 * @param code 组件code
 */
- (void)updateItem:(TTFaceSkinItem *)skinItem withCode:(NSString *)code
{
    skinItem.code = code;
    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
    skinItem.name = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    //图标
    NSString *imageName = [NSString stringWithFormat:@"face_ic_%@", code];
    skinItem.icon = [UIImage imageNamed:imageName];
}

/**
 * 创建组件
 */
- (TTFaceSkinItem *)itemWithCode:(NSString *)code value:(float)value action:(SEL)action
{
    TTFaceSkinItem *item = [TTFaceSkinItem itemWithCode:code action:action];
    // 标题
    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
    item.name = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    //图标
    NSString *imageName = [NSString stringWithFormat:@"face_ic_%@", code];
    NSString *selectImageName = [NSString stringWithFormat:@"face_ic_%@_sel", code];
    item.icon = [UIImage imageNamed:imageName];
    item.selectIcon = [UIImage imageNamed:selectImageName];
    item.value = value;
    item.defaultValue = value;
    
    return item;
}

@end


