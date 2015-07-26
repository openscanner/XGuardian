//
//  XGBundleIDThreatsDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

@objc(XGBundleIDThreatsDelegate)
class XGBundleIDThreatsDelegate: XGThreatsViewDelegate {

    static let sharedInstance = XGBundleIDThreatsDelegate()
    static func getInstance() -> XGThreatsViewDelegate {
        return sharedInstance
    }
    
    private var bundleItemArray : [XGBundleHijackItem]?
    
    //MARK: threats view delegate
    var title : String { get {
        return "BundleID Hijack"
        }}
    
    // optional func addNotificationObserver()
    // optional func removeNotificationObserver()
    
    func refreshThreatsData() -> Int {
        self.bundleItemArray = XGContainerApplicationManager.sharedInstance.hijackedApplicationArray
        if (nil == self.bundleItemArray) {
            return 0
        }
        
        return self.bundleItemArray!.count
    }
    
    func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        if nil != item {
            return nil
        }
        return bundleItemArray
    }
    
    func setCellView(cellView : NSTableCellView, item: AnyObject , parent : AnyObject? ) {
        let bundleItem = item  as! XGBundleHijackItem
        cellView.textField?.objectValue = bundleItem.application.bundleID
        cellView.imageView?.objectValue = NSWorkspace.sharedWorkspace().iconForFile(bundleItem.application.fullPath)
    }
    
    var threatsNumber : Int { get {
        if let array = self.bundleItemArray {
            return array.count
        }
        return 0
        } }
    
    func detailsView( threatsViewController : XGThreatsViewController, item : AnyObject?, parent : AnyObject?  ) -> NSView? {
        if let bundleItem =  item as? XGBundleHijackItem {
            let currentdetailViewController = NSViewController(nibName: "XGBundleDetailsView", bundle: nil)
            
            if let view = currentdetailViewController?.view as? XGBundleDetailsView{
                view.bundleHijackItem = bundleItem
                view.upperViewController = threatsViewController
                return view
            }
            return nil
        }
        return nil
    }

}
