//
//  ACL.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class ACL:Serializable,Deserializable {
    
    var perms:Int = 0
    
    var id:Id!
    
    init(){
        
    }
    
    init(perms:Int,id:Id) {
        self.perms = perms
        self.id = id
    }
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendInt(perms)
        buf.appendRecord(id)
    }
    
    public func deserialize(buf: StreamInBuffer) {
        perms = buf.readInt()
        
        id = Id()
        buf.readRecode(id)
    }
}

public class Id:Serializable,Deserializable {
    var scheme:String=""
    var id:String=""
    
    init(){
        
    }
    
    init(scheme:String,id:String) {
        self.scheme = scheme
        self.id = id
    }
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendString(scheme)
        buf.appendString(id)
    }
    
    public func deserialize(buf: StreamInBuffer) {
        scheme = buf.readString()!
        id = buf.readString()!
    }
}