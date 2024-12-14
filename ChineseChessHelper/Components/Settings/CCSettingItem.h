//
//  CCSettingItem.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CCSettingItem;
typedef void(^CCSettingItemAction)(void);

typedef NS_ENUM(NSUInteger, CCSettingItemDetailType) {
    CCSettingItemDetailType_Text = 0,
    CCSettingItemDetailType_Switch,
    CCSettingItemDetailType_TextField,
    CCSettingItemDetailType_Slider,
};

@interface CCSettingItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) CCSettingItemDetailType detailType;
@property (nonatomic, assign) UITableViewCellStyle style;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

///
@property (nonatomic, copy, nullable) NSString *detailText;
/// switch
@property (nonatomic, assign, getter=isOn) BOOL on;
/// textfield
@property (nonatomic, copy, nullable) NSString *textFieldText;
@property (nonatomic, assign) UIKeyboardType textFieldKeyboardType;
@property (nonatomic, assign) NSTextAlignment textFieldAlignment;
/// slider
@property (nonatomic, assign) CGFloat sliderTopMargin;
@property (nonatomic, assign) float sliderMin;
@property (nonatomic, assign) float sliderMax;
@property (nonatomic, assign) float sliderValue;
@property (nonatomic, assign) BOOL roundSliderValue;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;

@property (nonatomic, strong) CCSettingItemAction selectedAction;
@property (nonatomic, strong) CCSettingItemAction valueChangedAction;

@end

NS_ASSUME_NONNULL_END
