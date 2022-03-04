//
//  TTBeautyPanelView.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2022/1/13.
//  Copyright © 2022 TuSDK. All rights reserved.
//

#import "TTBeautyPanelView.h"

#import "TuParametersAdjustView.h"
#import "TuPanelBar.h"
#import "TuViewSlider.h"
#import "TuBeautyPanelConfig.h"

#import "TTFacePlasticPanelView.h"
#import "TTFaceSkinPanelView.h"
#import "TTCosmeticPanelView.h"

#import "TTBeautyModel.h"
#import <TuSDKPulseCore/TuSDKPulseCore.h>
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>

// 美颜列表高度
static const CGFloat kBeautyListHeight = 120;
// 美颜 tabbar 高度
static const CGFloat kBeautyTabbarHeight = 30;
// 美颜列表与参数视图间隔
static const CGFloat kBeautyListParamtersViewSpacing = 24;

@interface TTBeautyPanelView()<TuPanelTabbarDelegate,
                                ViewSliderDataSource,
                                ViewSliderDelegate,
                                TuParameterAdjustViewDelegate,
                                TTFacePlasticPanelViewDelegate,
                                SelesParametersListener,
                                TTFaceSkinPanelViewDelegate,
                                TTCosmeticPanelViewDelegate>
{
    TuParametersAdjustView *_paramtersAdjustView;
    //微整形面板
    TTFacePlasticPanelView *_plasticPanelView;
    //美肤面板
    TTFaceSkinPanelView *_skinPanelView;
    //美妆面板
    TTCosmeticPanelView *_cosmeticPanelView;
        
    TTBeautyModel *_beautyModel;
    //当前美妆code
    NSString *_curCosmeticCode;
    
}
@property(nonatomic, strong) id<TTBeautyProtocol> beautyTarget;

@property (nonatomic, strong) UIVisualEffectView *effectBackgroundView; // 模糊背景
@property (nonatomic, strong) TuPanelBar *tabbar; // 面板切换标签栏
@property (nonatomic, strong) TuViewSlider *pageSlider; // 页面切换控件

@end

@implementation TTBeautyPanelView

#pragma mark - instance
+ (instancetype)beautyPanelWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    TTBeautyPanelView *view = [[TTBeautyPanelView alloc] initWithFrame:frame beautyTarget:beautyTarget];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame beautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    if (self = [super initWithFrame:frame]) {
        _beautyTarget = beautyTarget;
        [self initWithSubViews];
    }
    return self;
}

#pragma mark - UI
- (void)initWithSubViews
{
    _beautyModel = [[TTBeautyModel alloc] initWithBeautyTarget:_beautyTarget];
    
    //调节栏
    _paramtersAdjustView = [[TuParametersAdjustView alloc] initWithFrame:CGRectZero];
    _paramtersAdjustView.delegate = self;
    [self addSubview:_paramtersAdjustView];

    //模糊背景
    _effectBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self addSubview:_effectBackgroundView];
    //微整形面板
    _plasticPanelView = [TTFacePlasticPanelView beautyPanelWithFrame:CGRectZero beautyTarget:self.beautyTarget];
    _plasticPanelView.delegate = self;
    //美肤面板
    _skinPanelView = [TTFaceSkinPanelView beautyPanelWithFrame:CGRectZero beautyTarget:self.beautyTarget];
    _skinPanelView.delegate = self;
    //美妆面板
    _cosmeticPanelView = [TTCosmeticPanelView beautyPanelWithFrame:CGRectZero beautyTarget:self.beautyTarget];
    _cosmeticPanelView.delegate = self;
    
    
    TuPanelBar *tabbar = [[TuPanelBar alloc] initWithFrame:CGRectZero];
    [self addSubview:tabbar];
    _tabbar = tabbar;
    tabbar.trackerSize = CGSizeMake(20, 2);
    tabbar.itemSelectedColor = [UIColor whiteColor];
    tabbar.itemNormalColor = [UIColor colorWithWhite:1 alpha:.25];
    tabbar.delegate = self;
    tabbar.itemTitles = @[NSLocalizedStringFromTable(@"tu_美肤", @"VideoDemo", @"美肤"), NSLocalizedStringFromTable(@"tu_微整形", @"VideoDemo", @"微整形"), NSLocalizedStringFromTable(@"tu_美妆", @"VideoDemo", @"美妆")];
    tabbar.itemTitleFont = [UIFont systemFontOfSize:13];
    
    TuViewSlider *pageSlider = [[TuViewSlider alloc] initWithFrame:CGRectZero];
    [self addSubview:pageSlider];
    _pageSlider = pageSlider;
    pageSlider.dataSource = self;
    pageSlider.delegate = self;
    pageSlider.selectedIndex = 0;
    pageSlider.disableSlide = YES;
}

