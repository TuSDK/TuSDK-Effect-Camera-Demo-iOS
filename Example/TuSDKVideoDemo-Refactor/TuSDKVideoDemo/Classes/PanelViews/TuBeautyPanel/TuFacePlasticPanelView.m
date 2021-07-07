/********************************************************
 * @file    : TuFacePlasticPanelView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   :微整形显示项
*********************************************************/

#import "TuFacePlasticPanelView.h"
#import "TuFacePlasticPanelViewCell.h"
#import "Constants.h"

#define itemHeight 90
@interface TuFacePlasticPanelView()<UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    NSMutableArray<TuFacePlasticPanelViewCellData *> *_datasets;
    NSInteger _preSeletedIndex;

}
@end


@implementation TuFacePlasticPanelView

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
    //加载数据
    _datasets = [NSMutableArray array];
    {
        TuFacePlasticPanelViewCellData *resetData = [[TuFacePlasticPanelViewCellData alloc] init];
        resetData.code = @"reset";
        resetData.state = TuFacePlasticPanelViewCellUnselected;
        [_datasets addObject:resetData];
        
        TuFacePlasticPanelViewCellData *pointData = [[TuFacePlasticPanelViewCellData alloc] init];
        pointData.code = @"point";
        pointData.state = TuFacePlasticPanelViewCellUnselected;
        [_datasets addObject:pointData];
        
        NSArray *faceFeatures = @[kPlasticKeyCodes, kPlasticKeyExtraCodes];
        for (NSString *code in faceFeatures)
        {
            TuFacePlasticPanelViewCellData *faceData = [[TuFacePlasticPanelViewCellData alloc] init];
            faceData.code = code;
            [_datasets addObject:faceData];
        }
    }
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];
    [_collectionView registerClass:[TuFacePlasticPanelViewCell class] forCellWithReuseIdentifier:@"TuFacePlasticPanelViewCell"];
}

- (void)layoutSubviews
{
    _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datasets.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 1)
    {
        return CGSizeMake(20, itemHeight);
    }
    else
    {
        return CGSizeMake(60, itemHeight);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuFacePlasticPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuFacePlasticPanelViewCell" forIndexPath:indexPath];
    cell.data = _datasets[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 1)
    {
        // 分隔符
    }
    else
    {
        TuFacePlasticPanelViewCellData *cellData = _datasets[indexPath.row];

        if (indexPath.item != _preSeletedIndex)
        {
            TuFacePlasticPanelViewCellData *preCellData = _datasets[_preSeletedIndex];
            
            preCellData.state = TuFacePlasticPanelViewCellUnselected;
        }
        
        if (indexPath.item != 0)
        {
            cellData.state = TuFacePlasticPanelViewCellSelected;
        }
        else
        {
            if (_preSeletedIndex == 0)
            {
                //未选中时点击重置无效
                return;
            }
        }

        if (self.delegate && [self.delegate respondsToSelector:@selector(tuFacePlasticPanelView:didSelectCode:)])
        {
            [self.delegate tuFacePlasticPanelView:self didSelectCode:cellData.code];
        }

        [_collectionView reloadData];

        _preSeletedIndex = indexPath.item;
    }
}

- (void)deselect
{
    if (_preSeletedIndex != 0)
    {
        TuFacePlasticPanelViewCellData *preCellData = _datasets[_preSeletedIndex];
        
        preCellData.state = TuFacePlasticPanelViewCellUnselected;
        [_collectionView reloadData];
        
        _preSeletedIndex = 0;
    }
}

@end
