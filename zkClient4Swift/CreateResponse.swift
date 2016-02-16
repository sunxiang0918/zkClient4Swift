//
//  CreateResponse.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class CreateResponse : Deserializable {
    
    private(set) public var path:String?
    
    public func deserialize(buf: StreamInBuffer) {
        
        if  buf.getData().length > 0 {
            path = buf.readString()
        }
    }
}