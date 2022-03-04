//
//  TTFilterItem.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBeautyItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTBeautyGroup : NSObject

/// 名称
@property(nonatomic, copy) NSString *name;

@property(nonatomic, strong) NSArray<TTBeautyItem *> *items;

+ (instancetype)groupWithName:(NSString *)name items:(NSArray<TTBeautyItem *> *)items;

@end

@interface TTFilterGroup : NSObject

/// 名称
@property(nonatomic, copy) NSString *name;

@property(nonatomic, strong) NSArray<TTFilterItem *> *items;

+ (instancetype)groupWithName:(NSString *)name items:(NSArray<TTFilterItem *> *)items;

@end

NS_ASSUME_NONNULL_END
