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
let queue6 = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)

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
var totalAccl = 0.0

private let countOfCorrected = 300
private let thresholdFactor = 0.012
private let windowSizesForAvgAccZ = 50
private let windowSizesForTurningPoint = 25

var correctSample = 0
var correctedAccZ = 0.0
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
var acclDerection = ""

//stop detecing
func stopAcclUpdate(averageAccZWindow: CircularArray1<Double>, turningPointWindow: CircularArray2<Double>){
    motionManager.stopAccelerometerUpdates()
    //print(averageAccZWindow)
    //print(turningPointWindow)
    /*averageAccZWindow = CircularArray1<Double>(count: windowSizesForAvgAccZ)
    averageAccZWindow.readIndex = 0
    averageAccZWindow.writeIndex = 0
    averageAccZWindow.tailIndex = 49
    averageAccZWindow.Size = 0
    averageAccZWindow.array = [Double](repeating: 0.0, count: 50)
    print(averageAccZWindow)*/
}

//start detecting
func startAcclUpdate(){
    var averageAccZWindow = CircularArray1<Double>(count: windowSizesForAvgAccZ)
    var turningPointWindow = CircularArray2<Double>(count: windowSizesForTurningPoint)
    
    guard motionManager.isAccelerometerAvailable else {
        print("The device  cannot support the function.")
        return
    }
    
    if pressStartDetect{
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
            if detectoblique == false{
                if (testAccl.xAccl < 12 && testAccl.xAccl > 7){
                    oriAccZ = testAccl.xAccl
                    xAccl = 1
                    acclDerection = "x"
                }else if (testAccl.yAccl < 12 && testAccl.yAccl > 7){
                    oriAccZ = testAccl.yAccl
                    yAccl = 1
                    acclDerection = "y"
                }else if (testAccl.zAccl < 12 && testAccl.zAccl > 7){
                    oriAccZ = testAccl.zAccl
                    zAccl = 1
                    acclDerection = "z"
                }else{
                    detectoblique = true
                    print("Place the phone without moving.")
                    NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                    //stopAcclUpdate()
                    sleep(10)
                    detectoblique = false
                }
                
                switch acclDerection{
                case "x":
                    if testAccl.yAccl < -0.5 && testAccl.yAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        //stopAcclUpdate()
                        sleep(10)
                    }else if testAccl.zAccl <  -0.5 && testAccl.zAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        //stopAcclUpdate()
                        sleep(10)
                    }
                case "y":
                    if testAccl.xAccl <  -0.5 && testAccl.xAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        //stopAcclUpdate()
                        sleep(10)
                    }else if testAccl.zAccl <  -0.5 && testAccl.zAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        //stopAcclUpdate()
                        sleep(10)
                    }
                case "z":
                    if testAccl.xAccl <  -0.5 && testAccl.xAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        //stopAcclUpdate()
                        sleep(10)
                    }else if testAccl.yAccl <  -0.5 && testAccl.yAccl > 0.5{
                        print("Place the phone without moving.")
                        NotificationCenter.default.post(name: Notification.Name("humanTouch"), object: nil)
                        //stopAcclUpdate()
                        sleep(10)
                    }
                default:
                    print(error!)
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
                            totalAccl = 0.0
                            NotificationCenter.default.post(name: Notification.Name("presentAccl"), object: nil)
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
                                if (averageAccZWindow.writeIndex  == 0){
                                    let lastIndex = (7.0 / 8) * averageAccZWindow.array[(averageAccZWindow.tailIndex)]!
                                    let currentIndex = (1.0 / 8) * (accZ - correctedAccZ)
                                    averageAccZWindow.write(lastIndex + currentIndex)
                                }else{
                                    let lastIndex = (7.0 / 8) * averageAccZWindow.array[(averageAccZWindow.writeIndex - 1)]!
                                    let currentIndex = (1.0 / 8) * (accZ - correctedAccZ)
                                    averageAccZWindow.write(lastIndex + currentIndex)
                                }
                            }
                        }
                        //Detect the unusual Accl
                        if (isTurningPoint(averageAccZWindow: averageAccZWindow)) {
                            turningPointOfCurrent = winOfLast1st
                            turningPointWindow.write(turningPointOfCurrent)
                            sumOfTurningPoint += turningPointOfCurrent
                            if (isCircularFull(turningPointWindow: turningPointWindow)) {
                                let estimatedValue = getEstimatedValue()
                                //print(estimatedValue)
                                queue6.async{
                                    if(treadDetect == false){
                                        treadDetect = true
                                        if (isEqOccur(estimatedValue: estimatedValue)) {
                                            Alert()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                                                stopAlert()
                                            })
                                            NotificationCenter.default.post(name: Notification.Name("presentEqImage"), object: nil)
                                            whichTypeDetect()
                                            
                                            //To do something after sendEqEvent
                                            if sendEqEvent == false{
                                                sendEqEvent = true
                                                eqEvent()
                                                sleep(5)
                                                if sendCorrectEqEvent{
                                                    lastSendCorrectEqEvent = true
                                                    //restore valueOfReliable
                                                    valueOfReliable = 100
                                                    print("Detection is correct.")
                                                }else{
                                                    //reset valueOfReliable
                                                    if failSendingEqEvent{
                                                        print("valueOfReliable does not be changed.")
                                                    }else{
                                                        valueOfReliable = 10
                                                        print("Detection is incorrect.")
                                                    }
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(55), execute: {
                                                    sendEqEvent = false
                                                    
                                                })
                                                
                                            }
                                        }
                                        treadDetect = false
                                    }
                                    
                                }
                                //Not to repeat detection
                                sumOfTurningPoint -= turningPointWindow.array[(turningPointWindow.writeIndex - 2) % turningPointWindow.array.count]!
                            }
                        }
                    }
                }
            }
            //queue4.async{
            
            //}
        })
    }else{
        stopAcclUpdate(averageAccZWindow: averageAccZWindow, turningPointWindow: turningPointWindow)
    }
    
    
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
func isTurningPoint(averageAccZWindow: CircularArray1<Double>) -> Bool {
    if (averageAccZWindow.Size < 3) {
        return false
    }
    if(averageAccZWindow.writeIndex < 3){
        winOfCurrent = averageAccZWindow.array[(averageAccZWindow.tailIndex)]!
        winOfLast1st = averageAccZWindow.array[(averageAccZWindow.tailIndex - 1)]!
        winOfLast2nd = averageAccZWindow.array[(averageAccZWindow.tailIndex - 2)]!
    }else{
        winOfCurrent = averageAccZWindow.array[(averageAccZWindow.writeIndex - 1) % averageAccZWindow.array.count]!
        winOfLast1st = averageAccZWindow.array[(averageAccZWindow.writeIndex - 2) % averageAccZWindow.array.count]!
        winOfLast2nd = averageAccZWindow.array[(averageAccZWindow.writeIndex - 3) % averageAccZWindow.array.count]!
    }
    
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
func isCircularFull(turningPointWindow: CircularArray2<Double>)->Bool{
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

func whichTypeDetect(){
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
}
class CircularArray{
    //static var averageAccZWindow = CircularArray1<Double>(count: windowSizesForAvgAccZ)
    //static var turningPointWindow = CircularArray2<Double>(count: windowSizesForTurningPoint)
}
