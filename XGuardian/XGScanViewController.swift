//
//  XGScanViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/8.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGScanViewController: NSViewController {
    
    @IBOutlet weak var scanButton: NSButton!
    @IBOutlet weak var functionalLabel: NSTextField!
    @IBOutlet weak var functionalDescrption: NSTextField!
    @IBOutlet weak var titleButton: NSButton!
    
    weak var scanView : XGScanView?
    weak var barItem: XGSideBarItem?
    
    private enum ScanSate {
        case INIT
        case RUNNING
        case END
    }
    private var scanState = ScanSate.INIT
    
    @IBAction func scanAction(sender: AnyObject) {
        switch self.scanState {
        case ScanSate.INIT:
            
            self.startScan()
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("processFireMethod:"), userInfo: nil, repeats: true)

            break;
        case ScanSate.RUNNING:
            break;
        case ScanSate.END:
            break;
        }
        return;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        self.titleButton.title = self.barItem!.title
        self.functionalLabel.objectValue = self.barItem?.title
        self.functionalDescrption.objectValue = self.barItem?.desc

    }

    func processFireMethod(timer : NSTimer ){
        let processValue = self.getScanProcessValue()
        if ( processValue >= 89.9){
            if let type = barItem?.type   {
                if type  == XGThreatsType.BundleIDHijack {
                   let process = XGContainerApplicationManager.sharedInstance.getScanProcess()
                    if process < 100.0 {
                        return
                    }
                }
            }
            self.scanState =  ScanSate.END
        } else {
            self.setScanProcessValue(processValue + 15.0)
        }
        
        if(self.scanState == ScanSate.END) {
            timer.invalidate();
            self.stopScan()
            
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
        
        //scan
        if let type = barItem?.type {
            switch  type{
            case XGThreatsType.ALL:
                XGKeychainInstance.scanAllItem()
                XGContainerApplicationManager.sharedInstance.scan()
            case XGThreatsType.keychainHijack:
                XGKeychainInstance.scanAllItem()
            case XGThreatsType.BundleIDHijack:
                XGContainerApplicationManager.sharedInstance.scan()
            default:
                break;
            }
        }
    }
    
    func setScanProcessValue(process: Double) {
        self.scanProcess.doubleValue = process
        
    }
    
    func getScanProcessValue() -> Double{
        return self.scanProcess.doubleValue
    }
    
    func stopScan() {
        //notification to swich
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationScanFinish, object: self.barItem)
        //self.scanButton.title = "SCAN"
        self.scanState =  ScanSate.INIT
        self.scanButton.state = NSOnState
        self.scanPromt.hidden = true
        self.scanProcess.doubleValue = 0
        self.scanProcess.stopAnimation(self)
    }
    
}
