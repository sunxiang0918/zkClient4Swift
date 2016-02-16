//
//  NSMutableData+Extension.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public extension NSMutableData {
    
    // MARK: Int32与Int64
    public func appendInt(value:Int){
        var networkOrderVal = CFSwapInt32HostToBig(UInt32(value))
        self.appendBytes(&networkOrderVal, length: sizeof(UInt32))
    }
    
    public func appendLong(value:Int) {
        var networkOrderVal = CFSwapInt64HostToBig(UInt64(value));
        self.appendBytes(&networkOrderVal, length: sizeof(UInt64))
    }
    
    // MARK: Float32与Float64
    public func appendFloat(value:Float) {
        var networkOrderVal = CFConvertFloat32HostToSwapped(Float32(value))
        self.appendBytes(&networkOrderVal, length: sizeof(Float32))
    }
    
    public func appendDouble(value:Double) {
        var networkOrderVal = CFConvertFloat64HostToSwapped(Float64(value))
        self.appendBytes(&networkOrderVal, length: sizeof(Float64))
    }
    
    
    // MARK: Bool
    public func appendBool(var val:Bool){
        self.appendBytes(&val, length: sizeof(Bool))
    }
    
    // MARK: String
    public func appendString(val:String,encoding:NSStringEncoding = NSUTF8StringEncoding){
        
        //获取到字节的长度,使用某一种编码
        let pLength : Int = val.lengthOfBytesUsingEncoding(encoding)

        //放入字符串的长度
        self.appendInt(pLength)
        
        //把字符串按照某种编码转化为字节数组
        let data = val.dataUsingEncoding(encoding)
        
        //放入NSData中
        self.appendData(data!)
    }

}

public extension NSData {
    
    convenience init(var uints:[UInt8]) {
        self.init(bytes:&uints,length:uints.count)
    }
    
    // MARK: Int32与Int64
    public func getInt(range:NSRange = NSRange(location:0,length:sizeof(UInt32))) -> Int {
        var val: UInt32 = 0
        self.getBytes(&val, range: range)
        return Int(CFSwapInt32BigToHost(val))
    }
    
    public func getLong(range:NSRange = NSRange(location:0,length:sizeof(UInt64))) -> Int {
        var val: UInt64 = 0
        self.getBytes(&val, range: range)
        return Int(CFSwapInt64BigToHost(val))
    }

    // MARK: Float32与Float64
    public func getFloat(range:NSRange = NSRange(location:0,length:sizeof(Float32))) -> Float {
        
        var val: CFSwappedFloat32 = CFSwappedFloat32(v: 0)
        self.getBytes(&val, range: range)
        let result = CFConvertFloat32SwappedToHost(val)
        return result
    }
    
    public func getDouble(range:NSRange = NSRange(location:0,length:sizeof(Float64))) -> Double {
        var val: CFSwappedFloat64 = CFSwappedFloat64(v: 0)
        self.getBytes(&val, range: range)
        let result = CFConvertFloat64SwappedToHost(val)
        return result
    }
    
    // MARK: Bool
    public func getBool(range:NSRange = NSRange(location:0,length:sizeof(Bool))) -> Bool {
        var val:Bool = false
        self.getBytes(&val, range: range)
        return val
    }
    
    // MARK: String
    public func getString(location:Int = 0,encoding:NSStringEncoding = NSUTF8StringEncoding) throws -> (String,Int){
        
        //先获取到长度
        let len = self.getInt(NSRange(location:location,length:sizeof(UInt32)))
        
        //找到子字节数组
        let subData = self.subdataWithRange(NSRange(location: location+sizeof(UInt32), length: len))
        
        //直接使用String的构造函数,采用某种编码格式获取字符串
        let string = String(data: subData, encoding: encoding)
        
        //如果凑不起字符串,就表示数据不正确,那么就抛出异常
        guard let _string = string else {
            throw AppException.FormatCastException
        }
        
        //返回结果
        return (_string,len+sizeof(UInt32))
    }

}
