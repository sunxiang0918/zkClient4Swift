//
//  ZkClient.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation


public class ZkClient {
    
    private var _closed = false     //是否关闭
    
    private(set) public var connected = false       //是否连接
    
    private var _connection:SimpleSocket        //Socket
    
    private var _connectionTimeout:Int      //连接超时时间
    
    private var _sessionTimeout:Int     //Session超时时间
    
    private let _eventLoopQueue:dispatch_queue_t        //事件处理异步队列
    private let _notifyLoopQueue:dispatch_queue_t       //消息通知异步线程
    private let _resubscriptLoopQueue:dispatch_queue_t
    
    private let _connsema:dispatch_semaphore_t      //连接信号量
    private let _sendsemaphore:dispatch_semaphore_t     //发送信号量
    private let _eventLock = NSLock()           //事件的锁
    
    private var _heartbeatThread:dispatch_source_t?     //心跳的异步队列
    
    //是否能处理的一个线程同步的信号量
    private var _readability = dispatch_semaphore_create(0)
    private var _writeability = dispatch_semaphore_create(0)
    
    private var _sendCache:[NSData] = []        //发送队列
    private let _receiveMessageQueue:MessageReceiveQueue       //接收队列
    
    private var _xid = 0        //xid
    
    /// 获取新的XID,ZK使用XID来区分异步的任务的
    private var nextXid:Int {
        get{
            var xid = 0
            synchronized(_xid) { () -> Void in
                xid = self._xid + 1
                self._xid = Int(xid)
            }
            return xid
        }
    }
    
    /// 事件的监听器
    private var _childListener:[String:[String:(String,[String]?)throws->Void ]] = Dictionary()
    private let _childListenerLock = NSLock()
    private var _dataChangeListener:[String:[String:(String,AnyObject?)throws->Void]] = Dictionary()
    private let _dataChangeListenerLock = NSLock()
    private var _dataDeleteListener:[String:[String:(String)throws->Void]] = Dictionary()
    private let _dataDeleteListenerLock = NSLock()
    private var _stateListener:[String:(KeeperState)throws->Void] = Dictionary()
    private let _stateListenerLock = NSLock()
    
    public init(serverstring:String,connectionTimeout:Int = 2147483647,sessionTimeout:Int = 30000) {
        
        _connectionTimeout = connectionTimeout
        _sessionTimeout = sessionTimeout
        
        _receiveMessageQueue = MessageReceiveQueue(timeOut: Double(_sessionTimeout)/1000)
        
        // 解析IP地址和端口,暂时不支持集群
        func generateHostAndPort(serverString:String) ->(String,Int) {
            
            let parts = serverString.componentsSeparatedByString(":")
            
            return (parts[0],parts.count>1 ? Int(parts[1])! : 0)
        }
        
        let (host,port) = generateHostAndPort(serverstring)
        
        //TODO 暂时还不支持集群的连接
        _connection = SimpleSocket(addr: host, port: port)
        
        //创建消息接收监听的信号量
        _connsema = dispatch_semaphore_create(0)
        _sendsemaphore = dispatch_semaphore_create(0)
        _eventLoopQueue = dispatch_queue_create("event.queue", DISPATCH_QUEUE_CONCURRENT);
        _notifyLoopQueue = dispatch_queue_create("notify.queue", DISPATCH_QUEUE_CONCURRENT);
        _resubscriptLoopQueue = dispatch_queue_create("resubscript.queue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(_eventLoopQueue) { () -> Void in
            do{
                try self.asyncSendEvent()
            }catch _ {
                
            }
        }
        
        dispatch_async(_eventLoopQueue) { () -> Void in
            do{
                try self.asyncRecvEvent()
            }catch _ {
                
            }
        }
    }
    
