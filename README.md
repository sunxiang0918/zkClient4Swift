# a simple Apache Zookeeper Client for apple swift lang

zkClient4Swift is a simple zookeeper client written in swift2 . Therefore,**it requires xCode 7 to compile**.



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

