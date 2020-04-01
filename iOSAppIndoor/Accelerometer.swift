//
//  Accelerometer.swift
//  ios_accelerometer
//
//  Created by mwnl on 2019/8/29.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion
import AVFoundation
import CoreData

var player: AVPlayer?

let queue4 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
let queue5 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
let queue6 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
let queue7 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)

var LastEqTime: Date? = nil
var EqTime: Date? = nil
var SecEqTime: Int? = nil
var uSecEqTime: Double? = nil
var presentEqImage = false
var lastSendCorrectEqEvent:Bool = false
var AccelCorrection:Bool = false
var sendEqEvent:Bool = false
var treadDetect:Bool? = false
var detectoblique:Bool? = false
let timeInterval: TimeInterval = 0.02
var presentAccl = Array(repeating: 0.0, count: 50)
var acclCount = 0

private let countOfCorrected = 300
private let thresholdFactor = 0.012
private let windowSizesForAvgAccZ = 50
private let windowSizesForTurningPoint = 25

var correctSample = 0
var correctedAccZ = 0.0
var averageAccZWindow = CircularArray1<Double>(count: windowSizesForAvgAccZ)
var turningPointWindow = CircularArray2<Double>(count: windowSizesForTurningPoint)

var winOfCurrent = 0.0
var winOfLast1st = 0.0
var winOfLast2nd = 0.0

var turningPointOfCurrent = 0.0
var sumOfTurningPoint = 0.0

var eqThreshold = 0.0
var motionManager = CMMotionManager()

struct Accl{
    var xAccl: Double = 0.0
    var yAccl: Double = 0.0
    var zAccl: Double = 0.0
}

var startDetecting = 0
var xAccl = 0
var yAccl = 0
var zAccl = 0

//stop detecing
func stopAcclUpdate(){
    motionManager.stopAccelerometerUpdates()
}

//start detecting
func startAcclUpdate(){
        guard motionManager.isAccelerometerAvailable else {
            print("The device  cannot support the function.")
            return
        }
        print("Place your device without moving")
        motionManager.accelerometerUpdateInterval = timeInterval
        eqThreshold = sqrt(thresholdFactor)
    let quene = OperationQueue.current
    motionManager.startAccelerometerUpdates(to: quene!, withHandler: {(acclData, error) in
        guard error == nil else {
            print(error!)
            return
        }
        var oriAccZ = 0.0
        var testAccl = Accl()
        testAccl.xAccl = abs((acclData!.acceleration.x) * 10)
        testAccl.yAccl = abs((acclData!.acceleration.y) * 10)
        testAccl.zAccl = abs((acclData!.acceleration.z) * 10)
        
        queue4.async{
            if detectoblique == false{
                if (testAccl.xAccl < 12 && testAccl.xAccl > 7){
                    oriAccZ = testAccl.xAccl
                    xAccl = 1
                }else if (testAccl.yAccl < 12 && testAccl.yAccl > 7){
                    oriAccZ = testAccl.yAccl
                    yAccl = 1
                }else if (testAccl.zAccl < 12 && testAccl.zAccl > 7){
                    oriAccZ = testAccl.zAccl
                    zAccl = 1
                }else{
                    detectoblique = true
                    print("Place the phone without moving.")
                    NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                    stopAcclUpdate()
                    detectoblique = false
                }
                if xAccl == 1{
                    if testAccl.yAccl < -0.5 && testAccl.yAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        stopAcclUpdate()
                    }else if testAccl.zAccl <  -0.5 && testAccl.zAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        stopAcclUpdate()
                    }
                }else if yAccl == 1{
                    if testAccl.xAccl <  -0.5 && testAccl.xAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        stopAcclUpdate()
                    }else if testAccl.zAccl <  -0.5 && testAccl.zAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        stopAcclUpdate()
                    }
                }else if zAccl == 1{
                    if testAccl.xAccl <  -0.5 && testAccl.xAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        stopAcclUpdate()
                    }else if testAccl.yAccl <  -0.5 && testAccl.yAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        stopAcclUpdate()
                    }
                }
                
                //prepare Accl to present in log
                if (oriAccZ != 0.0){
                    if motionManager.isAccelerometerActive {
                        let accZ = oriAccZ - 10
                        if acclCount < 50{
                            presentAccl[acclCount] = accZ
                            acclCount += 1
                        }else{
                            while acclCount > 0{
                                totalAccl += presentAccl[acclCount - 1]
                                acclCount -= 1
                            }
                            presentAccl = Array(repeating: 0.0, count: 50)
                            logAccl = totalAccl / 50.0
                            NotificationCenter.default.post(name: Notification.Name("presentAccl"), object: nil)
                            //logAccl = 0.0
                        }
                        
                        if (isNotYetCorrected()) {
                            correctionSensor(currAccZ: accZ)
                        }else{
                            if startDetecting == 0{
                                AccelCorrection = true
                                print("startDetecting")
                                startDetecting = 1
                            }
                            if (averageAccZWindow.Size == 0) {
                                averageAccZWindow.write(accZ - correctedAccZ)
                            }else {
                                averageAccZWindow.write((7.0 / 8) * averageAccZWindow.array[(averageAccZWindow.writeIndex - 1) % averageAccZWindow.array.count]! + (1.0 / 8) * (accZ - correctedAccZ))
                            }
                        }
                        
                        //Detect the unusual Accl
                        if (isTurningPoint()) {
                            turningPointOfCurrent = winOfLast1st
                            turningPointWindow.write(turningPointOfCurrent)
                            sumOfTurningPoint += turningPointOfCurrent
                            if (isCircularFull()) {
                                let estimatedValue = getEstimatedValue()
                                print(estimatedValue)
                                if(treadDetect == false){
                                    treadDetect = true
                                    queue6.async{
                                        if (isEqOccur(estimatedValue: estimatedValue)) {
                                            if isFirstDetect{
                                                print("isFirstLaunch")
                                                valueOfReliable = 100
                                                LastEqTime = Date()
                                                print(LastEqTime as Any)
                                                let secdate = LastEqTime!.timeIntervalSince1970 + 28800
                                                let x = Int(secdate)
                                                let y  = (secdate - Double(x)) * 1000000
                                                SecEqTime = x
                                                print(SecEqTime as Any)
                                                uSecEqTime = y
                                                print(uSecEqTime as Any)
                                            }else if thisLaunchFirstDetect{
                                                print("thisLaunchFirstDetect")
                                                //fetchCoreData()
                                                print(LastEqTime as Any)
                                                if LastEqTime == nil{
                                                    LastEqTime = Date()
                                                    let secdate = LastEqTime!.timeIntervalSince1970 + 28800
                                                    let x = Int(secdate)
                                                    let y  = (secdate - Double(x)) * 1000000
                                                    SecEqTime = x
                                                    uSecEqTime = y
                                                    valueOfReliable = 50
                                                }else{
                                                    let secdate = LastEqTime!.timeIntervalSince1970 + 28800
                                                    let x = Int(secdate)
                                                    let y  = (secdate - Double(x)) * 1000000
                                                    SecEqTime = x
                                                    uSecEqTime = y
                                                    EqTime = Date()
                                                    dateCount(eqTime: EqTime, lastEqTime: LastEqTime)
                                                    LastEqTime = EqTime
                                                }
                                            }
                                            else if lastSendCorrectEqEvent{
                                                print("lastSendCorrectEqEvent")
                                                lastSendCorrectEqEvent = false
                                                valueOfReliable = 100
                                            }else{
                                                print("recountReliability")
                                                EqTime = Date()
                                                print(EqTime as Any)
                                                let secdate = EqTime!.timeIntervalSince1970 + 28800
                                                let x = Int(secdate)
                                                let y  = (secdate - Double(x)) * 1000000
                                                SecEqTime = x
                                                uSecEqTime = y
                                                dateCount(eqTime: EqTime, lastEqTime: LastEqTime)
                                                LastEqTime = EqTime
                                            }
                                            isFirstDetect = false
                                            thisLaunchFirstDetect = false
                                            queue7.async {
                                                Alert()
                                                sleep(3)
                                                stopAlert()
                                            }
                                            
                                            //presentEqImage = true
                                            NotificationCenter.default.post(name: Notification.Name("presentEqImage"), object: nil)
                                            
                                            //To do something after sendEqEvent
                                            if sendEqEvent == false{
                                                sendEqEvent = true
                                                queue5.async {
                                                    eqEvent()
                                                    sleep(5)
                                                    if sendCorrectEqEvent{
                                                        lastSendCorrectEqEvent = true
                                                        //restore valueOfReliable
                                                        valueOfReliable = 100
                                                        print("Detection is correct.")
                                                    }else{
                                                        //reset valueOfReliable
                                                        valueOfReliable = 10
                                                        print("Detection is incorrect.")
                                                    }
                                                    //wait a minute to resend Eqevent.
                                                    sleep(55)
                                                    sendEqEvent = false
                                                }
                                            }
                                        }
                                    }
                                    //Not to repeat detection
                                    treadDetect = false
                                }
                                sumOfTurningPoint -= turningPointWindow.array[(turningPointWindow.writeIndex - 2) % turningPointWindow.array.count]!
                            }
                        }
                    }
                }
            }
        }
    })
}

