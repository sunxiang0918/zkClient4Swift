//
//  zkOpCode.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/15.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

/**
 ZK的操作码, 见JAVA中的: org.apache.zookeeper.ZooDefs类
 
 - notification:  <#notification description#>
 - create:        <#create description#>
 - delete:        <#delete description#>
 - exists:        <#exists description#>
 - getData:       <#getData description#>
 - setData:       <#setData description#>
 - getACL:        <#getACL description#>
 - setACL:        <#setACL description#>
 - getChildren:   <#getChildren description#>
 - sync:          <#sync description#>
 - ping:          <#ping description#>
 - getChildren2:  <#getChildren2 description#>
 - check:         <#check description#>
 - multi:         <#multi description#>
 - auth:          <#auth description#>
 - setWatches:    <#setWatches description#>
 - sasl:          <#sasl description#>
 - createSession: <#createSession description#>
 - closeSession:  <#closeSession description#>
 - error:         <#error description#>
 */
public enum zkOpCode:Int {
    
    case notification = 0
    case create = 1
    case delete = 2
    case exists = 3
    case getData = 4
    case setData = 5
    case getACL = 6
    case setACL = 7
    case getChildren = 8
    case sync = 9
    case ping = 11
    case getChildren2 = 12
    case check = 13
    case multi = 14
    case auth = 100
    case setWatches = 101
    case sasl = 102
    case createSession = -10
    case closeSession = -11
    case error = -1
}

/**
 ZK的异常操作码
 
 - Ok:                      <#Ok description#>
 - SystemError:             <#SystemError description#>
 - RuntimeInconsistency:    <#RuntimeInconsistency description#>
 - DataInconsistency:       <#DataInconsistency description#>
 - ConnectionLoss:          <#ConnectionLoss description#>
 - MarshallingError:        <#MarshallingError description#>
 - Unimplemented:           <#Unimplemented description#>
 - OperationTimeout:        <#OperationTimeout description#>
 - BadArguments:            <#BadArguments description#>
 - APIError:                <#APIError description#>
 - NoNode:                  <#NoNode description#>
 - NoAuth:                  <#NoAuth description#>
 - BadVersion:              <#BadVersion description#>
 - NoChildrenForEphemerals: <#NoChildrenForEphemerals description#>
 - NodeExists:              <#NodeExists description#>
 - NotEmpty:                <#NotEmpty description#>
 - SessionExpired:          <#SessionExpired description#>
 - InvalidCallback:         <#InvalidCallback description#>
 - InvalidACL:              <#InvalidACL description#>
 - AuthFailed:              <#AuthFailed description#>
 */
public enum KeeperExceptionCode:Int {
    case Ok = 0
    case SystemError = -1
    case RuntimeInconsistency = -2
    case DataInconsistency = -3
    case ConnectionLoss = -4
    case MarshallingError = -5
    case Unimplemented = -6
    case OperationTimeout = -7
    case BadArguments = -8
    case APIError = -100
    case NoNode = -101
    case NoAuth = -102
    case BadVersion = -103
    case NoChildrenForEphemerals = -108
    case NodeExists = -110
    case NotEmpty = -111
    case SessionExpired = -112
    case InvalidCallback = -113
    case InvalidACL = -114
    case AuthFailed = -115
}

extension KeeperExceptionCode : CustomStringConvertible {
    public var description: String {
        switch self {
        case Ok:return "Ok"
        case SystemError:return "SystemError"
        case RuntimeInconsistency:return "RuntimeInconsistency"
        case DataInconsistency:return "DataInconsistency"
        case ConnectionLoss:return "ConnectionLoss"
        case MarshallingError:return "MarshallingError"
        case Unimplemented:return "Unimplemented"
        case OperationTimeout:return "OperationTimeout"
        case BadArguments:return "BadArguments"
        case APIError:return "APIError"
        case NoNode:return "NoNode"
        case NoAuth:return "NoAuth"
        case BadVersion:return "BadVersion"
        case NoChildrenForEphemerals:return "NoChildrenForEphemerals"
        case NodeExists:return "NodeExists"
        case NotEmpty:return "NotEmpty"
        case SessionExpired:return "SessionExpired"
        case InvalidCallback:return "InvalidCallback"
        case InvalidACL:return "InvalidACL"
        case AuthFailed:return "AuthFailed"
        }
    }
}

/**
 监听事件的枚举
 
 - None:                <#None description#>
 - NodeCreated:         <#NodeCreated description#>
 - NodeDeleted:         <#NodeDeleted description#>
 - NodeDataChanged:     <#NodeDataChanged description#>
 - NodeChildrenChanged: <#NodeChildrenChanged description#>
 */
public enum EventType:Int {
    case None = -1
    case NodeCreated = 1
    case NodeDeleted = 2
    case NodeDataChanged = 3
    case NodeChildrenChanged = 4
}

/**
 事件的状态
 
 - Unknown:           <#Unknown description#>
 - Disconnected:      <#Disconnected description#>
 - NoSyncConnected:   <#NoSyncConnected description#>
 - SyncConnected:     <#SyncConnected description#>
 - AuthFailed:        <#AuthFailed description#>
 - ConnectedReadOnly: <#ConnectedReadOnly description#>
 - SaslAuthenticated: <#SaslAuthenticated description#>
 - Expired:           <#Expired description#>
 */
public enum KeeperState:Int {
    case Unknown = -1
    case Disconnected = 0
    case NoSyncConnected = 1
    case SyncConnected = 3
    case AuthFailed = 4
    case ConnectedReadOnly = 5
    case SaslAuthenticated = 6
    case Expired = -112
}

public enum Perms:Int {
    case READ = 1
    case WRITE = 2
    case CREATE = 4
    case DELETE = 8
    case ADMIN = 16
    case ALL = 31
}

public struct Ids {
    
    public static var ANYONE_ID_UNSAFE:Id {
        get{
            return Id(scheme: "world", id: "anyone");
        }
    }
    
    public static var AUTH_IDS:Id {
        get{
            return Id(scheme: "auth", id: "")
        }
    }
    
    public static var OPEN_ACL_UNSAFE:[ACL] {
        get{
            var acls = [ACL]()
            acls.append(ACL(perms: Perms.ALL.rawValue, id: ANYONE_ID_UNSAFE))
            return acls
        }
    }
    
    public static var CREATOR_ALL_ACL:[ACL] {
        get{
            var acls = [ACL]()
            acls.append(ACL(perms: Perms.ALL.rawValue, id: AUTH_IDS))
            return acls
        }
    }
    
    public static var READ_ACL_UNSAFE:[ACL] {
        get{
            var acls = [ACL]()
            acls.append(ACL(perms: Perms.READ.rawValue, id: ANYONE_ID_UNSAFE))
            return acls
        }
    }
}
