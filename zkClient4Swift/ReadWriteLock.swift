//
//  ReadWriteLock.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/20.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class ReadWriteLock {
    
    private var _readMutex:UnsafeMutablePointer<pthread_mutex_t>
    private var _writeMutex:UnsafeMutablePointer<pthread_mutex_t>
    
    private var _readCount:Int = 0
    
    public init(){
        let attr:UnsafeMutablePointer<pthread_mutexattr_t> = UnsafeMutablePointer.alloc(sizeof(pthread_mutexattr_t))
        pthread_mutexattr_init(attr)
        //经压力测试，递归方式可能会导致锁一直wait，SpringOx
        pthread_mutexattr_settype(attr, PTHREAD_MUTEX_NORMAL)
        
        _readMutex = UnsafeMutablePointer.alloc(sizeof(pthread_mutex_t))
        _writeMutex = UnsafeMutablePointer.alloc(sizeof(pthread_mutex_t))
        
        pthread_mutex_init(_readMutex, attr)
        pthread_mutex_init(_writeMutex, attr)
        pthread_mutexattr_destroy(attr)
    }
    
    
    deinit{
        pthread_mutex_destroy(_readMutex)
        pthread_mutex_destroy(_writeMutex)
    }
    
}

public extension ReadWriteLock {
    
    public func readLock() {
        pthread_mutex_lock(_readMutex)
        
        if _readCount >= 0 && ++_readCount == 1 {
            pthread_mutex_lock(_writeMutex)
        }
        
        pthread_mutex_unlock(_readMutex)
    }
    
    public func readUnlock() {
        
        pthread_mutex_lock(_readMutex)
        
        if _readCount > 0 && --_readCount == 0 {
            pthread_mutex_unlock(_writeMutex)
        }
        
        pthread_mutex_unlock(_readMutex)
    }
    
}

public extension ReadWriteLock {

    public func writeLock() {
        pthread_mutex_lock(_writeMutex)
    }
    
    public func writeUnlock() {
        pthread_mutex_unlock(_writeMutex)
    }
}

extension ReadWriteLock : NSLocking {
    
    @objc public func lock() {
        self.writeLock()
    }
    
    @objc public func unlock() {
        self.writeUnlock()
    }
}