//
//  DemoModel.swift
//  zkClient4Swift
//
//  Created by SUN on 16/2/25.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation

public class DemoModel : NSObject,MMTabBarItem {
    
    public var title:String!
    
    public var icon:NSImage?
    
    public var largeImage:NSImage?
    
    public var objectCount:Int = 0
    
    public var objectCountColor:NSColor?
    
    public var isProcessing:Bool = false
    
    public var isEdited:Bool = false
    
    public var hasCloseButton:Bool = true
    
//    @property (copy)   NSString     *title;
//    @property (retain) NSImage      *icon;
//    @property (retain) NSImage      *largeImage;
//    @property (assign) NSInteger    objectCount;
//    @property (retain) NSColor      *objectCountColor;
//    
//    @property (assign) BOOL isProcessing;
//    @property (assign) BOOL isEdited;
//    @property (assign) BOOL hasCloseButton;
    
}