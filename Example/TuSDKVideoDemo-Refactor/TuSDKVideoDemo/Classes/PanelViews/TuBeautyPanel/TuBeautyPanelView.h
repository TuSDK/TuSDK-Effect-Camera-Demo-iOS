/********************************************************
 * @file    : TuBeautyPanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美颜面板
*********************************************************/

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "TuCosmeticPanelView.h"
#import "TuFacePlasticPanelView.h"
#import "TuFaceSkinPanelView.h"
#import "TuBeautyPanelConfig.h"


@class TuBeautyPanelView;

@protocol TuBeautyPanelViewDelegate <NSObject>

- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enablePlastic:(BOOL)enable;
- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enableExtraPlastic:(BOOL)enable;
- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode;
- (SelesParameters *)tuBeautyPanelView:(TuBeautyPanelView *)view enableCosmetic:(BOOL)enable isAskPop:(BOOL)isAskPop;
- (void)tuBeautyPanelView:(TuBeautyPanelView *)view cosmeticParamCode:(NSString *)code enable:(BOOL)enable;
- (void)tuBeautyPanelView:(TuBeautyPanelView *)view cosmeticParamCode:(NSString *)code value:(NSInteger)value;

- (void)tuBeautyPanelView:(TuBeautyPanelView *)view plasticdidSelectCode:(NSString *)code;

@end



@interface TuBeautyPanelView : UIView

@property (nonatomic, weak) id<TuBeautyPanelViewDelegate> delegate;

@property (nonatomic, assign) BOOL resetCosmetic;

- (void)enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode;
- (void)enablePlastic:(BOOL)enable;
- (void)enableExtraPlastic:(BOOL)enable;
- (void)enableCosmetic:(BOOL)enable;

- (SelesParameters *)skinParams;

@end
