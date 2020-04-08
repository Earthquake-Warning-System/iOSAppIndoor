//
//  kpAlive.swift
//  test
//
//  Created by mwnl on 2019/8/27.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

let locale = Locale.current
var failSendingEqEvent = false
//kpAlivepacket to send Server.
public func kpAlive(){
    let test = KpAlive.Builder()
    test.setPacketType("0")
    test.setSensorId((UIDevice.current.identifierForVendor?.uuidString)!)
    test.setCountryCode(locale.regionCode!)
    test.setVersion("2")
    let protoData0: Data = try! test.build().data()
    
    switch sendDataToServer(proto: protoData0){
    case .success:
        print("Client sent message0 to server.")
        kpAliveCount += 1
        kpAliveTime = Date()
    case .failure(let error):
        failSendingEqEvent = true
        print("Client failed to send message0 to server: \(error)")
        
    }
}
