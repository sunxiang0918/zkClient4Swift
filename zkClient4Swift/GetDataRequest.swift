//
//  GetDataRequest.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class GetDataRequest : Serializable {
    
    var path:String = "/"
    var watch:Bool = false
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendString(path)
        buf.appendBool(watch)
    }
}