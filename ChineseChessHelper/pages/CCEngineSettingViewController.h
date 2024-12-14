//
//  CCEngineSettingViewController.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/25.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCViewController.h"
#import "ChessDataModel.h"
#import "CCSettingBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^EngineSettingCompletion)(CCEngineSetting* _Nullable);

@interface CCEngineSettingViewController : CCSettingBaseViewController

- (instancetype)initWithPlayMode:(BOOL)isSelfPlay;

@property (nonatomic, copy, nullable) EngineSettingCompletion completion;

@end

NS_ASSUME_NONNULL_END
