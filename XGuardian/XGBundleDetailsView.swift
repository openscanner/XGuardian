//
//  XGBundleDetailsView.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/17.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGBundleDetailsView: NSView, NSTableViewDelegate, NSTableViewDataSource{

    @IBOutlet weak var appImage: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    @IBOutlet weak var appFullPath: NSTextField!
    @IBOutlet weak var appBundleID: NSTextField!
    @IBOutlet weak var bundleIDHijiackTableView: NSTableView!
    
    weak var bundleHijackItem : XGBundleHijackItem?
    weak var upperViewController : XGThreatsViewController?
    
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
        
        if let hijiackedApp = self.bundleHijackItem?.application {
            self.appImage.objectValue =   NSWorkspace.sharedWorkspace().iconForFile(hijiackedApp.fullPath)
            self.appName.objectValue =   (hijiackedApp.fullPath as NSString).lastPathComponent
            self.appFullPath.objectValue =   hijiackedApp.fullPath
            self.appBundleID.objectValue =   hijiackedApp.bundleID
        }
        
        self.bundleIDHijiackTableView.setDelegate(self)
        self.bundleIDHijiackTableView.setDataSource(self)
        self.bundleIDHijiackTableView.headerView = nil
        self.bundleIDHijiackTableView.reloadData()
        
        //seleted first row
        self.bundleIDHijiackTableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let applist = self.bundleHijackItem?.hijackApplications {
            return applist.count
        }
        return 0;
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if nil == self.bundleHijackItem {
            return nil
        }
        let appList = self.bundleHijackItem?.hijackApplications
        let appPath = appList![row].fullPath
        
        if let identifier = tableColumn?.identifier {
            if let result =  tableView.makeViewWithIdentifier(identifier, owner: self) as? NSTableCellView {
                result.textField?.objectValue = (appPath as NSString).lastPathComponent
                result.imageView?.objectValue = NSWorkspace.sharedWorkspace().iconForFile(appPath)
                result.imageView?.sizeToFit()

                return result
            }
        }
        
        return nil;
    }

    
}
