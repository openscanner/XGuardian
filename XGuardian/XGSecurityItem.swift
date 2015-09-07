//
//  XGSecurityItem.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/24.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa
import Security


/*
Just for GenericPassword and InternetPassword
*/
@objc(XGSecurityItem)
class XGSecurityItem: NSObject, Printable, DebugPrintable, Equatable, Hashable {

    //*MARK: ClassType
    internal enum ClassType : Printable {
        case InternetPassword
        case GenericPassword
        case Certificate
        case Key
        case Identity
        
        internal func toRaw() -> CFStringRef
        {
            switch self {
            case InternetPassword :return kSecClassInternetPassword
            case GenericPassword  :return kSecClassGenericPassword
            case Certificate      :return kSecClassCertificate
            case Key              :return kSecClassKey
            case Identity         :return kSecClassIdentity
            }
        }
        
        internal static func fromRaw(classType : CFStringRef) -> ClassType
        {
            if( classType == kSecClassInternetPassword) {
                return ClassType.InternetPassword
            } else if (classType == kSecClassGenericPassword) {
                return ClassType.GenericPassword
            } else if (classType == kSecClassCertificate) {
                return ClassType.Certificate
            } else if (classType == kSecClassKey) {
                return ClassType.Key
            } else if (classType == kSecClassIdentity) {
                return ClassType.Identity
            }
            return ClassType.GenericPassword
            /*switch classType {
            case   kSecClassInternetPassword    : return ClassType.InternetPassword
            case   kSecClassGenericPassword 	: return ClassType.GenericPassword
            case   kSecClassCertificate         : return ClassType.Certificate
            case   kSecClassKey                 : return ClassType.Key
            case   kSecClassIdentity            : return ClassType.Identity
            }*/
        }
        
        internal var description: String { get {
            switch self {
            case InternetPassword:          return "Internet Password"
            case GenericPassword:           return "Generic Password"
            case Certificate:               return "Certificate"
            case Key:                       return "Key"
            case Identity:                  return "Identity"
            }
            }}
        
    }
    
//*MARK: -
    
    class func protocolFullName(shortName : String ) -> String {
        switch shortName {
        case kSecAttrProtocolFTP as! String        :  return "ftp"
        case kSecAttrProtocolFTPAccount as! String :  return "ftpa"
        case kSecAttrProtocolHTTP as! String      :  return "http"
        case kSecAttrProtocolIRC  as! String      :  return "irc"
        case kSecAttrProtocolNNTP as! String      :  return "nntp"
        case kSecAttrProtocolPOP3 as! String      :  return "pop3"
        case kSecAttrProtocolSMTP as! String      :  return "smtp"
        case kSecAttrProtocolSOCKS as! String     :  return "socks"
        case kSecAttrProtocolIMAP  as! String     :  return "imap"
        case kSecAttrProtocolLDAP  as! String     :  return "ldap"
        case kSecAttrProtocolAppleTalk as! String :  return "atlk" //what's this?
        case kSecAttrProtocolAFP   as! String     :  return "afp"
        case kSecAttrProtocolTelnet  as! String   :  return "telnet"
        case kSecAttrProtocolSSH     as! String   :  return "ssh"
        case kSecAttrProtocolFTPS    as! String   :  return "ftps"
        case kSecAttrProtocolHTTPS    as! String  :  return "https"
        case kSecAttrProtocolHTTPProxy as! String :  return "httpProxy"
        case kSecAttrProtocolHTTPSProxy as! String:  return "httpsProxy"
        case kSecAttrProtocolFTPProxy   as! String:  return "ftpProxy"
        case kSecAttrProtocolSMB        as! String:  return "smb"
        case kSecAttrProtocolRTSP       as! String:  return "rtsp"
        case kSecAttrProtocolRTSPProxy as! String :  return "rtspProxy"
        case kSecAttrProtocolDAAP    as! String   :  return "daap"
        case kSecAttrProtocolEPPC  as! String     :  return "eppc"
        case kSecAttrProtocolIPP    as! String    :  return "ipp"
        case kSecAttrProtocolNNTPS  as! String    :  return "nntps"
        case kSecAttrProtocolLDAPS   as! String   :  return "ldaps"
        case kSecAttrProtocolTelnetS as! String   :  return "telnets"
        case kSecAttrProtocolIMAPS    as! String  :  return "imaps"
        case kSecAttrProtocolIRCS     as! String  :  return "ircs"
        case kSecAttrProtocolPOP3S  as! String    :  return "pop3s"
        default: return shortName
        }
    }
    
