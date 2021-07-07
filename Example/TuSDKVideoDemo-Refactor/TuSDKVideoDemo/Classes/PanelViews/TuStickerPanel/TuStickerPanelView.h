/********************************************************
 * @file    : TuStickerPanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸面板
*********************************************************/
#import "TuStickerBaseDatasets.h"
#import "TuStickerDatasets.h"
#import "TuMonsterDatasets.h"

@class TuStickerPanelView;


@protocol TuStickerPanelViewDelegate <NSObject>
@optional
- (void)stickerPanelView:(TuStickerPanelView *)panelView didSelectItem:(__kindof TuStickerBaseData *)categoryItem;
- (void)stickerPanelView:(TuStickerPanelView *)panelView unSelectItem:(__kindof TuStickerBaseData *)categoryItem;
- (void)stickerPanelView:(TuStickerPanelView *)panelView didRemoveItem:(__kindof TuStickerBaseData *)categoryItem;
- (void)stickerPanelViewHidden:(TuStickerPanelView *)panelView;
@end

@interface TuStickerPanelView : UIView

@property (nonatomic, strong) NSArray<TuStickerBaseDatasets *> *categorys; // 分类列表
@property (nonatomic, weak) id<TuStickerPanelViewDelegate> delegate;

//@property (nonatomic, copy) void(^showPanelView)(void);

- (void)enableStickers:(BOOL)enable;

@end
