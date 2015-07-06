//
//  AppDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/29.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa



private let updateTimerInterval = 21600.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate{

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var mainContentView: NSView!
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //
        XGKeychainObserver.startObserve()
        self.loadViews()
        
        //check update
        //TODO:read timeinterval form plist add update check timer
        NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("processUpdateCheck:"), userInfo: nil, repeats: false)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application

        XGKeychainObserver.stopObserve()
    }
    
    func processUpdateCheck(timer : NSTimer ) {
        NSTimer.scheduledTimerWithTimeInterval(updateTimerInterval, target: self, selector: Selector("processUpdateCheck:"), userInfo: nil, repeats: false)
        XGBackend.updateLastedverion()
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().hide(sender)
        return false
    }



    func loadViews() {
        
        //window.delegate = self
        //window.autodisplay = true
        //window.restorable = true
        self.window.titlebarAppearsTransparent = true
        self.window.movableByWindowBackground = true
        self.window.titleVisibility = NSWindowTitleVisibility.Hidden
        self.window.styleMask |= NSFullSizeContentViewWindowMask;
        

    }
    

    


}

