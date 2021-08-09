/********************************************************
 * @file    : TuBeautyPanelView.m
 * @project : TuSDKVideoDemo
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 美颜面板
*********************************************************/

#import "TuBeautyPanelView.h"
#import "TuParametersAdjustView.h"

#import "TuPanelBar.h"
#import "TuViewSlider.h"
#import "Constants.h"

#import "TuBeautyPanelConfig.h"

// 美颜列表高度
static const CGFloat kBeautyListHeight = 120;
// 美颜 tabbar 高度
static const CGFloat kBeautyTabbarHeight = 30;
// 美颜列表与参数视图间隔
static const CGFloat kBeautyListParamtersViewSpacing = 24;

@interface TuBeautyPanelView() <TuPanelTabbarDelegate,
                                ViewSliderDataSource,
                                ViewSliderDelegate,
                                TuCosmeticPanelViewDelegate,
                                TuFacePlasticPanelViewDelegate,
                                TuFaceSkinPanelViewDelegate,
                                TuParameterAdjustViewDelegate>
{
    TuFaceSkinPanelView *_skinPanelView;
    TuFacePlasticPanelView *_plasticPanelView;
    TuCosmeticPanelView *_cosmeticPanelView;
    
    TuParametersAdjustView *_paramtersAdjustView;

    SelesParameters *_skinParams;
    SelesParameters *_plasticParams;
    SelesParameters *_plasticExtraParams;
    SelesParameters *_cosmeticParams;
    
    NSString *_curPlasticCode;
    NSString *_curCosmeticCode;
    BOOL _valueChange;
}

@property (nonatomic, strong) UIVisualEffectView *effectBackgroundView; // 模糊背景
@property (nonatomic, strong) TuPanelBar *tabbar; // 面板切换标签栏
@property (nonatomic, strong) TuViewSlider *pageSlider; // 页面切换控件

@end


@implementation TuBeautyPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _paramtersAdjustView = [[TuParametersAdjustView alloc] initWithFrame:CGRectZero];
    _paramtersAdjustView.delegate = self;
    [self addSubview:_paramtersAdjustView];

    _effectBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self addSubview:_effectBackgroundView];
    
    _plasticPanelView = [[TuFacePlasticPanelView alloc] initWithFrame:CGRectZero];
    _plasticPanelView.delegate = self;
    
    _skinPanelView = [[TuFaceSkinPanelView alloc] initWithFrame:CGRectZero];
    _skinPanelView.delegate = self;
    
    _cosmeticPanelView = [[TuCosmeticPanelView alloc] initWithFrame:CGRectZero];
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


#pragma mark - ViewSliderDataSource
- (NSInteger)numberOfViewsInSlider:(TuViewSlider *)slider
{
    return 3;
}

- (UIView *)viewSlider:(TuViewSlider *)slider viewAtIndex:(NSInteger)index
{
    switch (index)
    {
    case 0:
        return _skinPanelView;
    case 1:
        return _plasticPanelView;
    default:
        return _cosmeticPanelView;
    }
}

-(void)viewSlider:(TuViewSlider *)slider didSwitchToIndex:(NSInteger)index
{
    _tabbar.selectedIndex = index;
    
    
    
    
}

- (void)panelBar:(TuPanelBar *)bar didSwitchFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    _pageSlider.selectedIndex = toIndex;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01 || ![self pointInside:point withEvent:event]) return nil;
    UIView *hitView = [super hitTest:point withEvent:event];
    // 响应子视图
    if (hitView != self && !hitView.hidden) {
        return hitView;
    }
    return nil;
}


#pragma mark - TuFaceSkinPanelViewDelegate
- (void)TuFaceSkinPanelView:(TuFaceSkinPanelView *)view enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode
{
    if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableSkin:mode:)])
    {
        _skinParams = [_delegate tuBeautyPanelView:self enableSkin:enable mode:mode];
    }
    
    _paramtersAdjustView.hidden = YES;
}

- (void)TuFaceSkinPanelView:(TuFaceSkinPanelView *)view didSelectCode:(NSString *)code
{
    if (code == nil)
    {
        _paramtersAdjustView.hidden = YES;
        return;
    }
        
    if (_skinParams == nil)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableSkin:mode:)])
        {
            _skinParams = [_delegate tuBeautyPanelView:self enableSkin:YES mode:view.faceSkinType];
        }
    }
    [self skinParamtersViewUpdate:code];
}

