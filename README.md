# a simple Apache Zookeeper Client for apple swift lang

zkClient4Swift is a simple zookeeper client written in swift2 . Therefore,**it requires xCode 7 to compile**.

Swift已经开源了,并且支持Linux上运行.以后Swift不仅仅可以用来写IOS程序,还可以来做其他的后端程序甚至服务端程序.而Zookeeper在分布式服务系统中是必须的基石,像codis,kafka等都需要依赖zookeeper.因此,需要涉及到zookeeper的连接,而我在网上搜索了一遍,目前还没有Swift的Zookeeper的客户端.因此,就自己实现了一个,目前可能还不完善,有需要的兄弟自取吧.

# Features

* zookeeper服务器的连接      OK
* 节点的基本操作				OK
* 节点变化的监听				OK
* 断线重连,网络闪断重试			TODO
* 基于framework做一个Mac版的ZK的本地客户端.现在大家都是用的ZooInspector.jar   TODO

# issues
已知问题:

* 在MACOS上 需要把zookeeper的session超时时间设置为20秒以上. 因为心跳的线程,不知道为什么,有时会卡住11秒左右...发现是sleep(1)这个地方卡住的,还没有找到原因. 但是在IOS上就没有发现这个问题...

# Blog:
[翔妖除魔的个人博客](http://sunxiang0918.cn)

# api usage
## create client

```swift
//create a zkClient connect to 127.0.0.1 and port at 2181
//TODO not supoort zookeeper cluster
let zkClient = ZkClient(serverstring: "127.0.0.1:2181")
```

## connect to Zookeeper

```swift
zkClient.connect()
```

## get Children Node

```swift
let children = zkClient.getChildren("/hello")
for child in  children! {
    print("subNode:\(child)")
}
```

## check Node exists

```swift
print("check node exists:\(zkClient.exists("/aaaaaaa"))")
```

## delete the node

```swift
print("delete successed:\(zkClient.delete("/Hello/delete"))")
```

## create the node

```swift
//create node by CreateMode.PERSISTENT
try zkClient.create("/Hello/create2", model: CreateMode.PERSISTENT)

//create node by CreateMode.PERSISTENT and need create parent
try zkClient.create("/Hello2/create2",model: CreateMode.PERSISTENT,createParents:true)

//create node by CreateMode.PERSISTENT with data
try zkClient.create("/Hello/create", data: "试一试中文", model: CreateMode.PERSISTENT)
```

## read the node data

```swift
//default type is String
zkClient.readData("/Hello/create")
```
### write the node data

```swift
//write String to node
try zkClient.writeData("/Hello/create2",data: "试一试写入数据")
```

### subscribe child changes

```swift
zkClient.subscribeChildChanges("/Hello", listenerName: "HelloChildChanges") { (path, children) -> Void in
            print("路径:\(path)子节点发生变化:")
            if let cc  = children {
                for c in cc {
                    print("\(c)")
                }
            }
        }
```

### subscribe node data changes

```swift
zkClient.subscribeDataChanges("/Hello/Byte", listenerName: "ByteNodeDataChanges") { (path, data) -> Void in
            print("路径:\(path)节点内容发生变化,新的内容为:\(data)")
        }
```

### subscribe node delete

```swift
zkClient.subscribeDataDelete("/Hello/Byte", listenerName: "ByteNodeDelete") { (path) -> Void in
            print("路径节点:\(path)被删除")
        }
```

### unsubscribe child changes

```swift
zkClient.unsubscribeChildChanges("/Hello", listenerName: "HelloChildChanges")
```

### unsubscribe node data changes

```swift
zkClient.unsubscribeDataChanges("/Hello", listenerName: "HelloChildChanges")
```

### unsubscribe node data delete

```swift
zkClient.unsubscribeDataDelete("/Hello/Byte", listenerName: "ByteNodeDelete")
```
