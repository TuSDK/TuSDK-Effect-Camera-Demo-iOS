/********************************************************
 * @file    : TuFaceSkinPanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美肤面板
*********************************************************/
#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN

@class TuFaceSkinPanelView;

@protocol TuFaceSkinPanelViewDelegate <NSObject>
- (void)TuFaceSkinPanelView:(TuFaceSkinPanelView *)view enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode;
- (void)TuFaceSkinPanelView:(TuFaceSkinPanelView *)view didSelectCode:(NSString *)code;
@end


@interface TuFaceSkinPanelView : UIView
@property (nonatomic, weak) id<TuFaceSkinPanelViewDelegate> delegate;
@property (nonatomic, readonly) TuSkinFaceType faceSkinType;


- (void)enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode;

@end


NS_ASSUME_NONNULL_END
