//
//  TTEffectFactory.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/22.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TUPConfig;

@interface TTEffectSettings : NSObject
@property(nonatomic, copy) NSString *name; // 特效名称
@property(nonatomic, strong, nullable) TUPConfig *config; // sdk 特效配置
@end

/// 特效工厂类
@interface TTEffectFactory : NSObject

/// 获取特效配置
- (TTEffectSettings *)settingsWithEffect:(TTEffectType)effectType;

/// 获取美肤特效配置
- (TTEffectSettings *)skinSettingsWithEffect:(TTSkinStyle)skinStyle;

- (BOOL)fetchEffect:(TTEffectType)effectType setNumber:(NSNumber *)number forKey:(NSString*)key;
- (BOOL)fetchEffect:(TTEffectType)effectType setString:(NSString *)str forKey:(NSString*)key;
- (nullable NSString *)stringForKey:(NSString *)key inEffect:(TTEffectType)effectType;

- (void)fetchMonster:(TTMonsterStyle)monsterStyle;

@end

NS_ASSUME_NONNULL_END
