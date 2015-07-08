//
//  XGThreatsViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/7.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

private let kechainHijackString = "KEYCHAIN HIJACK"

class XGThreatsViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, NSSplitViewDelegate {

    @IBOutlet weak var threatsListView: NSOutlineView!
    @IBOutlet weak var detailView: NSView!
    @IBOutlet weak var titleText: NSTextField!
    
    var currentdetailViewController: NSViewController?
    
    private let topArray = [NSString(string: kechainHijackString )]
    
    private var kechainItemArray : [XGSecurityItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let keychainHijackNum = self.getKeychainHijack()
        
        //nagivation table view
        self.threatsListView.sizeLastColumnToFit()
        self.threatsListView.floatsGroupRows = true
        self.threatsListView.reloadData()
        
        
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.threatsListView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        
        //TODO: set the first card in our list
        //self.threatsListView.selectRowIndexes(NSIndexSet(index: 2), byExtendingSelection: false)
    }
    
    private func getKeychainHijack() -> Int {
        
        if  let itemSet = XGKeyChain.getItemSet() {
            self.kechainItemArray = itemSet.getPotentialArray();
        }
        
        if (nil == self.kechainItemArray) {
            return 0
        }
        
        return self.kechainItemArray!.count
    }
    
    
    private func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        if  let key = item as? NSString {
            if key.isEqualToString(kechainHijackString) {
                return self.kechainItemArray
            } else {
                return nil
            }
        }
        return self.topArray
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
    
    
    //delegate for outline view; isSelected?
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        if nil == outlineView.parentForItem(item) {
            return false
        }
        return true
    }
    
    
    //delegate for outline view; row height
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if nil == outlineView.parentForItem(item) {
            return 17.0
        }
        return 17.0
    }
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // For the groups, we just return a regular text view.
        if  (self.topArray as NSArray).containsObject(item) {
            if let result =  outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView {
                result.textField?.objectValue = (item as! NSString).uppercaseString
                return result
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView {

                
                let key = outlineView.parentForItem(item) as! NSString
                if key.isEqualToString(kechainHijackString) {
                    let secItem = item as! XGSecurityItem
                    result.textField?.objectValue = secItem.name
                    result.imageView?.objectValue = NSImage(named:NSImageNameQuickLookTemplate)
                } else {
                    return nil
                }
                
                return result
                
                /*
                let parent: (AnyObject?) = outlineView.parentForItem(item)
                let index = (self.topArray as NSArray).indexOfObject(parent!)
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
    private func setHijackDetailView( #secItem : XGSecurityItem) {
        let currentViewController = self.currentdetailViewController
        

        self.currentdetailViewController = NSViewController(nibName: "KeychainHijackDetailsView", bundle: nil)
   
        if let view = self.currentdetailViewController?.view as? XGKeychainHijackDetailsView{
            view.secItem = secItem
            if let currentVC = currentViewController {
                self.detailView.replaceSubview(currentVC.view, with: view)
            } else {
                self.detailView.addSubview(view)
            }
        }
        return
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let row = self.threatsListView.selectedRow;
        if(row != -1 ) {
            if  let item : AnyObject = self.threatsListView.itemAtRow(row) {
                
                if self.threatsListView.parentForItem(item) == nil {
                    return
                }
                
                let parent = self.threatsListView.parentForItem(item) as! String
                switch parent {
                case kechainHijackString:
                    self.setHijackDetailView(secItem: item as! XGSecurityItem)
                default:
                    break
                }
                //self.setContentView(name: item as String)
                println("row : \(row) \(item)")
                return;
            }
        }
    }



}
