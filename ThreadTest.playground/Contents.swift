//: Playground - noun: a place where people can play

import Cocoa
import zkClient4Swift

var str = "Hello, playground"

let lock = ReadWriteLock()


// 创建任务对象
let operation = NSBlockOperation { () -> Void in
    
    //开始第一个线程的读
    while true {
        NSThread.sleepForTimeInterval(1)
        lock.readLock()
        print("第一个读线程:\(NSDate())")
        lock.readUnlock()
    }
}

// 增加执行的闭包
operation.addExecutionBlock { () -> Void in
    //开始第一个线程的读
    while true {
        NSThread.sleepForTimeInterval(1)
        lock.readLock()
        print("第二个读线程:\(NSDate())")
        lock.readUnlock()
    }
}

// 增加执行的闭包
operation.addExecutionBlock { () -> Void in
    //开始第一个线程的读
        NSThread.sleepForTimeInterval(10)
        lock.writeLock()
        print("第一个写线程,开始10秒钟,:\(NSDate())")
        NSThread.sleepForTimeInterval(10)
        print("第一个写线程,10秒钟完成,:\(NSDate())")
        lock.writeUnlock()
}

// 开始任务
operation.start()