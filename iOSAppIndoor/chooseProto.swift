//
//  chooseProto.swift
//  test
//
//  Created by mwnl on 2019/8/27.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//unpack packet from Server
public func chooseProto(packetType: PacketType, recvProto: Data){
    switch packetType.packetType {
    case "0":
        recvCSKpalive(packetType: packetType, recvProto: recvProto)
        break
    case "2":
        let decodeData2 = try! EqOccur.parseFrom(data: recvProto as Data)
        sendCorrectEqEvent = true
        print("Shake Occurred")
        print(decodeData2)
        var l = 0
        if l < 4{
            if deviceToken[l].count > 5{
                let sender = PushNotificationSender()
                sender.sendPushNotification(to: deviceToken[l], title: "Warning", body: "Sharking Detected")
            }
            l += 1
        }
        break
    case "3":
        let decodeData3 = try! BootAsk.parseFrom(data: recvProto as Data)
        print(decodeData3)
        getNewCS = true
        let countryServer = UDPClient(address: decodeData3.serverIp, port: decodeData3.serverPort)
        CountryServer = countryServer
        print(CountryServer.address,CountryServer.port)
        kpAliveAck()
        print("Reconnect with countryServer/n")
        break
    case "5":
        let decodeData5 = try! KpAliveAck.parseFrom(data: recvProto as Data)
        print(decodeData5)
        break
    default:
        print("Cannot decode")
    }
}
