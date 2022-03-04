/********************************************************
 * @file    : TuOnlineSticker.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 在线贴纸
*********************************************************/
#import "TuSDKFramework.h"

/**
 在线贴纸模型
 */
@interface TuOnlineSticker : TuStickerGroup
@property (nonatomic, copy) NSString *previewImage; // 预览图 URL
//@property (nonatomic, copy) NSString *name; // 贴纸名称
//@property (nonatomic, assign) uint64_t idt; // 贴纸 ID（stickerID）

@end
