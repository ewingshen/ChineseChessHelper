//
//  CCSettingItemTableViewCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCSettingItemTableViewCell.h"
#import "UIView+CCFast.h"

@interface CCSettingItemTableViewCell () <UITextFieldDelegate>

@property (nonatomic, strong) UISwitch *detailSwitch;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *sliderLabel;

@end

@implementation CCSettingItemTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.detailSwitch = [UISwitch new];
        self.detailSwitch.hidden = YES;
        [self.detailSwitch addTarget:self action:@selector(onValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.detailSwitch];
        
        self.textField = [UITextField new];
        self.textField.hidden = YES;
        self.textField.delegate = self;
        [self.textField addTarget:self action:@selector(onValueChangedAction:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:self.textField];
        
        self.slider = [UISlider new];
        self.slider.hidden = YES;
        self.slider.continuous = YES;
        [self.slider addTarget:self action:@selector(onValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.slider];
        
        self.sliderLabel = [UILabel new];
        self.sliderLabel.font = [UIFont systemFontOfSize:UIFont.systemFontSize];
        self.sliderLabel.textColor = [UIColor systemGrayColor];
        [self.contentView addSubview:self.sliderLabel];
    }
    return self;
}

- (void)bind:(CCSettingItem *)item
{
    _item = item;
    
    self.textLabel.text = item.title;
    self.detailTextLabel.text = item.detailText;
    self.detailSwitch.on = item.isOn;
    
    self.textField.text = item.textFieldText;
    self.textField.textAlignment = item.textFieldAlignment;
    self.accessoryType = item.accessoryType;
    
    self.slider.minimumValue = item.sliderMin;
    self.slider.maximumValue = item.sliderMax;
    self.slider.value = item.sliderValue;
    [self updateSliderLabel];
    
    self.detailSwitch.hidden = item.detailType != CCSettingItemDetailType_Switch;
    self.textField.hidden = item.detailType != CCSettingItemDetailType_TextField;
    self.textField.keyboardType = item.textFieldKeyboardType;
    self.slider.hidden = item.detailType != CCSettingItemDetailType_Slider;
    self.sliderLabel.hidden = self.slider.isHidden;
    
    self.selectionStyle = item.selectionStyle;
}

- (void)onValueChangedAction:(UIControl *)sender
{
    if (sender == self.detailSwitch) {
        self.item.on = self.detailSwitch.isOn;
    } else if (sender == self.textField) {
        self.item.textFieldText = self.textField.text;
    } else if (sender == self.slider) {
        [self updateSliderLabel];
        self.item.sliderValue = self.slider.value;
    }
    
    CALL_BLOCK(self.item.valueChangedAction)
}

- (void)updateSliderLabel
{
    if (self.item.roundSliderValue) {
        self.slider.value = roundf(self.slider.value);
        self.sliderLabel.text = [NSString stringWithFormat:@"%d", (int)self.slider.value];
    } else {
        self.sliderLabel.text = [NSString stringWithFormat:@"%.2f", self.slider.value];
    }
    
    [self.sliderLabel sizeToFit];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat rightMargin = 12.0f;
    self.detailSwitch.frame = CGRectMake(self.contentView.width - self.detailSwitch.width - rightMargin, (self.contentView.height - self.detailSwitch.height) / 2, self.detailSwitch.width, self.detailSwitch.height);
    
    CGSize tfSize = CGSizeMake(80, 30);
    self.textField.frame = CGRectMake(self.contentView.width - tfSize.width - rightMargin, (self.contentView.height - tfSize.height) / 2, tfSize.width, tfSize.height);
    
    CGSize sliderSize = CGSizeMake(150, 30);
    CGFloat sliderTop = self.item.sliderTopMargin;
    if (sliderTop == 0) {
        sliderTop = (self.contentView.height - sliderSize.height) / 2;
    }
    self.slider.frame = CGRectMake(self.contentView.width - sliderSize.width - rightMargin, sliderTop, sliderSize.width, sliderSize.height);
    [self.sliderLabel sizeToFit];
    self.sliderLabel.frame = CGRectMake(self.slider.left - 2 - self.sliderLabel.width, self.slider.top + (self.slider.height - self.sliderLabel.height) * 0.5, self.sliderLabel.width, self.sliderLabel.height);
}

@end
