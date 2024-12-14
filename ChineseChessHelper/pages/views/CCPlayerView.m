//
//  CCPlayerView.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCPlayerView.h"

@interface CCPlayerView ()

@property (nonatomic, strong) UILabel *playerLabel;
@property (nonatomic, strong) UILabel *teamLabel;

@end

@implementation CCPlayerView

- (instancetype)initWithPlayerName:(NSString *)pn teamName:(NSString *)tn isRedCamp:(BOOL)isRed
{
    self = [super init];
    if (self) {
        self.playerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.playerLabel.font = [UIFont boldSystemFontOfSize:15];
        self.playerLabel.text = pn;
        self.playerLabel.textAlignment = NSTextAlignmentCenter;
        [self.playerLabel sizeToFit];
        [self addSubview:self.playerLabel];
        
        self.teamLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.teamLabel.font = [UIFont systemFontOfSize:12];
        self.teamLabel.textAlignment = NSTextAlignmentCenter;
        self.teamLabel.text = [NSString stringWithFormat:@"(%@)", tn];
        self.teamLabel.hidden = tn.length == 0;
        [self.teamLabel sizeToFit];
        [self addSubview:self.teamLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
}


@end
