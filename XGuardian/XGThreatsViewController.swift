//
//  XGThreatsViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/7.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

private let kechainHijackString = "keychain Hijack"
private let bundleIDHijackString = "BundleID Hijack"
private let URLSchemeString = "URL Scheme"


class XGThreatsViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, NSSplitViewDelegate {

    @IBOutlet weak var threatsListView: NSOutlineView!
    @IBOutlet weak var detailView: NSView!
    @IBOutlet weak var titleButton: NSButton!
    
    weak var barItem: XGSideBarItem?
    
    
    //for current selected threat detail informations view controlller
    var currentdetailViewController: NSViewController?
    
    private let topArray = [NSString(string: kechainHijackString ), NSString(string: bundleIDHijackString), NSString(string: URLSchemeString)]
    
    private var kechainItemArray : [XGSecurityItem]?
    private var bundleItemArray : [XGBundleHijackItem]?
    private weak var URLSchemeDict : XGURLSchemeDict?
    
    var threatsType = XGThreatsType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
           //nagivation table view
        self.threatsListView.sizeLastColumnToFit()
        self.threatsListView.floatsGroupRows = true
        
        
        switch self.threatsType {
        case XGThreatsType.ALL:
            self.titleButton?.title = "All Scan"
        case XGThreatsType.keychainHijack:
            self.titleButton.title = kechainHijackString
        case XGThreatsType.BundleIDHijack:
            self.titleButton.title = bundleIDHijackString
        case XGThreatsType.URLScheme:
            self.titleButton.title = URLSchemeString
        default:
            break
        }
        
        
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.threatsListView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        self.addNotificationObserver()
    }
    
     deinit {
        self.removeNotificationObserver()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.refreshThreatsListView()
    }
    
    private func addNotificationObserver() {
        
        //add notification observer for threats change
        
        switch self.threatsType {
        case XGThreatsType.ALL:
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("threatsDidChanged:"), name: "XGKeychainThreadsChangeNotification", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("threatsDidChanged:"), name: "XGBundleIDThreadsChangeNotification", object: nil)
            
        case XGThreatsType.keychainHijack:
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("threatsDidChanged:"), name: "XGKeychainThreadsChangeNotification", object: nil)
            
        case XGThreatsType.BundleIDHijack:
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("threatsDidChanged:"), name: "XGBundleIDThreadsChangeNotification", object: nil)
        
        case XGThreatsType.URLScheme:
            // do nothing
            break
            //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("threatsDidChanged:"), name: "XGBundleIDThreadsChangeNotification", object: nil)
            
        default:
            break
        }
    }
    
    private func removeNotificationObserver() {
        
        switch self.threatsType {
        case XGThreatsType.ALL:
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "XGKeychainThreadsChangeNotification", object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "XGBundleIDThreadsChangeNotification", object: nil)

            
        case XGThreatsType.keychainHijack:
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "XGKeychainThreadsChangeNotification", object: nil)
            
        case XGThreatsType.BundleIDHijack:
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "XGBundleIDThreadsChangeNotification", object: nil)
        
        case XGThreatsType.URLScheme:
            // do nothing
            break
            //NSNotificationCenter.defaultCenter().removeObserver(self, name: "XGBundleIDThreadsChangeNotification", object: nil)

        default:
            break
        }
        //remove notification observer for threats change
       
        
    }
    
    
    private func reloadThreatsData() {
        switch self.threatsType {
        case XGThreatsType.ALL:
            self.reloadKeychainHijack()
            self.reloadBundleHijiack()
            self.reloadURLScheme()
            
        case XGThreatsType.keychainHijack:
            self.reloadKeychainHijack()
            
        case XGThreatsType.BundleIDHijack:
            self.reloadBundleHijiack()
        
        case XGThreatsType.URLScheme:
            self.reloadURLScheme()
        default:
            break
        }
    }
    
    private func refreshThreatsListView() {

        self.reloadThreatsData()
        
        //TODO: if at back??
        self.threatsListView.reloadData()
        
        //set the first card in our list
        self.selectFirstRow()
    }
    
    
    private func selectFirstRow() {
        if(self.threatsType == XGThreatsType.ALL) {
            self.threatsListView.selectRowIndexes(NSIndexSet(index: 1), byExtendingSelection: false)
        }else {
            self.threatsListView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
        }
    }
    
    private func reloadBundleHijiack() -> Int {
        self.bundleItemArray = XGContainerApplicationManager.sharedInstance.hijackedApplicationArray
        if (nil == self.bundleItemArray) {
            return 0
        }
        
        return self.bundleItemArray!.count
    }
    
    private func reloadKeychainHijack() -> Int {
        
        if  let itemSet = XGKeyChain.getItemSet() {
            self.kechainItemArray = itemSet.getPotentialArray();
        }
        
        if (nil == self.kechainItemArray) {
            return 0
        }
        
        return self.kechainItemArray!.count
    }
    
    private func reloadURLScheme() -> Int {
        self.URLSchemeDict = XGURLSchemeManager.sharedInstance.urlSchemeMultiDict
        
        if let count = self.URLSchemeDict?.dataDict.count {
            return count
        }
        return 0
    }
    
    
    private func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        switch self.threatsType {
        case XGThreatsType.ALL:
            if  let key = item as? NSString {
                if key.isEqualToString(kechainHijackString) {
                    return self.kechainItemArray
                } else if  key.isEqualToString(bundleIDHijackString) {
                    return self.bundleItemArray
                } else if key.isEqualToString(URLSchemeString) {
                    if let schemeStringArray = self.URLSchemeDict?.dataDict.keys.array {
                        var schemeNSStringArray = [NSString]()
                        for schemeString in schemeStringArray {
                            schemeNSStringArray.append(schemeString as NSString)
                        }
                        return schemeNSStringArray
                    }
                }
                else {
                    return nil
                }
            }
            return self.topArray
            
        case XGThreatsType.keychainHijack:
            return self.kechainItemArray
            
        case XGThreatsType.BundleIDHijack:
            return self.bundleItemArray
        
        case XGThreatsType.URLScheme:
            if let schemeStringArray = self.URLSchemeDict?.dataDict.keys.array {
                var schemeNSStringArray = [NSString]()
                for schemeString in schemeStringArray {
                    schemeNSStringArray.append(schemeString as NSString)
                }
                return schemeNSStringArray
            }
            
            
        default:
            break
        }
        return nil
    }
    
    private func keychainThreatsNum() -> Int {
        if let array = self.kechainItemArray {
            return array.count
        }
        return 0
    }
    
    private func bundleIDThreatsNum() -> Int {
        if let array = self.bundleItemArray {
            return array.count
        }
        return 0
    }
    
    private func URLSchmeThreatsNum()  -> Int {
        if let count = self.URLSchemeDict?.dataDict.count {
            return count
        }
        return 0
    }
    
    func getThreatsNum() -> Int {

        self.reloadThreatsData()
        //return number
        switch self.threatsType {
        case XGThreatsType.ALL:
            //TODO: now only have keychain
            return  self.keychainThreatsNum() + self.bundleIDThreatsNum() + self.URLSchmeThreatsNum()
            
        case XGThreatsType.keychainHijack:
            return self.keychainThreatsNum()
        
        case XGThreatsType.BundleIDHijack:
            return self.bundleIDThreatsNum()
        
        case XGThreatsType.URLScheme:
            return self.URLSchmeThreatsNum()
            
        default:
            break
            
        }
        return 0
    }
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let childrens = self.childrenForItem(item){
            return childrens.count
        }
        return 0
    }
    
    //delegate for outline view; get item for index
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        //it must be have data
        let array = self.childrenForItem(item)!
        return array[index]
    }
    
    //delegate for outline view; expandable
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if self.threatsType != XGThreatsType.ALL {
            return false
        }
        
        if outlineView.parentForItem(item) == nil  {
            return true
        }
        return false
    }
    
    
    //delegate for outline view; isSelected?
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        
        if self.threatsType != XGThreatsType.ALL {
            return true
        }
        
        if nil == outlineView.parentForItem(item) {
            return false
        }
        return true
    }
    
    
    //delegate for outline view; row height
