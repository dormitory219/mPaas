//
//  APLogUser+TARGETNAME.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGANIZATION_NAME. All rights reserved.
//

#import "APLogUser+TARGETNAME.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation APLogUser (CATEGORYNAME)

- (NSString*)uploadLogUrl
{
    return @"${LOG_GW}/loggw/extLog.do";
}

- (NSString*)uploadStatusUrl
{
    return @"${LOG_GW}/loggw/report_diangosis_upload_status.htm";
}

- (NSString*)currentUserId
{
    return @"";
}

- (BOOL)isLogFormatAssertCheck
{
    return NO;
}

- (BOOL)isCloseLogEncrypt
{
    return NO;
}

@end

#pragma clang diagnostic pop
