/********************************************************
 * @file    : TuCameraFilterPackage.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 滤镜读取配置
*********************************************************/


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuCameraFilterPackage : NSObject

/**
 *  相机滤镜配置
 *  @return 相机滤镜配置
 */
+ (instancetype)sharePackage;

/**
 *  滤镜标题数组
 *  @return 滤镜标题数组
 */
- (NSArray *)titleGroupsWithComics:(BOOL)isComics;

- (NSArray *)filterGroups;
/**
 *  获取滤镜组
 *  @return group 滤镜列表
 */
- (NSArray *)filterOptionsGroups;

/**
 *  获取滤镜codes组
 *  @return group 滤镜codes列表
 */
- (NSArray *)filterCodesGroups;

@end

NS_ASSUME_NONNULL_END
