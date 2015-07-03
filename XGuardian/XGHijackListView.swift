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

class XGHijackListView: NSView, NSTableViewDelegate, NSTableViewDataSource {

        private var itemArray : [XGSecurityItem]?
    
    @IBOutlet weak var titleImage: NSImageView!
    @IBOutlet weak var titleLable: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
        

    @IBAction func btnRevealInFinder(sender: AnyObject) {
        NSLog("btnRevealInFinder:\(sender)")
    }
    
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
        self.tableView.headerView = nil
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)

        
        self.scan()
    }

    /**
    scan
    */
    func scan() {
        if  let itemSet = XGKeyChain.getItemSet() {
            self.itemArray = itemSet.getPotentialArray();
        }
        
        if( (nil == self.itemArray) || self.itemArray!.count <= 0) {
            self.titleImage.objectValue = NSImage(named:noHijackImage);
            self.titleLable.objectValue = noHijackStr;
            self.tableView.hidden = true;
        } else {
            self.tableView.hidden = false;
            self.titleImage.objectValue = NSImage(named:hijackImage);
            let title = hijackStr + " You have \(self.itemArray!.count) password maybe in danger"
            self.titleLable.objectValue = title;
        }
        
        /********/
        self.tableView.reloadData()
    }
    
/**************************************/
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let its = self.itemArray {
            return its.count;
        }
        return 0;
    }
    
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if nil == self.itemArray {
            return nil
        }
        let item = self.itemArray![row]
        
        if let identifier = tableColumn?.identifier {
            if let mainCell = tableView.makeViewWithIdentifier(identifier,owner:self) as? XGHijackListCell {
                
                mainCell.item = item
                mainCell.textField!.objectValue = item.name
                if item.classType == XGSecurityItem.ClassType.InternetPassword {
                    mainCell.imageView!.objectValue = NSImage(named: NSImageNameUserAccounts)
                }
                
                mainCell.classLable?.objectValue = item.classType?.description
                mainCell.accountLable?.objectValue = item.account
                mainCell.positionLable?.objectValue = item.position
                mainCell.modifyLable?.objectValue = item.modifyTime?.description
                
                return mainCell;
            }
        }
        return nil;
    }
/**************************************/

    
}
