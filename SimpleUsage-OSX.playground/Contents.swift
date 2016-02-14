//: Playground - noun: a place where people can play

import zkClient4Swift
import Foundation

var str = "Hello, playground"

var outBuffer = StreamOutBuffer()

outBuffer.appendInt(2)
outBuffer.appendLong(100)
outBuffer.appendBool(true)
outBuffer.appendBool(false)
outBuffer.appendString("这个是最恼火的")
outBuffer.appendInt(7)

let data = outBuffer.getBuffer()

print(data)

let inBuffer = StreamInBuffer(data:data)

print(inBuffer.readInt())
////
print(inBuffer.readLong())
//
print(inBuffer.readBool())
//
print(inBuffer.readBool())

try print(inBuffer.readString())

print(inBuffer.readInt())


outBuffer = StreamOutBuffer()

outBuffer.appendInt(0)
outBuffer.appendLong(0)
outBuffer.appendInt(30000)
outBuffer.appendLong(0)
outBuffer.appendString("\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
outBuffer.appendBool(false)

print(outBuffer.getBuffer())
