/********************************************************
 * @file    : TuStickerDownloader.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸下载器
*********************************************************/
#import <Foundation/Foundation.h>
#import "TuSDKFramework.h"

NS_ASSUME_NONNULL_BEGIN

/**
 贴纸道具下载器
 */
@interface TuStickerDownloader:TuOnlineStickerDownloader
+ (instancetype)shared;
- (void)addDelegate:(id<TuOnlineStickerDownloaderDelegate>)delegate;
- (void)removeDelegate:(id<TuOnlineStickerDownloaderDelegate>)delegate;
@end


NS_ASSUME_NONNULL_END
