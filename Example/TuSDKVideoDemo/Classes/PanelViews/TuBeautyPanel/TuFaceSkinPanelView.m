/********************************************************
 * @file    : TuFaceSkinPanelView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美肤面板
*********************************************************/

#import "TuFaceSkinPanelView.h"
#import "TuFaceSkinPanelViewCell.h"
#import "Constants.h"

#define itemHeight 90

@interface TuFaceSkinPanelView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    NSMutableArray<TuFaceSkinPanelViewData *> *_datasets;
    NSInteger _preSeletedIndex;
    NSString *_selectCode;
}
@end


@implementation TuFaceSkinPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _preSeletedIndex = -1;
        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    _datasets = [NSMutableArray array];
    {
        TuFaceSkinPanelViewData *resetData = [[TuFaceSkinPanelViewData alloc] init];
        resetData.code = @"reset";
        resetData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
        [_datasets addObject:resetData];

        NSArray *skinFeatures = @[TuBeautySkinKeys];
        
        TuFaceSkinPanelViewData *faceData = [[TuFaceSkinPanelViewData alloc] init];
        faceData.code = skinFeatures[0];
        faceData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
        [_datasets addObject:faceData];

        TuFaceSkinPanelViewData *pointData = [[TuFaceSkinPanelViewData alloc] init];
        pointData.code = @"point";
        pointData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
        [_datasets addObject:pointData];
        
        for (int i = 1; i < skinFeatures.count; i++)
        {
            TuFaceSkinPanelViewData *faceData = [[TuFaceSkinPanelViewData alloc] init];
            faceData.code = skinFeatures[i];
            faceData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
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
    [_collectionView registerClass:[TuFaceSkinPanelViewCell class] forCellWithReuseIdentifier:@"TuFaceSkinPanelViewCell"];
    
    //默认为自然
    _faceSkinType = TuSkinFaceTypeBeauty;
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
    if (indexPath.item == 2)
    {
        return CGSizeMake(20, itemHeight);
    }
    else
    {
        return CGSizeMake((lsqScreenWidth - 40) / 5, itemHeight);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuFaceSkinPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuFaceSkinPanelViewCell" forIndexPath:indexPath];
    cell.data = _datasets[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 2)
    {
        // 分隔符
    }
    else
    {
        TuFaceSkinPanelViewData *cellData = _datasets[indexPath.item];

        if (indexPath.item != _preSeletedIndex && _preSeletedIndex >= 0)
        {
            TuFaceSkinPanelViewData *preData = _datasets[_preSeletedIndex];
            
            preData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
        }
        
        cellData.beautySkinSelectType = TuBeautySkinSelectTypeSelected;
        [_collectionView reloadData];
        
        _preSeletedIndex = indexPath.item;
        
        if (indexPath.item == 0)
        {
            if (_delegate && [_delegate respondsToSelector:@selector(TuFaceSkinPanelView:enableSkin:mode:)])
            {
                _selectCode = nil;
                [_delegate TuFaceSkinPanelView:self enableSkin:NO mode:TuSkinFaceTypeNatural];
            }

            for (TuFaceSkinPanelViewData *viewData in _datasets)
            {
                viewData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
            }
        }
        else if (indexPath.item == 1)
        {
            if (_selectCode == nil)
            {
                [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
                return;
            }
            NSString *code = nil;
            NSString *addiCode = nil;
            
            if (_faceSkinType == TuSkinFaceTypeBeauty)
            {
                _faceSkinType = TuSkinFaceTypeMoist;
                code = @"skin_extreme";
                addiCode = @"ruddy";
            }
            else if (_faceSkinType == TuSkinFaceTypeMoist)
            {
                _faceSkinType = TuSkinFaceTypeNatural;
                //自然
                code = @"skin_precision";
                addiCode = @"ruddy";
            }
            else
            {
                _faceSkinType = TuSkinFaceTypeBeauty;
                code = @"skin_beauty";
                addiCode = @"sharpen";
            }
            
            TuFaceSkinPanelViewData *skinTypeData = _datasets[1];
            skinTypeData.code = code;
            [_datasets replaceObjectAtIndex:1 withObject:skinTypeData];
            
            TuFaceSkinPanelViewData *data = _datasets[5];
            data.code = addiCode;
            [_datasets replaceObjectAtIndex:5 withObject:data];
            
            [_collectionView reloadData];
            
            if (_delegate && [_delegate respondsToSelector:@selector(TuFaceSkinPanelView:enableSkin:mode:)])
            {
                [_delegate TuFaceSkinPanelView:self enableSkin:YES mode:_faceSkinType];
            }
            [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(TuFaceSkinPanelView:didSelectCode:)])
            {
                _selectCode = _datasets[indexPath.item].code;
                [self.delegate TuFaceSkinPanelView:self didSelectCode:_datasets[indexPath.item].code];
            }
        }
    }
}

- (void)enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode
{
    if (enable)
    {
        NSString *code = nil;
        NSString *addiCode = nil;
        
        switch (mode)
        {
            case TuSkinFaceTypeNatural:
            {
                _faceSkinType = TuSkinFaceTypeNatural;
                code = @"skin_precision";
                addiCode = @"ruddy";
            }
                break;
                
            case TuSkinFaceTypeMoist:
            {
                _faceSkinType = TuSkinFaceTypeMoist;
                code = @"skin_extreme";
                addiCode = @"ruddy";
            }
                break;
                
            case TuSkinFaceTypeBeauty:
            default:
            {
                _faceSkinType = TuSkinFaceTypeBeauty;
                code = @"skin_beauty";
                addiCode = @"sharpen";
            }
                break;
        }
        
        TuFaceSkinPanelViewData *skinTypeData = _datasets[1];
        skinTypeData.code = code;
        [_datasets replaceObjectAtIndex:1 withObject:skinTypeData];
        
        TuFaceSkinPanelViewData *data = _datasets[5];
        data.code = addiCode;
        [_datasets replaceObjectAtIndex:5 withObject:data];
        
        [_collectionView reloadData];
        
        if (_delegate && [_delegate respondsToSelector:@selector(TuFaceSkinPanelView:enableSkin:mode:)])
        {
            [_delegate TuFaceSkinPanelView:self enableSkin:YES mode:_faceSkinType];
        }
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(TuFaceSkinPanelView:enableSkin:mode:)])
        {
            _selectCode = nil;
            [_delegate TuFaceSkinPanelView:self enableSkin:NO mode:TuSkinFaceTypeNatural];
        }

        for (TuFaceSkinPanelViewData *viewData in _datasets)
        {
            viewData.beautySkinSelectType = TuBeautySkinSelectTypeUnselected;
        }
    }
}


@end
