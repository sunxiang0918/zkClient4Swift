//
//  StreamOutBuffer.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class StreamOutBuffer {
    private var _data:NSMutableData
    
    public init(){
        _data = NSMutableData()
    }
    
    public func appendInt(val:Int){
        _data.appendInt(val)
    }
    
    public func appendLong(val:Int){
        _data.appendLong(val)
    }
    
    public func appendBool(val:Bool){
        _data.appendBool(val)
    }
    
    public func appendString(val:String?){
        
        _data.appendString(val)
    }
    
    public func appendBuffer(val:NSData?){
        if let val = val {
            _data.appendData(val)
        }
//        _data.appendBuffer(val)
    }
    
    public func appendRecord(val:Serializable) {
        val.serialize(self)
    }
    
    public func getBuffer() -> NSData {
        return _data
    }
}