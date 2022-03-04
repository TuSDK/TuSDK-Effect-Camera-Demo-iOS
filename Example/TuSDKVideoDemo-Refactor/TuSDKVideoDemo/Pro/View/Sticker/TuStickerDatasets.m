/********************************************************
 * @file    : TuStickerDatasets.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸组分类
*********************************************************/
#import "TuStickerDatasets.h"
#import "TuOnlineSticker.h"
#import "TuSDKFramework.h"
#import "TuStickerDownloader.h"

/** TuStickerCategoryItem************************************************/
@interface TuStickerCategoryItem()<TuOnlineStickerDownloaderDelegate>
@end


@implementation TuStickerCategoryItem
- (void)setItem:(id)item
{
    [super setItem:item];
}

- (BOOL)online
{
    return [self.item isKindOfClass:[TuOnlineSticker class]];
}

- (void)loadThumb:(UIImageView *)thumbImageView completed:(void (^)(BOOL))hander
{
    if (!thumbImageView)
    {
        return;
    }
    
    if ([self.item isKindOfClass:[TuOnlineSticker class]])
    {
        TuOnlineSticker *onlineSticker = (TuOnlineSticker *)self.item;
        [thumbImageView lsq_setImageWithURL:[NSURL URLWithString:onlineSticker.previewImage]];
        
        if (hander)
        {
            hander(YES);
        }
    }
    else
    {
        TuStickerGroup *sticker = (TuStickerGroup *)self.item;
        [[TuStickerLocalPackage package] loadThumbWithStickerGroup:sticker imageView:thumbImageView];
        
        if (hander)
        {
            hander(YES);
        }
    }
}

- (void)load
{
    if (self.online == false)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(categoryItemLoadCompleted:)])
        {
            [self.delegate categoryItemLoadCompleted:self];
            return;
        }
    }
    
    if ([[TuStickerDownloader shared] isDownloadingWithGroupId:self.item.idt])
    {
        return;
    }
    
    self.isDownLoading = YES;

    uint64_t stickerId = self.item.idt;
    [[TuStickerDownloader shared] addDelegate:self];
    [[TuStickerDownloader shared] downloadWithGroupId:stickerId];
}

#pragma mark - TuSDKOnlineStickerDownloaderDelegate
- (void)onDownloadProgressChanged:(uint64_t)stickerGroupId
                         progress:(CGFloat)progress
                    changedStatus:(TuDownloadTaskStatus)status
{
    if (self.item.idt != stickerGroupId)
    {
        return;
    }
    
    if (status == TuDownloadTaskStatusDowned
        || status == TuDownloadTaskStatusDownFailed)
    {
        // 加载完成后从本地再次获取贴纸数据
        NSArray<TuStickerGroup *> *allLocalStickers = [[TuStickerLocalPackage package] getSmartStickerGroups];
        
        // 是否找到本地贴纸
        typeof(self) weakSelf = self;
        __block BOOL found = NO;
        [allLocalStickers enumerateObjectsUsingBlock:^(TuStickerGroup * _Nonnull stickerGroup, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if (weakSelf.item.idt == stickerGroup.idt)
            {
                weakSelf.item = stickerGroup;
                *stop = YES;
                found = YES;
            }
        }];
        
        self.isDownLoading = NO;
        
        if (status == TuDownloadTaskStatusDowned)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(categoryItemLoadCompleted:)])
            {
                [self.delegate categoryItemLoadCompleted:self];
            }
        }
        
        [[TuStickerDownloader shared] removeDelegate:self];
    }
}

@end


/** TuStickerDatasets************************************************/
static NSString * const kStickerIdKey = @"id";
static NSString * const kStickerNameKey = @"name";
static NSString * const kStickerPreviewImageKey = @"previewImage";
static NSString * const kStickerCategoryNameKey = @"categoryName";
static NSString * const kStickerCategoryStickersKey = @"stickers";
static NSString * const kStickerCategoryCategoriesKey = @"categories";


@implementation TuStickerDatasets
-(instancetype)init
{
    if (self = [super init])
    {
//        self.categoryType = TuSDKMediaEffectDataTypeSticker;
    }
    return self;
}

