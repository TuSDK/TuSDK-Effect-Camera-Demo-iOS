/********************************************************
 * @file    : TuStickerDownloader.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 贴纸下载器
*********************************************************/
#import "TuStickerDownloader.h"

@interface TuStickerDownloader()<TuOnlineStickerDownloaderDelegate>
{
    NSMutableArray<id<TuOnlineStickerDownloaderDelegate>> *_delegateArray;
}
@end


@implementation TuStickerDownloader
+ (instancetype)shared
{
    static TuStickerDownloader *_stickerDownloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_stickerDownloader == nil)
        {
            _stickerDownloader = [[TuStickerDownloader alloc] init];
        }
    });
    
    return _stickerDownloader;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [super setDelegate:self];
        _delegateArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [super setDelegate:nil];
    [_delegateArray removeAllObjects];
}

- (void)addDelegate:(id<TuOnlineStickerDownloaderDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    
    [_delegateArray addObject:delegate];
}

- (void)removeDelegate:(id<TuOnlineStickerDownloaderDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    [_delegateArray removeObject:delegate];
}


#pragma mark - TuSDKOnlineStickerDownloaderDelegate
/**
 贴纸下载结束回调
 
 @param stickerGroupId 贴纸分组 ID
 @param progress 下载进度
 @param status 下载状态
 */
- (void)onDownloadProgressChanged:(uint64_t)stickerGroupId
                         progress:(CGFloat)progress
                    changedStatus:(TuDownloadTaskStatus)status
{
    [_delegateArray enumerateObjectsUsingBlock:^(id<TuOnlineStickerDownloaderDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [delegate onDownloadProgressChanged:stickerGroupId progress:progress changedStatus:status];
    }];
}

@end
