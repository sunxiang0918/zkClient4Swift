//
//  StreamInBuffer.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class StreamInBuffer {
    
    private let _data:NSData
    private var _pos:Int

    
    public init(data:NSData){
        self._pos = 0
        self._data = data
    }
    
    public func readInt() -> Int {
        var val: Int = 0
        _data.getBytes(&val, range: NSRange(location: _pos, length: sizeof(UInt32)))
        _pos += sizeof(UInt32)
        val = Int(CFSwapInt32BigToHost(UInt32(val)))
        return val
    }
    
    public func readLong() -> Int {
        var val: Int = 0
        _data.getBytes(&val, range: NSRange(location: _pos, length: sizeof(UInt64)))
        _pos += sizeof(UInt64)
        val = Int(CFSwapInt64BigToHost(UInt64(val)))
        return val
    }
    
    public func readBool() -> Bool {
        var val:Bool = false
        _data.getBytes(&val, range: NSRange(location: _pos, length: sizeof(Bool)))
        _pos += sizeof(Bool)
        return val
    }
    
    public func readString() throws -> String{
        let len = self.readInt()
        
        let subData = _data.subdataWithRange(NSRange(location: _pos, length: len))
        
        let string = String(data: subData, encoding: NSUTF8StringEncoding)
        
        _pos += len
        
        guard let _string = string else {
            throw AppException.FormatCastException
        }
        
        return _string
    }
    
//    - (void) readRecord:(id<Deserializable>)record;
    
}