- (void)layoutSubviews {
    const CGSize size = self.bounds.size;
    CGRect safeBounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.safeAreaInsets);
    }
    
    _tabbar.itemWidth = CGRectGetWidth(safeBounds) / 3;
    const CGFloat tabbarY = CGRectGetMaxY(safeBounds) - kBeautyListHeight;
    _tabbar.frame = CGRectMake(CGRectGetMinX(safeBounds), tabbarY, CGRectGetWidth(safeBounds), kBeautyTabbarHeight);
    const CGFloat pageSliderHeight = kBeautyListHeight - kBeautyTabbarHeight;
    _pageSlider.frame = CGRectMake(CGRectGetMinX(safeBounds), CGRectGetMaxY(_tabbar.frame), CGRectGetWidth(safeBounds), pageSliderHeight);

    const CGFloat paramtersViewAvailableHeight = CGRectGetMaxY(safeBounds) - kBeautyListHeight - kBeautyListParamtersViewSpacing;
    const CGFloat paramtersViewSideMargin = 15;
    const CGFloat paramtersViewHeight = _paramtersAdjustView.contentHeight;
    _paramtersAdjustView.frame = CGRectMake(CGRectGetMinX(safeBounds) + paramtersViewSideMargin,
                                            paramtersViewAvailableHeight - paramtersViewHeight,
                                            CGRectGetWidth(_tabbar.frame) - paramtersViewSideMargin * 2,
                                            paramtersViewHeight);
    _effectBackgroundView.frame = CGRectMake(0, tabbarY, size.width, size.height - tabbarY);
}

#pragma mark - method
- (void)enablePlastic:(BOOL)enable
{
    [self.beautyTarget removeEffect:TTEffectTypePlastic];
    [_plasticPanelView deselect];
    _paramtersAdjustView.hidden = YES;
}

- (void)enableExtraPlastic:(BOOL)enable
{
    [self.beautyTarget removeEffect:TTEffectTypeReshape];
    [_plasticPanelView deselect];
    _paramtersAdjustView.hidden = YES;
}


#pragma mark - ViewSliderDataSource
- (NSInteger)numberOfViewsInSlider:(TuViewSlider *)slider
{
    return 3;
}

- (UIView *)viewSlider:(TuViewSlider *)slider viewAtIndex:(NSInteger)index
{

    switch (index) {
        case 0:
            return _skinPanelView;
            break;
        case 1:
            return _plasticPanelView;
            break;
        default:
            return _cosmeticPanelView;
            break;
    }
    
}

- (void)viewSlider:(TuViewSlider *)slider didSwitchToIndex:(NSInteger)index
{
    _tabbar.selectedIndex = index;
}

- (void)panelBar:(TuPanelBar *)bar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    _pageSlider.selectedIndex = toIndex;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    // 响应子视图
    if (hitView != self && !hitView.hidden) {
        return hitView;
    }
    return nil;
}

