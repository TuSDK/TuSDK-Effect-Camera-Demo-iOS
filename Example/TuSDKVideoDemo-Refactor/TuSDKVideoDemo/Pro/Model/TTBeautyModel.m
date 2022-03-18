//
//  TTBeautyModel.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/17.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTBeautyModel.h"
#import "TuBeautyPanelConfig.h"

#import <TuSDKPulseCore/TuSDKPulseCore.h>
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>


@interface TTBeautyModel()<SelesParametersListener>
{
    SelesParameters *_cosmeticParams;
}
@property (nonatomic, strong) id<TTBeautyProtocol> beautyTarget;

@end

@implementation TTBeautyModel

- (instancetype)initWithBeautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    if (self = [super init]) {
        self.beautyTarget = beautyTarget;
    }
    return self;
}

#pragma mark - 微整形相关
/**
 * 配置微整形调节栏参数
 * @param item 微整形组件
 * @return 微整形调节栏参数
 */
- (NSMutableArray *)plasticParamtersViewUpdate:(TTFacePlasticItem *)item
{
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:item.code forKey:@"code"];
    [dic setObject:item.name forKey:@"name"];
    [dic setObject:[NSNumber numberWithFloat:item.value] forKey:@"val"];
    [dic setObject:[NSNumber numberWithFloat:item.defaultValue] forKey:@"defaultVal"];
    [params addObject:dic];
    //显示偏移取值范围
    if (item.iSStyle101)
    {
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"status"];
    }
    
    return params;
    
    
}

/**
 * 配置微整形改造调节栏参数
 * @param item 微整形组件
 * @return 微整形调节栏参数
 */
- (NSMutableArray *)plasticExtraParamtersViewUpdate:(TTFacePlasticItem *)item
{
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:item.code forKey:@"code"];
    [dic setObject:item.name forKey:@"name"];
    [dic setObject:[NSNumber numberWithFloat:item.value] forKey:@"val"];
    [dic setObject:[NSNumber numberWithFloat:item.defaultValue] forKey:@"defaultVal"];
    [params addObject:dic];
    //显示偏移取值范围
    if (item.iSStyle101)
    {
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"status"];
    }
    
    return params;
    
}

/**
 * 根据微整形code修改相对应的参数值
 * @param code 微整形code
 * @param value 参数值
 */
- (void)updatePlasticArgsValue:(NSString *)code value:(float)value
{
    [self updatePlasticWithCode:code value:value];
}


