//
//  RequestHeader.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class RequestHeader:Serializable {

    public var xid:Int=0
    
    private var _type:Int=0
    
    public var type:zkOpCode {
        get {
            return zkOpCode(rawValue: _type)!
        }

        set{
            _type = newValue.rawValue
        }
    }
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendInt(xid)
        buf.appendInt(_type)
    }
}
