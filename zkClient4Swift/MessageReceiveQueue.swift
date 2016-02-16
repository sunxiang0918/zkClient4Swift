//
//  MessageReceiveQueue.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/16.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

/// 消息的缓存队列,按照XID来进行缓存.这样做的原因在于Socket的send和read并不是同步的,有可能send后马上read出来的反馈,并不是刚才send出去的哪一个.那么就需要把结果进行缓存.然后再加上同步信号量,从而实现同步的调用和反馈
public class MessageReceiveQueue {
    
    //锁,key为xid. value为有条件的Lock
    private var _lockMap:[Int:NSConditionLock] = [:]
    //响应数据,key为xid,value为响应
    private var _responseMap:[Int:Response] = [:]
    
    /**
     等待xid的响应
     
     - parameter xid: xid
     
     - returns:
     */
    public func waitForResponse(xid:Int) -> Response {
        let lock = NSConditionLock(condition: ReceiveState.WAITING.rawValue)
        
        //放入锁对象
        synchronized(_lockMap){
            self._lockMap[xid] = lock
        }
        
        //等待锁对象变为已接收到响应
        lock.lockWhenCondition(ReceiveState.ARRIVED.rawValue)
        
        //取出响应
        var response:Response?
        synchronized(_responseMap) {
            response = self._responseMap[xid]
        }
        
        //等待锁对象变为等待响应
        lock.unlockWithCondition(ReceiveState.WAITING.rawValue)
        
        //删除锁对象以及响应对象.因为xid使用一次就会自增
        synchronized(_lockMap){
            self._lockMap.removeValueForKey(xid)
        }
        
        synchronized(_responseMap) {
            self._responseMap.removeValueForKey(xid)
        }
        
        return response!
    }
    
    public func appendResponse(response:Response, forXid xid:Int) {
        var _lock:NSConditionLock?
        synchronized(_lockMap){
            _lock = self._lockMap[xid]
        }
        
        if _lock == nil {
            //如果没有请求,就收到了反馈,那么就先把反馈缓存起来
            _lock = NSConditionLock(condition: ReceiveState.WAITING.rawValue)
            //放入锁对象
            synchronized(_lockMap){
                self._lockMap[xid] = _lock!
            }
        }
        
        guard let lock = _lock else {
            print("没有找到xid:\(xid)的Lock")
            return
        }
        
        lock.lockWhenCondition(ReceiveState.WAITING.rawValue)
        
        synchronized(_responseMap) {
            self._responseMap[xid] = response
        }
        
        lock.unlockWithCondition(ReceiveState.ARRIVED.rawValue)
    }
    
    /**
     同步代码块,据说是有问题的: http://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
     
     - parameter lock: 锁对象
     - parameter block: 同步代码块
     */
    private func synchronized( lock:AnyObject, block:() -> Void ){
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        
        block()
    }
}

enum ReceiveState:Int {
    case WAITING = 0
    case ARRIVED = 1
}