//
//  TTBeautyView.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TTBeautyProtocol;

@interface TTBeautyView : UIView
- (instancetype)initWithBeautyTarget:(id<TTBeautyProtocol>)beautyTarget;
@end

NS_ASSUME_NONNULL_END
