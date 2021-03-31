/********************************************************
 * @file    : TuParametersAdjustView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 参数调节面板
*********************************************************/
#import "TuParametersAdjustView.h"
#import "TuCustomSlider.h"


static const CGFloat kItemHeight = 18; // 参数项高度
static const CGFloat kItemNameWidth = 30; // 参数名称标签宽度
static const CGFloat kItemValueWidth = 35; // 参数值标签宽度
static const CGFloat kItemLineSpacing = 11; // 参数项间的间隔

/** TuParameterAdjustItem ************************************************/
@interface TuParameterAdjustItem()
{
    NSInteger _index;
    
    UILabel *_nameLabel;
    UILabel *_valueLabel;
    TuCustomSlider *_slider;
    UIView *_centerPointView;
}
@end


@implementation TuParameterAdjustItem

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
    // 参数名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_nameLabel];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _nameLabel.layer.shadowOffset = CGSizeMake(0, 0);
    _nameLabel.layer.shadowRadius = 1.0;
    _nameLabel.layer.shadowOpacity = 0.6;
    
    // 数值label
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_valueLabel];
    _valueLabel.textColor = [UIColor whiteColor];
    _valueLabel.font = [UIFont systemFontOfSize:12];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    _valueLabel.adjustsFontSizeToFitWidth = YES;
    _valueLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _valueLabel.layer.shadowOffset = CGSizeMake(0, 0);
    _valueLabel.layer.shadowRadius = 1.0;
    _valueLabel.layer.shadowOpacity = 0.6;
    
    // 滑动条
    _slider = [[TuCustomSlider alloc] initWithFrame:CGRectZero];
    [_slider addTarget:self action:@selector(sliderProgressChange:) forControlEvents:UIControlEventValueChanged];
    _slider.layer.shadowColor = [UIColor blackColor].CGColor;
    _slider.layer.shadowOffset = CGSizeMake(0, 0);
    _slider.layer.shadowRadius = 1.0;
    _slider.layer.shadowOpacity = 0.6;
    [self addSubview:_slider];
    
    //滑动条默认点
    _centerPointView = [[UIView alloc] initWithFrame:CGRectZero];
    _centerPointView.backgroundColor = [UIColor whiteColor];
    _centerPointView.layer.cornerRadius = 4;

    [_slider addSubview:_centerPointView];
}

- (void)layoutSubviews
{
    _nameLabel.frame = CGRectMake(0, 0, kItemNameWidth, self.bounds.size.height);
    _valueLabel.frame = CGRectMake(self.bounds.size.width - kItemValueWidth, 0, kItemValueWidth, self.bounds.size.height);
    
    CGRect sliderFrame = CGRectZero;
    sliderFrame.origin.x = CGRectGetMaxX(_nameLabel.frame) + 12;
    sliderFrame.origin.y = 0;
    sliderFrame.size.width = CGRectGetMinX(_valueLabel.frame) - CGRectGetMaxX(_nameLabel.frame) - 24;
    sliderFrame.size.height = self.bounds.size.height;
    _slider.frame = sliderFrame;
    
    CGFloat sliderMinX = _defaultVal * CGRectGetWidth(sliderFrame);
    _centerPointView.frame = CGRectMake(sliderMinX - 4, CGRectGetHeight(sliderFrame) / 2 - 4, 8, 8);
    
//    if (_defaultVal != 0)
//    {
//        CGFloat sliderMinX = _defaultVal * CGRectGetWidth(sliderFrame);
//        if (_defaultVal == 1)
//        {
//            _centerPointView.frame = CGRectMake(sliderMinX - 8, CGRectGetHeight(sliderFrame) / 2 - 4, 8, 8);
//        }
//        else
//        {
//            _centerPointView.frame = CGRectMake(sliderMinX - 4, CGRectGetHeight(sliderFrame) / 2 - 4, 8, 8);
//        }
//    }
    if (_defaultVal == 1)
    {
        _centerPointView.frame = CGRectMake(sliderMinX - 8, CGRectGetHeight(sliderFrame) / 2 - 4, 8, 8);
    }
    else
    {
        if (_defaultVal == 0)
        {
            _centerPointView.frame = CGRectMake(sliderMinX, CGRectGetHeight(sliderFrame) / 2 - 4, 8, 8);
        }
        else
        {
            _centerPointView.frame = CGRectMake(sliderMinX - 4, CGRectGetHeight(sliderFrame) / 2 - 4, 8, 8);
        }
    }
}

