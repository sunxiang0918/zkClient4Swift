//
//  ExistsResponse.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class ExistsResponse:Deserializable {
    
    private(set) public var exists = false
    
    public func deserialize(buf: StreamInBuffer) {
        
        if  buf.getData().length == 0 {
            exists = false
        }else{
            exists = true
        }
        
    }
}