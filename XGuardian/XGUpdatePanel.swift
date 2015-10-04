//
//  XGUpdatePanel.swift
//  XGuardian
//
//  Created by WuYadong on 15/7/1.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

private var updatePanel : XGUpdatePanel?

class XGUpdatePanel: NSWindowController , NSWindowDelegate {

    weak var versionInfo : XGVersionInfo?
    
    @IBOutlet weak var versionText: NSTextField!

    
    @IBAction func btnUpdateCancel(sender: AnyObject) {
        self.window?.performClose(sender);
    }
    
    @IBAction func btnUpdateDownload(sender: AnyObject) {
        XGBackend.downloadLastedVersion()
        self.btnUpdateCancel(sender)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        //set window title
        self.window?.titlebarAppearsTransparent = true
        self.window?.movableByWindowBackground = true
        self.window?.titleVisibility = NSWindowTitleVisibility.Hidden
        self.window?.styleMask |= NSFullSizeContentViewWindowMask;
        
        self.window?.delegate = self
        
        self.versionInfo = XGBackend.getLastedverion()
        var versionStr = ""
        if(self.versionInfo != nil && self.versionInfo?.version != nil) {
            versionStr += "The lasted version: " + self.versionInfo!.version! + "\n"
        }
        if(self.versionInfo != nil && self.versionInfo?.changeLog != nil) {
            versionStr += "ChangeLog: \n" + self.versionInfo!.changeLog!
        }
        
        self.versionText.objectValue = versionStr

    }
    
    class func panelShow() {
        if (nil == updatePanel) {
            updatePanel = XGUpdatePanel(windowNibName: "UpdateWindow")
            if(nil == updatePanel)  {
                return
            }
        }
        updatePanel!.showWindow(nil)
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        return true
    }
    
    
    
}
