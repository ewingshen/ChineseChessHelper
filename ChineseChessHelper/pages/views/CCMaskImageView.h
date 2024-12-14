//
//  CCMaskImageView.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/10.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCMaskImageView : UIImageView

@property (nonatomic, strong) UIColor *maskColor;

@property (nonatomic, assign) BOOL showMask;

@end

NS_ASSUME_NONNULL_END