 //*MARK: -
    

    
    class XGSecurityItemApp: NSObject {
        var type : XGSecurityAppType = XGSecurityAppType.Unknown
        var fullPath: String = ""
        
        init(path : String, _ type : XGSecurityAppType) {
            self.fullPath = path
            self.type = type
        }
    }
    
//*MARK: -
    
    var name: String?
    var classType: ClassType?
    var position: String?
    var account: String?
    var desc: String?
    var createTime: NSDate?
    var modifyTime: NSDate?
    var creator : NSNumber?
    var applicationList: [String]?
    var applicationNum: Int = 0
    var itemRef : SecKeychainItemRef?
    var keychain : String?
    var applicationTypeList : [XGSecurityAppType]?

//*MARK: -
    
    @objc(init:)
    init(attrDict:NSDictionary) {
        
        // lable -> name
        if let label = attrDict[kSecAttrLabel as NSString] as? NSString {
            self.name = label as String
        }
        
        // class - 分类 
        if let kclass  = attrDict[kSecClass as NSString] as? NSString  {
            self.classType = ClassType.fromRaw(kclass as CFStringRef)
            
            //position
            if self.classType == ClassType.GenericPassword {
                if let svce = attrDict[kSecAttrService as NSString] as? NSString {
                    self.position = svce as String
                }
            } else if self.classType == ClassType.InternetPassword {
                let srvr = attrDict[kSecAttrServer as NSString] as? String
                let ptcl = attrDict[kSecAttrProtocol as NSString] as? String
                let path = attrDict[kSecAttrPath as NSString] as? String
                
                if ((srvr != nil)  && (ptcl != nil ))
                {
                    //Protocol String should chang with fullname
                    var position: String = XGSecurityItem.protocolFullName(ptcl!) + "://" + srvr!
                    if (path != nil) { position += path! }
                    self.position = position
                }
            }
            
        }
        
        // account
        if let account = attrDict[kSecAttrAccount as NSString] as? NSString {
            self.account = account as String
        }
        
        // descprtion
        if let desc = attrDict[kSecAttrDescription as NSString] as? NSString {
            self.desc = desc as String
        }
        
        // create time 
        if let ctime = attrDict[kSecAttrCreationDate as NSString] as? NSDate {
            self.createTime = ctime
        }
        
        // modify time
        if let mtime = attrDict[kSecAttrModificationDate as NSString] as? NSDate {
            self.modifyTime = mtime
        }
        
        // creator "crtr"
        if let creator = attrDict[kSecAttrCreator as NSString] as? NSNumber {
            self.creator = creator
        }
        
        // itemRef
        let item = attrDict["v_Ref"] as! SecKeychainItemRef
        self.itemRef = item
        let appRet = Keychain.secGetAppList(itemRef:item)
        if(appRet.status == Keychain.ResultCode.errSecSuccess){
            if (nil == appRet.appList) || (appRet.appList!.count == 0) {
                self.applicationNum = 0;
            } else if appRet.appList?.first == Keychain.secAuthorizeAllApp {
                self.applicationNum = -1; //any application can accesss
            } else {
                self.applicationNum = appRet.appList!.count;
            }
            self.applicationList = appRet.appList;
        }        
        
        /*if let access = attrDict[kSecAttrAccess as NSString] as? SecAccessRef {
            self.access = access
        }*/

        super.init()
        return
    }

//*MARK: -
    
    @objc(isSameWith:)
    func isSameWith(otherItem: XGSecurityItem) -> Bool {
        
        if (self.applicationNum != otherItem.applicationNum
            || self.creator != otherItem.creator) {
                return false
        }
        
        let samekey = self.isSameKey(otherItem)
        if !samekey {
            return false
        }
        
        return true;
    }
    
