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
    
    var delegate:NSStreamDelegate?
    
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
        
        let loop = NSRunLoop.currentRunLoop()
            
        inputStream.scheduleInRunLoop(loop, forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(loop, forMode: NSDefaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
        
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
        
        inputStream.read(&buff, maxLength: expectlen)
        
        return buff
    }
    
    
    //
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch (eventCode) {
            case NSStreamEvent.HasSpaceAvailable:
                print("接收到 HasSpaceAvailable 事件")
                break
            case NSStreamEvent.HasBytesAvailable:
                break
            case NSStreamEvent.EndEncountered:
                break
            case NSStreamEvent.ErrorOccurred:
                print("接收到 ErrorOccurred 事件")
                break
        default:
            break;
        }
    }
    
}
