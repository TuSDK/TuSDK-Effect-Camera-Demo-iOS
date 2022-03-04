//
//  TTCosmeticGroup.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/14.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTCosmeticGroup.h"
#import "TuBeautyPanelConfig.h"
@implementation TTCosmeticGroup

- (instancetype)init
{
    if (self = [super init]) {
        
        [self setupData];
    }
    return self;
}

- (void)setupData
{
//    TTCosmeticItem *item = [[TTCosmeticItem alloc] init];
 
//    NSArray *stickArray = [TuBeautyPanelConfig dataSetWithCosmeticCode:@"lipstick"];
//    //获取对应的code数组
//    NSDictionary *cosmeticParam = [self localCosmeticSticekerJSON];
//    NSLog(@"TT:cosmetic====%@", cosmeticParam);
    
    NSMutableArray *models = [NSMutableArray array];
    //一键卸妆
    NSString *resetName = NSLocalizedStringFromTable(@"tu_cosmeticReset", @"VideoDemo", @"美妆");
    TTCosmeticModel *resetModel = [TTCosmeticModel modelWithCode:@"reset" name:resetName];
    resetModel.icon = [UIImage imageNamed:@"makeup_not_ic"];
    [models addObject:resetModel];
    
    //标记点
    TTCosmeticModel *pointModel = [TTCosmeticModel modelWithCode:@"point" name:@""];
    pointModel.isPoint = YES;
    [models addObject:pointModel];
    
    //口红
    TTCosmeticModel *lipStickModel = [self cosmeticModelWith:@"lipstick"];
    [models addObject:lipStickModel];
    
    //腮红
    TTCosmeticModel *blushModel = [self cosmeticModelWith:@"blush"];
    [models addObject:blushModel];
    
    //眉毛
    TTCosmeticModel *eyebrowModel = [self cosmeticModelWith:@"eyebrow"];
    [models addObject:eyebrowModel];
    
    //眼影
    TTCosmeticModel *eyeshadowModel = [self cosmeticModelWith:@"eyeshadow"];
    [models addObject:eyeshadowModel];
    
    //眼线
    TTCosmeticModel *eyelinerModel = [self cosmeticModelWith:@"eyeliner"];
    [models addObject:eyelinerModel];
    
    //睫毛
    TTCosmeticModel *eyelashModel = [self cosmeticModelWith:@"eyelash"];
    [models addObject:eyelashModel];
    
    //修容
    TTCosmeticModel *shadingModel = [self cosmeticModelWith:@"shading powder"];
    [models addObject:shadingModel];
    
    _models = [models copy];
    //[self setupLipStickerData];
}

/**
 * 根据美妆类型创建组件
 */
- (TTCosmeticModel *)cosmeticModelWith:(NSString *)cosmeticType
{
    NSString *name = [NSString stringWithFormat:@"tu_%@", cosmeticType];
    NSString *cosmeticName = NSLocalizedStringFromTable(name, @"VideoDemo", @"美妆");
    TTCosmeticModel *model = [TTCosmeticModel modelWithCode:@"cosmeticType" name:cosmeticName];
    model.icon = [UIImage imageNamed:[NSString stringWithFormat:@"makeup_%@_ic", cosmeticType]];
    
    return model;
}

/// 组装口红数组
- (void)setupLipStickerData
{
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *codeParams = [[self localCosmeticSticekerJSON] objectForKey:@"lipstick"];
    NSArray *stickerArray = codeParams[@"stickers"];
    
    //返回按钮
    TTCosmeticItem *backItem = [TTCosmeticItem itemWithCode:@"back" ID:@"" name:codeParams[@"categoryName"]];
    [items addObject:backItem];
    
    //口红类型
    TTCosmeticItem *styleItem = [TTCosmeticItem itemWithCode:@"lipstickType" ID:@"" name:codeParams[@"categoryName"]];
    //默认为水润
    styleItem.style = TTBeautyLipstickStyleWaterWet;
    styleItem.action = @selector(setLipStyle:);
    styleItem.icon = [UIImage imageNamed:@"lipstick_water_ic"];
    [items addObject:styleItem];
    
    //重置
    NSString *resetTitle = NSLocalizedStringFromTable(@"tu_reset", @"VideoDemo", @"美妆");
    TTCosmeticItem *resetItem = [TTCosmeticItem itemWithCode:@"reset" ID:@"" name:resetTitle];
    resetItem.action = @selector(setLipEnable:);
    resetItem.icon = [UIImage imageNamed:@"reset_ic"];
    [items addObject:resetItem];
    
    //口红数据
    for (NSDictionary *stickerDic in stickerArray) {
        TTCosmeticItem *item = [TTCosmeticItem itemWithCode:@"lipOpacity" ID:stickerDic[@"ID"] name:stickerDic[@"name"]];
        //默认为水润
        item.style = TTBeautyLipstickStyleWaterWet;
        item.defaultValue = 0.4f;
        item.value = 0.4f;
        item.action = @selector(setLipOpacity:);
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:stickerDic[@"name"] ofType:@"jpg"];
        item.icon = [UIImage imageWithContentsOfFile:imagePath];
        
        [items addObject:item];
    }
    
    //标记点
    TTCosmeticItem *pointItem = [TTCosmeticItem itemWithCode:@"point" ID:@"" name:@""];
    [items addObject:pointItem];
    
}


/**
 本地配置的美妆数据

 @return NSDictionary<NSString *,NSDictionary*> *
 */
- (NSDictionary<NSString *,NSDictionary*> *)localCosmeticSticekerJSON
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

@end



@implementation TTCosmeticModel
/**
 * 初始化model
 * @param code 唯一标识
 * @param name 名称
 */
+ (instancetype)modelWithCode:(NSString *)code name:(NSString *)name
{
    TTCosmeticModel *model = [[TTCosmeticModel alloc] init];
    model.code = code;
    model.name = name;
    model.isSelect = NO;
    return model;
}

@end

