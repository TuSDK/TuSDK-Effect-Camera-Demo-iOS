/********************************************************
 * @file    : TuBeautyPanelConfig.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美肤、微整形和美妆默认配置
*********************************************************/

#import "TuBeautyPanelConfig.h"

#define KCosmeticEyeBrow @"标准黑", @"标准灰", @"标准棕", @"柳弯黑", @"柳弯灰", @"柳弯棕", @"叶细黑", @"叶细灰", @"叶细棕", @"峰眉黑", @"峰眉灰", @"峰眉棕", @"粗平黑", @"粗平灰", @"粗平棕", @"弯线黑", @"弯线灰", @"弯线棕", @"芭比黑", @"芭比灰", @"芭比棕", @"小桃黑", @"小桃灰", @"小桃棕", @"新月黑", @"新月灰", @"新月棕", @"断眉黑", @"断眉灰", @"断眉棕", @"野生黑", @"野生灰", @"野生棕", @"欧线黑", @"欧线灰", @"欧线棕", @"圆眉黑", @"圆眉灰", @"圆眉棕", @"延禧黑", @"延禧灰", @"延禧棕"


@implementation TuBeautyPanelConfig


+ (SelesParameters *)defaultPlasticParameters
{
    NSString *filterCode = @"TusdkFacePlastic";
    TuFilterModel filterModel = TuFilterModel_PlasticFace;
    
    SelesParameters *plasticParams = [SelesParameters parameterWithCode:filterCode model:filterModel];

    NSArray *plasticCodes = @[kPlasticKeyCodes];

    for (NSString *code in plasticCodes)
    {
        CGFloat value = 0.0f;
        
        if ([code isEqualToString:@"eyeSize"]) // 大眼
        {
            value = 0.3f;
        }
        else if ([code isEqualToString:@"chinSize"]) // 瘦脸
        {
            value = 0.5f;
        }
        else if ([code isEqualToString:@"noseSize"]) // 瘦鼻
        {
            value = 0.2f;
        }
        
        
        if ([code isEqualToString:@"mouthWidth"]
                || [code isEqualToString:@"archEyebrow"]
                || [code isEqualToString:@"jawSize"]
                || [code isEqualToString:@"eyeAngle"]
                || [code isEqualToString:@"eyeDis"]
                || [code isEqualToString:@"forehead"]
                || [code isEqualToString:@"browPosition"]
                || [code isEqualToString:@"lips"]
                || [code isEqualToString:@"philterum"]
                || [code isEqualToString:@"eyeHeight"])
        {
            [plasticParams appendFloatArgWithKey:code value:value minValue:-1 maxValue:1];
        }
        else
        {
            [plasticParams appendFloatArgWithKey:code value:value];
        }
        
    }
    
    return plasticParams;
}

+ (SelesParameters *)defaultPlasticExtraParameters
{
    NSString *filterCode = @"Plastic";
    TuFilterModel filterModel = TuFilterModel_PlasticFace;
    
    SelesParameters *plasticExtraParams = [SelesParameters parameterWithCode:filterCode model:filterModel];

    NSArray *plasticExtraCodes = @[kPlasticKeyExtraCodes];
    
    for (NSString *code in plasticExtraCodes)
    {
        [plasticExtraParams appendFloatArgWithKey:code value:0.0f];
    }
    
    return plasticExtraParams;
}


+ (SelesParameters *)defaultSkinParameters:(TuSkinFaceType)mode
{
    NSString *filterCode = @"Skin";
    TuFilterModel filterModel = TuFilterModel_SkinFace;

    switch (mode)
    {
        case TuSkinFaceTypeNatural: // 自然美颜
        {
            filterCode = @"skin_precision";
        }
        break;
            
        case TuSkinFaceTypeMoist: // 极致美颜
        {
            filterCode = @"skin_extreme";
        }
        break;
        
        case TuSkinFaceTypeBeauty: // 新美颜
        default:
        {
            filterCode = @"skin_beauty";
        }
        break;
    }
    
    SelesParameters *skinParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    
    switch (mode)
    {
        case TuSkinFaceTypeNatural: // 自然美颜
        {
            [skinParams appendFloatArgWithKey:@"smoothing" value:0.8f];
            [skinParams appendFloatArgWithKey:@"whitening" value:0.3f];
            [skinParams appendFloatArgWithKey:@"ruddy" value:0.2f];
        }
        break;
            
        case TuSkinFaceTypeMoist: // 极致美颜
        {
            [skinParams appendFloatArgWithKey:@"smoothing" value:0.8f];
            [skinParams appendFloatArgWithKey:@"whitening" value:0.3f];
            [skinParams appendFloatArgWithKey:@"ruddy" value:0.2f];
        }
        break;
        
        case TuSkinFaceTypeBeauty: // 新美颜
        default:
        {
            [skinParams appendFloatArgWithKey:@"smoothing" value:0.8f];
            [skinParams appendFloatArgWithKey:@"whitening" value:0.3f];
            [skinParams appendFloatArgWithKey:@"sharpen" value:0.6f];
        }
        break;
    }
    
    return skinParams;
}

