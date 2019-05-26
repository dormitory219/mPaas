//
//  MPNavigationViewController.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import "MPNavigationViewController.h"
#import "MPSecondaryViewController.h"

@interface MPNavigationViewController ()

@end

@implementation MPNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"主页";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一页" style:UIBarButtonItemStylePlain target:self action:@selector(btnClick)];
}

- (void)btnClick
{
    MPSecondaryViewController *vc = [[MPSecondaryViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
