//
//  CXKeychainHelper.m
//  KeychainSwiftAPI
//
//  Created by Denis Krivitski on 26/11/14.
//  Copyright (c) 2014 Checkmarx. All rights reserved.
//


#import <Security/Security.h>
#import "CXKeychainHelper.h"


@implementation CXResultWithStatus
@end

@implementation CXALCContent
@end

@implementation CXKeychainHelper

+(CXResultWithStatus*)secItemCopyMatchingCaller:(NSDictionary*)query
{
    CXResultWithStatus* resultWithStatus = [[CXResultWithStatus alloc] init];
    CFTypeRef result = nil;
    
    resultWithStatus.status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &result);
    if (result != nil) {
        resultWithStatus.result = CFBridgingRelease(result);
    }
    
    return resultWithStatus;
}

+(CXResultWithStatus*)secItemAddCaller:(NSDictionary*)query
{
    CXResultWithStatus* resultWithStatus = [[CXResultWithStatus alloc] init];
    CFTypeRef result = nil;
    
    resultWithStatus.status = SecItemAdd((__bridge CFDictionaryRef)(query), &result);
    if (result != nil) {
        resultWithStatus.result = CFBridgingRelease(result);
    }
    
    return resultWithStatus;
}



+(CXALCContent*)secACLCopyContents:(SecACLRef) acl{
    CXALCContent* alcContent = [[CXALCContent alloc] init];
    
    CFArrayRef applicationList = nil;
    CFStringRef description = nil;
    SecKeychainPromptSelector promptSelector = 0;
    
    alcContent.status = SecACLCopyContents(acl, &applicationList, &description, &promptSelector);
    
    if (applicationList != nil) {
        alcContent.applicationList = CFBridgingRelease(applicationList);
    }else {
        alcContent.applicationList = nil;
    }
    
    if (description != nil) {
        alcContent.desc = CFBridgingRelease(description);
    } else {
        alcContent.desc = nil;
    }

    alcContent.promptSelector = promptSelector;
    
    return alcContent;
    
}




@end


