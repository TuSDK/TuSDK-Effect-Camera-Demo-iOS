//
//  TTCosmeticPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTCosmeticPanelView;
@protocol TTBeautyProtocol;

@protocol TTCosmeticPanelViewDelegate <NSObject>

- (void)cosmeticPanelView:(TTCosmeticPanelView *)view code:(NSString *)code value:(NSInteger)value;
- (void)cosmeticPanelView:(TTCosmeticPanelView *)view code:(NSString *)code enable:(BOOL)enable;
//切换美妆
- (void)cosmeticPanelView:(TTCosmeticPanelView *)view changeCosmeticType:(NSString *)cosmeticCode;
//关闭调节栏
- (void)cosmeticPanelView:(TTCosmeticPanelView *)view closeSliderBar:(BOOL)close;

- (void)cosmeticPanelView:(TTCosmeticPanelView *)view didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TTCosmeticPanelView : UIView

@property (nonatomic, weak) id<TTCosmeticPanelViewDelegate>delegate;

@property (nonatomic, assign) BOOL resetCosmetic;

+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;

@end

NS_ASSUME_NONNULL_END
