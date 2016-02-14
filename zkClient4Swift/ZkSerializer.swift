//
//  ZkSerializer.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/14.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public protocol ZkSerializer {
    
    func serialize(buf:StreamOutBuffer);
    
}
