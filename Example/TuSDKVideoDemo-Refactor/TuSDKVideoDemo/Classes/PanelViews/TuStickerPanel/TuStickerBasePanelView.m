/********************************************************
 * @file    : TuStickerBasePanelView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸组显示
*********************************************************/
#import "TuStickerBasePanelView.h"

#define kRadianToDegrees(radian) (radian*180.0)/(M_PI)
/** TuStickerBasePanelViewItem************************************************/
@interface TuStickerBasePanelViewItem()

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, copy) void (^deleteButtonActionHandler)(TuStickerBasePanelViewItem *cell); // 删除按钮事件回调

@property (nonatomic, strong) UIActivityIndicatorView *loadingView; // 加载视图
@end


@implementation TuStickerBasePanelViewItem
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    
    UIColor *borderColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    
    UIView *backGroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
//    backGroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.24];
    backGroundView.layer.cornerRadius = 4;
    [self.contentView addSubview:backGroundView];
    
    //遮罩视图
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = backGroundView.bounds;
    effectView.alpha = 0.3;
    effectView.layer.masksToBounds = YES;
    effectView.layer.cornerRadius = 4;
    [backGroundView addSubview:effectView];
    self.effectView = effectView;
    self.effectView.hidden = YES;
    
    _thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 6, CGRectGetWidth(self.contentView.bounds) - 10, CGRectGetHeight(self.contentView.bounds) - 12)];
    _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_thumbnailView];

    _loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_loadingView];
    _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _loadingView.hidesWhenStopped = YES;
    
    _loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sticker_load_ic"]];
    _loadingImageView.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 16, CGRectGetHeight(self.contentView.bounds) - 16, 16, 16);
    [self.contentView addSubview:_loadingImageView];
    
    CGSize size = self.bounds.size;
//    _downloadIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sticker_download_ic"]];
    _downloadIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sticker_ic_download"]];
    CGSize downloadIconSize = _downloadIconView.intrinsicContentSize;
    _downloadIconView.frame = CGRectMake(size.width - downloadIconSize.width, size.height - downloadIconSize.height, downloadIconSize.width, downloadIconSize.height);
    _downloadIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:_downloadIconView];

    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"sticker_ic_update"] forState:UIControlStateNormal];
//    _deleteButton.imageView.contentMode = UIViewContentModeCenter;
//    _deleteButton.hidden = YES;
////    _deleteButton.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 32, 0, 32, 32);
//    _deleteButton.frame = CGRectMake(0, -CGRectGetWidth(self.contentView.bounds) + 8, CGRectGetWidth(self.contentView.bounds) * 2 - 16, CGRectGetWidth(self.contentView.bounds) * 2);
    _deleteButton.frame = _thumbnailView.bounds;
    _deleteButton.imageView.contentMode = UIViewContentModeCenter;
    _deleteButton.hidden = YES;
    _deleteButton.layer.borderColor = borderColor.CGColor;
    _deleteButton.layer.borderWidth = 2;
    _deleteButton.layer.cornerRadius = 4;
    _deleteButton.layer.masksToBounds = YES;
    _deleteButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.65];
    _deleteButton.frame = self.contentView.bounds;
    _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];

    _selectedView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    _selectedView.layer.borderColor = borderColor.CGColor;
    _selectedView.layer.borderWidth = 2;
    _selectedView.layer.cornerRadius = 4;
    _selectedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _selectedView.userInteractionEnabled = NO;
    _selectedView.hidden = YES;
    [self.contentView addSubview:_selectedView];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
//    if (!self.online)
//    {
//        _selectedView.hidden = !selected;
//    }
    _selectedView.hidden = !selected;
}

- (void)setOnline:(BOOL)online
{
    _online = online;
    _downloadIconView.hidden = !online;

    _loadingImageView.hidden = YES;
//    self.effectView.hidden = YES;
}

- (void)deleteButtonAction:(UIButton *)sender
{
    if (self.deleteButtonActionHandler) self.deleteButtonActionHandler(self);
}

- (void)startLoading
{
    self.downloadIconView.hidden = YES;
    
    [self.loadingView startAnimating];
//    [self startLoadingAnimation];
//    self.effectView.hidden = YES;
}

- (void)finishLoading
{
    [self.loadingView stopAnimating];
//    [self finishLoadingAnimation];
//    self.effectView.hidden = YES;
}

