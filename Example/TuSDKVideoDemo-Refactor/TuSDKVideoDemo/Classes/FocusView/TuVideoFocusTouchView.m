/********************************************************
 * @file    : TuSDKVideoFocusTouchView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 聚焦视图
*********************************************************/

#import "TuVideoFocusTouchView.h"
#import "TuVideoFocusRangeView.h"


@interface TuVideoFocusTouchView()
{
}
@end


@implementation TuVideoFocusTouchView

//@synthesize rangeView = _rangeView;
@synthesize displayGuideLine;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoFoucsDelay = 2.0f;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (UIView *)buildFaceDetectionView
{
//    UIView * view = [UIView initWithFrame:CGRectMake(0, 0, 0, 0)];
//
//    [view setBackgroundColor:[UIColor clearColor]];
//    view.layer.borderWidth = 1;
//    view.layer.borderColor = [lsqRGB(255, 192, 0) CGColor];
//    view.clipsToBounds = YES;
//    view.layer.masksToBounds = YES;
//    view.layer.cornerRadius = 10;
//    return view;
    
    return nil;
}

-(void)setRangeView:(UIView<TuFocusRangeViewProtocol> *)rangeView
{
    if (!rangeView)
    {
        return;
    }
    
    if (_rangeView)
    {
        [_rangeView removeFromSuperview];
    }
    _rangeView = rangeView;
    
    [self addSubview:_rangeView];
}

- (UIView<TuFocusRangeViewProtocol> *)rangeView
{
    if (!_rangeView && !_disableTapFocus)
    {
        _rangeView = [TuVideoFocusRangeView new];
        [self addSubview:_rangeView];
    }
    return _rangeView;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_disableTapFocus)
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_disableTapFocus)
    {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_disableTapFocus)
    {
        [super touchesEnded:touches withEvent:event];
    }
}

- (BOOL)onFocusWithPoint:(CGPoint)point isTouches:(BOOL)isTouches
{
    BOOL result = NO;
    
    if (isTouches)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(focusTouchView:didTapPoint:)])
        {
            if ([_delegate focusTouchView:self didTapPoint:point])
            {
                result = [super onFocusWithPoint:point isTouches:isTouches];
                [self.rangeView onTuSDKICFocusRange:CGRectMake(point.x, point.y, self.lsqGetSizeWidth, self.lsqGetSizeHeight)];
            }
        }
    }
    
    return result;
}


@end
