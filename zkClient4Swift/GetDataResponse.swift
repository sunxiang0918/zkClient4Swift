//
//  GetDataResponse.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class GetDataResponse : Deserializable {
    
    private(set) public var data:NSData?
    
    public func deserialize(buf: StreamInBuffer) {
        
        if  buf.getData().length > 0 {
            data = buf.getData()
        }
        
    }
}