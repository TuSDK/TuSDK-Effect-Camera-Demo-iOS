/********************************************************
 * @file    : TuVideoFocusRangeView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 聚焦视图
*********************************************************/

#import "TuVideoFocusRangeView.h"

@implementation TuVideoFocusRangeView
- (void)lsqInitView
{
    if (CGRectEqualToRect(self.frame, CGRectZero))
    {
        self.frame = CGRectMake(0, 0, 90, 90);
    }
    
    // self.center = CGPointMake(0.5f, 0.5f);
    
    // 动画选区视图
    _animaRangeView = [UIView initWithFrame:self.bounds];
    [self addSubview:_animaRangeView];
    
    // 最大选区视图
    _maxRangeView = [UIImageView initWithFrame:self.bounds];
    _maxRangeView.image = [[UIImage imageNamed:@"video_camera_focus"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [_animaRangeView addSubview:_maxRangeView];
    
    // 结束选区视图
    _endRangeView = [UIImageView initWithFrame:CGRectMake([self lsqGetCenterX:60], [self lsqGetCenterY:60], 60, 60)
                           imageNamed:@"video_camera_focus_finish"];
    [self addSubview:_endRangeView];
    
    // 光标 上
    _topCursor = [UIView initWithFrame:CGRectMake([self lsqGetCenterX:2], 0, 2, 12)];
    [_animaRangeView addSubview:_topCursor];
    
    // 光标 右
    _rightCursor = [UIView initWithFrame:CGRectMake(self.lsqGetSizeWidth - 12, [self lsqGetCenterY:2], 12, 2)];
    [_animaRangeView addSubview:_rightCursor];
    
    // 光标 下
    _bottomCursor = [UIView initWithFrame:CGRectMake([self lsqGetCenterX:2], self.lsqGetSizeHeight - 12, 2, 12)];
    [_animaRangeView addSubview:_bottomCursor];
    
    // 光标 左
    _leftCursor = [UIView initWithFrame:CGRectMake(0, [self lsqGetCenterY:2], 12, 2)];
    [_animaRangeView addSubview:_leftCursor];
    
    // 设置光标颜色
    [self setCursorColor:[UIColor whiteColor]];
    
    // 音频播放对象
    _audioPlayer = [AVAudioPlayer playerLsqBundleCameraFocusBeep];
    
    // 默认设置隐藏
    self.hidden = YES;
}

@end