#pragma mark - TuParameterAdjustViewDelegate
- (void)ParameterAdjustView:(TuParametersAdjustView *)paramAdjustView index:(NSInteger)index val:(float)val;
{
    switch (_pageSlider.selectedIndex) {
        case 0:
        {
            if ([[paramAdjustView params] count] - 1 < index)
            {
                return;
            }
            NSMutableDictionary *paramDic = [paramAdjustView.params objectAtIndex:index];
            NSString *code = [paramDic objectForKey:@"code"];
            //参数值更新
            [_beautyModel updateSkinWithCode:code value:val];
            [_skinPanelView updateSkinWithCode:code value:val];
        }
            break;
        case 1:
        {
            if ([[paramAdjustView params] count] - 1 < index)
            {
                return;
            }
            
            NSMutableDictionary *paramDic = [paramAdjustView.params objectAtIndex:index];
            NSString *code = [paramDic objectForKey:@"code"];
            
            //参数值更新
            [_beautyModel updatePlasticArgsValue:code value:val];
            [_plasticPanelView updatePlasticWithCode:code value:val];
        }
            break;
        case 2:
        {
            if ([[paramAdjustView params] count] - 1 < index)
            {
                return;
            }
            
            NSMutableDictionary *paramDic = [paramAdjustView.params objectAtIndex:index];
            NSString *code = [paramDic objectForKey:@"code"];
            
            [_beautyModel setCosmeticOpacityArg:code value:val];
        }
            break;
        default:
            break;
    }
}

#pragma mark - TTFacePlasticPanelViewDelegate
/**
 * 微整形效果选中
 * @param view 面板视图
 * @param item 选中组件
 */
- (void)facePlasticPanelView:(TTFacePlasticPanelView *)view didSelectItem:(TTFacePlasticItem *)item
{
    //添加选中或重置效果
    if (item.isReset) {
        
        NSString *title = NSLocalizedStringFromTable(@"tu_重置", @"VideoDemo", @"重置");
        NSString *msg = NSLocalizedStringFromTable(@"tu_将所有参数恢复默认吗？", @"VideoDemo", @"将所有参数恢复默认吗？");
        TuAlertView *alert = [TuAlertView alertWithController:[UIApplication sharedApplication].keyWindow.rootViewController title:title message:msg];
        
        [alert addAction:[TuAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_取消", @"VideoDemo", @"取消") handler:^(TuAlertAction * _Nonnull action)
        {
            self->_paramtersAdjustView.hidden = YES;
        }]];
        
        [alert addAction:[TuAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") handler:^(TuAlertAction * _Nonnull action)
        {
            if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(removeEffect:)]) {
                self->_paramtersAdjustView.hidden = YES;
                [self.beautyTarget removeEffect:TTEffectTypePlastic];
                [self.beautyTarget removeEffect:TTEffectTypeReshape];
                //重置微整形数据
                [self->_plasticPanelView resetPlasticData];
            }
        }]];

        [alert show];
        
        
    } else {
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(addEffect:)]) {
            //非微整形改造
            if (!item.isReshape) {
                [self.beautyTarget addEffect:TTEffectTypePlastic];
                
                _beautyModel.effectType = TTEffectTypePlastic;
                [self plasticParamtersViewUpdate:item];
                
            } else {
                _beautyModel.effectType = TTEffectTypeReshape;
                [self.beautyTarget addEffect:TTEffectTypeReshape];
                [self plasticParamtersViewUpdate:item];
            }
        }
    }
}

/**
 * 微整形参数更新
 * @param item 微整形组件
 */
- (void)plasticParamtersViewUpdate:(TTFacePlasticItem *)item
{
    //是否隐藏微整形调节栏视图
    _paramtersAdjustView.hidden = item.isReset;
    
    //根据微整形code获取对应参数
    if (item.isReshape) {
        
        NSMutableArray *params = [_beautyModel plasticExtraParamtersViewUpdate:item];
        [_paramtersAdjustView setParams:params];
        
    } else {
        
        NSMutableArray *params = [_beautyModel plasticParamtersViewUpdate:item];
        [_paramtersAdjustView setParams:params];
        
    }
}

