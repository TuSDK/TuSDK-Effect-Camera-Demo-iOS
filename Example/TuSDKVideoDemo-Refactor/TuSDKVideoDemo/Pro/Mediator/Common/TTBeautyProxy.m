//
//  TTBeautyProxy.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/14.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTBeautyProxy.h"

@interface NSObject (BeautyManager)
- (id)getBeautyManager;
@end

@interface TTBeautyProxy ()
@property(nonatomic, weak) id objc;
@property(nonatomic, weak) id beautyManager;
@end

@implementation TTBeautyProxy
+ (instancetype)transformObjc:(id)objc {
    return [[TTBeautyProxy alloc] initWithObjc:objc];
}
- (instancetype)initWithObjc:(id)objc {
    if (![objc respondsToSelector:@selector(getBeautyManager)]) {
        NSLog(@"%s failed, %@ doesn't has getBeautyManager method", __PRETTY_FUNCTION__, objc);
        return nil;
    }
    id beautyManager = [objc getBeautyManager];
    if (![beautyManager isKindOfClass:NSClassFromString(@"TTBeautyManager")]) {
        NSLog(@"%s failed, type mismatch of object.getBeautyManager(%@)", __PRETTY_FUNCTION__, objc);
        return nil;
    }
    _objc = objc;
    _beautyManager = beautyManager;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([_beautyManager respondsToSelector:sel]) {
        return [_beautyManager methodSignatureForSelector:sel];
    } else if ([_objc respondsToSelector:sel]) {
        return [_objc methodSignatureForSelector:sel];
    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    if ([_beautyManager respondsToSelector:selector]) {
        [invocation invokeWithTarget:_beautyManager];
    } else if ([_objc respondsToSelector:selector]) {
        [invocation invokeWithTarget:_objc];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_beautyManager respondsToSelector:aSelector]) {
        return YES;
    }
    if ([_objc respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}
@end
