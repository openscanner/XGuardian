//
//  XGAllThreatsDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

@objc(XGAllThreatsDelegate)
class XGAllThreatsDelegate: XGThreatsViewDelegate {
    
    static let sharedInstance = XGAllThreatsDelegate()
    static func getInstance() -> XGThreatsViewDelegate {
        return sharedInstance
    }
    
    let delegateArray : [XGThreatsViewDelegate] = [
        XGKeychainThreatsDelegate.getInstance(),
        XGBundleIDThreatsDelegate.getInstance(),
        XGURLSchemeThreatsDelegate.getInstance() ]
    
    var topArray = [NSString]()
    init() {
        for delegate in self.delegateArray {
            self.topArray.append(delegate.title as NSString)
        }
    }
    
    //MARK: threats view delegate
    var title : String { get {
        return "All Scan"
        }}
    
    // optional func addNotificationObserver()
    // optional func removeNotificationObserver()
    
    func refreshThreatsData() -> Int {
        var numberOfThreats = 0
        for delegate in self.delegateArray {
            numberOfThreats += delegate.refreshThreatsData()
        }
        return numberOfThreats
    }
    
    func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        
        if nil == item {
             return self.topArray
        }
        
        if  let key = item as? NSString {
            for delegate in self.delegateArray {
                if  key.isEqualToString(delegate.title) {
                    return delegate.childrenForItem(nil)
                }
            }
        }
        return nil
    }
    
    func setCellView(cellView : NSTableCellView, item: AnyObject, parent : AnyObject? ) {
        if let key = parent  as? NSString {
            for delegate in self.delegateArray {
                if  key.isEqualToString(delegate.title) {
                    delegate.setCellView(cellView, item: item, parent: parent)
                    return
                }
            }
        }
        if  let key = item as? NSString {
            for delegate in self.delegateArray {
                if  key.isEqualToString(delegate.title) {
                    cellView.textField?.objectValue = key
                    return
                }
            }
        }
    }
    
    var threatsNumber : Int { get {
        var numberOfThreats = 0
        for delegate in self.delegateArray {
            numberOfThreats += delegate.threatsNumber
        }
        return numberOfThreats
    } }
    
    func detailsView( threatsViewController : XGThreatsViewController, item : AnyObject?, parent : AnyObject? ) -> NSView? {
        if  let key = parent as? NSString {
            for delegate in self.delegateArray {
                if  key.isEqualToString(delegate.title) {
                    return delegate.detailsView(threatsViewController, item: item, parent: parent)
                }
            }
        }
        return nil
    }

}