#pragma mark - TuFacePlasticPanelViewDelegate
- (void)tuFacePlasticPanelView:(TuFacePlasticPanelView *)view didSelectCode:(NSString *)code
{
    if (code == nil)
    {
        _paramtersAdjustView.hidden = YES;
        return;
    }
    
    if ([code isEqualToString:@"reset"])
    {
        NSString *title = NSLocalizedStringFromTable(@"tu_重置", @"VideoDemo", @"重置");
        NSString *msg = NSLocalizedStringFromTable(@"tu_将所有参数恢复默认吗？", @"VideoDemo", @"将所有参数恢复默认吗？");
        TuAlertView *alert = [TuAlertView alertWithController:[UIApplication sharedApplication].keyWindow.rootViewController title:title message:msg];
        
        [alert addAction:[TuAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_取消", @"VideoDemo", @"取消") handler:^(TuAlertAction * _Nonnull action)
        {
            self->_paramtersAdjustView.hidden = YES;
        }]];
        
        [alert addAction:[TuAlertAction actionWithTitle:NSLocalizedStringFromTable(@"tu_确定", @"VideoDemo", @"确定") handler:^(TuAlertAction * _Nonnull action)
        {
            self->_curPlasticCode = nil;
            self->_paramtersAdjustView.hidden = YES;
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(tuBeautyPanelView:enablePlastic:)])
            {
                self->_plasticParams = [self->_delegate tuBeautyPanelView:self enablePlastic:YES];
            }
            
            [self plasticParamtersViewUpdate:self->_curPlasticCode];
        }]];

        [alert show];
    }
    else
    {
        _curPlasticCode = code;

        NSArray *plasticCodes = @[kPlasticKeyCodes];
        NSArray *plasticExtraCodes = @[kPlasticKeyExtraCodes];

        if ([plasticCodes containsObject:code])
        {
            if (_plasticParams == nil)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enablePlastic:)])
                {
                    _plasticParams = [_delegate tuBeautyPanelView:self enablePlastic:YES];
                }
            }
            
            [self plasticParamtersViewUpdate:code];
        }
        else if ([plasticExtraCodes containsObject:code])
        {
            if (_plasticExtraParams == nil)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableExtraPlastic:)])
                {
                    _plasticExtraParams = [_delegate tuBeautyPanelView:self enableExtraPlastic:YES];
                }
            }
            
            [self plasticExtraParamtersViewUpdate:code];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:plasticdidSelectCode:)])
    {
        [_delegate tuBeautyPanelView:self plasticdidSelectCode:code];
    }
}

#pragma mark - TuCosmeticPanelViewDelegate
- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view paramCode:(NSString *)code value:(NSInteger)value;
{
    if (_cosmeticParams == nil)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableCosmetic:isAskPop:)])
        {
            _cosmeticParams = [_delegate tuBeautyPanelView:self enableCosmetic:YES isAskPop:YES];
        }
    }
    
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
    
    if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:cosmeticParamCode:value:)])
    {
        [_delegate tuBeautyPanelView:self cosmeticParamCode:idCode value:value];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:cosmeticParamCode:enable:)]
        && paramCode)
    {
        [_delegate tuBeautyPanelView:self cosmeticParamCode:paramCode enable:YES];
    }

    [self cosmeticParamtersViewUpdate:_curCosmeticCode];

}

- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view didSelectedLipStickType:(NSInteger)lipStickType stickerName:(NSString *)stickerName
{
    if (_cosmeticParams == nil)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableCosmetic:isAskPop:)])
        {
            _cosmeticParams = [_delegate tuBeautyPanelView:self enableCosmetic:YES isAskPop:YES];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:cosmeticParamCode:enable:)])
    {
        [_delegate tuBeautyPanelView:self cosmeticParamCode:@"lipEnable" enable:YES];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:cosmeticParamCode:value:)])
    {
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

        [_delegate tuBeautyPanelView:self cosmeticParamCode:@"lipStyle" value:lipType];
        [_delegate tuBeautyPanelView:self cosmeticParamCode:@"lipColor" value:lipColor];
    }
    
    _curCosmeticCode = @"lipOpacity";
    [self cosmeticParamtersViewUpdate:_curCosmeticCode];
}

- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view paramCode:(NSString *)code enable:(BOOL)enable
{
    _paramtersAdjustView.hidden = YES;
    
    NSString *cosmeticCode;
    if ([code isEqualToString:@"cosmeticReset"])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableCosmetic:isAskPop:)])
        {
            _cosmeticParams = [_delegate tuBeautyPanelView:self enableCosmetic:NO isAskPop:YES];
        }
    }
    else
    {
        NSString *paramCode = nil;
        if ([code isEqualToString:@"lipstick"])
        {
            paramCode = @"lipEnable";
            cosmeticCode = @"lipOpacity";
        }
        else if ([code isEqualToString:@"blush"])
        {
            paramCode = @"blushEnable";
            cosmeticCode = @"blushOpacity";
        }
        else if ([code isEqualToString:@"eyebrow"])
        {
            paramCode = @"browEnable";
            cosmeticCode = @"browOpacity";
        }
        else if ([code isEqualToString:@"eyeshadow"])
        {
            paramCode = @"eyeshadowEnable";
            cosmeticCode = @"eyeshadowOpacity";
        }
        else if ([code isEqualToString:@"eyeliner"])
        {
            paramCode = @"eyelineEnable";
            cosmeticCode = @"eyelineOpacity";
        }
        else if ([code isEqualToString:@"eyelash"])
        {
            paramCode = @"eyelashEnable";
            cosmeticCode = @"eyelashOpacity";
        }
        else if ([code isEqualToString:@"shading powder"])
        {
            paramCode = @"facialEnable";
            cosmeticCode = @"facialOpacity";
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:cosmeticParamCode:enable:)]
            && paramCode)
        {
            [_delegate tuBeautyPanelView:self cosmeticParamCode:paramCode enable:enable];
        }
        
        NSDictionary *cosmeticConfig = [TuBeautyPanelConfig defaultCosmeticValue];
        if ([cosmeticConfig objectForKey:cosmeticCode])
        {
            CGFloat defaultValue = [[cosmeticConfig objectForKey:cosmeticCode] floatValue];
            SelesParameterArg *arg = [_cosmeticParams argWithKey:cosmeticCode];
            arg.precent = defaultValue;
        }
    }
}

- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view changeCosmeticType:(NSString *)cosmeticCode
{
    if (_paramtersAdjustView.hidden)
    {
        return;
    }
    
    if ([cosmeticCode isEqualToString:@"blush"])
    {
        _curCosmeticCode = @"blushOpacity";
    }
    else if ([cosmeticCode isEqualToString:@"eyebrow"])
    {
        _curCosmeticCode = @"browOpacity";
    }
    else if ([cosmeticCode isEqualToString:@"eyeshadow"])
    {
        _curCosmeticCode = @"eyeshadowOpacity";
    }
    else if ([cosmeticCode isEqualToString:@"eyeliner"])
    {
        _curCosmeticCode = @"eyelineOpacity";
    }
    else if ([cosmeticCode isEqualToString:@"eyelash"])
    {
        _curCosmeticCode = @"eyelashOpacity";
    }
    else if ([cosmeticCode isEqualToString:@"shading powder"])
    {
        _curCosmeticCode = @"facialOpacity";
    }
    else
    {
        _curCosmeticCode = @"lipOpacity";
    }
    [self cosmeticParamtersViewUpdate:_curCosmeticCode];
}

- (void)tuCosmeticPanelView:(TuCosmeticPanelView *)view closeSliderBar:(BOOL)close
{
    _paramtersAdjustView.hidden = close;
}