//动画对象
- (CABasicAnimation *)addLoadingImageAnimation
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    return rotationAnimation;
}

- (void)startLoadingAnimation
{
    [_loadingImageView.layer addAnimation:[self addLoadingImageAnimation] forKey:@"rotationAnimation"];
    _loadingImageView.hidden = NO;
}

- (void)finishLoadingAnimation
{
    [_loadingImageView.layer removeAnimationForKey:@"rotationAnimation"];
    _loadingImageView.hidden = YES;
}


/**
 隐藏/显示删除按钮

 @param hidden 是否隐藏
 @param animated 是否动画更新
 */
- (void)setDeleteButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!animated)
    {
        _deleteButton.hidden = hidden;
    }
    else
    {
        CGFloat startAlpha = 0.0f;
        CGFloat endAlpha = 1.0f;
        
        if (hidden)
        {
            startAlpha = 1.0f;
            endAlpha = 0.0f;
        }
        
        _deleteButton.hidden = NO;
        _deleteButton.alpha = startAlpha;
        [UIView animateWithDuration:.25 animations:^{
            self.deleteButton.alpha = endAlpha;
        } completion:^(BOOL finished) {
            self.deleteButton.hidden = hidden;
            self.deleteButton.alpha = 1;
        }];
    }
}

- (void)setSelectViewHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!animated)
    {
        _selectedView.hidden = hidden;
        return;
    }
    
    double startAlpha = hidden;
    double endAlpha = !hidden;
    _selectedView.alpha = startAlpha;
    _selectedView.hidden = NO;
    [UIView animateWithDuration:.25 animations:^{
        self.selectedView.alpha = endAlpha;
    } completion:^(BOOL finished) {
        self.selectedView.hidden = hidden;
        self.selectedView.alpha = 1;
    }];
}

@end


/** TuStickerBasePanelViewItem************************************************/
@interface TuStickerBasePanelView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSIndexPath *shouldShowDeleteButtonIndexPath; // 显示删除按钮的索引对象
@property (nonatomic, strong) NSIndexPath *selectedIndexPath; // 选中项索引对象
@end


@implementation TuStickerBasePanelView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    const int countPerRow = 5;
    const CGFloat itemHorizontalSpacing = 20;
    const CGFloat itemVerticalSpacing = 15;
    CGFloat itemWidth = (screenWidth - itemHorizontalSpacing) / countPerRow - itemHorizontalSpacing;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(itemVerticalSpacing, itemHorizontalSpacing, itemVerticalSpacing, itemHorizontalSpacing);
    flowLayout.minimumLineSpacing = itemVerticalSpacing;
    
    _itemCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _itemCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _itemCollectionView.backgroundColor = [UIColor clearColor];
    _itemCollectionView.dataSource = self;
    _itemCollectionView.allowsSelection = NO;
    [_itemCollectionView registerClass:[TuStickerBasePanelViewItem class] forCellWithReuseIdentifier:@"TuCategoryViewItemID"];
    [self addSubview:_itemCollectionView];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
}

#pragma mark - property

- (void)setShouldShowDeleteButtonIndexPath:(NSIndexPath *)shouldShowDeleteButtonIndexPath
{
    if ([shouldShowDeleteButtonIndexPath isEqual:_shouldShowDeleteButtonIndexPath])
    {
        return;
    }
    
    TuStickerBasePanelViewItem *cellShouldHideButton = (TuStickerBasePanelViewItem *)[_itemCollectionView cellForItemAtIndexPath:_shouldShowDeleteButtonIndexPath];
    [cellShouldHideButton setDeleteButtonHidden:YES animated:YES];
    TuStickerBasePanelViewItem *cellShouldShowButton = (TuStickerBasePanelViewItem *)[_itemCollectionView cellForItemAtIndexPath:shouldShowDeleteButtonIndexPath];
    [cellShouldShowButton setDeleteButtonHidden:NO animated:YES];
    
    _shouldShowDeleteButtonIndexPath = shouldShowDeleteButtonIndexPath;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    if ([selectedIndexPath isEqual:_selectedIndexPath])
    {
        return;
    }
    for (UICollectionViewCell *cellShouldDeselect in _itemCollectionView.visibleCells)
    {
        if (cellShouldDeselect.selected)
        {
            cellShouldDeselect.selected = NO;
        }
    }
    
    UICollectionViewCell *cellShouldSelect = [_itemCollectionView cellForItemAtIndexPath:selectedIndexPath];
    cellShouldSelect.selected = YES;
    
    _selectedIndexPath = selectedIndexPath;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex < 0
        || selectedIndex >= [self.dataSource categoryViewNumberOfItems:self])
    {
        return;
    }
    
    self.selectedIndexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
}
- (NSInteger)selectedIndex
{
    return _selectedIndexPath.item;
}

