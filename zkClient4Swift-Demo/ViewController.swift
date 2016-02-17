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

    let zkClient = ZkClient(serverstring: "127.0.0.1:2181")

//    let socket = SimpleSocket(addr: "127.0.0.1", port: 8080)
    
    @IBAction func connection(sender: NSButton) {
        
        zkClient.connect()
        
        debugPrint(zkClient.connected)
        
//        let children = zkClient.getChildren("/ftengine")
//        
//        for child in  children! {
//            print("子节点:\(child)")
//        }

        print("接收到的数据:\(zkClient.readData("/Hello/Byte"))")
        
//        socket.connect(timeout: -1)
//        socket.hasBytesAvailableDelegate = {aStream in
//            print("读出的结果:\(self.socket.read(10240, timeout: -1))")
//        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