//修改微整形值
- (void)updatePlasticWithCode:(NSString *)code value:(float)value;
{
    if ([code isEqualToString:@"eyeSize"]) {
        //大眼
        if ([self.beautyTarget respondsToSelector:@selector(setEyeEnlargeLevel:)]) {
            
            [_beautyTarget setEyeEnlargeLevel:value];
        }
    } else if ([code isEqualToString:@"chinSize"]) {
        //瘦脸
        if ([self.beautyTarget respondsToSelector:@selector(setCheekThinLevel:)]) {
            
            [_beautyTarget setCheekThinLevel:value];
        }
    } else if ([code isEqualToString:@"cheekNarrow"]) {
        //窄脸
        if ([self.beautyTarget respondsToSelector:@selector(setCheekNarrowLevel:)]) {
            
            [_beautyTarget setCheekNarrowLevel:value];
        }
    } else if ([code isEqualToString:@"smallFace"]) {
        //小脸
        if ([self.beautyTarget respondsToSelector:@selector(setFaceSmallLevel:)]) {
            
            [_beautyTarget setFaceSmallLevel:value];
        }
    } else if ([code isEqualToString:@"noseSize"]) {
        //瘦鼻
        if ([self.beautyTarget respondsToSelector:@selector(setNoseWidthLevel:)]) {
            
            [_beautyTarget setNoseWidthLevel:value];
        }
    } else if ([code isEqualToString:@"noseHeight"]) {
        //长鼻
        if ([self.beautyTarget respondsToSelector:@selector(setNoseHeightLevel:)]) {
            
            [_beautyTarget setNoseHeightLevel:value];
        }
    } else if ([code isEqualToString:@"mouthWidth"]) {
        //嘴形
        if ([self.beautyTarget respondsToSelector:@selector(setMouthWidthLevel:)]) {
            
            [_beautyTarget setMouthWidthLevel:value];
        }
    } else if ([code isEqualToString:@"lips"]) {
        //唇厚
        if ([self.beautyTarget respondsToSelector:@selector(setLipsThicknessLevel:)]) {
            
            [_beautyTarget setLipsThicknessLevel:value];
        }
    } else if ([code isEqualToString:@"philterum"]) {
        //缩人中
        if ([self.beautyTarget respondsToSelector:@selector(setPhilterumThicknessLevel:)]) {
            
            [_beautyTarget setPhilterumThicknessLevel:value];
        }
    } else if ([code isEqualToString:@"archEyebrow"]) {
        //细眉
        if ([self.beautyTarget respondsToSelector:@selector(setBrowThicknessLevel:)]) {
            
            [_beautyTarget setBrowThicknessLevel:value];
        }
    } else if ([code isEqualToString:@"browPosition"]) {
        //唇高
        if ([self.beautyTarget respondsToSelector:@selector(setBrowHeightLevel:)]) {
            
            [_beautyTarget setBrowHeightLevel:value];
        }
    } else if ([code isEqualToString:@"jawSize"]) {
        //下巴
        if ([self.beautyTarget respondsToSelector:@selector(setChinThicknessLevel:)]) {
            
            [_beautyTarget setChinThicknessLevel:value];
        }
    } else if ([code isEqualToString:@"cheekLowBoneNarrow"]) {
        //下颌骨
        if ([self.beautyTarget respondsToSelector:@selector(setCheekLowBoneNarrowLevel:)]) {
            
            [_beautyTarget setCheekLowBoneNarrowLevel:value];
        }
        
    } else if ([code isEqualToString:@"eyeAngle"]) {
        //眼角
        if ([self.beautyTarget respondsToSelector:@selector(setEyeAngleLevel:)]) {
            
            [_beautyTarget setEyeAngleLevel:value];
        }
    } else if ([code isEqualToString:@"eyeInnerConer"]) {
        //开内眼角
        if ([self.beautyTarget respondsToSelector:@selector(setEyeInnerConerLevel:)]) {
            
            [_beautyTarget setEyeInnerConerLevel:value];
        }
    } else if ([code isEqualToString:@"eyeOuterConer"]) {
        //开外眼角
        if ([self.beautyTarget respondsToSelector:@selector(setEyeOuterConerLevel:)]) {
            
            [_beautyTarget setEyeOuterConerLevel:value];
        }
    } else if ([code isEqualToString:@"eyeDis"]) {
        //眼距
        if ([self.beautyTarget respondsToSelector:@selector(setEyeDistanceLevel:)]) {
            
            [_beautyTarget setEyeDistanceLevel:value];
        }
    } else if ([code isEqualToString:@"eyeHeight"]) {
        //眼移动
        if ([self.beautyTarget respondsToSelector:@selector(setEyeHeightLevel:)]) {
            
            [_beautyTarget setEyeHeightLevel:value];
        }
    } else if ([code isEqualToString:@"forehead"]) {
        //发际线
        if ([self.beautyTarget respondsToSelector:@selector(setForeheadHeightLevel:)]) {
            
            [_beautyTarget setForeheadHeightLevel:value];
        }
    } else if ([code isEqualToString:@"cheekBoneNarrow"]) {
        //瘦颧骨
        if ([self.beautyTarget respondsToSelector:@selector(setCheekBoneNarrowLevel:)]) {
            
            [_beautyTarget setCheekBoneNarrowLevel:value];
        }
    } else if ([code isEqualToString:@"eyelid"]) {
        //双眼皮
        if ([self.beautyTarget respondsToSelector:@selector(setEyelidLevel:)]) {
            
            [_beautyTarget setEyelidLevel:value];
        }
    } else if ([code isEqualToString:@"eyemazing"]) {
        //卧蚕
        if ([self.beautyTarget respondsToSelector:@selector(setEyemazingLevel:)]) {
            
            [_beautyTarget setEyemazingLevel:value];
        }
    } else if ([code isEqualToString:@"whitenTeeth"]) {
        //白牙
        if ([self.beautyTarget respondsToSelector:@selector(setWhitenTeethLevel:)]) {
            
            [_beautyTarget setWhitenTeethLevel:value];
        }
    } else if ([code isEqualToString:@"eyeDetail"]) {
        //亮眼
        if ([self.beautyTarget respondsToSelector:@selector(setEyeDetailLevel:)]) {
            
            [_beautyTarget setEyeDetailLevel:value];
        }
    } else if ([code isEqualToString:@"removePouch"]) {
        //去黑眼圈
        if ([self.beautyTarget respondsToSelector:@selector(setRemovePouchLevel:)]) {
            
            [_beautyTarget setRemovePouchLevel:value];
        }
    } else if ([code isEqualToString:@"removeWrinkles"]) {
        //祛法令纹
        if ([self.beautyTarget respondsToSelector:@selector(setRemoveWrinklesLevel:)]) {
            
            [_beautyTarget setRemoveWrinklesLevel:value];
        }
    }
}