    /**
     打开连接
     */
    public func connect()throws {
        
        if _closed {
            NSLog("此链接已经被关闭了,需要重新实例化才能打开")
            throw AppException.AlreadyClosedException
        }
        
        //打开Socket连接
        let (success,errMsg) = _connection.connect(timeout: self._sessionTimeout)
        
        if  !success {
            throw AppException.ConnectionException(error: errMsg)
        }
        
        _connection.hasSpaceAvailableDelegate = {_ in dispatch_semaphore_signal(self._writeability)}
        _connection.hasBytesAvailableDelegate = {_ in dispatch_semaphore_signal(self._readability)}
        
        _connection.endEncounteredDelegate = {stream in
            
            if stream is NSInputStream {
                self.connected = false
//                print("接收到endEncountered事件")
                //重新连接
                self._connection.reconnection()
//                print("完成重连命令")
                //发送ZK连接的命令
                self.sendConnectionRequest()
            }
            
        }
        
        //发送ZK连接的命令
        self.sendConnectionRequest()
        
        //等待连接成功
        dispatch_semaphore_wait(_connsema, DISPATCH_TIME_FOREVER);
    }
    
    /**
     关闭连接
     */
    public func close()throws {
        
        if self._closed {
            NSLog("此链接已经被关闭了,不能重复关闭")
            throw AppException.AlreadyClosedException
        }
        
        synchronized(_closed) { () -> Void in
            //需要取消所有的事件订阅
            self.unsubscribeAll()
            
            self._connection.close()
            
            self.connected = false
        }
        
        self._closed = true
        
    }
    
    // MARK: 私有方法
    
    /**
    发送ZK连接的命令
    */
    private func sendConnectionRequest(){
        let outBuf = StreamOutBuffer()
        let connectRequest = ConnectRequest()
        connectRequest.timeOut = _sessionTimeout
        connectRequest.serialize(outBuf)
        
        try! sendMessage(outBuf)
    }
    
    /**
     执行命令的发送,并整理响应
     
     - parameter msg:  消息
     - parameter type: 事件类型
     */
    private func execute(message msg:Serializable,asType type:zkOpCode) -> Response? {
        
        //先生成请求的Header
        let requestHeader = RequestHeader()
        requestHeader.xid = nextXid
        requestHeader.type = type
        
        //构造出整个请求
        let buffer = StreamOutBuffer()
        requestHeader.serialize(buffer)
        msg.serialize(buffer)
        
        //阻塞的等待结果的响应
        do{
            //发送请求
            try self.sendMessage(buffer)
            
            return try _receiveMessageQueue.waitForResponse(requestHeader.xid)
        }catch AppException.ReceiveResponseTimeout(let xid,let timeout) {
            NSLog("接收xid:%d的响应超时:%f", xid,timeout)
            return nil
        }catch let e {
            print(e)
            return nil
        }
    }
    
    /**
     发送消息
     - parameter outBuf:
     */
    private func sendMessage(outBuf:StreamOutBuffer)throws {
        
        if _closed {
            NSLog("此链接已经被关闭了,需要重新实例化才能打开")
            throw AppException.AlreadyClosedException
        }
        
        synchronized(_sendCache, block: { () -> Void in
            self._sendCache.append(outBuf.getBuffer())
        })
        
        dispatch_semaphore_signal(_sendsemaphore);
        
    }
    
    /**
     异步发送任务的循环
     */
    private func asyncSendEvent()throws {
        
        while true {
            if _closed {
                NSLog("此链接已经被关闭了,需要重新实例化才能打开")
                throw AppException.AlreadyClosedException
            }
            
            //用于阻止线程在还没有connection的情况下,就开始发送消息了
            dispatch_semaphore_wait(_sendsemaphore, DISPATCH_TIME_FOREVER);
            //用于阻止线程在还没有打开连接的时候就开始不断的循环了
            dispatch_semaphore_wait(_writeability, DISPATCH_TIME_FOREVER)
            
            var data:NSData! = nil
            synchronized(_sendCache, block: { () -> Void in
                data = self._sendCache.removeFirst()
            })
            
            /**
             在消息的最前面增加长度标识
             
             - parameter data:
             
             - returns:
             */
            func appendLength(data:NSData) ->NSData {
                //这里在发送消息前,需要把消息的最前端加上长度
                let _data = NSMutableData()
                _data.appendInt(data.length)
                _data.appendData(data)
                return _data
            }
            
            let message = appendLength(data)
            
            // 发送消息
            let (success,errMsg) = _connection.send(data: message)
            if !success {
                NSLog("发送消息失败:%@", errMsg)
            }
            
//            print("发送消息成功:\(message)")
        }
        
    }
    
