//
//  CCSettingsViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/10.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCSettingsViewController.h"
#import "CCChessboardTypeSelectTableViewCell.h"
#import "CCChesscore.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <UIView+Toast.h>
#import "KKStoreKitHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "CCSettingItemTableViewCell.h"
#import "UIView+CCFast.h"

@interface CCSettingsViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SKProduct *adRemoveProduct;

@property (nonatomic, strong) CCSettingItem *analyzaDepthSettingItem;

@property (nonatomic, assign) BOOL purchasing;

@end

@implementation CCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.analyzaDepthSettingItem = [CCSettingItem new];
    self.analyzaDepthSettingItem.detailType = CCSettingItemDetailType_Slider;
    self.analyzaDepthSettingItem.sliderMax = 30;
    self.analyzaDepthSettingItem.sliderMin = 1;
    self.analyzaDepthSettingItem.title = @"电脑分析深度".localized;
    self.analyzaDepthSettingItem.roundSliderValue = YES;
    self.analyzaDepthSettingItem.sliderValue = [[CCChesscore core] analyzaDepth];
    weakify(self)
    self.analyzaDepthSettingItem.valueChangedAction = ^{
        [CCChesscore core].analyzaDepth = weak_self.analyzaDepthSettingItem.sliderValue;
    };
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
    [self.tableView registerClass:[CCChessboardTypeSelectTableViewCell class] forCellReuseIdentifier:@"chessboard_type"];
    [self.tableView registerClass:[CCSettingItemTableViewCell class] forCellReuseIdentifier:CCSettingItemTableViewCell.cc_reuseIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    self.title = @"设置".localized;
    
    if (![KKStoreKitHelper sharedInstance].adRemoved) {
        __weak typeof(self) weakSelf = self;
        [[KKStoreKitHelper sharedInstance] requestProducts:^(NSArray<SKProduct *> * producsts) {
            if (weakSelf == nil) return;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (producsts.count > 0) {
                strongSelf.adRemoveProduct = producsts.firstObject;
                [strongSelf.tableView reloadData];
            }
        }];
    }
}

#pragma mark - UITableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2 + (self.adRemoveProduct != nil ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 120;
    }
    
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"棋盘样式".localized;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        CCChessboardTypeSelectTableViewCell *cell = (CCChessboardTypeSelectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chessboard_type" forIndexPath:indexPath];
        cell.imageNames = @[@"boardImage_0", @"boardImage_1", @"boardImage_2"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        CCSettingItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCSettingItemTableViewCell.cc_reuseIdentifier forIndexPath:indexPath];
        [cell bind:self.analyzaDepthSettingItem];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"normal_cell"];
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell.textLabel.text = @"棋局自动播放间隔".localized;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [CCChesscore core].autoPlayDelay, @"秒".localized];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = @"意见反馈".localized;
        cell.detailTextLabel.text = @"shenkuikui@gmail.com";
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"开源声明".localized;
        cell.detailTextLabel.text = @"GPL v3.0";
    } else if (indexPath.section == 2 && self.adRemoveProduct != nil) {
        cell.textLabel.text = @"去广告".localized;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = self.adRemoveProduct.priceLocale;
        cell.detailTextLabel.text = [formatter stringFromNumber:self.adRemoveProduct.price];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自动播放间隔".localized message:@"单位：秒。最小间隔：0.5秒".localized preferredStyle:UIAlertControllerStyleAlert];
        weakify(alert)
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        weakify(self)
        [alert addAction:[UIAlertAction actionWithTitle:@"确定".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *text = weak_alert.textFields.firstObject.text;
            if (text.length <= 0) return;
            CGFloat delay = [text floatValue];
            if (delay < 0.5) {
                delay = 0.5;
            }
            
            [[CCChesscore core] setAutoPlayDelay:delay];
            
            [weak_self.tableView reloadData];
        }]];
        
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
            [mailVC setSubject:@"意见反馈".localized];
            [mailVC setToRecipients:@[@"shenkuikui@gmail.com"]];
            mailVC.delegate = self;
            
            [self.navigationController presentViewController:mailVC animated:YES completion:NULL];
        } else {
            [[UIPasteboard generalPasteboard] setString:@"shenkuikui@gmail.com"];
            
            [self.view makeToast:@"邮箱已复制到剪切板".localized duration:1.5 position:CSToastPositionCenter];
        }
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"开源声明".localized message:@"项目开源地址：https://github.com/ewingshen/ChineseChessHelper".localized preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:true completion:NULL];
    } else if (indexPath.section == 2 && self.adRemoveProduct != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"购买".localized message:@"去除App中的广告".localized preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        weakify(self)
        [alert addAction:[UIAlertAction actionWithTitle:@"恢复购买".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (!weak_self) return;
            strongify(self)
            strong_self.purchasing = YES;
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strong_self.view animated:true];
            hud.label.text = @"恢复购买中...".localized;
            [hud hideAnimated:true afterDelay:60];
            
            __weak typeof(self) weakSelf = strong_self;
            [[KKStoreKitHelper sharedInstance] restorePurchases:^(BOOL succ) {
                if (weakSelf == NULL) return;
                __strong typeof(weakSelf) sself = weakSelf;
                [MBProgressHUD hideHUDForView:sself.view animated:true];
                
                if (succ) {
                    [sself.view makeToast:@"恢复购买成功".localized duration:2.5 position:CSToastPositionCenter];
                    [[KKStoreKitHelper sharedInstance] setAdRemoved:YES];
                    [[KKAdHelper sharedInstance] removeAds];
                    sself.adRemoveProduct = nil;
                    [sself.tableView reloadData];
                } else {
                    [sself.view makeToast:@"恢复购买失败".localized duration:2.5 position:CSToastPositionCenter];
                }
                
                sself.purchasing = NO;
            }];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"购买".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (!weak_self) return;
            strongify(self)
            strong_self.purchasing = YES;
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strong_self.view animated:true];
            hud.label.text = @"购买中...".localized;
            [hud hideAnimated:true afterDelay:60];
            
            __weak typeof(self) weakSelf = strong_self;
            [[KKStoreKitHelper sharedInstance] buyProduct:strong_self.adRemoveProduct completion:^(BOOL succ) {
                if (weakSelf == NULL) return;
                __strong typeof(weakSelf) sself = weakSelf;
                [MBProgressHUD hideHUDForView:sself.view animated:true];
                
                if (succ) {
                    [sself.view makeToast:@"购买成功".localized duration:2.5 position:CSToastPositionCenter];
                    [[KKStoreKitHelper sharedInstance] setAdRemoved:YES];
                    [[KKAdHelper sharedInstance] removeAds];
                    sself.adRemoveProduct = nil;
                    [sself.tableView reloadData];
                } else {
                    [sself.view makeToast:@"购买失败".localized duration:2.5 position:CSToastPositionCenter];
                }
                
                sself.purchasing = NO;
            }];
        }]];
        
        [self presentViewController:alert animated:true completion:NULL];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg = nil;
    switch (result) {
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败".localized;
            break;
        case MFMailComposeResultSent:
            msg = @"邮件已发送".localized;
            break;
        default:
            break;
    }
    
    if (msg) {
        [self.view makeToast:msg duration:1.5 position:CSToastPositionCenter];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
