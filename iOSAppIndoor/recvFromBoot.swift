//
//  recvFromBoot.swift
//  test
//
//  Created by mwnl on 2019/8/28.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//Function to receive packet to Bootstrap Server.
public func recvDataFromBoot()->(PacketType: PacketType, recvProto: Data){
    var(ByteArray, SenderIPAddress, SenderPort) = BoostrapServer.recv(1024)
    
    if(ByteArray == nil){
        let gotNo = NSData(bytes: ByteArray as! [UInt8], length: ByteArray!.count)
        let noData = try! PacketType.parseFrom(data: gotNo as Data)
        return(noData,gotNo as Data)
    }else{
        var recvProto = NSData(bytes: ByteArray as! [UInt8], length: ByteArray!.count)
        let unpacket = try! PacketType.parseFrom(data: recvProto as Data)
        return (unpacket, recvProto as Data)
    }
}
