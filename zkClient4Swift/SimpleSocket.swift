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
    
    private(set) var connected:Bool = false

    public var hasSpaceAvailableDelegate:((NSStream) -> Void)?
    public var hasBytesAvailableDelegate:((NSStream) -> Void)?
    public var endEncounteredDelegate:((NSStream) -> Void)?
    public var errorOccurredDelegate:((NSStream) -> Void)?
    
    private var _readStream:Unmanaged<CFReadStream>?
    private var _writeStream:Unmanaged<CFWriteStream>?
    
    private var inputStream:NSInputStream?
    private var outputStream:NSOutputStream?
    
    override init(){
        self.addr=""
        self.port=0
    }
    
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
    }
    
    public func connect(timeout t:Int)->(Bool,String){

        
        NSStream.getStreamsToHostWithName(addr, port: port, inputStream: &inputStream, outputStream: &outputStream)

        guard let inputStream = inputStream,outputStream = outputStream else {
            //这里说明没有开启流
            return (false,"Can not open stream")
        }

        inputStream.delegate = self
        outputStream.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let loop = NSRunLoop.currentRunLoop()
            inputStream.scheduleInRunLoop(loop, forMode: NSDefaultRunLoopMode)
            outputStream.scheduleInRunLoop(loop, forMode: NSDefaultRunLoopMode)
            inputStream.open()
            outputStream.open()
            loop.run()
        }

        return (true,"")
    }
    
    
    public func close()->(Bool,String){
        return (false,"")
    }
    
    public func send(var data d:[UInt8])->(Bool,String){
     
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
            return nil
        }
        
        var buff:[UInt8] = [UInt8](count:expectlen,repeatedValue:0x0)
        
        let len = inputStream.read(&buff, maxLength: expectlen)
        
        if len > 0 {
            let result = buff[0..<len]
            return Array(result)
        }
        
        return nil
    }
    
    
    //
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch (eventCode) {
            case NSStreamEvent.HasSpaceAvailable:
                print("接收到HasSpaceAvailable事件:\(aStream)")
                hasSpaceAvailableDelegate?(aStream)
                break
            case NSStreamEvent.HasBytesAvailable:
                print("接收到HasBytesAvailable事件:\(aStream)")
                hasBytesAvailableDelegate?(aStream)
                break
            case NSStreamEvent.EndEncountered:
                print("接收到EndEncountered事件:\(aStream)")
                endEncounteredDelegate?(aStream)
                break
            case NSStreamEvent.ErrorOccurred:
                print("接收到ErrorOccurred事件:\(aStream)")
                errorOccurredDelegate?(aStream)
                break
        default:
            print("接收到事件:\(eventCode) OpenCompleted事件:\(NSStreamEvent.OpenCompleted):\(aStream)")
            break;
        }
    }

}
