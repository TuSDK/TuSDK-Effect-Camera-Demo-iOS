//
//  TTEffectFactory.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/22.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTEffectFactory.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>

@implementation TTEffectSettings
- (instancetype)initWithName:(NSString *)name config:(nullable TUPConfig *)config {
    self = [super init];
    if (self) {
        _name = name;
        _config = config;
    }
    return self;
}
@end

@interface TTEffectFactory ()
@property(nonatomic, strong) TTEffectSettings *plastic;
@property(nonatomic, strong) TTEffectSettings *reshape;
@property(nonatomic, strong) TTEffectSettings *cosmetic;
@property(nonatomic, strong) TTEffectSettings *skinNatural;
@property(nonatomic, strong) TTEffectSettings *skinHazy;
@property(nonatomic, strong) TTEffectSettings *skinBeauty;
@property(nonatomic, strong) TTEffectSettings *filter;
@property(nonatomic, strong) TTEffectSettings *liveSticker;
@property(nonatomic, strong) TTEffectSettings *monster;
@property(nonatomic, strong) TTEffectSettings *joiner;
@end

@implementation TTEffectFactory

- (instancetype)init {
    self = [super init];
    if (self) {
        _plastic = [[TTEffectSettings alloc] initWithName:TUPFPTusdkFacePlasticFilter_TYPE_NAME config:nil];
        _reshape = [[TTEffectSettings alloc] initWithName:TUPFPTusdkFaceReshapeFilter_TYPE_NAME config:nil];
        _cosmetic = [[TTEffectSettings alloc] initWithName:TUPFPTusdkCosmeticFilter_TYPE_NAME config:nil];
        
        TUPConfig *skinNaturalConfig = [[TUPConfig alloc] init];
        [skinNaturalConfig setString:TUPFPTusdkImageFilter_NAME_SkinNatural forKey:TUPFPTusdkImageFilter_CONFIG_NAME];
        _skinNatural = [[TTEffectSettings alloc] initWithName:TUPFPTusdkImageFilter_TYPE_NAME config:skinNaturalConfig];
        
        TUPConfig *skinHazyConfig = [[TUPConfig alloc] init];
        [skinHazyConfig setString:TUPFPTusdkImageFilter_NAME_SkinHazy forKey:TUPFPTusdkImageFilter_CONFIG_NAME];
        _skinHazy = [[TTEffectSettings alloc] initWithName:TUPFPTusdkImageFilter_TYPE_NAME config:skinHazyConfig];
        
        _skinBeauty = [[TTEffectSettings alloc] initWithName:TUPFPTusdkBeautFaceV2Filter_TYPE_NAME config:nil];
        
        _filter = [[TTEffectSettings alloc] initWithName:TUPFPTusdkImageFilter_TYPE_NAME config:[[TUPConfig alloc] init]];
        
        _liveSticker = [[TTEffectSettings alloc] initWithName:TUPFPTusdkLiveStickerFilter_TYPE_NAME config:[[TUPConfig alloc] init]];
        
        _monster = [[TTEffectSettings alloc] initWithName:TUPFPTusdkFaceMonsterFilter_TYPE_NAME config:[[TUPConfig alloc] init]];
        
        _joiner = [[TTEffectSettings alloc] initWithName:TUPFPSimultaneouslyFilter_TYPE_NAME config:[[TUPConfig alloc] init]];
    }
    return self;
}

- (TTEffectSettings *)settingsWithEffect:(TTEffectType)effectType {
    switch (effectType) {
        case TTEffectTypePlastic:
            return self.plastic;
        case TTEffectTypeReshape:
            return self.reshape;
        case TTEffectTypeCosmetic:
            return self.cosmetic;
        case TTEffectTypeSkin:
            return self.skinNatural;
        case TTEffectTypeFilter:
            return self.filter;
        case TTEffectTypeLiveSticker:
            return self.liveSticker;
        case TTEffectTypeMonster:
            return self.monster;
        case TTEffectTypeJoiner:
            return self.joiner;
        default:
            break;
    }
}

- (TTEffectSettings *)skinSettingsWithEffect:(TTSkinStyle)skinStyle {
    switch (skinStyle) {
        case TTSkinStyleNatural:
            return self.skinNatural;
        case TTSkinStyleHazy:
            return self.skinHazy;
        case TTSkinStyleBeauty:
            return self.skinBeauty;
        default:
            break;
    }
}

- (nullable TUPConfig *)configWithEffect:(TTEffectType)effectType {
    TTEffectSettings *settings = [self settingsWithEffect:effectType];
    return settings.config;
}

- (BOOL)fetchEffect:(TTEffectType)effectType setNumber:(NSNumber *)number forKey:(NSString *)key {
    TUPConfig *config = [self configWithEffect:effectType];
    if (!config) {
        return NO;
    }
    return [config setNumber:number forKey:key];
}

- (BOOL)fetchEffect:(TTEffectType)effectType setString:(NSString *)str forKey:(NSString *)key {
    TUPConfig *config = [self configWithEffect:effectType];
    if (!config) {
        return NO;
    }
    return [config setString:str forKey:key];
}

- (void)fetchMonster:(TTMonsterStyle)monsterStyle {
    NSString *code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_Empty;
    switch (monsterStyle) {
        case TTMonsterStyleBigNose:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_BigNose;
            break;
        case TTMonsterStylePieFace:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_PieFace;
            break;
        case TTMonsterStyleSquareFace:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_SquareFace;
            break;
        case TTMonsterStyleThickLips:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_ThickLips;
            break;
        case TTMonsterStyleSmallEyes:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_SmallEyes;
            break;
        case TTMonsterStylePapayaFace:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_PapayaFace;
            break;
        case TTMonsterStyleSnakeFace:
            code = TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE_SnakeFace;
            break;
        default:
            break;
    }
    [self.monster.config setString:code forKey:TUPFPTusdkFaceMonsterFilter_CONFIG_TYPE];
}

- (NSString *)stringForKey:(NSString *)key inEffect:(TTEffectType)effectType {
    TUPConfig *config = [self configWithEffect:effectType];
    if (!config) {
        return nil;
    }
    return [config getString:key];
}
@end
