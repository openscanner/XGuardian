//
//  XGKeychainThreatsDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

@objc(XGKeychainThreatsDelegate)
class XGKeychainThreatsDelegate: XGThreatsViewDelegate {
    
    static let sharedInstance = XGKeychainThreatsDelegate()
    static func getInstance() -> XGThreatsViewDelegate {
        return sharedInstance
    }
    
    private var hijackedItemArray : [XGSecurityItem]?
    
    //MARK: threats view delegate
    var title : String { get {
        return "keychain Hijack"
        }}
    
    // optional func addNotificationObserver()
    // optional func removeNotificationObserver()
    
    func refreshThreatsData() -> Int {
        XGKeychainInstance.scanAllItem()
        if let hijackedItemArray = XGKeychainInstance.getHijackedItemArray() {
            self.hijackedItemArray = hijackedItemArray
            return hijackedItemArray.count
        } else {
            self.hijackedItemArray = nil
            return 0
        }
    }
    
    func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        if nil != item {
            return nil
        }
        return self.hijackedItemArray
    }
    
    func setCellView(cellView : NSTableCellView, item: AnyObject, parent : AnyObject? ) {
        let secItem = item as! XGSecurityItem
        cellView.textField?.objectValue = secItem.name
        if secItem.classType == XGSecurityItem.ClassType.InternetPassword {
            cellView.imageView?.objectValue = NSImage(named: NSImageNameUserAccounts)
        } else {
            cellView.imageView?.objectValue = NSImage(named:NSImageNameUser)
        }
    }
    
    var threatsNumber : Int { get {
        if let hijackedItemArray = self.hijackedItemArray {
            self.hijackedItemArray = hijackedItemArray
            return hijackedItemArray.count
        }
        return 0
    } }
    
    func detailsView( threatsViewController : XGThreatsViewController, item : AnyObject?, parent : AnyObject?  ) -> NSView? {
        if let secItem =  item as? XGSecurityItem {
            let currentdetailViewController = NSViewController(nibName: "KeychainHijackDetailsView", bundle: nil)
            
            if let view = currentdetailViewController?.view as? XGKeychainHijackDetailsView{
                view.secItem = secItem
                view.upperViewController = threatsViewController
                return view
            }
        }
        return nil
    }
}
