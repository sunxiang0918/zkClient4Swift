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
        
        defer {
            _pos += sizeof(UInt32)
        }
        
        return _data.getInt(NSRange(location: _pos, length: sizeof(UInt32)))
    }
    
    public func readLong() -> Int {
        
        defer {
            _pos += sizeof(UInt64)
        }
        
        return _data.getLong(NSRange(location: _pos, length: sizeof(UInt64)))
    }
    
    public func readBool() -> Bool {
        
        defer {
            _pos += sizeof(Bool)
        }
        
        return _data.getBool(NSRange(location: _pos, length: sizeof(Bool)))
    }
    
    public func readString() throws -> String{
        
        let (_string,len) = try _data.getString(_pos)
        
        defer {
            _pos += len
        }
        
        return _string
    }
    
//    - (void) readRecord:(id<Deserializable>)record;
    
}