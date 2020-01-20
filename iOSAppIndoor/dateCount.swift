//
//  dateCount.swift
//  iOSAppIndoor
//
//  Created by mwnl on 2019/9/28.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation

var sendCorrectEqEvent:Bool = false
var thisLaunchFirstDetect = true
var valueOfReliable: Double = 100

public func dateCount(eqTime: Date?, lastEqTime: Date?){

    let LastEqTime = lastEqTime
    let EqTime = eqTime
    
    var timeDiff = Calendar.current.dateComponents( [.year, .month, .day , .hour, .minute, .second], from: LastEqTime!, to: EqTime! )
    
    print(timeDiff)

    if (timeDiff.day! != 0 || timeDiff.month! != 0 || timeDiff.year! != 0){
        valueOfReliable = 100
    }else if timeDiff.hour! < 3{
        valueOfReliable = 10
    }else if timeDiff.hour! >= 3 && timeDiff.hour! < 6{
        valueOfReliable = 15
    }else if timeDiff.hour! >= 6 && timeDiff.hour! < 9{
        valueOfReliable = 25
    }else if timeDiff.hour! >= 9 && timeDiff.hour! < 12{
        valueOfReliable = 40
    }else if timeDiff.hour! >= 12 && timeDiff.hour! < 18{
        valueOfReliable = 60
    }else if timeDiff.hour! >= 18 && timeDiff.hour! < 21{
        valueOfReliable = 85
    }else if timeDiff.hour! >= 21 && timeDiff.hour! < 24{
        valueOfReliable = 100
    }
    print(valueOfReliable)
}


