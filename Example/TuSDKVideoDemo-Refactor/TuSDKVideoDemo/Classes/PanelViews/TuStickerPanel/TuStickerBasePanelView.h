/********************************************************
 * @file    : TuStickerBasePanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸组显示
*********************************************************/
#import <UIKit/UIKit.h>

@class TuStickerBasePanelView, TuStickerBasePanelViewItem;


@protocol TuCategoryViewDataSource <NSObject>
/**
 * 当前分类页面的道具个数
 * @param pageView 道具分类展示视图
 * @return 当前分类页面道具个数
 */
- (NSInteger)categoryViewNumberOfItems:(TuStickerBasePanelView *)pageView;
/**
 * 配置当前分类下每个道具单元格
 * @param pageView 道具分类展示视图
 * @param cell 道具按钮
 * @param index 按钮索引
 */
- (void)categoryView:(TuStickerBasePanelView *)pageView cellForItemAtIndex:(TuStickerBasePanelViewItem *)cell atIndex:(NSInteger)index;
@end


@protocol TuCategoryViewDelegate <NSObject>
@optional
/**
 * 道具单元格单击选中回调
 * @param pageView 道具分类展示视图
 * @param cell 道具按钮
 * @param index 按钮索引
 */
- (void)categoryView:(TuStickerBasePanelView *)pageView didSelectCell:(TuStickerBasePanelViewItem *)cell atIndex:(NSInteger)index;
/**
 * 询问是否可以删除道具物品
 * @param pageView 道具分类展示视图
 * @param indexPath 按钮索引
 */
- (BOOL)categoryView:(TuStickerBasePanelView *)pageView canDeleteButtonAtIndex:(NSIndexPath *)indexPath;
/**
 * 道具单元格点击删除按钮回调
 * @param pageView 道具分类展示视图
 * @param index 按钮索引
 */
- (void)categoryView:(TuStickerBasePanelView *)pageView didTapDeleteButtonAtIndex:(NSInteger)index;
@end


#pragma mark - StickerCollectionCell
@interface TuStickerBasePanelViewItem : UICollectionViewCell
@property (nonatomic, strong, readonly) UIImageView *thumbnailView; // 缩略图
@property (nonatomic, strong, readonly) UIImageView *loadingImageView; // 加载视图
@property (nonatomic, strong, readonly) UIImageView *downloadIconView; // 下载图标视图
@property (nonatomic, strong, readonly) UIButton *deleteButton; // 删除按钮
@property (nonatomic, strong, readonly) UIView *selectedView; // 选中状态视图
@property (nonatomic, assign) BOOL online; // 是否为在线道具

- (void)startLoading; // 切换至载入中状态
- (void)finishLoading; //  结束载入中状态
@end


@interface TuStickerBasePanelView : UIView <UICollectionViewDataSource>
@property (nonatomic, strong, readonly) UICollectionView *itemCollectionView;
@property (nonatomic, weak) id<TuCategoryViewDataSource> dataSource;
@property (nonatomic, weak) id<TuCategoryViewDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedIndex; //  选中索引
@property (nonatomic, assign) NSInteger pageIndex; // 当前页面索引

- (void)dismissDeleteButtons; // 隐藏删除按钮
- (void)deselect; // 取消选中

@end
