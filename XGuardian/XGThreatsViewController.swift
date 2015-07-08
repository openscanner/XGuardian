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
    @IBOutlet weak var titleButton: NSButton!
    
    var currentdetailViewController: NSViewController?
    
    private let topArray = [NSString(string: kechainHijackString )]
    
    private var kechainItemArray : [XGSecurityItem]?
    
    var threatsType = XGThreatsType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let keychainHijackNum = self.getKeychainHijack()
        
        //nagivation table view
        self.threatsListView.sizeLastColumnToFit()
        self.threatsListView.floatsGroupRows = true
        self.threatsListView.reloadData()
        
        switch self.threatsType {
        case XGThreatsType.ALL:
            self.titleButton?.title = "ALL SCAN"
        case XGThreatsType.keychainHijack:
            self.titleButton.title = "Keychain Hijack"
        default:
            break
        }
        
        
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
        switch self.threatsType {
        case XGThreatsType.ALL:
            if  let key = item as? NSString {
                if key.isEqualToString(kechainHijackString) {
                    return self.kechainItemArray
                } else {
                    return nil
                }
            }
            return self.topArray
            
        case XGThreatsType.keychainHijack:
            return self.kechainItemArray
            
        default:
            break
        }
        return nil
    }
    
    func getThreatsNum() -> Int {
        switch self.threatsType {
        case XGThreatsType.ALL:
            //TODO: now only have keychain
            return self.kechainItemArray!.count
            
        case XGThreatsType.keychainHijack:
            return self.kechainItemArray!.count
            
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
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if nil == outlineView.parentForItem(item) {
            return 17.0
        }
        return 17.0
    }
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // For the groups, we just return a regular text view.
        if  (self.threatsType == XGThreatsType.ALL) && ((self.topArray as NSArray).containsObject(item)) {
            if let result =  outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView {
                result.textField?.objectValue = (item as! NSString).uppercaseString
                return result
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView {

                if self.threatsType == XGThreatsType.ALL {
                    let key = outlineView.parentForItem(item) as! NSString
                    if key.isEqualToString(kechainHijackString) {
                        let secItem = item as! XGSecurityItem
                        result.textField?.objectValue = secItem.name
                        result.imageView?.objectValue = NSImage(named:NSImageNameQuickLookTemplate)
                    } else {
                        return nil
                    }
                } else if self.threatsType == XGThreatsType.keychainHijack {
                    let secItem = item as! XGSecurityItem
                    result.textField?.objectValue = secItem.name
                    result.imageView?.objectValue = NSImage(named:NSImageNameQuickLookTemplate)
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
        if(row < 0 ) {
            return
        }
        switch self.threatsType {
        case XGThreatsType.ALL:
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
                //println("row : \(row) \(item)")
                
            }
        case XGThreatsType.keychainHijack:
            if  let item = self.threatsListView.itemAtRow(row) as? XGSecurityItem{
                self.setHijackDetailView(secItem: item )
                
            }
        default:
            break
        }
        return;
        
    }



}