+ (NSArray *)allCategories
{
    static NSArray<TuStickerBaseDatasets *> *categories;
    if (categories)
    {
        return categories;
    }
    
    /** 本地配置的在线贴纸数据，需要下载后才可以使用 */
    NSDictionary *onlineStickerJSONDic = [self localOnlineSticekerJSON];
    // 遍历 categories 字段的数组，其每个元素是字典
    NSArray *onlineStickerJSONCategories = onlineStickerJSONDic[kStickerCategoryCategoriesKey];
    
    // 获取本地打包及在线下载后的所有贴纸，并创建索引字典
    NSArray<TuStickerGroup *> *allLocalStickers = [[TuStickerLocalPackage package] getSmartStickerGroups];
    NSMutableDictionary *localStickerDic = [NSMutableDictionary dictionary];
    for (TuStickerGroup *sticker in allLocalStickers)
    {
        localStickerDic[@(sticker.idt)] = sticker;
    }
    
    /** 本地贴纸 + 在线贴纸分类 */
    NSMutableArray *allStickerCategories = [NSMutableArray array];
    
    for (NSDictionary *onlineCategory in onlineStickerJSONCategories)
    {
        TuStickerDatasets *stickerCategory = [[TuStickerDatasets alloc] init];
        stickerCategory.name = onlineCategory[kStickerCategoryNameKey];

        // 通过 idt 进行筛选，若本地存在该贴纸，则使用本地的贴纸对象；否则为在线贴纸
        NSMutableArray<TuStickerCategoryItem *> *propsItems = [NSMutableArray array];
        
        for (NSDictionary *stickerDic in onlineCategory[kStickerCategoryStickersKey])
        {
            NSInteger idt = [stickerDic[kStickerIdKey] integerValue];
            TuStickerGroup *sticker = localStickerDic[@(idt)];
            TuStickerCategoryItem *propsItem = [[TuStickerCategoryItem alloc] init];
           
            // 如果本地包含该贴纸 无效下载
            if (sticker)
            {
                propsItem.item = sticker;
                [propsItems addObject:propsItem];
            }
            else
            {
                // 本地不包含该贴纸 需要标记为在线贴纸
                TuOnlineSticker *onlineSticker = [[TuOnlineSticker alloc] init];
                onlineSticker.idt = idt;
                onlineSticker.name = stickerDic[kStickerNameKey];
                onlineSticker.previewImage = stickerDic[kStickerPreviewImageKey];
                propsItem.item = onlineSticker;
                [propsItems addObject:propsItem];
            }
        }
        
        stickerCategory.propsItems = propsItems;
        [allStickerCategories addObject:stickerCategory];
    }
    
    return categories = [allStickerCategories copy];
}

/**
 删除指定道具物品
 
 @param propsItem 道具物品
 */
- (BOOL)removePropsItem:(TuStickerCategoryItem *)propsItem
{
    if (![self canRemovePropsItem:propsItem])
    {
        return NO;
    }
    
    NSUInteger index = [self.propsItems indexOfObject:propsItem];
    
    if (index >= 0 && !propsItem.online)
    {
        // 删除本地存在的贴纸
        [[TuStickerLocalPackage package] removeDownloadWithIdt:propsItem.item.idt];
     
        /** 本地配置的在线贴纸数据，需要下载后才可以使用 */
        NSDictionary *onlineStickerJSONDic = [TuStickerDatasets localOnlineSticekerJSON];
        // 遍历 categories 字段的数组，其每个元素是字典
        NSArray *onlineStickerJSONCategories = onlineStickerJSONDic[kStickerCategoryCategoriesKey];
        
        for (NSDictionary *onlineCategory in onlineStickerJSONCategories)
        {
            for (NSDictionary *stickerDic in onlineCategory[kStickerCategoryStickersKey])
            {
                NSInteger idt = [stickerDic[kStickerIdKey] integerValue];
                
                if (idt == propsItem.item.idt)
                {
                    TuOnlineSticker *onlineSticker = [[TuOnlineSticker alloc] init];
                    onlineSticker.idt = idt;
                    onlineSticker.name = stickerDic[kStickerNameKey];
                    onlineSticker.previewImage = stickerDic[kStickerPreviewImageKey];
                    propsItem.item = onlineSticker;
                }
            }
        }
        
        return YES;
    }
    
    return NO;
}

/**
 本地配置的在线贴纸数据

 @return NSDictionary<NSString *,NSDictionary*> *
 */
+ (NSDictionary<NSString *, NSDictionary*> *)localOnlineSticekerJSON
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"customStickerCategories" ofType:@"json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath])
    {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:0 error:&error];
    if (error)
    {
        NSLog(@"sticker categories error: %@", error);
        return nil;
    }
    
    return jsonDic;
}



#pragma mark - 支持的 json 配置格式示例
// 示例配置
// {
//     "categories":
//     [
//         {
//             "categoryName": "分类名称0", // 分类名称
//             "stickers": // 贴纸数组，支持本地贴纸和在线贴纸
//             [
//                 { // 在线贴纸示例，需配置 `name`、`id`、`previewImage`
//                     // 贴纸名称
//                     "name": "贴纸0",
//                     // 贴纸唯一 ID
//                     "id": "1024",
//                     "previewImage": "https://img.tusdk.com/api/stickerGroup/img?id=stickerID" // 贴纸预览图 URL
//                 },
//                 { // 本地贴纸配置示例，只需配置 `id`
//                     "id": "1048576" // 本地贴纸对应的 ID
//                 }
//             ]
//         },
//         { // 其他分类配置以此类推
//             "categoryName": "分类名称1",
//             "stickers":
//             [
//                 {
//                     "id": "2048"
//                 },
//                 {
//                     "id": "512"
//                 }
//             ]
//         }
//     ]
// }

@end
