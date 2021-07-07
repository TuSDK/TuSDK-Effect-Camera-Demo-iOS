/********************************************************
 * @file    : TuFilterPanelViewCell.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 滤镜显示项
*********************************************************/

#import "TuFilterPanelViewCell.h"

#define ComicsCodes @"CHComics_Video", @"USComics_Video", @"JPComics_Video", @"Lightcolor_Video", @"Ink_Video", @"Monochrome_Video"

@implementation TuFilterPanelViewCellData
 - (instancetype)init
 {
     if (self = [super init])
     {
         _state = TuFilterPanelViewCellUnselected;
         _filterCode = @"Normal";
     }
     return self;
 }
@end


@interface TuFilterPanelViewCell()
{
    UILabel *_titleLabel;
    UIImageView *_thumbnailView;
    UIImageView *_selectedView;
}
@end


@implementation TuFilterPanelViewCell

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
    [super setSelected:selected];

    if ([_data.filterCode isEqualToString:@"Normal"])
    {
        
    }
    else
    {
        _titleLabel.hidden = selected;
        _selectedView.hidden = !selected;
        
        NSArray *cosicsCodes = @[ComicsCodes];
        if ([cosicsCodes containsObject:_data.filterCode])
        {
            _selectedView.image = nil;
        }
        else
        {
            _selectedView.image = [UIImage imageNamed:@"ic_parameter"];
        }
    }
}

- (void)setData:(TuFilterPanelViewCellData *)data
{
    _data = data;
    
    if ([_data.filterCode isEqualToString:@"Normal"])
    {
        _titleLabel.text = nil;
        _titleLabel.hidden = YES;
        _thumbnailView.image = [UIImage imageNamed:@"ic_nix"];
        _thumbnailView.contentMode = UIViewContentModeCenter;
    }
    else
    {
        NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", _data.filterCode];
        _titleLabel.text = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");

        NSString *thumbName = [NSString stringWithFormat:@"lsq_filter_thumb_%@", _data.filterCode];
        NSString *thumbPath = [[NSBundle mainBundle] pathForResource:thumbName ofType:@"jpg"];
        _thumbnailView.image = [UIImage imageWithContentsOfFile:thumbPath];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        
        if (data.state != TuFilterPanelViewCellUnselected)
        {
            _titleLabel.hidden = YES;
            _selectedView.hidden = NO;
            
            NSArray *cosicsCodes = @[ComicsCodes];
            if ([cosicsCodes containsObject:_data.filterCode])
            {
                _selectedView.image = nil;
            }
            else
            {
                _selectedView.image = [UIImage imageNamed:@"ic_parameter"];
            }
        }
    }
}


@end
