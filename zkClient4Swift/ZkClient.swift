//
//  ZkClient.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation


public class ZkClient {
    
    private var _closed = true
    
    private(set) public var connected = false
    
    private var _connection:TCPClient
    
    private var _connectionTimeout:Int
    
    private var _sessionTimeout:Int
    
    private let _eventLoopQueue:dispatch_queue_t
    private let _connsema:dispatch_semaphore_t
    
    //是否能处理的一个线程同步的信号量
    private var _handleability = dispatch_semaphore_create(0)
    
    private let _receiveMessageQueue = MessageReceiveQueue()
    
    private var _xid = 0
    
    public init(serverstring:String,connectionTimeout:Int = 2147483647,sessionTimeout:Int = 30000) {
        
        _connectionTimeout = connectionTimeout
        _sessionTimeout = sessionTimeout
        
        // 解析IP地址和端口,暂时不支持集群
        func generateHostAndPort(serverString:String) ->(String,Int) {
            
            let parts = serverString.componentsSeparatedByString(":")
            
            return (parts[0],parts.count>1 ? Int(parts[1])! : 0)
        }
        
        let (host,port) = generateHostAndPort(serverstring)
        
        print("链接地址:addr:\(host) port:\(port)")
        
        //TODO 暂时还不支持集群的连接
        _connection = TCPClient(addr: host, port: port)
        
        //创建消息接收监听的信号量
        _connsema = dispatch_semaphore_create(0)
        _eventLoopQueue = dispatch_queue_create("event.queue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(_eventLoopQueue) { () -> Void in
            self.asyncRecvEvent()
        }
    }
    
    public func connect() {
        
        //打开Socket连接
        let (success,errMsg) = _connection.connect(timeout: self._sessionTimeout)
        
        if  !success {
            print("打开连接失败"+errMsg)
        }
        
        //打开可以处理消息的信号量
//        dispatch_semaphore_signal(_handleability)
        
        //发送ZK连接的命令
        self.sendConnectionRequest()
        
        //等待连接成功
        dispatch_semaphore_wait(_connsema, DISPATCH_TIME_FOREVER);
    }
    
    // MARK: 事件的订阅相关
    
    /**
     订阅某个路径的Child变化,调用listener处理事件
     
     - parameter path:     给定的路径
     - parameter listener: 事件发生后的处理
     
     - returns: the current children of the path or null if the zk node with the given path doesn't exist.
     */
    public func subscribeChildChanges(path:String,listener:(String,[String])throws->Void) -> [String]{
        
        return watchForChilds(path)
    }
    
    /**
     取消某个路径的Child事件
     
     - parameter path:     给定的路径
     - parameter listener: 事件处理器
     */
    public func unsubscribeChildChanges(path:String,listener:(String,[String])throws->Void) {
        
    }
    
    /**
     增加某一个路径的数据变化
     
     - parameter path:        给定的路径
     - parameter dataChange:  数据变化的事件处理
     - parameter dataDeleted: 数据节点删除的事件处理
     */
    public func subscribeDataChanges(path:String,dataChange:(String,Any)throws->Void,dataDeleted:((String)throws->Void)?=nil){
        
    }
    
    /**
     取消某一个路径的数据变化事件订阅
     
     - parameter path:        给定的路径
     - parameter dataChange:  数据变化的事件处理
     - parameter dataDeleted: 数据节点删除的事件处理
     */
    public func unsubscribeDataChanges(path:String,dataChange:(String,Any)throws->Void,dataDeleted:((String)throws->Void)?=nil){
        
    }
    
    /**
     取消订阅所有的消息处理
     */
    public func unsubscribeAll(){
        
    }
    
    /**
     对给定的某个路径增加 Child观察器
     
     - parameter path: 路径
     
     - returns: the current children of the path or null if the zk node with the given path doesn't exist.
     */
    public func watchForChilds(path:String) -> [String] {
        
        return [String]()
    }
    