#pragma mark - TTFaceSkinPanelViewDelegate
/**
 * 美肤效果选中
 * @param view 面板视图
 * @param item 选中组件
 */
- (void)faceSkinPanelView:(TTFaceSkinPanelView *)view didSelectItem:(TTFaceSkinItem *)item;
{
    //重置则隐藏
    _paramtersAdjustView.hidden = item.isReset;
    //添加选中或重置效果
    if (item.isReset)
    {
        //重置
        [self.beautyTarget resetEffect:TTEffectTypeSkin];
    }
    else
    {
        if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setSkinStyle:)]) {
            [self.beautyTarget setSkinStyle:item.skinType];
            [self skinParamtersViewUpdate:item];
        }
    }
}

/**
 * 设置美肤效果
 * @param view 面板视图
 * @param skinType 美肤算法
 */
- (void)faceSkinPanelView:(TTFaceSkinPanelView *)view setSkinType:(TTSkinStyle)skinType;
{
    if (self.beautyTarget && [self.beautyTarget respondsToSelector:@selector(setSkinStyle:)]) {
        [self.beautyTarget setSkinStyle:skinType];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(beautyPanelView:didSelectSkinType:)]) {
        [self.delegate beautyPanelView:self didSelectSkinType:skinType];
    }
}

/**
 * 美肤参数更新
 * @param item 美肤组件
 */
- (void)skinParamtersViewUpdate:(TTFaceSkinItem *)item
{
    NSMutableArray *params = [_beautyModel skinParamtersViewUpdate:item];
    [_paramtersAdjustView setParams:params];
}

#pragma mark - TTCosmeticPanelViewDelegate
- (void)cosmeticPanelView:(TTCosmeticPanelView *)view code:(NSString *)code enable:(BOOL)enable;
{
    _paramtersAdjustView.hidden = YES;
    //重置
    if ([code isEqualToString:@"cosmeticReset"]) {
        //清除所有美妆效果
        [self resetAllCosmeticAction];
    } else {
        //美妆开关
        [_beautyModel setCosmeticEnable:code enable:enable];
        [_beautyModel setCosmeticParamsArgKeyWithCode:code precent:NO];
    }
}

- (void)cosmeticPanelView:(TTCosmeticPanelView *)view changeCosmeticType:(NSString *)cosmeticCode;
{
    if (_paramtersAdjustView.hidden) return;
    
    //美妆不透明度参数
    _curCosmeticCode = [_beautyModel cosmeticOpacityCodeWithCode:cosmeticCode];
    //美妆参数面板
    [_beautyModel cosmeticParamtersViewHidden:_curCosmeticCode];
    NSMutableArray *cosmeticParams = [_beautyModel cosmeticParamtersViewUpdate:_curCosmeticCode];
    [_paramtersAdjustView setParams:cosmeticParams];
}

