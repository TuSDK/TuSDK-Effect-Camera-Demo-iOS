//
//  TTStickerPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/4.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTStickerPanelView.h"
#import "TuSDKFramework.h"
#import "TuStickerBasePanelView.h"
#import "TuStickerDownloader.h"
#import "TuPanelBar.h"
#import "TuViewSlider.h"
#import "TTRenderDef.h"
@interface TTStickerPanelView()<TuPanelTabbarDelegate,
                                ViewSliderDataSource,
                                ViewSliderDelegate,
                                TuCategoryViewDataSource,
                                TuCategoryViewDelegate,
                                TuBaseCategoryItemDelegate,
                                TuOnlineStickerDownloaderDelegate>
{
    UIView *_backgroundView;
    
    TuStickerBaseData *_lastSelectedPropsItem;
    TuStickerBasePanelView *_currentCategoryPageView;
    TuStickerBasePanelViewItem *_lastSelectViewItem;
    
    UIButton *_unsetButton;
    TuPanelBar *_pageTabbar;
    TuViewSlider *_pageSlider;

    CALayer *_verticalSeparatorLayer;/**垂直分割线*/
    CALayer *_horizontalSeparatorLayer;/**水平分割线*/
}

@property(nonatomic, strong) id<TTBeautyProtocol> beautyTarget;

@end

@implementation TTStickerPanelView

#pragma mark - instance
+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    TTStickerPanelView *view = [[TTStickerPanelView alloc] initWithFrame:frame beautyTarget:beautyTarget];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    if (self = [super initWithFrame:frame]) {
        _beautyTarget = beautyTarget;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self addSubview:_backgroundView];
    

    _unsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_unsetButton setImage:[UIImage imageNamed:@"sticker_no_ic"] forState:UIControlStateNormal];
    [self addSubview:_unsetButton];

    _pageTabbar = [[TuPanelBar alloc] initWithFrame:CGRectZero];
    _pageTabbar.itemsSpacing = 24;
    _pageTabbar.trackerSize = CGSizeMake(32, 2);
    _pageTabbar.itemSelectedColor = [UIColor whiteColor];
    _pageTabbar.itemNormalColor = [UIColor whiteColor];
    _pageTabbar.delegate = self;
    _pageTabbar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:_pageTabbar];

    _pageSlider = [[TuViewSlider alloc] initWithFrame:CGRectZero];
    _pageSlider.dataSource = self;
    _pageSlider.delegate = self;
    _pageSlider.selectedIndex = 0;
    [self addSubview:_pageSlider];
    
    _verticalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_verticalSeparatorLayer];
    _verticalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    _horizontalSeparatorLayer = [CALayer layer];
    [self.layer addSublayer:_horizontalSeparatorLayer];
    _horizontalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;

    // dataset load
    NSMutableArray<TuStickerBaseDatasets *> *allCategories = [[NSMutableArray alloc] init];
    NSMutableArray *allCategoryNames = [[NSMutableArray alloc] init];

    NSArray<TuStickerBaseDatasets *> *stickerCategories = [TuStickerDatasets allCategories];
    if (stickerCategories != nil)
    {
        for (int categoryIndex = 0; categoryIndex < stickerCategories.count; categoryIndex++)
        {
            [allCategories addObject:stickerCategories[categoryIndex]];
            [allCategoryNames addObject:stickerCategories[categoryIndex].name];
        }
    }
    
    NSArray<TuStickerBaseDatasets *> *monsterCategories = [TuMonsterDatasets allCategories];
    if (monsterCategories != nil)
    {
        for (int categoryIndex = 0; categoryIndex < monsterCategories.count; categoryIndex++)
        {
            [allCategories addObject:monsterCategories[categoryIndex]];
            [allCategoryNames addObject:monsterCategories[categoryIndex].name];
        }
    }

    _categorys = allCategories;
 
    _pageTabbar.itemTitles = allCategoryNames;
    [_unsetButton addTarget:self action:@selector(unsetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    [[TuStickerDownloader shared] addDelegate:self];

}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;
    const CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    CGFloat safeBottom = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        safeBottom = 20;
    }
    const CGFloat tabbarHeight = 36;
    const CGFloat separatorHeight = 36;
    
    _unsetButton.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMinY(safeBounds), 52, tabbarHeight);
    _pageTabbar.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame), CGRectGetMinY(safeBounds), CGRectGetWidth(safeBounds) - CGRectGetMaxX(_unsetButton.frame), tabbarHeight);
    _pageSlider.frame = CGRectMake(CGRectGetMinX(safeBounds), tabbarHeight, CGRectGetWidth(safeBounds), size.height - tabbarHeight - safeBottom);
    
    _verticalSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(_unsetButton.frame), CGRectGetMinY(_unsetButton.frame) + tabbarHeight / 2 - separatorHeight / 2, 1, separatorHeight);
    _horizontalSeparatorLayer.frame = CGRectMake(0, CGRectGetMaxY(_unsetButton.frame), CGRectGetWidth(safeBounds), 1);
    
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [_currentCategoryPageView dismissDeleteButtons];
}

