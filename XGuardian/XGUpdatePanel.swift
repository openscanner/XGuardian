//
//  XGUpdatePanel.swift
//  XGuardian
//
//  Created by WuYadong on 15/7/1.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGUpdatePanel: NSWindowController , NSWindowDelegate {

    weak var versionInfo : XGVersionInfo?
    
    @IBOutlet var panel: NSPanel!
    @IBOutlet weak var versionText: NSTextField!

    
    @IBAction func btnUpdateCancel(sender: AnyObject) {
        NSApplication.sharedApplication().stopModal()
        panel.close();
    }
    
    @IBAction func btnUpdateDownload(sender: AnyObject) {
        XGBackend.downloadLastedVersion()
        self.btnUpdateCancel(sender)
    }
    
    func panelShow() {
        self.loadWindow()
    
        self.versionInfo = XGBackend.getLastedverion()
        var versionStr = ""
        if(self.versionInfo != nil && self.versionInfo?.version != nil) {
            versionStr += "The lasted version: " + self.versionInfo!.version! + "\n"
        }
        if(self.versionInfo != nil && self.versionInfo?.changeLog != nil) {
            versionStr += "ChangeLog: \n" + self.versionInfo!.changeLog!
        }
    
        self.versionText.objectValue = versionStr
    
        NSApplication.sharedApplication().runModalForWindow(self.panel)
        self.showWindow(nil)
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        //window.orderOut(sender)
        //window.hidesOnDeactivate
        //window.hide
        //NSApplication.sharedApplication().hide(sender)
        NSApplication.sharedApplication().stopModal()
        return true
    }
    
    func windowWillBeginSheet(notification: NSNotification) {

    }
    
        
 /*   - (void)showInWindow:(NSWindow *)window {
    if (!panel) {
    [NSBundle loadNibNamed:@"SecondWindow" owner:self];
    }
    
    [NSApp beginSheet: panel
	   modalForWindow: window
    modalDelegate: nil
	   didEndSelector: nil
		  contextInfo: nil];
    //[NSApp runModalSession:[NSApp beginModalSessionForWindow:panel]];
    }*/

    
    
}
