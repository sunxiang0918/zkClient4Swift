//
//  Deserializable.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public protocol Deserializable {
    
    /**
     反序列化
     
     - parameter buf:
     */
    func deserialize(buf:StreamInBuffer)
}