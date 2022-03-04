//
//  TTFacePlasticPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTBeautyItem.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TTBeautyProtocol;

@class TTFacePlasticPanelView;

@protocol TTFacePlasticPanelViewDelegate <NSObject>

/**
 * 微整形效果选中
 * @param view 面板视图
 * @param item 选中组件
 */
- (void)facePlasticPanelView:(TTFacePlasticPanelView *)view didSelectItem:(TTFacePlasticItem *)item;

@end

@interface TTFacePlasticPanelView : UIView

+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;

@property (nonatomic, weak) id<TTFacePlasticPanelViewDelegate> delegate;

/**
 * 根据微整形code修改相对应的参数值
 * @param code 微整形code
 * @param value 参数值
 */
- (void)updatePlasticWithCode:(NSString *)code value:(float)value;

/// 重置微整形数据
- (void)resetPlasticData;

- (void)deselect; // 取消选中

@end

NS_ASSUME_NONNULL_END
