//
//  MPDrawerMainViewController.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import "MPDrawerMainViewController.h"

#define TITLE_VIEW_HEIGHT 64
#define TITLE_VIEW_INNER_VIEW_Y 25

@interface MPDrawerMainViewController () <UIGestureRecognizerDelegate>

@end

@implementation MPDrawerMainViewController

- (BOOL)autohideNavigationBar
{
    return YES;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TITLE_VIEW_HEIGHT)];
    titleView.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:68.0/255.0 blue:80.0/255.0 alpha:1.0];
    
    UILabel* titleInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, TITLE_VIEW_INNER_VIEW_Y, self.view.frame.size.width, 30)];
    titleInfoLabel.text = @"主页";
    titleInfoLabel.textColor = [UIColor whiteColor];
    titleInfoLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:titleInfoLabel];
    
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
    //[leftButton setOrigin:CGPointMake(15, TITLE_VIEW_INNER_VIEW_Y)];
    leftButton.frame = CGRectMake(15, TITLE_VIEW_INNER_VIEW_Y, 50, 30);
    //根据图片大小自适应；
    [leftButton sizeToFit];
    [leftButton addTarget:self action:@selector(leftBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:leftButton];
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"Test" forState:UIControlStateNormal];
    [rightButton sizeToFit];
    rightButton.frame = CGRectMake(self.view.frame.size.width-90, TITLE_VIEW_INNER_VIEW_Y, 70, 30);
    [rightButton addTarget:self action:@selector(rightBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:rightButton];
    
    
    [self.view addSubview:titleView];
    
    //创建并添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    pan.delegate = self;
    
}

- (void)leftBtnDidClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(mainViewControllerDidClickTheLeftButton:withButton:)]) {
        [self.delegate mainViewControllerDidClickTheLeftButton:self withButton:btn ];
    }
    
}

- (void)rightBtnDidClick
{
    NSLog(@"Right click");
}

//处理手势
- (void)pan:(UIPanGestureRecognizer *)pan
{
    if ([self.delegate respondsToSelector:@selector(mainViewController:didPan:)]) {
        [self.delegate mainViewController:self didPan:pan];
    }
}


#pragma mark ----------UIGestureRecognizerDelegate------------

//重写该方法，避免因为DTBaseViewController中的该函数导致的拖拉手势只能生效一次的情况
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    return YES;
    
}

//规定手势只在某一部分区域点击了才有用
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchP = [touch locationInView:self.view];
    if (touchP.x < self.view.frame.size.width * 0.2) {
        return YES;
    }
    
    return NO;
}

@end
