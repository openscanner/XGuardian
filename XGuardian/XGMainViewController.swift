//
//  XGMainViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/6.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


enum XGThreatsType {
    case None
    case ALL
    case keychainHijack
    case BundleIDHijack
}

class XGSideBarItem : NSObject {
    let title : String
    let imageName : String
    let type : XGThreatsType
    let firstNib: String
    let secondNib: String
    let desc : String
    var isThreatsView: Bool = false
    
    init(title : String, imageName : String, type: XGThreatsType, firstNib : String, secondNib : String,desc : String ) {
        self.title = title
        self.imageName = imageName
        self.type = type
        self.firstNib = firstNib
        self.secondNib = secondNib
        self.desc = desc
    }
}



// side bar item dictionary
private let staticFirstEmpty = "     "
private let staticFlaws=NSString(string:"Flaws")
private let staticTopArray =  [NSString(string:staticFirstEmpty), staticFlaws, NSString(string:"Information")]

private let staticChildrenDictionary = [
    staticTopArray[0] : [XGSideBarItem( title:      "All Scan",
                                        imageName:  "AllscanIcon",
                                        type:       XGThreatsType.ALL ,
                                        firstNib:   "ScanView",
                                        secondNib:  "ThreatsView",
                                        desc:        "Scan all vulnerability attack")] ,
    
    staticTopArray[1] : [XGSideBarItem( title:      "Keychain Hijack",
                                        imageName:  "KeychainIcon",
                                        type:       XGThreatsType.keychainHijack ,
                                        firstNib:   "ScanView",
                                        secondNib:  "ThreatsView",
                                        desc:       "Attack App can hijack keychain item through by delete keychain item first, then create the new one."),
        
                        XGSideBarItem(  title:      "BundleID Hijack",
                                        imageName:  "BudleIDIcon",
                                        type:       XGThreatsType.BundleIDHijack ,
                                        firstNib:   "ScanView",
                                        secondNib:  "ThreatsView",
                                        desc: "Attack Application fully access the target application's container by hijiack bundleID through sub-application")],
    
    staticTopArray[2] : [XGSideBarItem( title:      "Keychain List",
                                        imageName:  "UrlschemlIcon",
                                        type:       XGThreatsType.None,
                                        firstNib:   "KeychainView",
                                        secondNib:  "",
                                        desc:       "")]
];



// notification observer
let NotificationScanFinish = "scanFinishNotification"
let NotificationRescan = "RescanNotification"

let XGNotificationDictArray = [ ["Name" : NotificationScanFinish, "Selector" : "scanDidFinished:"],
    ["Name" : NotificationRescan,     "Selector" : "shouldRescan:"]]

class XGMainViewController: NSViewController,NSOutlineViewDelegate, NSOutlineViewDataSource, NSSplitViewDelegate{
    
    @IBOutlet weak var nagivationView: NSOutlineView!
    @IBOutlet weak var mainContentView: NSView!
    
