/********************************************************
 * @file    : TuFacePlasticPanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   :微整形显示项
*********************************************************/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TuFacePlasticPanelView;

@protocol TuFacePlasticPanelViewDelegate <NSObject>
- (void)tuFacePlasticPanelView:(TuFacePlasticPanelView *)view didSelectCode:(NSString *)code;
@end


@interface TuFacePlasticPanelView : UIView
@property (nonatomic, weak) id<TuFacePlasticPanelViewDelegate> delegate;

- (void)deselect; // 取消选中

@end


NS_ASSUME_NONNULL_END