    /**
     异步接收消息的处理
     */
    private func asyncRecvEvent()throws {
        while true {
            
            if _closed {
                NSLog("此链接已经被关闭了,需要重新实例化才能打开")
                throw AppException.AlreadyClosedException
            }
            
            //用于阻止线程在还没有打开连接的时候就开始不断的循环了
            dispatch_semaphore_wait(_readability, DISPATCH_TIME_FOREVER)
            
            //到这的肯定是可以读取内容了
            guard let uints = _connection.read(102400, timeout: _sessionTimeout) else {
                NSLog("读取消息错误,没有获取到数据")
                continue
            }
            
            let data = NSData(uints: uints)
            
            //获取到数据的长度
            let msglen = data.getInt()
            
            //获取到真实的数据
            let inBuf = StreamInBuffer(data: data.subdataWithRange(NSRange(location:sizeof(UInt32),length:msglen)))
            
            if(!connected){
                //如果还没有连接,那么这个地方获取到的消息一定是 连接回调
                let connectResponse = ConnectResponse()
                connectResponse.deserialize(inBuf)
                
//                print("接收到连接成功的反馈seesionID:\(connectResponse.sessionId) data:\(inBuf.getData())")
                
                self.connected = true
                
                //设置ping的 后台线程,否则zk会认为你超时了.也就是心跳
                self.setupHeartbeatThread()
                
                dispatch_semaphore_signal(_connsema);
                
                //重新开启事件的订阅
                dispatch_async(_resubscriptLoopQueue) { () -> Void in
                    self.reSubscriptAllListener()
                }
            }else{
                //解析消息的头
                let header = ReplyHeader()
                header.deserialize(inBuf)
                
                let realData = inBuf.getData()      //获取除了头以外的所有数据
                
                // 根据xid的不同,确定不同的事件
                switch header.xid {
                case -1:
                    //这里是消息的通知
                    self.handleNotification(realData)
                    continue
                case -2:
                    //这里是Ping的结果
//                    print("接收到心跳的结果")
                    continue
                default:break
                }
                
//                print("接收到的响应:xid:\(header.xid) zxid:\(header.zxid) 消息体:\(realData)")
                
                /// 把结果放入异步队列
                let response = Response(header: header, data: realData)
                
                _receiveMessageQueue.appendResponse(response, forXid: header.xid)
                
            }
            
        }
    }
    
    private func setupHeartbeatThread() {
        
//        print("重新开启心跳线程")
        
        if _heartbeatThread != nil {
            return
        }
        
        _heartbeatThread = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        
        if let _heartbeat = _heartbeatThread {
            dispatch_source_set_timer(_heartbeat, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC)
            
            dispatch_source_set_event_handler(_heartbeat, { () -> Void in
                
//                print("进入setupHeartbeatThread:\(NSThread.currentThread()) 准备发送心跳 :\(NSDate())")
                
                let outBuf = StreamOutBuffer()
                
                let ping = Ping()
                ping.serialize(outBuf)
                
                do{
                    try self.sendMessage(outBuf)
                }catch _ {
                    NSLog("本次心跳失败")
                }
            })
            
            dispatch_resume(_heartbeat)
        }
    }
    
}


// MARK: - 对Client增加监听方面的增强
public extension ZkClient {
    
    // MARK: 事件的订阅相关
    
