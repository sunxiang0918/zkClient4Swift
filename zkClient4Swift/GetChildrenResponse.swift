//
//  GetChildrenResponse.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class GetChildrenResponse:Deserializable {
    
    private(set) public var children:[String] = []
    
    public func deserialize(buf: StreamInBuffer) {
        
        let childrenCount = buf.readInt()
        if childrenCount <= 0 {
            return
        }
        for _ in 0 ..< childrenCount{
            if let child = buf.readString() {
                self.children.append(child)
            }
        }
        
        //TODO 还有 Stat 状态数据没有记录
    }
}