#pragma mark - paramters updata
- (void)skinParamtersViewUpdate:(NSString *)code
{
    _paramtersAdjustView.hidden = NO;

    SelesParameterArg *arg = [_skinParams argWithKey:code];
    if (arg == nil)
    {
        _paramtersAdjustView.hidden = YES;
        return;
    }
    
    double percentValue = arg.precent;

    NSDictionary *effectConfig = [TuBeautyPanelConfig defaultSkinValue];
    CGFloat defaultValue = 0;
    if ([effectConfig objectForKey:code])
    {
        defaultValue = [[effectConfig objectForKey:code] floatValue];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];

    for (int skinIndex = 0; skinIndex < _skinParams.args.count; skinIndex++)
    {
        SelesParameterArg *parameterArg = _skinParams.args[skinIndex];
        if ([parameterArg.key isEqualToString:code])
        {
            NSString *paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
            paramName = NSLocalizedStringFromTable(paramName, @"TuSDKConstants", @"无需国际化");
            CGFloat paramVal = percentValue;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:code forKey:@"code"];
            [dic setObject:paramName forKey:@"name"];
            if (_valueChange)
            {
                [dic setObject:[NSNumber numberWithFloat:paramVal] forKey:@"val"];
            }
            else
            {
                [dic setObject:[NSNumber numberWithFloat:defaultValue] forKey:@"val"];
            }
            
            [dic setObject:[NSNumber numberWithFloat:defaultValue] forKey:@"defaultVal"];
            
            [params addObject:dic];
            
            [_paramtersAdjustView setParams:params];
            break;
        }
    }
}




- (void)plasticParamtersViewUpdate:(NSString *)code
{
    _paramtersAdjustView.hidden = NO;

    SelesParameterArg *arg = [_plasticParams argWithKey:code];
    if (arg == nil)
    {
        _paramtersAdjustView.hidden = YES;
        return;
    }
    
    double percentValue = arg.precent;

    NSDictionary *effectConfig = [TuBeautyPanelConfig defaultPlasticValue];
    CGFloat defaultValue = 0;
    if ([effectConfig objectForKey:code])
    {
        defaultValue = [[effectConfig objectForKey:code] floatValue];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];

    for (int plasticIndex = 0; plasticIndex < _plasticParams.args.count; plasticIndex++)
    {
        SelesParameterArg *parameterArg = _plasticParams.args[plasticIndex];
        
        if ([parameterArg.key isEqualToString:code])
        {
            NSString *paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
            paramName = NSLocalizedStringFromTable(paramName, @"TuSDKConstants", @"无需国际化");

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:code forKey:@"code"];
            [dic setObject:paramName forKey:@"name"];
            [dic setObject:[NSNumber numberWithFloat:percentValue] forKey:@"val"];
            [dic setObject:[NSNumber numberWithFloat:defaultValue] forKey:@"defaultVal"];
            //显示偏移取值范围
            if ([code isEqualToString:@"mouthWidth"]
                    || [code isEqualToString:@"archEyebrow"]
                    || [code isEqualToString:@"jawSize"]
                    || [code isEqualToString:@"eyeAngle"]
                    || [code isEqualToString:@"eyeDis"]
                    || [code isEqualToString:@"forehead"]
                    || [code isEqualToString:@"browPosition"]
                    || [code isEqualToString:@"lips"]
                    || [code isEqualToString:@"philterum"]
                    || [code isEqualToString:@"eyeHeight"])
            {
                [dic setObject:[NSNumber numberWithBool:YES] forKey:@"status"];
            }
            
            [params addObject:dic];
            
            [_paramtersAdjustView setParams:params];
            break;
        }
    }
}


- (void)plasticExtraParamtersViewUpdate:(NSString *)code
{
    _paramtersAdjustView.hidden = NO;

    SelesParameterArg *arg = [_plasticExtraParams argWithKey:code];
    if (arg == nil)
    {
        _paramtersAdjustView.hidden = YES;
        return;
    }
    
    
    NSDictionary *effectConfig = [TuBeautyPanelConfig defaultExtraPlasticValue];
    CGFloat defaultValue = 0;
    if ([effectConfig objectForKey:code])
    {
        defaultValue = [[effectConfig objectForKey:code] floatValue];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];

    for (int plasticIndex = 0; plasticIndex < _plasticExtraParams.args.count; plasticIndex++)
    {
        SelesParameterArg *parameterArg = _plasticExtraParams.args[plasticIndex];
        if ([parameterArg.key isEqualToString:code])
        {
            NSString *paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
            paramName = NSLocalizedStringFromTable(paramName, @"TuSDKConstants", @"无需国际化");

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:code forKey:@"code"];
            [dic setObject:paramName forKey:@"name"];
            [dic setObject:[NSNumber numberWithFloat:arg.precent] forKey:@"val"];

            [params addObject:dic];
            
            [_paramtersAdjustView setParams:params];
            break;
        }
    }
}

