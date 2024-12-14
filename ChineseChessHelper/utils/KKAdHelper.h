//
//  KKAdHelper.h
//  SlidePuzzle
//
//  Created by ewing on 2020/1/3.
//  Copyright © 2020 ewingshen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KKRewardAdCompletion)(BOOL);

@interface KKAdHelper : NSObject

+ (instancetype)sharedInstance;

- (void)initSDK;

- (void)loadBannerAd:(NSString *)adUnitID rootViewController:(UIViewController *)vc;

- (void)loadRewardAd:(NSString *)adUnitID presentViewController:(UIViewController *)vc completionBlock:(KKRewardAdCompletion)completion;
- (void)showRewardAd;

- (void)bringBannerView;

- (void)removeAds;

+ (CGSize)ADSize;

@end

NS_ASSUME_NONNULL_END
