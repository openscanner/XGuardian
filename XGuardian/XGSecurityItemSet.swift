//
//  XGSecurityItemSet.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/27.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

@objc(XGSecurityItemSet)
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
    
    @objc(findItem:)
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
    


    func getPotentialArray() -> [XGSecurityItem] {
        /*var valueDict =  self.itemDict as NSDictionary
        return valueDict.allValues  as? [XGSecurityItem] */
        var valueArray = [XGSecurityItem]()
        
        for item in self.itemDict.values {
            if(item.islikely()){
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
