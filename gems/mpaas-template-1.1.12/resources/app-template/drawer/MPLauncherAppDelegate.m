//
//  MPLauncherAppDelegate.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGNIZATION_NAME. All rights reserved.
//

#import "MPLauncherAppDelegate.h"
#import "MPDrawerViewController.h"

@interface MPLauncherAppDelegate ()

@property (nonatomic, strong) MPDrawerViewController* rootVC;

@end

@implementation MPLauncherAppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        self.rootVC = [[MPDrawerViewController alloc] init];
    }
    return self;
}

- (UIViewController *)rootControllerInApplication:(DTMicroApplication *)application
{
    return self.rootVC;
}

- (void)application:(DTMicroApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
}

- (void)application:(DTMicroApplication *)application willResumeWithOptions:(NSDictionary *)launchOptions
{
    
}

@end
