//
//  MusicItem.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/6/18.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicItem : NSObject
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *time;

+ (instancetype)itemWithName:(NSString *)name time:(NSString *)time;
@end

NS_ASSUME_NONNULL_END