func isNotYetCorrected()->Bool{
    if(correctSample != countOfCorrected){
        return true
    }else{
        //print(correctedAccZ)
        return false
    }
}
func correctionSensor(currAccZ: Double) {
    correctSample += 1
    correctedAccZ = correctedAccZ + (currAccZ / Double(countOfCorrected))
}
func isTurningPoint() -> Bool {
    if (averageAccZWindow.Size < 3) {
        return false
    }
    winOfCurrent = averageAccZWindow.array[(averageAccZWindow.writeIndex - 1) % averageAccZWindow.array.count]!
    winOfLast1st = averageAccZWindow.array[(averageAccZWindow.writeIndex - 2) % averageAccZWindow.array.count]!
    winOfLast2nd = averageAccZWindow.array[(averageAccZWindow.writeIndex - 3) % averageAccZWindow.array.count]!
    //print(averageAccZWindow.array)
    if(isLargerPoint() || isSmallerPoint()){
        return true
    }else{
        return false
    }
}
func isLargerPoint()->Bool{
    if(winOfLast1st > winOfCurrent && winOfLast1st > winOfLast2nd){
        return true
    }else{
        return false
    }
}
func isSmallerPoint()->Bool{
    if(winOfLast1st < winOfCurrent && winOfLast1st < winOfLast2nd){
        return true
    }else{
        return false
    }
}
func isCircularFull()->Bool{
    if(turningPointWindow.Size == windowSizesForTurningPoint){
        return true
    }else{
        return false
    }
}

func getEstimatedValue()->Double{
    return abs(sumOfTurningPoint - (turningPointOfCurrent * Double(windowSizesForTurningPoint)))
}
func isEqOccur(estimatedValue: Double)->Bool{
    if(estimatedValue > Double(windowSizesForTurningPoint) * eqThreshold){
        return true
    }else{
        return false
    }
}

public func Alert(){
    if let url = Bundle.main.url(forResource: "Alert", withExtension: "mp3") {
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            //Didn't work
            print(error)
        }
        player = AVPlayer(url: url)
        if player?.rate == 0 {
            player?.play()
        }else{
            player?.pause()
        }
    }
}
public func stopAlert(){
    player?.pause()
}

