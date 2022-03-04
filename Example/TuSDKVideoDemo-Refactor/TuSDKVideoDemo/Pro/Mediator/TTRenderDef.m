//
//  TTRenderDef.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2022/1/6.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTRenderDef.h"
CGFloat TTVideoRecordSpeedValue(TTVideoRecordSpeed speed) {
    switch (speed) {
        case TTVideoRecordSpeed_SLOWEST:
            return 2.0;
        case TTVideoRecordSpeed_SLOW:
            return 1.5;
        case TTVideoRecordSpeed_NOMAL:
            return 1;
        case TTVideoRecordSpeed_FAST:
            return 0.75;
        case TTVideoRecordSpeed_FASTEST:
            return 0.5;
        default:
            return 1;
    }
}

CGFloat TTVideoRecordSpeedMixerValue(TTVideoRecordSpeed speed) {
    switch (speed) {
        case TTVideoRecordSpeed_SLOWEST:
            return 0.5;
        case TTVideoRecordSpeed_SLOW:
            return 0.75;
        case TTVideoRecordSpeed_NOMAL:
            return 1;
        case TTVideoRecordSpeed_FAST:
            return 1.5;
        case TTVideoRecordSpeed_FASTEST:
            return 2;
        default:
            return 1;
    }
}

NSString *TTEffectTypeDescription(TTEffectType type) {
    switch (type) {
        case TTEffectTypePlastic:
            return @"微整形";
        case TTEffectTypeReshape:
            return @"微整形改造";
        case TTEffectTypeCosmetic:
            return @"美妆";
        case TTEffectTypeSkin:
            return @"美肤";
        case TTEffectTypeFilter:
            return @"滤镜";
        case TTEffectTypeLiveSticker:
            return @"动态贴纸";
        case TTEffectTypeMonster:
            return @"哈哈镜";
        case TTEffectTypeJoiner:
            return @"合拍";
        default:
            return @"unknown";
    }
}
@implementation TTRenderDef

@end
