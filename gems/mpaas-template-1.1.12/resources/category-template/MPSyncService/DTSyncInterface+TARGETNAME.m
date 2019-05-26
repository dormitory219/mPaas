//
//  DTSyncInterface+TARGETNAME.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGANIZATION_NAME. All rights reserved.
//

#import "DTSyncInterface+TARGETNAME.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation DTSyncInterface (CATEGORYNAME)

- (NSString*)appId
{
    return @"${APP_ID}";
}

- (NSString*)platform
{
    return @"IOS";
}

- (NSString*)workspaceId
{
    return @"${WORKSPACE_ID}";
}

- (int)syncPort
{
    return ${SYNC_PORT};
}

- (NSString*)syncServer
{
    return @"${SYNC_SERVER}";
}

@end

#pragma clang diagnostic pop
