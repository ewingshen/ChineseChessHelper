//
//  CCViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/2.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCViewController.h"
#import "MBProgressHUD.h"
#import "Toast.h"

@interface CCViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation CCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setBackgroundImage:[UIImage imageNamed:@"cc_bg"]];
        
    [self setLeftButton:nil image:[UIImage imageNamed:@"back"] target:self action:@selector(backAction)].frame = CGRectMake(0, 0, 24, 44);
}

- (UIButton *)setRightButton:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)aSelector
{
    return [self setButton:title image:image target:target action:aSelector leftOrRight:NO];
}

- (UIButton *)setLeftButton:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)aSelector
{
    return [self setButton:title image:image target:target action:aSelector leftOrRight:YES];
}

- (UIButton *)setButton:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)aSelector leftOrRight:(BOOL)left
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
    }
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:target action:aSelector forControlEvents:UIControlEventTouchUpInside];

    if (left) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    
    return btn;
}

- (UIBarButtonItem *)barButtonItem:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
    }
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setBackgroundImage:(UIImage *)image
{
    if (!self.backgroundImageView) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundImageView.clipsToBounds = YES;
        self.backgroundImageView.alpha = 0.618;
        [self.view insertSubview:self.backgroundImageView atIndex:0];
    }
    
    self.backgroundImageView.image = image;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.backgroundImageView.frame = self.view.bounds;
}

- (void)backAction
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)showHUD:(NSString *)title
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = title;
}

- (void)hideHUD
{
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
}

- (void)toast:(NSString *)msg
{
    [self.view makeToast:msg];
}

- (void)presentVC:(UIViewController *)vc from:(UIView * _Nullable)sourceView
{
    UIPopoverPresentationController *pop = [vc popoverPresentationController];
    if (pop && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        pop.sourceView = sourceView;
        pop.sourceRect = sourceView.bounds;
    }
    
    [self presentViewController:vc animated:true completion:NULL];
}

- (void)dealloc
{
    DLog(@"%@ deinit.", self);
}
@end
