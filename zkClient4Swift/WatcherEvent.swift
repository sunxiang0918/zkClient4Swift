//
//  WatcherEvent.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/17.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class WatcherEvent:Serializable,Deserializable {
    
    public var type:Int = 0
    public var state:Int = 0
    public var path:String?
    
    public var typeEnum:EventType {
        get {
            return EventType(rawValue: type)!
        }
    }
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendInt(type)
        buf.appendInt(state)
        buf.appendString(path)
    }
    
    public func deserialize(buf: StreamInBuffer) {
        type = buf.readInt()
        state = buf.readInt()
        path = buf.readString()
    }
    
    
}