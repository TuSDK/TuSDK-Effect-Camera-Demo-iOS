/********************************************************
 * @file    : TuFilterPanelView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 滤镜面板
*********************************************************/

#import "TuFilterPanelView.h"
#import "TuParametersAdjustView.h"
#import "TuPanelBar.h"
#import "TuViewSlider.h"
#import "TuCameraFilterPackage.h"


@implementation TuFilterPanelViewDataset
- (instancetype)initWith:(NSString *)name codes:(NSMutableArray<NSString *> *)codes
 {
     if (self = [super init])
     {
         _groupName = name;
         _groupData = [NSMutableArray array];
         
         for (NSString *code in codes)
         {
             TuFilterPanelViewCellData *cellData = [[TuFilterPanelViewCellData alloc] init];
             cellData.filterCode = code;
             [_groupData addObject:cellData];
         }
     }
     
     return self;
 }
@end


@interface TuFilterPanelView()<UICollectionViewDelegate,
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
    
    NSMutableArray<TuFilterPanelViewDataset *> *_datasets;
    NSInteger _curGroupIndex;
    NSInteger _preFilterIndex;

    SelesParameters *_filterParams;
}

@end


@implementation TuFilterPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    _curGroupIndex = 0;
    _preFilterIndex = 0;
        
    _datasets = [NSMutableArray array];
    
    NSArray *filterGroups = [[TuCameraFilterPackage sharePackage] filterGroups];
    for (TuFilterGroup *filterGroup in filterGroups)
    {
        NSString *name = NSLocalizedStringFromTable(filterGroup.name, @"TuSDKConstants", @"无需国际化");
        NSMutableArray<NSString *> *codes = [NSMutableArray array];

        NSArray *filters = [[TuFilterLocalPackage package] optionsWithGroup:filterGroup];
        for (TuFilterOption *option in filters)
        {
            [codes addObject:option.code];
        }
                
        [_datasets addObject:[[TuFilterPanelViewDataset alloc] initWith:name codes:codes]];
    }
    // 漫画滤镜
    {
        NSString *name = NSLocalizedStringFromTable(@"tu_漫画", @"VideoDemo", @"漫画");
        NSMutableArray<NSString *> *codes = [NSMutableArray array];
        [codes addObject:@"CHComics_Video"];
        [codes addObject:@"USComics_Video"];
        [codes addObject:@"JPComics_Video"];
        [codes addObject:@"Lightcolor_Video"];
        [codes addObject:@"Ink_Video"];
        [codes addObject:@"Monochrome_Video"];

        [_datasets addObject:[[TuFilterPanelViewDataset alloc] initWith:name codes:codes]];
    }

    
    _backGroudView = [[UIView alloc] initWithFrame:CGRectZero];
//    _backGroudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
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
    [_filterCollectionView registerClass:[TuFilterPanelViewCell class] forCellWithReuseIdentifier:@"TuFilterPanelViewCell"];
    
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
    
    NSMutableArray<NSString *> *titles = [NSMutableArray array];
    for (TuFilterPanelViewDataset *dataset in _datasets)
    {
        [titles addObject:dataset.groupName];
    }
    tabbar.itemTitles = titles;
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
    if (_datasets.count < 6) {
        
        CGFloat tabBarWidth = (CGRectGetWidth(safeBounds) - CGRectGetMinX(_tabbar.frame)) / _datasets.count;
        _tabbar.itemWidth = tabBarWidth;
        
    } else {
        _tabbar.itemsSpacing = 32;
    }
    
    _verticalSeparatorLayer.frame = CGRectMake(CGRectGetMaxX(_unsetBtn.frame), CGRectGetMinY(_unsetBtn.frame) + kFilterTabbarHeight / 2 - separatorHeight / 2, 1, separatorHeight);
    _horizontalSeparatorLayer.frame = CGRectMake(0, CGRectGetMaxY(_unsetBtn.frame), CGRectGetWidth(safeBounds), 1);
    
    _paramtersAdjustView.frame = CGRectMake(CGRectGetMinX(safeBounds) + 15,
    CGRectGetMaxY(safeBounds) - viewHeight - 24 - _paramtersAdjustView.contentHeight, CGRectGetWidth(safeBounds) - 15 * 2, _paramtersAdjustView.contentHeight);

}

