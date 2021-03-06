//: Playground - noun: a place where people can play

import zkClient4Swift
import Foundation

var path = "/Hello2/create"

let range = path.rangeOfString("/", options: .BackwardsSearch)!
path.startIndex.distanceTo(range.startIndex)
let parentDir = path.substringToIndex(range.startIndex)

var outBuffer = StreamOutBuffer()

outBuffer.appendInt(-1)
outBuffer.appendLong(-5)
outBuffer.appendLong(11111111)
outBuffer.appendBool(true)
outBuffer.appendBool(false)
outBuffer.appendString("这个是最恼火的")
outBuffer.appendInt(7)

let data = outBuffer.getBuffer()

let a = Int32(2)

print(data)

let inBuffer = StreamInBuffer(data:data)

print(inBuffer.readInt())
////
print(inBuffer.readLong())
////
print(inBuffer.readLong())
////
print(inBuffer.readBool())
////
print(inBuffer.readBool())
//
print(inBuffer.readString()!)
//
print(inBuffer.readInt())


outBuffer = StreamOutBuffer()

outBuffer.appendInt(0)
outBuffer.appendLong(0)
outBuffer.appendInt(30000)
outBuffer.appendLong(0)
outBuffer.appendString("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
outBuffer.appendBool(false)

print(outBuffer.getBuffer())