#pragma mark - 美肤相关

/**
 * 配置美肤调节栏参数
 * @param item 美肤组件
 * @return 美肤调节栏参数
 */
- (NSMutableArray *)skinParamtersViewUpdate:(TTFaceSkinItem *)item
{
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:item.code forKey:@"code"];
    [dic setObject:item.name forKey:@"name"];
    [dic setObject:[NSNumber numberWithFloat:item.value] forKey:@"val"];
    [dic setObject:[NSNumber numberWithFloat:item.defaultValue] forKey:@"defaultVal"];
    [params addObject:dic];
    
    return params;
}

/**
 * 根据美肤code修改相对应的参数值
 * @param code 微整形code
 * @param value 参数值
 */
- (void)updateSkinWithCode:(NSString *)code value:(float)value;
{
    if ([code isEqualToString:@"smoothing"]) {
        //磨皮
        if ([self.beautyTarget respondsToSelector:@selector(setSmoothLevel:)]) {
            [self.beautyTarget setSmoothLevel:value];
        }
    } else if ([code isEqualToString:@"whitening"]) {
        //美白
        if ([self.beautyTarget respondsToSelector:@selector(setWhiteningLevel:)]) {
            [self.beautyTarget setWhiteningLevel:value];
        }
    } else if ([code isEqualToString:@"sharpen"]) {
        //锐化
        if ([self.beautyTarget respondsToSelector:@selector(setSharpenLevel:)]) {
            [self.beautyTarget setSharpenLevel:value];
        }
    } else if ([code isEqualToString:@"ruddy"]) {
        //红润
        if ([self.beautyTarget respondsToSelector:@selector(setRuddyLevel:)]) {
            [self.beautyTarget setRuddyLevel:value];
        }
    }
}

#pragma mark - 美妆相关
/**
 * 美妆开关
 * @param code 美妆code
 * @param enable 开关
 */
