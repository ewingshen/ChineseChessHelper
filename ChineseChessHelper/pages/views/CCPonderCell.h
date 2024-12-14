//
//  CCPonderCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/4.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PikafishFullInfo;

@interface CCPonderCell : UICollectionViewCell

@property (nonatomic, copy) EmptyAction playAction;

- (void)updateScore:(NSString *)score moveList:(NSArray<NSString *> *)ml nextIsRed:(BOOL)isRed depth:(int)d;

@end

NS_ASSUME_NONNULL_END
