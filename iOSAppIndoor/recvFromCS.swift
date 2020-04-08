//
//  recvFromCS.swift
//  iOSAppIndoor
//
//  Created by mwnl on 2019/9/24.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

var getCSResponse: Bool = false
var countCSResponse = 0

//Function to receive packet to Country Server.
public func recvCSKpalive(packetType: PacketType, recvProto: Data){
    print(packetType.packetType)
    let decodeData0 = try! KpAlive.parseFrom(data: recvProto as Data)
    print(decodeData0)
    getCSResponse = true
    getNewCS = true
    failSendingEqEvent = false
    countCSResponse = 3
}