    func isLikely() -> Bool {
        
        //check application numbers
        if ( self.applicationNum <= 1  ){
            return false;
        }
        
        
        if (nil == self.applicationList ) {
            return false;
        }
        
        var appList = self.applicationList!
        var leftApps = [String]()
        var leftAppNum = appList.count
        
        var applicationTypeList = [XGSecurityAppType](count: leftAppNum, repeatedValue: XGSecurityAppType.Unknown )
        
        //check is apple
        var OK_nubmer = 0
        for ( var i = 0; i <  appList.count ; i++ ){
            let type = XGUtilize.checkApple(appList[i])
            //if(appList[i].hasSuffix("airportd")) {
            //    print(appList[i])
            //    println(type)
            //}
            applicationTypeList[i] = type
            if (XGSecurityAppType.Group == type || XGSecurityAppType.Apple == type  ){
                OK_nubmer = 1
            }
            if (XGSecurityAppType.Group == type || XGSecurityAppType.Apple == type || XGSecurityAppType.WhiteList == type ){
                leftAppNum -= 1
                if appList[i].lastPathComponent.hasPrefix("Keychain Access.app") {
                    leftAppNum -= 1
                }
            } else {
                leftApps.append(appList[i])
            }
        }
        
        
        if ( (OK_nubmer + leftAppNum) <= 1 ) {
            return false
        }
        
        //check is same
        while leftApps.count > 1 {
            let appLast = leftApps.removeLast()
            
            for appOther in leftApps {
                if(appOther.hasPrefix(appLast) || appLast.hasPrefix(appOther)) {
                    leftAppNum--
                }
            }
        }
        
        if ( (OK_nubmer + leftAppNum) <= 1 ) {
            return false
        }
        
        //TODO: check same sining

        self.applicationTypeList = applicationTypeList
        return true

    }
    
    /**
    Check the key is the same
    
    :param: key another key for check
    
    :returns: ture for same, otherwise is false
    */
    func isSameKey (key: XGSecurityItem?) -> Bool {
        if (nil == key) {
            return false
        } else if (key === self) {
            return true
        }
        
        if( (key!.name == self.name) &&
            (key!.classType == self.classType) &&
            (key!.account == self.account) &&
            (key!.position == self.position)
            ) {
            return true
        }
        
        return false
    }
    
    override func key() -> String {
        var key = "key-"
        if(nil != self.name) { key += self.name! }
        if(nil != self.account) { key += self.account! }
        if(nil != self.position) { key += self.position! }
        return key
    }
    
    
    override var hashValue: Int { get {
        return self.key().hashValue;
        }
    }
    

    override var description : String {
        var descStr = ""
        if(self.name != nil) { descStr = "Name: \(self.name!)\n" }
        if(self.account != nil)  { descStr += "Account: \(self.account!) \n" }
        if(self.classType != nil) { descStr += "Class: \(self.classType!) \n" }
        if(self.position != nil) {descStr += "Position: \(self.position!) \n"}
        if(self.desc != nil) { descStr += "Description: \(self.desc!) \n" }
        if(self.createTime != nil) { descStr += "Creation Time: \(self.createTime!) \n" }
        if(self.modifyTime != nil) { descStr += "Modified Time: \(self.createTime!) \n" }
        if(self.creator != nil) {descStr += "Creator: \(self.creator!) \n"}
        
        if(self.applicationNum == -1){
            descStr += "Authorized Applications: Any\n"
        } else if (self.applicationNum == 0) {
            descStr += "Authorized Applications: None\n"
        } else {
            descStr += "Authorized Applications: \n"
            if let al = self.applicationList {
                for str in al {
                    descStr += "        \(str)\n"
                }
            }
        }
        
        return descStr
    }
    

    override var debugDescription : String {
        return self.description
    }
    
}

func == (lhs: XGSecurityItem, rhs: XGSecurityItem) -> Bool {
    let samekey = lhs.isSameKey(rhs)
    if !samekey {
        return false
    }
    
    if (lhs.applicationNum != rhs.applicationNum
        || lhs.createTime != rhs.createTime
        || lhs.creator != rhs.creator) {
        return false
    }
    
    if(lhs.applicationNum != rhs.applicationNum) {
        return false;
    }
    
    return true;
    
}