- (void)unsetButtonAction:(UIButton *)sender
{
    _paramtersAdjustView.hidden = YES;
    
    TuFilterPanelViewCell *preCell = (TuFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0]];
    preCell.selected = NO;

    for (TuFilterPanelViewCellData *cellData in _datasets[_curGroupIndex].groupData)
    {
        cellData.state = TuFilterPanelViewCellUnselected;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tuFilterPanelView:didSelectedFilterCode:)])
    {
        [self.delegate tuFilterPanelView:self didSelectedFilterCode:@"Normal"];
    }
    _curGroupIndex = 0;
    _preFilterIndex = 0;
}

//滑动到上一组滤镜
- (void)swipeToLastFilter
{
    
    TuFilterPanelViewCell *preCell = (TuFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0]];
    preCell.selected = NO;
    
    TuFilterPanelViewCellData *preData = _datasets[_curGroupIndex].groupData[_preFilterIndex];
    NSInteger lastCellState = preData.state;
    preData.state = TuFilterPanelViewCellUnselected;
    
    if (_preFilterIndex != 0)
    {
        _preFilterIndex--;
    }
    else
    {
        if (_curGroupIndex != 0)
        {
            _curGroupIndex--;
        }
        else
        {
            _curGroupIndex = _datasets.count - 1;
        }
        NSInteger curGroupTotalCount = [_datasets[_curGroupIndex].groupData count];
        _preFilterIndex = curGroupTotalCount - 1;
        _tabbar.selectedIndex = _curGroupIndex;
        [_filterCollectionView reloadData];
    }
    
    if (lastCellState != TuFilterPanelViewCellParamAdjust)
    {
        _paramtersAdjustView.hidden = YES;
    }
    
    TuFilterPanelViewCell *cell = (TuFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0]];
    cell.selected = YES;
    
    TuFilterPanelViewCellData *cellData = _datasets[_curGroupIndex].groupData[_preFilterIndex];
    
    cellData.state = lastCellState == TuFilterPanelViewCellUnselected ? TuFilterPanelViewCellSelected : lastCellState;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tuFilterPanelView:didSelectedFilterCode:)])
    {
        _filterParams = [self.delegate tuFilterPanelView:self didSelectedFilterCode:cellData.filterCode];
        [self AdjustFilterParamters];
    }
    
    [_filterCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

//滑动到下一组滤镜
- (void)swipeToNextFilter
{
    NSInteger curGroupTotalCount = [_datasets[_curGroupIndex].groupData count];
    
    TuFilterPanelViewCell *preCell = (TuFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0]];
    preCell.selected = NO;
    
    TuFilterPanelViewCellData *preData = _datasets[_curGroupIndex].groupData[_preFilterIndex];
    NSInteger lastCellState = preData.state;
    preData.state = TuFilterPanelViewCellUnselected;
    
    if (_preFilterIndex != curGroupTotalCount - 1)
    {
        _preFilterIndex++;
    }
    else
    {
        if (_curGroupIndex != _datasets.count - 1)
        {
            _curGroupIndex++;
        }
        else
        {
            _curGroupIndex = 0;
        }
        
        _preFilterIndex = 0;
        _tabbar.selectedIndex = _curGroupIndex;
                
        [_filterCollectionView reloadData];
    }
    
    if (lastCellState != TuFilterPanelViewCellParamAdjust)
    {
        _paramtersAdjustView.hidden = YES;
    }
    
    TuFilterPanelViewCell *cell = (TuFilterPanelViewCell *)[_filterCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0]];
    cell.selected = YES;
    
    TuFilterPanelViewCellData *cellData = _datasets[_curGroupIndex].groupData[_preFilterIndex];
    
    cellData.state = lastCellState == TuFilterPanelViewCellUnselected ? TuFilterPanelViewCellSelected : lastCellState;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tuFilterPanelView:didSelectedFilterCode:)])
    {
        _filterParams = [self.delegate tuFilterPanelView:self didSelectedFilterCode:cellData.filterCode];
        [self AdjustFilterParamters];
        
    }
    [_filterCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_preFilterIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];

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
    _preFilterIndex = 0;

    for (TuFilterPanelViewCellData *cellData in _datasets[fromIndex].groupData)
    {
        cellData.state = TuFilterPanelViewCellUnselected;
    }
    
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
    return _datasets[_curGroupIndex].groupData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuFilterPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuFilterPanelViewCell" forIndexPath:indexPath];
    cell.data = _datasets[_curGroupIndex].groupData[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuFilterPanelViewCell *cell = (TuFilterPanelViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    TuFilterPanelViewCellData *cellData = _datasets[_curGroupIndex].groupData[indexPath.row];
    
    if (indexPath.item == _preFilterIndex)
    {
        if (cellData.state == TuFilterPanelViewCellSelected)
        {
            cellData.state = TuFilterPanelViewCellParamAdjust;
            _paramtersAdjustView.hidden = NO;
        }
        else if (cellData.state == TuFilterPanelViewCellParamAdjust)
        {
            cellData.state = TuFilterPanelViewCellSelected;
            _paramtersAdjustView.hidden = NO;
        }
        else
        {
            cellData.state = TuFilterPanelViewCellSelected;
            _paramtersAdjustView.hidden = YES;
        }
        
        if (indexPath.item == 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tuFilterPanelView:didSelectedFilterCode:)])
            {
                _filterParams = [self.delegate tuFilterPanelView:self didSelectedFilterCode:cell.data.filterCode];
                [self AdjustFilterParamters];
            }
        }
    }
    else
    {
        _paramtersAdjustView.hidden = YES;

        TuFilterPanelViewCellData *preCellData = _datasets[_curGroupIndex].groupData[_preFilterIndex];

        [preCellData setState:TuFilterPanelViewCellUnselected];
        [cellData setState:TuFilterPanelViewCellSelected];

        if (self.delegate && [self.delegate respondsToSelector:@selector(tuFilterPanelView:didSelectedFilterCode:)])
        {
            _filterParams = [self.delegate tuFilterPanelView:self didSelectedFilterCode:cell.data.filterCode];
            [self AdjustFilterParamters];
        }
    }
    
    _preFilterIndex = indexPath.item;
}

- (void)AdjustFilterParamters
{
    NSMutableArray* params = [[NSMutableArray alloc] init];
 
    if (_filterParams || _filterParams.args)
    {
        for (NSInteger parIndex = 0; parIndex < _filterParams.args.count; parIndex++)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];

            NSString *paramName = _filterParams.args[parIndex].key;
            CGFloat paramVal = _filterParams.args[parIndex].precent;
            CGFloat defaultVal = _filterParams.args[parIndex].defaultValue;
            
            paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", paramName];
            paramName = NSLocalizedStringFromTable(paramName, @"TuSDKConstants", @"无需国际化");

            [dic setObject:paramName forKey:@"name"];
            [dic setObject:[NSNumber numberWithFloat:paramVal] forKey:@"val"];
            [dic setObject:[NSNumber numberWithFloat:defaultVal] forKey:@"defaultVal"];

            [params addObject:dic];
        }
    }
    [_paramtersAdjustView setParams:params];
}

- (void)ParameterAdjustView:(TuParametersAdjustView *)paramAdjustView index:(NSInteger)index val:(float)val
{
    _filterParams.args[index].precent = val;
}



@end
