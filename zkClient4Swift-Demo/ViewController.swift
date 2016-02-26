//
//  ViewController.swift
//  zkClient4Swift-Demo
//
//  Created by SUN on 16/2/17.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Cocoa
import zkClient4Swift

class ViewController: NSViewController {

    @IBOutlet weak var tabBar: MMTabBarView!
    @IBOutlet weak var tabBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tabView: NSTabView!
    
    let zkClient = ZkClient(serverstring: "127.0.0.1:2181")

//    let socket = SimpleSocket(addr: "127.0.0.1", port: 8080)
    
    @IBAction func connection(sender: NSButton) {
        
        try! zkClient.connect()
        
        debugPrint(zkClient.connected)
        
//        let children = zkClient.getChildren("/ftengine")
//        
//        for child in  children! {
//            print("子节点:\(child)")
//        }

//        print("接收到的数据:\(zkClient.readData("/Hello/Byte",watch: true))")
        
        zkClient.subscribeChildChanges("/Hello", listenerName: "HelloChildChanges") { (path, children) -> Void in
            print("路径:\(path)子节点发生变化:")
            if let cc  = children {
                for c in cc {
                    print("\(c)")
                }
            }
        }
        
        zkClient.subscribeDataChanges("/Hello/Byte", listenerName: "ByteNodeDataChanges") { (path, data) -> Void in
            print("路径:\(path)节点内容发生变化,新的内容为:\(data)")
        }
        
        zkClient.subscribeDataDelete("/Hello/Byte", listenerName: "ByteNodeDelete") { (path) -> Void in
            print("路径节点:\(path)被删除")
        }

    }
    
    @IBOutlet weak var pathField: NSTextField!
    
    @IBAction func getDataAction(sender: NSButton) {
        if !zkClient.connected {
            return
        }
        
        let value = try! zkClient.readData(pathField.stringValue) as? String
        
        textView.string = value
    }
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tabBar.delegate = self
//        tabView.delegate = self
        tabBar.setStyleNamed("Adium")
        tabBar.setHideForSingleTab(true)
        tabBar.setShowAddTabButton(true)
//        tabBar.setOrientation(MMTabBarHorizontalOrientation)
        tabBar.setButtonMinWidth(1000)
        tabBar.setButtonMaxWidth(4000)
        
        // remove any tabs present in the nib
        for item in tabView.tabViewItems {
            tabView.removeTabViewItem(item)
        }
        
        print(tabBar.numberOfTabViewItems())
        
        let newItem = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("quickConnectionSplitView") as! QuickConnectionViewItem
        
        let view = NSTabViewItem(viewController: newItem)
        let model1 = DemoModel()
        model1.title = "asdf"
        model1.isProcessing = true
        view.identifier = model1
        
        print(tabBar.numberOfTabViewItems())
        
        tabView.addTabViewItem(view)
        
        tabBar.addAttachedButtonForTabViewItem(view)
        
        print(tabBar.numberOfTabViewItems())
        
        
        let newItem2 = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("quickConnectionSplitView") as! QuickConnectionViewItem
        
        tabView.addTabViewItem(NSTabViewItem(viewController: newItem2))
        print(tabBar.numberOfTabViewItems())
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension ViewController: MMTabBarViewDelegate,NSTabViewDelegate {
 
    func addNewTabToTabView(aTabView: NSTabView!) {
        let newItem = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("quickConnectionSplitView") as! QuickConnectionViewItem
        
        let view = NSTabViewItem(viewController: newItem)
        let model1 = DemoModel()
        model1.title = "asdf"
        view.identifier = model1
        
        tabView.addTabViewItem(view)
    }
    
    func tabViewDidChangeNumberOfTabViewItems(tabView: NSTabView) {
        print("到这来了")
    }
    
//    func tabView(aTabView: NSTabView!, tabBarViewDidHide tabBarView: MMTabBarView!) {
//        tabBarHeight.constant = 0.0
//    }
//    
//    func tabView(aTabView: NSTabView!, tabBarViewDidUnhide tabBarView: MMTabBarView!) {
//        tabBarHeight.constant = 30.0
//    }
}

