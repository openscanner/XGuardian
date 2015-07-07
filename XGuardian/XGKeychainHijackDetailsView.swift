//
//  XGKeychainHijackDetailsView.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/7.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGKeychainHijackDetailsView: NSView, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var classLabel: NSTextField!
    @IBOutlet weak var accountLabel: NSTextField!
    @IBOutlet weak var positionLabel: NSTextField!
    @IBOutlet weak var createLabel: NSTextField!
    @IBOutlet weak var modifyLabel: NSTextField!
    @IBOutlet weak var imageLabel: NSImageView!
    
    @IBOutlet weak var hijackAppTableView: NSTableView!
    
    weak var secItem : XGSecurityItem?
    
    
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
        if  let item = self.secItem {
            self.nameLabel.objectValue = item.name
            self.classLabel.objectValue = item.classType?.description
            self.accountLabel.objectValue = item.account
            self.positionLabel.objectValue = item.position
            self.createLabel.objectValue = item.createTime?.description
            self.modifyLabel.objectValue = item.modifyTime?.description
            if item.classType == XGSecurityItem.ClassType.InternetPassword {
                self.imageLabel!.objectValue = NSImage(named: NSImageNameUserAccounts)
            }
        }
        

        self.hijackAppTableView.setDelegate(self)
        self.hijackAppTableView.setDataSource(self)
        self.hijackAppTableView.reloadData()
        
        //seleted first row
        self.hijackAppTableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)

    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let applist = self.secItem?.applicationList {
            return applist.count
        }
        return 0;
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if nil == self.secItem {
            return nil
        }
        let appList = self.secItem?.applicationList
        
        let appPath = appList![row]
        
        if let identifier = tableColumn?.identifier {
            if let result =  tableView.makeViewWithIdentifier(identifier, owner: self) as? XGKeychainHijackDetailsCell {
                result.appFullPath = appPath
                result.textField?.objectValue = appPath.lastPathComponent
                result.imageView?.objectValue = NSWorkspace.sharedWorkspace().iconForFile(appPath)
                result.appFullPath = appPath
                result.secItem = self.secItem
                
                return result
            }
        }
        
        return nil;
    }

    
}
