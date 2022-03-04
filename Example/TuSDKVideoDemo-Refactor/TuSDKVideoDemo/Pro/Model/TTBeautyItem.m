//
//  TTBeautyItem.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/6.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTBeautyItem.h"

@implementation TTBeautyItem

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action;
{
    TTBeautyItem *item = [[TTBeautyItem alloc] init];
    item.code = code;
    item.isSelected = NO;
    item.action = action;
    item.defaultValue = 0;
    return item;
}


@end

/// 滤镜组件
@implementation TTFilterItem

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action
{
    TTFilterItem *item = [[TTFilterItem alloc] init];
    item.code = code;
    item.isSelected = NO;
    item.action = action;
    item.isComics = NO;
    item.selectState = TTFilterSelectStateUnselected;
    return item;
}

@end


/// 微整形组件
@implementation TTFacePlasticItem

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action
{
    TTFacePlasticItem *item = [[TTFacePlasticItem alloc] init];
    item.code = code;
    item.isSelected = NO;
    item.action = action;
    item.isReshape = NO;
    item.isReset = NO;
    item.iSStyle101 = NO;
    return item;
}

@end

/// 美肤 组件
@implementation TTFaceSkinItem

+ (instancetype)itemWithCode:(NSString *)code action:(SEL)action;
{
    TTFaceSkinItem *item = [[TTFaceSkinItem alloc] init];
    item.code = code;
    item.isSelected = NO;
    item.action = action;
    item.isReset = NO;
    item.isHidden = NO;
    return item;
}

@end

/// 美妆 组件
@implementation TTCosmeticItem

+ (instancetype)itemWithCode:(NSString *)code ID:(NSString *)ID name:(NSString *)name;
{
    TTCosmeticItem *item = [[TTCosmeticItem alloc] init];
    item.code = code;
    item.id = ID;
    item.name = name;
    item.isSelected = NO;
    return item;
}

@end
