//
/*
let parent: (AnyObject?) = outlineView.parentForItem(item)
let index = (staticTopArray as NSArray).indexOfObject(parent!)
BOOL hideUnreadIndicator = YES;
// Setup the unread indicator to show in some cases. Layout is done in SidebarTableCellView's viewWillDraw
if (index == 0) {
// First row in the index
hideUnreadIndicator = NO;
[result.button setTitle:@"42"];
[result.button sizeToFit];
// Make it appear as a normal label and not a button
[[result.button cell] setHighlightsBy:0];
} else if (index == 2) {
// Example for a button
hideUnreadIndicator = NO;
result.button.target = self;
result.button.action = @selector(buttonClicked:);
[result.button setImage:[NSImage imageNamed:NSImageNameAddTemplate]];
// Make it appear as a button
[[result.button cell] setHighlightsBy:NSPushInCellMask|NSChangeBackgroundCellMask];
}
[result.button setHidden:hideUnreadIndicator];
return result;*/

//  XGMainViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/6.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


class XGSideBarItem : NSObject {
    let title : String
    let imageName : String
    let firstNib: String
    let secondNib: String
    
    init(_ title : String, _ imageName : String, _ firstNib : String,  _  secondNib : String) {
        self.title = title
        self.imageName = imageName
        self.firstNib = firstNib
        self.secondNib = secondNib
    }
}

// side bar item dictionary
private let staticFirstEmpty = "     "
private let staticTopArray =  [NSString(string:staticFirstEmpty), NSString(string:"Flaws"), NSString(string:"Information")]

private let staticChildrenDictionary = [
    staticTopArray[0] : [XGSideBarItem("All Scan", "AllscanIcon",  "ScanView", "ThreatsView")] ,
    staticTopArray[1] : [XGSideBarItem("Keychain Hijack", "KeychainIcon", "ScanView",  "ThreatsView")],
    staticTopArray[2] : [XGSideBarItem("Keychain List","UrlschemlIcon", "AllscanIcon", "")]
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
            return 34.0
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
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView {
                
                if let barItem = item as? XGSideBarItem {
                    result.textField?.objectValue = barItem.title
                    result.imageView?.objectValue = NSImage(named:barItem.imageName)
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
   
    private func getViewController(name: String) -> NSViewController? {
        if "ThreatsView" == name {
            return XGThreatsViewController(nibName: name, bundle: nil)
        } else if "ScanView" == name {
            return XGScanViewController(nibName: name, bundle: nil)
        }
        
        return NSViewController(nibName: name, bundle: nil)
    }
    
    /* TODO*/
    private func setCurrentView(nibName: String, _ title: String, _ forceSwitch: Bool) {
        
        let currentViewController = self.currentContentViewController
        let contentViewController = self.contentViewControllerDict[title]
        if  !forceSwitch && contentViewController != nil  {
            self.currentContentViewController = contentViewController
        } else {
            self.currentContentViewController = self.getViewController(nibName)
            self.currentContentViewController?.title = title
            self.contentViewControllerDict[title] = self.currentContentViewController
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
                    self.setCurrentView(item.firstNib, item.title, false)
                    return;
                }
            }
        }
    }
    
    func scanDidFinished(notification: NSNotification) {
        println("notification: \(notification)")
        let title = notification.object as! String
        self.setCurrentView("ThreatsView", title, true)
        return;
    }
    
}



