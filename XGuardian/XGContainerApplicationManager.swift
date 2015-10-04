//
//  XGContainerApplicationManager.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/16.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


let XGApplicationPath = "/Applications"
let XGApplicationExtensions = [".app", ".xpc"]


class XGBundleHijackItem : NSObject {
    var application : XGThirdMacApplicationInfo
    var hijackApplications = [XGThirdMacApplicationInfo]()
    
    init( application : XGThirdMacApplicationInfo ){
        self.application = application
        super.init()
    }
}

@objc(XGContainerApplicationManager)
class XGContainerApplicationManager: NSObject {
    
    //single
    @objc(sharedInstance)
    static let sharedInstance = XGContainerApplicationManager()

    var applications = [XGThirdMacApplicationInfo]()
    var hijackedApplicationArray = [XGBundleHijackItem]()
    private var scanProcess = 0.0
    
    private func savApplication( url : NSURL, subApps : [NSURL]?) {
        if let app = XGThirdMacApplicationInfo(fullPath: url.path!) {
            self.applications.append(app)
            
            if let subAppsURL = subApps {
                for subAppURL in subAppsURL {
                    if let subApp = XGThirdMacApplicationInfo(fullPath: subAppURL.path!) {
                        app.addSubApp(subApp)
                    }
                }
            }
        }
    }
    
    private func cleanApplications() {
        self.applications.removeAll(keepCapacity: true)
    }
    
    private func isApple(url : NSURL ) -> Bool {
        if let bundleID = XGUtilize.getBundleIDFromURL(url) {
            if bundleID.hasPrefix("com.apple") {
                return true
            }
        }
        return false
    }
    
    
    
    private func getAllThirdApplications() {
        
        //find all applications in the /Appplication
        let applicationsURLAarry = XGUtilize.getApplications(NSSearchPathDomainMask.SystemDomainMask)
        
        
        //find sub application
        for appURL in applicationsURLAarry {
            //com.apple no need check
            //remove apple's application
            if self.isApple(appURL) {
                continue
            }
            let subAppURLArray = XGUtilize.getSubApplications(appURL)
            self.savApplication(appURL , subApps : subAppURLArray)
        }
    }
    
    private func checkBundleIDHijcak() {
        var appBundleDict = [String : XGThirdMacApplicationInfo]()
        for appInfo in self.applications {
            appBundleDict[appInfo.bundleID] = appInfo
        }
        
        for appInfo in self.applications {
            if let subApplications = appInfo.subApplications  {
                for sub_app in subApplications {
                    if let appHijacked = appBundleDict[sub_app.bundleID]{
                        if appInfo != appHijacked {
                            let appHijackedItem = XGBundleHijackItem(application: appHijacked)
                            appHijackedItem.hijackApplications.append(sub_app)
                            self.hijackedApplicationArray.append(appHijackedItem)
                        }
                    }
                }
            }
        }
    }
    
    
    private func backendScan() {
        //clean
        self.scanProcess = 0.0
        self.cleanApplications()
        self.hijackedApplicationArray.removeAll(keepCapacity: false)
        self.scanProcess = 5.0
        
        //
        self.getAllThirdApplications()
        self.scanProcess = 40.0
        
        //check bundle ID hijack
        self.checkBundleIDHijcak()
        
        self.scanProcess = 100.0
    }
    
    func scan() {
        self.scanProcess = 0.0
        let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND , 0)
        
        dispatch_async(queue, {
            // DO SOMETHING ON THE MAINTHREAD
            self.backendScan()
        })
        
    }
    
    func getScanProcess() -> Double {
        return self.scanProcess
    }
    
    @objc
    func applicationChanged() {
        self.scan()
    }
    
    func startMoniter() {
        /* Define variables and create a CFArray object containing
        CFString objects containing paths to watch.
        */
        let url = XGUtilize.getSystemApplicationsURL()
        let path = url.path!
        let appsPathRef = path as CFStringRef
        XGFileEventsHelper.startWatch(appsPathRef)
        
    }
    
}
