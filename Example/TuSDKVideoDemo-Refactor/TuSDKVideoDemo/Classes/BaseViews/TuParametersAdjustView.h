/********************************************************
 * @file    : TuParametersAdjustView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 参数调节面板
*********************************************************/
#import <UIKit/UIKit.h>


@protocol TuParameterAdjustViewItemDelegate<NSObject>
@optional
- (void)sliderProgressChange:(NSInteger)index val:(float)val;
@end

@interface TuParameterAdjustItem : UIView
@property (nonatomic, weak) id<TuParameterAdjustViewItemDelegate> delegate;
/**
 微整形 : 判断是否name是否剔除大眼、瘦鼻、瘦脸
 YES : val - -0.5 ~ 0.5
 NO  : val - 0 ~ 1
 */
@property (nonatomic, assign) BOOL status;
@property (nonatomic, assign) float defaultVal;
- (void)setParam:(NSString *)name val:(float)val index:(NSInteger)index;
@end


@class TuParametersAdjustView;
@protocol TuParameterAdjustViewDelegate<NSObject>
@optional
- (void)ParameterAdjustView:(TuParametersAdjustView *)paramAdjustView index:(NSInteger)index val:(float)val;
@end

@interface TuParametersAdjustView : UIView
@property (nonatomic, strong) NSMutableArray *params;
@property (nonatomic, assign, readonly) CGFloat contentHeight; //  面板的自适应高度
@property (nonatomic, weak) id<TuParameterAdjustViewDelegate> delegate;

@end