    var currentContentViewController: NSViewController?
    var contentViewControllerDict  = [String:NSViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //nagivation table view
        self.nagivationView.sizeLastColumnToFit()
        self.nagivationView.floatsGroupRows = false
        //self.nagivationView.rowSizeStyle = NSTableViewRowSizeStyle.Custom
        //self.nagivationView.rowHeight               =   NSFont.systemFontSizeForControlSize:(NSSmallControlSize) + 4;
        //self.nagivationView.intercellSpacing        =   CGSizeMake(20, 5);
        self.nagivationView.reloadData()
        
        
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.nagivationView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        //set the first card in our list
        self.nagivationView.selectRowIndexes(NSIndexSet(index: 1), byExtendingSelection: false)
        
        //regist notifcation observer
        for noteDict in XGNotificationDictArray {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(noteDict["Selector"]!), name: noteDict["Name"], object: nil)
        }
        
    }
    
    private func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        if  let key = item as? NSString {
            if(key.length <= 1) { return nil }
            return staticChildrenDictionary[key]
        }
        let keys = staticTopArray
        return keys
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
        if outlineView.parentForItem(item) == nil  {
            return true
        }
        return false
    }
    
    //delegate for outline view; is group
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        //        if let key = item as? NSString  {
        //            let isGroup = (staticTopArray as NSArray).containsObject(key)
        //            return isGroup
        //        }
        return false
    }
    
    //delegate for outline view; isSelected?
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if let key = item as? NSString  {
            let isGroup = (staticTopArray as NSArray).containsObject(key)
            return !isGroup
        }
        return true
    }
    
    //delegate for outline view; show hide
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        //no show hide
        return false
    }
    
    //delegate for outline view; row height
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if (item as? String) == staticFirstEmpty  {
            return 40.0
        }
        return 25.0
    }
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // For the groups, we just return a regular text view.
        if  (staticTopArray as NSArray).containsObject(item) {
            if let result =  outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView {
                result.textField?.objectValue = (item as! NSString).uppercaseString
                return result
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? XGSideBarCellView {
                
                if let barItem = item as? XGSideBarItem {
                    result.textField?.objectValue = barItem.title
                    result.imageView?.objectValue = NSImage(named:barItem.imageName)
                    if barItem.isThreatsView {
                        if let threatsViewController = self.contentViewControllerDict[barItem.title] as? XGThreatsViewController {
                            result.indicatorButton.hidden = false
                            result.indicatorButton.title = threatsViewController.getThreatsNum().description
                            result.indicatorButton.sizeToFit()
                            let cell = result.indicatorButton.cell()  as! NSButtonCell
                            cell.highlightsBy = NSCellStyleMask.allZeros
                        }
                        
                    }else {
                        result.indicatorButton.hidden = true
                    }
                }
                return result
                
            }
        }
        return nil
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
//MARK: -
    
    private func getViewController(name: String, barItem: XGSideBarItem) -> NSViewController? {
        if "ThreatsView" == name {
            let threatsViewController = XGThreatsViewController(nibName: name, bundle: nil)
            threatsViewController?.threatsType = barItem.type
            threatsViewController?.barItem = barItem
            return threatsViewController
        } else if "ScanView" == name {
            let scanViewController = XGScanViewController(nibName: name, bundle: nil)
            scanViewController?.barItem = barItem
            return scanViewController
        }
        
        return NSViewController(nibName: name, bundle: nil)
    }
    
    private func setCurrentView(nibName: String, _ barItem: XGSideBarItem, _ forceSwitch: Bool) {
        
        let currentViewController = self.currentContentViewController
        let contentViewController = self.contentViewControllerDict[barItem.title]
        if  !forceSwitch && contentViewController != nil  {
            self.currentContentViewController = contentViewController
        } else {
            self.currentContentViewController = self.getViewController(nibName, barItem: barItem)
            self.contentViewControllerDict[barItem.title] = self.currentContentViewController
        }
        
        if let view = self.currentContentViewController?.view {
            
            if let currentVC = currentViewController {
                self.mainContentView.replaceSubview(currentVC.view, with: view)
            } else {
                self.mainContentView.addSubview(view)
            }
        }
    }
    
    //set backend view, not show on frontend
    private func setBackendView(nibName: String, _ barItem: XGSideBarItem) {
        
        let contentViewController = self.getViewController(nibName, barItem: barItem)
        self.contentViewControllerDict[barItem.title] = contentViewController
        
//        if let view = contentViewController?.view {
//            self.mainContentView.addSubview(view, positioned: NSWindowOrderingMode.Out, relativeTo: nil)
//        }
        
    }
    
    //
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let row = self.nagivationView.selectedRow;
        if(row != -1 ) {
            if let item = self.nagivationView.itemAtRow(row) as? XGSideBarItem {
                if self.nagivationView.parentForItem(item) != nil {
                    self.setCurrentView(item.firstNib, item, false)
                    return;
                }
            }
        }
        
    }

    func scanDidFinished(notification: NSNotification) {
        if let bar = notification.object as? XGSideBarItem {
            if(bar.type == XGThreatsType.ALL) {
                for sub_bar in staticChildrenDictionary[staticFlaws]! {
                    if !sub_bar.isThreatsView {
                        self.setBackendView(sub_bar.secondNib, sub_bar)
                        sub_bar.isThreatsView = true
                    }
                }
            }
            self.setCurrentView(bar.secondNib, bar, true)
            bar.isThreatsView = true
            self.nagivationView.reloadData()
            
            //self.nagivationView.reloadItem(bar)
        }
        return
        
    }
    
    
    func shouldRescan(notification: NSNotification) {
        //println("shouldRescan notification: \(notification)")
        if let bar = notification.object as? XGSideBarItem {
            self.nagivationView.reloadData()
        }
    }
    
}
