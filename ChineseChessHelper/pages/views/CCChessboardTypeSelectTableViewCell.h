//
//  CCChessboardTypeSelectTableViewCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/10.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCChessboardTypeSelectTableViewCell : UITableViewCell

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) NSArray<NSString *> *imageNames;

@end

NS_ASSUME_NONNULL_END
