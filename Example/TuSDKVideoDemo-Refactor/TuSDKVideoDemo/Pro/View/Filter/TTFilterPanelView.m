//
//  TTFilterPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFilterPanelView.h"
#import "TuParametersAdjustView.h"
#import "TuPanelBar.h"
#import "TuViewSlider.h"

#import "TTFilterPanelViewCell.h"
#import "TTFilterModel.h"

#import <TuSDKPulseCore/TuSDKPulseCore.h>
#import "TTRenderDef.h"

@interface TTFilterPanelView()<UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout,
                                TuPanelTabbarDelegate,
                                TuParameterAdjustViewDelegate>
{
    UIView *_backGroudView;
    UICollectionView *_filterCollectionView;
    
    TuParametersAdjustView *_paramtersAdjustView;
    
    TuPanelBar *_tabbar;
    UIButton *_unsetBtn;
    
    CALayer *_verticalSeparatorLayer;
    CALayer *_horizontalSeparatorLayer;
    UIVisualEffectView *_effectBackgroundView;
    
//    NSMutableArray<TuFilterPanelViewDataset *> *_datasets;
    NSInteger _curGroupIndex;      //当前选中的滤镜组序号
    NSInteger _selectFilterIndex;  //当前选中的滤镜序号
    NSInteger _selectGroupIndex;   //当前选中滤镜所在的滤镜组序号

    //是否选中正常滤镜，默认为YES
    BOOL _selectNormalFilter;
    //滤镜数据
    TTFilterModel *_filterModel;
}

@property(nonatomic, strong) id<TTBeautyProtocol> beautyTarget;

@end

@implementation TTFilterPanelView


#pragma mark - instancet
+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    TTFilterPanelView *view = [[TTFilterPanelView alloc] initWithFrame:frame beautyTarget:beautyTarget];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    if (self = [super initWithFrame:frame]) {
        _beautyTarget = beautyTarget;
        [self initWithSubViews];
    }
    return self;
}

