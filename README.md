# a simple Apache Zookeeper Client for apple swift lang

zkClient4Swift is a simple zookeeper client written in swift2 . Therefore,**it requires xCode 7 to compile**.

Swift已经开源了,以后Swift不仅仅可以用来写IOS程序,还可以来做其他的后端程序等等.因此,有可能会需要涉及到zookeeper的连接,网上搜索了一遍,目前还没有Swift的Zookeeper的客户端.因此,就自己实现了一个,目前可能还不完善,有需要的兄弟自取吧.

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

