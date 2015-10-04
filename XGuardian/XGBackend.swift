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


public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

extension Request {
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<T>) -> Void) -> Self {
        let responseSerializer = GenericResponseSerializer<T> { request, response, data in
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data)
            
            switch result {
            case .Success(let value):
                if let
                    response = response,
                    responseObject = T(response: response, representation: value)
                {
                    return .Success(responseObject)
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(data, error)
                }
            case .Failure(let data, let error):
                return .Failure(data, error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}


final class XGVersionInfo: NSObject, ResponseObjectSerializable {
    let version: String?
    let url: String?
    let changeLog : String?
    let md5: String?
    
    @objc required init?(response: NSHTTPURLResponse,representation: AnyObject) {
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
        _ = Alamofire.request(.GET, lastedVersionURL)
            .responseObject { (_, _, versionInfo: Result<XGVersionInfo>) in
                XGBackend.update(versionInfo.value)
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
            print(versionInfo)

            XGUpdatePanel.panelShow()
            
        }
    }
    
    class func openURL(urlStr : String!  ) {
        
        let url = NSURL(string: urlStr)!
        let cfUrl = url as CFURL;

        LSOpenCFURLRef(cfUrl,nil);
        return
    }

    
    class func downloadLastedVersion() {

        if lastedVersion != nil && lastedVersion?.url != nil {
            openURL(lastedVersion!.url)

        }
    }
    
}
