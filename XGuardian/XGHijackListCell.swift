//
//  XGHijackListCell.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/30.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGHijackListCell: NSTableCellView, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var classLable: NSTextField?
    @IBOutlet var accountLable: NSTextField?
    @IBOutlet var positionLable: NSTextField?
    @IBOutlet var modifyLable: NSTextField?
    @IBOutlet var applicationTable: NSTableView?
    
    weak var  item : XGSecurityItem?
    
    
    
    @IBAction func btnRevelAction(sender: AnyObject) {
        
        let row = self.applicationTable?.rowForView(sender as! NSView)
        let applicationList = self.item?.applicationList
        if nil == applicationList || row < 0 || row >= applicationList?.count{
            return
        }
        
        let applicationFullPath = applicationList![row!]
        NSWorkspace.sharedWorkspace().selectFile(applicationFullPath, inFileViewerRootedAtPath: "")
    }
    
    @IBAction func btnDeleteAction(sender: AnyObject) {
        let row = self.applicationTable?.rowForView(sender as! NSView)
    }

    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.        
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        //
        self.applicationTable?.headerView = nil
        self.applicationTable?.setDelegate(self)
        self.applicationTable?.setDataSource(self)
        self.applicationTable?.doubleAction = Selector("openAppInFinder:")
        
        self.applicationTable?.reloadData()
    }
    
    func openAppInFinder(sender: AnyObject) {
        // let row = self.tableView.rowForView(sender as! NSView)
        let applicationList = self.item?.applicationList
        let row = (sender as! NSTableView).clickedRow
        if nil == applicationList || row < 0 || row >= applicationList?.count{
            return
        }
        let applicationFullPath = applicationList![row]
        NSWorkspace.sharedWorkspace().selectFile(applicationFullPath, inFileViewerRootedAtPath: "")
        return
    }
    
    /**************************************/
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let applicationList = self.item?.applicationList {
            return applicationList.count;
        }
        return 0;
    }
    
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let applicationList = self.item?.applicationList
        if nil == applicationList {
            return nil
        }
        let application = applicationList![row]
        
        if let identifier = tableColumn?.identifier {
            if let appCell = tableView.makeViewWithIdentifier(identifier,owner:self) as? NSTableCellView {
                
                appCell.textField!.objectValue = application.lastPathComponent
                appCell.imageView!.objectValue = NSWorkspace.sharedWorkspace().iconForFile(application)
                
                return appCell;
            }
        }
        return nil;
    }
    /**************************************/

}
