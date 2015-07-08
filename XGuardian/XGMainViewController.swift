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
}

class XGSideBarItem : NSObject {
    let title : String
    let imageName : String
    let type : XGThreatsType
    let firstNib: String
    let secondNib: String
    let desc : String
    var isThreatsView: Bool = false
    
    init(_ title : String, _ imageName : String, _ type: XGThreatsType,  _ firstNib : String,  _  secondNib : String, _ desc : String ) {
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
private let staticTopArray =  [NSString(string:staticFirstEmpty), NSString(string:"Flaws"), NSString(string:"Information")]

private let staticChildrenDictionary = [
    staticTopArray[0] : [XGSideBarItem("All Scan",          "AllscanIcon",      XGThreatsType.ALL ,             "ScanView", "ThreatsView", "Scan all vulnerability attack")] ,
    staticTopArray[1] : [XGSideBarItem("Keychain Hijack",   "KeychainIcon",     XGThreatsType.keychainHijack ,  "ScanView", "ThreatsView", "Keychain Hijack: Attack App can hijack keychain item through by delete keychain item first, then create the new one.")],
    staticTopArray[2] : [XGSideBarItem("Keychain List",     "UrlschemlIcon",    XGThreatsType.None,             "KeychainView"," ", " ")]
];



// notification
let ScanFinisheNotification = "scanFinisheNotification"

class XGMainViewController: NSViewController,NSOutlineViewDelegate, NSOutlineViewDataSource, NSSplitViewDelegate{
    
    @IBOutlet weak var nagivationView: NSOutlineView!
    @IBOutlet weak var mainContentView: NSView!
    
    var currentContentViewController: NSViewController?
    var contentViewControllerDict  = [String:NSViewController]()
    var viewControllerArray =  [NSViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //nagivation table view
        self.nagivationView.sizeLastColumnToFit()
        self.nagivationView.floatsGroupRows = false
        //self.nagivationView.rowSizeStyle = NSTableViewRowSizeStyle.Custom
        self.nagivationView.reloadData()
        
        
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.nagivationView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        
        //self.nagivationView.headerView = nil;
        //self.nagivationView.reloadData()
        //TODO: set the first card in our list
        self.nagivationView.selectRowIndexes(NSIndexSet(index: 1), byExtendingSelection: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scanDidFinished:"), name: ScanFinisheNotification, object: nil)
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
        if let key = item as? NSString  {
            let isGroup = (staticTopArray as NSArray).containsObject(key)
            return isGroup
        }
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
        return 20.0
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
                        result.indicatorButton.hidden = false
                        result.indicatorButton.title = (self.currentContentViewController as! XGThreatsViewController).getThreatsNum().description
                        result.indicatorButton.sizeToFit()
                        let cell = result.indicatorButton.cell()  as! NSButtonCell
                        cell.highlightsBy = NSCellStyleMask.allZeros

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
    
    //
    private func getViewController(name: String, barItem: XGSideBarItem) -> NSViewController? {
        if "ThreatsView" == name {
            let threatsViewController = XGThreatsViewController(nibName: name, bundle: nil)
            threatsViewController?.threatsType = barItem.type
            return threatsViewController
        } else if "ScanView" == name {
            let scanViewController = XGScanViewController(nibName: name, bundle: nil)
            scanViewController?.barItem = barItem
            return scanViewController
        }
        
        return NSViewController(nibName: name, bundle: nil)
    }
    
    //TODO:
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
        println("notification: \(notification)")
        if let bar = notification.object as? XGSideBarItem {
            self.setCurrentView(bar.secondNib, bar, true)
            bar.isThreatsView = true
            self.nagivationView.reloadData()
            //self.nagivationView.reloadItem(bar)
        }
        return;
    }
    
}



