//
//  AppDelegate.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GADFullScreenContentDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GADAppOpenAd *appOpenAd;
@property (weak, nonatomic) NSDate *loadTime;

- (void)requestAppOpenAd;
- (void)try2PresentAd;

@end

