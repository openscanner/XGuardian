//
//  XGFileEventsHelper.m
//  XGuardian
//
//  Created by WuYadong on 15/7/19.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

#include <Block.h>
#include <dispatch/dispatch.h>
#include <sys/types.h>

#import "XGuardian-Swift.h"
#import "XGFileEventsHelper.h"


@interface XGFileEventsHelper()
+ (void) callBackEvent ;
@end


void XGFileEventCallBack(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    
    static const FSEventStreamEventFlags dirChangedEvent = kFSEventStreamEventFlagItemCreated| kFSEventStreamEventFlagItemRemoved | kFSEventStreamEventFlagItemIsDir;
    
    //char **paths = eventPaths;
    BOOL dirChangedFlag = false;
    for (int i=0; i < numEvents; i++) {
        
        /* flags are unsigned long, IDs are uint64_t */
        //printf("Change %llu in %s, flags 0x%x\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
        
        // dir
        if (eventIds[i] & (dirChangedEvent)) {
            dirChangedFlag = true;
            break;
        }

    }
    
    if (dirChangedFlag) {
        [XGFileEventsHelper callBackEvent];
        
    }
}


@implementation XGFileEventsHelper

//TODO: add delegate to deal the call back should be better
+ (void) callBackEvent {
    [[XGContainerApplicationManager sharedInstance] applicationChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XGBundleIDThreadsChangeNotification" object:nil];
}


+ (void) startWatch:(CFStringRef) path {

    CFArrayRef pathsToWatch = CFArrayCreate(kCFAllocatorDefault, (const void **)&path, 1, NULL);
    void *callbackInfo = NULL; // could put stream-specific data here.
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 1.0; /* Latency in seconds */
    
    /* Create the stream, passing in a callback */
    stream = FSEventStreamCreate(NULL,
                                 &XGFileEventCallBack,
                                 callbackInfo,
                                 pathsToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagIgnoreSelf                                 );
    
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    CFRelease(pathsToWatch);
    
}

@end