/**
 获取当前视图的控制器

 @return 视图控制器
 */
- (UIViewController *)viewController
{
    UIResponder *responder = self;
    
    while ((responder = [responder nextResponder]))
    {
        if ([responder isKindOfClass: [UIViewController class]])
        {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

/**
 重置按钮事件

 @param sender 点击的按钮
 */
- (void)unsetButtonAction:(UIButton *)sender
{
    if (_lastSelectedPropsItem)
    {
        //移除动态贴纸特效
        [self removeStickerEffect];
    }
    
    [_currentCategoryPageView deselect];
    _lastSelectViewItem = nil;
}

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    [_currentCategoryPageView dismissDeleteButtons];
}

#pragma mark - tabbar viewSlider
- (void)panelBar:(TuPanelBar *)bar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    _pageSlider.selectedIndex = toIndex;
}

- (NSInteger)numberOfViewsInSlider:(TuViewSlider *)slider
{
    return _categorys.count;
}

- (void)viewSlider:(TuViewSlider *)slider didSwitchToIndex:(NSInteger)index
{
    _pageTabbar.selectedIndex = index;

    _currentCategoryPageView = (TuStickerBasePanelView *)slider.currentView;
}

- (UIView *)viewSlider:(TuViewSlider *)slider viewAtIndex:(NSInteger)index
{
    // 每个贴纸分类下的列表是一个 StickerCategoryPageView 独立页面，显示时创建，完全离开屏幕时销毁。
    TuStickerBasePanelView *categoryView = [[TuStickerBasePanelView alloc] initWithFrame:CGRectZero];
    categoryView.pageIndex = index;
    categoryView.dataSource = self;
    categoryView.delegate = self;
    return categoryView;
}

- (void)reloadPanelView
{
    [_currentCategoryPageView.itemCollectionView reloadData];
}

#pragma mark StickerCategoryPageViewDataSource
- (NSInteger)categoryViewNumberOfItems:(TuStickerBasePanelView *)pageView
{
    return _categorys[pageView.pageIndex].propsItems.count;
}

- (void)categoryView:(TuStickerBasePanelView *)pageView cellForItemAtIndex:(TuStickerBasePanelViewItem *)cell atIndex:(NSInteger)index
{
    TuStickerBaseData *propsItem = _categorys[pageView.pageIndex].propsItems[index];
    cell.online = propsItem.online;
    
    if (propsItem.isDownLoading)
    {
        [cell startLoading];
    }
    else
    {
        [cell finishLoading];
    }
    
    [propsItem loadThumb:cell.thumbnailView completed:^(BOOL result)
    {
        if (!propsItem.isDownLoading)
        {
            [cell finishLoading];
        }
    }];
}


#pragma mark PropsItemPageViewDelegate
- (BOOL)categoryView:(TuStickerBasePanelView *)pageView canDeleteButtonAtIndex:(NSIndexPath *)indexPath
{
    return [_categorys[pageView.pageIndex] canRemovePropsItem:_categorys[pageView.pageIndex].propsItems[indexPath.row]];
}

- (void)categoryView:(TuStickerBasePanelView *)pageView didTapDeleteButtonAtIndex:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;

    NSString *title = NSLocalizedStringFromTable(@"确认删除本地文件？", @"TuSDKConstants", @"确认删除本地文件？");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"取消", @"TuSDKConstants", @"取消")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf->_currentCategoryPageView dismissDeleteButtons];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"删除", @"TuSDKConstants", @"删除")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf->_currentCategoryPageView dismissDeleteButtons];
            
            TuStickerBaseData *propsItem = strongSelf.categorys[pageView.pageIndex].propsItems[index];
            if ([strongSelf.categorys[pageView.pageIndex] removePropsItem:propsItem])
            {
                [strongSelf->_currentCategoryPageView.itemCollectionView reloadData];
            }
            
            if (strongSelf->_lastSelectedPropsItem == propsItem)
            {
                if ([strongSelf.delegate respondsToSelector:@selector(stickerPanelView:didRemoveItem:)])
                {
                    [strongSelf.delegate stickerPanelView:strongSelf didRemoveItem:propsItem];
                }
            }
            
        }
    }]];
    
    [[self viewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)categoryView:(TuStickerBasePanelView *)pageView didSelectCell:(TuStickerBasePanelViewItem *)cell atIndex:(NSInteger)index
{
    if (!cell)
    {
        if (_lastSelectedPropsItem) {
            [self removeStickerEffect];
        }
        [_currentCategoryPageView deselect];
        return;
    }
    
    TuStickerBaseData *propsItem = _categorys[_currentCategoryPageView.pageIndex].propsItems[index];
    _lastSelectedPropsItem = propsItem;
    
    if ([propsItem online] && !propsItem.isDownLoading)
    {
        [cell startLoading];
    }
    _lastSelectViewItem = cell;
    propsItem.delegate = self;
    [propsItem load];
}

- (void)categoryItemLoadCompleted:(TuStickerBaseData *)categoryItem
{
    if (categoryItem == _lastSelectedPropsItem)
    {
        if ([self.delegate respondsToSelector:@selector(stickerPanelView:didSelectItem:)])
        {
            [self.delegate stickerPanelView:self didSelectItem:categoryItem];
        }
        
        [self enableStickers:NO];
        //动态贴纸和哈哈镜不能共存
        if ([categoryItem isKindOfClass:[TuMonsterData class]])
        {
            //移除动态贴纸
            if ([self.beautyTarget respondsToSelector:@selector(removeEffect:)]) {
                [self.beautyTarget removeEffect:TTEffectTypeLiveSticker];
            }
            //添加哈哈镜
            TuMonsterData *monsterData = (TuMonsterData *)categoryItem;
            TuSDKMonsterFaceType faceType = (TuSDKMonsterFaceType)[((NSNumber *)monsterData.item) unsignedIntValue];
            TTMonsterStyle monsterStyle = TTMonsterStyleEmpty;
            switch (faceType) {
                case TuSDKMonsterFaceTypeBigNose:        //大鼻子
                    monsterStyle = TTMonsterStyleBigNose;
                    break;
                case TuSDKMonsterFaceTypePieFace:        //大饼脸
                    monsterStyle = TTMonsterStylePieFace;
                    break;
                case TuSDKMonsterFaceTypeSquareFace:     //国字脸
                    monsterStyle = TTMonsterStyleSquareFace;
                    break;
                case TuSDKMonsterFaceTypeThickLips:      //厚嘴唇
                    monsterStyle = TTMonsterStyleThickLips;
                    break;
                case TuSDKMonsterFaceTypeSmallEyes:      //眯眯眼
                    monsterStyle = TTMonsterStyleSmallEyes;
                    break;
                case TuSDKMonsterFaceTypePapayaFace:     //木瓜脸
                    monsterStyle = TTMonsterStylePapayaFace;
                    break;
                case TuSDKMonsterFaceTypeSnakeFace:      //蛇精脸
                    monsterStyle = TTMonsterStyleSnakeFace;
                    break;
                default:
                    break;
            }
            if ([self.beautyTarget respondsToSelector:@selector(setMonsterStyle:)]) {
                [self.beautyTarget setMonsterStyle:monsterStyle];
            }
        }
        else
        {
            //动态贴纸
            TuStickerGroup *stickerGroup = (TuStickerGroup *)categoryItem.item;
            if (stickerGroup) {
                //移除哈哈镜
                if ([self.beautyTarget respondsToSelector:@selector(removeEffect:)]) {
                    [self.beautyTarget removeEffect:TTEffectTypeMonster];
                }
                //添加动态贴纸
                NSInteger stickerGroupId = stickerGroup.idt;
                if ([self.beautyTarget respondsToSelector:@selector(setLiveSticker:)]) {
                    [self.beautyTarget setLiveSticker:stickerGroupId];
                }
            }
        }
    }
}

#pragma mark TuSDKOnlineStickerDownloaderDelegate
- (void)onDownloadProgressChanged:(uint64_t)stickerGroupId
                         progress:(CGFloat)progress
                    changedStatus:(TuDownloadTaskStatus)status
{
    if (status == TuDownloadTaskStatusDowned || status == TuDownloadTaskStatusDownFailed)
    {
        [self reloadPanelView];
    }
}

#pragma mark - method
- (void)hiddenPanelView:(UIButton *)sender
{
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerPanelViewHidden:)])
    {
        [self.delegate stickerPanelViewHidden:self];
    }
}

- (void)enableStickers:(BOOL)enable;
{
    if ([_lastSelectedPropsItem isKindOfClass:[TuMonsterData class]] && _lastSelectViewItem != nil)
    {
        //哈哈镜特效和微整形特效 不能同时存在
        [self removeStickerEffect];
        if (enable)
        {
            [_currentCategoryPageView deselect];
        }
    }
}

/// 移除动态贴纸特效
- (void)removeStickerEffect
{
    if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(removeEffect:)]) {
        
        //贴纸移除、哈哈镜移除
        [self.beautyTarget removeEffect:TTEffectTypeLiveSticker];
        [self.beautyTarget removeEffect:TTEffectTypeMonster];
    }
}

@end