- (void)setCosmeticEnable:(NSString *)code enable:(BOOL)enable;
{
    NSString *paramCode = nil;
    NSString *cosmeticCode = nil;
    if ([code isEqualToString:@"lipstick"])
    {
        //口红开关
        paramCode = @"lipEnable";
        cosmeticCode = @"lipOpacity";
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setLipEnable:)]) {
            [self.beautyTarget setLipEnable:enable];
        }
    }
    else if ([code isEqualToString:@"blush"])
    {
        //腮红开关
        paramCode = @"blushEnable";
        cosmeticCode = @"blushOpacity";
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setBlushEnable:)]) {
            [self.beautyTarget setBlushEnable:enable];
        }
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        //眉毛开关
        paramCode = @"browEnable";
        cosmeticCode = @"browOpacity";
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setBrowEnable:)]) {
            [self.beautyTarget setBrowEnable:enable];
        }
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        //眼影开关
        paramCode = @"eyeshadowEnable";
        cosmeticCode = @"eyeshadowOpacity";
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setEyeshadowEnable:)]) {
            [self.beautyTarget setEyeshadowEnable:enable];
        }
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        paramCode = @"eyelineEnable";
        cosmeticCode = @"eyelineOpacity";
        //眼线开关
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setEyelineEnable:)]) {
            [self.beautyTarget setEyelineEnable:enable];
        }
    }
    else if ([code isEqualToString:@"eyelash"])
    {
        paramCode = @"eyelashEnable";
        cosmeticCode = @"eyelashOpacity";
        //睫毛开关
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setEyelashEnable:)]) {
            [self.beautyTarget setEyelashEnable:enable];
        }
    }
    else if ([code isEqualToString:@"shading powder"])
    {
        paramCode = @"facialEnable";
        cosmeticCode = @"facialOpacity";
        //修容开关
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setFacialEnable:)]) {
            [self.beautyTarget setFacialEnable:enable];
        }
    }
    if (!enable) {
        //设置默认参数
        NSDictionary *cosmeticConfig = [TuBeautyPanelConfig defaultCosmeticValue];
        if ([cosmeticConfig objectForKey:cosmeticCode])
        {
            CGFloat defaultValue = [[cosmeticConfig objectForKey:cosmeticCode] floatValue];
            SelesParameterArg *arg = [_cosmeticParams argWithKey:cosmeticCode];
            arg.precent = defaultValue;
        }
    }
}

/**
 * 设置美妆参数百分比
 * @param code 美妆code
 * @param precent 百分比
 */
- (void)setCosmeticParamsArgKeyWithCode:(NSString *)code precent:(CGFloat)precent
{
    NSString *enableCode = [self cosmeticEnableCodeWithCode:code];
    if (_cosmeticParams == nil) {
        _cosmeticParams = [self getCosmeticParamter];
    }
    [_cosmeticParams argWithKey:enableCode].precent = precent;
}

- (void)setCosmeticParamsArgKeyWithCode:(NSString *)code stickerId:(NSInteger)stickerId
{
    if (_cosmeticParams == nil) {
        _cosmeticParams = [self getCosmeticParamter];
    }
    [_cosmeticParams argWithKey:code].infinteValue = stickerId;
}

/// 根据code、value改变参数
- (void)setCosmeticOpacityArg:(NSString *)opacityCode value:(CGFloat)value
{
    if (_cosmeticParams == nil) {
        _cosmeticParams = [self getCosmeticParamter];
    }
    SelesParameterArg *cosmeticArg = [_cosmeticParams argWithKey:opacityCode];
    if (cosmeticArg)
    {
        cosmeticArg.precent = value;
    }
}

/// 获取参数key值
- (NSString *)cosmeticEnableCodeWithCode:(NSString *)code
{
    NSString *enableCode = nil;
    
    if ([code isEqualToString:@"lipstick"])
    {
        //口红
        enableCode = @"lipEnable";
    }
    else if ([code isEqualToString:@"blush"])
    {
        //腮红
        enableCode = @"blushEnable";
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        //眉毛
        enableCode = @"browEnable";
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        //眼影
        enableCode = @"eyeshadowEnable";
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        //眼线
        enableCode = @"eyelineEnable";
    }
    else if ([code isEqualToString:@"eyelash"])
    {
        //睫毛
        enableCode = @"eyelashEnable";
    }
    else if ([code isEqualToString:@"shading powder"])
    {
        //修容
        enableCode = @"facialEnable";
    }
    
    return enableCode;
}

- (NSString *)cosmeticOpacityCodeWithCode:(NSString *)code
{
    NSString *opacityCode = nil;
    
    if ([code isEqualToString:@"lipstick"])
    {
        //口红
        opacityCode = @"lipOpacity";
    }
    else if ([code isEqualToString:@"blush"])
    {
        //腮红
        opacityCode = @"blushOpacity";
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        //眉毛
        opacityCode = @"browOpacity";
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        //眼影
        opacityCode = @"eyeshadowOpacity";
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        //眼线
        opacityCode = @"eyelineOpacity";
    }
    else if ([code isEqualToString:@"eyelash"])
    {
        //睫毛
        opacityCode = @"eyelashOpacity";
    }
    else if ([code isEqualToString:@"shading powder"])
    {
        //修容
        opacityCode = @"facialOpacity";
    }
    
    return opacityCode;
}

