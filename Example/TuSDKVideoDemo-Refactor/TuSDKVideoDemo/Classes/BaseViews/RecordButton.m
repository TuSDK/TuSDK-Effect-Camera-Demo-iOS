/********************************************************
 * @file    : RecordButton.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 录制按钮
*********************************************************/

#import "RecordButton.h"

@interface RecordButton()
{
    RecordButtonStyle _style;
}

@property (nonatomic, strong) CAShapeLayer *backgroundDotLayer; // 背景圆点图层
@property (nonatomic, strong) CAShapeLayer *dotLayer; // 前景圆点图层
@property (nonatomic, assign) CGPoint panBeganCenter; // 滑动开始中点，用于滑动结束后还原
@property (nonatomic, assign) CGSize contentSize; // 内容适配大小
@property (nonatomic, strong) UIColor *backgroundDotColor; // 背景圆点颜色
@property (nonatomic, strong) UIColor *dotColor; // 前景圆点颜色
@property (nonatomic, assign) double backgroundDotRatio; // 背景圆点与前景圆点直径比率

@end


@implementation RecordButton

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        [self commonInit];
    }
    return self;
}

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
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor whiteColor];
    self.adjustsImageWhenHighlighted = NO;
    _backgroundDotColor = [UIColor colorWithWhite:1 alpha:0.6];
    _dotColor = [UIColor colorWithRed:254.0f/255.0f green:58.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
    _backgroundDotRatio = 7/9.0;
    
    _dotLayer = [CAShapeLayer layer];
    [self.layer insertSublayer:_dotLayer atIndex:0];
    _dotLayer.fillColor = _dotColor.CGColor;
    
    _backgroundDotLayer = [CAShapeLayer layer];
    [self.layer insertSublayer:_backgroundDotLayer atIndex:0];
    _backgroundDotLayer.fillColor = _backgroundDotColor.CGColor;
    
    [self addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchEndAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundDotLayer.frame = _dotLayer.frame = self.bounds;
    _backgroundDotLayer.path = [self circleWithRadiusInset:0].CGPath;
    _dotLayer.path = [self circleWithRadiusScale:_backgroundDotRatio].CGPath;
    [self bringSubviewToFront:self.imageView];
}

/**
 创建圆形路径

 @param radiusInset 半径缩进
 @return 圆形路径
 */
- (UIBezierPath *)circleWithRadiusInset:(CGFloat)radiusInset
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = center.x + radiusInset;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    return path;
}

/**
 创建圆形路径

 @param radiusScale 半径缩放
 @return 圆形路径
 */
- (UIBezierPath *)circleWithRadiusScale:(CGFloat)radiusScale
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = center.x * radiusScale;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    return path;
}


#pragma mark - property
- (void)setContentSize:(CGSize)contentSize
{
    _contentSize = contentSize;
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    return _contentSize;
}

- (void)setBackgroundDotColor:(UIColor *)backgroundDotColor
{
    _backgroundDotColor = backgroundDotColor;
    _backgroundDotLayer.fillColor = backgroundDotColor.CGColor;
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    _dotLayer.fillColor = _dotColor.CGColor;
}

- (void)setBackgroundDotRatio:(double)backgroundDotRatio
{
    _backgroundDotRatio = backgroundDotRatio;
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        NSString *transformKey = @"transform.scale";
        [_backgroundDotLayer setValue:@(7/6.0) forKeyPath:transformKey];
        [_dotLayer setValue:@(6/7.0) forKeyPath:transformKey];
    }
    else
    {
        _backgroundDotLayer.affineTransform = CGAffineTransformIdentity;
        _dotLayer.affineTransform = CGAffineTransformIdentity;
    }
}

#pragma mark - action
- (void)touchDownAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(recordButtonDidTouchDown:)])
    {
        [_delegate recordButtonDidTouchDown:self];
    }
}

- (void)touchEndAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(recordButtonDidTouchEnd:)])
    {
        [_delegate recordButtonDidTouchEnd:self];
    }
}

- (void)switchStyle:(RecordButtonStyle)style
{
    self.backgroundDotColor = [UIColor colorWithWhite:1 alpha:0.6];
    self.dotColor = [UIColor colorWithRed:254.0f/255.0f green:58.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
    self.contentSize = CGSizeMake(72, 72);
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateSelected];
    
    _style = style;
    
    switch (style)
    {
        case RecordButtonStyle_PhotoCapture:
            self.dotColor = [UIColor whiteColor];
            break;
            
        default:
        {
            UIImage *image = [UIImage imageNamed:@"video_ic_recording"];
            [self setImage:image forState:UIControlStateNormal];
            [self setImage:image forState:UIControlStateSelected];
        }
            break;
    }
}

- (RecordButtonStyle)getRecordStyle
{
    return _style;
}

@end
