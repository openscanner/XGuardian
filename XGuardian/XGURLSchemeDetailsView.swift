//
//  XGURLSchemeDetailsView.swift
//  XGuardian
//
//  Created by WuYadong on 15/7/23.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

class XGURLSchemeDetailsView: NSView , NSMatrixDelegate {

    @IBOutlet weak var SchemeApplicationsMatrix: NSMatrix!
    
    weak var upperViewController : XGThreatsViewController?
    var scheme : String?
    var appFullPaths : [String]?
    var preSelectedRow = 0
    
    @IBAction func matrixAction(sender: AnyObject) {
        if self.isChangedRow() {
            if let app = appFullPaths?[self.preSelectedRow] {
                println("set default app: \(app)")
                XGURLSchemeManager.sharedInstance.setDefaultApplication(scheme!, appFullPath: app)
            }
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        // Drawing code here.
        let bezierPath = NSBezierPath(roundedRect: self.bounds, xRadius: 0, yRadius: 0)
        bezierPath.lineWidth = 1.0
        NSColor.whiteColor().set()
        bezierPath.fill()
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        
        self.SchemeApplicationsMatrix.delegate = self
        self.SchemeApplicationsMatrix.tabKeyTraversesCells = false
        self.SchemeApplicationsMatrix.tabKeyTraversesCells = false
        
        self.setAppRaido()
        
    }
    
    private func setRow(row : Int) {
        if ( self.SchemeApplicationsMatrix.selectedRow != row) {
            self.SchemeApplicationsMatrix.selectCellAtRow(row, column:0)
        }
        self.preSelectedRow = row
    }
    
    private func isChangedRow() -> Bool {
        if ( self.SchemeApplicationsMatrix.selectedRow != self.preSelectedRow) {
            self.preSelectedRow = self.SchemeApplicationsMatrix.selectedRow 
            return true
        }
        return false
    }

    
    private func setAppRaido() {
        if let appFullPaths = self.appFullPaths {
            for (var i = 1; i < appFullPaths.count; i++) {
                self.SchemeApplicationsMatrix.addRow()
            }
            
            let defaultApp = XGURLSchemeManager.sharedInstance.getDefaultApplication(self.scheme!)
            let cellArray = self.SchemeApplicationsMatrix.cells
            for (var i = 0; i < appFullPaths.count; i++) {
                let cell = cellArray[i] as!  NSButtonCell
                cell.title = appFullPaths[i].lastPathComponent
                if defaultApp == appFullPaths[i] {
                    self.setRow(i)
                }
            }
        }
    }
    
}
