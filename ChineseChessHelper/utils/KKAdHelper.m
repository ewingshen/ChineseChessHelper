//
//  KKAdHelper.m
//  SlidePuzzle
//
//  Created by ewing on 2020/1/3.
//  Copyright © 2020 ewingshen. All rights reserved.
//

#import "KKAdHelper.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "UIView+CCFast.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface KKAdHelper () <GADBannerViewDelegate>
@property (nonatomic, strong) GADBannerView *banner;

@property (nonatomic, strong) GADRewardedAd *rewardedAd;
@property (nonatomic, weak) UIViewController *rewardedViewController;
@property (nonatomic, strong) KKRewardAdCompletion earnedBlock;
@property (nonatomic, assign) BOOL loading;

@end

@implementation KKAdHelper
+ (instancetype)sharedInstance
{
    static KKAdHelper *singletion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletion = [[KKAdHelper alloc] init];
    });
    return singletion;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)initSDK
{
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[kGADSimulatorID];
}

- (void)loadBannerAd:(NSString *)adUnitID rootViewController:(nonnull UIViewController *)vc
{
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.banner = [[GADBannerView alloc] initWithAdSize:GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(SCREEN_WIDTH)];
                self.banner.adUnitID = adUnitID;
                self.banner.rootViewController = vc;
                self.banner.delegate = self;
                
                GADRequest *request = [GADRequest request];
                [self.banner loadRequest:request];
            });
        }];
    } else {
        self.banner = [[GADBannerView alloc] initWithAdSize:GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(SCREEN_WIDTH)];
        self.banner.adUnitID = adUnitID;
        self.banner.rootViewController = vc;
        self.banner.delegate = self;
        
        GADRequest *request = [GADRequest request];
        [self.banner loadRequest:request];
    }
}

- (void)loadRewardAd:(NSString *)adUnitID presentViewController:(UIViewController *)vc completionBlock:(KKRewardAdCompletion)completion
{
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            self.rewardedViewController = vc;
            self.earnedBlock = completion;
            self.loading = YES;
            [GADRewardedAd loadWithAdUnitID:adUnitID request:[GADRequest request] completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
                self.loading = NO;
                self.rewardedAd = rewardedAd;
            }];
        }];
    } else {
        self.rewardedViewController = vc;
        self.earnedBlock = completion;
        self.loading = YES;
        [GADRewardedAd loadWithAdUnitID:adUnitID request:[GADRequest request] completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            self.loading = NO;
            self.rewardedAd = rewardedAd;
        }];
    }
}

- (void)showRewardAd
{
    if (self.rewardedAd && self.rewardedViewController) {
        [self.rewardedAd presentFromRootViewController:self.rewardedViewController userDidEarnRewardHandler:^{
            
        }];
    } else {
        //
    }
}

- (void)bringBannerView
{
    [self.banner.superview bringSubviewToFront:self.banner];
}

- (void)removeAds
{
    [self.banner removeFromSuperview];
    self.banner = nil;
}

+ (CGSize)ADSize {
    return GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(SCREEN_WIDTH).size;
}
#pragma mark - GADRewardedAdDelegate
- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward
{
    if (self.rewardedViewController && self.earnedBlock) {
        self.earnedBlock(YES);
    }
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", nil) message:NSLocalizedString(@"Can't show rewarded ad", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [controller addAction:ok];
    
    [self.rewardedViewController presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - GADBannerViewDelegate
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    UIWindow *w = [UIView keyWindow];
    if (!w) return;
    [w addSubview:bannerView];
    bannerView.alpha = 0;
    [bannerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(w);
        make.bottom.equalTo(w).inset(w.safeAreaInsets.bottom);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        bannerView.alpha = 1;
    }];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    [UIView animateWithDuration:0.25 animations:^{
        bannerView.alpha = 0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GADRequest *request = [GADRequest request];
        [self.banner loadRequest:request];
    });
}

@end
