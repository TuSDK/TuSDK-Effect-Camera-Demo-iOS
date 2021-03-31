/********************************************************
 * @file    : TuFilterPanelView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 滤镜面板
*********************************************************/
#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
#import "TuFilterPanelViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class TuFilterPanelView;


@protocol TuFilterPanelViewDelegate<NSObject>
- (SelesParameters *)tuFilterPanelView:(TuFilterPanelView *)panelView didSelectedFilterCode:(NSString *)code;
@end


@interface TuFilterPanelViewDataset : NSObject
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, strong) NSMutableArray<TuFilterPanelViewCellData *> *groupData;

- (instancetype)initWith:(NSString *)name codes:(NSMutableArray<NSString *> *)codes;
@end

@interface TuFilterPanelView : UIView
@property (nonatomic, strong) NSArray *filterCodes; //滤镜
@property (nonatomic, weak) id<TuFilterPanelViewDelegate> delegate;

/**切换到下一个滤镜*/
- (void)swipeToNextFilter;

/**切换到上一个滤镜*/
- (void)swipeToLastFilter;

@end


NS_ASSUME_NONNULL_END
