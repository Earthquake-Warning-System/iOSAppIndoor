//
//  eqEvent.swift
//  test
//
//  Created by mwnl on 2019/8/27.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//eqEventpacket to send Server.
public func eqEvent(){
    let test = EqEvent.Builder()
    test.setPacketType("1")
    test.setSensorId((UIDevice.current.identifierForVendor?.uuidString)!)
    test.setEventOutput(UInt32(valueOfReliable))
    test.setEventSec(Int64(SecEqTime!))
    test.setEventUsec(Int64(uSecEqTime!))
    test.setVersion("2")
    let protoData1: Data = try! test.build().data()
    
    switch sendDataToServer(proto: protoData1){
    case .success:
        print(valueOfReliable)
        print("Shake Occurring!")
        print("Client sent message1 to server.")
    case .failure(let error):
        valueOfReliable = 100
        print("Client failed to send message1 to server: \(error)")
    }
}

