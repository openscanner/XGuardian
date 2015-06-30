//
//  XGKeychainObserver.h
//  XGuardian
//
//  Created by WuYadong on 15/6/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGKeychainObserver : NSObject

@property (assign,atomic) bool isExit;
@property (strong,nonatomic) NSThread* thread;

+ (XGKeychainObserver*) startObserve;
+ (void) stopObserve;



- (void) processKeychainEvent:(SecKeychainEvent)event CBInfo:(SecKeychainCallbackInfo *)cbinfo;

@end

