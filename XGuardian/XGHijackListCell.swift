//
//  XGHijackListCell.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/30.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGHijackListCell: NSTableCellView {

    @IBOutlet var imageLabel: NSImageView?
    @IBOutlet var nameLabel: NSTextField?
    @IBOutlet var classLabel: NSTextField?
    @IBOutlet var accountLabel: NSTextField?
    @IBOutlet var positionLabel: NSTextField?
    @IBOutlet var modifyLabel: NSTextField?

    
    weak var  item : XGSecurityItem?
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        //
//        self.applicationTable?.headerView = nil
//        self.applicationTable?.setDelegate(self)
//        self.applicationTable?.setDataSource(self)
//        
//        
//        self.applicationTable?.reloadData()
    }
    
    
   
}
