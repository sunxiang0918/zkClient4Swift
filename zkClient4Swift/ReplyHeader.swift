//
//  ReplyHeader.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class ReplyHeader:Deserializable {
    
    private(set) var xid:Int=0
    
    private(set) var zxid:Int=0
    
    private(set) var error:Int=0
    
    var headerLength:Int {
        get {
            return sizeof(UInt32)+sizeof(UInt64)+sizeof(UInt32)
        }
    }
    
    public func deserialize(buf: StreamInBuffer) {
        self.xid = buf.readInt()
        self.zxid = buf.readLong()
        self.error = buf.readInt()
    }
    
    
}