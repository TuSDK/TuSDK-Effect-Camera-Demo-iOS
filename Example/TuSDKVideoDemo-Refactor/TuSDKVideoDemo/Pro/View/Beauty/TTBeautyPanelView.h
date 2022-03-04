//
//  TTBeautyPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRenderDef.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TTBeautyProtocol;

@class TTBeautyPanelView;

@protocol TTBeautyPanelViewDelegate <NSObject>

/**
 * 切换美肤类型
 * @param view 当前视图
 * @param skinStyle 美肤类型
 */
- (void)beautyPanelView:(TTBeautyPanelView *)view didSelectSkinType:(TTSkinStyle)skinStyle;

@end

@interface TTBeautyPanelView : UIView

@property (nonatomic, weak) id<TTBeautyPanelViewDelegate> delegate;

+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;

- (void)enablePlastic:(BOOL)enable;
- (void)enableExtraPlastic:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
