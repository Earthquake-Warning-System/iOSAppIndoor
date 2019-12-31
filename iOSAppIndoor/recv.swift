//
//  recvDataFromServer.swift
//  test
//
//  Created by mwnl on 2019/8/26.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//Function to receive packet to Server.
public func recvDataFromServer()->(PacketType: PacketType, recvProto: Data){
    var(ByteArray, SenderIPAddress, SenderPort) = CountryServer.recv(1024)
    var recvProto = NSData(bytes: ByteArray as! [UInt8], length: ByteArray!.count)
    let unpacket = try! PacketType.parseFrom(data: recvProto as Data)
    return (unpacket, recvProto as Data)
}