    /**
     对给定的某个路径增加 数据观察器
     
     - parameter path:
     */
    public func watchForData(path:String) {
        
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
    public func create(path:String,data:AnyObject? = nil,model:CreateMode,createParents:Bool = false)throws -> String{
        
        return ""
    }
    
    /**
     删除一个节点
     
     - parameter path: 节点的路径
     
     - returns: 删除成功返回true,失败返回false
     */
    public func delete(path:String) -> Bool {
        
        let deleteRequest = DeleteRequest()
        deleteRequest.path = path
        
        //执行命令,并得到结果
        guard let resposne = execute(message: deleteRequest, asType: .delete) else {
            //TODO 这里应该需要处理错误的情况
            return false
        }
        
        return resposne.header.error == 0
        
    }
    
    /**
     获取一个节点的数据
    
     - parameter path: 节点数据
     
     - returns: 返回的对象
     */
    public func readData(path:String,deserialize:(StreamInBuffer)->AnyObject? = {inBuffer in inBuffer.readString()}) -> AnyObject? {
        return nil
    }
    
    /**
     往一个节点写入一个数据
     
     - parameter path: 节点路径
     - parameter data: 节点数据
     
     - throws:
     */
    public func writeData(path:String,data:AnyObject? = nil)throws -> Void {
        
    }
    
    /**
     判断一个路径是否存在
     
     - parameter path: 路径
     
     - returns: 存在返回true,不存在返回false
     */
    public func exists(path:String) -> Bool {
        
        let existsRequest = ExistsRequest()
        existsRequest.path = path
        
        //执行命令,并得到结果
        guard let resposne = execute(message: existsRequest, asType: .exists) else {
            //TODO 这里应该需要处理错误的情况
            return false
        }
        
        let existsResponse = ExistsResponse()
        existsResponse.deserialize(StreamInBuffer(data: resposne.data))
        
        return existsResponse.exists
    }
    
    /**
     返回一个节点的子节点
     
     - parameter path: 节点路径
     
     - returns: 子节点,如果当前节点不存在,那么返回nil
     */
    public func getChildren(path:String) -> [String]? {
        
        let getChildrenRequest = GetChildrenRequest()
        getChildrenRequest.path = path
        
        //执行命令,并得到结果
        guard let resposne = execute(message: getChildrenRequest, asType: .getChildren2) else {
            //TODO 这里应该需要处理错误的情况
            return nil
        }
        
        let getChildrenResponse = GetChildrenResponse()
        getChildrenResponse.deserialize(StreamInBuffer(data: resposne.data))
        
        return getChildrenResponse.children
    }
    
    /**
     返回一个节点的子节点数
     
     - parameter path: 节点路径
     
     - returns: 如果当前节点不存在,或者没有子节点,返回0
     */
    public func countChildren(path:String) -> Int {
        guard let count = self.getChildren(path)?.count else {
            return 0
        }
        
        return count
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
        
        sendMessage(outBuf)
    }
    
    /**
     执行命令的发送,并整理响应
     
     - parameter msg:  消息
     - parameter type: 事件类型
     */
    private func execute(message msg:Serializable,asType type:zkOpCode) -> Response? {
        
        //先生成请求的Header
        let requestHeader = RequestHeader()
        requestHeader.xid = getAndIncrementXid()
        requestHeader.type = type
        
        //构造出整个请求
        let buffer = StreamOutBuffer()
        requestHeader.serialize(buffer)
        msg.serialize(buffer)
        
        //发送请求
        self.sendMessage(buffer)
        
        //阻塞的等待结果的响应
        return _receiveMessageQueue.waitForResponse(requestHeader.xid)
    }
    
    /**
     发送消息
     TODO 发送消息现在还是同步的,后面可能会需要改成异步的
     - parameter outBuf:
     */
    private func sendMessage(outBuf:StreamOutBuffer) {
        
        func appendLength(data:NSData) ->NSData {
            //这里在发送消息前,需要把消息的最前端加上长度
            let _data = NSMutableData()
            _data.appendInt(data.length)
            _data.appendData(data)
            return _data
        }
        
        let message = appendLength(outBuf.getBuffer())
        
        let (success,errMsg) = _connection.send(data: message)
        
        if !success {
            //TODO 还没有处理失败的情况
            print("发送消息失败"+errMsg)
        }
        
        //打开可以处理消息的信号量
        dispatch_semaphore_signal(_handleability)
    }
    
    private func asyncRecvEvent(){
        while true {
            //用于阻止线程在还没有打开连接的时候就开始不断的循环了
            dispatch_semaphore_wait(_handleability, DISPATCH_TIME_FOREVER)
            
            //到这的肯定是可以读取内容了
            guard let uints = _connection.read(102400, timeout: _sessionTimeout) else {
                continue
            }
            
            let data = NSData(uints: uints)
            
            //获取到数据的长度
            let msglen = data.getInt()
            
            //获取到真实的数据
            let inBuf = StreamInBuffer(data: data.subdataWithRange(NSRange(location:sizeof(UInt32),length:msglen)))
            
            //TODO 这里还要判断是否是连接的回调消息
            if(!connected){
                //如果还没有连接,那么这个地方获取到的消息一定是 连接回调
                let connectResponse = ConnectResponse()
                connectResponse.deserialize(inBuf)
                
                self.connected = true
                
                dispatch_semaphore_signal(_connsema);
            }else{
                
                //解析消息的头
                let header = ReplyHeader()
                header.deserialize(inBuf)
                
//                let headerLength = header.headerLength      //获取消息头的长度
                
                let realData = inBuf.getData()      //获取除了头以外的所有数据
                
                let response = Response(header: header, data: realData)
                
                _receiveMessageQueue.appendResponse(response, forXid: header.xid)
                
            }
            
        }
    }
    
    private func getAndIncrementXid() -> Int {
        
        var xid = 0
        synchronized(_xid) { () -> Void in
            xid = self._xid + 1
            self._xid = Int(xid)
        }
        
        return xid
    }
}