- (void)setResetCosmetic:(BOOL)resetCosmetic
{
    _paramtersAdjustView.hidden = YES;

    _resetCosmetic = resetCosmetic;
    _cosmeticPanelView.resetCosmetic = resetCosmetic;
}


- (void)cosmeticParamtersViewUpdate:(NSString *)code
{
    _paramtersAdjustView.hidden = NO;

    SelesParameterArg *arg = [_cosmeticParams argWithKey:code];
    if (arg == nil)
    {
        _paramtersAdjustView.hidden = YES;
        return;
    }
    
    NSDictionary *effectConfig = [TuBeautyPanelConfig defaultCosmeticValue];
    CGFloat defaultValue = 0;
    if ([effectConfig objectForKey:code])
    {
        defaultValue = [[effectConfig objectForKey:code] floatValue];
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];

    for (int cosmeticIndex = 0; cosmeticIndex < _cosmeticParams.args.count; cosmeticIndex++)
    {
        SelesParameterArg *parameterArg = _cosmeticParams.args[cosmeticIndex];
        
        if ([parameterArg.key isEqualToString:code])
        {
            NSString *paramName = [NSString stringWithFormat:@"lsq_filter_set_%@", code];
            paramName = NSLocalizedStringFromTable(@"tu_不透明度", @"VideoDemo", @"无需国际化");

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:code forKey:@"code"];
            [dic setObject:paramName forKey:@"name"];
            [dic setObject:[NSNumber numberWithFloat:arg.precent] forKey:@"val"];
            [dic setObject:[NSNumber numberWithFloat:defaultValue] forKey:@"defaultVal"];
            [params addObject:dic];
            
            [_paramtersAdjustView setParams:params];
            break;
        }
    }
}

- (void)ParameterAdjustView:(TuParametersAdjustView *)paramAdjustView index:(NSInteger)index val:(float)val
{
    switch (_pageSlider.selectedIndex)
    {
        case 0:
        {
            _valueChange = YES;
            if ([[paramAdjustView params] count] - 1 < index)
            {
                return;
            }
            
            NSMutableDictionary *paramDic = [paramAdjustView.params objectAtIndex:index];
            NSString *code = [paramDic objectForKey:@"code"];
            
            SelesParameterArg *skinArg = [_skinParams argWithKey:code];
            if (skinArg)
            {
                skinArg.precent = val;
            }
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
            
            
            SelesParameterArg *plasticArg = [_plasticParams argWithKey:code];
            if (plasticArg)
            {
                plasticArg.precent = val;
            }
            
            SelesParameterArg *plasticExtraArg = [_plasticExtraParams argWithKey:code];
            if (plasticExtraArg)
            {
                plasticExtraArg.precent = val;
            }
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
            
            SelesParameterArg *cosmeticArg = [_cosmeticParams argWithKey:code];
            if (cosmeticArg)
            {
                cosmeticArg.precent = val;
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)enablePlastic:(BOOL)enable
{
    if ((enable && _plasticParams == nil) || !enable)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enablePlastic:)])
        {
            _plasticParams = [_delegate tuBeautyPanelView:self enablePlastic:enable];
        }
        [_plasticPanelView deselect];
        _paramtersAdjustView.hidden = !enable;
    }
}

- (void)enableExtraPlastic:(BOOL)enable
{
    if ((enable && _plasticExtraParams == nil) || !enable)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableExtraPlastic:)])
        {
            _plasticExtraParams = [_delegate tuBeautyPanelView:self enableExtraPlastic:enable];
        }
        [_plasticPanelView deselect];
    }
}

- (void)enableCosmetic:(BOOL)enable
{
    if ((enable && _plasticExtraParams == nil) || !enable)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(tuBeautyPanelView:enableCosmetic:isAskPop:)])
        {
            _cosmeticParams = [_delegate tuBeautyPanelView:self enableCosmetic:enable isAskPop:NO];
        }
        [_cosmeticPanelView deselect];
    }
    _paramtersAdjustView.hidden = enable;
}


- (void)enableSkin:(BOOL)enable mode:(TuSkinFaceType)mode
{
    if (enable && mode == _skinPanelView.faceSkinType && _skinParams)
    {
        return;
    }
    
    [_skinPanelView enableSkin:enable mode:mode];
}

- (SelesParameters *)skinParams
{
    return _skinParams;
}


@end
