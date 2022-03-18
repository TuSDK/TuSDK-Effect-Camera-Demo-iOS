//
//  TTFaceSkinPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFaceSkinPanelView.h"
#import "TTFaceSkinPanelViewCell.h"
#import "TTRenderDef.h"
#import "TTFaceSkinModel.h"
#define itemHeight 90

@interface TTFaceSkinPanelView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    //选中的index
    NSInteger _seletedIndex;
    
    TTFaceSkinModel *_skinModel;
}

@property (nonatomic, strong) id<TTBeautyProtocol> beautyTarget;

@end

@implementation TTFaceSkinPanelView

#pragma mark - instance
+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    TTFaceSkinPanelView *view = [[TTFaceSkinPanelView alloc] initWithFrame:frame beautyTarget:beautyTarget];
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


- (void)initWithSubViews
{
    //获取美肤数据
    _skinModel = [[TTFaceSkinModel alloc] init];
    
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
    [_collectionView registerClass:[TTFaceSkinPanelViewCell class] forCellWithReuseIdentifier:@"TTFaceSkinPanelViewCell"];
    
}

- (void)layoutSubviews
{
    _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _skinModel.skinItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 2)
    {
        return CGSizeMake(20, itemHeight);
    }
    else
    {
        //判断美肤切换按钮里美肤类型
        TTFaceSkinItem *item = _skinModel.skinItems[1];
        if (item.skinType == TTSkinStyleNatural) {
            //自然美肤隐藏红润
            if (indexPath.item == 6) {
                return CGSizeMake(0, itemHeight);
            }
        } else {
            //其他隐藏锐化
            if (indexPath.item == 5) {
                return CGSizeMake(0, itemHeight);
            }
        }
        return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 40) / 5, itemHeight);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTFaceSkinPanelViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTFaceSkinPanelViewCell" forIndexPath:indexPath];
    TTFaceSkinItem *item = _skinModel.skinItems[indexPath.item];
    cell.skinItem = item;
    cell.hidden = item.isHidden;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //item为2时为分隔符
    if (indexPath.item == 2) return;
    
    
    TTFaceSkinItem *item = _skinModel.skinItems[indexPath.item];
    
    switch (indexPath.item) {
        case 0:
        {   //当前选中和上一次选中均为0时，则不做任何操作
            if (_seletedIndex == 0 && indexPath.item == 0) return;
            item.isSelected = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(faceSkinPanelView:didSelectItem:)]) {
                [self.delegate faceSkinPanelView:self didSelectItem:item];
            }
            
            for (TTFaceSkinItem *item in _skinModel.skinItems) {
                item.isSelected = NO;
            }
        }
            break;
        case 1:
        {
            //如果当前未选中任意美肤效果，则点击切换美肤按钮默认选中磨皮效果;如果当前已存在美肤效果，则点击切换美肤类型算法
            if (_seletedIndex == 0) {
                [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
                //添加默认自然美肤效果
                if (self.delegate && [self.delegate respondsToSelector:@selector(faceSkinPanelView:setSkinType:)]) {
                    [self.delegate faceSkinPanelView:self setSkinType:TTSkinStyleNatural];
                }
                return;
            }
            
            //切换美肤类型
            [_skinModel changeSkinType:item];
            if (self.delegate && [self.delegate respondsToSelector:@selector(faceSkinPanelView:setSkinType:)]) {
                [self.delegate faceSkinPanelView:self setSkinType:item.skinType];
            }
            [self collectionView:_collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];

        }
            break;
        default:
        {
            //如果上次未重置效果，则默认添加自然美肤特效
            if (_seletedIndex == 0) {
                //添加默认自然美肤效果
                if (self.delegate && [self.delegate respondsToSelector:@selector(faceSkinPanelView:setSkinType:)]) {
                    [self.delegate faceSkinPanelView:self setSkinType:TTSkinStyleNatural];
                }
            }
            //先将上次选中置为未选中
            TTFaceSkinItem *lastItem = _skinModel.skinItems[_seletedIndex];
            lastItem.isSelected = NO;
            
            item.isSelected = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(faceSkinPanelView:didSelectItem:)]) {
                [self.delegate faceSkinPanelView:self didSelectItem:item];
            }
        }
            break;
    }
    
    [_collectionView reloadData];

    _seletedIndex = indexPath.item == 1 ? 3 : indexPath.item;
    
}

/**
 * 根据美肤code修改相对应的参数值
 * @param code 美肤code
 * @param value 参数值
 */
- (void)updateSkinWithCode:(NSString *)code value:(float)value;
{
    for (TTFaceSkinItem *item in _skinModel.skinItems) {
        if ([item.code isEqualToString:code]) {
            item.value = value;
        }
    }
}

@end
