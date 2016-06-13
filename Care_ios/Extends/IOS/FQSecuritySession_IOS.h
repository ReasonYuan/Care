//
//  FQSecuritySession_IOS.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JreEmulation.h"
#include "Platform.h"

@interface FQSecuritySession_IOS : NSObject
{
    
}

+(void)setAccessToken:(NSString*)token;

/**
 *获取验证header
 */
+(NSDictionary*)getSessionHeadersWithUrl:(NSString*) resource andMethod:(NSString*) method;


+(IOSByteArray *)getRecord3DesKey;

@end
