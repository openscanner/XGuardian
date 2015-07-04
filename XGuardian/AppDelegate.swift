//
//  AppDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/29.
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

var staticTopLevelItems = [NSString(string: "Keychain")]
var staticChildrenValue = [NSString(string:"HijackView"), NSString(string:"KeychainView")]
var staticChildrenDictionary = [NSString(string:"Keychain"): staticChildrenValue]

private let updateTimerInterval = 21600.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, NSSplitViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var nagivationView: NSOutlineView!
    @IBOutlet var mainContentView: NSView!
    
    //let topLevelItems = staticTopLevelItems
    //let childrenDictionary = staticChildrenDictionary
    
    //[String:[String]]?
    var currentContentViewController: NSViewController?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //
        XGKeychainObserver.startObserve()
        self.loadViews()
        
        //check update
        XGBackend.updateLastedverion()
        //TODO:read timeinterval form plist add update check timer
        NSTimer.scheduledTimerWithTimeInterval(updateTimerInterval, target: self, selector: Selector("processUpdateCheck:"), userInfo: nil, repeats: true)
    }
    
    func processUpdateCheck(timer : NSTimer ) {
        XGBackend.updateLastedverion()
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().hide(sender)
        return false
    }


    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        XGKeychainObserver.stopObserve()
    }
    
    func loadViews() {
        
        //window.delegate = self
        //window.autodisplay = true
        //window.restorable = true
        
        //nagivation table view
        self.nagivationView.sizeLastColumnToFit()
        self.nagivationView.reloadData()
        self.nagivationView.floatsGroupRows = false
        self.nagivationView.rowSizeStyle = NSTableViewRowSizeStyle.Default
        
        
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.nagivationView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()

        
        //self.nagivationView.headerView = nil;
        //self.nagivationView.reloadData()
        //TODO: set the first card in our list
        self.nagivationView.selectRowIndexes(NSIndexSet(index: 1), byExtendingSelection: false)
    }
    
    private func childrenForItem(item: AnyObject?) ->  [NSString] {
        if  nil != item {
            return staticChildrenValue
        }
        return staticTopLevelItems
    }
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return self.childrenForItem(item).count
    }
    
    //delegate for outline view; get item for index
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        let array = self.childrenForItem(item as? NSString)
        return array[index]
        //return self.childrenForItem(item)[index]
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
            let isGroup = (staticTopLevelItems as NSArray).containsObject(key)
            return isGroup
        }
        return false
    }
    
    //delegate for outline view
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
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // For the groups, we just return a regular text view.
        if  (staticTopLevelItems as NSArray).containsObject(item) {
            if let result =  outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView {
                result.textField?.objectValue = (item as! NSString).uppercaseString
                //result.textField?.accessibilitySelected = false
                return result
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView {
                
                
                //set icon
                let parent: (AnyObject?) = outlineView.parentForItem(item)
                let index = (staticTopLevelItems as NSArray).indexOfObject(parent!)
                switch item as! String {
                case "HijackView":
                    result.textField?.objectValue = "Hijack Scan"
                    result.imageView?.objectValue = NSImage(named:NSImageNameQuickLookTemplate)
                case "KeychainView":
                    result.textField?.objectValue = "Keychain Item List"
                    result.imageView?.objectValue = NSImage(named:NSImageNameListViewTemplate)
                default:
                    break
                }
                
                //
                return result
                
               /* BOOL hideUnreadIndicator = YES;
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
    
    
    /*func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return nagivationData.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let buttonDict = nagivationData[row]
        if let identifier = tableColumn?.identifier {
            if let cellView = tableView.makeViewWithIdentifier(identifier,owner:self) as? NSTableCellView {
                cellView.textField!.objectValue = buttonDict["name"]!
                let image = NSImage(named: buttonDict["image"]!)
                cellView.imageView?.objectValue = image
                return cellView
            }
        }
        
        return nil
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }*/
    
    /**********************/
    
   /* TODO*/
    private func setContentView(#name: String) {
        if let currentVC = self.currentContentViewController {
            currentVC.view.removeFromSuperview()
        }
        self.currentContentViewController = NSViewController(nibName: name, bundle: nil)
        if let view = self.currentContentViewController?.view {
            //view.frame = self.mainContentView.bounds
            //view.autoresizingMask = NSAutoresizingMaskOptions.ViewWidthSizable | NSAutoresizingMaskOptions.ViewHeightSizable
            self.mainContentView.addSubview(view)
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

