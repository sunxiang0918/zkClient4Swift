//
//  DeleteRequest.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class DeleteRequest : Serializable {
    
    var path:String = ""
    var version:Int = 0
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendString(path)
        buf.appendInt(version)
    }
}