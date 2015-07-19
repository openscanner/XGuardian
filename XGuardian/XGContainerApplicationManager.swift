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
    
    @objc(sharedInstance)
    static let sharedInstance = XGContainerApplicationManager()
    
    let fileManager = NSFileManager.defaultManager()
    var applications = [XGThirdMacApplicationInfo]()
    
    var hijackedApplicationArray = [XGBundleHijackItem]()
    
    private func getSubApplications(url : NSURL ) -> [NSURL] {
        
        var subAppURL = [NSURL]()

    
        var filesURL =  [url]
        while ( filesURL.count > 0) {
            let url = filesURL.removeLast()
            
            var subFiles = fileManager.contentsOfDirectoryAtURL(url,
                includingPropertiesForKeys: [NSURLIsDirectoryKey],
                options: NSDirectoryEnumerationOptions.SkipsHiddenFiles,
                error: nil)
            
            if(nil == subFiles || subFiles?.count == 0) {
                continue
            }
            var subFilesURL =  subFiles as! [NSURL]
            for subFile in subFilesURL {
                if let pathExtension = subFile.pathExtension {
                    if (pathExtension == "app" || pathExtension == "xpc"){
                        subAppURL.append(subFile)
                    } else {
                        filesURL.append(subFile)
                    }
                }
            }
        }
        
        return subAppURL
    }
    
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
        if let bundleID = XGUtilize.getBundleIDFromPath(url.path!) {
            if bundleID.hasPrefix("com.apple") {
                return true
            }
        }
        return false
    }
    
    private func getApplicationsURL() -> NSURL {
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.ApplicationDirectory,
            inDomains:NSSearchPathDomainMask.SystemDomainMask) as! [NSURL]
        let url = urls[0]
        return url
    }
    
    private func getAllThirdApplications() {
        //find all applications in the /Appplication

        //println("urls \(urls)")
        let url = self.getApplicationsURL()
        var applicationsURLAarry = [NSURL]()

        let applicationArray = self.getSubApplications(url)
        if(0 != applicationArray.count) {
            applicationsURLAarry += applicationArray
        } else {
            return
        }
        
        
        //find sub application
        for appURL in applicationsURLAarry {
            //com.apple no need check
            //remove apple's application
            if self.isApple(appURL) {
                continue
            }
            let subAppURLArray = self.getSubApplications(appURL)
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
    
    private func testAddHijack() {
        //TODO : Just for test, please delete
        let appHijackedItem = XGBundleHijackItem(application: self.applications[0])
        appHijackedItem.hijackApplications.append(self.applications[1])
        let appHijackedItem2 = XGBundleHijackItem(application: self.applications[2])
        appHijackedItem.hijackApplications.append(self.applications[3])
        self.hijackedApplicationArray.append(appHijackedItem)
        self.hijackedApplicationArray.append(appHijackedItem2)
        println("\(self.hijackedApplicationArray)")
    }
    
    func scan() {
        //clean
        self.cleanApplications()
        self.hijackedApplicationArray.removeAll(keepCapacity: false)
        
        self.getAllThirdApplications()
        
        //check bundle ID hijack
        self.checkBundleIDHijcak()
 
    }
    
    @objc
    func applicationChanged() {
        self.scan()
        //self.testAddHijack()
        //NSNotificationCenter.defaultCenter().postNotificationName("XGThreadsChangeNotification",object:nil);
    }
    
    func startMoniter() {
        /* Define variables and create a CFArray object containing
        CFString objects containing paths to watch.
        */
        let url = self.getApplicationsURL()
        let path = url.path!
        let appsPathRef = path as CFStringRef
        XGFileEventsHelper.startWatch(appsPathRef)
        
    }
    
}
