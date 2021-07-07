/********************************************************
 * @file    : RecordButton.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 录制按钮
*********************************************************/

#import <UIKit/UIKit.h>

@class RecordButton;


typedef NS_ENUM(NSInteger, RecordButtonStyle)
{
    RecordButtonStyle_PhotoCapture, // 拍照模式样式
    RecordButtonStyle_TapRecord, // 录制模式样式（默认）
    RecordButtonStyle_JoinerRecord // 合拍
};

@protocol RecordButtonDelegate <NSObject>
@optional
- (void)recordButtonDidTouchDown:(RecordButton *)reocrdButton;
- (void)recordButtonDidTouchEnd:(RecordButton *)reocrdButton;
@end


@interface RecordButton : UIButton
@property(nonatomic, weak) id<RecordButtonDelegate> delegate;

- (void)switchStyle:(RecordButtonStyle)style;
- (RecordButtonStyle)getRecordStyle;

@end
