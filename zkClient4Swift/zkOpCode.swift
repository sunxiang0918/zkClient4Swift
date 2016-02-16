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