//    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
//        if nil == outlineView.parentForItem(item) {
//            return 17.0
//        }
//        return 17.0
//    }
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // For the groups, we just return a regular text view.
        if  (self.threatsType == XGThreatsType.ALL) && ((self.topArray as NSArray).containsObject(item)) {
            if let result =  outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView {
                result.textField?.objectValue = (item as! NSString)
                return result
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView {
                
                var itemType = XGThreatsType.None
                
                switch self.threatsType {
                case XGThreatsType.ALL:
                    let key = outlineView.parentForItem(item) as! NSString
                    if key.isEqualToString(kechainHijackString) {
                        itemType = XGThreatsType.keychainHijack
                    } else if  key.isEqualToString(bundleIDHijackString) {
                        itemType = XGThreatsType.BundleIDHijack
                    }  else if  key.isEqualToString(URLSchemeString) {
                        itemType = XGThreatsType.URLScheme
                    }

                    
                default:
                    itemType = self.threatsType
                }
                
                switch itemType {
                case XGThreatsType.keychainHijack:
                    let secItem = item as! XGSecurityItem
                    result.textField?.objectValue = secItem.name
                    if secItem.classType == XGSecurityItem.ClassType.InternetPassword {
                        result.imageView?.objectValue = NSImage(named: NSImageNameUserAccounts)
                    } else {
                        result.imageView?.objectValue = NSImage(named:NSImageNameUser)
                    }
                    
                    
                case XGThreatsType.BundleIDHijack:
                    let bundleItem = item  as! XGBundleHijackItem
                    result.textField?.objectValue = bundleItem.application.bundleID
                    result.imageView?.objectValue = NSWorkspace.sharedWorkspace().iconForFile(bundleItem.application.fullPath)
                    
                case XGThreatsType.URLScheme:
                    let scheme = item  as! String
                    result.textField?.objectValue = scheme + "://"
                    result.imageView?.hidden = true
                    
                default:
                    break
                    
                }
            
                return result
            }
        }
        return nil
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
    
    /**********************/
    
    /* TODO*/
    private func setHijackDetailView( #secItem : XGSecurityItem) {
        if let currentViewController = self.currentdetailViewController {
            currentViewController.view.removeFromSuperview()
        }
        

        self.currentdetailViewController = NSViewController(nibName: "KeychainHijackDetailsView", bundle: nil)
   
        if let view = self.currentdetailViewController?.view as? XGKeychainHijackDetailsView{
            view.secItem = secItem
            view.upperViewController = self
            self.detailView.addSubview(view)
        }
        return
    }
    
    private func setBundleDetailView( #bundleItem : XGBundleHijackItem) {
        if let currentViewController = self.currentdetailViewController {
            currentViewController.view.removeFromSuperview()
        }
        
        
        self.currentdetailViewController = NSViewController(nibName: "XGBundleDetailsView", bundle: nil)
        
        if let view = self.currentdetailViewController?.view as? XGBundleDetailsView{
            view.bundleHijackItem = bundleItem
            view.upperViewController = self
            self.detailView.addSubview(view)
        }
        return
    }
    
    private func setURLSchemeDetailView( #scheme : NSString) {
        if let currentViewController = self.currentdetailViewController {
            currentViewController.view.removeFromSuperview()
        }
        
        
        self.currentdetailViewController = NSViewController(nibName: "XGURLSchemeHijackDetailsView", bundle: nil)
        
        if let view = self.currentdetailViewController?.view as? XGURLSchemeDetailsView {
            view.scheme = scheme as String
            view.appFullPaths = self.URLSchemeDict?.dataDict[scheme as String]
            view.upperViewController = self
            self.detailView.addSubview(view)
        }
        return
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let row = self.threatsListView.selectedRow;
        if(row < 0 ) {
            return
        }
        
        var itemType = XGThreatsType.None
        
        switch self.threatsType {
        case XGThreatsType.ALL:
            if  let item : AnyObject = self.threatsListView.itemAtRow(row) {
                
                if self.threatsListView.parentForItem(item) == nil {
                    return
                }
                
                let parent = self.threatsListView.parentForItem(item) as! String
                switch parent {
                case kechainHijackString:
                    itemType = XGThreatsType.keychainHijack
                case bundleIDHijackString:
                    itemType = XGThreatsType.BundleIDHijack
                case URLSchemeString:
                    itemType = XGThreatsType.URLScheme
                default:
                    break
                }
            }
            
        default:
            itemType = self.threatsType
        }
        
        switch itemType{
        case XGThreatsType.keychainHijack:
            if  let item = self.threatsListView.itemAtRow(row) as? XGSecurityItem{
                self.setHijackDetailView(secItem: item )
                
            }
        
        case XGThreatsType.BundleIDHijack:
            if  let item = self.threatsListView.itemAtRow(row) as? XGBundleHijackItem{
                self.setBundleDetailView(bundleItem: item )
                
            }
        
        case XGThreatsType.URLScheme:
            if  let item = self.threatsListView.itemAtRow(row) as? NSString {
                self.setURLSchemeDetailView(scheme: item )
                
            }
        default:
            break
        }
        return;
        
    }
    
    
    private func refreshThreatsListViewAndSideBar() {
        
        self.refreshThreatsListView()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationRefresh, object: self.barItem)
    }
    
    func KeychainHijackViewChanged(rescan : Bool) {
        //println("KeychainHijackViewChanged ")
        if rescan {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationRescan, object: self.barItem)
        } else {
            self.refreshThreatsListViewAndSideBar()
        }
    }
    
    func bundleIDHijackViewChanged() {
        //println("bundleIDHijackViewChanged ")

        self.refreshThreatsListViewAndSideBar()
    }
    
    func threatsDidChanged(notification: NSNotification) {
        //println("threatsDidChanged")
        let rescan =  (notification.object != nil)
        
        if notification.name == "XGKeychainThreadsChangeNotification" {
            dispatch_async(dispatch_get_main_queue(), {
                
                // DO SOMETHING ON THE MAINTHREAD
                self.KeychainHijackViewChanged(rescan)
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                
                // DO SOMETHING ON THE MAINTHREAD
                self.bundleIDHijackViewChanged()
            })
        }
        
    }


}