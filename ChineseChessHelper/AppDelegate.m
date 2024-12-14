//
//  AppDelegate.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "AppDelegate.h"
#import "KKAdHelper.h"
#import "ChessCore/CCChesscore.h"
#import "CCSettingsViewController.h"
#import "KKStoreKitHelper.h"
#import "Toast.h"
@import FirebaseCore;
@import FirebaseAnalytics;
@import FirebaseCrashlytics;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (@available(iOS 13.0, *)) {
        _window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    [[KKAdHelper sharedInstance] initSDK];
    
    [CSToastManager setDefaultDuration:3];
    [CSToastManager setDefaultPosition:CSToastPositionCenter];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *a = [UINavigationBarAppearance new];
        [a configureWithOpaqueBackground];
        a.backgroundColor = [UIColor whiteColor];
        [UINavigationBar new].standardAppearance = a;
        UINavigationBar.appearance.scrollEdgeAppearance = a;
    }
    
    [FIRApp configure];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (![[KKStoreKitHelper sharedInstance] adRemoved] && ![self purchasing]) {
        [self try2PresentAd];
    }
}

- (void)requestAppOpenAd
{
    self.appOpenAd = nil;
    [GADAppOpenAd loadWithAdUnitID:@""
                           request:[GADRequest request]
                       orientation:UIInterfaceOrientationPortrait
                 completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
        if (error) {
//            NSLog(@"Failed to load app open ad: %@", error);
            return;
        }
        self.appOpenAd = appOpenAd;
        self.appOpenAd.fullScreenContentDelegate = self;
        self.loadTime = [NSDate date];
    }];
}

- (void)try2PresentAd
{
    if (self.appOpenAd && [self wasLoadTimeLessThanNHoursAgo:4]) {
        UIViewController *rootController = self.window.rootViewController;
        [self.appOpenAd presentFromRootViewController:rootController];
      } else {
        // If you don't have an ad ready, request one.
        [self requestAppOpenAd];
      }
}

- (BOOL)wasLoadTimeLessThanNHoursAgo:(int)n 
{
    NSDate *now = [NSDate date];
    NSTimeInterval timeIntervalBetweenNowAndLoadTime = [now timeIntervalSinceDate:self.loadTime];
    double secondsPerHour = 3600.0;
    double intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour;
    return intervalInHours < n;
}

- (BOOL)purchasing 
{
    UINavigationController *nav = self.window.rootViewController;
    if (![nav isKindOfClass:[UINavigationController class]]) {
        return NO;
    }
    
    CCSettingsViewController *svc = nav.topViewController;
    if (![svc isKindOfClass:[CCSettingsViewController class]]) {
        return NO;
    }
    
    return svc.purchasing;
}

#pragma mark - GADFullScreenContentDelegate

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [self requestAppOpenAd];
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self requestAppOpenAd];
}

@end
