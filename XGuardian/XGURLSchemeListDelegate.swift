//
//  XGURLSchemeListDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/26.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

@objc(XGURLSchemeListDelegate)
class XGURLSchemeListDelegate: XGURLSchemeThreatsDelegate {
    
    static let sharedListInstance = XGURLSchemeListDelegate()
    static func getListInstance() -> XGThreatsViewDelegate {
        return sharedListInstance
    }
    
    //private weak var URLSchemeDict : XGURLSchemeDict?
    
    override func refreshThreatsData() -> Int {
        self.URLSchemeDict = XGURLSchemeManager.sharedInstance.urlSchemeApplications
        
        if let count = self.URLSchemeDict?.dataDict.count {
            return count
        }
        return 0
    }
 }
