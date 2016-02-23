//
//  SimpleSocket.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class SimpleSocket : NSObject,NSStreamDelegate {
    
    private(set) var addr:String
    private(set) var port:Int
    private(set) var connectTimeout = 30000
    
    
    private(set) var connected:Bool = false
    
    private var reconnectionLock:ReadWriteLock      //重连接的锁
    
    private var inputLock:ReadWriteLock
    private var outputLock:ReadWriteLock
    
    private var _closed:Bool = false        //标识是是否是手动关闭

    public var hasSpaceAvailableDelegate:((NSStream) -> Void)?
    public var hasBytesAvailableDelegate:((NSStream) -> Void)?
    public var endEncounteredDelegate:((NSStream) -> Void)?
    public var errorOccurredDelegate:((NSStream) -> Void)?
    
    private var _readStream:Unmanaged<CFReadStream>?
    private var _writeStream:Unmanaged<CFWriteStream>?
    
    private var inputStream:NSInputStream?
    private var outputStream:NSOutputStream?
    
    private var loop:NSRunLoop?
    
    override init(){
        self.addr=""
        self.port=0
        reconnectionLock = ReadWriteLock()
        inputLock = ReadWriteLock()
        outputLock = ReadWriteLock()
    }
    
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
        reconnectionLock = ReadWriteLock()
        inputLock = ReadWriteLock()
        outputLock = ReadWriteLock()
    }
    
    private let sharedWorkQueue = dispatch_queue_create("socketWork.queue", DISPATCH_QUEUE_CONCURRENT)
    
    public func connect(timeout t:Int)->(Bool,String){
        
        connectTimeout = t
        
        NSStream.getStreamsToHostWithName(addr, port: port, inputStream: &inputStream, outputStream: &outputStream)

        guard let inputStream = inputStream,outputStream = outputStream else {
            //这里说明没有开启流
            return (false,"Can not open stream")
        }

        inputStream.delegate = self
        outputStream.delegate = self
        
        // 更换了一种方式来打开inputStream和outputStream,避免使用RunLoop的方式 无法关闭循环
        CFReadStreamSetDispatchQueue(inputStream, sharedWorkQueue)
        CFWriteStreamSetDispatchQueue(outputStream, sharedWorkQueue)
        inputStream.open()
        outputStream.open()
        self.connected = true
        
        inputLock.writeLock()
        outputLock.writeLock()
        
        return (true,"")
    }
    
    
    public func close()->(Bool,String){
        _closed = true
        
        outputStream?.delegate = nil
        inputStream?.delegate = nil
        if let stream = inputStream {
            CFReadStreamSetDispatchQueue(stream, nil)
            stream.close()
        }
        if let stream = outputStream {
            CFWriteStreamSetDispatchQueue(stream, nil)
            stream.close()
        }
        outputStream = nil
        inputStream = nil
        
        self.connected = false
        
        return (true,"")
    }
    
    public func send(var data d:[UInt8])->(Bool,String){
        outputLock.readLock()
        defer{outputLock.readUnlock()}
        
        guard let outputStream = outputStream else {
            return (false,"outputStream is closed")
        }
        let len = outputStream.write(&d, maxLength: d.count)
        return len==d.count ? (true,"") : (false,"send error")
    }
    
    
    public func send(str s:String)->(Bool,String){
        
        guard let data = s.dataUsingEncoding(NSUTF8StringEncoding) else {
            return (false,"string format error")
        }
        
        return send(data: data)
    }
    
    public func send(data d:NSData)->(Bool,String){
        var buff:[UInt8] = [UInt8](count:d.length,repeatedValue:0x0)
        d.getBytes(&buff, length: d.length)
        return send(data: buff)
    }
    
    public func read(expectlen:Int, timeout:Int = -1)->[UInt8]?{
     
        guard let inputStream = inputStream else {
            print("错误,没有打开inputStream")
            return nil
        }
        
        var buff:[UInt8] = [UInt8](count:expectlen,repeatedValue:0x0)
        
        let len = inputStream.read(&buff, maxLength: expectlen)
        
        if len > 0 {
            let result = buff[0..<len]
            return Array(result)
        }
        
        print("读取出来的len为0,错误:\(inputStream.streamError)")
        
        return nil
    }
    
    
    //
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch (eventCode) {
            case NSStreamEvent.HasSpaceAvailable:
//                print("接收到HasSpaceAvailable事件:\(aStream)")
                reconnectionLock.readLock()
                defer{reconnectionLock.readUnlock()}
                hasSpaceAvailableDelegate?(aStream)
                break
            case NSStreamEvent.HasBytesAvailable:
//                print("接收到HasBytesAvailable事件:\(aStream)")
                reconnectionLock.readLock()
                defer{reconnectionLock.readUnlock()}
                hasBytesAvailableDelegate?(aStream)
                break
            case NSStreamEvent.EndEncountered:
//                print("接收到EndEncountered事件:\(aStream) error:\(aStream.streamError)")
                
                connected = false
                
                endEncounteredDelegate?(aStream)
                break
            case NSStreamEvent.ErrorOccurred:
//                print("接收到ErrorOccurred事件:\(aStream) error:\(aStream.streamError)")
                errorOccurredDelegate?(aStream)
                break
            case NSStreamEvent.OpenCompleted:
//                print("接收到OpenCompleted事件:\(aStream)")
                if aStream is NSInputStream {
                    inputLock.writeUnlock()
                }
                if aStream is NSOutputStream {
                    outputLock.writeUnlock()
                }
                break
        default:
            print("接收到事件:\(eventCode) :\(aStream)")
            break;
        }
    }
    
    /**
     断线重连
     */
    public func reconnection() {
        
        //上写锁
        reconnectionLock.writeLock()
        //解写锁
        defer{reconnectionLock.writeUnlock()}
        
        close()
        
        connect(timeout: connectTimeout)
        
        connected = true
    }

}