#pragma mark - UI
- (void)initWithSubViews
{
    _curGroupIndex = _selectFilterIndex = _selectGroupIndex = 0;
    
    _filterModel = [[TTFilterModel alloc] init];
    
    _backGroudView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_backGroudView];
    
    _effectBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [_backGroudView addSubview:_effectBackgroundView];
    _effectBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 15;
    flowLayout.minimumLineSpacing = 15;
    
    _filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _filterCollectionView.delegate = self;
    _filterCollectionView.dataSource = self;
    _filterCollectionView.showsHorizontalScrollIndicator = NO;
    _filterCollectionView.backgroundColor = [UIColor clearColor];
    [_filterCollectionView registerClass:[TTFilterPanelViewCell class] forCellWithReuseIdentifier:@"TTFilterPanelViewCell"];
    
    [_backGroudView addSubview:_filterCollectionView];
    
    _paramtersAdjustView = [[TuParametersAdjustView alloc] initWithFrame:CGRectZero];
    _paramtersAdjustView.delegate = self;
    [self addSubview:_paramtersAdjustView];
    
    _unsetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_unsetBtn setImage:[UIImage imageNamed:@"video_ic_nix"] forState:0];
    [_unsetBtn addTarget:self action:@selector(unsetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_backGroudView addSubview:_unsetBtn];
    
    _verticalSeparatorLayer = [CALayer layer];
    [_backGroudView.layer addSublayer:_verticalSeparatorLayer];
    _verticalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    _horizontalSeparatorLayer = [CALayer layer];
    [_backGroudView.layer addSublayer:_horizontalSeparatorLayer];
    _horizontalSeparatorLayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    
    // 分页标签栏
    TuPanelBar *tabbar = [[TuPanelBar alloc] initWithFrame:CGRectZero];
    [_backGroudView addSubview:tabbar];
    _tabbar = tabbar;
    tabbar.trackerSize = CGSizeMake(48, 2);
    tabbar.itemSelectedColor = [UIColor whiteColor];
    tabbar.itemNormalColor = [UIColor colorWithWhite:1 alpha:.25];
    tabbar.delegate = self;
    
    tabbar.itemTitles = _filterModel.titleGroups;
    tabbar.itemTitleFont = [UIFont systemFontOfSize:13];
    tabbar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

- (void)layoutSubviews
{
    CGRect safeBounds = self.bounds;
    
    CGFloat safeBottom = 0;
    if ([UIDevice lsqIsDeviceiPhoneX]) {
        safeBottom = 20;
    }
    static const CGFloat kFilterTabbarHeight = 36;
    CGFloat viewHeight = 104 + safeBottom + kFilterTabbarHeight;
    CGFloat sliderHeight = 100;
    const CGFloat separatorHeight = 36;
    // tabbar 高度
    
    _backGroudView.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMaxY(safeBounds) - viewHeight, CGRectGetWidth(safeBounds), viewHeight);

    _effectBackgroundView.frame = CGRectMake(0, 0, safeBounds.size.width, safeBounds.size.height);
    
    _unsetBtn.frame = CGRectMake(CGRectGetMinX(safeBounds), 0, 52, kFilterTabbarHeight);
    _tabbar.frame = CGRectMake(CGRectGetMaxX(_unsetBtn.frame) + 10, 0, CGRectGetWidth(safeBounds) - CGRectGetMaxX(_unsetBtn.frame) - 10, kFilterTabbarHeight);
    _filterCollectionView.frame = CGRectMake(CGRectGetMinX(safeBounds), kFilterTabbarHeight, CGRectGetWidth(safeBounds), sliderHeight);
    if (_filterModel.titleGroups.count < 6) {
        
        CGFloat tabBarWidth = (CGRectGetWidth(safeBounds) - CGRectGetMinX(_tabbar.frame)) / _filterModel.titleGroups.count;
        _tabbar.itemWidth = tabBarWidth;
        
    } else {
        _tabbar.itemsSpacing = 32;
    }
    
    _verticalSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(_unsetBtn.frame), CGRectGetMinY(_unsetBtn.frame) + kFilterTabbarHeight / 2 - separatorHeight / 2, 1, separatorHeight);
    _horizontalSeparatorLayer.frame = CGRectMake(0, CGRectGetMaxY(_unsetBtn.frame), CGRectGetWidth(safeBounds), 1);
    
    _paramtersAdjustView.frame = CGRectMake(CGRectGetMinX(safeBounds) + 15,
    CGRectGetMaxY(safeBounds) - viewHeight - 24 - _paramtersAdjustView.contentHeight, CGRectGetWidth(safeBounds) - 15 * 2, _paramtersAdjustView.contentHeight);

}