+ (SelesParameters *)defaultCosmeticParameters
{
    NSString *filterCode = @"Cosmetic";
    TuFilterModel filterModel = TuFilterModel_CosmeticFace;
    
    SelesParameters *cosmeticParams = [SelesParameters parameterWithCode:filterCode model:filterModel];
    
//    [cosmeticParams appendFloatArgWithKey:@"facialEnable" value:0]; // 修容开关
    [cosmeticParams appendFloatArgWithKey:@"facialOpacity" value:0.4f];  // 修容不透明度
//    [cosmeticParams appendFloatArgWithKey:@"facialId" value:0];  // 修容贴纸id
//
//    [cosmeticParams appendFloatArgWithKey:@"lipEnable" value:0];  // 口红开关
    [cosmeticParams appendFloatArgWithKey:@"lipOpacity" value:0.4f];  // 口红不透明度
//    [cosmeticParams appendFloatArgWithKey:@"lipStyle" value:0];  // 口红类型
//    [cosmeticParams appendFloatArgWithKey:@"lipColor" value:0];  // 口红颜色
//
//    [cosmeticParams appendFloatArgWithKey:@"blushEnable" value:0];  // 腮红开关
    [cosmeticParams appendFloatArgWithKey:@"blushOpacity" value:0.5f];  // 腮红不透明度
//    [cosmeticParams appendFloatArgWithKey:@"blushId" value:0];  // 腮红贴纸id
//
//    [cosmeticParams appendFloatArgWithKey:@"browEnable" value:0];  // 眉毛开关
    [cosmeticParams appendFloatArgWithKey:@"browOpacity" value:0.4f];  // 眉毛不透明度
//    [cosmeticParams appendFloatArgWithKey:@"browId" value:0];  // 眉毛贴纸id
//
//    [cosmeticParams appendFloatArgWithKey:@"eyeshadowEnable" value:0];  // 眼影开关
    [cosmeticParams appendFloatArgWithKey:@"eyeshadowOpacity" value:0.5f];  // 眼影不透明度
//    [cosmeticParams appendFloatArgWithKey:@"eyeshadowId" value:0];  // 眼影贴纸id
//
//    [cosmeticParams appendFloatArgWithKey:@"eyelineEnable" value:0];  // 眼线开关
    [cosmeticParams appendFloatArgWithKey:@"eyelineOpacity" value:0.5f];  // 眼线不透明度
//    [cosmeticParams appendFloatArgWithKey:@"eyelineId" value:0];  // 眼线贴纸id
//
//    [cosmeticParams appendFloatArgWithKey:@"eyelashEnable" value:0];  // 睫毛开关
    [cosmeticParams appendFloatArgWithKey:@"eyelashOpacity" value:0.5f];  // 睫毛不透明度
//    [cosmeticParams appendFloatArgWithKey:@"eyelashId" value:0];  // 睫毛贴纸id
    
    return cosmeticParams;
}


/**设置默认的微整形参数值*/
+ (NSDictionary *)defaultPlasticValue
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithFloat:0.3f] forKey:@"eyeSize"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"chinSize"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"cheekNarrow"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"smallFace"];
    [params setValue:[NSNumber numberWithFloat:0.2f] forKey:@"noseSize"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"noseHeight"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"mouthWidth"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"lips"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"philterum"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"archEyebrow"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"browPosition"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"jawSize"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"cheekLowBoneNarrow"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"eyeAngle"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"eyeInnerConer"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"eyeOuterConer"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"eyeDis"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"eyeHeight"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"forehead"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"cheekBoneNarrow"];
    
    return [params copy];
}

/**设置微整形参数值*/
+ (NSDictionary *)defaultExtraPlasticValue
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"eyelid"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"eyemazing"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"whitenTeeth"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"eyeDetail"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"removePouch"];
    [params setValue:[NSNumber numberWithFloat:0.0f] forKey:@"removeWrinkles"];
    
    return [params copy];
}

