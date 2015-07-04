//
//  XGHijackListView.swift
//  XGuardian
//
//  Created by WuYadong on 15/6/29.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

private let noHijackStr = "Congratulation! We don't find hijack!"
private let noHijackImage = NSImageNameStatusAvailable
private let hijackStr = "OW, NO!"
private let hijackImage = NSImageNameCaution

class XGHijackListView: NSView, NSOutlineViewDelegate, NSOutlineViewDataSource {

    private var itemArray : [XGSecurityItem]?
    
    @IBOutlet weak var titleImage: NSImageView!
    @IBOutlet weak var titleLable: NSTextField!
    @IBOutlet weak var outlineView: NSOutlineView!

    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        let bezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 0, yRadius: 0)
        bezierPath.lineWidth = 1.0
        NSColor.whiteColor().set()
        bezierPath.fill()
    
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        //
        self.outlineView.setDelegate(self)
        
        if self.scan() {
            self.titleImage.objectValue = NSImage(named:noHijackImage);
            self.titleLable.objectValue = noHijackStr;
            self.outlineView.hidden = true;
        } else {
            self.outlineView.setDataSource(self)
            self.outlineView.hidden = false;
            self.titleImage.objectValue = NSImage(named:hijackImage);
            let title = hijackStr + " You have \(self.itemArray!.count) password maybe in danger"
            self.titleLable.objectValue = title;
            
            //set outline view
            self.outlineView.sizeLastColumnToFit()
            self.outlineView.reloadData()
            self.outlineView.floatsGroupRows = false
            self.outlineView.rowSizeStyle = NSTableViewRowSizeStyle.Custom
            
            
            // Expand all the root items; disable the expansion animation that normally happens
            NSAnimationContext.beginGrouping()
            NSAnimationContext.currentContext().duration = NSTimeInterval(0)
            self.outlineView.expandItem(nil, expandChildren: true)
            NSAnimationContext.endGrouping()
        }
 
    }

    /**
    scan
    */
    func scan() -> Bool {
        if  let itemSet = XGKeyChain.getItemSet() {
            self.itemArray = itemSet.getPotentialArray();
        }
        
        if( (nil == self.itemArray) || self.itemArray!.count <= 0) {
            return true
        }
        
        /********/
        return false
    }
    
    private func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        if  nil == item {
            return self.itemArray
        } else {
            if let secItem = item as? XGSecurityItem {
                return secItem.applicationList
            }
        }
        return nil
    }
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let children = self.childrenForItem(item) {
            return children.count
        }
        return 0
    }
    
    //delegate for outline view; get item for index
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        let array = self.childrenForItem(item)
        if let itemArray = array as? [XGSecurityItem] {
            return itemArray[index]
        }
        
        let appArray = array as! [String]
        return appArray[index] as NSString
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
        if let secItem = item as? XGSecurityItem  {
            let isGroup = (self.itemArray! as NSArray).containsObject(secItem)
            return isGroup
        }
        return false
    }
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        //no show hide
        return false
    }
    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        if let secItem = item as? XGSecurityItem  {
           return 100
        }
        return 17
    }
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        // For the groups, we just return a regular text view.
        if  (self.itemArray! as NSArray).containsObject(item) {
            if let itemCell =  outlineView.makeViewWithIdentifier("ItemCell", owner: self) as? XGHijackListCell {
                let secItem = item as! XGSecurityItem
                itemCell.item = secItem
                itemCell.nameLabel!.objectValue = secItem.name
                if secItem.classType == XGSecurityItem.ClassType.InternetPassword {
                    itemCell.imageLabel!.objectValue = NSImage(named: NSImageNameUserAccounts)
                }
                
                itemCell.classLabel?.objectValue = secItem.classType?.description
                itemCell.accountLabel?.objectValue = secItem.account
                itemCell.positionLabel?.objectValue = secItem.position
                itemCell.modifyLabel?.objectValue = secItem.modifyTime?.description
                return itemCell
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("AppListCell", owner: self) as? XGHijackListAppCell {
                let appPath = item as! String
                result.appFullPath = appPath
                result.secItem = outlineView.parentForItem(item) as? XGSecurityItem
                result.textField?.objectValue = item.lastPathComponent
                result.imageView?.objectValue = NSWorkspace.sharedWorkspace().iconForFile(appPath)
                
                return result
            }
        }
        
        return nil
    }

}
