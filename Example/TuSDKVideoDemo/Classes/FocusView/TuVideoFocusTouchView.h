
/********************************************************
 * @file    : TuSDKVideoFocusTouchView.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 聚焦视图
*********************************************************/

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"


@protocol TuFocusTouchViewDelegate <NSObject>
- (BOOL)focusTouchView:(TuFocusTouchViewBase *)focusTouchView didTapPoint:(CGPoint)point;
@end

/**
 *  相机聚焦触摸视图
 */
@interface TuVideoFocusTouchView : TuFocusTouchViewBase
{
}

@property (nonatomic, readonly) UIView<TuFocusRangeViewProtocol> *rangeView; // 聚焦视图 (如果不设定，将使用 TuSDKICFocusRangeView)
@property (nonatomic, weak) id<TuFocusTouchViewDelegate> delegate;
@property (nonatomic) NSInteger topSpace; // 顶部边距
@property (nonatomic) BOOL disableTapFocus; // 是否禁止触摸聚焦 (默认: YES)

@end

