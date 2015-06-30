//
//  XGSecurityItemSet.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/27.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGSecurityItemSet: NSObject {
    
    //use XGSecurityItem.key() as keys:
    var itemDict:Dictionary<String, XGSecurityItem> =  Dictionary<String, XGSecurityItem>(minimumCapacity: 8)
    
    var count: Int { get { return self.itemDict.count}}
    var isEmpty : Bool { get {
        return self.itemDict.isEmpty
    } }
    
    func addItem( item : XGSecurityItem) {
        self.itemDict[item.key()] = item
    }
    
    func removeItem(item : XGSecurityItem) {
        self.itemDict.removeValueForKey(item.key())
    }
    
    func findItem(item : XGSecurityItem) -> XGSecurityItem? {
        return self.itemDict[item.key()]
    }
    
    func toArray() -> [XGSecurityItem] {
        /*var valueDict =  self.itemDict as NSDictionary
        return valueDict.allValues  as? [XGSecurityItem] */
        var valueArray = [XGSecurityItem]()
        
        for item in self.itemDict.values {
           valueArray.append(item)
        }
        return  valueArray;
    }
    
    private func checkValidApp(fullPath : String ) -> Bool {
        
        var ref : Unmanaged<SecStaticCode>?
        
        //let urlStr = "file://"+ fullPath
       /*  let url = NSURL(fileURLWithPath: fullPath)
        let status = SecStaticCodeCreateWithPath(url! as CFURL!, kSecCSDefaultFlags, &ref)
        if status != errSecSuccess {
            return false
        }
       SecStaticCodeCheckValidity(_ staticCode: SecStaticCode!, _ flags: SecCSFlags, _ requirement: SecRequirement!) -> OSStatus*/
        /*
CFDictionaryRef dictRef = NULL;
status = SecCodeCopySigningInformation( ref, kSecCSSigningInformation, &dictRef );
if (noErr != status
|| NULL == dictRef)
{
return ret;
}

NSArray *cerArray
= (NSArray *)CFDictionaryGetValue( dictRef, kSecCodeInfoCertificates );
if (nil == cerArray
|| 0 == [cerArray count])
{
return ret;
}

SecCertificateRef cert = (SecCertificateRef)[cerArray lastObject];
CFStringRef subjectSummary;
//    if ([XXX isSysemVersion10_5])
//    {
SecCertificateCopyCommonName( cert, &subjectSummary );
//    }
//    else
//    {
//    subjectSummary = SecCertificateCopySubjectSummary( cert );
//    }

*/

        return true
    }

    func getPotentialArray() -> [XGSecurityItem] {
        /*var valueDict =  self.itemDict as NSDictionary
        return valueDict.allValues  as? [XGSecurityItem] */
        var valueArray = [XGSecurityItem]()
        
        for item in self.itemDict.values {
            if(item.applicationNum != 1){
                //TODO : valid checking should be add
                valueArray.append(item)
            }
        }
        return  valueArray;
    }
    
//    func removeItemAtIndex() {
//      self.itemDict.removeAtIndex(index: );
//    }
}
