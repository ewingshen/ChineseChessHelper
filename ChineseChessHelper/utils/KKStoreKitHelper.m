//
//  KKStoreKitHelper.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/5/24.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "KKStoreKitHelper.h"

@interface KKStoreKitHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *callbacks;

@property (nonatomic, strong) PurchasesCompletion pc;

@property (nonatomic, strong) NSNumber *ar;

@end

@implementation KKStoreKitHelper

+ (instancetype)sharedInstance
{
    static KKStoreKitHelper *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[KKStoreKitHelper alloc] init];
    });
    
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        self.callbacks = [NSMutableArray array];
    }
    return self;
}

- (void)requestProducts:(ProductRequestCompletion)cmp
{
    if (cmp != NULL) {
        [self.callbacks addObject:cmp];
    }
    
    if (self.products.count > 0) {
        if (cmp != NULL) {
            cmp(self.products);
        }
    } else if (!self.productsRequest) {
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"1000"]];
        self.productsRequest.delegate = self;
        [self.productsRequest start];
    }
}

- (void)buyProduct:(SKProduct *)p completion:(PurchasesCompletion)cmp
{
    self.pc = cmp;
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchases:(PurchasesCompletion)cmp
{
    self.pc = cmp;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)setAdRemoved:(BOOL)adRemoved
{
    self.ar = @(adRemoved);
    
    [[NSUserDefaults standardUserDefaults] setObject:self.ar forKey:@"removed_ad_already"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)adRemoved
{
    if (!self.ar) {
        self.ar = [[NSUserDefaults standardUserDefaults] objectForKey:@"removed_ad_already"];
    }
    
    return [self.ar boolValue];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // 处理产品信息响应
    self.products = [response.products mutableCopy];
    self.productsRequest = nil;
    
    DLog(@"Products: %@", self.products);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ProductRequestCompletion cb in self.callbacks) {
            cb(self.products);
        }
    });
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    // 处理交易状态更新
    DLog(@"transactions: %@", transactions);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchasing:
                    // 购买中
                    DLog(@"购买中...");
                    break;
                case SKPaymentTransactionStatePurchased:
                    // 购买成功
                    DLog(@"购买成功！");
                    // 在这里可以处理购买成功后的逻辑，如解锁功能或提供服务
                    [queue finishTransaction:transaction];
                    
                    if (self.pc) {
                        self.pc(YES);
                    }
                    break;
                case SKPaymentTransactionStateFailed:
                    // 购买失败
                    DLog(@"购买失败：%@", transaction.error.localizedDescription);
                    // 在这里可以处理购买失败后的逻辑，如提示用户或提供其他购买选项
                    [queue finishTransaction:transaction];
                    
                    if (self.pc) {
                        self.pc(NO);
                    }
                    break;
                case SKPaymentTransactionStateRestored:
                    // 恢复购买
                    DLog(@"恢复购买成功！");
                    // 在这里可以处理恢复购买成功后的逻辑，如解锁功能或提供服务
                    [queue finishTransaction:transaction];
                    
                    if (self.pc) {
                        self.pc(YES);
                    }
                    break;
                default:
                    break;
            }
        }
    });
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    DLog(@"");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    DLog(@"restore failed with error %@", error);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.pc) {
            self.pc(NO);
        }
    });
}
@end
