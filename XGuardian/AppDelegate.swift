//
//  AppDelegate.swift
//  XGuardian
//
//  Created by  吴亚冬 on 15/6/29.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

import Cocoa

private let hijackName = "Keychain Hijack"
private let hijackImage = NSImageNameQuickLookTemplate
private let keychainName = "Keychain List"
private let keychainImage = NSImageNameListViewTemplate
private let nagivationData =  [["name":hijackName, "image":hijackImage],
    ["name":keychainName, "image":keychainImage]
]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSPageControllerDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var nagivationView: NSTableView!
    @IBOutlet weak var pageController: NSPageController!


    func applicationDidFinishLaunching(aNotification: NSNotification) {

        XGKeychainObserver.startObserve()
        self.loadViews()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        XGKeychainObserver.stopObserve()
    }
    
    func loadViews() {

        //nagivation table view
        //self.nagivationView.setDataSource(self)
        //self.nagivationView.setDelegate(self)
        
        pageController.delegate = self as NSPageControllerDelegate;
        
        pageController.arrangedObjects = nagivationData;
        pageController.transitionStyle = NSPageControllerTransitionStyle.StackBook
        
        self.nagivationView.reloadData()
        //TODO: set the first card in our list
        self.nagivationView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return nagivationData.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let buttonDict = nagivationData[row]
        if let identifier = tableColumn?.identifier {
            if let cellView = tableView.makeViewWithIdentifier(identifier,owner:self) as? NSTableCellView {
                cellView.textField!.objectValue = buttonDict["name"]!
                let image = NSImage(named: buttonDict["image"]!)
                cellView.imageView?.objectValue = image
                return cellView
            }
        }
        
        return nil
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let row = self.nagivationView.selectedRow;
        if( row < 0 && row > nagivationData.count && row == self.pageController.selectedIndex) {
            return
        }
        // The selection of the table view changed. We want to animate to the new selection.
        // However, since we are manually performing the animation,
        // -pageControllerDidEndLiveTransition: will not be called. We are required to
        // [self.pageController completeTransition] when the animation completes.
        //
        self.pageController.selectedIndex = row
        NSAnimationContext.runAnimationGroup( {context in self.pageController.animator().selectedIndex = row; return ()}, completionHandler: {self.pageController.completeTransition()})
        
    }
    
    //- (void)scrollWheel:(NSEvent *)theEvent
    
    //*MARK: NSPageControllerDelegate
    
    func pageController(pageController: NSPageController,viewControllerForIdentifier identifier: String!) -> NSViewController! {
        
        let view = NSViewController(nibName: identifier, bundle: nil)
        return view
    }
    
    func pageController(pageController: NSPageController, identifierForObject object: AnyObject!) -> String! {
        
        let dict:[String:String] = object as! [String:String]
    
        let name = dict["name"]
        if(hijackName == name) {
            return "HijackView"
        } else {
            return "KeychainView"
        }
    }
    
   /* func pageController(pageController: NSPageController, prepareViewController viewController: NSViewController!, withObject object: AnyObject!) {
        
        viewController.loadView();
        return;
    }*/
    
    
    func pageController(pageController: NSPageController, frameForObject object: AnyObject!) -> NSRect {
        return NSInsetRect(pageController.view.bounds, 1, 1);
    }
    
    func pageControllerDidEndLiveTransition(pageController: NSPageController) {
        
        //self.nagivationView.selectRowIndexes(NSIndexSet(index: pageController.selectedIndex), byExtendingSelection: false)
        
        pageController.completeTransition();
    }
    
    



}