    /**
    订阅某个路径的Child变化,调用listener处理事件
    
    - parameter path:     给定的路径
    - parameter listener: 事件发生后的处理
    
    - returns: the current children of the path or null if the zk node with the given path doesn't exist.
    */
    public func subscribeChildChanges(path:String,listenerName:String,listener:(String,[String]?)throws->Void) -> [String]?{
        
        _childListenerLock.lock()
        
        let listeners = _childListener[path]
        
        if listeners == nil {
            _childListener[path] = [:]
        }
        
        _childListener[path]?[listenerName] = listener
        
        _childListenerLock.unlock()
        
        return watchForChilds(path)
    }
    
    /**
     取消某个路径的Child事件
     
     - parameter path:     给定的路径
     - parameter listener: 事件处理器
     */
    public func unsubscribeChildChanges(path:String,listenerName:String) {
        _childListenerLock.lock()
        
        var listeners = _childListener[path]
        
        listeners?.removeValueForKey(listenerName)
        
        _childListenerLock.unlock()
    }
    
    /**
     增加某一个路径的数据变化
     
     - parameter path:        给定的路径
     - parameter listenerName: 监听器的名字
     - parameter listener: 数据变化的事件处理
     */
    public func subscribeDataChanges(path:String,listenerName:String,listener:(String,AnyObject?)throws->Void){
        
        _dataChangeListenerLock.lock()
        
        let listeners = _dataChangeListener[path]
        
        if listeners == nil {
            _dataChangeListener[path] = [:]
        }
        
        _dataChangeListener[path]?[listenerName] = listener
        
        _dataChangeListenerLock.unlock()
        
        watchForData(path)
    }
    
    /**
     取消某一个路径的数据变化事件订阅
     
     - parameter path:        给定的路径
     - parameter listenerName:  监听器的名字
     */
    public func unsubscribeDataChanges(path:String,listenerName:String){
        _dataChangeListenerLock.lock()
        
        var listeners = _dataChangeListener[path]
        
        listeners?.removeValueForKey(listenerName)
        
        _dataChangeListenerLock.unlock()
    }
    
    /**
     订阅节点删除事件
     
     - parameter path:         给定的路径
     - parameter listenerName: 监听器的名字
     - parameter listener:     监听器
     */
    public func subscribeDataDelete(path:String,listenerName:String,listener:(String)throws->Void) {
        _dataDeleteListenerLock.lock()
        
        let listeners = _dataDeleteListener[path]
        
        if listeners == nil {
            _dataDeleteListener[path] = [:]
        }
        
        _dataDeleteListener[path]?[listenerName] = listener
        
        _dataDeleteListenerLock.unlock()
        
        watchForData(path)
    }
    
    public func unsubscribeDataDelete(path:String,listenerName:String){
        _dataDeleteListenerLock.lock()
        
        var listeners = _dataDeleteListener[path]
        
        listeners?.removeValueForKey(listenerName)
        
        _dataDeleteListenerLock.unlock()
    }
    
    /**
     订阅连接状态的事件
     
     - parameter listenerName: 监听器的名字
     - parameter listener:     监听器
     */
    public func subscribeStateChanges(listenerName:String,listener:(KeeperState)throws->Void) {
        _stateListenerLock.lock()
        
        _stateListener[listenerName] = listener
        
        _stateListenerLock.unlock()
    }
    
    /**
     取消订阅
     
     - parameter listenerName: 监听器的名字
     */
    public func unsubscribeStateChanges(listenerName:String) {
        _stateListenerLock.lock()
        
        _stateListener.removeValueForKey(listenerName)
        
        _stateListenerLock.unlock()
    }
    
