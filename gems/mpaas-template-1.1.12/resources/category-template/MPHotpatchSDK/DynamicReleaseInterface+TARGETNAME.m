//
//  DynamicReleaseInterface+TARGETNAME.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGANIZATION_NAME. All rights reserved.
//

#import "DynamicReleaseInterface+TARGETNAME.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation DynamicReleaseInterface (CATEGORYNAME)

- (NSString*)AESEncryptionKeyName
{
    return @"${APP_KEY}";
}

#ifdef MPNebulaHandler
- (id<NebulaHandler>)getNebulaHandler
{
    NARequestManager *handle = [NARequestManager sharedInctance];
    return handle;
}
#endif

@end

#pragma clang diagnostic pop
