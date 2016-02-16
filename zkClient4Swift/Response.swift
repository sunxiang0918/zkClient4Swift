//
//  Response.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation


public class Response {
    
    private(set) public var header:ReplyHeader
    
    private(set) public var data:NSData
    
    
    init(header:ReplyHeader,data:NSData) {
        self.header = header
        self.data = data
    }
}