//
//  XGThreatsViewController.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/7.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa


@objc protocol XGThreatsViewDelegate { //class only
    
    static func getInstance() -> XGThreatsViewDelegate
    var title : String { get }
    optional func addNotificationObserver()
    optional func removeNotificationObserver()
    
    func refreshThreatsData() -> Int
    

    func childrenForItem(item: AnyObject?) ->  [AnyObject]?
    func isExpandable(item: AnyObject?) -> Bool
    optional func isSelectable(item: AnyObject?) -> Bool
    func setCellView(cellView : NSTableCellView, item: AnyObject, parent : AnyObject? )
    
    var threatsNumber : Int { get }
    
    func detailsView(threatsViewController: XGThreatsViewController, item : AnyObject?, parent : AnyObject? ) -> NSView?
    
    
}


class XGThreatsViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource, NSSplitViewDelegate {

    @IBOutlet weak var threatsListView: NSOutlineView!
    @IBOutlet weak var detailView: NSView!
    @IBOutlet weak var titleButton: NSButton!
    
    weak var barItem: XGSideBarItem?
    
    var threatsDelegate : XGThreatsViewDelegate?
    //for current selected threat detail informations view controlller
    var currentdetailSubView: NSView?
    
    
    var threatsType = XGThreatsType.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
           //nagivation table view
        self.threatsListView.sizeLastColumnToFit()
        self.threatsListView.floatsGroupRows = true
        
        self.refreshThreatsData()
        if let threatsDelegate = self.threatsDelegate {
            self.titleButton.title = threatsDelegate.title
        }

        self.addNotificationObserver()
    }
    
     deinit {
        self.removeNotificationObserver()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.refreshThreatsListView()
        
        // Expand all the root items; disable the expansion animation that normally happens
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = NSTimeInterval(0)
        self.threatsListView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
        
        //set the first card in our list
        self.selectFirstRow()
    }
    
    func getThreatsNum() -> Int {
        
        if let threatsDelegate = self.threatsDelegate {
            return threatsDelegate.threatsNumber
        }
        return 0
    }
    
    //MARK: private functions
    
    private func addNotificationObserver() {
        
        //add notification observer for threats change
        self.threatsDelegate?.addNotificationObserver?()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("threatsDidChanged:"), name: "XGThreadsChangedNotification", object: nil)
    }
    
    private func removeNotificationObserver() {
        self.threatsDelegate?.removeNotificationObserver?()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "XGThreadsChangedNotification", object: nil)
    }
    
    
    private func refreshThreatsData() {
        self.threatsDelegate?.refreshThreatsData()
    }
    
    private func refreshThreatsListView() {

        //TODO: if at back??
        self.threatsListView.reloadData()
        self.selectFirstRow()
    }
    
    
    private func selectFirstRow() {
        if(self.threatsType == XGThreatsType.ALL) {
            self.threatsListView.selectRowIndexes(NSIndexSet(index: 1), byExtendingSelection: false)
        }else {
            self.threatsListView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
        }
    }
    
    
    private func childrenForItem(item: AnyObject?) ->  [AnyObject]? {
        return self.threatsDelegate?.childrenForItem(item)
    }
    
    
    //MARK: delegate for outline view

    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let childrens = self.childrenForItem(item){
            return childrens.count
        }
        return 0
    }
    
    //delegate for outline view; get item for index
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        //it must be have data
        let array = self.childrenForItem(item)!
        return array[index]
    }
    
    //delegate for outline view; expandable
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return self.threatsDelegate!.isExpandable(item)
    }
    
    
    //delegate for outline view; isSelected?
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        
        if let isSelectable = self.threatsDelegate?.isSelectable?(item) {
            return isSelectable
        }
        return true
    }
    
    
    //delegate for outline view; row height
//    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
//        if nil == outlineView.parentForItem(item) {
//            return 17.0
//        }
//        return 17.0
//    }
    
    
    //delegate for outline view
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        let parent: (AnyObject?) = outlineView.parentForItem(item)

        
        // For the groups, we just return a regular text view.
        if  (self.threatsType == XGThreatsType.ALL) && ( parent == nil ) {
            if let result =  outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as? NSTableCellView {
                
                self.threatsDelegate?.setCellView(result, item: item, parent: parent)
                return result
            }
        }  else {
            if let result =  outlineView.makeViewWithIdentifier("DataCell", owner: self) as? NSTableCellView {
  
                self.threatsDelegate?.setCellView(result, item: item, parent: parent)
                return result
            }
        }
        return nil
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let row = self.threatsListView.selectedRow;
        if(row < 0 ) {
            return
        }
           let item: AnyObject? = self.threatsListView.itemAtRow(row)
        let parent: (AnyObject?) = self.threatsListView.parentForItem(item)
        
        if let currentView = self.currentdetailSubView {
            currentView.removeFromSuperview()
        }
        
        if let subView = self.threatsDelegate?.detailsView(self, item: item,  parent: parent) {
            self.detailView.addSubview(subView)
            self.currentdetailSubView = subView
        }
        return;
        
    }
    
    //MARK: -
    private func refreshThreatsListViewAndSideBar() {
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationRefresh, object: self.barItem)
        self.refreshThreatsListView()
    }
    
    func KeychainHijackViewChanged(rescan : Bool) {
        //println("KeychainHijackViewChanged ")
        if rescan {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationRescan, object: self.barItem)
        } else {
            self.refreshThreatsListViewAndSideBar()
        }
    }
    
    
    func threatsDidChanged(notification: NSNotification) {
        
        let rescan =  (notification.object != nil)

        // DO SOMETHING ON THE MAINTHREAD
        self.KeychainHijackViewChanged(rescan)
        
    }


}