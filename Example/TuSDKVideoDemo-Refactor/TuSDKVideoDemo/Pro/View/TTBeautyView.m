//
//  TTBeautyView.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTBeautyView.h"
//#import "TTCameraDef.h"
//#import "TTBeautyItem.h"
#import <objc/message.h>

@interface TTBeautyView ()
@property(nonatomic, strong) id<TTBeautyProtocol> beautyTarget;
@end

@implementation TTBeautyView

- (instancetype)initWithBeautyTarget:(id<TTBeautyProtocol>)beautyTarget {
    self = [super init];
    if (self) {
        _beautyTarget = beautyTarget;
        
    }
    return self;
}

//- (void)updateItem:(TTBeautyItem *)item {
//    if (![self.beautyTarget respondsToSelector:item.action]) {
//        return;
//    }
//    
//    void (*setter)(id, SEL, float) = (void (*)(id, SEL, float))objc_msgSend;
//    setter(self.beautyTarget, item.action, item.value);
//}
@end
