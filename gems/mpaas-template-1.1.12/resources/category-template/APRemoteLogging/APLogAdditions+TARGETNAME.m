//
//  APLogAdditions+TARGETNAME.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGANIZATION_NAME. All rights reserved.
//

#import "APLogAdditions+TARGETNAME.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation APLogAdditions (CATEGORYNAME)

- (NSString*)logServerURL
{
    return @"${LOG_GW}/loggw/logUpload.do";
}

- (NSArray*)defaultUploadLogTypes
{
    return @[@(APLogTypeBehavior), @(APLogTypeCrash), @(APLogTypeAuto), @(APLogTypeMonitor), @(APLogTypeKeyBizTrace), @(APLogTypePerformance)];
}

- (NSString *)platformID
{
    return @"${APP_KEY}-${WORKSPACE_ID}";
}

@end

#pragma clang diagnostic pop
