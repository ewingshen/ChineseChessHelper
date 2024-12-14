//
//  CCViewController.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/2.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCViewController : UIViewController

- (void)setBackgroundImage:(UIImage *)image;

- (UIButton *)setLeftButton:(NSString * _Nullable)title image:(UIImage * _Nullable)image target:(nullable id)target action:(nullable SEL)aSelector;
- (UIButton *)setRightButton:(NSString * _Nullable)title image:(UIImage * _Nullable)image target:(nullable id)target action:(nullable SEL)aSelector;

- (void)backAction;

- (void)showHUD:(NSString *)title;
- (void)hideHUD;
- (void)toast:(NSString *)msg;

- (void)presentVC:(UIViewController *)vc from:(UIView * _Nullable)sourceView;

- (UIBarButtonItem *)barButtonItem:(NSString *)title image:(UIImage * _Nullable)image target:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
