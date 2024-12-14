//
//  CCEngineSettingViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/25.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCEngineSettingViewController.h"
#import "EngineWrapper.h"

static NSString *EngineSettingKey = @"engine_setting_key";

@interface CCEngineSettingViewController ()

@property (nonatomic, strong) CCEngineSetting *es;
@property (nonatomic, assign) BOOL isSelfPlay;

@end

@implementation CCEngineSettingViewController

- (instancetype)initWithPlayMode:(BOOL)isSelfPlay
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:[EngineSettingKey stringByAppendingFormat:@"%d", isSelfPlay]];
        if (data != nil) {
            NSError *error = nil;
            CCEngineSetting *es = [NSKeyedUnarchiver unarchivedObjectOfClass:[CCEngineSetting class] fromData:data error:&error];
            if (error) {
                DLog(@"unarchive engineSetting failed with error: %@", error);
            } else if (es) {
                self.es = es;
            }
        }
        
        if (!self.es) {
            self.es = [CCEngineSetting new];
            self.es.goDepth = 10;
            self.es.goTime = 0;
            self.es.color = isSelfPlay ? CCEngineColor_None : CCEngineColor_Black;
        }
        
        self.isSelfPlay = isSelfPlay;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"电脑设置".localized;
    
    [self setLeftButton:@"取消".localized image:nil target:self action:@selector(backAction)];
    [self setRightButton:@"确定".localized image:nil target:self action:@selector(done)];
}

- (void)dealloc
{
    self.completion = nil;
}

- (void)done
{
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.es requiringSecureCoding:NO error:&error];
    if (error) {
        DLog(@"archive setting failed with error: %@", error);
    } else if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:[EngineSettingKey stringByAppendingFormat:@"%d", self.isSelfPlay]];
    }
    CALL_BLOCK(self.completion, self.es)
}

- (void)setupData
{
    [self.data removeAllObjects];
    
    weakify(self)
    if (!self.isSelfPlay) {
        CCSettingItem *isRed = [CCSettingItem new];
        isRed.title = @"电脑执红".localized;
        isRed.detailType = CCSettingItemDetailType_Switch;
        isRed.on = self.es.color == CCEngineColor_Red;
        weakify(isRed)
        isRed.valueChangedAction = ^{
            if (!weak_self || !weak_isRed) return;
            strongify(self)
            strongify(isRed)
            
            strong_self.es.color = strong_isRed.isOn ? CCEngineColor_Red : CCEngineColor_Black;
        };
        [self.data addObject: isRed];
        
        CCSettingItem *goTime = [CCSettingItem new];
        goTime.title = @"思考用时(秒)：".localized;
        goTime.style = UITableViewCellStyleSubtitle;
        goTime.detailText = @"为0表示不限制时间，搜索固定深度.".localized;
        goTime.textFieldText = [NSString stringWithFormat:@"%.1f", self.es.goTime];
        goTime.detailType = CCSettingItemDetailType_TextField;
        goTime.textFieldKeyboardType = UIKeyboardTypeDecimalPad;
        weakify(goTime)
        goTime.valueChangedAction = ^{
            if (!weak_self || !weak_goTime) return;
            strongify(self)
            strongify(goTime)
            
            strong_self.es.goTime = [strong_goTime.textFieldText floatValue];
            if (strong_self.es.goTime < 0.5) {
                strong_self.es.goTime = 0.5;
            }
        };
        [self.data addObject: goTime];
    }
    
    CCSettingItem *goDepth = [CCSettingItem new];
    goDepth.title = @"思考深度".localized;
    goDepth.detailType = CCSettingItemDetailType_Slider;
    goDepth.sliderMax = self.isSelfPlay ? 30 : 20;
    goDepth.sliderMin = 1;
    goDepth.sliderValue = self.es.goDepth;
    goDepth.roundSliderValue = YES;
    weakify(goDepth)
    goDepth.valueChangedAction = ^{
        if (!weak_self || !weak_goDepth) return;
        strongify(self)
        strongify(goDepth)
        
        strong_self.es.goDepth = strong_goDepth.sliderValue;
    };
    [self.data addObject: goDepth];
    
    CCSettingItem *threads = [CCSettingItem new];
    threads.title = @"线程数".localized;
    threads.detailText = @"线程数越大电脑行棋越快，但是耗电量、发热增加".localized;
    threads.style = UITableViewCellStyleSubtitle;
    threads.detailType = CCSettingItemDetailType_Slider;
    threads.sliderMax = [[EngineWrapper shared] maxThreadCount] - 1;
    threads.sliderMin = 1;
    threads.roundSliderValue = YES;
    threads.sliderValue = roundf((threads.sliderMax + threads.sliderMin) / 2);
    threads.sliderTopMargin = 12;
    threads.height = 80;
    self.es.threads = threads.sliderValue;
    weakify(threads)
    threads.valueChangedAction = ^{
        if (!weak_self || !weak_threads) return;
        strongify(self)
        strongify(threads)
        
        strong_self.es.threads = strong_threads.sliderValue;
    };
    [self.data addObject:threads];
}

@end


