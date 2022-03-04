/********************************************************
 * @file    : TuStickerBaseDatasets.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 
*********************************************************/
#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"

@class TuStickerBaseData;

@protocol TuBaseCategoryItemDelegate<NSObject>
- (void)categoryItemLoadCompleted:(TuStickerBaseData *)categoryItem;
@end


@interface TuStickerBaseData<Item>:NSObject
@property (nonatomic) Item item; // 道具项数据
@property (nonatomic, readonly) BOOL online; // 当前贴纸道具是否为在线贴纸，如果为 true 需下载后方可使用
@property (nonatomic, assign) BOOL isDownLoading; // 是否正在下载中
@property (nonatomic, weak) id<TuBaseCategoryItemDelegate> delegate;

- (void)loadThumb:(UIImageView *)thumbImageView completed:(void(^)(BOOL))hander;
- (void)load;
@end


@interface TuStickerBaseDatasets:NSObject
@property(nonatomic, copy) NSString *name; // 分类名称
@property(nonatomic, strong) NSArray<TuStickerBaseData *> *propsItems; // 分类道具

- (BOOL)canRemovePropsItem:(TuStickerBaseData *)propsItem;
- (BOOL)removePropsItem:(TuStickerBaseData *)propsItem;
@end


#pragma mark - 支持的 json 配置格式

// 示例配置
// {
//     "categories":
//     [
//         {
//             "categoryName": "分类名称0", // 分类名称
//             "stickers": // 道具数组，支持本地道具和在线道具
//             [
//                 { // 在线道具示例，需配置 `name`、`id`、`previewImage`
//                     // 道具名称
//                     "name": "道具0",
//                     // 道具唯一 ID
//                     "id": "1024",
//                     "previewImage": "https://img.tusdk.com/api/stickerGroup/img?id=stickerID" // 道具预览图 URL
//                 },
//                 { // 本地道具配置示例，只需配置 `id`
//                     "id": "1048576" // 本地道具对应的 ID
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
