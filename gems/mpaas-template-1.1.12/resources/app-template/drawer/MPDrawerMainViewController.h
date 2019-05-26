//
//  MPDrawerMainViewController.h
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import <APMobileFramework/APMobileFramework.h>

@class MPDrawerMainViewController;
@protocol MPDrawerMainViewControllerDelegate <NSObject>

@optional

- (void)mainViewControllerDidClickTheLeftButton:(MPDrawerMainViewController *)mainViewController withButton:(UIButton *)btn;
- (void)mainViewController:(MPDrawerMainViewController *)mainViewController didPan:(UIPanGestureRecognizer *)pan;

@end

@interface MPDrawerMainViewController : DTViewController

@property (nonatomic,weak)id<MPDrawerMainViewControllerDelegate>delegate;

@end
