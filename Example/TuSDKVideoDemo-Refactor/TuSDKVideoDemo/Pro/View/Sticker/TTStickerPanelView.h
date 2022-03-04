//
//  TTStickerPanelView.h
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/4.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuStickerBaseDatasets.h"
#import "TuStickerDatasets.h"
#import "TuMonsterDatasets.h"

@class TTStickerPanelView;
@protocol TTBeautyProtocol;

@protocol TTStickerPanelViewDelegate <NSObject>
@optional
- (void)stickerPanelView:(TTStickerPanelView * _Nullable)panelView didSelectItem:(__kindof TuStickerBaseData *)categoryItem;
//- (void)stickerPanelView:(TTStickerPanelView * _Nullable)panelView unSelectItem:(__kindof TuStickerBaseData *)categoryItem;
- (void)stickerPanelView:(TTStickerPanelView * _Nullable)panelView didRemoveItem:(__kindof TuStickerBaseData *)categoryItem;
- (void)stickerPanelViewHidden:(TTStickerPanelView * _Nullable)panelView;
@end

NS_ASSUME_NONNULL_BEGIN

@interface TTStickerPanelView : UIView

+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget;

@property (nonatomic, strong) NSArray<TuStickerBaseDatasets *> *categorys; // 分类列表
@property (nonatomic, weak) id<TTStickerPanelViewDelegate> delegate;

- (void)enableStickers:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
