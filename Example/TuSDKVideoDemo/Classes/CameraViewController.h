
/********************************************************
 * @file    : CameraViewController.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 相机控制器
*********************************************************/

#import <UIKit/UIKit.h>
#import "CameraMoreMenuView.h"
#import "MarkableProgressView.h"
#import "RecordButton.h"

/**
 录制相机视图控制器
 */
@interface CameraViewController : UIViewController
+ (instancetype)recordController;
@end
