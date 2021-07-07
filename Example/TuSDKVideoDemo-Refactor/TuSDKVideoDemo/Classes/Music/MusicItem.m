//
//  MusicItem.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/6/18.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

+ (instancetype)itemWithName:(NSString *)name time:(NSString *)time {
    MusicItem *item = [[MusicItem alloc] init];
    item.name = name;
    item.time = time;
    item.isPlaying = NO;
    return item;
}
@end