#pragma mark - method
- (void)unsetButtonAction:(UIButton *)sender
{
    _paramtersAdjustView.hidden = YES;
    
    TTFilterPanelViewCell *preCell = (TTFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0]];
    preCell.selected = NO;

    //遍历当前并将全部设置为取消选中状态
    for (TTFilterItem *item in _filterModel.filterGroups[_curGroupIndex].items)
    {
        item.selectState = TTFilterSelectStateUnselected;
    }
    
    //选中正常滤镜
    [self updateFilterWithCode:@"Normal"];
    
    _curGroupIndex = _selectFilterIndex = _selectGroupIndex = _tabbar.selectedIndex = 0;
    _selectNormalFilter = YES;
    [_filterCollectionView reloadData];
    [_filterCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

//滑动到上一组滤镜
- (void)swipeToLastFilter
{
    if (_selectGroupIndex != _curGroupIndex)
    {
        _curGroupIndex = _selectGroupIndex;
        _tabbar.selectedIndex = _curGroupIndex;
        [_filterCollectionView reloadData];
    }
    
    TTFilterPanelViewCell *preCell = (TTFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0]];
    preCell.selected = NO;
    
    TTFilterItem *lastItem = _filterModel.filterGroups[_curGroupIndex].items[_selectFilterIndex];
    TTFilterSelectState lastItemState = lastItem.selectState;
    lastItem.selectState = TTFilterSelectStateUnselected;
    
    if (_selectFilterIndex != 0)
    {
        _selectFilterIndex--;
    }
    else
    {
        if (_curGroupIndex != 0)
        {
            _curGroupIndex--;
        }
        else
        {
            _curGroupIndex = _filterModel.titleGroups.count - 1;
        }
        NSInteger curGroupTotalCount = [_filterModel.filterGroups[_curGroupIndex].items count];
        _selectFilterIndex = curGroupTotalCount - 1;
        _tabbar.selectedIndex = _selectGroupIndex = _curGroupIndex;
        [_filterCollectionView reloadData];
        
    }
    
    if (lastItemState != TTFilterSelectStateParamAdjust)
    {
        _paramtersAdjustView.hidden = YES;
    }
    
    TTFilterPanelViewCell *cell = (TTFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0]];
    cell.selected = YES;
    
    TTFilterItem *item = _filterModel.filterGroups[_curGroupIndex].items[_selectFilterIndex];
    item.selectState = lastItemState == TTFilterSelectStateUnselected ? TTFilterSelectStateSelected : lastItemState;
    
    //切换滤镜
    [self updateFilter:item];
    
    [_filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionRight];
    
    _selectNormalFilter = NO;
    
}

//滑动到下一组滤镜
- (void)swipeToNextFilter
{
    if (_selectGroupIndex != _curGroupIndex)
    {
        _curGroupIndex = _selectGroupIndex;
        _tabbar.selectedIndex = _curGroupIndex;
        [_filterCollectionView reloadData];
    }
    
    NSInteger curGroupTotalCount = _filterModel.filterGroups[_curGroupIndex].items.count;
    
    TTFilterPanelViewCell *preCell = (TTFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0]];
    preCell.selected = NO;
    
    TTFilterItem *lastItem = _filterModel.filterGroups[_curGroupIndex].items[_selectFilterIndex];
    TTFilterSelectState lastItemState = lastItem.selectState;
    lastItem.selectState = TTFilterSelectStateUnselected;
    
    if (_selectFilterIndex != curGroupTotalCount - 1)
    {
        if (_selectNormalFilter)
        {
            _curGroupIndex = 0;
            _selectNormalFilter = NO;
        }
        else
        {
            _selectFilterIndex++;
        }

    }
    else
    {
        if (_curGroupIndex != _filterModel.filterGroups.count - 1)
        {
            _curGroupIndex++;
        }
        else
        {
            _curGroupIndex = 0;
        }

        _selectFilterIndex = 0;
        _tabbar.selectedIndex = _selectGroupIndex = _curGroupIndex;

        [_filterCollectionView reloadData];
    }

    if (lastItem.selectState != TTFilterSelectStateParamAdjust)
    {
        _paramtersAdjustView.hidden = YES;
    }
    
    TTFilterPanelViewCell *cell = (TTFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0]];
    cell.selected = YES;
    
    TTFilterItem *item = _filterModel.filterGroups[_curGroupIndex].items[_selectFilterIndex];
    item.selectState = lastItemState == TTFilterSelectStateUnselected ? TTFilterSelectStateSelected : lastItemState;
    
    //切换滤镜
    [self updateFilter:item];

    [_filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectFilterIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    // 响应子视图
    if (hitView != self) {
        return hitView;
    }

    return nil;
}