- (void)updateValueText
{
    // 文字显示的范围是 0% ~ 100%
    float percentValue = (_slider.value - _slider.minimumValue) / (_slider.maximumValue - _slider.minimumValue) * 1.0;
    if (_status)
    {
        if (percentValue > 0.49 && percentValue < 0.51)
        {
            percentValue = 0;
        }
        else
        {
            percentValue -= 0.5;
        }
    }
    _valueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(percentValue) numberStyle:NSNumberFormatterPercentStyle];
}

- (void)setStatus:(BOOL)status
{
    _status = status;
}

- (void)setParam:(NSString *)name val:(float)val index:(NSInteger)index
{
    _index = index;
    
    _nameLabel.text = name;
    
    if (_status && val == 0)
    {
        val += 0.5;
    }
    _slider.value = val;
    [self updateValueText];
}

- (void)setDefaultVal:(float)defaultVal
{
    _defaultVal = defaultVal;
    [self updateValueText];
}

- (void)sliderProgressChange:(TuCustomSlider *)slider
{
    float value = slider.value;
    
    if (_delegate && [_delegate respondsToSelector:@selector(sliderProgressChange:val:)])
    {
        [_delegate sliderProgressChange:_index val:value];
    }
    
    [self updateValueText];
}
@end


/** TuParametersAdjustView ************************************************/
@interface TuParametersAdjustView()<TuParameterAdjustViewItemDelegate>
{
    NSArray<TuParameterAdjustItem *> *_itemViews;
    CGFloat _contentHeight;
}
@end


@implementation TuParametersAdjustView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    CGFloat itemY = size.height - kItemHeight;
    
    for (NSInteger i = _itemViews.count - 1; i >= 0; i--)
    {
        TuParameterAdjustItem *itemView = _itemViews[i];
        itemView.frame = CGRectMake(0, itemY, size.width, kItemHeight);
        itemY -= kItemHeight + kItemLineSpacing;
    }
}


- (void)setParams:(NSMutableArray *)params
{
    _params = params;
    
    [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSMutableArray *itemViews = [NSMutableArray array];
    for (NSInteger parIndex = 0; parIndex < _params.count; parIndex++)
    {
        NSString *name = [_params[parIndex] objectForKey:@"name"];
        float val = [[_params[parIndex] objectForKey:@"val"] floatValue];
        float defaultVal = 0;
        if ([_params[parIndex] objectForKey:@"defaultVal"])
        {
            defaultVal = [[_params[parIndex] objectForKey:@"defaultVal"] floatValue];
        }
        
        TuParameterAdjustItem *itemView = [[TuParameterAdjustItem alloc] initWithFrame:CGRectZero];
        itemView.delegate = self;
        if ([_params[parIndex] objectForKey:@"status"])
        {
            NSNumber *status = [_params[parIndex] objectForKey:@"status"];
            itemView.status = status.boolValue;
        }
        
        [itemView setParam:name val:val index:parIndex];
        itemView.defaultVal = defaultVal;
        [itemViews addObject:itemView];
        [self addSubview:itemView];
    }
    
    _itemViews = itemViews.copy;
    
    _contentHeight = _itemViews.count * (kItemHeight + kItemLineSpacing) - kItemLineSpacing;
    [self.superview setNeedsLayout];
}

- (void)sliderProgressChange:(NSInteger)index val:(float)val
{
    if (_delegate && [_delegate respondsToSelector:@selector(ParameterAdjustView:index:val:)])
    {
        [_delegate ParameterAdjustView:self index:index val:val];
    }
}


@end
