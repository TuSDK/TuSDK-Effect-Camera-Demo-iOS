/********************************************************
 * @file    : TuFacePlasticPanelViewCell.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   :微整形显示项
*********************************************************/
#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, TuFacePlasticPanelViewCellState)
{
    TuFacePlasticPanelViewCellUnselected = 0,
    TuFacePlasticPanelViewCellSelected
};


@interface TuFacePlasticPanelViewCellData : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) TuFacePlasticPanelViewCellState state;
@end


@interface TuFacePlasticPanelViewCell : UICollectionViewCell
@property (nonatomic, strong) TuFacePlasticPanelViewCellData *data;
@end


NS_ASSUME_NONNULL_END
