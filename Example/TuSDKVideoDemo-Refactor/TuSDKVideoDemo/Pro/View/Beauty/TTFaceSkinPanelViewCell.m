//
//  TTFaceSkinPanelViewCell.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/14.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFaceSkinPanelViewCell.h"

@interface TTFaceSkinPanelViewCell()
{
    UILabel *_titleLabel;
    UIImageView *_thumbnailView;
    UIImageView *_selectImageView;
    UIView *_pointView;
    UIColor *_normalColor;
    UIColor *_selectColor;
}

@end

@implementation TTFaceSkinPanelViewCell

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
    _normalColor = [UIColor colorWithWhite:1 alpha:0.35];
    _selectColor = [UIColor colorWithRed:255.f/255 green:222.f/255 blue:0 alpha:1];
    
    _thumbnailView = [[UIImageView alloc] init];
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    _thumbnailView.backgroundColor = [UIColor clearColor];
    _thumbnailView.layer.masksToBounds = YES;
    [self addSubview:_thumbnailView];
    
    _selectImageView = [[UIImageView alloc] init];
    _selectImageView.layer.masksToBounds = YES;
    [self addSubview:_selectImageView];
    _selectImageView.hidden = YES;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.35];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _pointView = [[UIView alloc] init];
    _pointView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    _pointView.layer.cornerRadius = 3;
    _pointView.hidden = YES;
    [self addSubview:_pointView];
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    const CGFloat labelHeight = 22;
    const CGFloat imageWidth = 40;
    
    CGFloat margin = 0;
    CGFloat labelWidth = size.width;
    CGFloat titleMinX = 0;

    _thumbnailView.frame = CGRectMake(size.width / 2 - imageWidth / 2 + margin, 12, imageWidth, imageWidth);
    _titleLabel.frame = CGRectMake(titleMinX, CGRectGetHeight(_thumbnailView.frame) + CGRectGetMinY(_thumbnailView.frame), labelWidth, labelHeight);
    
    _selectImageView.frame = _thumbnailView.frame;
    
    _pointView.frame = CGRectMake(0, 0, 6, 6);
    _pointView.center = _thumbnailView.center;
}

- (void)setSkinItem:(TTFaceSkinItem *)skinItem
{
    _pointView.hidden = _selectImageView.hidden = YES;
    _thumbnailView.hidden = NO;
    
    //间隔符
    if ([skinItem.code isEqualToString:@"point"]) {
        
        _titleLabel.text = @"";
        _thumbnailView.hidden = _selectImageView.hidden = YES;
        _pointView.hidden = NO;
        
    } else {
        
        _titleLabel.text = skinItem.name;
        _thumbnailView.image = skinItem.icon;
        _selectImageView.image = skinItem.selectIcon;
        
    }
    
    if (!skinItem.isSelected) {
        
        //未选中时将选中视图隐藏
        _selectImageView.hidden = YES;
        _titleLabel.textColor = _normalColor;
        
    } else {
        
        //选中时显示选中视图
        if (![skinItem.code isEqualToString:@"reset"]) {
            
            _selectImageView.hidden = NO;
            _titleLabel.textColor = _selectColor;
            
        }
    }
    self.contentView.hidden = skinItem.isHidden;
}

@end
