//
//  CreateRequest.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class CreateRequest:Serializable {
    
    var path:String=""
    var data:NSData?
    var acls:[ACL] = []
    var flag:CreateMode = CreateMode.EPHEMERAL
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendString(path)
        buf.appendBuffer(data)
        
        //写入ACL数组
        buf.appendInt(acls.count)
        for acl in acls {
            buf.appendRecord(acl)
        }
        
        buf.appendInt(flag.toFlag())
    }
}