//
//  XGHijackView.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/29.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGHijackView: NSView, NSUserNotificationCenterDelegate {

    @IBOutlet weak var owner: NSViewController!
    @IBOutlet weak var hijackListView: XGHijackListView!
    
    private var upperView: NSView? //remember superview
    
    private enum ScanSate {
       case INIT
       case RUNNING
       case END
    }
    private var scanState = ScanSate.INIT
    
    @IBOutlet weak var scanButton: NSButton!
    @IBOutlet weak var scanProcess: NSProgressIndicator!
    @IBOutlet weak var scanPromt: NSTextField!
    
    @IBAction func scanAction(sender: NSButton) {
        switch self.scanState {
        case ScanSate.INIT:
            self.scanState =  ScanSate.RUNNING
            self.scanPromt.hidden = false;
            self.scanButton.title = "SCANNING"
            self.scanProcess.displayedWhenStopped = false;
            //self.scanProcess.hidden = false;
            self.scanProcess.startAnimation(self)
            self.scanProcess.doubleValue = 0.0
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("processFireMethod:"), userInfo: nil, repeats: true)
            //scan
            XGKeyChain.scanAllItem()
            break;
        case ScanSate.RUNNING:
            break;
        case ScanSate.END:
            break;
        }
        return;
    }
    
    func processFireMethod(timer : NSTimer ){
        
        if (self.scanProcess.doubleValue >= 89.9){
            self.scanState =  ScanSate.END
        } else {
            self.scanProcess.doubleValue += 15.0
        }
        
        if(self.scanState == ScanSate.END) {
            timer.invalidate();
            self.scanButton.title = "SCANED"
            self.scanPromt.hidden = true
            self.scanProcess.doubleValue = 0
            self.scanProcess.stopAnimation(self)
            
            
            self.owner.view = self.hijackListView
            self.upperView = self.superview
            self.superview?.addSubview(self.hijackListView)
            self.superview?.replaceSubview(self, with:self.hijackListView)
        }
        return;
    }
    
    //reactive scan view
    func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
        self.scanState = ScanSate.INIT
        self.scanButton.title = "SCAN"
        self.owner.view = self
        self.upperView?.addSubview(self)
        self.upperView?.replaceSubview(self.hijackListView, with:self)
        //self.owner.loadView()
        
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        //set user notification delegate
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let bezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 0, yRadius: 0)
        bezierPath.lineWidth = 1.0
        NSColor.whiteColor().set()
        bezierPath.fill()

    }
    

    
   override var opaque :Bool { get {
        return false;
        }
    }
    
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        return nil
    }
    

    
}
