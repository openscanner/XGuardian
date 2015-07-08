//
//  XGScanView.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/8.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGScanView: NSView {
    

    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        let bezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 0, yRadius: 0)
        bezierPath.lineWidth = 1.0
        NSColor.whiteColor().set()
        bezierPath.fill()
        
    }
    
    
    
    
    
}

