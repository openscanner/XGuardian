//
//  XGBackend.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/1.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa
import Alamofire


private let lastedVersionURL = "http://xara.openscanner.cc/version/getLastversion"


@objc public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

extension Alamofire.Request {
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if let response = response, JSON: AnyObject = JSON {
                return (T(response: response, representation: JSON), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }
}

final class XGVersionInfo: NSObject, ResponseObjectSerializable, Printable {
    let version: String?
    let url: String?
    let changeLog : String?
    let md5: String?
    
    @objc required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.version = representation.valueForKeyPath("version") as? String
        self.changeLog = representation.valueForKeyPath("changeLog") as? String
        self.md5 = representation.valueForKeyPath("md5") as? String
        self.url = representation.valueForKeyPath("versionURL") as? String
    }
    
    override var description : String {
        var descStr = ""
        if(self.version != nil)  { descStr += "version: \(self.version!) \n" }
        if(self.changeLog != nil) { descStr += "Class: \(self.changeLog!) \n" }
        if(self.url != nil) {descStr += "downloadURL: \(self.url!) \n"}
        if(self.md5 != nil) { descStr += "md5: \(self.md5!) \n" }
        return descStr
    }
}

private var lastedVersion : XGVersionInfo?

class XGBackend: NSObject {

   // var httpManager = AFHTTPRequestOperationManager.manager()
    class func currentVersion() -> String {
        let infoDict = NSBundle.mainBundle().infoDictionary
        let version = infoDict!["CFBundleShortVersionString"] as! String!
        return version
    }
    
    class func getLastedverion() -> XGVersionInfo? {
        return lastedVersion
    }
    
    class func cleanLastedverion() {
        lastedVersion = nil
    }
    
    class func updateLastedverion() {
        let response = Alamofire.request(.GET, lastedVersionURL)
            .responseObject { (_, _, versionInfo: XGVersionInfo?, _) in
                XGBackend.update(versionInfo)
        }
       return
    }
    
    class func update(versionInfo:XGVersionInfo?) {
        if let version = versionInfo {
            
            let currentVersion = XGBackend.currentVersion()
            NSLog("currentVersion:\(currentVersion)")
                 
            //don't update
            if (nil != lastedVersion) && (version.version == lastedVersion!.version) {
                return
            }
            //check current version
            if (version.version == currentVersion) {
                return
            }
            lastedVersion = version
            println(versionInfo)
            let updatePanel = XGUpdatePanel(windowNibName: "UpdateWindow")
            //updatePanel.loadWindow()
            updatePanel.panelShow()
            
        }
    }
    
    class func openURL(urlStr : String!  ) {
        
        let url = NSURL(string: urlStr)!
        let cfUrl = url as CFURL;

        LSOpenCFURLRef(cfUrl,nil);
        //CFRelease(url);
        return
    }

    
    class func downloadLastedVersion() {
      /*  let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DownloadsDirectory, domain: .UserDomainMask)*/
        if lastedVersion != nil && lastedVersion?.url != nil {
            openURL(lastedVersion!.url)
/* Alamofire.download(.GET, lastedVersion!.url!, destination)
                .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                    println(totalBytesRead)
                }
                .response { (request, response, _, error) in
                    println(response)
            }*/
        }
    }
    
}
