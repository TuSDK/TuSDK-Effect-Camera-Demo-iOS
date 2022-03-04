//
//  TTFacePlasticPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFacePlasticPanelView.h"
#import "TTFacePlasticPanelViewCell.h"
#import "TTFacePlasticModel.h"
#import "TTRenderDef.h"
#define itemHeight 90
@interface TTFacePlasticPanelView()<UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    //选中的index
    NSInteger _seletedIndex;
}
@property (nonatomic, strong) id<TTBeautyProtocol> beautyTarget;
@property (nonatomic, strong) TTFacePlasticModel *plasticModel;

@end

@implementation TTFacePlasticPanelView

#pragma mark - instance
+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    TTFacePlasticPanelView *view = [[TTFacePlasticPanelView alloc] initWithFrame:frame beautyTarget:beautyTarget];
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
    _plasticModel = [[TTFacePlasticModel alloc] init];
    
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
    [_collectionView registerClass:[TTFacePlasticPanelViewCell class] forCellWithReuseIdentifier:@"TTFacePlasticPanelViewCell"];
}

- (void)layoutSubviews
{
    _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _plasticModel.plasticGroup.count;
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
    TTFacePlasticPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTFacePlasticPanelViewCell" forIndexPath:indexPath];
    cell.beautyItem = _plasticModel.plasticGroup[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //item index为1 时为分隔符
    if (indexPath.item == 1) return;
    
    TTFacePlasticItem *item = _plasticModel.plasticGroup[indexPath.item];
    
    //当前选中与上次选中不一致时，将上次选中置为未选中状态
    if (indexPath.item != _seletedIndex) {
        TTFacePlasticItem *lastBeautyItem = _plasticModel.plasticGroup[_seletedIndex];
        lastBeautyItem.isSelected = NO;
    }
    //将当前选中置为YES
    if (indexPath.item != 0) {
        
        item.isSelected = YES;
        
    } else {
        //未选中时点击重置无效
        if (_seletedIndex == 0) return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(facePlasticPanelView:didSelectItem:)]) {
        
        [self.delegate facePlasticPanelView:self didSelectItem:item];
    }
    
    [_collectionView reloadData];

    _seletedIndex = indexPath.item;
}

/**
 * 根据微整形code修改相对应的参数值
 * @param code 微整形code
 * @param value 参数值
 */
- (void)updatePlasticWithCode:(NSString *)code value:(float)value;
{
    for (TTFacePlasticItem *item in _plasticModel.plasticGroup) {
        if ([item.code isEqualToString:code]) {
            item.value = value;
        }
    }
}
/// 重置微整形数据
- (void)resetPlasticData
{
    //重置数据
    _plasticModel = nil;
    _plasticModel = [[TTFacePlasticModel alloc] init];
}

//取消选中
- (void)deselect
{
    if (_seletedIndex != 0)
    {
        for (TTFacePlasticItem *item in _plasticModel.plasticGroup) {
            item.isSelected = NO;
        }
        [_collectionView reloadData];
        _seletedIndex = 0;
    }
}

@end