/**
 * 美妆参数面板是否隐藏
 * @param code 美妆code
 */
- (BOOL)cosmeticParamtersViewHidden:(NSString *)code;
{
    if (_cosmeticParams == nil) {
        _cosmeticParams = [self getCosmeticParamter];
    }
    SelesParameterArg *arg = [_cosmeticParams argWithKey:code];
    if (arg == nil) return YES;
    return NO;
}

- (SelesParameters *)getCosmeticParamter
{
    SelesParameters *cosmeticParams = [TuBeautyPanelConfig defaultCosmeticParameters];
    NSString *filterCode = TUPFPTusdkCosmeticFilter_TYPE_NAME;
    // params
    SelesParameters *filterParams = [SelesParameters parameterWithCode:filterCode model:TuFilterModel_CosmeticFace];
    for (SelesParameterArg *arg in cosmeticParams.args)
    {
        [filterParams appendFloatArgWithKey:arg.key value:arg.value];
    }
    filterParams.listener = self;
    
    return filterParams;
}

/**
 * 设置美妆参数
 * @param code 美妆code
 */
- (NSMutableArray *)cosmeticParamtersViewUpdate:(NSString *)code;
{
    if (_cosmeticParams == nil) {
        _cosmeticParams = [self getCosmeticParamter];
    }
    
    SelesParameterArg *arg = [_cosmeticParams argWithKey:code];
    
    NSDictionary *effectConfig = [TuBeautyPanelConfig defaultCosmeticValue];
    CGFloat defaultValue = 0;
    if ([effectConfig objectForKey:code])
    {
        defaultValue = [[effectConfig objectForKey:code] floatValue];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];

    for (int cosmeticIndex = 0; cosmeticIndex < _cosmeticParams.args.count; cosmeticIndex++)
    {
        SelesParameterArg *parameterArg = _cosmeticParams.args[cosmeticIndex];
        
        if ([parameterArg.key isEqualToString:code])
        {
            NSString *paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
            paramName = NSLocalizedStringFromTable(@"tu_不透明度", @"VideoDemo", @"无需国际化");

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:code forKey:@"code"];
            [dic setObject:paramName forKey:@"name"];
            [dic setObject:[NSNumber numberWithFloat:arg.precent] forKey:@"val"];
            [dic setObject:[NSNumber numberWithFloat:defaultValue] forKey:@"defaultVal"];
            [params addObject:dic];
            
        }
    }
    return params;
}

/**
 * 设置美妆贴纸ID
 * @param style 美妆类型
 * @param stickerId 美妆贴纸ID
 */
