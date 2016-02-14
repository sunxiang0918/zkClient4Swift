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
        var networkOrderVal = CFSwapInt32HostToBig(UInt32(val))
        _data.appendBytes(&networkOrderVal, length: 4)
    }
    
    public func appendLong(val:Int){
        var networkOrderVal = CFSwapInt64HostToBig(UInt64(val));
        _data.appendBytes(&networkOrderVal, length: sizeof(UInt64))
    }
    
    public func appendBool(var val:Bool){
        _data.appendBytes(&val, length: sizeof(Bool))
    }
    
    public func appendString(val:String){
        
        let pLength : Int = val.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
//        let pLength = val.characters.count
        
        var len = CFSwapInt32HostToBig(UInt32(pLength))
        
        _data.appendBytes(&len, length: sizeof(UInt32))
        
        let data = val.dataUsingEncoding(NSUTF8StringEncoding)
        
        _data.appendData(data!)
        
    }
    
    public func getBuffer() -> NSData {
        return _data
    }
}