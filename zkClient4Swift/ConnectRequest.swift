//
//  ConnectRequest.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class ConnectRequest:Serializable {
    
    var protocolVersion=0
    var lastZxidSeen=0
    var timeOut=30000
    var sessionId=0
    var passwd="".stringByPaddingToLength(16, withString: "\0", startingAtIndex: 0)
    
    public func serialize(buf: StreamOutBuffer) {
        buf.appendInt(protocolVersion)
        buf.appendLong(lastZxidSeen)
        buf.appendInt(timeOut)
        buf.appendLong(sessionId)
        buf.appendString(passwd)
        buf.appendBool(false)       //readOnly
    }
}