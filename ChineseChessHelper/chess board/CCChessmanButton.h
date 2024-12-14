//
//  CCChessmanButton.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/30.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCChessUtil.h"
NS_ASSUME_NONNULL_BEGIN

@interface CCChessmanButton : UIButton

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CCChessmanType type;

@end

NS_ASSUME_NONNULL_END
