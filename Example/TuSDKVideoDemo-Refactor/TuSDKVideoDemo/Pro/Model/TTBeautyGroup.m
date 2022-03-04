//
//  TTFilterItem.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTBeautyGroup.h"


@implementation TTBeautyGroup

+ (instancetype)groupWithName:(NSString *)name items:(NSArray<TTBeautyItem *> *)items;
{
    TTBeautyGroup *group = [[TTBeautyGroup alloc] init];
    group.name = name;
    group.items = items;
    return group;
}

@end



@implementation TTFilterGroup

+ (instancetype)groupWithName:(NSString *)name items:(NSArray<TTFilterItem *> *)items;
{
    TTFilterGroup *group = [[TTFilterGroup alloc] init];
    group.name = name;
    group.items = items;
    return group;
}

@end