    /**
     取消订阅所有的消息处理
     */
    public func unsubscribeAll(){
        
        _dataChangeListenerLock.lock()
        _dataChangeListener.removeAll()
        _dataChangeListenerLock.unlock()
        
        _childListenerLock.lock()
        _childListener.removeAll()
        _childListenerLock.unlock()
        
        _dataDeleteListenerLock.lock()
        _dataDeleteListener.removeAll()
        _dataDeleteListenerLock.unlock()
        
        _stateListenerLock.lock()
        _stateListener.removeAll()
        _stateListenerLock.unlock()
    }
    
    private func reSubscriptAllListener() {
        _childListenerLock.lock()
        if _childListener.count > 0 {
            for (path,listeners) in _childListener {
                if listeners.count > 0 {
                    watchForChilds(path)
                    break
                }
            }
        }
        _childListenerLock.unlock()
        
        _dataChangeListenerLock.lock()
        if _dataChangeListener.count > 0 {
            for (path,listeners) in _dataChangeListener {
                if listeners.count > 0 {
                    watchForData(path)
                    break
                }
            }
        }
        _dataChangeListenerLock.unlock()
        
        _dataDeleteListenerLock.lock()
        if _dataDeleteListener.count > 0 {
            for (path,listeners) in _dataDeleteListener {
                if listeners.count > 0 {
                    watchForData(path)
                    break
                }
            }
        }
        _dataDeleteListenerLock.unlock()
    }
    
    /**
     对给定的某个路径增加 Child观察器
     
     - parameter path: 路径
     
     - returns: the current children of the path or null if the zk node with the given path doesn't exist.
     */
    public func watchForChilds(path:String) -> [String]? {
        
        do{
            try exists(path, watch: true)
        
            return try getChildren(path, watch: true);
        }catch AppException.OperationException(let code, let error){
            print("子节点观察器失败:\(code) error:\(error)")
            return nil
        }catch _ {
            return nil
        }
    }
    
    /**
     对给定的某个路径增加 数据观察器
     
     - parameter path:
     */
    public func watchForData(path:String) {
        do{
            try exists(path, watch: true)
        }catch AppException.OperationException(let code, let error){
            print("数据观察器失败:\(code) error:\(error)")
        }catch _ {
        }
    }
    
    // MARK: 私有方法
    
    /**
     异步处理通知事件
     
     - parameter data:
     */
    private func handleNotification(data:NSData) {
        let event = WatcherEvent()
        event.deserialize(StreamInBuffer(data: data))
        
        //这里采用了异步的处理来响应事件
        dispatch_async(_notifyLoopQueue) { () -> Void in
            self.processNotification(event)
        }
        
    }
    
    /**
     异步处理通知事件
     
     - parameter event:
     */
    private func processNotification(event:WatcherEvent) {
        
        let stateChanged = event.path == nil
        let znodeChanged = event.path != nil
        let dataChanged = event.type == EventType.NodeDataChanged.rawValue || event.type == EventType.NodeDeleted.rawValue || event.type == EventType.NodeCreated.rawValue
            || event.type == EventType.NodeChildrenChanged.rawValue
        
        _eventLock.lock()
        defer {
            _eventLock.unlock()
        }
        
        do {
            defer {
                if stateChanged {
                    //先空实现
                }
                
                if znodeChanged {
                    //先空实现
                }
                
                if dataChanged {
                    //先空实现
                }
            }
            
            if stateChanged {
                self.processStateChange(event)
            }
            
            if dataChanged {
                self.processDataOrChildChange(event)
            }
        }catch _{
            
        }
        
    }
    
    /**
     处理ZK状态的变化
     
     - parameter event:
     */
    private func processStateChange(event:WatcherEvent) {
        
        func _fireStateChangeEvents(event:WatcherEvent) {
            
            if _stateListener.count > 0 {
                for (_,listener) in _stateListener {
                    do{
                      try listener(event.stateEnum)
                    }catch let e {
                        print("响应状态变化事件出错:\(e)")
                    }
                }
            }
        }
        
        _fireStateChangeEvents(event)
        
        if event.stateEnum == KeeperState.Expired {
            self.connected = false
            //重新连接
            self._connection.reconnection()
            //发送ZK连接的命令
            self.sendConnectionRequest()
        }
    }
    
