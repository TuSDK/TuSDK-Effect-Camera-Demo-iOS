//
//  AppDelegate.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/6/15.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "AppDelegate.h"
#import "TuSDKFramework.h"
#import <Bugly/Bugly.h>
#import <TuSDKPulse/TUPEngine.h>

#ifdef DEBUG
//#import <DoraemonKit/DoraemonManager.h>
#endif
#import "TTViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /**
     *  启动Bugly收集错误报告
     */
    [Bugly startWithAppId:@"66806f5e0e"];
    
    // 可选: 设置日志输出级别 (默认不输出)
    [TUCCore setLogLevel:TuLogLevelDEBUG];
    
    /**
     *  初始化SDK，应用密钥是您的应用在 TuSDK 的唯一标识符。每个应用的包名(Bundle Identifier)、密钥、资源包(滤镜、贴纸等)三者需要匹配，否则将会报错。
     *
     *  @param appkey 应用秘钥 (请前往 https://tutucloud.com 申请秘钥)
     */
    
    // Attention ！！！！！！
    // ********************** 更换包名和秘钥之后，一定要去控制台打包替换资源文件 **********************
    /**
     *  指定开发模式,需要与lsq_tusdk_configs.json中masters.key匹配， 如果找不到devType将默认读取master字段
     *  如果一个应用对应多个包名，则可以使用这种方式来进行集成调试。
     */
    // [TUCCore initSdkWithAppKey:@"828d700d182dd469-04-ewdjn1" devType:@"debug"];
    [TUCCore initSdkWithAppKey:@"829a2f7c3672a2fa-04-ewdjn1"];
    [TUPEngine Init:nil];

    
    // 设置弹框时，背景按钮不可点击
    [TuPopupProgress setDefaultMaskType:TuSDKProgressHUDMaskTypeClear];
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    
    self.window.rootViewController = [[TTViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    // 添加文件引入
    //#import <TuSDKPulseCore/TuSDKPulseCore.h>
    //#import <TuSDKPulse/TUPEngine.h>
    // 版本号输出
    NSLog(@"TuSDK.framework 的版本号 : %@",lsqPulseSDKVersion);
#ifdef DEBUG
//    [[DoraemonManager shareInstance] install];
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationwillTerminateAction" object:nil];
    [TUPEngine Terminate];
}


@end
