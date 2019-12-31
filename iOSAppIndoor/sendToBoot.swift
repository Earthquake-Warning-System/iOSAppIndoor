//
//  sendToBoot.swift
//  test
//
//  Created by mwnl on 2019/8/28.
//  Copyright © 2019年 mwnl. All rights reserved.
//

import Foundation
import SwiftSocket

//Function to send packet to Bootstrap Server.
public func sendDataToBoot(proto: Data)->Result{
    switch BoostrapServer.send(data: proto){
    case.success:
        return .success
    case .failure(let error):
        return .failure(SocketError.unknownError)
    }
}

