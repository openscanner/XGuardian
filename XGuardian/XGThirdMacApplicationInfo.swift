//
//  XGThirdMacApplicationInfo.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/16.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


class XGThirdMacApplicationInfo: NSObject , Printable {
    var fullPath : String = ""
    var bundleID : String = ""
    var subApplications: [XGThirdMacApplicationInfo]?
    
    init?(fullPath : String) {
        super.init()
        
        if let bundleID = XGUtilize.getBundleIDFromPath(fullPath) {
            self.fullPath = fullPath
            self.bundleID = bundleID
        } else {
            return nil
        }
    }
    
    func addSubApp(subApp : XGThirdMacApplicationInfo) {
        if nil == self.subApplications {
            self.subApplications = [XGThirdMacApplicationInfo]()
        }
        self.subApplications?.append(subApp)
    }
    
    func getSubApps() -> [XGThirdMacApplicationInfo]? {
        return self.subApplications
    }
    
    override var description : String {
        var desc = "Application: \(self.fullPath)\nBundleID: \(self.bundleID)\n"
        if let subApplications = self.subApplications {
            desc += "Sub Applications:\n"
            for sub in subApplications {
                desc += "    \(sub.description)\n"
            }
        }
        
        return desc
    }
    
    
}
