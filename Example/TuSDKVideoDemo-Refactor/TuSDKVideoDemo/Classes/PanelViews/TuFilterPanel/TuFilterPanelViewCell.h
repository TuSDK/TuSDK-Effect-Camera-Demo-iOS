/********************************************************
 * @file    : TuFilterPanelViewCell.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 滤镜显示项
*********************************************************/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TuFilterPanelViewCellState)
{
    TuFilterPanelViewCellUnselected = 0,
    TuFilterPanelViewCellSelected,
    TuFilterPanelViewCellParamAdjust
};


@interface TuFilterPanelViewCellData : NSObject
@property (nonatomic, assign) TuFilterPanelViewCellState state;
@property (nonatomic, copy) NSString *filterCode;
@end


@interface TuFilterPanelViewCell : UICollectionViewCell
@property (nonatomic, strong) TuFilterPanelViewCellData *data;
@end


NS_ASSUME_NONNULL_END
