//
//  MPDrawerViewController.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import "MPDrawerViewController.h"
#import "MPDrawerMainViewController.h"
#import "MPDrawerLeftView.h"

#define screenW [UIScreen mainScreen].bounds.size.width
#define targetL screenW * 0.8

@interface MPDrawerViewController () <MPDrawerMainViewControllerDelegate> {
    UITapGestureRecognizer* _tapGesture;
}

@property (nonatomic, strong) MPDrawerLeftView* leftView;

@end

@implementation MPDrawerViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _leftView = [[MPDrawerLeftView alloc] initWithFrame:CGRectMake(0, 0, targetL, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_leftView];
    
    MPDrawerMainViewController* mainViewController = [[MPDrawerMainViewController alloc] init];
    mainViewController.delegate = self;
    [self addChildViewController:mainViewController];
    [self.view addSubview:mainViewController.view];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    MPDrawerMainViewController *mainViewController = self.childViewControllers[0];
    
    [UIView animateWithDuration:0.5 animations:^{
        mainViewController.view.frame = [UIScreen mainScreen].bounds;
    }];
    
    mainViewController.view.userInteractionEnabled = YES;
    
    //移除手势,手势一添加，只要不移除，就永远会影响到事件的传递
    if (_tapGesture){
        [self.view removeGestureRecognizer:_tapGesture];
        _tapGesture = nil;
    }
}


- (void)mainViewControllerDidClickTheLeftButton:(MPDrawerMainViewController *)mainViewController withButton:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^{
        mainViewController.view.transform = CGAffineTransformTranslate(mainViewController.view.transform, targetL, 0);
    }];
    
    mainViewController.view.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    _tapGesture = tap;
}

- (void)mainViewController:(MPDrawerMainViewController *)mainViewController didPan:(UIPanGestureRecognizer *)pan
{
    
    CGPoint offSet = [pan translationInView:self.view];
    
    mainViewController.view.frame = [self frameWithOffsetX:offSet.x withOriginalFrame:mainViewController.view.frame];
    
    //结束拖拽后
    if (pan.state == UIGestureRecognizerStateEnded) {
        CGFloat target = 0;
        if (mainViewController.view.frame.origin.x > screenW * 0.3) {
            target = targetL;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            mainViewController.view.frame  = [self frameWithOffsetX:target - mainViewController.view.frame.origin.x withOriginalFrame:mainViewController.view.frame];
        }];
    }
    
    //每次偏移之后都需要复位
    [pan setTranslation:CGPointZero inView:self.view];
    
    //判断是否是显示了左视图
    if (mainViewController.view.frame.origin.x == targetL) {
        
        mainViewController.view.userInteractionEnabled = NO;
        
        //添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self.view addGestureRecognizer:tap];
        _tapGesture = tap;
    }
    
}

- (CGRect)frameWithOffsetX:(CGFloat)x withOriginalFrame:(CGRect)frame
{
    frame.origin.x += x;
    return frame;
}


//处理自己的点击手势
- (void)tap:(UITapGestureRecognizer *)tap
{
    
    MPDrawerMainViewController *mainViewController = self.childViewControllers[0];
    
    [UIView animateWithDuration:0.5 animations:^{
        mainViewController.view.frame = [UIScreen mainScreen].bounds;
    }];
    
    mainViewController.view.userInteractionEnabled = YES;
    
    //移除手势,手势一添加，只要不移除，就永远会影响到事件的传递
    [self.view removeGestureRecognizer:tap];
    _tapGesture = nil;
}
@end
