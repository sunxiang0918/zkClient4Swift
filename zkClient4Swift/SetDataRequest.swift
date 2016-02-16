//
//  SetDataRequest.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class SetDataRequest : Serializable {
    
    var path:String = ""
    var data:NSData?
    var version:Int = -1
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendString(path)
        buf.appendBuffer(data)
        buf.appendInt(version)
    }
    
}