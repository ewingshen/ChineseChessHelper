//
//  UIView+CCFast.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/30.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CCFast)

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;

@property (nonatomic, assign) CGSize size;

- (void)relayout;

+ (UIWindow * _Nullable)keyWindow;

@end

@interface UITableViewCell (CCUtils)

+ (NSString*)cc_reuseIdentifier;

@end

@interface UICollectionViewCell (CCUtils)

+ (NSString *)cc_reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