#pragma mark - public

- (void)dismissDeleteButtons
{
    if ([_shouldShowDeleteButtonIndexPath isEqual:_selectedIndexPath])
    {
        [self deselect];
        if ([self.delegate respondsToSelector:@selector(categoryView:didSelectCell:atIndex:)])
        {
            [self.delegate categoryView:self didSelectCell:nil atIndex:-1];
        }
    }
    self.shouldShowDeleteButtonIndexPath = nil;
}

- (void)deselect
{
    self.selectedIndexPath = nil;
}

#pragma mark - action

/**
 点击手势事件

 @param sender 点击手势
 */
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:_itemCollectionView];
    if (!CGRectContainsPoint(_itemCollectionView.bounds, touchPoint))
    {
        return;
    }
    NSIndexPath *touchIndexPath = [_itemCollectionView indexPathForItemAtPoint:touchPoint];
    if (!touchIndexPath)
    {
        return;
    }
    [self dismissDeleteButtons];
    self.selectedIndexPath = touchIndexPath;
    TuStickerBasePanelViewItem *cell = (TuStickerBasePanelViewItem *)[_itemCollectionView cellForItemAtIndexPath:touchIndexPath];
    if ([self.delegate respondsToSelector:@selector(categoryView:didSelectCell:atIndex:)])
    {
        [self.delegate categoryView:self didSelectCell:cell atIndex:touchIndexPath.item];
    }
}

/**
 长按手势事件

 @param sender 长按手势
 */
- (void)longPressAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    CGPoint touchPoint = [sender locationInView:_itemCollectionView];
    if (!CGRectContainsPoint(_itemCollectionView.bounds, touchPoint))
    {
        return;
    }
    NSIndexPath *touchIndexPath = [_itemCollectionView indexPathForItemAtPoint:touchPoint];
    if (!touchIndexPath)
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(categoryView:canDeleteButtonAtIndex:)])
    {
        if (![self.delegate categoryView:self canDeleteButtonAtIndex:touchIndexPath])
        {
            NSLog(@"canDeleteButtonAtIndex return false.");
            return;
        }
    }
    
    self.shouldShowDeleteButtonIndexPath = touchIndexPath;
    
    if ([_selectedIndexPath isEqual:_shouldShowDeleteButtonIndexPath])
    {
        TuStickerBasePanelViewItem *cellShouldHideView = (TuStickerBasePanelViewItem *)[_itemCollectionView cellForItemAtIndexPath:_shouldShowDeleteButtonIndexPath];
        [cellShouldHideView setSelectViewHidden:YES animated:NO];
    }
}

/**
 单元格点击删除按钮

 @param cell 单元格
 @param indexPath 单元格索引对象
 */
- (void)cell:(TuStickerBasePanelViewItem *)cell didTapDeleteButtonWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(categoryView:didTapDeleteButtonAtIndex:)])
    {
        [self.delegate categoryView:self didTapDeleteButtonAtIndex:indexPath.item];
    }
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TuStickerBasePanelViewItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TuCategoryViewItemID" forIndexPath:indexPath];
    
    //cell.thumbnailView.image = [UIImage imageNamed:@"default"];
    [self.dataSource categoryView:self cellForItemAtIndex:cell atIndex:indexPath.item];

    // 选中当前项
    cell.selected = [_selectedIndexPath isEqual:indexPath];
    
    cell.deleteButton.hidden = cell.selected || ![indexPath isEqual:_shouldShowDeleteButtonIndexPath] || cell.online;
    __weak typeof(self) weakSelf = self;
    cell.deleteButtonActionHandler = ^(TuStickerBasePanelViewItem *cell) {
        [weakSelf cell:cell didTapDeleteButtonWithIndexPath:indexPath];
    };
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource categoryViewNumberOfItems:self];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    for (UIView *view in _itemCollectionView.visibleCells)
    {
        if ([touch.view isDescendantOfView:view])
        {
            return YES;
        }
    }
    return NO;
}

@end
