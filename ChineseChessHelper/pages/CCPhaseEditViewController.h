//
//  CCPhaseEditViewController.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/2.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CCPhaseEditViewControllerDelegate;

@interface CCPhaseEditViewController : CCViewController

- (instancetype)initWithInitialPhase:(NSData *)ip;

@property (nonatomic, weak) id<CCPhaseEditViewControllerDelegate> delegate;

@end

@protocol CCPhaseEditViewControllerDelegate <NSObject>

- (void)phaseEditViewController:(CCPhaseEditViewController *)viewController didFinished:(UIImage *)boardImage phase:(NSData *)phase;

@end

NS_ASSUME_NONNULL_END
