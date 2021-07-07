/********************************************************
 * @file    : Constants.h
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 通用参数配置文件
*********************************************************/

#import <UIKit/UIKit.h>
#import "TuSDKFramework.h"

// 注意事项: 以 s 结尾的宏都是一些散列值，使用时需进行封包；而以 Array、Dictionary 结尾的则是可直接使用的数组和字典。


// 新相机滤镜的 filterCode - 3.5.6
#define kCameraNormalFilterCodes @"Sharp_Video",@"Scenery_Video", @"Food_Video", @"Portrait_Video"

// 录制相机漫画滤镜 filterCode
#define kCameraComicsFilterCodes @"CHComics_Video", @"USComics_Video", @"JPComics_Video", @"Lightcolor_Video", @"Ink_Video", @"Monochrome_Video"
// 美颜滤镜参数名称
#define kBeautySkinKeys @"skin_default",@"smoothing",@"whitening", @"sharpen"
#define kNaturalBeautySkinKeys @"skin_default",@"smoothing",@"whitening", @"ruddy"
#define TuBeautySkinKeys @"skin_beauty",@"smoothing",@"whitening", @"sharpen"
#define TuSkipBeautySkinKeys @"smoothing",@"whitening", @"sharpen", @"ruddy"


// 美型（微整形）滤镜参数名称 - 3.6.1
#define kPlasticKeyCodes @"eyeSize", @"chinSize", @"cheekNarrow", @"smallFace", @"noseSize", @"noseHeight", @"mouthWidth", @"lips", @"philterum", @"archEyebrow", @"browPosition", @"jawSize", @"cheekLowBoneNarrow", @"eyeAngle", @"eyeInnerConer", @"eyeOuterConer", @"eyeDis", @"eyeHeight", @"forehead", @"cheekBoneNarrow"
#define kPlasticKeyExtraCodes @"eyelid", @"eyemazing", @"whitenTeeth", @"eyeDetail", @"removePouch", @"removeWrinkles"


typedef NS_ENUM(NSInteger, TuJoinerDirection) {
    TuJoinerDirectionHorizontal, //左右
    TuJoinerDirectionVertical, // 上下
    TuJoinerDirectionCross // 抢镜
};





