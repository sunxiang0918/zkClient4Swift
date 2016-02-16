//: Playground - noun: a place where people can play


import zkClient4Swift
import Foundation

let zkClient = ZkClient(serverstring: "127.0.0.1:2181")

debugPrint(zkClient.connected)

zkClient.connect()

debugPrint(zkClient.connected)


zkClient.getChildren("/ftengine")
