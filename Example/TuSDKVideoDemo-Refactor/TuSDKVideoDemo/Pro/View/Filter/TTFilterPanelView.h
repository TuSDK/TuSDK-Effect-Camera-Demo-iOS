//
//  TTFilterPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/5.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TTFilterPanelView;
@protocol TTBeautyProtocol;

@protocol TTFilterPanelViewDelegate <NSObject>

/**
 * 切换滤镜
 * @param view 滤镜视图
 * @param filterCode 滤镜code
 */
- (void)filterPanelView:(TTFilterPanelView *)view didSelectFilterCode:(NSString *)filterCode;

@end

@interface TTFilterPanelView : UIView

@property (nonatomic, weak) id<TTFilterPanelViewDelegate> delegate;

+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;

/// 切换到下一个滤镜
- (void)swipeToNextFilter;

/// 切换到上一个滤镜
- (void)swipeToLastFilter;

@end

NS_ASSUME_NONNULL_END
