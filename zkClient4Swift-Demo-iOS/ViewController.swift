//
//  ViewController.swift
//  zkClient4Swift-Demo-iOS
//
//  Created by SUN on 16/2/19.
//  Copyright © 2016年 SUN. All rights reserved.
//

import UIKit
import zkClient4Swift

class ViewController: UIViewController {

    let zkClient = ZkClient(serverstring: "127.0.0.1:2181")
    
    @IBOutlet weak var pathField: UITextField!
    
    @IBOutlet weak var resultTextView: UITextView!
    
    @IBAction func getDataAction(sender: UIButton) {
        if !zkClient.connected {
            return
        }
        
        let value = zkClient.readData(pathField.text!) as? String
        
        resultTextView.text = value
    }
    
    @IBAction func connection(sender: UIButton) {
        zkClient.connect()
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

