//
//  XGHijackListView.swift
//  XGuardian
//
//  Created by WuYadong on 15/6/29.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

private let noHijackStr = "Congratulation!"
private let noHijackImage = NSImageNameStatusAvailable
private let hijackStr = "OW, NO!"
private let hijackImage = NSImageNameCaution

class XGHijackListView: NSView, NSTableViewDelegate, NSTableViewDataSource {

        private var itemArray : [XGSecurityItem]?
    
    @IBOutlet weak var titleImage: NSImageView!
    @IBOutlet weak var titleLable: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    

    
    
    @IBAction func btnRevelAction(sender: AnyObject) {
        let row = self.tableView.rowForView(sender as! NSView)
        
      /*  ATDesktopEntity *entity = [self _entityForRow:row];
        [[NSWorkspace sharedWorkspace] selectFile:[entity.fileURL path] inFileViewerRootedAtPath:nil];*/
    }
    
    @IBAction func btnDeleteAction(sender: AnyObject) {
        let row = self.tableView.rowForView(sender as! NSView)
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        
        //self.tableView.doubleAction = Selector("openAppFinder:")
    
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        //
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)
        //self.tableView.doubleAction = Selector("openAppFinder:")
        
        self.scan()
    }
    
    /**
    scan
    */
    func scan() {
        if  let itemSet = XGKeyChain.getItemSet() {
            self.itemArray = itemSet.getPotentialArray();
        }
        if( (nil == self.itemArray) || self.itemArray!.count < 0) {
            self.titleImage.objectValue = NSImage(named:noHijackImage);
            self.titleLable.objectValue = noHijackStr;
        } else {
            self.titleImage.objectValue = NSImage(named:hijackImage);
            let title = hijackStr + " You have\(self.itemArray!.count) password maybe in danger"
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
                
                mainCell.textField!.objectValue = item.name
                if item.classType == XGSecurityItem.ClassType.InternetPassword {
                    mainCell.imageView!.objectValue = NSImage(named: NSImageNameUserAccounts)
                }
                
                mainCell.classLable?.objectValue = item.classType?.description
                mainCell.accountLable?.objectValue = item.account
                mainCell.positionLable?.objectValue = item.position
                mainCell.modifyLable?.objectValue = item.modifyTime?.description
                //mainCell.application =
                
                
             //   mainCell.
                if let applicationList = item.applicationList {
                    for (var i = 0; i < applicationList.count ; i++){
                        let application = applicationList[i]
                        if(i == 0) {
                            mainCell.application?.objectValue = application.lastPathComponent
                            mainCell.appFullPath?.objectValue = application
                            mainCell.appImage?.objectValue = NSWorkspace.sharedWorkspace().iconForFile(application)
                        } else {
                            
                        }
                    
                    let appPathFiled = NSTextField(frame: mainCell.frame)
                    
                    /*
                    // Create the new NSTextField with a frame of the {0,0} with the width of the table.
                    // Note that the height of the frame is not really relevant, because the row height will modify the height.
                    result = [[NSTextField alloc] initWithFrame:...];
                    
                    // The identifier of the NSTextField instance is set to MyView.
                    // This allows the cell to be reused.
                    result.identifier = @"MyView";
                    */
                    
                    }
                }

                
                return mainCell;
            }
        }
        return nil;
    }
/**************************************/

    
}
