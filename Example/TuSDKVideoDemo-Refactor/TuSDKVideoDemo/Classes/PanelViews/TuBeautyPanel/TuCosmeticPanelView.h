/********************************************************
 * @file    : TuCosmeticPanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美妆面板
*********************************************************/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class TuCosmeticPanelView;

@protocol TuCosmeticPanelViewDelegate <NSObject>

- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view paramCode:(NSString *)code value:(NSInteger)value;
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view paramCode:(NSString *)code enable:(BOOL)enable;
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName;
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view closeSliderBar:(BOOL)close;
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view changeCosmeticType:(NSString *)cosmeticCode;
@end


@interface TuCosmeticPanelView : UIView
@property (nonatomic, weak) id<TuCosmeticPanelViewDelegate> delegate;

@property (nonatomic, assign) BOOL resetCosmetic;

- (void)deselect; // 取消选中

@end


NS_ASSUME_NONNULL_END
