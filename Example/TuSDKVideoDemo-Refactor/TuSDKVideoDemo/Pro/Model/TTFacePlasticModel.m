//
//  TTFacePlasticModel.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/14.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFacePlasticModel.h"

#import "TTRenderDef.h"
#import "TuBeautyPanelConfig.h"
#import <TuSDKPulseCore/TuSDKPulseCore.h>
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>

#define kPlasticKeyCodes @"eyeSize", @"chinSize", @"cheekNarrow", @"smallFace", @"noseSize", @"noseHeight", @"mouthWidth", @"lips", @"philterum", @"archEyebrow", @"browPosition", @"jawSize", @"cheekLowBoneNarrow", @"eyeAngle", @"eyeInnerConer", @"eyeOuterConer", @"eyeDis", @"eyeHeight", @"forehead", @"cheekBoneNarrow"
#define kPlasticKeyExtraCodes @"eyelid", @"eyemazing", @"whitenTeeth", @"eyeDetail", @"removePouch", @"removeWrinkles"

@interface TTFacePlasticModel()

@end

@implementation TTFacePlasticModel

- (instancetype)init
{
    if (self = [super init]) {
        
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    NSMutableArray *items = [NSMutableArray array];
    //重置
    TTFacePlasticItem *resetItem = [TTFacePlasticItem itemWithCode:@"reset" action:@selector(resetEffect:)];
    //名称
    resetItem.name = NSLocalizedStringFromTable(@"tu_重置", @"VideoDemo", @"重置");
    //图标
    resetItem.icon = [UIImage imageNamed:@"plastic_reset"];
    resetItem.selectIcon = [UIImage imageNamed:@"plastic_reset_sel"];
    resetItem.isReset = YES;
    [items addObject:resetItem];
    
    //间隔符
    TTFacePlasticItem *pointItem = [TTFacePlasticItem itemWithCode:@"point" action:@selector(resetEffect:)];
    [items addObject:pointItem];
    //大眼
    TTFacePlasticItem *eyeSizeItem = [self itemWithCode:@"eyeSize" value:0.3 action:@selector(setEyeEnlargeLevel:)];
    [items addObject:eyeSizeItem];
    //瘦脸
    TTFacePlasticItem *chinSizeItem = [self itemWithCode:@"chinSize" value:0.5 action:@selector(setCheekThinLevel:)];
    [items addObject:chinSizeItem];
    //窄脸
    TTFacePlasticItem *cheekNarrowItem = [self itemWithCode:@"cheekNarrow" value:0 action:@selector(setCheekNarrowLevel:)];
    [items addObject:cheekNarrowItem];
    //小脸
    TTFacePlasticItem *smallFaceItem = [self itemWithCode:@"smallFace" value:0 action:@selector(setFaceSmallLevel:)];
    [items addObject:smallFaceItem];
    //瘦鼻
    TTFacePlasticItem *noseSizeItem = [self itemWithCode:@"noseSize" value:0.2 action:@selector(setNoseWidthLevel:)];
    [items addObject:noseSizeItem];
    //长鼻
    TTFacePlasticItem *noseHeightItem = [self itemWithCode:@"noseHeight" value:0 action:@selector(setNoseHeightLevel:)];
    [items addObject:noseHeightItem];
    //嘴形
    TTFacePlasticItem *mouthWidthItem = [self itemWithCode:@"mouthWidth" value:0.5 action:@selector(setMouthWidthLevel:)];
    mouthWidthItem.iSStyle101 = YES;
    [items addObject:mouthWidthItem];
    //唇厚
    TTFacePlasticItem *lipsItem = [self itemWithCode:@"lips" value:0.5 action:@selector(setLipsThicknessLevel:)];
    lipsItem.iSStyle101 = YES;
    [items addObject:lipsItem];
    //缩人中
    TTFacePlasticItem *philterumItem = [self itemWithCode:@"philterum" value:0.5 action:@selector(setPhilterumThicknessLevel:)];
    philterumItem.iSStyle101 = YES;
    [items addObject:philterumItem];
    //细眉
    TTFacePlasticItem *archEyebrowItem = [self itemWithCode:@"archEyebrow" value:0.5 action:@selector(setBrowThicknessLevel:)];
    archEyebrowItem.iSStyle101 = YES;
    [items addObject:archEyebrowItem];
    //唇高
    TTFacePlasticItem *browPositionItem = [self itemWithCode:@"browPosition" value:0.5 action:@selector(setBrowHeightLevel:)];
    browPositionItem.iSStyle101 = YES;
    [items addObject:browPositionItem];
    //下巴
    TTFacePlasticItem *jawSizeItem = [self itemWithCode:@"jawSize" value:0.5 action:@selector(setChinThicknessLevel:)];
    jawSizeItem.iSStyle101 = YES;
    [items addObject:jawSizeItem];
    //下颌骨
    TTFacePlasticItem *cheekLowBoneNarrowItem = [self itemWithCode:@"cheekLowBoneNarrow" value:0 action:@selector(setCheekLowBoneNarrowLevel:)];
    [items addObject:cheekLowBoneNarrowItem];
    //眼角
    TTFacePlasticItem *eyeAngleItem = [self itemWithCode:@"eyeAngle" value:0.5 action:@selector(setEyeAngleLevel:)];
    eyeAngleItem.iSStyle101 = YES;
    [items addObject:eyeAngleItem];
    //开内眼角
    TTFacePlasticItem *eyeInnerConerItem = [self itemWithCode:@"eyeInnerConer" value:0 action:@selector(setEyeInnerConerLevel:)];
    [items addObject:eyeInnerConerItem];
    //开外眼角
    TTFacePlasticItem *eyeOuterConerItem = [self itemWithCode:@"eyeOuterConer" value:0 action:@selector(setEyeOuterConerLevel:)];
    [items addObject:eyeOuterConerItem];
    //眼距
    TTFacePlasticItem *eyeDisItem = [self itemWithCode:@"eyeDis" value:0.5 action:@selector(setEyeDistanceLevel:)];
    eyeDisItem.iSStyle101 = YES;
    [items addObject:eyeDisItem];
    //眼移动
    TTFacePlasticItem *eyeHeightItem = [self itemWithCode:@"eyeHeight" value:0.5 action:@selector(setEyeHeightLevel:)];
    eyeHeightItem.iSStyle101 = YES;
    [items addObject:eyeHeightItem];
    //发际线
    TTFacePlasticItem *foreheadItem = [self itemWithCode:@"forehead" value:0.5 action:@selector(setForeheadHeightLevel:)];
    foreheadItem.iSStyle101 = YES;
    [items addObject:foreheadItem];
    //瘦颧骨
    TTFacePlasticItem *cheekBoneNarrowItem = [self itemWithCode:@"cheekBoneNarrow" value:0 action:@selector(setCheekBoneNarrowLevel:)];
    [items addObject:cheekBoneNarrowItem];
    //双眼皮
    TTFacePlasticItem *eyelidItem = [self itemWithCode:@"eyelid" value:0 action:@selector(setEyelidLevel:)];
    [items addObject:eyelidItem];
    //卧蚕
    TTFacePlasticItem *eyemazingItem = [self itemWithCode:@"eyemazing" value:0 action:@selector(setEyemazingLevel:)];
    [items addObject:eyemazingItem];
    //白牙
    TTFacePlasticItem *whitenTeethItem = [self itemWithCode:@"whitenTeeth" value:0 action:@selector(setWhitenTeethLevel:)];
    [items addObject:whitenTeethItem];
    //亮眼
    TTFacePlasticItem *eyeDetailItem = [self itemWithCode:@"eyeDetail" value:0 action:@selector(setEyeDetailLevel:)];
    [items addObject:eyeDetailItem];
    //去黑眼圈
    TTFacePlasticItem *removePouchItem = [self itemWithCode:@"removePouch" value:0 action:@selector(setRemovePouchLevel:)];
    [items addObject:removePouchItem];
    //祛法令纹
    TTFacePlasticItem *removeWrinklesItem = [self itemWithCode:@"removeWrinkles" value:0 action:@selector(setRemoveWrinklesLevel:)];
    [items addObject:removeWrinklesItem];
    
    _plasticGroup = [items copy];
}

/**
 * 创建组件
 */
- (TTFacePlasticItem *)itemWithCode:(NSString *)code value:(float)value action:(SEL)action
{
    TTFacePlasticItem *faceItem = [TTFacePlasticItem itemWithCode:code action:action];
    //名称
    NSString *title = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
    faceItem.name = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    //图标
    NSString *imageName = [NSString stringWithFormat:@"plastic_%@", code];
    NSString *selectImageName = [NSString stringWithFormat:@"plastic_%@_sel", code];
    faceItem.icon = [UIImage imageNamed:imageName];
    faceItem.selectIcon = [UIImage imageNamed:selectImageName];
    //判断是否为微整形改造
    NSArray *resharpCodes = @[kPlasticKeyExtraCodes];
    if ([resharpCodes containsObject:code]) {
        faceItem.isReshape = YES;
    }
    faceItem.value = value;
    faceItem.defaultValue = value;
    return faceItem;
}


@end
