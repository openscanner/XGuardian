//
//  XGKeychainView.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/29.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGKeychainView: NSView, NSTableViewDelegate, NSTableViewDataSource {
    
    private var itemArray : [XGSecurityItem]?
    
    @IBOutlet weak var keychainTable: NSTableView!
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var classLabel: NSTextField!
    @IBOutlet weak var accountLabel: NSTextField!
    @IBOutlet weak var positionLabel: NSTextField!
    
    @IBOutlet weak var owner: NSViewController!
    @IBOutlet weak var applicationsLabel: NSTextField!
    
    //override func
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
        let itemSet = XGKeychainInstance.getItemSet()
        self.itemArray = itemSet.toArray();
        self.keychainTable.setDelegate(self)
        self.keychainTable.setDataSource(self)
        self.keychainTable.doubleAction = Selector("openAppFinder:")
        self.keychainTable.reloadData()
        
        
        self.keychainTable.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    }
    
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let its = self.itemArray {
            return its.count;
        }
        return 0;
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let row = self.keychainTable.selectedRow;
        if( row < 0 || row > self.itemArray?.count) {
            return
        }
        
        let item = self.itemArray![row]
        if item.classType == XGSecurityItem.ClassType.InternetPassword {
            let image = NSImage(named: NSImageNameUserAccounts )
            iconView.image = image;
        } else if item.classType == XGSecurityItem.ClassType.GenericPassword {
            let image = NSImage(named: NSImageNameComputer)
            iconView.image = image;
        }
        
        self.classLabel.objectValue = item.classType?.description;
        self.nameLabel.objectValue = item.name
        self.accountLabel.objectValue = item.account
        self.positionLabel.objectValue = item.position
        var appStr = ""
        if let appList = item.applicationList {
            for (var i = 0 ; i < appList.count ; i++) {
                if(i > 1) {  appStr += " | " }
                appStr += (appList[i] as NSString).lastPathComponent
            }
        } else  if item.applicationNum == -1 {
            appStr = "ANY Application"
        }
        self.applicationsLabel.objectValue = appStr
        
        
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if nil == self.itemArray {
            return nil
        }
        let item = self.itemArray![row]
        
        
        if let identifier = tableColumn?.identifier {
            switch identifier {
            case "NameCell":
                if let nameTextField = tableView.makeViewWithIdentifier(identifier,owner:self) as? NSTableCellView {
                    nameTextField.textField!.objectValue  = item.name;
                    //nameTextField.textField!.stringValue = item.name!;
                    //let cellRect = CGRectMake(0, 0, tableView.frame.size.width ,44);
                    //nameTextField.frame = cellRect;
                    return nameTextField;
                }
                break;
                
            case "ClassCell":
                if let classTextField = tableView.makeViewWithIdentifier(identifier,owner:self) as? NSTableCellView {
                    classTextField.textField!.objectValue = item.classType!.description;
                    return classTextField
                }
                break;
                
            case "ApplicationsCell":
                let appCellView = tableView.makeViewWithIdentifier(identifier,owner:self) as? NSTableCellView
                if(nil == appCellView){
                    return nil
                }
                
                if(item.applicationNum > 0) {
                    let applicationFullPath = item.applicationList![0];
                    let appName = (applicationFullPath as NSString).lastPathComponent
                    appCellView!.textField!.objectValue = appName
                    
                    let image = NSWorkspace.sharedWorkspace().iconForFile(applicationFullPath)
                    appCellView!.imageView?.objectValue = image
                    return appCellView
                } else if(item.applicationNum == -1) {
                    
                    appCellView!.textField?.objectValue = Keychain.secAuthorizeAllApp
                    return appCellView
                } else {
                    return nil
                }
            default:
                break;
            }
        }
        
        return nil;
    }
    
    //double clicks to open the application in finder
    func openAppFinder(sender: AnyObject) {
        // let row = self.tableView.rowForView(sender as! NSView)
        let row = (sender as! NSTableView).clickedRow
        if nil == self.itemArray || row < 0 || row >= self.itemArray?.count{
            return
        }
        let item = self.itemArray![row]
        if let applicationFullPath = item.applicationList?[0] {
            NSWorkspace.sharedWorkspace().selectFile(applicationFullPath, inFileViewerRootedAtPath: "")
        }
    }


    
    
    
    
}
