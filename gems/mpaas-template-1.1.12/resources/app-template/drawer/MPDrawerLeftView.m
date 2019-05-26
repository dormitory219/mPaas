//
//  MPDrawerLeftView.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import "MPDrawerLeftView.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define BACKGROUND_HEIGHT 160
#define BACKGROUND_MARGIN_LEFT 30
#define BUTTON_INSET_LEFT 30
#define BUTTON_MARGIN_TOP 30
#define BUTTON_HEIGHT 30

@implementation MPDrawerLeftView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    
    return self;
}

//初始化一些操作，创建子控件，布局子控件
- (void)setUp
{
    _userBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, BACKGROUND_HEIGHT)];
    _userBackgroundView.backgroundColor = [UIColor colorWithRed:95.0/255.0 green:95/255.0 blue:95/255.0 alpha:1.0];
    
    _userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BACKGROUND_MARGIN_LEFT, 25, 100, 100)];
    [_userImageView setImage:[UIImage imageNamed:@"ic_launcher.png"]];
    [_userBackgroundView addSubview:_userImageView];
    
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(BACKGROUND_MARGIN_LEFT, _userImageView.frame.origin.y+_userImageView.frame.size.height, 100, 20)];
    _userNameLabel.textAlignment = NSTextAlignmentCenter;
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.text = @"金融云";
    [_userBackgroundView addSubview:_userNameLabel];
    
    [self addSubview:_userBackgroundView];
    
    
    
    _buttonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, BACKGROUND_HEIGHT, SCREEN_W, SCREEN_H-BACKGROUND_HEIGHT)];
    _buttonScrollView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    _userInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, BUTTON_MARGIN_TOP, SCREEN_W, BUTTON_HEIGHT)];
    [self setButtonInfo:self.userInfoButton title:@"个人信息" image:[UIImage imageNamed:@"TabBar_Friends_Sel"]];
    [self.userInfoButton addTarget:self action:@selector(userInfoButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [_buttonScrollView addSubview:_userInfoButton];
    
    
    _userCenterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, BUTTON_MARGIN_TOP+_userInfoButton.frame.origin.y+_userInfoButton.frame.size.height, SCREEN_W, BUTTON_HEIGHT)];
    [self setButtonInfo:self.userCenterButton title:@"用户中心" image:[UIImage imageNamed:@"TabBar_Discovery_Sel"]];
    [self.userCenterButton addTarget:self action:@selector(userCenterButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [_buttonScrollView addSubview:_userCenterButton];
    
    [self addSubview:_buttonScrollView];
}

- (void) setButtonInfo:(UIButton*)button title:(NSString*)title image:(UIImage*)image
{
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageView.tintColor = [UIColor whiteColor];
    button.tintColor = [UIColor whiteColor];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -button.titleLabel.bounds.size.width+BUTTON_INSET_LEFT, 0, button.titleLabel.bounds.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, image.size.width+BUTTON_INSET_LEFT, 0, -image.size.width);
}

- (void)userInfoButtonDidClick
{
    [DTContextGet() startApplication:@"20000003" params:@{} animated:YES];
    NSLog(@"user info");
}

- (void)userCenterButtonDidClick
{
    [DTContextGet() startApplication:@"20000002" params:@{} animated:YES];
    NSLog(@"user center");
}

@end
