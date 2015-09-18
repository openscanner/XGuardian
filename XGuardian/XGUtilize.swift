//
//  XGUtilize.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/16.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


enum XGSecurityAppType: Int ,CustomStringConvertible{
    case Unknown = 0
    case WhiteList = 1
    case Sining = 2
    case Group = 3
    case Apple = 4
    
    internal var description: String { get {
        switch self {
        case Unknown:           return "Unknown"
        case WhiteList:         return "WhiteList"
        case Sining:            return "Sining"
        case Group:             return "Group"
        case Apple:             return "Apple"
        }
        }}
}



class XGUtilize: NSObject {
    
    class func getSubApplications(url : NSURL ) -> [NSURL] {
        
        var subAppURL = [NSURL]()
        
        var filesURL =  [url]
        while ( filesURL.count > 0) {
            let url = filesURL.removeLast()
            
            let subFiles = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(url,
                includingPropertiesForKeys: [NSURLIsDirectoryKey],
                options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            
            if(nil == subFiles || subFiles?.count == 0) {
                continue
            }
            
            for subFile in subFiles! {
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
    
    class func getSystemApplicationsURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.ApplicationDirectory,
            inDomains:NSSearchPathDomainMask.SystemDomainMask) 
        let url = urls[0]
        return url
    }
    
    class func getApplications(domainMask: NSSearchPathDomainMask) -> [NSURL] {

        var applicationsURLAarry = [NSURL]()
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.ApplicationDirectory,
            inDomains:domainMask) 
        
        for  url in urls {
            let applicationArray = self.getSubApplications(url)
            if(0 != applicationArray.count) {
                applicationsURLAarry += applicationArray
            }
        }
        return applicationsURLAarry
    }
    
    /// get application's bundle ID from applicaion's URL
    class func getBundleIDFromURL(appURL : NSURL) -> String? {
        var secStaticCode : SecStaticCode?
        let cfUrl = appURL as CFURL
        
        
        var status = SecStaticCodeCreateWithPath(cfUrl , SecCSFlags.DefaultFlags /*0*/, &secStaticCode)
        if status != errSecSuccess || secStaticCode == nil {
            NSLog("BundleID From URL:\(appURL) SecStaticCodeCreateWithPath error:\(status)")
            return nil
        }
        
        
        var dictRef : CFDictionary?
        status = SecCodeCopySigningInformation(secStaticCode!, SecCSFlags(rawValue: kSecCSSigningInformation), &dictRef )
        if status != errSecSuccess || dictRef == nil {
            NSLog("BundleID From URL:\(appURL) SecCodeCopySigningInformation error:\(status)")
            return nil
        }
        let signingInfoDict = dictRef as! NSDictionary;
        
        if let identifier = signingInfoDict[kSecCodeInfoIdentifier as NSString] as? String {
            return identifier
        }
        
        return nil
    }
    
    /// get application's bundle ID from applicaion's full path
    class func getBundleIDFromPath(appFullPath : String) -> String? {
        let url = NSURL(fileURLWithPath: appFullPath)
        return self.getBundleIDFromURL(url)
    }
    
    //
    class func getURLSchemeFromURL(appURL : NSURL) -> [String]? {
        var secStaticCode : SecStaticCode?
        let cfUrl = appURL as CFURL;
        
        var status = SecStaticCodeCreateWithPath(cfUrl , SecCSFlags.DefaultFlags /*0*/, &secStaticCode)
        if status != errSecSuccess || secStaticCode == nil {
            return nil
        }
        
        
        var dictRef : CFDictionary?
        status = SecCodeCopySigningInformation(secStaticCode!, SecCSFlags(rawValue: kSecCSSigningInformation), &dictRef )
        if status != errSecSuccess || dictRef == nil {
            return nil
        }
        
        let signingInfoDict = dictRef! as NSDictionary;
        
        var urlSchemes = [String]()
        if let infoPList = signingInfoDict[kSecCodeInfoPList as NSString] as? NSDictionary {
            if let urlTypes = infoPList["CFBundleURLTypes"] as? [NSDictionary] {
                //print(urlTypes)
                for urlType in urlTypes {
                    if let urls = urlType["CFBundleURLSchemes"] as? [String] {
                        urlSchemes += urls
                    }
                }
            }
        }
        
        if urlSchemes.count > 0 {
            return urlSchemes
        }
        return nil
    }
    
    class func getURLSchemeFromPath(appFullPath : String) -> [String]? {
        let url = NSURL(fileURLWithPath: appFullPath)
        return self.getURLSchemeFromURL(url)
    }
    
    
    private static let appWhiteList = ["com.google.Chrome",
        "com.operasoftware.Opera",
        "com.dashlane.Dashlane"]  //"com.agilebits.onepassword4"
    
    class func checkWhiteList(bundleID : String) -> Bool {
        return appWhiteList.contains(bundleID)
        /*for appBundle in appWhiteList {
            if appBundle == bundleID {
                return true
            }
        }
        return false*/
    }
    
    class func checkApple(appFullPath: String) -> XGSecurityAppType {
        
        if appFullPath.hasPrefix("group:") {
            return XGSecurityAppType.Group
        }
        
        //TODO : change String compare
        let ia = "InternetAccounts"
        if appFullPath == ia {
            return XGSecurityAppType.Apple
        }
        
        if let identifier = XGUtilize.getBundleIDFromPath(appFullPath){
            if identifier.hasPrefix("com.apple") {
                return XGSecurityAppType.Apple
            } else if checkWhiteList(identifier) {
                return XGSecurityAppType.WhiteList
            }
            else {
                return XGSecurityAppType.Sining
            }
        }
        
        return XGSecurityAppType.Unknown
    }
    
}
