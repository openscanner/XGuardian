//
//  XGURLSchemeManager.swift
//  XGuardian
//
//  Created by WuYadong on 15/7/22.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGApplicationURLScheme {
    let appFullPath : String
    let urlSchemes : [String]
    
    init(appFullPath : String , urlSchemes : [String] ) {
        self.appFullPath = appFullPath
        self.urlSchemes = urlSchemes
    }
}

class XGURLSchemeDict:NSObject {
    var dataDict = [String:[String]]()
}

class XGURLSchemeManager: NSObject {

    static let sharedInstance = XGURLSchemeManager()
    
    var urlSchemeApplications = [String:[String]]()
    var urlSchemeMultiDict = XGURLSchemeDict()
    
    private static let commonSchemeList = ["http",
        "https",
        "ftp",
        "sftp",
        "rtsp",
        "file",
        "ssh",
        "mailto",
        "sms",
        "tel",
        "telnet",
        "x-man-page", //open manul page
    ]
    
    private static let privateSchemeList = ["qq",
        "tencent"
    ]
    
    private func addSchemeApplication(scheme : String, app : String) {
        if urlSchemeApplications[scheme] ==  nil {
            urlSchemeApplications[scheme] = [app]
        } else {
            urlSchemeApplications[scheme]?.append(app);
        }
    }
    
    func scan() {
        
        self.urlSchemeApplications.removeAll(keepCapacity: true)
        
        //get all applications
        let allApplications = XGUtilize.getApplications(NSSearchPathDomainMask.SystemDomainMask |
            NSSearchPathDomainMask.UserDomainMask | NSSearchPathDomainMask.LocalDomainMask)
        
        //get all applications URL scheme, and put in dictionary
        for app in allApplications {
            if let schemes = XGUtilize.getURLSchemeFromURL(app) {
                for scheme in schemes {
                    self.addSchemeApplication(scheme, app: app.path!)
                }
            }
        }
        
        //print(self.urlSchemeApplications)
        
        //scan same URL scheme hijack
        for (scheme, apps) in urlSchemeApplications {
            
            //check application number
            if apps.count <= 1 {
                continue
            }
            
            //check common shcheme
            if contains(XGURLSchemeManager.commonSchemeList, scheme) {
                continue
            }
            self.urlSchemeMultiDict.dataDict[scheme] = apps
        }

    }
    
    func getDefaultApplication(scheme : String ) -> String? {
        if let url = NSURL(scheme: scheme, host: nil, path: "/a") {
            if let appURL = NSWorkspace.sharedWorkspace().URLForApplicationToOpenURL(url) {
                return appURL.path
            }
        }
        return nil
    }
    
    func setDefaultApplication(scheme: String , appFullPath : String ) -> Bool {
        if let bundle = XGUtilize.getBundleIDFromPath(appFullPath) {
            let status = LSSetDefaultHandlerForURLScheme(scheme as CFString, bundle)
            if status != errSecSuccess {
                NSLog("set URL scheme: \(scheme) default application to \(appFullPath) error: \(status)")
            } else {
                return true
            }
            
        }
        
        return false
    }
    
}
