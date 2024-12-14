//
//  KKStoreKitHelper.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/5/24.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ProductRequestCompletion)(NSArray<SKProduct *> *);
typedef void(^PurchasesCompletion)(BOOL);

@interface KKStoreKitHelper : NSObject

@property (nonatomic, assign) BOOL adRemoved;

+ (instancetype)sharedInstance;

- (void)requestProducts:(_Nullable ProductRequestCompletion)cmp;

- (void)buyProduct:(SKProduct *)p completion:(PurchasesCompletion)cmp;

- (void)restorePurchases:(PurchasesCompletion)cmp;

@end

NS_ASSUME_NONNULL_END
