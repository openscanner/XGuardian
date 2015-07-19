//
//  XGUtilize.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/16.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGUtilize: NSObject {

    class func getBundleIDFromPath(appFullPath : String) -> String? {
        var ref : Unmanaged<SecStaticCode>?
        let url = NSURL(fileURLWithPath: appFullPath)!
        
        
        let cfUrl = url as CFURL;
        
        
        var status = SecStaticCodeCreateWithPath(cfUrl , SecCSFlags(kSecCSDefaultFlags) /*0*/, &ref)
        if status != errSecSuccess || ref == nil {
            return nil
        }
        
        let secStaticCode = ref!.takeRetainedValue() as SecStaticCode;
        
        var dictRef : Unmanaged<CFDictionary>?
        status = SecCodeCopySigningInformation(secStaticCode, SecCSFlags(kSecCSSigningInformation), &dictRef )
        if status != errSecSuccess || dictRef == nil {
            return nil
        }
        let signingInfoDict = dictRef!.takeRetainedValue() as NSDictionary;
        
        if let identifier = signingInfoDict[kSecCodeInfoIdentifier as NSString] as? String {
            return identifier
        }
        
        return nil
    }
}
