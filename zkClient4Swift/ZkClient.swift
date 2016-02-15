//
//  ZkClient.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation


public class ZkClient {
    
    init(serverstring:String,connectionTimeout:Int = 0x7fffffff,sessionTimeout:Int = 30000) {
        
    }
    
    // MARK: 事件的订阅相关
    
    /**
     订阅某个路径的Child变化,调用listener处理事件
     
     - parameter path:     给定的路径
     - parameter listener: 事件发生后的处理
     
     - returns: the current children of the path or null if the zk node with the given path doesn't exist.
     */
    func subscribeChildChanges(path:String,listener:(String,[String])throws->Void) -> [String]{
        
        return watchForChilds(path)
    }
    
    /**
     取消某个路径的Child事件
     
     - parameter path:     给定的路径
     - parameter listener: 事件处理器
     */
    func unsubscribeChildChanges(path:String,listener:(String,[String])throws->Void) {
        
    }
    
    /**
     增加某一个路径的数据变化
     
     - parameter path:        给定的路径
     - parameter dataChange:  数据变化的事件处理
     - parameter dataDeleted: 数据节点删除的事件处理
     */
    func subscribeDataChanges(path:String,dataChange:(String,Any)throws->Void,dataDeleted:((String)throws->Void)?=nil){
        
    }
    
    /**
     取消某一个路径的数据变化事件订阅
     
     - parameter path:        给定的路径
     - parameter dataChange:  数据变化的事件处理
     - parameter dataDeleted: 数据节点删除的事件处理
     */
    func unsubscribeDataChanges(path:String,dataChange:(String,Any)throws->Void,dataDeleted:((String)throws->Void)?=nil){
        
    }
    
    /**
     取消订阅所有的消息处理
     */
    func unsubscribeAll(){
        
    }
    
    /**
     对给定的某个路径增加 Child观察器
     
     - parameter path: 路径
     
     - returns: the current children of the path or null if the zk node with the given path doesn't exist.
     */
    func watchForChilds(path:String) -> [String] {
        
        return [String]()
    }
    
    /**
     对给定的某个路径增加 数据观察器
     
     - parameter path:
     */
    func watchForData(path:String) {
        
    }
    
    // MARK: 节点数据相关
    /**
    创建一个节点
    
    - parameter path:  节点的路径
    - parameter data:  节点数据
    - parameter model: 节点类型
    - parameter createParents: 是否创建父节点,默认为false
    
    - throws:
    
    - returns: 节点的完整路径
    */
    func create(path:String,data:AnyObject? = nil,model:CreateMode,createParents:Bool = false)throws -> String{
        
        return ""
    }
    
    /**
     删除一个节点
     
     - parameter path: 节点的路径
     
     - returns: 删除成功返回true,失败返回false
     */
    func delete(path:String) -> Bool {
        return false
    }
    
    /**
     获取一个节点的数据
    
     - parameter path: 节点数据
     
     - returns: 返回的对象
     */
    func readData(path:String,deserialize:(StreamInBuffer)->AnyObject? = {inBuffer in inBuffer.readString()}) -> AnyObject? {
        return nil
    }
    
    /**
     往一个节点写入一个数据
     
     - parameter path: 节点路径
     - parameter data: 节点数据
     
     - throws:
     */
    func writeData(path:String,data:AnyObject? = nil)throws -> Void {
        
    }
    
    /**
     判断一个路径是否存在
     
     - parameter path: 路径
     
     - returns: 存在返回true,不存在返回false
     */
    func exists(path:String) -> Bool {
        return false
    }
    
    /**
     返回一个节点的子节点
     
     - parameter path: 节点路径
     
     - returns: 子节点,如果当前节点不存在,那么返回nil
     */
    func getChildren(path:String) -> [String]? {
        return nil
    }
    
    /**
     返回一个节点的子节点数
     
     - parameter path: 节点路径
     
     - returns: 如果当前节点不存在,或者没有子节点,返回0
     */
    func countChildren(path:String) -> Int {
        guard let count = self.getChildren(path)?.count else {
            return 0
        }
        
        return count
    }
    
}