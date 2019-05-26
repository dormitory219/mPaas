//
//  MPSecondaryViewController.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import "MPSecondaryViewController.h"

@implementation MPSecondaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, self.view.bounds.size.height/2-60, self.view.bounds.size.width-60, 40)];
    label.text = @"Hello World!";
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
}

- (UIImage *)customNavigationBarBackButtonImage {
    return [UIImage imageNamed:@"back_button"];
}

- (UIColor *)customNavigationBarBackButtonTitleColor {
    return [UIColor colorWithRed:0.169 green:0.569 blue:0.886 alpha:1.00];
}

@end
