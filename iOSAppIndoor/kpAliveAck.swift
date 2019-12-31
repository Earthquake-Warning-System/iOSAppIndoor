//
//  kpAliveAck.swift
//  test
//
//  Created by mwnl on 2019/8/27.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//kpAliveAckpacket to send Server.
public func kpAliveAck(){
    let test = KpAliveAck.Builder()
    test.setPacketType("5")
    test.setVersion("2")
    let protoData5: Data = try! test.build().data()
    
    switch sendDataToServer(proto: protoData5){
    case .success:
        print("Connect with countryServer")
    case .failure(let error):
        print("Client failed to send message5 to server: \(error)")
    }
}
