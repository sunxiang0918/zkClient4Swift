//
//  Ping.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/17.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class Ping : Serializable {
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendInt(-2)       //xid
        buf.appendInt(zkOpCode.ping.rawValue)
    }
}