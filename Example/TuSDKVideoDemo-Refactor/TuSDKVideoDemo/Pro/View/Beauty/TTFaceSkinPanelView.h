//
//  TTFaceSkinPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTBeautyItem.h"

NS_ASSUME_NONNULL_BEGIN
@class TTFaceSkinPanelView;
@protocol TTFaceSkinPanelViewDelegate <NSObject>

/**
 * 美肤效果选中
 * @param view 面板视图
 * @param item 选中组件
 */
- (void)faceSkinPanelView:(TTFaceSkinPanelView *)view didSelectItem:(TTFaceSkinItem *)item;
/**
 * 设置美肤效果
 * @param view 面板视图
 * @param skinType 美肤算法
 */
- (void)faceSkinPanelView:(TTFaceSkinPanelView *)view setSkinType:(TTSkinStyle)skinType;

@end

@protocol TTBeautyProtocol;

@interface TTFaceSkinPanelView : UIView

@property (nonatomic, weak) id<TTFaceSkinPanelViewDelegate> delegate;

+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;

/**
 * 根据美肤code修改相对应的参数值
 * @param code 美肤code
 * @param value 参数值
 */
- (void)updateSkinWithCode:(NSString *)code value:(float)value;

@end

NS_ASSUME_NONNULL_END
