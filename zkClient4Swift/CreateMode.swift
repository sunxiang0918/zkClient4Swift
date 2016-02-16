//
//  CreateMode.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public enum CreateMode {
    
    case MODE(Int,Bool,Bool)
    
    public static let PERSISTENT = CreateMode.MODE(0,false,false)
    public static let PERSISTENT_SEQUENTIAL = CreateMode.MODE(2,false,true)
    public static let EPHEMERAL = CreateMode.MODE(1,true,false)
    public static let EPHEMERAL_SEQUENTIAL = CreateMode.MODE(3,true,true)
    
    func isPersistent() -> Bool{
        switch self {
        case .MODE(_,let ephemeral,_):
            return !ephemeral
        }
    }
    
    func isSequential() -> Bool{
        switch self {
        case .MODE(_,_,let sequential):
            return sequential
        }
    }
    
    func toFlag() -> Int {
        switch self {
        case .MODE(let flag,_,_):
            return flag
        }
    }
    
    func fromFlag(flag:Int)throws -> CreateMode {
        switch flag {
        case 0: return CreateMode.PERSISTENT
        case 1: return CreateMode.PERSISTENT_SEQUENTIAL
        case 2: return CreateMode.EPHEMERAL
        case 3: return CreateMode.EPHEMERAL_SEQUENTIAL
        default: throw AppException.IllegalArgumentException
        }
    }
}