/**设置美肤参数值*/
+ (NSDictionary *)defaultSkinValue
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithFloat:0.8f] forKey:@"smoothing"];
    [params setValue:[NSNumber numberWithFloat:0.3f] forKey:@"whitening"];
    [params setValue:[NSNumber numberWithFloat:0.2f] forKey:@"ruddy"];
    [params setValue:[NSNumber numberWithFloat:0.6f] forKey:@"sharpen"];
    
    return [params copy];
}

/**设置默认的美妆参数值*/
+ (NSDictionary *)defaultCosmeticValue
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithFloat:0.4f] forKey:@"lipOpacity"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"blushOpacity"];
    [params setValue:[NSNumber numberWithFloat:0.4f] forKey:@"browOpacity"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"eyeshadowOpacity"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"eyelineOpacity"];
    [params setValue:[NSNumber numberWithFloat:0.5f] forKey:@"eyelashOpacity"];
    [params setValue:[NSNumber numberWithFloat:0.4f] forKey:@"facialOpacity"];
    
    return [params copy];
}


//获取美妆数组
+ (NSArray *)cosmeticDataSet
{
    // 美妆
    //@"CosLipGloss", @"CosBlush", @"CosBrows", @"CosEyeShadow", @"CosEyeLine", @"CosEyeLash", @"CosIris"
    return @[@"reset", @"point", @"lipstick", @"blush", @"eyebrow", @"eyeshadow", @"eyeliner", @"eyelash", @"shading powder"];
}

/**
 根据美妆code获取数组
 @param code 美妆code
 @return code名称数组
 */
+ (NSArray *)dataSetWithCosmeticCode:(NSString *)code;
{
    if ([code isEqualToString:@"reset"])
    {
        return @[@"reset"];
    }
    else if ([code isEqualToString:@"point"])
    {
        return @[@"point"];
    }
    else if ([code isEqualToString:@"lipstick"])
    {
        //口红
        NSArray *stickArray = [TuBeautyPanelConfig codeNameDataSetByCosmeticCode:code];
        return stickArray;
    }
    else if ([code isEqualToString:@"blush"])
    {
        //腮红
        NSArray *blushArray = [TuBeautyPanelConfig codeNameDataSetByCosmeticCode:code];
        return blushArray;
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        //眉毛
        return @[@"point", @"back", @"eyebrowType", @"reset", KCosmeticEyeBrow, @"point"];
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        //眼影
        NSArray *eyeShadowArray = [TuBeautyPanelConfig codeNameDataSetByCosmeticCode:code];
        return eyeShadowArray;
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        //睫毛
        NSArray *eyeLinerArray = [TuBeautyPanelConfig codeNameDataSetByCosmeticCode:code];
        return eyeLinerArray;
    }
    else
    {
        NSArray *eyeLashArray = [TuBeautyPanelConfig codeNameDataSetByCosmeticCode:code];
        return eyeLashArray;
    }
}

/**
 根据美妆code获取名称数组
 @param code 美妆code
 @return 相对应code下包含的贴纸名称数组
 */
+ (NSMutableArray *)codeNameDataSetByCosmeticCode:(NSString *)code
{
    //获取对应的code数组
    NSDictionary *cosmeticParam = [TuBeautyPanelConfig localCosmeticSticekerJSON];
    
    NSMutableArray *titleDataSet = [NSMutableArray array];
    
    //添加 返回 和 重置 字段
    if (![code isEqualToString:@"lipstick"])
    {
        [titleDataSet addObject:@"point"];
    }
    
    [titleDataSet addObject:@"back"];
    
    if ([code isEqualToString:@"lipstick"])
    {
        [titleDataSet addObject:@"lipstickType"];
    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        [titleDataSet addObject:@"eyebrowType"];
    }
    
    [titleDataSet addObject:@"reset"];
    
    //未正确读取到json文件，只返回"back" 和 "reset"
    if (cosmeticParam == nil)
    {
        NSLog(@"cosmeticCategories.json is not found");
        return titleDataSet;
    }
    NSDictionary *codeParams = [cosmeticParam objectForKey:code];
    
    NSArray *blushStickerArray = codeParams[@"stickers"];
    
    for (NSDictionary *stickerParam in blushStickerArray)
    {
        NSString *codeName = stickerParam[@"name"];
        [titleDataSet addObject:codeName];
    }
    //shading powder
    //foundation
    if (![code isEqualToString:@"shading powder"])
    {
        [titleDataSet addObject:@"point"];
    }
    
    return titleDataSet;
}

