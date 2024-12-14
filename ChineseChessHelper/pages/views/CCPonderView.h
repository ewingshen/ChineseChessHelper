//
//  CCPonderView.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/2.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PikafishModels.h"

NS_ASSUME_NONNULL_BEGIN

@class CCPonderView;

@protocol CCPonderViewDelegate <NSObject>

- (void)ponderView:(CCPonderView *)pv didSelectPV:(PikafishFullInfo*)info;

@end

@interface CCPonderView : UIView

@property (nonatomic, weak) id<CCPonderViewDelegate> delegate;
@property (nonatomic, strong, nullable) NSData *initialPhase;
@property (nonatomic, copy) NSString *moves;
@property (nonatomic, assign) CGSize boardSize;

- (void)updateInfo:(PikafishFullInfo *)info;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
