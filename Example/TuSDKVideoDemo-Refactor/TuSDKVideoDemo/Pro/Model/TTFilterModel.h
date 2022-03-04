//
//  TTFilterModel.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBeautyGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFilterModel : NSObject
/**滤镜数据数组*/
@property (nonatomic, strong) NSArray <TTFilterGroup *> *filterGroups;
/**滤镜组标题数组*/
@property (nonatomic, strong) NSArray <NSString *> *titleGroups;

/**
 * 根据滤镜code获取对应调节栏信息
 * @param code 滤镜code
 */
- (NSMutableArray *)changeFilterWithCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
