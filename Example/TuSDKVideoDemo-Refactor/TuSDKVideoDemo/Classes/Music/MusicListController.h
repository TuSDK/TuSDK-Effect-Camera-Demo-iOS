//
//  MusicListController.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/6/9.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MusicListController;
@protocol MusicListDelegate <NSObject>

- (void)controller:(MusicListController *)controller didSelectedAtItem:(NSString *)musicName;

@end

@interface MusicListController : UIViewController
@property (nonatomic, weak) id<MusicListDelegate> delegate;
@property (nonatomic, copy) NSString *defaultMusicName;
- (void)dismiss;
@end

@class MusicItem;
@interface MusicListCell : UITableViewCell
@property (nonatomic, strong) MusicItem *item;
@property (nonatomic, copy) void (^didSelectedBlock)(void);
@property (nonatomic, copy) void (^playerBlock)(void);

@end
NS_ASSUME_NONNULL_END