    /**
     处理数据节点或子节点的变化
     
     - parameter event:
     */
    private func processDataOrChildChange(event:WatcherEvent) {
        let path = event.path!
        
        func _fireChildChangedEvents(path:String){
            let childListeners = _childListener[path]
            if let tmp = childListeners where tmp.count > 0 {
                fireChildChangedEvents(path,childListeners: tmp)
            }
        }
        
        func _fireDataChangedEvents(path:String) {
            let dataChangeListeners = _dataChangeListener[path]
            if let tmp = dataChangeListeners where tmp.count > 0 {
                fireDataChangedEvents(path,dataChangeListeners: tmp)
            }
        }
        
        func _fireDataDeleteEvents(path:String) {
            let dataDeleteListeners = _dataDeleteListener[path]
            if let tmp = dataDeleteListeners where tmp.count > 0 {
                fireDataDeleteEvents(path,dataDeleteListeners: tmp)
            }
        }
        
        switch event.typeEnum {
        case .NodeChildrenChanged:
            _fireChildChangedEvents(path)
            break
        case .NodeCreated:
            //这个地方的逻辑应该是这样的,zk对于同一个节点的不同类型的监听,只会触发一次通知.
            //由于节点被删除了.那么就需要判断它的父节点是否注册了ChildChangedEvents,如果注册了的,那么同样需要通知出来
            let parentPath = path.substringToIndex(path.rangeOfString("/", options: .BackwardsSearch)!.startIndex)
            _fireChildChangedEvents(parentPath)
            _fireDataChangedEvents(path)
            break
        case .NodeDeleted:
            //这个地方的逻辑应该是这样的,zk对于同一个节点的不同类型的监听,只会触发一次通知.
            //由于节点被删除了.那么就需要判断它的父节点是否注册了ChildChangedEvents,如果注册了的,那么同样需要通知出来
            let parentPath = path.substringToIndex(path.rangeOfString("/", options: .BackwardsSearch)!.startIndex)
            _fireChildChangedEvents(parentPath)
            _fireDataDeleteEvents(path)
            break
        case .NodeDataChanged:
            _fireDataChangedEvents(path)
            break
        default:
            break
        }
    }
    
    private func fireDataDeleteEvents(path:String,dataDeleteListeners:[String:(String)throws->Void]) {
        
        for (name,listener) in dataDeleteListeners {
            
            do{
                try exists(path, watch: true)
                try listener(path)
            } catch let e {
                print("处理节点删除消息监听:\(name) 失败path:\(path) error:\(e)")
            }
            
        }
    }
    
    private func fireDataChangedEvents(path:String,dataChangeListeners:[String:(String,AnyObject?)throws->Void]) {
        
        for (name,listener) in dataChangeListeners {
            
            do{
                try exists(path, watch: true)
                
                let data = try readData(path,watch: true)
                try listener(path,data)
            } catch let e {
                print("处理节点内容变化消息监听:\(name) 失败path:\(path) error:\(e)")
            }
            
        }
    }
    
    private func fireChildChangedEvents(path:String,childListeners:[String:(String,[String]?)throws->Void]){
        
        for (name,listener) in childListeners {
            
            do{
                // if the node doesn't exist we should listen for the root node to reappear
                try exists(path, watch: true)
                
                let children = try getChildren(path,watch: true)
                
                try listener(path, children)
            } catch let e {
                print("处理节点子节点变化消息监听:\(name) 失败path:\(path) error:\(e)")
            }
            
        }
    }
    
    /**
     判断是否有监听
     
     - parameter path: 路径节点
     
     - returns:
     */
    private func hasListeners(path:String) -> Bool {
        
        if let tmp = self._childListener[path] where tmp.count > 0 {
            return true
        }
        
        if let tmp = self._dataChangeListener[path] where tmp.count > 0 {
            return true
        }
        
        if let tmp = self._dataDeleteListener[path] where tmp.count > 0 {
            return true
        }
        
        return false
    }
}

