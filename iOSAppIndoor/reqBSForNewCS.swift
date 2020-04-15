//
//  reqBSForNewCS.swift
//  iOSAppIndoor
//
//  Created by mwnlMacbookPro on 2020/4/8.
//  Copyright © 2020 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

public func reqBSForNewCS(){
    bootAsk()
    let unpacket3 = recvDataFromBoot()
    print(unpacket3.PacketType.packetType)
    let decodeData3 = try! BootAsk.parseFrom(data: unpacket3.recvProto as Data)
    print(decodeData3)
    let countryServer = UDPClient(address: decodeData3.serverIp, port: decodeData3.serverPort)
    CountryServer = countryServer
    print(CountryServer.address,CountryServer.port)
    
}
