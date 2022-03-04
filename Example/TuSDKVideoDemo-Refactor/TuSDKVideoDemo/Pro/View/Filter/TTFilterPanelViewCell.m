//
//  TTFilterPanelViewCell.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTFilterPanelViewCell.h"

@interface TTFilterPanelViewCell()
{
    UILabel *_titleLabel;
    UIImageView *_thumbnailView;
    UIImageView *_selectedView;
}

@end

@implementation TTFilterPanelViewCell

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
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    
    _thumbnailView = [[UIImageView alloc] init];
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnailView.userInteractionEnabled = NO;
    [self addSubview:_thumbnailView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.userInteractionEnabled = NO;
    [self addSubview:_titleLabel];

    _selectedView = [[UIImageView alloc] init];
    _selectedView.contentMode = UIViewContentModeCenter;
    _selectedView.image = [UIImage imageNamed:@"ic_parameter"];
    _selectedView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _selectedView.userInteractionEnabled = NO;
    _selectedView.hidden = YES;
    [self addSubview:_selectedView];
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    _thumbnailView.frame = self.bounds;
    const CGFloat labelHeight = 16;
    _titleLabel.frame = CGRectMake(0, size.height - labelHeight, size.width, labelHeight);
    _selectedView.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected
{
    _titleLabel.hidden = selected;
    _selectedView.hidden = !selected;
    
    if (_item.isComics) {
        //漫画滤镜不显示选中视图
        _selectedView.image = nil;
    } else {
        _selectedView.image = [UIImage imageNamed:@"ic_parameter"];
    }
}

- (void)setItem:(TTFilterItem *)item
{
    _item = item;
    
    _titleLabel.text = item.name;
    _thumbnailView.image = item.icon;
    
    if (item.selectState != TTFilterSelectStateUnselected) {
        
        _titleLabel.hidden = YES;
        _selectedView.hidden = NO;
        
        //判断是否是漫画滤镜
        if (item.isComics) {
             //漫画滤镜不显示选中视图
            _selectedView.image = nil;
            
        } else {
            _selectedView.image = [UIImage imageNamed:@"ic_parameter"];
        }
    }
    
}

@end
