/********************************************************
 * @file    : TuFaceSkinPanelViewCell.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美肤显示项
*********************************************************/
#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TuBeautySkinSelectType)
{
    TuBeautySkinSelectTypeUnselected = 0,
    TuBeautySkinSelectTypeSelected
};


@interface TuFaceSkinPanelViewData : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) TuBeautySkinSelectType beautySkinSelectType;
@end


@interface TuFaceSkinPanelViewCell : UICollectionViewCell
@property (nonatomic, strong) TuFaceSkinPanelViewData *data;
@end


NS_ASSUME_NONNULL_END
