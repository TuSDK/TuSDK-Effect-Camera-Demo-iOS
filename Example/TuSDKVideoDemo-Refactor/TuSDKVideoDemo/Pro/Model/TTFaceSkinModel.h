//
//  TTFaceSkinModel.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/14.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBeautyItem.h"
#import "TTRenderDef.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTFaceSkinModel : NSObject

@property (nonatomic, copy) NSArray<TTFaceSkinItem *> *skinItems;

/**
 * 切换美肤类型
 * @param skinItem  美肤item
 */
- (void)changeSkinType:(TTFaceSkinItem *)skinItem;
@end


NS_ASSUME_NONNULL_END
