//
//  ConnectResponse.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class ConnectResponse:Deserializable {
    
    private(set) var protocolVersion:Int=0
    private(set) var timeOut:Int=3000
    private(set) var sessionId:Int=0
    private(set) var passwd:String="".stringByPaddingToLength(16, withString: "\0", startingAtIndex: 0)
    
    public func deserialize(buf: StreamInBuffer) {
        self.protocolVersion = buf.readInt()
        self.timeOut = buf.readInt()
        self.sessionId = buf.readLong()
        self.passwd = buf.readString() ?? "".stringByPaddingToLength(16, withString: "\0", startingAtIndex: 0)
    }
}
