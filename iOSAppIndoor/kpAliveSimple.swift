//
//  kpAliveSimple.swift
//  iOSAppIndoor
//
//  Created by mwnlMacbookPro on 2020/3/17.
//  Copyright © 2020 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket
public func kpAliveSimple(){
    let test = KpAlive.Builder()
    test.setPacketType("5")
    
    let protoData5: Data = try! test.build().data()
    
    switch sendDataToServer(proto: protoData5){
    case .success:
        print("Client sent message5 to server.")
    case .failure(let error):
        print("Client failed to send message5 to server: \(error)")
    }
}
