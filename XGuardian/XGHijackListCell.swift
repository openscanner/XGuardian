//
//  XGHijackListCell.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/30.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGHijackListCell: NSTableCellView {

    @IBOutlet var classLable: NSTextField?
    @IBOutlet var accountLable: NSTextField?
    @IBOutlet var positionLable: NSTextField?
    @IBOutlet var modifyLable: NSTextField?
    
    @IBOutlet var application: NSTextField?
    @IBOutlet var appFullPath: NSTextField?
    @IBOutlet var appImage: NSImageView?
  //  @IBOutlet var accountLable: NSTextField!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }

}