#pragma mark - TuPanelTabbarDelegate
- (void)panelBar:(TuPanelBar *)bar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    _curGroupIndex = toIndex;

    NSInteger selectItem = 0;
    /**
     *  判断当前选中的tabbar.selectIndex是否和选中的滤镜是同一个滤镜组
     *  YES  则 滚动到 选中滤镜 的位置
     *  NO 则从起始位置开始
     */
    if (_curGroupIndex == _selectGroupIndex)
    {
        selectItem = _selectFilterIndex;
    }
    
    [_filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectItem inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
    [_filterCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(15, 60);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(15, 60);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 60);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _filterModel.filterGroups[_curGroupIndex].items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTFilterPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTFilterPanelViewCell" forIndexPath:indexPath];
    cell.item = _filterModel.filterGroups[_curGroupIndex].items[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTFilterPanelViewCell *cell = (TTFilterPanelViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    
    NSInteger currentFilterGroupIndex = _curGroupIndex;
    if (_curGroupIndex != _selectGroupIndex)
    {
        //选中滤镜组 和 当前滤镜组不一致，则将上一组滤镜的选中状态取消
        currentFilterGroupIndex = _selectGroupIndex;
        
        TTFilterItem *lastFilterItem = _filterModel.filterGroups[currentFilterGroupIndex].items[_selectFilterIndex];
        lastFilterItem.selectState = TTFilterSelectStateUnselected;
        
    } else {
        
        if (_selectFilterIndex != indexPath.item)
        {
            
            TTFilterItem *lastFilterItem = _filterModel.filterGroups[_selectGroupIndex].items[_selectFilterIndex];
            lastFilterItem.selectState = TTFilterSelectStateUnselected;
        }
    }

    TTFilterItem *item = _filterModel.filterGroups[_curGroupIndex].items[indexPath.row];

    if (indexPath.item == _selectFilterIndex)
    {
        //切换选中状态 选中 -> 展示调节栏
        if (item.selectState == TTFilterSelectStateSelected)
        {
            item.selectState = TTFilterSelectStateParamAdjust;
            _paramtersAdjustView.hidden = NO;
        }
        else if (item.selectState == TTFilterSelectStateParamAdjust)
        {
            item.selectState = TTFilterSelectStateSelected;
            _paramtersAdjustView.hidden = NO;
        }
        else
        {
            item.selectState = TTFilterSelectStateSelected;
            _paramtersAdjustView.hidden = YES;
        }
        //切换滤镜
        [self updateFilter:cell.item];
        
    }
    else
    {
        _paramtersAdjustView.hidden = YES;
        item.selectState = TTFilterSelectStateSelected;
        
        //切换滤镜
        [self updateFilter:cell.item];

    }
    _selectGroupIndex = _curGroupIndex;
    _selectFilterIndex = indexPath.item;
    [collectionView reloadData];
}

- (void)adjustFilterParamters:(NSString *)code
{
    NSMutableArray *params = [_filterModel changeFilterWithCode:code];
    if (params.count == 0) return;
    
    [_paramtersAdjustView setParams:params];
    
    CGFloat strength = [params[0][@"defaultVal"] floatValue];
    
    [self.beautyTarget setFilterStrength:strength];
}

- (void)ParameterAdjustView:(TuParametersAdjustView *)paramAdjustView index:(NSInteger)index val:(float)val
{
    if ([self.beautyTarget respondsToSelector:@selector(setFilterStrength:)]) {
        [self.beautyTarget setFilterStrength:val];
    }
}

#pragma mark - changeFilterCode
/**
 * 切换滤镜效果
 * @param filterItem 滤镜组件
 */
- (void)updateFilter:(TTFilterItem *)filterItem
{
    [self updateFilterWithCode:filterItem.code];
}
/**
 * 切换滤镜效果
 * @param code 滤镜code
 */
- (void)updateFilterWithCode:(NSString *)code
{
    if ([self.beautyTarget respondsToSelector:@selector(setFilter:)]) {
        
        [self.beautyTarget setFilter:code];
    }
    //切换滤镜回调，用于视图上实时展示选中滤镜名称
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterPanelView:didSelectFilterCode:)]) {
        [self.delegate filterPanelView:self didSelectFilterCode:code];
    }
    
    //Normal为取消滤镜效果，不需要获取滤镜参数
    if ([code isEqualToString:@"Normal"]) return;
        
    [self adjustFilterParamters:code];
}

@end
