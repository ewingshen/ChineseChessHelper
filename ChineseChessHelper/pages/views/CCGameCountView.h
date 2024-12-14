//
//  CCGameCountView.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/24.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCGameCountView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;

- (void)updateWin:(int)wc tie:(int)tc lose:(int)lc;

@end

NS_ASSUME_NONNULL_END
