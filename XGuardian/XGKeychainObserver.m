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
        case kSecKeychainListChangedEvent:
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
     SecKeychainEventMask wathEventMask = kSecAddEventMask|kSecDeleteEventMask|kSecUpdateEventMask|kSecPasswordChangedEventMask|kSecDefaultChangedEventMask|kSecDataAccessEventMask|kSecTrustSettingsChangedEventMask;
    OSStatus stat = SecKeychainAddCallback ( XGSecKeychainCBFun, wathEventMask, &CB_Context );
    return stat;
}

+(OSStatus) secKeychainRemoveCallback {
    OSStatus stat = SecKeychainRemoveCallback ( XGSecKeychainCBFun );
    return stat;
}
@end


/***************************************************************************/
#pragma mark XGKeychainCallbackInfo

@interface XGKeychainCallbackInfo:NSObject
@property (readonly, assign, nonatomic) SecKeychainEvent   event;
@property (readonly, assign, nonatomic) UInt32             version;
@property (readonly, nonatomic        ) SecKeychainItemRef itemRef;
@property (readonly, nonatomic        ) SecKeychainRef     keychain;
@property (readonly, assign, nonatomic) pid_t              pid;
@property (readonly, nonatomic        ) NSString           *appName;
@property (readonly, nonatomic        ) NSString           *bundleID;
@property (readonly, nonatomic        ) NSURL              *bundleURL;
@property (readonly, nonatomic        ) XGSecurityItem     *securityItem;
@end

@implementation XGKeychainCallbackInfo

- (instancetype)init:(SecKeychainEvent)event CBInfo:(SecKeychainCallbackInfo *)cbinfo
             AppInfo:(NSRunningApplication*)appInfo SecurityItem:(XGSecurityItem *)securityItem{
    self = [super  init];
    if (self) {
        _event = event;
        _version = cbinfo->version;
        _itemRef = cbinfo->item;
        _keychain = cbinfo->keychain;
        
        _pid = cbinfo->pid;
        _appName = [appInfo localizedName];
        _bundleID = [appInfo bundleIdentifier];
        _bundleURL = [appInfo bundleURL];
        
        _securityItem = securityItem;
 
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
    
    SecKeychainItemRef itemRef = cbinfo->item;
    XGSecurityItem *securityItem = nil;
    if( nil != itemRef) {
        NSDictionary* attrDict = [XGKeyChain secKeychainItemGetAttr:itemRef];
        if(nil == attrDict) {
            return;
        }
        //NSLog(@"item%@", attrDict);
        
        if (nil ==  [attrDict objectForKey:@"v_Ref"] ) {
            [attrDict setValue:(__bridge id)(itemRef) forKey:@"v_Ref"];
        }
        securityItem = [[XGSecurityItem alloc]init:attrDict];
        
    }
    
    NSRunningApplication *appInfo = [NSRunningApplication runningApplicationWithProcessIdentifier:cbinfo->pid];

    XGKeychainCallbackInfo* info = [[XGKeychainCallbackInfo alloc] init:event CBInfo:cbinfo AppInfo:appInfo SecurityItem:securityItem];
    
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
    
    //NSLog(@"SecKeychainCallbackInfo:\nevent:%d version:%d pid:%d \nApp Name:%@\nbundle ID:%@\nbudle URL:%@\n item:%@", [info event], [info version], [info pid], info.appName, info.bundleID, info.bundleURL, info.securityItem);
    
    //find same key info in the dictionary
    XGSecurityItemSet *itemSet = [XGKeyChain getItemSet];
    XGSecurityItem *oldItem = [itemSet findItem:[info securityItem]];
    if(nil == oldItem) {
        return;
    }
    
    //check the application list change
    if ((info.securityItem.applicationNum !=1) &&  (oldItem.applicationNum != 1) ) {
        return;
    }
    
    BOOL isSame = [oldItem isSameWith:info.securityItem];
    if (isSame) {
        return;
    }
    
    [itemSet addItem:info.securityItem];
    
    //notify
    NSUserNotification *notification  = [[NSUserNotification alloc]init];
    NSUserNotificationCenter* ntfCecenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notification setTitle: @"HiJack"];
    [notification setContentImage:[NSImage imageNamed:@"NSApplicationIcon"]];
    //notification.activationType = NSUserNotificationActivationTypeContentsClicked;
    [notification setInformativeText:[[NSString  alloc] initWithFormat:@"%@(%@) may have been hijack! Please check it.", info.securityItem.name, info.securityItem.account]];
    [ntfCecenter deliverNotification:notification];
    
    

    
}


@end
