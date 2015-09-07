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
    
    /**
    menu for update check
    
    :param: sender update menu
    */
    @IBAction func Update(sender: AnyObject) {
        XGBackend.cleanLastedverion() // manual check
        XGBackend.updateLastedverion()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        XGURLSchemeManager.sharedInstance.scan()
        
        //bundle ID hijack check
        let applicationMgr = XGContainerApplicationManager.sharedInstance
        applicationMgr.startMoniter()
        
        //start observe thread
        XGKeychainObserver.startObserve()
        self.loadViews()
        
        //check update
        //TODO:read timeinterval form plist add update check timer
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("processUpdateCheck:"), userInfo: nil, repeats: false)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
        // stop observe thread
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

