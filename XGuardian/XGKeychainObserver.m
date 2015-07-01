//
//  XGKeychainObserver.m
//  XGuardian
//
//  Created by WuYadong on 15/6/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

@import AppKit;
#import "XGuardian-Swift.h"
#import "XGKeychainObserver.h"



static XGKeychainObserver* staticSharedObserver = nil;
static int CB_Context = 12;

static OSStatus XGSecKeychainCBFun ( SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context )
{
    switch (keychainEvent) {
        case kSecLockEvent:
        case kSecUnlockEvent:
            /*no need */
            return errSecSuccess;
            break;
        /*case kSecAddEvent:
            break;
        case kSecDeleteEvent:
            break;
        case kSecUpdateEvent:
            break;
        case kSecPasswordChangedEvent:
            break;
        case kSecDefaultChangedEvent:
            break;
        case kSecDataAccessEvent:
            break;
        case kSecKeychainListChangedEvent:
            break;
        case kSecTrustSettingsChangedEvent:
            break;
        default:
            NSLog(@"Unknown keychain event");
            break;*/
    }
    [staticSharedObserver processKeychainEvent:keychainEvent CBInfo:info];
    return errSecSuccess;
}

#pragma mark XGKeychainObserverCallbackManager

@interface XGKeychainObserverCallbackManager:NSObject
+(OSStatus) secKeychainAddCallback;
+(OSStatus) secKeychainRemoveCallback;
@end

@implementation XGKeychainObserverCallbackManager

+(OSStatus) secKeychainAddCallback{
    OSStatus stat = SecKeychainAddCallback ( XGSecKeychainCBFun, kSecEveryEventMask, &CB_Context );
    //NSLog(@"SecKeychainAddCallback: status- %d ", stat);
    return stat;
}

+(OSStatus) secKeychainRemoveCallback {
    OSStatus stat = SecKeychainRemoveCallback ( XGSecKeychainCBFun );
    //NSLog(@"SecKeychainRemoveCallback: status- %d ", stat);
    return stat;
}
@end


/***************************************************************************/
#pragma mark XGKeychainCallbackInfo

@interface XGKeychainCallbackInfo:NSObject
@property (readonly, assign, nonatomic) SecKeychainEvent event;
@property (readonly, assign, nonatomic)   UInt32 version;
@property (readonly, nonatomic)   SecKeychainItemRef	item;
@property (readonly, nonatomic)   SecKeychainRef		keychain;
@property (readonly, assign, nonatomic)   pid_t pid;
@end

@implementation XGKeychainCallbackInfo

- (instancetype)init:(SecKeychainEvent)event CBInfo:(SecKeychainCallbackInfo *)cbinfo {
    self = [super  init];
    if (self) {
        _event = event;
        _version = cbinfo->version;
        _item = cbinfo->item;
        _keychain = cbinfo->keychain;
        _pid = cbinfo->pid;
    }
    return self;
}

@end

/***************************************************************************/
#pragma mark XGKeychainObserver

@interface XGKeychainObserver ()
@property (assign, atomic) bool isRunning;
- (void) threadMethod;
- (void) keychainEventProcessor:(XGKeychainCallbackInfo *)info;
@end

#pragma mark -

@implementation XGKeychainObserver

+  (XGKeychainObserver*) startObserve {

    if (nil == staticSharedObserver) {
        staticSharedObserver = [[XGKeychainObserver alloc] init];
        if (nil == staticSharedObserver) {
            return nil;
        }
    }

    //start thread
    [staticSharedObserver setIsExit:false];
    [staticSharedObserver start];
    
    // start watch keychain event
    [XGKeychainObserverCallbackManager secKeychainAddCallback];
    return staticSharedObserver;
}

+  (void) stopObserve {
    
    // stop watch keychain event
    [XGKeychainObserverCallbackManager secKeychainRemoveCallback];
    
    //stop thread
    [staticSharedObserver setIsExit:true];
    //staticSharedObserver()
    

    return;
}

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
    
    _isRunning = false;
    _isExit = false;
    _thread = nil;
    
    return self;
}

- (void) start {
    
    if (_isRunning || _thread != nil) {
        return;
    }
    _isRunning = true;
    
    NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadMethod) object:nil];
    if (nil == thread) {
        _isRunning = false;
        return;
    }
    
    _thread = thread;
    [thread start];
}

- (void) processKeychainEvent:(SecKeychainEvent)event CBInfo:(SecKeychainCallbackInfo *)cbinfo {
    
    /*
    NSArray* attrArry = [XGKeyChain secKeychainItemGetAttr:cbinfo->item];
    NSLog(@"attrArry:%@", attrArry);
    */
    
    XGKeychainCallbackInfo* info = [[XGKeychainCallbackInfo alloc] init:event CBInfo:cbinfo];
    [self performSelector:@selector(keychainEventProcessor:) onThread:[self thread] withObject:info waitUntilDone:NO];
}

/**
 *  keychain observer process thread
 */
- (void) threadMethod {
    NSRunLoop* runloop = [NSRunLoop currentRunLoop];
    
    while (!self.isExit) {
        [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
      
    _isRunning = false;
    _isExit = false;
    return;
}

- (void) keychainEventProcessor:(XGKeychainCallbackInfo *)info {
    
    switch ([info event]) {
        /*case kSecLockEvent:
            break;
        case kSecUnlockEvent:
            break;*/
        case kSecAddEvent:
            break;
        case kSecDeleteEvent:
            break;
        case kSecUpdateEvent:
            break;
        case kSecPasswordChangedEvent:
            break;
        case kSecDefaultChangedEvent:
            break;
        case kSecDataAccessEvent:
            break;
        case kSecKeychainListChangedEvent:
            break;
        case kSecTrustSettingsChangedEvent:
            break;
        default:
            NSLog(@"Unknown keychain event");
            break;
    }
    
    
    NSRunningApplication *appInfo = [NSRunningApplication runningApplicationWithProcessIdentifier:[info pid]];
    NSString *appName = [appInfo localizedName];
    NSString *bundleID = [appInfo bundleIdentifier];
    NSURL *bundleURL = [appInfo bundleURL];
    
    
    //SecKeychainRef keychain = [info keychain];
    SecKeychainItemRef itemRef = [info item];
    
    NSLog(@"SecKeychainCallbackInfo:\n event:%d version:%d pid:%d \n App Name:%@\nbundle ID:%@\nbudle URL:%@\n ", [info event], [info version], [info pid], appName, bundleID, bundleURL);
    
    
    NSArray* attrArry = [XGKeyChain secKeychainItemGetAttr:itemRef];
    if(nil != attrArry) {
        NSLog(@"item%@", attrArry);
    }
    return;
    
}




@end
