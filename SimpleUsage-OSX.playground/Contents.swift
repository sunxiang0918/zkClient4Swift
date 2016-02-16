//: Playground - noun: a place where people can play


import zkClient4Swift
import Foundation

let zkClient = ZkClient(serverstring: "127.0.0.1:2181")

debugPrint(zkClient.connected)

zkClient.connect()

debugPrint(zkClient.connected)


let children = zkClient.getChildren("/ftengine")

for child in  children! {
    print("子节点:\(child)")
}

print("节点是否存在:\(zkClient.exists("/aaaaaaa"))")
print("节点是否存在:\(zkClient.exists("/ftengine"))")

print("是否删除节点成功:\(zkClient.delete("/Hello/delete"))")