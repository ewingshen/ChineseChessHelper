//
//  CCPlayerView.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayerView : UIView

- (instancetype)initWithPlayerName:(NSString *)pn teamName:(NSString *)tn isRedCamp:(BOOL)isRed;

@end

NS_ASSUME_NONNULL_END