// MARK: - 对节点的基本操作的扩展
public extension ZkClient {
    
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
    public func create(path:String,data:AnyObject? = nil,model:CreateMode,createParents:Bool = false,serialize:(AnyObject?,StreamOutBuffer)->Void = {(obj:AnyObject?,outBuffer:StreamOutBuffer) in outBuffer.appendString((obj ?? "") as? String) })throws -> String{
        
        let createRequest = CreateRequest()
        createRequest.path = path
        let _outBuffer = StreamOutBuffer()
        serialize(data,_outBuffer)
        
        createRequest.data = _outBuffer.getBuffer()
        createRequest.flag = model
        createRequest.acls = Ids.OPEN_ACL_UNSAFE
        
        //执行命令,并得到结果
        guard let response = execute(message: createRequest, asType: .create) else {
            //TODO 这里应该需要处理错误的情况
            return ""
        }
        
        if  response.header.error == KeeperExceptionCode.NoNode.rawValue && createParents {
            //表示没有父节点,需要根据判断来创建父节点
            let parentDir = path.substringToIndex(path.rangeOfString("/", options: .BackwardsSearch)!.startIndex)
            try self.create(parentDir, data: nil, model: model, createParents: createParents, serialize: serialize)
            return try self.create(path, data: data, model: model, createParents: createParents, serialize: serialize)
        }else if response.header.error != KeeperExceptionCode.Ok.rawValue {
            print("创建节点:\(path)失败,错误为:\(response.header.error)")
            throw AppException.OperationException(code: KeeperExceptionCode(rawValue: response.header.error)!.description,error: "创建节点:\(path)失败,错误为:\(response.header.error)")
        }
        
        let createResponse = CreateResponse()
        createResponse.deserialize(StreamInBuffer(data: response.data))
        
        return createResponse.path ?? ""
        
    }
    
    /**
     删除一个节点
     
     - parameter path: 节点的路径
     
     - returns: 删除成功返回true,失败返回false
     */
    public func delete(path:String)throws -> Bool {
        
        let deleteRequest = DeleteRequest()
        deleteRequest.path = path
        
        //执行命令,并得到结果
        guard let response = execute(message: deleteRequest, asType: .delete) else {
            //TODO 这里应该需要处理错误的情况
            return false
        }
        
        if response.header.error != KeeperExceptionCode.Ok.rawValue {
            print("删除节点:\(path) 失败,错误为:\(response.header.error)")
            throw AppException.OperationException(code: KeeperExceptionCode(rawValue: response.header.error)!.description,error: "删除节点:\(path) 失败,错误为:\(response.header.error)")
        }
        
        return response.header.error == KeeperExceptionCode.Ok.rawValue
        
    }
    
    /**
     获取一个节点的数据
     
     - parameter path: 节点数据
     
     - returns: 返回的对象
     */
    public func readData(path:String,watch:Bool? = nil,deserialize:(StreamInBuffer)->AnyObject? = {inBuffer in inBuffer.readString()})throws -> AnyObject? {
        
        let getDataRequest = GetDataRequest()
        getDataRequest.path = path
        getDataRequest.watch = watch ?? hasListeners(path)
        
        //执行命令,并得到结果
        guard let response = execute(message: getDataRequest, asType: .getData) else {
            //TODO 这里应该需要处理错误的情况
            return nil
        }
        
        if response.header.error != KeeperExceptionCode.Ok.rawValue {
            print("获取节点:\(path)数据 失败,错误为:\(response.header.error)")
            throw AppException.OperationException(code: KeeperExceptionCode(rawValue: response.header.error)!.description,error: "获取节点:\(path)数据 失败,错误为:\(response.header.error)")
        }
        
        let getDataResponse = GetDataResponse()
        getDataResponse.deserialize(StreamInBuffer(data: response.data))
        
        
        guard let data = getDataResponse.data else {
            return nil
        }
        
        return deserialize(StreamInBuffer(data:data))
    }
    
