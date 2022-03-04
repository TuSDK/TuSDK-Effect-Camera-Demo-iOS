//
//  TTFilterModel.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFilterModel.h"
#import "TuCameraFilterPackage.h"
#import "TTRenderDef.h"

//漫画滤镜数组
#define TTComicsFilterCodes @"CHComics_Video", @"USComics_Video", @"JPComics_Video", @"Lightcolor_Video", @"Ink_Video", @"Monochrome_Video"
@interface TTFilterModel()
{
    //是否显示漫画滤镜
    BOOL _isShowComics;
}

@end

@implementation TTFilterModel

- (instancetype)init
{
    if (self = [super init]) {
        _isShowComics = YES;
        [self setupData];
    }
    return self;
}


- (void)setupData
{
    NSArray *filterGroups = [[TuCameraFilterPackage sharePackage] filterGroups];
    //创建滤镜数组
    NSMutableArray<TTFilterGroup *> *filterArray = [NSMutableArray array];
    //创建滤镜数组
    NSMutableArray<NSString *> *filterTitleGroups = [NSMutableArray array];
    
    for (TuFilterGroup *filterGroup in filterGroups) {
        //滤镜组名称
        NSString *title = NSLocalizedStringFromTable(filterGroup.name, @"TuSDKConstants", @"无需国际化");
        //根据滤镜组获取其中包含的所有滤镜
        NSArray *filters = [[TuFilterLocalPackage package] optionsWithGroup:filterGroup];
        NSMutableArray<TTFilterItem *> *items = [NSMutableArray array];
        //遍历滤镜组中的包含的所有滤镜
        for (TuFilterOption *option in filters) {
            TTFilterItem *item = [TTFilterItem itemWithCode:option.code action:@selector(setFilter:)];
            NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", option.code];
            item.name = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
            NSString *thumbName = [NSString stringWithFormat:@"lsq_filter_thumb_%@", option.code];
            NSString *thumbPath = [[NSBundle mainBundle] pathForResource:thumbName ofType:@"jpg"];
            item.icon = [UIImage imageWithContentsOfFile:thumbPath];
            [items addObject:item];
        }
        //添加滤镜组标题
        [filterTitleGroups addObject:title];
        //包装滤镜组
        TTFilterGroup *group = [TTFilterGroup groupWithName:title items:items];
        [filterArray addObject:group];
    }
    
    //漫画滤镜
    if (_isShowComics) {
        NSString *title = NSLocalizedStringFromTable(@"tu_漫画", @"TuSDKConstants", @"漫画");
        NSArray *comicsItems = @[TTComicsFilterCodes];
        NSMutableArray<TTFilterItem *> *items = [NSMutableArray array];
        for (NSString *comicsCode in comicsItems) {
            
            TTFilterItem *item = [TTFilterItem itemWithCode:comicsCode action:@selector(setFilter:)];
            NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", comicsCode];
            item.name = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
            item.isComics = YES;
            NSString *thumbName = [NSString stringWithFormat:@"lsq_filter_thumb_%@", comicsCode];
            NSString *thumbPath = [[NSBundle mainBundle] pathForResource:thumbName ofType:@"jpg"];
            item.icon = [UIImage imageWithContentsOfFile:thumbPath];
            [items addObject:item];
        }
        //添加滤镜组标题
        [filterTitleGroups addObject:title];
        //包装滤镜组
        TTFilterGroup *group = [TTFilterGroup groupWithName:title items:items];
        [filterArray addObject:group];
    }
    _filterGroups = [filterArray copy];
    _titleGroups  = [filterTitleGroups copy];
}

/**
 * 根据滤镜code获取对应调节栏信息
 * @param code 滤镜code
 */
- (NSMutableArray *)changeFilterWithCode:(NSString *)code;
{
    //获取滤镜配置参数
    SelesParameters *filterParams = [SelesParameters parameterWithCode:code model:TuFilterModel_Filter];
    TuFilterOption *filtrOption = [[TuFilterLocalPackage package] optionWithCode:code];
    
    for (NSString *key in filtrOption.args)
    {
        NSNumber *val = [filtrOption.args valueForKey:key];
        [filterParams appendFloatArgWithKey:key value:val.floatValue];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    if (filterParams || filterParams.args)
    {
        for (NSInteger parIndex = 0; parIndex < filterParams.args.count; parIndex++)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];

            NSString *paramName = filterParams.args[parIndex].key;
            CGFloat paramVal = filterParams.args[parIndex].precent;
            CGFloat defaultVal = filterParams.args[parIndex].defaultValue;

            paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", paramName];
            paramName = NSLocalizedStringFromTable(paramName, @"TuSDKConstants", @"无需国际化");

            [dic setObject:paramName forKey:@"name"];
            [dic setObject:[NSNumber numberWithFloat:paramVal] forKey:@"val"];
            [dic setObject:[NSNumber numberWithFloat:defaultVal] forKey:@"defaultVal"];

            [params addObject:dic];
        }
    }
    return [params copy];
}

@end
