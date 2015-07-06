//
//  XGMainViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/6.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


private let hijackName = "Keychain Hijack"
private let hijackImage = NSImageNameQuickLookTemplate
private let keychainName = "Item List"
private let keychainImage = NSImageNameListViewTemplate
private let nagivationData =  [["name":hijackName, "image":hijackImage],
    ["name":keychainName, "image":keychainImage]
]

let staticTopArray =  [NSString(string:" "), NSString(string:"Keychain"), NSString(string:"222")]
let staticChildrenDictionary = [NSString(string:" ") : [NSString(string:" ")], NSString(string:"Keychain"): [NSString(string:"HijackView"), NSString(string:"KeychainView"), NSString(string: "threatsView")], NSString(string:"2") : [NSString(string:" ")]]

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
        self.nagivationView.reloadData()
        
       
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.nagivationView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        
        //self.nagivationView.headerView = nil;
        //self.nagivationView.reloadData()
        //TODO: set the first card in our list
        self.nagivationView.selectRowIndexes(NSIndexSet(index: 2), byExtendingSelection: false)
    }
    
    private func childrenForItem(item: AnyObject?) ->  [NSString]? {
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
        /*if let itemStr = item as? NSString {
        if itemStr.isEqualToString("Keychain") {
        return false
        }
        }
        return true;*/
    }
    
    //delegate for outline view; row height
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if (item as? NSString)?.length <= 1 {
            return 9.0
        }
        return 17.0
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
                
                
                //set icon
                switch item as! String {
                case "HijackView":
                    result.textField?.objectValue = "Hijack Scan"
                    result.imageView?.objectValue = NSImage(named:NSImageNameQuickLookTemplate)
                case "KeychainView":
                    result.textField?.objectValue = "Keychain Item List"
                    result.imageView?.objectValue = NSImage(named:NSImageNameListViewTemplate)
                case "threatsView":
                    result.textField?.objectValue = "AllScan"
                    result.imageView?.objectValue = NSImage(named:NSImageNameListViewTemplate)
                default:
                    break
                }
                
                //
                return result
                
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
            }
        }
        return nil
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
    
    /**********************/
    
    /* TODO*/
    private func setContentView(#name: String) {
        /*if let currentVC = self.currentContentViewController {
            currentVC.view.removeFromSuperview()
        }*/
        let currentViewController = self.currentContentViewController
        if let contentViewController = self.contentViewControllerDict[name] {
            self.currentContentViewController = contentViewController
        } else {
            self.currentContentViewController = NSViewController(nibName: name, bundle: nil)
            self.contentViewControllerDict[name] = self.currentContentViewController
        }
        
        if let view = self.currentContentViewController?.view {
            //view.frame = self.mainContentView.bounds
            //view.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable | NSAutoresizingMaskOptions.ViewHeightSizable
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
            if let item = self.nagivationView.itemAtRow(row) as? String {
                if self.nagivationView.parentForItem(item) != nil {
                    self.setContentView(name: item as String)
                    return;
                }
            }
        }
    }
    
}
