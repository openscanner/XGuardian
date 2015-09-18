//
//  XGAllThreatsDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


class XGAllThreatsDelegate:NSObject, XGThreatsViewDelegate {
    
    static let sharedInstance = XGAllThreatsDelegate()
    static func getInstance() -> XGThreatsViewDelegate {
        return sharedInstance
    }
    
    let delegateArray : [XGThreatsViewDelegate] = [
        XGKeychainThreatsDelegate.getInstance(),
        XGBundleIDThreatsDelegate.getInstance(),
        XGURLSchemeThreatsDelegate.getInstance() ]
    
    var topArray = [NSString]()
    override init() {
        super.init()
        
        for delegate in self.delegateArray {
            self.topArray.append(delegate.title as NSString)
        }
    }
    
    //MARK: threats view delegate
    var title : String { get {
        return "All Scan"
        }}
    
    func addNotificationObserver() {
        for delegate in self.delegateArray {
            delegate.addNotificationObserver?()
        }
    }
    
    func removeNotificationObserver() {
        for delegate in self.delegateArray {
            delegate.removeNotificationObserver?()
        }
    }
    
    func refreshThreatsData() -> Int {
        var numberOfThreats = 0
        for delegate in self.delegateArray {
            numberOfThreats += delegate.refreshThreatsData()
        }
        return numberOfThreats
    }
    
    func isExpandable(item: AnyObject?) -> Bool {
        if let title = item as? NSString {
            if self.topArray.contains(title) {
                return true
            }
        }
        return false
    }
    
    func isSelectable(item: AnyObject?) -> Bool {
        if let title = item as? NSString {
            if self.topArray.contains(title) {
                return false
            }
        }
        return true
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
