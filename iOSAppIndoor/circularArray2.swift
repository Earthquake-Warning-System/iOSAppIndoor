//
//  circularArray2.swift
//  ios_accelerometer
//
//  Created by mwnl on 2019/9/1.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation

public struct CircularArray2<T> {
    public var array: [T?]
    public var readIndex = 0
    public var writeIndex = 0
    public var Size = 0
    
    public init(count: Int) {
        array = [T?](repeating: nil, count: 25)
    }
    
    public mutating func write(_ element: T) {
        array[writeIndex % array.count] = element
        if(Size < 25){
            Size += 1
        }
        writeIndex += 1
    }
    
    public mutating func read() -> T? {
        if !isEmpty {
            let element = array[readIndex % array.count]
            readIndex += 1
            return element
        } else {
            return nil
        }
    }
    
    fileprivate var availableSpaceForReading: Int {
        return writeIndex - readIndex
    }
    
    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }
    
    fileprivate var availableSpaceForWriting: Int {
        return array.count - availableSpaceForReading
    }
    
    public var isFull: Bool {
        return availableSpaceForWriting == 0
    }
    
}
