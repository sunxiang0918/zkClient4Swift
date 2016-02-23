//
//  Exceptions.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

enum AppException : ErrorType {
    case FormatCastException
    case IllegalArgumentException
    case IllegalFormatException(coinsNeeded: Int)
    case ReceiveResponseTimeout(xid:Int,timeout:Double)
    case AlreadyClosedException
    case ConnectionException(error:String)
    case SendException(error:String)
    case OperationException(code:String,error:String)
}