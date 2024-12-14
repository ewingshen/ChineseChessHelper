//
//  CCMoveListCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/2.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCMoveListCell : UITableViewCell

- (void)updateTitle:(NSString *)title move:(NSString * _Nullable)m;

- (void)updateTextColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
