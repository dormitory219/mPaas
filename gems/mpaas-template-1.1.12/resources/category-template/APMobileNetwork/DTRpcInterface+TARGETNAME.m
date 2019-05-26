//
//  DTRpcInterface+TARGETNAME.m
//  PROTOTYPE
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright © TODAYS_YEAR ORGANIZATION_NAME. All rights reserved.
//

#import "DTRpcInterface+TARGETNAME.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation DTRpcInterface (CATEGORYNAME)

- (NSString*)gatewayURL
{
    return @"${RPC_GW}";
}

- (NSString*)signKeyForRequest:(NSURLRequest*)request
{
    return @"${APP_KEY}";
}

- (NSString *)productId
{
    return @"${APP_ID}";
}

- (NSString*)commonInterceptorClassName
{
    return @"DTRpcCommonInterceptor";
}

@end

#pragma clang diagnostic pop
