//
//  TTCosmeticGroup.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/14.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBeautyItem.h"

@class TTCosmeticModel;
NS_ASSUME_NONNULL_BEGIN

@interface TTCosmeticGroup : NSObject

@property (nonatomic, copy) NSArray <TTCosmeticModel *> *models;

@end

@interface TTCosmeticModel : NSObject

// 唯一标识
@property (nonatomic, copy) NSString *code;
// 图标
@property (nonatomic, strong) UIImage *icon;
// 名称
@property (nonatomic, copy) NSString *name;
// 是否选中
@property (nonatomic, assign) BOOL isSelect;
// 是否为小圆点
@property (nonatomic, assign) BOOL isPoint;
// 美妆分类数组
@property (nonatomic, copy) NSArray<TTCosmeticItem *> *items;

/**
 * 初始化model
 * @param code 唯一标识
 * @param name 名称
 */
+ (instancetype)modelWithCode:(NSString *)code name:(NSString *)name;

@end



NS_ASSUME_NONNULL_END
