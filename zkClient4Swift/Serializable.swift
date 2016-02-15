//
//  Serializable.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public protocol Serializable {
    /**
     序列化
     
     - parameter buf: 序列化输出
     */
    func serialize(buf:StreamOutBuffer)

}