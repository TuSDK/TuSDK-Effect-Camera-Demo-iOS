/********************************************************
 * @file    : TuCustomSlider.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   :
*********************************************************/

#import "TuCustomSlider.h"

#define SLIDER_X_BOUND 30
#define SLIDER_Y_BOUND 40

@interface TuCustomSlider()
@property (nonatomic, assign) CGPoint touchBeginPoint;
@property (nonatomic, assign) CGRect lastBounds;

@end


@implementation TuCustomSlider
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
    [self setThumbImage:[self.class circleImageWithSize:CGSizeMake(18, 18) color:[UIColor whiteColor]] forState:UIControlStateNormal];
    self.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.tintColor = [UIColor whiteColor];
}


- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{

    rect.origin.x = rect.origin.x;
    rect.size.width = rect.size.width ;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    _lastBounds = result;
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    UIView *result = [super hitTest:point withEvent:event];
    
    if (point.x < 0 || point.x > self.bounds.size.width){
        
        return result;
        
    }
    
    if ((point.y >= - SLIDER_Y_BOUND) && (point.y < _lastBounds.size.height + SLIDER_Y_BOUND)) {
        float value = 0.0;
        value = point.x - self.bounds.origin.x;
        value = value/self.bounds.size.width;
        
        value = value < 0? 0 : value;
        value = value > 1? 1: value;
        
        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
        [self setValue:value animated:YES];
    }
    return result;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL result = [super pointInside:point withEvent:event];
    if (!result && point.y > -10) {
        if ((point.x >= _lastBounds.origin.x - SLIDER_X_BOUND) && (point.x <= (_lastBounds.origin.x + _lastBounds.size.width + SLIDER_X_BOUND)) && (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND))) {
            result = YES;
        }
      
    }
      return result;
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (touches.count > 1) return;
    _touchBeginPoint = [touches.anyObject locationInView:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (touches.count > 1) return;
    CGPoint touchEndPoint = [touches.anyObject locationInView:self];
    if (!CGPointEqualToPoint(touchEndPoint, _touchBeginPoint)) {
        _touchBeginPoint = CGPointZero;
        return;
    }
    CGFloat value = touchEndPoint.x / self.bounds.size.width;
    [self setValue:value animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

+ (UIImage *)circleImageWithSize:(CGSize)size color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
