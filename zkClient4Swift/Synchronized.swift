//
//  Synchronized.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

/**
 同步代码块,据说是有问题的: http://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
 
 - parameter lock: 锁对象
 - parameter block: 同步代码块
 */
public func synchronized( lock:AnyObject, block:() -> Void ){
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    
    block()
}