- (void)cosmeticPanelView:(TTCosmeticPanelView *)view code:(NSString *)code value:(NSInteger)value;
{
    NSString *paramCode = nil;
    NSString *idCode = nil;
    if ([code isEqualToString:@"blush"])
    {
        paramCode = @"blushEnable";
        idCode = @"blushId";
        _curCosmeticCode = @"blushOpacity";

    }
    else if ([code isEqualToString:@"eyebrow"])
    {
        paramCode = @"browEnable";
        idCode = @"browId";
        _curCosmeticCode = @"browOpacity";
    }
    else if ([code isEqualToString:@"eyeshadow"])
    {
        paramCode = @"eyeshadowEnable";
        idCode = @"eyeshadowId";
        _curCosmeticCode = @"eyeshadowOpacity";
    }
    else if ([code isEqualToString:@"eyeliner"])
    {
        paramCode = @"eyelineEnable";
        idCode = @"eyelineId";
        _curCosmeticCode = @"eyelineOpacity";
    }
    else if ([code isEqualToString:@"eyelash"])
    {
        paramCode = @"eyelashEnable";
        idCode = @"eyelashId";
        _curCosmeticCode = @"eyelashOpacity";
    }
    else if ([code isEqualToString:@"shading powder"])
    {
        paramCode = @"facialEnable";
        idCode = @"facialId";
        _curCosmeticCode = @"facialOpacity";
    }
    
    //设置美妆开关
    [_beautyModel setCosmeticEnable:code enable:YES];
    //设置美妆贴纸ID
    [_beautyModel setCosmeticIDWithStyle:idCode stickerID:value];
    

    NSInteger stickerId = -1;

    TuStickerGroup *stickerGroup = [[TuStickerLocalPackage package] groupWithGroupID:value];
    if (stickerGroup && stickerGroup.stickers)
    {
        TuSticker *sticker = stickerGroup.stickers[0];
        stickerId = sticker.idt;
    }

    if (stickerId == -1)
    {
        return;
    }
    [_beautyModel setCosmeticParamsArgKeyWithCode:code precent:1];
    [_beautyModel setCosmeticParamsArgKeyWithCode:idCode stickerId:stickerId];
    NSMutableArray *cosmeticParams = [_beautyModel cosmeticParamtersViewUpdate:_curCosmeticCode];
    [_paramtersAdjustView setParams:cosmeticParams];
    _paramtersAdjustView.hidden = cosmeticParams.count == 0;
}

//关闭调节栏
- (void)cosmeticPanelView:(TTCosmeticPanelView *)view closeSliderBar:(BOOL)close;
{
    _paramtersAdjustView.hidden = close;
}

- (void)cosmeticPanelView:(TTCosmeticPanelView *)view didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName;
{
    //设置口红开关
    [_beautyModel setCosmeticEnable:@"lipstick" enable:YES];
    [_beautyModel setCosmeticParamsArgKeyWithCode:@"lipstick" precent:1];
    
    CosmeticLipType lipType = COSMETIC_SHUIRUN_TYPE;
    switch (lipStickType)
    {
    case 1:  // 滋润
        lipType = COSMETIC_ZIRUN_TYPE;
        break;
    case 2:  // 雾面
        lipType = COSMETIC_WUMIAN_TYPE;
        break;
    default: // 水润
        lipType = COSMETIC_SHUIRUN_TYPE;
        break;
    }
    int lipColor = [TuBeautyPanelConfig stickLipParamByStickerName:stickerName];
    [_beautyModel setCosmeticParamsArgKeyWithCode:@"lipStyle" stickerId:lipType];
    [_beautyModel setCosmeticParamsArgKeyWithCode:@"lipColor" stickerId:lipColor];
    
    //设置
    [_beautyModel setCosmeticIDWithStyle:@"lipStyle" stickerID:lipType];
    [_beautyModel setCosmeticIDWithStyle:@"lipColor" stickerID:lipColor];
    
    _curCosmeticCode = @"lipOpacity";
    NSMutableArray *cosmeticParams = [_beautyModel cosmeticParamtersViewUpdate:_curCosmeticCode];
    [_paramtersAdjustView setParams:cosmeticParams];
    _paramtersAdjustView.hidden = cosmeticParams.count == 0;
}


//重置所有美妆效果
- (void)resetAllCosmeticAction
{
    typeof(self)weakSelf = self;
    NSString *title = NSLocalizedStringFromTable(@"tu_美妆", @"VideoDemo", @"美妆");
    NSString *msg = NSLocalizedStringFromTable(@"tu_确定删除所有美妆效果?", @"VideoDemo", @"美妆");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LSQString(@"lsq_nav_cancel", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confimAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (weakSelf.beautyTarget && [weakSelf.beautyTarget respondsToSelector:@selector(removeEffect:)]) {
            [weakSelf.beautyTarget removeEffect:TTEffectTypeCosmetic];
        }
        weakSelf->_paramtersAdjustView.hidden = YES;
        weakSelf->_cosmeticPanelView.resetCosmetic = YES;
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:confimAction];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}

/// 获取当前的控制器
- (UIViewController *)currentViewController
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    return vc;
}

@end
