//
//  CCPlayViewController.h
//  ChineseChessHelper
//
//  Created by ewing on 2023/10/27.
//  Copyright © 2023 sheehangame. All rights reserved.
//

#import "CCViewController.h"
#import "ChessDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayViewController : CCViewController

- (instancetype)initWithEngine:(CCEngineSetting *)engine moveList:(NSString * _Nullable)ml;

@end

NS_ASSUME_NONNULL_END
