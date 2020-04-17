//
//  circularArray.swift
//  ios_accelerometer
//
//  Created by mwnl on 2019/8/31.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation

public struct CircularArray1<T> {
    public var array: [T?]
    public var readIndex = 0
    public var writeIndex = 0
    public var tailIndex = 49
    public var Size = 0
    
    public init(count: Int) {
        array = [T?](repeating: nil, count: count)
    }
    
    public mutating func write(_ element: T) {
        array[writeIndex % array.count] = element
        if(Size < 3){
            Size += 1
        }
        writeIndex = (writeIndex + 1) % array.count
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
