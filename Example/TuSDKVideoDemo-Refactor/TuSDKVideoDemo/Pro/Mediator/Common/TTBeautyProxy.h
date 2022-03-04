//
//  TTBeautyProxy.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTBeautyProxy : NSProxy <TTBeautyProtocol>
+ (instancetype)transformObjc:(id)objc;
@end

NS_ASSUME_NONNULL_END