/**
 根据眉毛类型 和 贴纸名称获取贴纸code
 @param browType 眉毛类型
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)eyeBrowCodeByBrowType:(NSInteger)browType stickerName:(NSString *)stickerName
{
    NSDictionary *cosmeticParam = [TuBeautyPanelConfig localCosmeticSticekerJSON];
    //未正确读取到json文件，返回空
    if (cosmeticParam == nil)
    {
        NSLog(@"cosmeticCategories.json is not found");
        return @"";
    }
    //获取对应的code数组
    NSString *code = @"eyebrow-Fog";
    //0 -> 雾根眉  1 -> 雾眉
    if (browType == 0)
    {
        code = @"eyebrow-Fogen";
        stickerName = [stickerName stringByAppendingString:@"b"];
    }
    else
    {
        stickerName = [stickerName stringByAppendingString:@"a"];
    }
    NSDictionary *codeParams = [[TuBeautyPanelConfig localCosmeticSticekerJSON] objectForKey:code];
    NSArray *blushStickerArray = codeParams[@"stickers"];
    
    for (NSDictionary *stickerParam in blushStickerArray)
    {
        if ([stickerParam[@"name"] isEqualToString:stickerName])
        {
            return stickerParam[@"id"];
        }
    }
    return @"";
}


/**
 根据美妆code 和 贴纸名称获取贴纸code
 @param code 美妆code
 @param stickerName 贴纸名称
 @return 贴纸code
 */
+ (NSString *)effectCodeByCosmeticCode:(NSString *)code stickerName:(NSString *)stickerName
{
    NSDictionary *cosmeticParam = [TuBeautyPanelConfig localCosmeticSticekerJSON];
    //未正确读取到json文件，返回空
    if (cosmeticParam == nil)
    {
        NSLog(@"cosmeticCategories.json is not found");
        return @"";
    }
    //获取对应的code数组
    NSDictionary *codeParams = [[TuBeautyPanelConfig localCosmeticSticekerJSON] objectForKey:code];
    NSArray *blushStickerArray = codeParams[@"stickers"];
    
    for (NSDictionary *stickerParam in blushStickerArray)
    {
        if ([stickerParam[@"name"] isEqualToString:stickerName])
        {
            return stickerParam[@"id"];
        }
    }
    return @"";
}

/**
 本地配置的美妆数据

 @return NSDictionary<NSString *,NSDictionary*> *
 */
+ (NSDictionary<NSString *,NSDictionary*> *)localCosmeticSticekerJSON
{
   
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"cosmeticCategories" ofType:@"json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:0 error:&error];
    if (error) {
        NSLog(@"cosmetic sticker categories error: %@", error);
        return nil;
    }
    
    return jsonDic;
}


/**
 本地配置的口红参数
 */
+ (int)stickLipParamByStickerName:(NSString *)stickerName
{
    if ([stickerName isEqualToString:@"lipStick_1"])
    {
        //枫叶红
        return 0xB23029;
    }
    else if ([stickerName isEqualToString:@"lipStick_2"])
    {
        //正红色
        return 0xC2030D;
    }
    else if ([stickerName isEqualToString:@"lipStick_3"])
    {
        //牛血红
        return 0x6A0500;
    }
    else if ([stickerName isEqualToString:@"lipStick_4"])
    {
        //番茄橘
        return 0xA02112;
    }
    else if ([stickerName isEqualToString:@"lipStick_5"])
    {
        //暖柿红
        return 0xEF5D47;
    }
    else if ([stickerName isEqualToString:@"lipStick_6"])
    {
        //正橘色
        return 0xBF1B1C;
    }
    else if ([stickerName isEqualToString:@"lipStick_7"])
    {
        //珊瑚粉
        return 0xF27A7A;
    }
    else if ([stickerName isEqualToString:@"lipStick_8"])
    {
        //玫红色
        return 0xD00A39;
    }
    else if ([stickerName isEqualToString:@"lipStick_9"])
    {
        //梅子色
        return 0x6A122D;
    }
    else if ([stickerName isEqualToString:@"lipStick_10"])
    {
        //覆盆子
        return 0x842852;
    }
    else if ([stickerName isEqualToString:@"lipStick_11"])
    {
        //肉桂色
        return 0xE58C7A;
    }
    else if ([stickerName isEqualToString:@"lipStick_12"])
    {
        //奶茶色
        return 0xFFBEB5;
    }
    else
    {
        //豆沙色
        return 0xB78073;
    }
}


@end
