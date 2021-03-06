//
//  XGURLSchemeThreatsDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


class XGURLSchemeThreatsDelegate:NSObject, XGThreatsViewDelegate {
    
    static let sharedInstance = XGURLSchemeThreatsDelegate()
    static func getInstance() -> XGThreatsViewDelegate {
        return sharedInstance
    }
    
    weak var URLSchemeDict : XGURLSchemeDict?
    
    //MARK: threats view delegate
    var title : String { get {
        return "URL Scheme"
        }}
    
    // optional func addNotificationObserver()
    // optional func removeNotificationObserver()
    
    func refreshThreatsData() -> Int {
        self.URLSchemeDict = XGURLSchemeManager.sharedInstance.urlSchemeThreatsDict
        
        if let count = self.URLSchemeDict?.dataDict.count {
            return count
        }
        return 0
    }
    
    func isExpandable(item: AnyObject?) -> Bool {
        return false
    }
    
    func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        if nil != item {
            return nil
        }

        if let schemeStringArray = self.URLSchemeDict?.dataDict.keys.sort({$0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending}) {
            return schemeStringArray as [NSString]
        }
        return nil
    }
    
    func setCellView(cellView : NSTableCellView, item: AnyObject, parent : AnyObject? ) {
        cellView.textField?.objectValue = item // + "://"
        cellView.imageView?.hidden = true
    }
    
    var threatsNumber : Int { get {
        if let count = self.URLSchemeDict?.dataDict.count {
            return count
        }
        return 0
        } }
    
    func detailsView( threatsViewController : XGThreatsViewController, item : AnyObject? , parent : AnyObject? ) -> NSView? {
        if let scheme =  item as? NSString {
            let currentdetailViewController = NSViewController(nibName: "XGURLSchemeHijackDetailsView", bundle: nil)
            
            if let view = currentdetailViewController?.view as? XGURLSchemeDetailsView{
                view.scheme = scheme as String
                view.appFullPaths = self.URLSchemeDict?.dataDict[scheme as String]
                view.upperViewController = threatsViewController
                return view
            }
        }
        return nil
    }
}