    /**
     往一个节点写入一个数据
     
     - parameter path: 节点路径
     - parameter data: 节点数据
     
     - throws:
     */
    public func writeData(path:String,data:AnyObject? = nil,serialize:(AnyObject?,StreamOutBuffer)->Void = {(obj:AnyObject?,outBuffer:StreamOutBuffer) in outBuffer.appendString((obj ?? "") as? String) })throws -> Bool {
        
        let setDataRequest = SetDataRequest()
        
        setDataRequest.path = path
        let _outBuffer = StreamOutBuffer()
        serialize(data,_outBuffer)
        setDataRequest.data = _outBuffer.getBuffer()
        
        //执行命令,并得到结果
        guard let response = execute(message: setDataRequest, asType: .setData) else {
            //TODO 这里应该需要处理错误的情况
            return false
        }
        
        if response.header.error != KeeperExceptionCode.Ok.rawValue {
            print("写入节点:\(path) 数据 失败,错误为:\(response.header.error)")
            throw AppException.OperationException(code: KeeperExceptionCode(rawValue: response.header.error)!.description,error: "写入节点:\(path) 数据 失败,错误为:\(response.header.error)")
        }
        
        return response.header.error == KeeperExceptionCode.Ok.rawValue
    }
    
    /**
     判断一个路径是否存在
     
     - parameter path: 路径
     
     - returns: 存在返回true,不存在返回false
     */
    public func exists(path:String,watch:Bool? = nil)throws -> Bool {
        
        let existsRequest = ExistsRequest()
        existsRequest.path = path
        existsRequest.watch = watch ?? hasListeners(path)
        
        //执行命令,并得到结果
        guard let response = execute(message: existsRequest, asType: .exists) else {
            //TODO 这里应该需要处理错误的情况
            return false
        }
        
        if response.header.error != KeeperExceptionCode.Ok.rawValue {
            print("检测节点:\(path) 是否存在 失败,错误为:\(response.header.error)")
            throw AppException.OperationException(code: KeeperExceptionCode(rawValue: response.header.error)!.description,error: "检测节点:\(path) 是否存在 失败,错误为:\(response.header.error)")
        }
        
        let existsResponse = ExistsResponse()
        existsResponse.deserialize(StreamInBuffer(data: response.data))
        
        return existsResponse.exists
    }
    
    /**
     返回一个节点的子节点
     
     - parameter path: 节点路径
     
     - returns: 子节点,如果当前节点不存在,那么返回nil
     */
    public func getChildren(path:String,watch:Bool? = nil)throws -> [String]? {
        
        let getChildrenRequest = GetChildrenRequest()
        getChildrenRequest.path = path
        getChildrenRequest.watch = watch ?? hasListeners(path)
        
        //执行命令,并得到结果
        guard let response = execute(message: getChildrenRequest, asType: .getChildren2) else {
            //TODO 这里应该需要处理错误的情况
            return nil
        }
        
        if response.header.error != KeeperExceptionCode.Ok.rawValue {
            print("获取节点:\(path) 子节点失败,错误为:\(response.header.error)")
            throw AppException.OperationException(code: KeeperExceptionCode(rawValue: response.header.error)!.description,error: "获取节点:\(path) 子节点失败,错误为:\(response.header.error)")
        }
        
        let getChildrenResponse = GetChildrenResponse()
        getChildrenResponse.deserialize(StreamInBuffer(data: response.data))
        
        return getChildrenResponse.children
    }
    
    /**
     返回一个节点的子节点数
     
     - parameter path: 节点路径
     
     - returns: 如果当前节点不存在,或者没有子节点,返回0
     */
    public func countChildren(path:String)throws -> Int {
        guard let count = try self.getChildren(path)?.count else {
            return 0
        }
        
        return count
    }
    
}