//
//  XGScanViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/8.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGScanViewController: NSViewController, NSUserNotificationCenterDelegate {

    weak var scanView : XGScanView?
    
    private enum ScanSate {
        case INIT
        case RUNNING
        case END
    }
    private var scanState = ScanSate.INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanView = self.view as? XGScanView
        // Do view setup here.
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    @IBOutlet weak var scanButton: NSButton!

    @IBAction func scanAction(sender: AnyObject) {
        switch self.scanState {
        case ScanSate.INIT:
            
            self.startScan()
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
        let processValue = self.getScanProcessValue()
            if ( processValue >= 89.9){
                self.scanState =  ScanSate.END
            } else {
                self.setScanProcessValue(processValue + 15.0)
            }
        
        if(self.scanState == ScanSate.END) {
            timer.invalidate();
            self.stopScan()
            
            //TODO:notification to swich
            NSNotificationCenter.defaultCenter().postNotificationName(ScanFinisheNotification, object: self.title! as NSString)
        }
        return;
    }
    
    @IBOutlet weak var scanProcess: NSProgressIndicator!
    @IBOutlet weak var scanPromt: NSTextField!
    
    
    
    func startScan() {
        self.scanState =  ScanSate.RUNNING
        self.scanPromt.hidden = false;
        self.scanButton.state = NSOffState
        self.scanProcess.displayedWhenStopped = false
        //self.scanProcess.hidden = false;
        self.scanProcess.startAnimation(self)
        self.scanProcess.doubleValue = 0.0
    }
    
    func setScanProcessValue(process: Double) {
        self.scanProcess.doubleValue = process
        
    }
    
    func getScanProcessValue() -> Double{
        return self.scanProcess.doubleValue
    }
    
    func stopScan() {
        //self.scanButton.title = "SCAN"
        self.scanState =  ScanSate.INIT
        self.scanButton.state = NSOnState
        self.scanPromt.hidden = true
        self.scanProcess.doubleValue = 0
        self.scanProcess.stopAnimation(self)
    }
    
    //reactive scan view
    func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
        //            self.scanState = ScanSate.INIT
        //            self.scanButton.title = "SCAN"
        //            self.owner.view = self
        //            self.upperView?.addSubview(self)
        //            self.upperView?.replaceSubview(self.hijackListView, with:self)
        //self.owner.loadView()
        
    }

}