- (void)setCosmeticIDWithStyle:(NSString *)style stickerID:(NSInteger)stickerId;
{
    if ([style isEqualToString:@"lipStyle"]) {
        //口红类型
        TTBeautyLipstickStyle lipStyle = stickerId;
//        switch (stickerId) {
//            case COSMETIC_SHUIRUN_TYPE:  //水润
//                lipStyle = TTBeautyLipstickStyleWaterWet;
//                break;
//            case COSMETIC_ZIRUN_TYPE:    //滋润
//                lipStyle = TTBeautyLipstickStyleMoist;
//                break;
//            case COSMETIC_WUMIAN_TYPE:   //雾面
//                lipStyle = TTBeautyLipstickStyleMatte;
//                break;
//            default:
//                break;
//        }
        
        if ([self.beautyTarget respondsToSelector:@selector(setLipStyle:)]) {
            [self.beautyTarget setLipStyle:lipStyle];
        }
        
    } else if ([style isEqualToString:@"lipColor"]) {
        //口红颜色
        if ([self.beautyTarget respondsToSelector:@selector(setLipSticker:)]) {
            [self.beautyTarget setLipSticker:stickerId];
        }
        
    } else {
        NSInteger cosmeticStickerId = -1;
        TuStickerGroup *stickerGroup = [[TuStickerLocalPackage package] groupWithGroupID:stickerId];
        if (stickerGroup && stickerGroup.stickers)
        {
            TuSticker *sticker = stickerGroup.stickers[0];
            cosmeticStickerId = sticker.idt;
        }
        //未找到相关贴纸
        if (cosmeticStickerId == -1) return;
        
        if ([style isEqualToString:@"facialId"]) {
            //修容贴纸id
            if ([self.beautyTarget respondsToSelector:@selector(setFacialId:)]) {
                [self.beautyTarget setFacialSticker:cosmeticStickerId];
            }
        } else if ([style isEqualToString:@"blushId"]) {
            //腮红贴纸id
            if ([self.beautyTarget respondsToSelector:@selector(setBlushSticker:)]) {
                [self.beautyTarget setBlushSticker:cosmeticStickerId];
            }
        } else if ([style isEqualToString:@"browId"]) {
            //眉毛贴纸id
            if ([self.beautyTarget respondsToSelector:@selector(setBrowSticker:)]) {
                [self.beautyTarget setBrowSticker:cosmeticStickerId];
            }
        } else if ([style isEqualToString:@"eyeshadowId"]) {
            //眼影贴纸id
            if ([self.beautyTarget respondsToSelector:@selector(setEyeshadowSticker:)]) {
                [self.beautyTarget setEyeshadowSticker:cosmeticStickerId];
            }
        } else if ([style isEqualToString:@"eyelineId"]) {
            //眼线贴纸id
            if ([self.beautyTarget respondsToSelector:@selector(setEyelineSticker:)]) {
                [self.beautyTarget setEyelineSticker:cosmeticStickerId];
            }
        } else if ([style isEqualToString:@"eyelashId"]) {
            //睫毛贴纸id
            if ([self.beautyTarget respondsToSelector:@selector(setEyelashSticker:)]) {
                [self.beautyTarget setEyelashSticker:cosmeticStickerId];
            }
        }
    }
}

#pragma mark - SelesParametersListener
/** 更新参数 */
- (void)onSelesParametersUpdate:(TuFilterModel)model code:(NSString *)code arg:(SelesParameterArg *)arg;
{
    if (model == TuFilterModel_CosmeticFace) {
        if ([arg.key isEqualToString:@"eyelineOpacity"]) {
            //眼线
            if ([self.beautyTarget respondsToSelector:@selector(setEyelineOpacity:)]) {
                [self.beautyTarget setEyelineOpacity:arg.value];
            }
        } else if ([arg.key isEqualToString:@"blushOpacity"]) {
            //腮红
            if ([self.beautyTarget respondsToSelector:@selector(setBlushOpacity:)]) {
                [self.beautyTarget setBlushOpacity:arg.value];
            }
        } else if ([arg.key isEqualToString:@"browOpacity"]) {
            //眉毛
            if ([self.beautyTarget respondsToSelector:@selector(setBrowOpacity:)]) {
                [self.beautyTarget setBrowOpacity:arg.value];
            }
        } else if ([arg.key isEqualToString:@"eyeshadowOpacity"]) {
            //眼影
            if ([self.beautyTarget respondsToSelector:@selector(setEyeshadowOpacity:)]) {
                [self.beautyTarget setEyeshadowOpacity:arg.value];
            }
        } else if ([arg.key isEqualToString:@"eyelashOpacity"]) {
            //睫毛
            if ([self.beautyTarget respondsToSelector:@selector(setEyelashOpacity:)]) {
                [self.beautyTarget setEyelashOpacity:arg.value];
            }
        } else if ([arg.key isEqualToString:@"facialOpacity"]) {
            //修容
            if ([self.beautyTarget respondsToSelector:@selector(setFacialOpacity:)]) {
                [self.beautyTarget setFacialOpacity:arg.value];
            }
        } else if ([arg.key isEqualToString:@"lipOpacity"]) {
            //口红
            if ([self.beautyTarget respondsToSelector:@selector(setLipOpacity:)]) {
                [self.beautyTarget setLipOpacity:arg.value];
            }
        }
    }
}

@end
