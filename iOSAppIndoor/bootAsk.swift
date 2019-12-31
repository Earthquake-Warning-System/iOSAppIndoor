//
//  bootAsk.swift
//  test
//
//  Created by mwnl on 2019/8/27.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//bootAskpacket to send Server.
public func bootAsk(){
    let test = BootAsk.Builder()
    test.setPacketType("3")
    test.setVersion("2")
    let protoData3: Data = try! test.build().data()
    
    switch sendDataToBoot(proto: protoData3){
    case .success:
        print("Client sent message3 to server.")
    case .failure(let error):
        print("Client failed to send message3 to server: \(error)")
    }
}
